<h3 align="center">idata2502-project</h3>
<p align="center">Portfolio for the course IDATA2502 Cloud service administration</p>

## Goal of the project

This project is part of my education, and is meant to be a way of learning how to combine various tools to create a pipeline for deploying a full stack web application on highly available infrastructure.

This is accomplished by deploying a HA Kubernetes cluster on Linode, using 6 nodes and a NodeBalancer.
For management, there is a bastion host that is used to run Ansible playbooks on the cluster.

Linode does also provide a managed Kubernetes service, but I wanted to learn how to set it up myself in an automated fashion.

## Project structure

The project is split into two parts, `infrastructure` and `services`.

```bash
├───docs              # documentation
├───helm              # helm chart
├───infrastructure
│   ├───configuration # ansible
│   └───definition    # terraform
└───services
    ├───backend
    └───frontend
```
