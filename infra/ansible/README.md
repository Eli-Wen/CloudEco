\# Ansible Kubernetes Automation



This folder contains Ansible automation for preparing and creating the CloudEco Kubernetes cluster.



\## Role in the project



\- Terraform provisions Azure infrastructure: resource group, multi-region VNets, NSGs, public IPs, NICs, VMs, and VNet peerings.

\- Ansible prepares the Ubuntu nodes: swap off, kernel networking, containerd, kubeadm, kubelet, and kubectl.

\- Ansible then initialises the Kubernetes control plane, installs Calico CNI, joins worker nodes, and verifies cluster health.



This keeps the final workflow reproducible rather than relying on manual SSH configuration.



\## Files



\- `inventory.ini`: master and worker node inventory.

\- `prepare-k8s-nodes.yml`: installs containerd and Kubernetes tooling on all nodes.

\- `setup-k8s-cluster.yml`: runs `kubeadm init`, installs Calico, joins workers, and verifies the cluster.



\## Run order



From this folder:



```bash

ansible-playbook -i inventory.ini prepare-k8s-nodes.yml

ansible-playbook -i inventory.ini setup-k8s-cluster.yml

