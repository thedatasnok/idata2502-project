bastion:
  hosts:
    ${bastion}
controlplane:
  hosts:
    ${controlplane}
worker:
  hosts:
    ${worker}
cluster:
  children:
    controlplane:
    worker:
  vars:
    ansible_ssh_common_args: '-o ProxyJump="root@${bastion_ip}"'

all:
  children:
    bastion:
    controlplane:
    worker:
