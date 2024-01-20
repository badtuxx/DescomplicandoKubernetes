# Descomplicando o Kubernetes - Expert Mode

## DAY-5
&nbsp;

## Conteúdo do Day-5

- [Descomplicando o Kubernetes - Expert Mode](#descomplicando-o-kubernetes---expert-mode)
  - [DAY-5](#day-5)
  - [Conteúdo do Day-5](#conteúdo-do-day-5)
  - [Inicio da aula do Day-5](#inicio-da-aula-do-day-5)
    - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
    - [Instalação de um cluster Kubernetes](#instalação-de-um-cluster-kubernetes)
      - [O que é um cluster Kubernetes?](#o-que-é-um-cluster-kubernetes)
      - [Formas de instalar o Kubernetes](#formas-de-instalar-o-kubernetes)
      - [Criando um cluster Kubernetes com o kubeadm](#criando-um-cluster-kubernetes-com-o-kubeadm)
        - [Instalando o kubeadm](#instalando-o-kubeadm)
        - [Desativando o uso do swap no sistema](#desativando-o-uso-do-swap-no-sistema)
        - [Carregando os módulos do kernel](#carregando-os-módulos-do-kernel)
        - [Configurando parâmetros do sistema](#configurando-parâmetros-do-sistema)
        - [Instalando os pacotes do Kubernetes](#instalando-os-pacotes-do-kubernetes)
        - [Instalando o Docker e o containerd](#instalando-o-docker-e-o-containerd)
        - [Configurando o containerd](#configurando-o-containerd)
        - [Habilitando o serviço do kubelet](#habilitando-o-serviço-do-kubelet)
        - [Configurando as portas](#configurando-as-portas)
        - [Iniciando o cluster](#iniciando-o-cluster)
        - [Entendendo o arquivo admin.conf](#entendendo-o-arquivo-adminconf)
        - [Instalando o Weave Net](#instalando-o-weave-net)
        - [O que é o CNI?](#o-que-é-o-cni)
      - [Visualizando detalhes dos nodes](#visualizando-detalhes-dos-nodes)
    - [A sua lição de casa](#a-sua-lição-de-casa)
  - [Final do Day-5](#final-do-day-5)

&nbsp;

## Inicio da aula do Day-5

### O que iremos ver hoje?

Hoje nós iremos falar como instalar o Kubernetes em um cluster com 03 nodes, onde um deles será o control plane e os outros dois serão os workers.

Nós iremos utilizar o `kubeadm` para configurar o nosso cluster. Nós iremos conhecer no detalhe como criar um cluster utilizando 03 instancias EC2 da AWS, mas você pode utilizar qualquer outro tipo de instância, desde que seja uma instância Linux, o importante é entender o processo de instalação do Kubernetes e como seus componentes trabalham juntos.

Espero que você se divirta durante o Day-5, e que aprenda muito com o conteúdo que preparamos para você. Hoje o dia será mais curtinho, mas não menos importante. Bora lá! #VAIIII

### Instalação de um cluster Kubernetes


#### O que é um cluster Kubernetes?

Um cluster Kubernetes é um conjunto de nodes que trabalham juntos para executar todos os nossos `pods`. Um cluster Kubernetes é composto por nodes que podem ser tanto `control plane` quanto `workers`. O `control plane` é responsável por gerenciar o cluster, enquanto os `workers` são responsáveis por executar os `pods` que são criados no cluster pelos usuários.

Quando estamos pensando em um cluster Kubernetes, precisamos lembrar que a principal função do Kubernetes é orquestrar containers. O Kubernetes é um orquestrador de containers, sendo assim quando estamos falando de um cluster Kubernetes, estamos falando de um cluster de orquestradores de containers. Eu sempre gosto de pensar em um cluster Kubernetes como se fosse uma orquestra, onde temos uma pessoa regendo a orquestra, que é o `control plane`, e temos as pessoas musicistas, que estão executando os instrumentos, que são os `workers`.

Sendo assim, o `control plane` é responsável por gerenciar o cluster, como por exemplo:

* Criar e gerenciar os recursos do cluster, como por exemplo, `namespaces`, `deployments`, `services`, `configmaps`, `secrets`, etc.
* Gerenciar os `workers` do cluster.
* Gerenciar a rede do cluster. 
* O `etcd` desempenha um papel crucial na manutenção da estabilidade e confiabilidade do cluster. Ele armazena as informações de configuração de todos os componentes do `control plane`, incluindo os detalhes dos serviços, `pods` e outros recursos do cluster. Graças ao seu design distribuído, o `etcd` é capaz de tolerar falhas e garantir a continuidade dos dados, mesmo em caso de falha de um ou mais nós. Além disso, ele suporta a comunicação segura entre os componentes do cluster, usando criptografia `TLS` para proteger os dados.

* O `scheduler` é o componente responsável por decidir em qual nó os `pods` serão executados, levando em consideração os requisitos e os recursos disponíveis. O `scheduler` também monitora constantemente a situação do cluster e, se necessário, ajusta a distribuição dos pods para garantir a melhor utilização dos recursos e manter a harmonia entre os componentes. 

* O `controller-manager` é responsável por gerenciar os diferentes controladores que regulam o estado do cluster e mantêm tudo funcionando. Ele monitora constantemente o estado atual dos recursos e compara-os com o estado desejado, fazendo ajustes conforme necessário.

* Onde está o `api-server` é o componente central que expõe a API do Kubernetes, permitindo que outros componentes do `control plane`, como o `controller-manager` e o `scheduler`, bem como ferramentas externas, se comuniquem e interajam com o cluster. O `api-server` é a principal interface de comunicação do Kubernetes, autenticando e autorizando solicitações, processando-as e fornecendo as respostas apropriadas. Ele garante que as informações sejam compartilhadas e acessadas de forma segura e eficiente, possibilitando uma colaboração harmoniosa entre todos os componentes do cluster.


Já no lado dos `workers`, as coisa são bem mais simples, pois a principal função deles é executar os `pods` que são criados no cluster pelos usuários. Nos `workers` nós temos, por padrão, os seguintes componentes do Kubernetes:

* O `kubelet` é o agente que funciona em cada nó do cluster, garantindo que os containers estejam funcionando conforme o esperado dentro dos pods. Ele assume o controle de cada nó, garantindo que os containers estejam sendo executados conforme as instruções recebidas do `control plane`. Ele monitora constantemente o estado atual dos `pods` e compara-os com o estado desejado. Caso haja alguma divergência, o `kubelet` faz os ajustes necessários para que os containers sigam funcionando perfeitamente.

* O `kube-proxy`, que é o componente responsável fazer ser possível que os `pods` e os `services` se comuniquem entre si e com o mundo externo. Ele observa o `control plane` para identificar mudanças na configuração dos serviços e, em seguida, atualiza as regras de encaminhamento de tráfego para garantir que tudo continue fluindo conforme o esperado.


* Todos os `pods` de nossas aplicações.



#### Formas de instalar o Kubernetes

Hoje nós iremos focar a instalação do Kubernetes utilizando o `kubeadm`, que é uma das formas mais antigas para a criação de um cluster Kubernetes. Mas existem outras formas de instalar o Kubernetes, vou detalhar algumas delas aqui:

* **`kubeadm`**: É uma ferramenta para criar e gerenciar um cluster Kubernetes em vários nós. Ele automatiza muitas das tarefas de configuração do cluster, incluindo a instalação do control plane e dos nodes. É altamente configurável e pode ser usado para criar clusters personalizados.

* **`Kubespray`**: É uma ferramenta que usa o Ansible para implantar e gerenciar um cluster Kubernetes em vários nós. Ele oferece muitas opções para personalizar a instalação do cluster, incluindo a escolha do provedor de rede, o número de réplicas do control plane, o tipo de armazenamento e muito mais. É uma boa opção para implantar um cluster em vários ambientes, incluindo nuvens públicas e privadas.

* **`Cloud Providers`**: Muitos provedores de nuvem, como AWS, Google Cloud Platform e Microsoft Azure, oferecem opções para implantar um cluster Kubernetes em sua infraestrutura. Eles geralmente fornecem modelos predefinidos que podem ser usados para implantar um cluster com apenas alguns cliques. Alguns provedores de nuvem também oferecem serviços gerenciados de Kubernetes que lidam com toda a configuração e gerenciamento do cluster.

* **`Kubernetes Gerenciados`**: São serviços gerenciados oferecidos por alguns provedores de nuvem, como Amazon EKS, o GKE do Google Cloud e o AKS, da Azure. Eles oferecem um cluster Kubernetes gerenciado onde você só precisa se preocupar em implantar e gerenciar seus aplicativos. Esses serviços lidam com a configuração, atualização e manutenção do cluster para você. Nesse caso, você não tem que gerenciar o `control plane` do cluster, pois ele é gerenciado pelo provedor de nuvem.

* **`Kops`**: É uma ferramenta para implantar e gerenciar clusters Kubernetes na nuvem. Ele foi projetado especificamente para implantação em nuvens públicas como AWS, GCP e Azure. Kops permite criar, atualizar e gerenciar clusters Kubernetes na nuvem. Algumas das principais vantagens do uso do Kops são a personalização, escalabilidade e segurança. No entanto, o uso do Kops pode ser mais complexo do que outras opções de instalação do Kubernetes, especialmente se você não estiver familiarizado com a nuvem em que está implantando.

* **`Minikube` e `kind`**: São ferramentas que permitem criar um cluster Kubernetes localmente, em um único nó. São úteis para testar e aprender sobre o Kubernetes, pois você pode criar um cluster em poucos minutos e começar a implantar aplicativos imediatamente. Elas também são úteis para pessoas desenvolvedoras que precisam testar suas aplicações em um ambiente Kubernetes sem precisar configurar um cluster em um ambiente de produção.

Ainda existem outras formas de instalar o Kubernetes, mas essas são as mais comuns. Para mais detalhes sobre as outras formas de instalar o Kubernetes, você pode consultar a documentação oficial do Kubernetes.


#### Criando um cluster Kubernetes com o kubeadm

Agora que você já sabe o que é o Kubernetes e quais são as suas principais funcionalidades, vamos começar a instalar o Kubernetes em nosso cluster. Nesse momento iremos ver como realizar a criação de um cluster Kubernetes utilizando o `kubeadm`, porém no decorrer da nossa jornada iremos ver outras formas de instalar o Kubernetes.

Como falado, o `kubeadm` é uma ferramenta para criar e gerenciar um cluster Kubernetes em vários nós. Ele automatiza muitas das tarefas de configuração do cluster, incluindo a instalação do `control plane` e dos `nodes`.

Primeira coisa, para que possamos seguir em frente, temos que entender quais são os pré-requisitos para a instalação do Kubernetes. Para isso, você pode consultar a documentação oficial do Kubernetes, mas vou listar aqui os principais pré-requisitos:

* Linux

* 2 GB ou mais de RAM por máquina (menos de 2 GB não é recomendado)

* 2 CPUs ou mais

* Conexão de rede entre todas os nodes no cluster (pode ser via rede pública ou privada)

* Algumas portas precisam estar abertas para que o cluster funcione corretamente, as principais:

    * Porta 6443: É a porta padrão usada pelo Kubernetes API Server para se comunicar com os componentes do cluster. É a porta principal usada para gerenciar o cluster e deve estar sempre aberta.

    * Portas 10250-10255: Essas portas são usadas pelo kubelet para se comunicar com o control plane do Kubernetes. A porta 10250 é usada para comunicação de leitura/gravação e a porta 10255 é usada apenas para comunicação de leitura.

    * Porta 30000-32767: Essas portas são usadas para serviços NodePort que precisam ser acessíveis fora do cluster. O Kubernetes aloca uma porta aleatória dentro desse intervalo para cada serviço NodePort e redireciona o tráfego para o pod correspondente.

    * Porta 2379-2380: Essas portas são usadas pelo etcd, o banco de dados de chave-valor distribuído usado pelo control plane do Kubernetes. A porta 2379 é usada para comunicação de leitura/gravação e a porta 2380 é usada apenas para comunicação de eleição.


&nbsp;

##### Instalando o kubeadm
Estamos aqui para configurar nosso ambiente Kubernetes e, olha só, é simples como voar! Vamos lá!

##### Desativando o uso do swap no sistema

Primeiro, vamos desativar a utilização de swap no sistema. Isso é necessário porque o Kubernetes não trabalha bem com swap ativado:

```
sudo swapoff -a
```

##### Carregando os módulos do kernel

Agora, vamos carregar os módulos do kernel necessários para o funcionamento do Kubernetes:

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

##### Configurando parâmetros do sistema

Em seguida, vamos configurar alguns parâmetros do sistema. Isso garantirá que nosso cluster funcione corretamente:

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

##### Instalando os pacotes do Kubernetes

Hora de instalar os pacotes do Kubernetes! Coisa linda de ai meu Deus! Aqui vamos nós:

```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

##### Instalando o containerd

Em seguida, vamos instalar o containerd, que são essenciais para nosso ambiente Kubernetes:

```
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io
```

##### Configurando o containerd

Agora, vamos configurar o containerd para que ele funcione adequadamente com o nosso cluster:

```
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd
```

##### Habilitando o serviço do kubelet

Por fim, vamos habilitar o serviço do kubelet para que ele inicie automaticamente com o sistema:

```
sudo systemctl enable --now kubelet
```

##### Configurando as portas

Antes de iniciar o cluster, lembre-se das portas que precisam estar abertas para que o cluster funcione corretamente. Precisamos ter as portas TCP 6443, 10250-10255, 30000-32767 e 2379-2380 abertas entre os nodes do cluster. No nosso exemplo, onde estaremos usando somente um node `control plane`, não precisamos nos preocupar com algumas quando temos mais de um node `control plane`, pois eles precisam se comunicar entre si para manter o estado do cluster, ou ainda as portas 30000-32767, que são usadas para serviços NodePort que precisam ser acessíveis fora do cluster. Elas nós podemos ir abrindo conforme a necessidade, conforme vamos criando os nossos serviços.

Por agora o que precisamos garantir são as portas TCP 6443 somente no `control plane` e as 10250-10255 abertas em todos nodes do cluster.

Em nosso exemplo vamos utilizar como CNI o Weave Net, que é um CNI que utiliza o protocolo de roteamento de pacotes do Kubernetes para criar uma rede entre os pods. Falarei mais sobre ele mais pra frente, mas como estamos falando das portas que são importantes para o cluster funcionar, precisamos abrir a porta TCP 6783 e as portas UDP 6783 e 6784, para que o Weave Net funcione corretamente.

Então já sabe, não esqueça de abrir as portas TCP 6443, 10250-10255 e 6783 no seu firewall.

##### Inicializando o cluster

Agora que temos tudo configurado, vamos iniciar o nosso cluster:

```
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=<O IP QUE VAI FALAR COM OS NODES>
```

&nbsp;


Substitua `<O IP QUE VAI FALAR COM OS NODES>` pelo endereço IP da máquina que está atuando como `control plane`.

Após a execução bem-sucedida do comando acima, você verá uma mensagem informando que o cluster foi inicializado com sucesso e todos os detalhes de sua inicialização, conforme é possível ver na saída do comando:

```bash
[init] Using Kubernetes version: v1.26.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.31.57.89]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-01 localhost] and IPs [172.31.57.89 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-01 localhost] and IPs [172.31.57.89 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 7.504091 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-01 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: if9hn9.xhxo6s89byj9rsmd
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.57.89:6443 --token if9hn9.xhxo6s89byj9rsmd \
	--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477 

```

&nbsp;

Inclusive, você verá uma lista de comandos para configurar o acesso ao cluster com o kubectl. Copie e cole esse comando em seu terminal:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

&nbsp;

Essa configuração é necessária para que o kubectl possa se comunicar com o cluster, pois quando estamos copiando o arquivo `admin.conf` para o diretório `.kube` do usuário, estamos copiando o arquivo com as permissões de root, esse é o motivo de executarmos o comando `sudo chown $(id -u):$(id -g) $HOME/.kube/config` para alterar as permissões do arquivo para o usuário que está executando o comando.


##### Entendendo o arquivo admin.conf
Agora precisamos entender o que temos dentro do arquivo `admin.conf`. Antes de mais nada precisamos conhecer alguns pontos importantes sobre o a estrutura do arquivo `admin.conf`:

- É um arquivo de configuração do kubectl, que é o cliente de linha de comando do Kubernetes. Ele é usado para se comunicar com o cluster Kubernetes.

- Contém as informações de acesso ao cluster, como o endereço do servidor API, o certificado de cliente e o token de autenticação.

- Eu posso ter mais de um contexto dentro do arquivo `admin.conf`, onde cada contexto é um cluster Kubernetes. Por exemplo, eu posso ter um contexto para o cluster de produção e outro para o cluster de desenvolvimento, simples como voar.

- Ele contém os dados de acesso ao cluster, portanto, se alguém tiver acesso a esse arquivo, ele terá acesso ao cluster. (Desde que tenha acesso ao cluster, claro).

- O arquivo `admin.conf` é criado quando o cluster é inicializado.


Vou copiar aqui o conteúdo de um exemplo de arquivo `admin.conf`:

```yaml
apiVersion: v1

clusters:
- cluster:
    certificate-authority-data: SEU_CERTIFICADO_AQUI
    server: https://172.31.57.89:6443
  name: kubernetes

contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes

current-context: kubernetes-admin@kubernetes

kind: Config

preferences: {}

users:
- name: kubernetes-admin
  user:
    client-certificate-data: SUA_CHAVE_PUBLICA_AQUI
    client-key-data: SUA_CHAVE_PRIVADA_AQUI
```

&nbsp;

Simplificando, temos a seguinte estrutura:

```yaml
apiVersion: v1
clusters:
#...
contexts:
#...
current-context: kind-kind-multinodes
kind: Config
preferences: {}
users:
#...
```

&nbsp;

Vamos ver o que temos dentro de cada seção:

**Clusters**

A seção clusters contém informações sobre os clusters Kubernetes que você deseja acessar, como o endereço do servidor API e o certificado de autoridade. Neste arquivo, há somente um cluster chamado kubernetes, que é o cluster que acabamos de criar.

```yaml
- cluster:
    certificate-authority-data: SEU_CERTIFICADO_AQUI
    server: https://172.31.57.89:6443
  name: kubernetes
```

&nbsp;

**Contextos**

A seção contexts define configurações específicas para cada combinação de cluster, usuário e namespace. Nós somente temos um contexto configurado. Ele é chamado kubernetes-admin@kubernetes e combina o cluster kubernetes com o usuário kubernetes-admin.

```yaml
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
```

&nbsp;


**Contexto atual**

A propriedade current-context indica o contexto atualmente ativo, ou seja, qual combinação de cluster, usuário e namespace será usada ao executar comandos kubectl. Neste arquivo, o contexto atual é o kubernetes-admin@kubernetes.

```yaml
current-context: kubernetes-admin@kubernetes
```

&nbsp;

**Preferências**

A seção preferences contém configurações globais que afetam o comportamento do kubectl. Aqui podemos definir o editor de texto padrão, por exemplo.

```yaml
preferences: {}
```

&nbsp;

**Usuários**

A seção users contém informações sobre os usuários e suas credenciais para acessar os clusters. Neste arquivo, há somente um usuário chamado kubernetes-admin. Ele contém os dados do certificado de cliente e da chave do cliente.

```yaml
- name: kubernetes-admin
  user:
    client-certificate-data: SUA_CHAVE_PUBLICA_AQUI
    client-key-data: SUA_CHAVE_PRIVADA_AQUI
```

&nbsp;


Outra informação super importante que está contida nesse arquivo é referente as credenciais de acesso ao cluster. Essas credenciais são usadas para autenticar o usuário que está executando o comando kubectl. Essas credenciais são:

- **Token de autenticação**: É um token de acesso que é usado para autenticar o usuário que está executando o comando kubectl. Esse token é gerado automaticamente quando o cluster é inicializado. Esse token é usado para autenticar o usuário que está executando o comando kubectl. Esse token é gerado automaticamente quando o cluster é inicializado.

- **certificate-authority-data**: Este campo contém a representação em base64 do certificado da autoridade de certificação (CA) do cluster. A CA é responsável por assinar e emitir certificados para o cluster. O certificado da CA é usado para verificar a autenticidade dos certificados apresentados pelo servidor de API e pelos clientes, garantindo que a comunicação entre eles seja segura e confiável.

- **client-certificate-data**: Este campo contém a representação em base64 do certificado do cliente. O certificado do cliente é usado para autenticar o usuário ao se comunicar com o servidor de API do Kubernetes. O certificado é assinado pela autoridade de certificação (CA) do cluster e inclui informações sobre o usuário e sua chave pública.

- **client-key-data**: Este campo contém a representação em base64 da chave privada do cliente. A chave privada é usada para assinar as solicitações enviadas ao servidor de API do Kubernetes, permitindo que o servidor verifique a autenticidade da solicitação. A chave privada deve ser mantida em sigilo e não compartilhada com outras pessoas ou sistemas.

Esses campos são importantes para estabelecer uma comunicação segura e autenticada entre o cliente (geralmente o kubectl ou outras ferramentas de gerenciamento) e o servidor de API do Kubernetes. Eles permitem que o servidor de API verifique a identidade do cliente e vice-versa, garantindo que apenas usuários e sistemas autorizados possam acessar e gerenciar os recursos do cluster.

&nbsp;

Você pode encontrar os arquivos que são utilizados para adicionar essas credentiais ao seu cluster em `/etc/kubernetes/pki/`.
Lá temos os seguintes arquivos que são utilizados para adicionar essas credenciais ao seu cluster:

- **client-certificate-data**: O arquivo de certificado do cliente geralmente é encontrado em /etc/kubernetes/pki/apiserver-kubelet-client.crt.

- **client-key-data**: O arquivo da chave privada do cliente geralmente é encontrado em /etc/kubernetes/pki/apiserver-kubelet-client.key.

- **certificate-authority-data**: O arquivo do certificado da autoridade de certificação (CA) geralmente é encontrado em /etc/kubernetes/pki/ca.crt.

Vale lembrar que esse arquivo é gerado automaticamente quando o cluster é inicializado, e são adicionados ao arquivo `admin.conf` que é utilizado para acessar o cluster. Essas credenciais são copiadas para o arquivo `admin.conf` já convertidas para base64.

&nbsp;

Pronto, agora você já sabe o porquê copiamos o arquivo `admin.conf` para o diretório `~/.kube/` e como ele funciona.


Caso você queira, você pode acessar o conteúdo do arquivo `admin.conf` com o seguinte comando:


```bash
kubectl config view
```

&nbsp;

Ele somente irá omitir os dados de certificados e chaves privadas, que são muito grandes para serem exibidos no terminal.

&nbsp;

##### Adicionando os demais nodes ao cluster

Agora que já temos o nosso cluster inicializado e já estamos entendendo muito bem o que é o arquivo `admin.conf`, chegou o momento de adicionar os demais nodes ao nosso cluster.

Para isso, vamos novamente utilizar o comando `kubeadm`, porém ao invés de executar o comando no node do control plane, nesse momento precisamos rodar o comando diretamente no node que queremos adicionar ao cluster.

Quando inicializamos o nosso cluster, o `kubeadm` nos mostrou o comando que precisamos executar no novos nodes, para que eles possam ser adicinados ao cluster como `workers`.

```bash
sudo kubeadm join 172.31.57.89:6443 --token if9hn9.xhxo6s89byj9rsmd \
	--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477 
```

&nbsp;

O comando kubeadm join é usado para adicionar um novo node ao cluster Kubernetes existente. Ele é executado nos worker nodes para que eles possam se juntar ao cluster e receber instruções do control plane. Vamos analisar as partes do comando fornecido:

- **kubeadm join**: O comando base para adicionar um novo nó ao cluster.

- **172.31.57.89:6443**: Endereço IP e porta do servidor de API do nó mestre (control plane). Neste exemplo, o nó mestre está localizado no IP 172.31.57.89 e a porta é 6443.

- **--token if9hn9.xhxo6s89byj9rsmd**: O token é usado para autenticar o nó trabalhador no nó mestre durante o processo de adesão. Os tokens são gerados pelo nó mestre e têm uma validade limitada (por padrão, 24 horas). Neste exemplo, o token é if9hn9.xhxo6s89byj9rsmd.

- **--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477**: Este é um hash criptográfico do certificado da autoridade de certificação (CA) do control plane. Ele é usado para garantir que o nó worker esteja se comunicando com o nó do control plane correto e autêntico. O valor após sha256: é o hash do certificado CA.

Ao executar este comando no worker, ele iniciará o processo de adesão ao cluster. Se o token for válido e o hash do certificado CA corresponder ao certificado CA do nó do control plane, o nó worker será autenticado e adicionado ao cluster. Após a adesão bem-sucedida, o novo node começará a executar os Pods e a receber instruções do control plane, conforme necessário.

Após executar o `join` em cada worker node, vá até o node que criamos para ser o control plane, e execute:

```bash
kubectl get nodes
```

&nbsp;

```bash
NAME     STATUS   ROLES           AGE   VERSION
k8s-01   NotReady    control-plane   4m   v1.26.3
k8s-02   NotReady    <none>          3m   v1.26.3
k8s-03   NotReady    <none>          3m   v1.26.3
```

&nbsp;

Agora você já consegue ver que os dois novos nodes foram adicionados ao cluster, porém ainda estão com o status `Not Ready`, pois ainda não instalamos o nosso plugin de rede para que seja possível a comunicação entre os pods. Vamos resolver isso agora. :)

##### Instalando o Weave Net

Agora que o cluster está inicializado, vamos instalar o Weave Net:

```
$ kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

&nbsp;

Aguarde alguns minutos até que todos os componentes do cluster estejam em funcionamento. Você pode verificar o status dos componentes do cluster com o seguinte comando:

```
kubectl get pods -n kube-system
```
&nbsp;

```
kubectl get nodes
```

&nbsp;

```bash
NAME     STATUS   ROLES           AGE   VERSION
k8s-01   Ready    control-plane   7m   v1.26.3
k8s-02   Ready    <none>          6m   v1.26.3
k8s-03   Ready    <none>          6m   v1.26.3
```

&nbsp;

O Weave Net é um plugin de rede que permite que os pods se comuniquem entre si. Ele também permite que os pods se comuniquem com o mundo externo, como outros clusters ou a Internet. 
Quando o Kubernetes é instalado, ele resolve vários problemas por si só, porém quando o assunto é a comunicação entre os pods, ele não resolve. Por isso, precisamos instalar um plugin de rede para resolver esse problema.

##### O que é o CNI?

CNI é uma especificação e conjunto de bibliotecas para a configuração de interfaces de rede em containers. A CNI permite que diferentes soluções de rede sejam integradas ao Kubernetes, facilitando a comunicação entre os Pods (grupos de containers) e serviços.

Com isso, temos diferentes plugins de redes, que seguem a especificação CNI, e que podem ser utilizados no Kubernetes. O Weave Net é um desses plugins de rede.

Entre os plugins de rede mais utilizados no Kubernetes, temos:

- **Calico** é um dos plugins de rede mais populares e amplamente utilizados no Kubernetes. Ele fornece segurança de rede e permite a implementação de políticas de rede. O Calico utiliza o BGP (Border Gateway Protocol) para rotear tráfego entre os nós do cluster, proporcionando um desempenho eficiente e escalável.

- **Flannel** é um plugin de rede simples e fácil de configurar, projetado para o Kubernetes. Ele cria uma rede overlay que permite que os Pods se comuniquem entre si, mesmo em diferentes nós do cluster. O Flannel atribui um intervalo de IPs a cada nó e utiliza um protocolo simples para rotear o tráfego entre os nós.

- **Weave** é outra solução popular de rede para Kubernetes. Ele fornece uma rede overlay que permite a comunicação entre os Pods em diferentes nós. Além disso, o Weave suporta criptografia de rede e gerenciamento de políticas de rede. Ele também pode ser integrado com outras soluções, como o Calico, para fornecer recursos adicionais de segurança e políticas de rede.

- **Cilium** é um plugin de rede focado em segurança e desempenho. Ele utiliza o BPF (Berkeley Packet Filter) para fornecer políticas de rede e segurança de alto desempenho. O Cilium também oferece recursos avançados, como balanceamento de carga, monitoramento e solução de problemas de rede.

- **Kube-router** é uma solução de rede leve para Kubernetes. Ele utiliza o BGP e IPVS (IP Virtual Server) para rotear o tráfego entre os nós do cluster, proporcionando um desempenho eficiente e escalável. Kube-router também suporta políticas de rede e permite a implementação de firewalls entre os Pods.

Esses são apenas alguns dos plugins de rede mais populares e amplamente utilizados no Kubernetes. Você pode encontrar uma lista completa de plugins de rede no site do Kubernetes.

Agora, qual você deverá escolher? A resposta é simples: o que melhor se adequar às suas necessidades. Cada plugin de rede tem suas vantagens e desvantagens, e você deve escolher aquele que melhor se adequar ao seu ambiente.

Minha dica, procure não ficar inventando muita moda, tenta utilizar os que são já validados e bem aceitos pela comunidade, como o Weave Net, Calico, Flannel, etc. 

O meu preferido é o `Weave Net` pela simplicidade de instalação e os recursos oferecidos.

Um cara que eu tenho gostado bastante é o `Cilium`, ele é bem completo e tem uma comunidade bem ativa, além de utilizar o BPF, que é um assunto super quente no mundo Kubernetes!

&nbsp;

Pronto, já temos o nosso cluster inicializado e o Weave Net instalado. Agora, vamos criar um Deployment para testar a comunicação entre os Pods.

```bash
kubectl create deployment nginx --image=nginx --replicas 3
```

&nbsp;

```bash
kubectl get pods -o wide
```

&nbsp;

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx-748c667d99-8brrj   1/1     Running   0          12s   10.32.0.4   k8s-02   <none>           <none>
nginx-748c667d99-8knx2   1/1     Running   0          12s   10.40.0.2   k8s-03   <none>           <none>
nginx-748c667d99-l6w7r   1/1     Running   0          12s   10.40.0.1   k8s-03   <none>           <none>
```

&nbsp;

Pronto, nosso cluster está funcionando e os Pods estão em execução em diferentes nós.

Agora você já pode se divertir e utilizar o seu mais novo cluster Kubernetes!

&nbsp;


#### Visualizando detalhes dos nodes

Agora que já temos o nosso clustes com 03 nodes, nós podemos visualizar os detalhes de cada um deles, e assim entender cada detalhe.

Para ver a descrição do node, basta executar o comando abaixo:

```bash
kubectl describe node k8s-01
```

&nbsp;

```bash
Name:               k8s-01
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8s-01
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 07 Apr 2023 11:52:46 +0000
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  k8s-01
  AcquireTime:     <unset>
  RenewTime:       Fri, 07 Apr 2023 12:49:09 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Fri, 07 Apr 2023 11:57:03 +0000   Fri, 07 Apr 2023 11:57:03 +0000   WeaveIsUp                    Weave pod has set this
  MemoryPressure       False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:57:05 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  172.31.57.89
  Hostname:    k8s-01
Capacity:
  cpu:                2
  ephemeral-storage:  7941576Ki
  hugepages-2Mi:      0
  memory:             4015088Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  7318956430
  hugepages-2Mi:      0
  memory:             3912688Ki
  pods:               110
System Info:
  Machine ID:                 c8a6ad1dd24342c48ba303688d3ada1f
  System UUID:                ec2b271b-8df3-f164-b01c-3b5078a2d15b
  Boot ID:                    93ae6b0c-13fa-432d-b15a-d3725b6c0e72
  Kernel Version:             5.15.0-1031-aws
  OS Image:                   Ubuntu 22.04.2 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.20
  Kubelet Version:            v1.26.3
  Kube-Proxy Version:         v1.26.3
PodCIDR:                      10.10.0.0/24
PodCIDRs:                     10.10.0.0/24
Non-terminated Pods:          (6 in total)
  Namespace                   Name                              CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                              ------------  ----------  ---------------  -------------  ---
  kube-system                 etcd-k8s-01                       100m (5%)     0 (0%)      100Mi (2%)       0 (0%)         56m
  kube-system                 kube-apiserver-k8s-01             250m (12%)    0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-controller-manager-k8s-01    200m (10%)    0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-proxy-skpfc                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-scheduler-k8s-01             100m (5%)     0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 weave-net-hks8s                   100m (5%)     0 (0%)      0 (0%)           0 (0%)         52m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                750m (37%)  0 (0%)
  memory             100Mi (2%)  0 (0%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
Events:
  Type     Reason                   Age   From             Message
  ----     ------                   ----  ----             -------
  Normal   Starting                 56m   kube-proxy       
  Normal   Starting                 56m   kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      56m   kubelet          invalid capacity 0 on image filesystem
  Normal   NodeHasSufficientMemory  56m   kubelet          Node k8s-01 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    56m   kubelet          Node k8s-01 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     56m   kubelet          Node k8s-01 status is now: NodeHasSufficientPID
  Normal   NodeAllocatableEnforced  56m   kubelet          Updated Node Allocatable limit across pods
  Normal   RegisteredNode           56m   node-controller  Node k8s-01 event: Registered Node k8s-01 in Controller
  Normal   NodeReady                52m   kubelet          Node k8s-01 status is now: NodeReady
```

&nbsp;

Na saída do comando acima é possível ver detalhes como o nome do node, o IP interno, o hostname, a capacidade de CPU, memória, armazenamento, pods, etc. Também é possível ver os pods que estão rodando no node, os recursos alocados e os eventos que ocorreram no node.

Caso você queira visualizar detalhes dos outros dois nodes, basta utilizar o comando abaixo:

```bash
kubectl get nodes k8s-02 -o wide
kubectl get nodes k8s-03 -o wide
```

&nbsp;

```bash
NAME     STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
k8s-02   Ready    <none>   59m   v1.26.3   172.31.59.34   <none>        Ubuntu 22.04.2 LTS   5.15.0-1031-aws   containerd://1.6.20
```

&nbsp;


Estou utilizando o parâmetro `-o wide` para que o comando retorne mais detalhes sobre o node, como o IP externo e o IP interno.

E claro, você ainda pode utilizar o comando `kubectl describe node` para visualizar mais detalhes dos demais nodes, como fizemos para o node `k8s-01`.


### A sua lição de casa

A sua lição de casa é realizar a instalação do cluster Kubernetes utilizando o Kubeadm. Use a criatividade e teste diferentes plugins de redes.

O mais importante é você ter um cluster Kubernetes funcionando e pronto para ser utilizado, e mais do que isso, é importante que você entenda como o cluster funciona e sinta-se confortável para realizar sua manutenção e a administração.

&nbsp;

## Final do Day-5

Durante o Day-5 você aprendeu como criar um cluster Kubernetes utilizando 3 nodes através do Kubeadm. Você ainda aprender todos os detalhes importantes sobre o cluster e seus componentes. Fizemos a instalação do plugin de rede Weave Net e ainda conhecemos o que é o CNI e os plugins de rede mais utilizados no Kubernetes.

Agora partiu documentação do Kubernetes para que você possa se aprofundar ainda mais no assunto e construir um cluster Kubernetes ainda mais robusto e seguro.

&nbsp;
