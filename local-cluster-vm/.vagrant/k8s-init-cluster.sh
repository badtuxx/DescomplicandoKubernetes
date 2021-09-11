#!/bin/bash

USER_HOME=/home/vagrant

echo "Download images of the components by cluster..."
kubeadm config images pull

echo "Initialize cluster..."
mkdir $USER_HOME/token
kubeadm init > $USER_HOME/token/.token_join

echo "configure runtime container for root..."
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "configure runtime container for normal user..."
mkdir -p $USER_HOME/.kube
cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
chown vagrant:vagrant $USER_HOME/.kube/config

# Enable kernel modules
echo "Enable kernel moludes..."
sudo modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs

# weavenet
echo "Should now deploy a pod network to the cluster..."
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# echo "List Nodes..."
# kubectl get nodes
# 
# # Firewall Allow
# ufw allow from 192.168.99.0/24
# ufw allow from 192.168.0.0/24
# 
# ufw allow from 192.168.99.0/24 to any port 6443
# ufw allow from 192.168.99.0/24 to any port 2379
# ufw allow from 192.168.99.0/24 to any port 2380
# ufw allow from 192.168.99.0/24 to any port 68
# 
# 
# ufw allow from 192.168.0.0/24 to any port 6443
# ufw allow from 192.168.0.0/24 to any port 2379
# ufw allow from 192.168.0.0/24 to any port 2380
# ufw allow from 192.168.0.0/24 to any port 68
# 
# ufw enable
# ufw reload
# 
echo "Show join token"
echo "========================================================================="
JOIN_TOKEN=$(cat token/.token_join |grep -i "kubeadm join" && cat token/.token_join |grep -i "discovery-token-ca-cert-hash")
echo $JOIN_TOKEN | tr -d '\\' > token/.token_join
cat token/.token_join
echo "========================================================================="

