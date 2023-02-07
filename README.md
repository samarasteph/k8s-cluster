Install K8s cluster with vagrant.

Kubernetes version: latest stable.

Requirements: 
- Linux system (host)
- Virtualbox or VMWare software.
- Vagrant installed

K8s Cluster nodes:
- 1 control plane (master1)
- 2 worker nodes: worker1 and worker2

1- Download K8s binaries for k8s cluster setup with download-k8s.sh script
2- Run 'vagrant up' to set up VM (hashicorp/bionic64 box).
3- run setup-cluster.sh for kubeadm commands and network set up (flannel)

