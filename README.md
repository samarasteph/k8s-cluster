Install K8s cluster with vagrant.

Kubernetes version: latest stable.

Requirements: 
- Linux system Debian(like) or Centos (host system)
- Virtualbox, VMWare software or libvirt.
- Vagrant

## Remark: 
- To use with qemu, install qemu-kvm libvirt libguestfs-tools virt-install rsync
- To use with KVM, see install information at https://ostechnix.com/how-to-use-vagrant-with-libvirt-kvm-provider/ 

sudo apt install qemu libvirt-daemon-system libvirt-clients libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev ruby-libvirt ebtables dnsmasq-base

https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation

Need to install following vagrant plugins:

- vagrant-libvirt: "vagrant plugin install vagrant-libvirt"
- vagrant-mutate: "vagrant plugin install vagrant-mutate"

K8s Cluster nodes:
- 1 control plane (master1)
- 2 worker nodes: worker1 and worker2

## Installation steps
1- Download K8s binaries for k8s cluster setup with download-k8s.sh script (do it once for all)
2- Run 'vagrant up' to set up VM (tested with hashicorp/bionic64 and centos/7 boxes).
3- run setup-cluster.sh for kubeadm commands and network set up (flannel)

