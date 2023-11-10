locals {
  shared_vars = yamldecode(file("${path.module}/vars.yml"))
}

terraform {
  cloud {
    organization = "datasnok"

    workspaces {
      name = "idata2502-project"
    }
  }

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.9.4"
    }
  }
}

data "hcp_vault_secrets_secret" "linode_token" {
  app_name    = "idata2502-project"
  secret_name = "LINODE_TOKEN"
}

provider "linode" {
  token = data.hcp_vault_secrets_secret.linode_token.secret_value
}

resource "linode_instance" "bastion" {
  label           = "bastion-1"
  image           = "linode/ubuntu22.04"
  region          = local.shared_vars.LINODE_REGION
  type            = "g6-nanode-1"
  authorized_keys = local.shared_vars.SSH_PUBLIC_KEY

  interface {
    purpose = "public"
  }

  interface {
    purpose      = "vlan"
    label        = "internal-network"
    ipam_address = "192.168.0.250/24"
  }
}

resource "linode_instance" "control_plane" {
  count           = 3
  label           = "plane-${count.index + 1}"
  image           = "linode/ubuntu22.04"
  region          = local.shared_vars.LINODE_REGION
  type            = "g6-standard-1"
  authorized_keys = local.shared_vars.SSH_PUBLIC_KEY
  private_ip      = true

  interface {
    purpose = "public"
  }

  interface {
    purpose      = "vlan"
    label        = "internal-network"
    ipam_address = "192.168.0.${count.index + 2}/24"
  }
}

resource "linode_instance" "worker" {
  count           = 3
  label           = "worker-${count.index + 1}"
  image           = "linode/ubuntu22.04"
  region          = local.shared_vars.LINODE_REGION
  type            = "g6-standard-1"
  authorized_keys = local.shared_vars.SSH_PUBLIC_KEY
  private_ip      = true

  interface {
    purpose = "public"
  }

  interface {
    purpose      = "vlan"
    label        = "internal-network"
    ipam_address = "192.168.0.${count.index + 10}/24"
  }
}

# We need to allow SSH access to the instances to allow Ansible to provision the cluster
resource "linode_firewall" "bastion_ingress" {
  label = "bastion-ingress"

  inbound {
    label    = "tcp-22-inbound-allow"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [linode_instance.bastion.id]
}

locals {
  ipv4_addresses = concat(
    [for node in linode_instance.worker : "${node.ip_address}/32"],
    [for node in linode_instance.worker : "${node.private_ip_address}/32"],
    [for node in linode_instance.control_plane : "${node.ip_address}/32"],
    [for node in linode_instance.control_plane : "${node.private_ip_address}/32"],
  )

  ipv6_addresses = concat(
    [for node in linode_instance.worker : "${node.ipv6}"],
    [for node in linode_instance.control_plane : "${node.ipv6}"],
  )
}

resource "linode_firewall" "cluster_firewall" {
  label = "cluster-firewall"

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "tcp-http-inbound-allow"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "tcp-any-inbound-allow-internal"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "1-65535"
    ipv4     = local.ipv4_addresses
    ipv6     = local.ipv6_addresses
  }

  inbound {
    label    = "udp-any-inbound-allow-internal"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "1-65535"
    ipv4     = local.ipv4_addresses
    ipv6     = local.ipv6_addresses
  }

  linodes = concat(
    linode_instance.control_plane.*.id,
    linode_instance.worker.*.id
  )
}

data "template_file" "ansible_inventory" {
  template = file("${path.module}/hosts.tpl")

  vars = {
    bastion_ip = tolist(linode_instance.bastion.ipv4)[0]
    bastion = indent(4, yamlencode({ "${linode_instance.bastion.label}" = {
      ansible_user = "root"
      ansible_host = tolist(linode_instance.bastion.ipv4)[0]
    } }))
    controlplane = indent(4, yamlencode({ for plane in linode_instance.control_plane : plane.label => {
      ansible_user = "root"
      ansible_host = replace(plane.interface[1].ipam_address, "/24", "")
    } }))
    worker = indent(4, yamlencode({ for worker in linode_instance.worker : worker.label => {
      ansible_user = "root"
      ansible_host = replace(worker.interface[1].ipam_address, "/24", "")
    } }))
  }
}

resource "null_resource" "ansible_inventory" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible_inventory.rendered}\" > ${path.module}/../configuration/inventory/hosts.yml"
  }
}
