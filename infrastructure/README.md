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

<!-- TODO -->

## Current infrastructure cost

| Resource   | Cost (monthly) | Quantity | Total (monthly) |
| ---------- | -------------- | -------- | --------------- |
| Linode 4GB | $24            | 3        | $72             |
|            |                |          | **$72**         |

Taking the free credits of $100 into account, this should last approximately 1 month and a couple weeks.

## Testing the ansible playbook locally

<!-- TODO -->
