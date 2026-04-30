\# Ansible Kubernetes Node Preparation



This folder contains the Ansible configuration used to prepare the three Azure VMs for the Kubernetes cluster.



Terraform provisions the Azure infrastructure. Ansible configures the operating system on each VM by disabling swap, enabling Kubernetes kernel networking, installing containerd, and installing kubeadm, kubelet, and kubectl.



Run from `infra/ansible`:



```bash

ansible-playbook -i inventory.ini prepare-k8s-nodes.yml

