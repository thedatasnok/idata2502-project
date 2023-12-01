# Core infrastructure

This directory contains the core infrastructure for the project.

This includes the following:

- `configuration` Ansible configuration of hosts
- `definition` Terraform definition of infrastructure

It is important that the definitions and configurations made are idempotent, allowing for re-running the pipeline without breaking anything.

## Terraform

The infrastructure is defined using Terraform, creating nodes and networks.

## Ansible

The configuration part is handled by ansible, which is used to configure the nodes set up by Terraform.

## Required manual intervention

In order for the pipeline to succeed, changes need to be made in the used domain registrar.
For my use-case it's GoDaddy, and what I want to do is forward the subdomain `cloud.overlien.no` to Akamai's nameservers.

This is done by adding the following records:

```
NS  cloud   ns1.linode.com
NS  cloud   ns2.linode.com
NS  cloud   ns3.linode.com
NS  cloud   ns4.linode.com
NS  cloud   ns5.linode.com
```

## Current infrastructure cost

| Resource            | Cost (monthly) | Quantity | Total (monthly) |
| ------------------- | -------------- | -------- | --------------- |
| Nanode 1GB          | $5             | 1        | $5              |
| Linode 2GB          | $12            | 6        | $72             |
| Linode NodeBalancer | $10            | 1        | $10             |
|                     |                |          | **$87**         |

## Testing the ansible playbooks locally

1. Install ansible

```
sudo apt install python3.10-venv
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install --include-deps ansible
pipx inject ansible jmespath
```

2. Change to the ansible directory, `cd configuration`

3. Prepare environment variables, see [.env.example](configuration/.env.example) and [register-env.sh](configuration/register-env.sh)

```bash
source register-env.sh
```

4. Run a playbook

```
ansible-playbook playbooks/install-cluster.yml -i inventory/hosts.yml
```
