#!/usr/bin/zsh

source bin-versionning
DIR=bin

if [[ ! -d $DIR ]]; then
mkdir $DIR
fi

cd $DIR
rm -fr *

echo "\n**** Download Containerd ${CONTAINERD_VERSION} ****\n"
wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

echo "\n**** Download runc ${RUNC_VERSION} ****\n"
wget https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.amd64

echo "\n**** Download CNI plugins ${CNI_VERSION} ****\n"
wget https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz

echo "\n**** Download crtctl tool ${CRICTL_VERSION} ****\n"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" --output crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz

echo "\n**** Download kubeadm & kubelet ${K8S_RELEASE} ****\n"
curl -L --remote-name-all https://dl.k8s.io/release/${K8S_RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet}

echo "\n**** Download kubectl ${K8S_RELEASE} ****\n"
curl -LO https://dl.k8s.io/release/${K8S_RELEASE}/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/${K8S_RELEASE}/bin/linux/amd64/kubectl.sha256
echo "$(cat kubectl.sha256) kubectl"| sha256sum --check

cd -
