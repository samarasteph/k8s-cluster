#!/bin/bash

echo '\n**** Starting K8s intallation ****\n'

# install dependencies for kubernetes
DEPS="socat conntrack"

if [ -x "$(which yum)" ]; then
	yum install -y ${DEPS}
fi

if [ -x "$(which apt-get)" ]; then
    export DEBIAN_FRONTEND=noninteractive
	apt-get install -y ${DEPS}
fi
	
if [ -x "$(which apk)" ]; then
	apk update
	apk upgrade
	apk add socat conntrack-tools
fi
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

# copy sudoers additional path
cp vagrant-host/sudo_paths /etc/sudoers.d/

# bin repo folder is shared in vagrant-host/bin
source vagrant-host/bin-versionning
cd vagrant-host/bin

# Containerd installation
echo "\n**** Containerd installation ****\n"

tar xvzf containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz  -C /usr/local/ #> /dev/null
cp containerd.service /etc/systemd/system
systemctl daemon-reload 
systemctl enable --now containerd

echo "\n**** runc & cni plugins installation ****\n"

# runc install

install -m 755 runc.amd64 /usr/local/sbin/runc  #> /dev/null

# cni plugins install

mkdir -p /opt/cni/bin/
tar xvzf cni-plugins-linux-amd64-${CNI_VERSION}.tgz  -C /opt/cni/bin/  #> /dev/null

# modify containerd configuration to set systemd cgroup
mkdir -p /etc/containerd
/usr/local/bin/containerd config default|tee /etc/containerd/config.toml    > /dev/null
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
${DOWNLOAD_DIR}/crictl config --set runtime-endpoint=${CONTAINERD_SOCKET} 
${DOWNLOAD_DIR}/crictl config --set image-endpoint=${CONTAINERD_SOCKET} 

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
