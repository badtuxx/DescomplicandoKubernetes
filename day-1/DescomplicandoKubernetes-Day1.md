# O que preciso saber antes de começar?

## Qual distro Linux devo usar?

Com a maioria das distribuições você conseguirá seguir esse treinamento. Algumas ferramentas importantes começaram a se tornar padrão, o que fez com que as diferenças entre as distribuições diminuísse. Por exemplo, devemos citar o systemd e o journald, que hoje estão presente na maioria das distribuições Linux.


## Alguns sites que devemos visitar:

[https://kubernetes.io/](https://kubernetes.io/)

[https://github.com/kubernetes/kubernetes/](https://github.com/kubernetes/kubernetes/)

[https://github.com/kubernetes/kubernetes/issues](https://github.com/kubernetes/kubernetes/issues)

[https://www.cncf.io/certification/cka/](https://www.cncf.io/certification/cka/)

[https://www.cncf.io/certification/ckad/](https://www.cncf.io/certification/ckad/)

[https://12factor.net/pt_br/](https://12factor.net/pt_br/)


## E o K8s?

O Kubernetes significa Piloto ou Timoneiro em Grego.

Ele foi baseado no Borg, produto criado no Google e utilizado por muitos anos internamente.

O Borg deu origem, além do k8s, ao Mesos e o Cloud Foundry, por exemplo.

Como o kubernetes é difícil de pronunciar para quem fala inglês, eles apelidaram de k8s, que se pronuncia Kates

Ele tornou-se open source em Junho de 2014.

Possui milhares de desenvolvedores e mais de 66k commits.

A cada 3 meses sai uma nova release.

O melhor app para rodar em container, principalmente no k8s, são aplicações que seguem o 12 factors.

Para simplificar, a arquitetura do k8s é feita de um manager e diversos workers nodes. Veremos também como rodar tudo em uma única maquina, mais isso é interessante somente para estudos, nunca para produção. 😀

O manager roda um API server, um scheduler e alguns controllers e o ETCD, um sistema de armazenamento para manter o estado do cluster, configurações dos containers e de rede.

O k8s expõe uma API, através do kube-apiserver, e você se comunica com ela através do comando **kubectl,** você também pode criar o seu próprio client, evidentemente.

O kube-scheduller cuida das requisições vindas da kube-apiserver para a criação de novos containers e verifica em qual o melhor node para isso.

Cada worker node roda dois processos, o kubelet e o kube-proxy. 

O kubelet é quem recebe as requisições para criação e gerenciamento dos containers, bem como de seus recursos.

O kube-proxy cria e gerencia as regras para expor os containers na rede.


## Portas que devemos nos preocupar:

**MASTER**
```
kube-apiserver => 6443 TCP

etcd server API => 2379-2380 TCP

Kubelet API => 10250 TCP

kube-scheduler => 10251 TCP

kube-controller-manager => 10252 TCP

Kubelet API Read-only => 10255 TCP

*NodePort Services => 30000-32767 TCP

```


**WORKER**
```
Kubelet API => 10250 TCP

Kubelet API Read-only => 10255 TCP

NodePort Services => 30000-32767 TCP
```

Caso utilize o Weave como pod network, conforme demonstrado no material, lembre-se de liberar as portas:

A porta TCP _6783_ e as portas UDP _6783_ e _6784_.

Lembre-se de fazer as liberações em seu firewall.


## 


## Primeiras palavras chaves do K8s

Vamos conhecer algumas palavras chaves para que você possa se sentir em casa:

**Pod** => No k8s, containers não são tratados individualmente, ele são gerenciados através de pods, que são agrupamentos de um ou mais containers dividindo o mesmo endereço, isso normalmente é composto por uma app principal e outras app de suporte para essa primeira.

**Controllers** => Responsável pela orquestração, ele interage com o api server para saber o status de cada objeto.

**Deployment** => É um dos principais controllers, ele é responsável por garantir que possui recursos disponíveis como IP e storage para o deploy dos ReplicaSet e DaemonSet.

**Jobs ou CronJobs** => Responsáveis pelo gerenciamento de task isoladas ou recorrentes

Para acompanhar o treinamento, você pode possuir dois cenários. Poderá utilizar somente uma máquina com o minikube instalado, ou então, subir um cluster com 03 máquinas, pode ser virtual ou cloud.

Nosso foco será em dois comandos, o kubeadm e o kubectl.


# 


# Instalação


## MiniKube

Primeiro iremos ver como realizar a instalação do k8s através de uma única máquina, onde iremos utilizar o minikube, que é o responsável por fazer rodar todos os componentes do k8s juntos. Ele também traz o Docker engine. 😀

Realizar antes a instalação do VirtualBox 5.0.12:

[https://download.virtualbox.org/virtualbox/5.0.12/](https://download.virtualbox.org/virtualbox/5.0.12/)

 

Antes de instalar o minikube, precisamos realizar a instalação do kubectl:

**LINUX**


```
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

# chmod +x kubectl && mv kubectl /usr/local/bin/
```


**MACOS**


```
# curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl

# chmod +x kubectl && mv kubectl /usr/local/bin/
```


No MacOS, você pode também realizar a instalação através do brew:


```
# brew install kubectl
```


**WINDOWS**


```
# curl -Lo https://storage.googleapis.com/kubernetes-release/release/v1.13.7/bin/windows/amd64/kubectl.exe
```


Se você utiliza o PSGallery:


```
# Install-Script -Name install-kubectl -Scope CurrentUser -Force    
install-kubectl.ps1 [-DownloadLocation <path>]
```


doc:

[https://kubernetes.io/docs/tasks/tools/install-minikube/](https://kubernetes.io/docs/tasks/tools/install-minikube/)

**LINUX**


```
# curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \ && chmod +x minikube
# sudo cp minikube /usr/local/bin && rm minikube
```


**MACOS**


```
# curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 \ && chmod +x minikube
# sudo cp minikube /usr/local/bin && rm minikube
```


**WINDOWS**

[https://storage.googleapis.com/minikube/releases/v1.1.1/minikube-windows-amd64.exe](https://storage.googleapis.com/minikube/releases/v1.1.1/minikube-windows-amd64.exe)

Com isso, já podemos iniciar o nosso minikube e seus componentes:


```
# minikube start
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Downloading Minikube ISO
 153.08 MB / 153.08 MB [============================================] 100.00% 0s
Getting VM IP address...
Moving files into cluster...
Downloading kubeadm v1.10.0
Downloading kubelet v1.10.0
Finished Downloading kubelet v1.10.0
Finished Downloading kubeadm v1.10.0
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.
```


Para visualizar todos os nodes:


```
# kubectl get nodes
NAME       STATUS    ROLES     AGE       VERSION
minikube   Ready     master    1m        v1.10.0
```


Nesse caso somente temos um, afinal estamos rodando o minikube justamente por esse motivo, para roda-lo quando temos somente uma máquina. Lembre-se, ele é recomendado somente para estudos, nunca em produção.


## 


## Instalação em cluster com 03 nodes.

Já vimos como realizar a instalação do K8s através do minikube, agora vamos realizar a instalação em um cenário com 03 máquinas, seja VM ou cloud.

O setup que iremos utilizar para o treinamento é de máquinas com, no mínimo, a seguinte configuração:



*   Debian, Ubuntu, Centos, Red Hat, Fedora, SuSe.
*   2 Core CPU
*   2GB de memória RAM

Primeiro, faça a atualização de seus nodes:

Subir os seguintes módulos do kernel em todos os nodes:


```
# vim /etc/modules-load.d/k8s.conf
br_netfilter
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
ip_vs
```


**Debian e família:**


```
# apt-get update -y && apt-get upgrade -y
```


**Red Hat e família:**


```
# yum upgrade -y
```


Agora, bora realizar a instalação do Docker


```
# curl -fsSL https://get.docker.com | bash
```


Assim, teremos a última versão do docker instalado em todos os nodes.

Agora vamos adicionar o repo do Kubernetes em nossos nodes:

**Debian e Familia:**


```
# apt-get update && apt-get install -y apt-transport-https

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# apt-get update

# apt-get install -y kubelet kubeadm kubectl
```


**Red Hat e Família**


```
# vim /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

# setenforce 0

# systemctl stop firewalld

# systemctl disable firewalld

# yum install -y kubelet kubeadm kubectl

# systemctl enable kubelet && systemctl start kubelet
```


Ainda na família do Red Hat, é importante configurar alguns parâmetros de kernel no sysctl:


```
# vim /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

# sysctl --system
```


Agora em ambas as distribuições é muito importante também verificar se o drive cgroup usado pelo kubelet é o mesmo usado pelo docker, para verificar isso execute o seguinte comando:


```
# docker info | grep -i cgroup
Cgroup Driver: cgroupfs

# sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# systemctl daemon-reload

# systemctl restart kubelet
```


docs: [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)

Antes de iniciar o nosso cluster precisamos desabilitar nossa swap, portanto:


```
# swapoff -a
```


E comente a entrada referente a swap em seu arquivo fstab:


```
# vim /etc/fstab
```


Uma observação, quando iniciarmos o nosso cluster ele irá mostrar uma mensagem de warning falando que é recomendável a utilização do docker 17.03. Essa versão é bastante antiga e utilizando o K8s com a versão 18.03 não tive nenhum problema de incompatibilidade ou coisa do gênero, mas fica aqui o aviso. 😉


## Agora vamos iniciar o nosso cluster

Antes de iniciarmos o nosso cluster, vamos fazer o pull das imagens que serão utilizadas para montar o nosso cluster.


```
# kubeadm config images pull
```


Executar o comando abaixo somente no nó principal (master-node).


```
# kubeadm init --apiserver-advertise-address $(hostname -i)
```


O comando acima irá iniciar o cluster e em seguida exibirá a linha que de comando que preciso executar em meus outros nodes. 


```
	[WARNING SystemVerification]: docker version is greater than the most recently validated version. Docker version: 18.05.0-ce. Max validated version: 17.03
...
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
... 
kubeadm join --token 39c341.a3bc3c4dd49758d5 IP_DO_MASTER:6443 --discovery-token-ca-cert-hash sha256:37092
...
```


O kubeadm executa uma série de pré-verificações para garantir o bom funcionamento do kubernetes.

Agora, para que possamos iniciar o gerenciamento do nosso cluster, vamos criar a estrutura de diretórios de nossa configuração, o kubeadm gentilmente já informa os comandos necessários na hora que executamos o init.  


```
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


Nesses diretório, teremos toda a configuração necessária para o funcionamento do kubeclt.

Se você ainda não reiniciou seu máquina para que os modulos do kernel fossem carregados, execute o seguinte comando:


```
# modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs
```


Agora vamos criar o nosso podnetwork, mais pra frente iremos entrar em maiores detalhes sobre eles.

Nesse exemplo, vamos utilizar o Weave, sensacional opção juntamente com o Cálico, na minha opinião os mais completos.


```
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.extensions/weave-net created
```


Vamos listar esses podnetwork:
```
# kubectl get pods -n kube-system**

NAME                                         READY       STATUS       RESTARTS   AGE

coredns-78fcdf6894-fzbp2          1/1              Running       0                    9m

coredns-78fcdf6894-vp6td          1/1              Running       0                    9m

etcd                                             1/1              Running       0                    7m

kube-apiserver                            1/1              Running       0                    8m

kube-controller-manager             1/1              Running       0                    8m

kube-proxy-smhxn                       1/1             Running        0                   9m

kube-scheduler-                           1/1             Running        0                   8m

weave-net-9b6kg                        2/2             Running       0                   2m
```
Agora já podemos adicionar os demais nodes ao cluster. Vamos pegar aquela linha de comando da saída do kubeadm init e executar nos outros dois nodes:


```
# kubeadm join --token 39c341.a3bc3c4dd49758d5 IP_DO_MASTER:6443 --discovery-token-ca-cert-hash sha256:37092 
```


Para verificar todos os nodes do cluster execute:


```
# kubectl get nodes
NAME               STATUS   ROLES    AGE   VERSION
elliot-01    Ready    master   95s   v1.18.2
elliot-02   Ready    <none>   79s   v1.18.2
elliot-03    Ready    <none>   79s   v1.18.2
```



# Primeiros Passos no K8s

Vamos ver alguns detalhes sobre o um dos nossos nodes:


```
# kubectl describe node elliot-03
Name:               elliot-03
Roles:              master
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-172-31-17-67
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/master=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Sun, 10 May 2020 17:06:11 +0000

...

  Normal  NodeAllocatableEnforced  3m               kubelet, elliot-03     Updated Node Allocatable limit across pods
  Normal  Starting                 3m               kube-proxy, elliot-03  Starting kube-proxy.
  Normal  NodeReady                3m               kubelet, elliot-03     Node elliot-03 status is now: NodeReady
```


Para visualizar novamente o token para inserção de novos nodes:


```
# kubeadm token create --print-join-command
kubeadm join --token 39c341.a3bc3c4dd49758d5 IP_DO_MASTER:6443 --discovery-token-ca-cert-hash sha256:37092 
```


Está ruim de ficar digitando? use o auto-complete:


```
# source <(kubectl completion bash)
```


Deixe de forma definitiva:


```
# echo "source <(kubectl completion bash)" >> ~/.bashrc
```


Verificar os namespaces:


```
# kubectl get namespace
NAME              STATUS   AGE
default           Active   4m01s
kube-node-lease   Active   4m02s
kube-public       Active   4m02s
kube-system       Active   4m02s
```


Vamos listar os pods do namespace kube-system:


```
# kubectl get pods -n kube-system
NAME                                      READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-n6kj9                  1/1     Running   0          4m2s
coredns-66bff467f8-vk84w                  1/1     Running   0          4m2s
etcd-ip-172-31-17-67                      1/1     Running   0          4m8s
kube-apiserver-ip-172-31-17-67            1/1     Running   0          4m8s
kube-controller-manager-ip-172-31-17-67   1/1     Running   0          4m8s
kube-proxy-499j5                          1/1     Running   0          3m55s
kube-proxy-5c2gn                          1/1     Running   0          4m2s
kube-proxy-bwm2l                          1/1     Running   0          3m56s
kube-scheduler-ip-172-31-17-67            1/1     Running   0          4m8s
weave-net-2xsk7                           2/2     Running   0          4m2s
weave-net-p6979                           2/2     Running   1          3m55s
weave-net-zlqvq                           2/2     Running   0          3m56s
```


Tem pod escondido? Veja os pods de todos os namespaces:


```
# kubectl get pods --all-namespaces
```


Vamos executar o nosso primeiro exemplo, o nosso querido nginx de sempre:


```
# kubectl run nginx --image nginx
pod/nginx created
```


Vamos ver o objeto pod:


```
# kubectl get pods
NAME                                                 READY   STATUS        RESTARTS   AGE
nginx                                                1/1     Running       0          56s
```


Vamos ver a descrição do nosso pod:


```
# kubectl describe pods nginx
Name:         nginx
Namespace:    default
Priority:     0
Node:         elliot-03/172.31.24.60
Start Time:   Sun, 10 May 2020 17:11:35 +0000
Labels:       run=nginx
Annotations:  <none>
Status:       Running
IP:           10.46.0.3
IPs:
  IP:  10.46.0.3
Containers:
  nginx:
    Container ID:   docker://55d310b6fbca7c1555564b434e957c2c3e810dc1dd8c55878db1484b16691532
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:86ae264c3f4acb99b2dee4d0098c40cb8c46dcf9e1148f05d3a51c4df6758c12
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 10 May 2020 17:11:43 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-q7pdb (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  default-token-q7pdb:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-q7pdb
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From                      Message
  ----    ------     ----  ----                      -------
  Normal  Scheduled  80s   default-scheduler         Successfully assigned default/nginx to elliot-03
  Normal  Pulling    79s   kubelet, elliot-03  Pulling image "nginx"
  Normal  Pulled     73s   kubelet, elliot-03  Successfully pulled image "nginx"
  Normal  Created    72s   kubelet, elliot-03  Created container nginx
  Normal  Started    72s   kubelet, elliot-03  Started container nginx
```


Vamos conferir se nosso cluster está tudo ok:


```
# kubectl get events
LAST ... KIND ...  REASON    SOURCE      MESSAGE
1m       pod       Pulling   kubelet     pulling image "nginx"
1m       pod       Pulled    kubelet     successfully pulled
1m       Pod       created   kubelet     Created container
1m       pod       started   kubelet     Started container
```
Nas últimas linhas podemos ver nosso pod nginx sendo construído.

Olha a saída do get pods, só que no formato yams:


```
# kubectl get pods nginx -o yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2020-05-10T17:11:35Z"
  labels:
    run: nginx
  managedFields:
...

```


Nós podemos pegar essa saída e redirecionar para um arquivo:


```
# kubectl get pods nginx -o yaml > meu_primeiro.yaml
```


Vamos dar uma olhada nesse arquivo, quer dizer, nesse manifesto que acabamos de criar, remova a parte em negrito conforme abaixo, pois essas informações são sobre o pod atual e seu status. Não vamos precisar disso, afinal iremos criar outro pod, baseado no atual. :)


```
# vim meu_primeiro.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
  namespace: default
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-q7pdb
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: elliot-03
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: default-token-q7pdb
    secret:
      defaultMode: 420
      secretName: default-token-q7pdb
```


Agora vamos remover o nosso pod do nginx:


```
# kubectl delete pods nginx
pod "nginx" deleted
```


Agora vamos novamente criá-lo, só que utilizando o nosso manifesto:


```
# kubectl create -f meu_primeiro.yaml
pod/nginx created

# kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          10s
```


Vamos criar um segundo arquivo, baseado no nosso novo pod:


```
# kubectl get pods nginx -o yaml > meu_segundo.yaml
```


Vamos ver a diferença entre eles:


```
# diff meu_primeiro.yaml meu_segundo.yaml
```


Idênticos concordam ?.

Agora vamos tentar expor a porta desse nosso pod:


```
# kubectl expose pod nginx
```


Não foi possível, tomamos o seguinte erro:


```
error: couldn't find port via --port flag or introspection
See 'kubectl expose -h' for help and examples
```


Precisamos ter a entrada _ports_ no arquivo, vamos remover o pod que está em execução e adicionar a entrada ports:


```
# kubectl delete -f meu_primeiro.yaml
pod "nginx" deleted
```


Vamos alterar o arquivo e adicionar as linhas destacadas abaixo:


```
# vim meu_primeiro.yaml
...
spec:
       containers:
       - image: nginx
         imagePullPolicy: Always
         ports:
         - containerPort: 80
         name: nginx
         resources: {}
...
```


Agora vamos criá-lo novamente esse arquivo:


```
# kubectl create -f meu_primeiro.yaml
pod/nginx created
```


Verificando se nosso pod já está em execução:


```
# kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          14s
```


Vamos tentar expor novamente:


```
# kubectl expose pod nginx
service/nginx exposed
```


Vamos pegar qual é o ip de nosso service do nginx que acabamos de criar:


```
# kubectl get svc nginx 
NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.104.209.243   <none>        80/TCP    11s
```


Vamos ver os detalhes desse pod:


```
# kubectl describe pod nginx
Name:         nginx
Namespace:    default
Priority:     0
Node:         elliot-03/172.31.24.60
Start Time:   Sun, 10 May 2020 17:23:42 +0000
Labels:       run=nginx
Annotations:  <none>
Status:       Running
IP:           10.46.0.1
IPs:
  IP:  10.46.0.1
Containers:
  nginx:
    Container ID:   docker://1702c47ba9ce36bb65801bb78ae4e8411acad30a0cf5e3c621d128944236b567
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:86ae264c3f4acb99b2dee4d0098c40cb8c46dcf9e1148f05d3a51c4df6758c12
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sun, 10 May 2020 17:23:45 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-q7pdb (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  default-token-q7pdb:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-q7pdb
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason   Age   From                      Message
  ----    ------   ----  ----                      -------
  Normal  Pulling  77s   kubelet, elliot-03  Pulling image "nginx"
  Normal  Pulled   76s   kubelet, elliot-03  Successfully pulled image "nginx"
  Normal  Created  76s   kubelet, elliot-03  Created container nginx
  Normal  Started  75s   kubelet, elliot-03  Started container nginx
```


Vamos ver o pod com mais detalhes:


```
# kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP          NODE              NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          2m15s   10.46.0.1   elliot-03   <none>           <none>
```


Vamos deletar o nosso pod:

```
# kubectl delete pods nginx
pod "nginx" deleted
```


Veja os pods novamente:


```
# kubectl get pods
No resources found in default namespace.
```