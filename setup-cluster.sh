#/usr/bin/sh

IP_NODE=''
KUBEADM_JOIN=''
ETH="eth1"

if [ ! -d misc ]; then
mkdir misc/
fi

get_ip () {
    IP_NODE=$(vagrant ssh -c "ip -4 -br addr show ${ETH}" $1|sed -r "s@${ETH}\s+UP\s+([1-9]+.[0-9]+.[0-9]+.[0-9]+)/[0-9]+@\1@g" | tr -d '\r\n' )
}

get_kadm_command() {
    PART1=$(grep "kubeadm join" misc/token.txt|tr -d '\r\n'|tr -d '\\')
    PART2=$(grep "discovery-token" misc/token.txt|tr -d '\r\n')
    KUBEADM_JOIN="$PART1 $PART2"
}

get_ip  "master1"
MASTER_IP=$IP_NODE
echo "master1 ip='$MASTER_IP'"

echo "**** executing control plane initialization for master1 ****"
KUBEADM_CONTROL_PLANE_CMD="kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16"
echo -- Pulling images --
echo 'sudo kubeadm config images pull'|vagrant ssh master1
echo "--  Executing kubeadm init command: --"
echo $KUBEADM_CONTROL_PLANE_CMD
vagrant ssh -c "sudo ${KUBEADM_CONTROL_PLANE_CMD}" master1 | tee misc/token.txt

# get kubeadm join .... command
get_kadm_command

echo "****************************************************"
echo "**** Joining with woker nodes using command:"
echo $KUBEADM_JOIN

echo
echo '-- Joining worker1 to cluster --'
echo "sudo ${KUBEADM_JOIN}"|vagrant ssh worker1
echo
echo '-- Joining worker2 to cluster --'
echo "sudo ${KUBEADM_JOIN}"|vagrant ssh worker2

echo "****************************************************"
echo 'Set KUBECONFIG'
vagrant ssh -c 'sudo cat /etc/kubernetes/admin.conf' master1 >  ${HOME}/.kube/vagrant_config
export KUBECONFIG=${HOME}/.kube/vagrant_config
kubectl apply -f kube-flannel.yml
