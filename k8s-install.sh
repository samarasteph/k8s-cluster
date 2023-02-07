#!/bin/bash

echo '\n**** Starting K8s intallation ****\n'

export DEBIAN_FRONTEND=noninteractive

apt-get install -y socat conntrack

sudo swapoff -a

cat <<EOF |tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter 
cat <<EOF |tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# restart
sysctl --system

# bin repo folder is shared in /vagrant/bin
source /vagrant/bin-versionning
cd /vagrant/bin

# Containerd installation
echo "\n**** Containerd installation ****\n"

tar Cxvzf /usr/local/ containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz  #> /dev/null
cp containerd.service /etc/systemd/system
systemctl daemon-reload 
systemctl enable --now containerd

echo "\n**** runc & cni plugins installation ****\n"

# runc install

install -m 755 runc.amd64 /usr/local/sbin/runc  #> /dev/null

# cni plugins install

mkdir -p /opt/cni/bin/
tar Cxvzf /opt/cni/bin/  cni-plugins-linux-amd64-${CNI_VERSION}.tgz     #> /dev/null

# modify containerd configuration to set systemd cgroup
mkdir -p /etc/containerd
containerd config default|tee /etc/containerd/config.toml    > /dev/null
### vi /etc/containerd/config.toml 
sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
### systemctl status containerd

# download crictl, kubelet, kubeadm and kubectl

DOWNLOAD_DIR="/usr/local/bin"
# https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md

tar -C $DOWNLOAD_DIR -xz -f crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz

#configure containerd endpoints with crictl
CONTAINERD_SOCKET="unix:///var/run/containerd/containerd.sock"
crictl config --set runtime-endpoint=${CONTAINERD_SOCKET} 
crictl config --set image-endpoint=${CONTAINERD_SOCKET} 

echo "\n**** kubeadm & kubelet installation ****\n"

echo "Install to directory '$DOWNLOAD_DIR'"
cp kubeadm kubelet $DOWNLOAD_DIR
# ls -l $DOWNLOAD_DIR 

cd $DOWNLOAD_DIR #> /dev/null
chmod +x kubeadm
chmod +x kubelet
cd -  #> /dev/null

curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_SYSTEMD_RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" |sed "s:/usr/bin:${DOWNLOAD_DIR}:g" |tee /etc/systemd/system/kubelet.service

mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_SYSTEMD_RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" |sed "s:/usr/bin:${DOWNLOAD_DIR}:g" |tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
systemctl enable --now kubelet &2> /dev/null
