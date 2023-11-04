locals {
  default_token   = file("./token")
  default_ssh_key = file("~/.ssh/id_rsa.pub")
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

provider "linode" {
  token = local.default_token
}

resource "linode_instance" "bastion" {
  label           = "bastion-1"
  image           = "linode/ubuntu22.04"
  region          = "se-sto"
  type            = "g6-nanode-1"
  authorized_keys = [local.default_ssh_key]

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
  region          = "se-sto"
  type            = "g6-standard-1"
  authorized_keys = [local.default_ssh_key]

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
  region          = "se-sto"
  type            = "g6-standard-1"
  authorized_keys = [local.default_ssh_key]

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

resource "linode_firewall" "cluster_firewall" {
  label = "cluster-firewall"

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

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

resource "local_sensitive_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${path.module}/../configuration/ansible/inventory/hosts.yml"
}
