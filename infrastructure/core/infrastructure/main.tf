variable "token" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.8.0"
    }
  }
}

provider "linode" {
  token = var.token
}


resource "linode_instance" "k8s_node" {
  count           = 3
  label           = "k8s-master"
  image           = "linode/ubuntu22.04"
  region          = "se-sto"
  type            = "g6-standard-1"
  authorized_keys = [var.ssh_public_key]
}

resource "linode_instance" "k8s_worker" {
  count           = 2
  label           = "k8s-worker"
  image           = "linode/ubuntu22.04"
  region          = "se-sto"
  type            = "g6-standard-1"
  authorized_keys = [var.ssh_public_key]
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

  linodes = [linode_instance.k8s_master.*.id, linode_instance.k8s_worker.*.id]
}
