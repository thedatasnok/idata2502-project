locals {
  default_token   = file("./token")
  default_ssh_key = file("~/.ssh/id_rsa.pub")
}

terraform {
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

resource "linode_instance" "k3s_server" {
  count           = 3
  label           = "k3s-server-${count.index + 1}"
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

resource "linode_instance" "k3s_agent" {
  count           = 3
  label           = "k3s-agent-${count.index + 1}"
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
resource "linode_firewall" "node-ingress" {
  label = "node-ingress"

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

  linodes = concat(linode_instance.k3s_server[*].id, linode_instance.k3s_agent[*].id)
}
