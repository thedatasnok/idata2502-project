locals {
  default_token   = file("./token")
  default_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdMjx9MC8YJji3HEnD52s45O2suLTkTk1IuMILOW15eJwqjQt+YlCErMHiZr1uasouUwPRXvJsgj9Kzbub9LXjLyvEkvVB5FozDeT0KQ8YCGp2FxUHYQeX74Lv7Dc9yrmjE5g9Xj/8Bm85WWzn9jP5bPUATXSGGJynguVijos+yst2pEf6h9tiKAmw61hFHqh91J0+cLZs61GfhSxsLhonhahby6DzdkrkxK7i3y1uTbKESvzJJklMBpTsW3uNtrIjBmcJYf3swB49/qKESqpd/7Euu+VOygAnrh53dNM84f9hAcqLxNp8MpGv19PjFJ2jsnP3mkDFP1bapA73mvT6aiSY/ucA0od+aIeb1q/OYJogW5fBtRxqkr1umJR9jJnLhnUqea5gHFB5kpqEQcdJgRg+2mwqt0YCnUF2Q+sn7dtKI4MXut/lW1UF732SEB4PJgqJwTmjeNh/I247XUAQ2lSfsylTDsk/ASzy+ctVC1yvoo6VH2tZ6WVciOxBxEM= datasnok@DESKTOP-FATS1F2"
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

resource "linode_lke_cluster" "cluster" {
  k8s_version = "1.27"
  label       = "cluster"
  region      = "se-sto"
  pool {
    count = 3
    type  = "g6-standard-1"
  }
}

//Export this cluster's attributes
output "kubeconfig" {
  value     = linode_lke_cluster.cluster.kubeconfig
  sensitive = true
}

output "api_endpoints" {
  value = linode_lke_cluster.cluster.api_endpoints
}

output "status" {
  value = linode_lke_cluster.cluster.status
}

output "id" {
  value = linode_lke_cluster.cluster.id
}

output "pool" {
  value = linode_lke_cluster.cluster.pool
}
