#/usr/bin/zsh
#kubeadm config images pull
IP_NODE=''
KUBEADM_JOIN=''

if [ ! -d misc ]; then
mkdir misc/
fi

get_ip () {
    IP_NODE=$(vagrant ssh -c "ip -4 -br addr show eth1" $1|sed -r 's@eth1\s+UP\s+([1-9]+.[0-9]+.[0-9]+.[0-9]+)/[0-9]+@\1@g' | tr -d '\r\n' )
}

get_kadm_command() {
    PART1=$(grep "kubeadm join" misc/token.txt|tr -d '\r\n'|tr -d '\\')
    PART2=$(grep "discovery-token" misc/token.txt|tr -d '\r\n')
    KUBEADM_JOIN="$PART1 $PART2"
}

get_ip  "master1"
MASTER_IP=$IP_NODE
echo "master1 ip='$MASTER_IP'"

KUBEADM_CONTROL_PLANE_CMD="kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16"
echo "**** executing control plane initialization for master1 with command:"
echo $KUBEADM_CONTROL_PLANE_CMD|tee misc/init.sh
chmod a+x misc/init.sh
echo --
vagrant ssh -c "sudo bash -c /vagrant/misc/init.sh" master1 |tee misc/token.txt

# get kubeadm join .... command
get_kadm_command

echo "****************************************************"
echo "**** Joining with worker1 & worker2 using command:"
echo $KUBEADM_JOIN|tee misc/join.sh
chmod a+x misc/join.sh

echo
echo '+++ Joining worker1 to cluster'
vagrant ssh -c "sudo bash -c /vagrant/misc/join.sh" worker1
echo
echo '+++ Joining worker2 to cluster'
vagrant ssh -c "sudo bash -c /vagrant/misc/join.sh" worker2

echo
echo 'Set KUBECONFIG'
vagrant ssh -c 'sudo cp /etc/kubernetes/admin.conf /vagrant/misc/vagrant_config' master1
vagrant ssh -c 'sudo chown vagrant /vagrant/misc/vagrant_config' master1
cp misc/vagrant_config ${HOME}/.kube/
export KUBECONFIG=${HOME}/.kube/vagrant_config
kubectl apply -f kube-flannel.yml
