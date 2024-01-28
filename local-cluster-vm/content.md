# O que é o kubernetes?
Kubernetes (K8s) é um produto Open Source utilizado para automatizar a implantação, o dimensionamento e o gerenciamento de aplicativos em contêiner.
* Todo ação que acontece no cluster passa pelo apiserver do kubernetes, o etcd é o banco de dados
* kubeScaduler - é o responsável por selecionar o node adequado
* kubelet roda em todos node master e workers

## que é um Pod?
É a menor unidade dentro de cluster k8s, a diferença que tempos de um Pod por um Container é que o Pod vai dividir o namespace (compartilhar) em os container ele pode comportar mais de um container, mais a conselha-se um container por Pod ou no minimo dois.

## Controller
é o responsável por controlar (objecto, resource) toda a orquestração ele comunicaºse com apiserver do kubernetes para colectar informações do cluster através do replicaSet se alguma coisa de errado a conter como replicaSet o controller responsável por tomar decisão é Deployment.
Nas camadas de Objectos do kubernetes temos os:
-> [Deployment [Service [ReplicaSet [DeamonSet [Pod [Ingress]]]]]]

## Deployment
É um dos principais controller ele controla os ReplicaSet
Dentro do kubernetes para para fazer o deploy de uma app temos que os seguintes passos:
1. Create a Deployment (create auto a replicaSet)
2. Create a Service (Para ter acesso externo Bind Port to Deployment as Replicas)

## Minikube
É uma image do kubenetes rodando em uma VM para uso em ambiente Dev, ele nos dá a possibilidade de usar o kubernetes sem necessáriamente ter um cluster K8S instalado.

Antes de instalar o minikube, precisamos realizar a instalação do kubectl:
### LINUX
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
```
```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \ && chmod +x minikube
```
```bash
sudo cp minikube /usr/local/bin && rm minikube
```
### Comando Minikube
* Subir os componentes do kubenetes em uma VM local
```bash
minikube start
```
* Visualizar os Nodes
```bash
kubectl get nodes
```
* Visualizar os Pods
```bash
kubectl get pods
```
* Visualizar os Deployment
```bash
kubectl get deployment
```
* Visualizar os Deployment de todos namespaces
```bash
kubectl get deployment --all-namespaces
```
* Visualizar IP do cluster minikube
```bash
minikube ip
```
* Acessar o minikube host
```bash
minikube ssh
```
* Remover o minikube host
```bash
minikube delete
```
* Parar o minikube host
```bash
minikube stop
```
* Acessar o dashboard
```bash
minikube dashboard
```

## Instalando um cluster kubernetes
### create script to install cluster tools
```bash
#!/bin/bash

echo "Install Docker Engine\n"
curl -sfSL https://get.docker.com | bash

echo "Add vagrant user to docker group"
usermod -aG docker vagrant

echo "Configure container runtime deamon by EOD (End Of File)"
cat > /etc/docker/deamon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo "Create docker service for systemd\n"
mkdir -p /etc/systemd/system/docker.service.d

echo "reload deamon..\n"
systemctl deamon-reload

echo "Restart docker..\n"
systemctl restart docker

echo "Check cgroup in docker info..\n"
docker info | grep i cgroup

# Kubernetes config
echo "Add kubernetes repository...\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubeadm kubelet kubectl
```
### create host from Vagrant
```vagrantfile
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "elliot-0#{i}" do |node|
      node.vm.box = "ubuntu/xenial64"
      node.vm.hostname = "elliot-0#{i}"
      node.vm.network "public_network",
        use_dhcp_assigned_default_route: true, bridge: "enp0s20u2"
      node.vm.provision "shell", inline: "curl -fsSL https://get.docker.com | bash"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "elliot-0#{i}"
        vb.memory = 3076
        vb.cpus = 2
      end
    end
  end
end
```
```bash
vagrant up
```
## Inicializar o cluster
```bash
kubeadm config images pull
```
```bash
kubeadm init
```
### Join node in cluster
```bash
sudo kubeadm join <hosts>:<port> --token 4ipu0m.5q0or83aao7j2aru --discovery-token-ca-cert-hash sha256:739d75755ed9dba30415af83e64774aad1e701cf9d0dd3393dd05908af6068c9
```