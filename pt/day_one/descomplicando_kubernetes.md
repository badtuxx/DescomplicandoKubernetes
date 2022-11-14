# Descomplicando Kubernetes dia 1

## Sumário

- [Descomplicando Kubernetes dia 1](#descomplicando-kubernetes-dia-1)
  - [Sumário](#sumário)
- [O quê preciso saber antes de começar?](#o-quê-preciso-saber-antes-de-começar)
  - [Qual distro GNU/Linux devo usar?](#qual-distro-gnulinux-devo-usar)
  - [Alguns sites que devemos visitar](#alguns-sites-que-devemos-visitar)
  - [E o k8s?](#e-o-k8s)
  - [Arquitetura do k8s](#arquitetura-do-k8s)
  - [Portas que devemos nos preocupar](#portas-que-devemos-nos-preocupar)
  - [Tá, mas qual tipo de aplicação eu devo rodar sobre o k8s?](#tá-mas-qual-tipo-de-aplicação-eu-devo-rodar-sobre-o-k8s)
  - [Conceitos-chave do k8s](#conceitos-chave-do-k8s)
- [Aviso sobre os comandos](#aviso-sobre-os-comandos)
- [Kubectl](#kubectl)
  - [Instalação do Kubectl no GNU/Linux](#instalação-do-kubectl-no-gnulinux)
  - [Instalação do Kubectl no MacOS](#instalação-do-kubectl-no-macos)
  - [Instalação do Kubectl no Windows](#instalação-do-kubectl-no-windows)
  - [kubectl: alias e autocomplete](#kubectl-alias-e-autocomplete)
- [Minikube](#minikube)
  - [Requisitos básicos](#requisitos-básicos)
  - [Instalação do Minikube no GNU/Linux](#instalação-do-minikube-no-gnulinux)
  - [Instalação do Minikube no MacOS](#instalação-do-minikube-no-macos)
  - [Instalação do Minikube no Microsoft Windows](#instalação-do-minikube-no-microsoft-windows)
  - [Iniciando, parando e excluindo o Minikube](#iniciando-parando-e-excluindo-o-minikube)
  - [Certo, e como eu sei que está tudo funcionando como deveria?](#certo-e-como-eu-sei-que-está-tudo-funcionando-como-deveria)
  - [Descobrindo o endereço do Minikube](#descobrindo-o-endereço-do-minikube)
  - [Acessando a máquina do Minikube via SSH](#acessando-a-máquina-do-minikube-via-ssh)
  - [Dashboard](#dashboard)
  - [Logs](#logs)
- [Microk8s](#microk8s)
  - [Requisitos básicos](#requisitos-básicos-1)
  - [Instalação do MicroK8s no GNU/Linux](#instalação-do-microk8s-no-gnulinux)
    - [Versões que suportam Snap](#versões-que-suportam-snap)
  - [Instalação no Windows](#instalação-no-windows)
    - [Instalando o Chocolatey](#instalando-o-chocolatey)
      - [Instalando o Multipass](#instalando-o-multipass)
    - [Utilizando Microk8s com Multipass](#utilizando-microk8s-com-multipass)
  - [Instalando o Microk8s no MacOS](#instalando-o-microk8s-no-macos)
    - [Instalando o Brew](#instalando-o-brew)
    - [Instalando o Microk8s via Brew](#instalando-o-microk8s-via-brew)
- [Kind](#kind)
  - [Instalação no GNU/Linux](#instalação-no-gnulinux)
  - [Instalação no MacOS](#instalação-no-macos)
  - [Instalação no Windows](#instalação-no-windows-1)
    - [Instalação no Windows via Chocolatey](#instalação-no-windows-via-chocolatey)
  - [Criando um cluster com o Kind](#criando-um-cluster-com-o-kind)
    - [Criando um cluster com múltiplos nós locais com o Kind](#criando-um-cluster-com-múltiplos-nós-locais-com-o-kind)
- [k3s](#k3s)
- [Instalação do cluster Kubernetes em três nós](#instalação-do-cluster-kubernetes-em-três-nós)
  - [Requisitos básicos](#requisitos-básicos-2)
  - [Configuração de módulos de kernel](#configuração-de-módulos-de-kernel)
  - [Atualização da distribuição](#atualização-da-distribuição)
  - [Instalação do Docker e do Kubernetes](#instalação-do-docker-e-do-kubernetes)
  - [Inicialização do cluster](#inicialização-do-cluster)
  - [Configuração do arquivo de contextos do kubectl](#configuração-do-arquivo-de-contextos-do-kubectl)
  - [Inserindo os nós workers no cluster](#inserindo-os-nós-workers-no-cluster)
    - [Múltiplas Interfaces](#múltiplas-interfaces)
  - [Instalação do pod network](#instalação-do-pod-network)
  - [Verificando a instalação](#verificando-a-instalação)
- [Primeiros passos no k8s](#primeiros-passos-no-k8s)
  - [Exibindo informações detalhadas sobre os nós](#exibindo-informações-detalhadas-sobre-os-nós)
  - [Exibindo novamente token para entrar no cluster](#exibindo-novamente-token-para-entrar-no-cluster)
  - [Ativando o autocomplete](#ativando-o-autocomplete)
  - [Verificando os namespaces e pods](#verificando-os-namespaces-e-pods)
  - [Executando nosso primeiro pod no k8s](#executando-nosso-primeiro-pod-no-k8s)
  - [Verificar os últimos eventos do cluster](#verificar-os-últimos-eventos-do-cluster)
  - [Efetuar o dump de um objeto em formato YAML](#efetuar-o-dump-de-um-objeto-em-formato-yaml)
  - [Socorro, são muitas opções!](#socorro-são-muitas-opções)
  - [Expondo o pod](#expondo-o-pod)
  - [Limpando tudo e indo para casa](#limpando-tudo-e-indo-para-casa)



## O quê preciso saber antes de começar?

Durante essa sessão vamos saber tudo o que precisamos antes de começar a sair criando o nosso cluster ou então nossos deployments.


### Qual distro GNU/Linux devo usar?

Devido ao fato de algumas ferramentas importantes, como o ``systemd`` e ``journald``, terem se tornado padrão na maioria das principais distribuições disponíveis hoje, você não deve encontrar problemas para seguir o treinamento, caso você opte por uma delas, como Ubuntu, Debian, CentOS e afins.

### Alguns sites que devemos visitar

Abaixo temos os sites oficiais do projeto do Kubernetes:

- [https://kubernetes.io](https://kubernetes.io)

- [https://github.com/kubernetes/kubernetes/](https://github.com/kubernetes/kubernetes/)

- [https://github.com/kubernetes/kubernetes/issues](https://github.com/kubernetes/kubernetes/issues)


Abaixo temos as páginas oficiais das certificações do Kubernetes (CKA, CKAD e CKS):

- [https://www.cncf.io/certification/cka/](https://www.cncf.io/certification/cka/)

- [https://www.cncf.io/certification/ckad/](https://www.cncf.io/certification/ckad/)

- [https://www.cncf.io/certification/cks/](https://www.cncf.io/certification/cks/)


Outro site importante de conhecer e estudar, é o site dos 12 fatores, muito importante para o desenvolvimento de aplicações que tem como objetivo serem executadas em cluster Kubernetes:

- [https://12factor.net/pt_br/](https://12factor.net/pt_br/)



## O que é o Kubernetes?

**Versão resumida:**

O projeto Kubernetes foi desenvolvido pela Google, em meados de 2014, para atuar como um orquestrador de contêineres para a empresa. O Kubernetes (k8s), cujo termo em Grego significa "timoneiro", é um projeto *open source* que conta com *design* e desenvolvimento baseados no projeto Borg, que também é da Google [1](https://kubernetes.io/blog/2015/04/borg-predecessor-to-kubernetes/). Alguns outros produtos disponíveis no mercado, tais como o Apache Mesos e o Cloud Foundry, também surgiram a partir do projeto Borg.

Como Kubernetes é uma palavra difícil de se pronunciar - e de se escrever - a comunidade simplesmente o apelidou de **k8s**, seguindo o padrão [i18n](http://www.i18nguy.com/origini18n.html) (a letra "k" seguida por oito letras e o "s" no final), pronunciando-se simplesmente "kates".

**Versão longa:**

Praticamente todo software desenvolvido na Google é executado em contêiner [2](https://www.enterpriseai.news/2014/05/28/google-runs-software-containers/). A Google já gerencia contêineres em larga escala há mais de uma década, quando não se falava tanto sobre isso. Para atender a demanda interna, alguns desenvolvedores do Google construíram três sistemas diferentes de gerenciamento de contêineres: **Borg**, **Omega** e **Kubernetes**. Cada sistema teve o desenvolvimento bastante influenciado pelo antecessor, embora fosse desenvolvido por diferentes razões.

O primeiro sistema de gerenciamento de contêineres desenvolvido no Google foi o Borg, construído para gerenciar serviços de longa duração e jobs em lote, que anteriormente eram tratados por dois sistemas:  **Babysitter** e **Global Work Queue**. O último influenciou fortemente a arquitetura do Borg, mas estava focado em execução de jobs em lote. O Borg continua sendo o principal sistema de gerenciamento de contêineres dentro do Google por causa de sua escala, variedade de recursos e robustez extrema.

O segundo sistema foi o Omega, descendente do Borg. Ele foi impulsionado pelo desejo de melhorar a engenharia de software do ecossistema Borg. Esse sistema aplicou muitos dos padrões que tiveram sucesso no Borg, mas foi construído do zero para ter a arquitetura mais consistente. Muitas das inovações do Omega foram posteriormente incorporadas ao Borg.

O terceiro sistema foi o Kubernetes. Concebido e desenvolvido em um mundo onde desenvolvedores externos estavam se interessando em contêineres e o Google desenvolveu um negócio em amplo crescimento atualmente, que é a venda de infraestrutura de nuvem pública.

O Kubernetes é de código aberto - em contraste com o Borg e o Omega que foram desenvolvidos como sistemas puramente internos do Google. O Kubernetes foi desenvolvido com um foco mais forte na experiência de desenvolvedores que escrevem aplicativos que são executados em um cluster: seu principal objetivo é facilitar a implantação e o gerenciamento de sistemas distribuídos, enquanto se beneficia do melhor uso de recursos de memória e processamento que os contêineres possibilitam.

Estas informações foram extraídas e adaptadas deste [artigo](https://static.googleusercontent.com/media/research.google.com/pt-BR//pubs/archive/44843.pdf), que descreve as lições aprendidas com o desenvolvimento e operação desses sistemas.

### Arquitetura do k8s

Assim como os demais orquestradores disponíveis, o k8s também segue um modelo *control plane/workers*, constituindo assim um *cluster*, onde para seu funcionamento é recomendado no mínimo três nós: o nó *control-plane*, responsável (por padrão) pelo gerenciamento do *cluster*, e os demais como *workers*, executores das aplicações que queremos executar sobre esse *cluster*.

É possível criar um cluster Kubernetes rodando em apenas um nó, porém é recomendado somente para fins de estudos e nunca executado em ambiente produtivo.

Caso você queira utilizar o Kubernetes em sua máquina local, em seu desktop, existem diversas soluções que irão criar um cluster Kubernetes, utilizando máquinas virtuais ou o Docker, por exemplo.

Com isso você poderá ter um cluster Kubernetes com diversos nós, porém todos eles rodando em sua máquina local, em seu desktop.

Alguns exemplos são:

* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start): Uma ferramenta para execução de contêineres Docker que simulam o funcionamento de um cluster Kubernetes. É utilizado para fins didáticos, de desenvolvimento e testes. O **Kind não deve ser utilizado para produção**;

* [Minikube](https://github.com/kubernetes/minikube): ferramenta para implementar um *cluster* Kubernetes localmente com apenas um nó. Muito utilizado para fins didáticos, de desenvolvimento e testes. O **Minikube não deve ser utilizado para produção**;

* [MicroK8S](https://microk8s.io): Desenvolvido pela [Canonical](https://canonical.com), mesma empresa que desenvolve o [Ubuntu](https://ubuntu.com). Pode ser utilizado em diversas distribuições e **pode ser utilizado em ambientes de produção**, em especial para *Edge Computing* e IoT (*Internet of things*);

* [k3s](https://k3s.io): Desenvolvido pela [Rancher Labs](https://rancher.com), é um concorrente direto do MicroK8s, podendo ser executado inclusive em Raspberry Pi.

* [k0s](https://k0sproject.io): Desenvolvido pela [Mirantis](https://www.mirantis.com), mesma empresa que adquiriu a parte enterprise do [Docker](https://www.docker.com). É uma distribuição do Kubernetes com todos os recursos necessários para funcionar em um único binário, que proporciona uma simplicidade na instalação e manutenção do cluster. A pronúncia é correta é kay-zero-ess e tem por objetivo reduzir o esforço técnico e desgaste na instalação de um cluster Kubernetes, por isso o seu nome faz alusão a *Zero Friction*. **O k0s pode ser utilizado em ambientes de produção**

A figura a seguir mostra a arquitetura interna de componentes do k8s.

| ![Arquitetura Kubernetes](../../images/kubernetes_architecture.png) |
|:---------------------------------------------------------------------------------------------:|
| *Arquitetura Kubernetes [Ref: phoenixnap.com KB article](https://phoenixnap.com/kb/understanding-kubernetes-architecture-diagrams)*                                                                      |


* **API Server**: É um dos principais componentes do k8s. Este componente fornece uma API que utiliza JSON sobre HTTP para comunicação, onde para isto é utilizado principalmente o utilitário ``kubectl``, por parte dos administradores, para a comunicação com os demais nós, como mostrado no gráfico. Estas comunicações entre componentes são estabelecidas através de requisições [REST](https://restfulapi.net);

* **etcd**: O etcd é um *datastore* chave-valor distribuído que o k8s utiliza para armazenar as especificações, status e configurações do *cluster*. Todos os dados armazenados dentro do etcd são manipulados apenas através da API. Por questões de segurança, o etcd é por padrão executado apenas em nós classificados como *control plane* no *cluster* k8s, mas também podem ser executados em *clusters* externos, específicos para o etcd, por exemplo;

* **Scheduler**: O *scheduler* é responsável por selecionar o nó que irá hospedar um determinado *pod* (a menor unidade de um *cluster* k8s - não se preocupe sobre isso por enquanto, nós falaremos mais sobre isso mais tarde) para ser executado. Esta seleção é feita baseando-se na quantidade de recursos disponíveis em cada nó, como também no estado de cada um dos nós do *cluster*, garantindo assim que os recursos sejam bem distribuídos. Além disso, a seleção dos nós, na qual um ou mais pods serão executados, também pode levar em consideração políticas definidas pelo usuário, tais como afinidade, localização dos dados a serem lidos pelas aplicações, etc;

* **Controller Manager**: É o *controller manager* quem garante que o *cluster* esteja no último estado definido no etcd. Por exemplo: se no etcd um *deploy* está configurado para possuir dez réplicas de um *pod*, é o *controller manager* quem irá verificar se o estado atual do *cluster* corresponde a este estado e, em caso negativo, procurará conciliar ambos;

* **Kubelet**: O *kubelet* pode ser visto como o agente do k8s que é executado nos nós workers. Em cada nó worker deverá existir um agente Kubelet em execução. O Kubelet é responsável por de fato gerenciar os *pods*, que foram direcionados pelo *controller* do *cluster*, dentro dos nós, de forma que para isto o Kubelet pode iniciar, parar e manter os contêineres e os pods em funcionamento de acordo com o instruído pelo controlador do cluster;

* **Kube-proxy**: Age como um *proxy* e um *load balancer*. Este componente é responsável por efetuar roteamento de requisições para os *pods* corretos, como também por cuidar da parte de rede do nó;

* **Container Runtime**: O *container runtime* é o ambiente de execução de contêineres necessário para o funcionamento do k8s. Desde a versão v1.24 o k8s requer que você utilize um container runtime compativel com o CRI (Container Runtime Interface) que foi apresentado em 2016 como um interface capaz de criar um padrão de comunicação entre o container runtime e k8s. Versões anteriores à v1.24 ofereciam integração direta com o Docker Engine usando um componente chamado dockershim porém essa integração direta não está mais disponível. A documentação oficial do kubernetes (v1.24) apresenta alguns ambientes de execução e suas respectivas configurações como o [containerd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd) um projeto avaliado com o nível graduado pela CNCF (Cloud Native Computing Foundation) e o [CRI-0](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o) projeto incubado pela CNCF.

> Projetos graduados e incubados pela CNCF são considerados estáveis ​​e utilizados com sucesso em produção.

### Portas que devemos nos preocupar

**CONTROL PLANE**

Protocol|Direction|Port Range|Purpose|Used By
--------|---------|----------|-------|-------
TCP|Inbound|6443*|Kubernetes API server|All
TCP|Inbound|2379-2380|etcd server client API|kube-apiserver, etcd
TCP|Inbound|10250|Kubelet API|Self, Control plane
TCP|Inbound|10251|kube-scheduler|Self
TCP|Inbound|10252|kube-controller-manager|Self

* Toda porta marcada por * é customizável, você precisa se certificar que a porta alterada também esteja aberta.

**WORKERS**

Protocol|Direction|Port Range|Purpose|Used By
--------|---------|----------|-------|-------
TCP|Inbound|10250|Kubelet API|Self, Control plane
TCP|Inbound|30000-32767|NodePort|Services All

Caso você opte pelo [Weave](https://weave.works) como *pod network*, devem ser liberadas também as portas 6783 (TCP) e 6783/6784 (UDP).

### Tá, mas qual tipo de aplicação eu devo rodar sobre o k8s?

O melhor *app* para executar em contêiner, principalmente no k8s, são aplicações que seguem o [The Twelve-Factor App](https://12factor.net/pt_br/).

### Conceitos-chave do k8s

É importante saber que a forma como o k8s gerencia os contêineres é ligeiramente diferente de outros orquestradores, como o Docker Swarm, sobretudo devido ao fato de que ele não trata os contêineres diretamente, mas sim através de *pods*. Vamos conhecer alguns dos principais conceitos que envolvem o k8s a seguir:

- **Pod**: É o menor objeto do k8s. Como dito anteriormente, o k8s não trabalha com os contêineres diretamente, mas organiza-os dentro de *pods*, que são abstrações que dividem os mesmos recursos, como endereços, volumes, ciclos de CPU e memória. Um pod pode possuir vários contêineres;

- **Deployment**: É um dos principais *controllers* utilizados. O *Deployment*, em conjunto com o *ReplicaSet*, garante que determinado número de réplicas de um pod esteja em execução nos nós workers do cluster. Além disso, o Deployment também é responsável por gerenciar o ciclo de vida das aplicações, onde características associadas a aplicação, tais como imagem, porta, volumes e variáveis de ambiente, podem ser especificados em arquivos do tipo *yaml* ou *json* para posteriormente serem passados como parâmetro para o ``kubectl`` executar o deployment. Esta ação pode ser executada tanto para criação quanto para atualização e remoção do deployment;

- **ReplicaSets**: É um objeto responsável por garantir a quantidade de pods em execução no nó;

- **Services**: É uma forma de você expor a comunicação através de um *ClusterIP*, *NodePort* ou *LoadBalancer* para distribuir as requisições entre os diversos Pods daquele Deployment. Funciona como um balanceador de carga.

- **Controller**: É o objeto responsável por interagir com o *API Server* e orquestrar algum outro objeto. Um exemplo de objeto desta classe é o *Deployments*;

- **Jobs e CronJobs**: são objetos responsáveis pelo gerenciamento de jobs isolados ou recorrentes.


## Importante!

### Aviso sobre os comandos

> **Atenção!!!** Antes de cada comando é apresentado o tipo prompt. Exemplos:

```
$ comando1
```

```
# comando2
```

> O prompt que inicia com o caractere "$", indica que o comando deve ser executado com um usuário comum do sistema operacional.
>
> O prompt que inicia com o caractere "#", indica que o comando deve ser executado com o usuário **root**.
>
> Você não deve copiar/colar o prompt, apenas o comando. :-)




## Instalando e customizando o Kubectl

### Instalação do Kubectl no GNU/Linux

Vamos instalar o ``kubectl`` com os seguintes comandos.

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
```

### Instalação do Kubectl no MacOS

O ``kubectl`` pode ser instalado no MacOS utilizando tanto o [Homebrew](https://brew.sh), quanto o método tradicional. Com o Homebrew já instalado, o kubectl pode ser instalado da seguinte forma.

```
sudo brew install kubectl

kubectl version --client
```

Ou:

```
sudo brew install kubectl-cli

kubectl version --client
```

Já com o método tradicional, a instalação pode ser realizada com os seguintes comandos.

```
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
```

### Instalação do Kubectl no Windows

A instalação do ``kubectl`` pode ser realizada efetuando o download [neste link](https://dl.k8s.io/release/v1.24.3/bin/windows/amd64/kubectl.exe). 

Outras informações sobre como instalar o kubectl no Windows podem ser encontradas [nesta página](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/).


### Customizando o kubectl

#### Auto-complete

Execute o seguinte comando para configurar o alias e autocomplete para o ``kubectl``.

No Bash:

```bash
source <(kubectl completion bash) # configura o autocomplete na sua sessão atual (antes, certifique-se de ter instalado o pacote bash-completion).

echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanentemente ao seu shell.
```

No ZSH:

```bash 
source <(kubectl completion zsh)

echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)"
```

#### Criando um alias para o kubectl

Crie o alias ``k`` para ``kubectl``:

```
alias k=kubectl

complete -F __start_kubectl k
```

## Criando um cluster Kubernetes

### Criando o cluster em sua máquina local

Vamos mostrar algumas opções, caso você queira começar a brincar com o Kubernetes utilizando somente a sua máquina local, o seu desktop.

Lembre-se, você não é obrigado a testar/utilizar todas as opções abaixo, mas seria muito bom caso você testasse. :D

#### Minikube

##### Requisitos básicos

É importante frisar que o Minikube deve ser instalado localmente, e não em um *cloud provider*. Por isso, as especificações de *hardware* a seguir são referentes à máquina local.

* Processamento: 1 core;
* Memória: 2 GB;
* HD: 20 GB.

##### Instalação do Minikube no GNU/Linux

Antes de mais nada, verifique se a sua máquina suporta virtualização. No GNU/Linux, isto pode ser realizado com o seguinte comando:

```
grep -E --color 'vmx|svm' /proc/cpuinfo
```

Caso a saída do comando não seja vazia, o resultado é positivo.

Há a possibilidade de não utilizar um *hypervisor* para a instalação do Minikube, executando-o ao invés disso sobre o próprio host. Iremos utilizar o Oracle VirtualBox como *hypervisor*, que pode ser encontrado [aqui](https://www.virtualbox.org).

Efetue o download e a instalação do ``Minikube`` utilizando os seguintes comandos.

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

chmod +x ./minikube

sudo mv ./minikube /usr/local/bin/minikube

minikube version
```

##### Instalação do Minikube no MacOS

No MacOS, o comando para verificar se o processador suporta virtualização é:

```
sysctl -a | grep -E --color 'machdep.cpu.features|VMX'
```

Se você visualizar `VMX` na saída, o resultado é positivo.

Efetue a instalação do Minikube com um dos dois métodos a seguir, podendo optar-se pelo Homebrew ou pelo método tradicional.

```
sudo brew install minikube

minikube version
```

Ou:

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

chmod +x ./minikube

sudo mv ./minikube /usr/local/bin/minikube

minikube version
```

##### Instalação do Minikube no Microsoft Windows

No Microsoft Windows, você deve executar o comando `systeminfo` no prompt de comando ou no terminal. Caso o retorno deste comando seja semelhante com o descrito a seguir, então a virtualização é suportada.

```
Hyper-V Requirements:     VM Monitor Mode Extensions: Yes
                          Virtualization Enabled In Firmware: Yes
                          Second Level Address Translation: Yes
                          Data Execution Prevention Available: Yes
```

Caso a linha a seguir também esteja presente, não é necessária a instalação de um *hypervisor* como o Oracle VirtualBox:

```
Hyper-V Requirements:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.
```

Faça o download e a instalação de um *hypervisor* (preferencialmente o [Oracle VirtualBox](https://www.virtualbox.org)), caso no passo anterior não tenha sido acusada a presença de um. Finalmente, efetue o download do instalador do Minikube [aqui](https://github.com/kubernetes/minikube/releases/latest) e execute-o.


##### Iniciando, parando e excluindo o Minikube

Quando operando em conjunto com um *hypervisor*, o Minikube cria uma máquina virtual, onde dentro dela estarão todos os componentes do k8s para execução.

É possível selecionar qual *hypervisor* iremos utilizar por padrão, através no comando abaixo:

```
minikube config set driver <SEU_HYPERVISOR> 
```

Você deve substituir <SEU_HYPERVISOR> pelo seu hypervisor, por exemplo o KVM2, QEMU, Virtualbox ou o Hyperkit.


Caso não queria configurar um hypervisor padrão, você pode digitar o comando ``minikube start --driver=hyperkit`` toda vez que criar um novo ambiente. 


##### Certo, e como eu sei que está tudo funcionando como deveria?

Uma vez iniciado, você deve ter uma saída na tela similar à seguinte:

```
minikube start

😄  minikube v1.26.0 on Debian bookworm/sid
✨  Using the qemu2 (experimental) driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🔥  Creating qemu2 VM (CPUs=2, Memory=6000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.24.1 on Docker 20.10.16 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

```

Você pode então listar os nós que fazem parte do seu *cluster* k8s com o seguinte comando:

```
kubectl get nodes
```

A saída será similar ao conteúdo a seguir:

```
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   26s   v1.24.1
```

Para criar um cluster com mais de um nó, você pode utilizar o comando abaixo, apenas modificando os valores para o desejado:

```
minikube start --nodes 2 -p multinode-cluster

😄  minikube v1.26.0 on Debian bookworm/sid
✨  Automatically selected the docker driver. Other choices: kvm2, virtualbox, ssh, none, qemu2 (experimental)
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.24.1 preload ...
    > preloaded-images-k8s-v18-v1...: 405.83 MiB / 405.83 MiB  100.00% 66.78 Mi
    > gcr.io/k8s-minikube/kicbase: 385.99 MiB / 386.00 MiB  100.00% 23.63 MiB p
    > gcr.io/k8s-minikube/kicbase: 0 B [_________________________] ?% ? p/s 11s
🔥  Creating docker container (CPUs=2, Memory=8000MB) ...
🐳  Preparing Kubernetes v1.24.1 on Docker 20.10.17 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass

👍  Starting worker node minikube-m02 in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=8000MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.11.11
🐳  Preparing Kubernetes v1.24.1 on Docker 20.10.17 ...
    ▪ env NO_PROXY=192.168.11.11
🔎  Verifying Kubernetes components...
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

```

Para visualizar os nós do seu novo cluster Kubernetes, digite:

```
kubectl get nodes

NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   66s   v1.24.1
minikube-m02   Ready    <none>          48s   v1.24.1
```

Inicialmente, a intenção do Minikube é executar o k8s em apenas um nó, porém a partir da versão 1.10.1 e possível usar a função de multi-node.

Caso os comandos anteriores tenham sido executados sem erro, a instalação do Minikube terá sido realizada com sucesso.

##### Ver detalhes sobre o cluster 

```
minikube status
```

##### Descobrindo o endereço do Minikube

Como dito anteriormente, o Minikube irá criar uma máquina virtual, assim como o ambiente para a execução do k8s localmente. Ele também irá configurar o ``kubectl`` para comunicar-se com o Minikube. Para saber qual é o endereço IP dessa máquina virtual, pode-se executar:

```
minikube ip
```

O endereço apresentado é que deve ser utilizado para comunicação com o k8s.

##### Acessando a máquina do Minikube via SSH

Para acessar a máquina virtual criada pelo Minikube, pode-se executar:

```
minikube ssh
```

##### Dashboard

O Minikube vem com um *dashboard* *web* interessante para que o usuário iniciante observe como funcionam os *workloads* sobre o k8s. Para habilitá-lo, o usuário pode digitar:

```
minikube dashboard
```

##### Logs

Os *logs* do Minikube podem ser acessados através do seguinte comando.

```
minikube logs
```

##### Remover o cluster

```
minikube delete
```

Caso queira remover o cluster e todos os arquivos referente a ele, utilize o parametro *--purge*, conforme abaixo:

```
minikube delete --purge
```

#### Kind

O Kind (*Kubernetes in Docker*) é outra alternativa para executar o Kubernetes num ambiente local para testes e aprendizado, mas não é recomendado para uso em produção.

##### Instalação no GNU/Linux

Para fazer a instalação no GNU/Linux, execute os seguintes comandos.

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-linux-amd64

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind
```

##### Instalação no MacOS

Para fazer a instalação no MacOS, execute o seguinte comando.

```
sudo brew install kind
```

ou

```
Para Intel Macs
[ $(uname -m) = x86_64 ]&& curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-darwin-amd64
Para M1 / ARM Macs
[ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-darwin-arm64

chmod +x ./kind
mv ./kind /usr/bin/kind
```

##### Instalação no Windows

Para fazer a instalação no Windows, execute os seguintes comandos.

```
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.14.0/kind-windows-amd64

Move-Item .\kind-windows-amd64.exe c:\kind.exe
```

###### Instalação no Windows via [Chocolatey](https://chocolatey.org/install)

Execute o seguinte comando para instalar o Kind no Windows usando o Chocolatey.

```
choco install kind
```

##### Criando um cluster com o Kind

Após realizar a instalação do Kind, vamos iniciar o nosso cluster.

```
kind create cluster

Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.25.2) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/

```

É possível criar mais de um cluster e personalizar o seu nome.

```
kind create cluster --name giropops

Creating cluster "giropops" ...
 ✓ Ensuring node image (kindest/node:v1.25.2) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-giropops"
You can now use your cluster with:

kubectl cluster-info --context kind-giropops

Thanks for using kind! 😊
```

Para visualizar os seus clusters utilizando o kind, execute o comando a seguir.

```
kind get clusters

kind
giropops
```

Liste os nodes do cluster.

```
kubectl get nodes

NAME                     STATUS   ROLES           AGE   VERSION
giropops-control-plane   Ready    control-plane   74s   v1.25.2

```

##### Criando um cluster com múltiplos nós locais com o Kind

É possível para essa aula incluir múltiplos nós na estrutura do Kind, que foi mencionado anteriormente.

Execute o comando a seguir para selecionar e remover todos os clusters locais criados no Kind.

```
kind delete clusters $(kind get clusters)

Deleted clusters: ["giropops" "kind"]
```

Crie um arquivo de configuração para definir quantos e o tipo de nós no cluster que você deseja. No exemplo a seguir, será criado o arquivo de configuração ``kind-3nodes.yaml`` para especificar um cluster com 1 nó control-plane (que executará o control plane) e 2 workers.

```
cat << EOF > $HOME/kind-3nodes.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF
```

Agora vamos criar um cluster chamado ``kind-multinodes`` utilizando as especificações definidas no arquivo ``kind-3nodes.yaml``.

```
kind create cluster --name kind-multinodes --config $HOME/kind-3nodes.yaml

Creating cluster "kind-multinodes" ...
 ✓ Ensuring node image (kindest/node:v1.25.2) 🖼
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind-multinodes"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-multinodes

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

Valide a criação do cluster com o comando a seguir.

```
kubectl get nodes

NAME                            STATUS   ROLES           AGE   VERSION
kind-multinodes-control-plane   Ready    control-plane   52s   v1.25.2
kind-multinodes-worker          Ready    <none>          32s   v1.25.2
kind-multinodes-worker2         Ready    <none>          32s   v1.25.2
```

Mais informações sobre o Kind estão disponíveis em: https://kind.sigs.k8s.io


### Instalação do cluster Kubernetes em três nós

#### Requisitos básicos

Como já dito anteriormente, o Minikube é ótimo para desenvolvedores, estudos e testes, mas não tem como propósito a execução em ambiente de produção. Dito isso, a instalação de um *cluster* k8s para o treinamento irá requerer pelo menos três máquinas, físicas ou virtuais, cada qual com no mínimo a seguinte configuração:

- Distribuição: Debian, Ubuntu, CentOS, Red Hat, Fedora, SuSE;

- Processamento: 2 *cores*;

- Memória: 2GB.

#### Configuração de módulos e parametrização de kernel

O k8s requer que certos módulos do kernel GNU/Linux estejam carregados para seu pleno funcionamento, e que esses módulos sejam carregados no momento da inicialização do computador. Para tanto, crie o arquivo ``/etc/modules-load.d/k8s.conf`` com o seguinte conteúdo em todos os seus nós.

```bash
vim /etc/modules-load.d/k8s.conf 
```

```
br_netfilter
ip_vs
ip_vs_rr
ip_vs_sh
ip_vs_wrr
nf_conntrack_ipv4
overlay
```

Vamos habilitar o repasse de pacotes e fazer com que o *iptables* gerencie os pacotes que estão trafegando pelas *brigdes*. Para isso vamos utilizar *systcl* para parametrizar o kernel.

```bash
vim /etc/sysctl.d/k8s.conf 
```

```
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
```

Para ler as novas configurações:

```bash
sysctl --system
```

#### Atualização da distribuição

Em distribuições Debian e baseadas, como o Ubuntu, execute os comandos a seguir, em cada um de seus nós, para executar atualização do sistema.

```
sudo apt update

sudo apt upgrade -y
```

Em distribuições Red Hat e baseadas, use o seguinte comando.

```
sudo yum upgrade -y
```

#### O Container Runtime

Para que seja possível executar os containers nos nós é necessário ter um *container runtime* instalado em cada um dos nós.

O *container runtime* ou o *container engine* é o responsável por executar os containers nos nós. Quando você está utilizando containers em sua máquina, por exemplo, você está fazendo uso de algum *container runtime*.

O *container runtime* é o responsável por gerenciar as imagens e volumes, é ele o responsável por garantir que os os recursos que os containers estão utilizando está devidamente isolados, a vida do container e muito mais.

Hoje temos diversas opções para se utilizar como *container runtime*, que até pouco tempo atrás tinhamos somente o Docker para esse papel.

Hoje o Docker não é mais suportado pelo Kubernetes, pois o Docker é muito mais do que apenas um *container runtime*. 

O Docker Swarm, por exemplo, vem por padrão quando você instala o Docker, ou seja, não faz sentido ter o Docker inteiro sendo que o Kubernetes somente utiliza um pedaço pequeno do Docker.

O Kubernetes suporta diversos *container runtime*, desde que alinhados com o *Open Container Interface*, o OCI.

*Container runtimes* suportados pelo Kubernetes:

- containerd
- CRI-O
- Docker Engine
- Mirantis Container Runtime


##### Instalando e configurando o containerd

Para instalar o *containerd* nos nós, utilize o instalador de pacotes padrão de sua distribuição. Para esse exemplo estou utilizando um Ubuntu Server, então irei utilizar o *apt*.

Para que isso seja possível vamos adicionar o repositório do Docker. Mas nós não iremos instalar o Docker, iremos somente realizar a instalação do Containerd.


```bash
# Adicionando a chave do repositório
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update

# Instalando o containerd
sudo apt install -y containerd.io
```

Agora vamos criar diretório que irá conter as configurações do *containerd*.

```bash
mkdir -p /etc/containerd
```

Agora já podemos criar a configuração básica para o nosso *containerd*, lembrando que é super importante ler a documentação do *containerd* para que você possa conhecer todas as opções para o seu ambiente.

```bash
containerd config default > /etc/containerd/config.toml
```

Agora vamos reiniciar o serviço para que as novas configurações entrem em vigor.

```bash
# Habilitando o serviço
systemctl enable containerd

# Reiniciando o serviço
systemctl restart containerd
```

##### Instalando o kubeadm

O próximo passo é efetuar a adição dos repositórios do k8s e efetuar a instalação do ``kubeadm``.

Em distribuições Debian e baseadas, isso pode ser realizado com os comandos a seguir.

```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
```

É necessário desativar a memória swap em todos os nós com o comando a seguir.

```bash
sudo swapoff -a
```

Além de comentar a linha referente à mesma no arquivo ```/etc/fstab```.

```bash
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

Após esses procedimentos, é interessante a reinicialização de todos os nós do *cluster*.


##### Inicialização do cluster

Antes de inicializarmos o *cluster*, vamos efetuar o *download* das imagens que serão utilizadas, executando o comando a seguir no nó que será o *control-plane*.
Vamos passar o parametro *--cri-socket* para especificar o caminho do arquivo de socket do nosso *container runtime*, nesse caso o *containerd*

```
sudo kubeadm config images pull --cri-socket /run/containerd/containerd.sock
```

Execute o comando a seguir também apenas no nó *control-plane* para a inicialização do cluster. 

Estamos passando alguns importantes parametros:

- _--control-plane-endpoint_ -> Ip do seu node que será utilizado no cluster. Importante caso você tenha mais de uma interface ou endereço.

- _--cri-socket_ -> O arquivo de socket do nosso container runtime.

- _--upload-certs_ -> Faz o upload do certificado do *control plane* para o kubeadm-certs  secret.


```
sudo kubeadm init --upload-certs --control-plane-endpoint=ADICIONE_O_IP_DO_NODE_AQUI  --cri-socket /run/containerd/containerd.sock
```

Opcionalmente, você também pode passar o cidr com a opção _--pod-network-cidr_. O comando obedecerá a seguinte sintaxe:

```
sudo kubeadm init --upload-certs --control-plane-endpoint=ADICIONE_O_IP_DO_NODE_AQUI  --cri-socket /run/containerd/containerd.sock --pod-network-cidr 192.168.99.0/24
```

A saída do comando será algo similar ao mostrado a seguir.

```
[init] Using Kubernetes version: v1.24.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [172.31.19.147 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.31.19.147]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [172.31.19.147 localhost] and IPs [172.31.19.147 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [172.31.19.147 localhost] and IPs [172.31.19.147 127.0.0.1 ::1]
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
[apiclient] All control plane components are healthy after 8.505808 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
55befb249a01aca7be98b3e7209628f4c4f04c6a05c250c4bb084af722452c36
[mark-control-plane] Marking the node 172.31.19.147 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node 172.31.19.147 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: q1m5ci.5p2mtgby0s4ek4vr
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

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 172.31.19.147:6443 --token q1m5ci.5p2mtgby0s4ek4vr \
	--discovery-token-ca-cert-hash sha256:45f6437514981d97631bd5d48822c670ec4a548c9768043fca6e5eda0133b934 \
	--control-plane --certificate-key 55befb249a01aca7be98b3e7209628f4c4f04c6a05c250c4bb084af722452c36

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.19.147:6443 --token q1m5ci.5p2mtgby0s4ek4vr \
	--discovery-token-ca-cert-hash sha256:45f6437514981d97631bd5d48822c670ec4a548c9768043fca6e5eda0133b934 
```

Caso o servidor possua mais de uma interface de rede, você pode verificar se o IP interno do nó do seu cluster corresponde ao IP da interface esperada com o seguinte comando:

```
kubectl describe node elliot-1 | grep InternalIP
```

A saída será algo similar a seguir:

```
InternalIP:  172.31.19.147
```

Caso o IP não corresponda ao da interface de rede escolhida, você pode ir até o arquivo localizado em _/etc/systemd/system/kubelet.service.d/10-kubeadm.conf_ com o editor da sua preferência, procure por _KUBELET_CONFIG_ARGS_ e adicione no final a instrução --node-ip=<IP Da sua preferência>. O trecho alterado será semelhante a esse:

```
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --node-ip=192.168.99.2"
```

Salve o arquivo e execute os comandos abaixo para reiniciar a configuração e consequentemente o kubelet.

```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

#### Configuração do arquivo de contextos do kubectl

Como dito anteriormente e de forma similar ao Docker Swarm, o próprio kubeadm já mostrará os comandos necessários para a configuração do ``kubectl``, para que assim possa ser estabelecida comunicação com o cluster k8s. Para tanto, execute os seguintes comandos.

```
mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### Inserindo os nós workers no cluster

Para inserir os nós *workers* ou mais *control plane* no *cluster*, basta executar a linha que começa com ``kubeadm join`` que vimos na saída do comando de inicialização do cluster.

```
You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 172.31.19.147:6443 --token q1m5ci.5p2mtgby0s4ek4vr \
	--discovery-token-ca-cert-hash sha256:45f6437514981d97631bd5d48822c670ec4a548c9768043fca6e5eda0133b934 \
	--control-plane --certificate-key 55befb249a01aca7be98b3e7209628f4c4f04c6a05c250c4bb084af722452c36

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.19.147:6443 --token q1m5ci.5p2mtgby0s4ek4vr \
	--discovery-token-ca-cert-hash sha256:45f6437514981d97631bd5d48822c670ec4a548c9768043fca6e5eda0133b934 
```

Conforme notamos na saída acima temos dois comandos, um para que possamos adicionar mais nós como *control plane* ou então para adicionar nós como *worker*.

Apenas copie e cole o comando nos nós que você deseja adicionar ao cluster. Nessa linha de comando do *kubeadm join* já estamos passando o IP e porta do nosso primeiro nó *control plane* e as informações sobre o certificado, informações necessárias para que seja possível a entrada do nó no cluster.


Lembre-se, o comando abaixo deve ser executado nos nós que irão compor o cluster, no exemplo vamos adicionar mais dois nós como *workers*

```bash
kubeadm join 172.31.19.147:6443 --token q1m5ci.5p2mtgby0s4ek4vr --discovery-token-ca-cert-hash sha256:45f6437514981d97631bd5d48822c670ec4a548c9768043fca6e5eda0133b934 

[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

Agora no nó *control plane* verifique os nós que já fazem parte do cluster através do comando *kubectl*

```bash
kubectl get nodes
NAME               STATUS     ROLES           AGE   VERSION
ip-172-31-19-147   NotReady   control-plane   68s   v1.24.3
ip-172-31-24-77    NotReady   <none>          29s   v1.24.3
ip-172-31-25-32    NotReady   <none>          31s   v1.24.3
```

Perceba que os nós ainda não estão *Ready*, pois ainda não instalamos o *pod network* para resolver a comunicação entre pods em diferentes nós.

#### A rede do Kubernetes

Entender como funciona a rede no Kubernetes é super importante para que você consiga entender não somente o comportamento do próprio Kubernetes, como também para o entendimento de como as suas aplicações se comportam e interagem.
Primeira coisa que devemos entender é que o Kubernetes não resolve como funciona a comunicação de pods em nós diferentes, para que isso seja resolvido é necessário utilizar o que chamamos de *pod networking*.

Ou seja, o k8s por padrão não fornece uma solução de *networking* *out-of-the-box*. 

Para resolver esse problema foi criado o *Container Network Interface*, o **CNI**.
O *CNI* nada mais é do que uma especificação e um conjunto de bibliotecas para a criação de soluções de *pod networking*, ou seja, plugins para resolver o problema de comunicação entre os pods.

Temos diversas solução de *pod networking* como *add-on*, cada qual com funcionalidades diferentes, tais como: [Flannel](https://github.com/coreos/flannel), [Calico](http://docs.projectcalico.org/), [Romana](http://romana.io), [Weave-net](https://www.weave.works/products/weave-net/), entre outros.

É importante saber as caracteristicas de cada solução e como elas resolvem a comunicação entre os pods.

Por exemplo, temos soluções que utilizam *eBPF* como é o caso do *Cilium*, ou ainda soluções que atuam na camada 3 ou na camada 7 do modelo de referencia OSI. 

Dito isso, a melhor coisa é você ler os detalhes de cada solução e entender qual a melhor antende suas necessidades.

Eu gosto muito da **Weave-net** e será ela que iremos abordar durante o treinamento, na dúvida de qual usar, vá de **Weave-net**! :)


Para instalar o *Weave-net* execute o seguinte comando no nó *control plane*.

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

Para verificar se o *pod network* foi criado com sucesso, execute o seguinte comando.

```
kubectl get pods -n kube-system
```

O resultado deve ser semelhante ao mostrado a seguir.

```
NAMESPACE     NAME                                       READY   STATUS    RESTARTS      AGE
kube-system   coredns-6d4b75cb6d-vjtw5                   1/1     Running   0             2m4s
kube-system   coredns-6d4b75cb6d-xd89l                   1/1     Running   0             2m4s
kube-system   etcd-ip-172-31-19-147                      1/1     Running   0             2m19s
kube-system   kube-apiserver-ip-172-31-19-147            1/1     Running   0             2m18s
kube-system   kube-controller-manager-ip-172-31-19-147   1/1     Running   0             2m18s
kube-system   kube-proxy-djvp4                           1/1     Running   0             103s
kube-system   kube-proxy-f2f57                           1/1     Running   0             2m5s
kube-system   kube-proxy-tshff                           1/1     Running   0             105s
kube-system   kube-scheduler-ip-172-31-19-147            1/1     Running   0             2m18s
kube-system   weave-net-4qfbb                            2/2     Running   1 (22s ago)   28s
kube-system   weave-net-htlrp                            2/2     Running   1 (22s ago)   28s
kube-system   weave-net-nltmv                            2/2     Running   1 (21s ago)   28s

```

Pode-se observar que há três contêineres do Weave-net em execução, um em cada nó do cluster,  provendo a *pod networking* para o nosso *cluster*.

#### Verificando a instalação

Para verificar se a instalação está funcionando, e se os nós estão se comunicando, você pode executar o comando ``kubectl get nodes`` no nó control-plane, que deve lhe retornar algo como o conteúdo a seguir.


```bash
kubectl get nodes

NAME               STATUS   ROLES           AGE     VERSION
ip-172-31-19-147   Ready    control-plane   2m20s   v1.24.3
ip-172-31-24-77    Ready    <none>          101s    v1.24.3
ip-172-31-25-32    Ready    <none>          103s    v1.24.3

```

### Primeiros passos no k8s

#### Exibindo informações detalhadas sobre os nós

```
kubectl describe node [nome_do_no]
```

Exemplo:

```
kubectl describe node ip-172-31-19-147

Name:               ip-172-31-19-147
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-172-31-19-147
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Sun, 07 Aug 2022 07:05:52 +0000
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
                    node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  ip-172-31-19-147
  AcquireTime:     <unset>
  RenewTime:       Sun, 07 Aug 2022 08:10:33 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Sun, 07 Aug 2022 07:07:56 +0000   Sun, 07 Aug 2022 07:07:56 +0000   WeaveIsUp                    Weave pod has set this
  MemoryPressure       False   Sun, 07 Aug 2022 08:09:15 +0000   Sun, 07 Aug 2022 07:05:49 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Sun, 07 Aug 2022 08:09:15 +0000   Sun, 07 Aug 2022 07:05:49 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Sun, 07 Aug 2022 08:09:15 +0000   Sun, 07 Aug 2022 07:05:49 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Sun, 07 Aug 2022 08:09:15 +0000   Sun, 07 Aug 2022 07:07:58 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  172.31.19.147
  Hostname:    ip-172-31-19-147
Capacity:
  cpu:                2
  ephemeral-storage:  7950756Ki
  hugepages-2Mi:      0
  memory:             4016852Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  7327416718
  hugepages-2Mi:      0
  memory:             3914452Ki
  pods:               110
System Info:
  Machine ID:                 23fb437f79c4489ab1e351f42b69a52c
  System UUID:                ec2e1b61-092b-df48-4c41-f51d2f5e84d7
  Boot ID:                    1e1ce6a2-3cf0-4961-be37-1f15ba5cd232
  Kernel Version:             5.13.0-1029-aws
  OS Image:                   Ubuntu 20.04.4 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.6
  Kubelet Version:            v1.24.3
  Kube-Proxy Version:         v1.24.3
PodCIDR:                      10.244.0.0/24
PodCIDRs:                     10.244.0.0/24
Non-terminated Pods:          (8 in total)
....
```

##### Exibindo novamente token para adicionar um novo nó no cluster

Para visualizar novamente o *token* para inserção de novos nós, execute o seguinte comando.

```
sudo kubeadm token create --print-join-command
```

##### Ativando o autocomplete

Em distribuições Debian e baseadas, certifique-se que o pacote ``bash-completion`` esteja instalado. Instale-o com o comando a seguir.

```
sudo apt install -y bash-completion
```

Em sistemas Red Hat e baseados, execute:

```
sudo yum install -y bash-completion
```

Feito isso, execute o seguinte comando.

```
kubectl completion bash > /etc/bash_completion.d/kubectl
```

Efetue *logoff* e *login* para carregar o *autocomplete*. Caso não deseje, execute:

```
source <(kubectl completion bash)
```

##### Verificando os namespaces e pods

O k8s organiza tudo dentro de *namespaces*. Por meio deles, podem ser realizadas limitações de segurança e de recursos dentro do *cluster*, tais como *pods*, *replication controllers* e diversos outros. Para visualizar os *namespaces* disponíveis no *cluster*, digite:

```
kubectl get namespaces

NAME              STATUS   AGE
default           Active   8d
kube-node-lease   Active   8d
kube-public       Active   8d
kube-system       Active   8d
```

Vamos listar os *pods* do *namespace* **kube-system** utilizando o comando a seguir.

```
kubectl get pod -n kube-system

NAME                                       READY   STATUS    RESTARTS       AGE
coredns-6d4b75cb6d-vjtw5                   1/1     Running   0              106m
coredns-6d4b75cb6d-xd89l                   1/1     Running   0              106m
etcd-ip-172-31-19-147                      1/1     Running   0              106m
kube-apiserver-ip-172-31-19-147            1/1     Running   0              106m
kube-controller-manager-ip-172-31-19-147   1/1     Running   0              106m
kube-proxy-djvp4                           1/1     Running   0              106m
kube-proxy-f2f57                           1/1     Running   0              106m
kube-proxy-tshff                           1/1     Running   0              106m
kube-scheduler-ip-172-31-19-147            1/1     Running   0              106m
weave-net-4qfbb                            2/2     Running   1 (104m ago)   105m
weave-net-htlrp                            2/2     Running   1 (104m ago)   105m
weave-net-nltmv                            2/2     Running   1 (104m ago)   105m
```

Será que há algum *pod* escondido em algum *namespace*? É possível listar todos os *pods* de todos os *namespaces* com o comando a seguir.

```
kubectl get pods --all-namespaces
```

Há a possibilidade ainda, de utilizar o comando com a opção ```-o wide```, que disponibiliza maiores informações sobre o recurso, inclusive em qual nó o *pod* está sendo executado. Exemplo:

```
kubectl get pods --all-namespaces -o wide

NAMESPACE     NAME                                       READY   STATUS    RESTARTS       AGE    IP              NODE               NOMINATED NODE   READINESS GATES
kube-system   coredns-6d4b75cb6d-vjtw5                   1/1     Running   0              105m   10.32.0.3       ip-172-31-19-147   <none>           <none>
kube-system   coredns-6d4b75cb6d-xd89l                   1/1     Running   0              105m   10.32.0.2       ip-172-31-19-147   <none>           <none>
kube-system   etcd-ip-172-31-19-147                      1/1     Running   0              105m   172.31.19.147   ip-172-31-19-147   <none>           <none>
kube-system   kube-apiserver-ip-172-31-19-147            1/1     Running   0              105m   172.31.19.147   ip-172-31-19-147   <none>           <none>
kube-system   kube-controller-manager-ip-172-31-19-147   1/1     Running   0              105m   172.31.19.147   ip-172-31-19-147   <none>           <none>
kube-system   kube-proxy-djvp4                           1/1     Running   0              105m   172.31.24.77    ip-172-31-24-77    <none>           <none>
kube-system   kube-proxy-f2f57                           1/1     Running   0              105m   172.31.19.147   ip-172-31-19-147   <none>           <none>
kube-system   kube-proxy-tshff                           1/1     Running   0              105m   172.31.25.32    ip-172-31-25-32    <none>           <none>
kube-system   kube-scheduler-ip-172-31-19-147            1/1     Running   0              105m   172.31.19.147   ip-172-31-19-147   <none>           <none>
kube-system   weave-net-4qfbb                            2/2     Running   1 (103m ago)   103m   172.31.19.147   ip-172-31-19-147   <none>           <none>
kube-system   weave-net-htlrp                            2/2     Running   1 (103m ago)   103m   172.31.25.32    ip-172-31-25-32    <none>           <none>
kube-system   weave-net-nltmv                            2/2     Running   1 (103m ago)   103m   172.31.24.77    ip-172-31-24-77    <none>           <none>
```

##### Executando nosso primeiro pod no k8s

Iremos iniciar o nosso primeiro *pod* no k8s. Para isso, executaremos o comando a seguir.

```
kubectl run nginx --image nginx

pod/nginx created
```

Listando os *pods* com ``kubectl get pods``, obteremos a seguinte saída.

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          66s
```

Vamos olhar agora a descrição desse objeto dentro do *cluster*.

```
kubectl describe pod nginx

Name:         nginx
Namespace:    default
Priority:     0
Node:         ip-172-31-25-32/172.31.25.32
Start Time:   Sun, 07 Aug 2022 08:53:24 +0000
Labels:       run=nginx
Annotations:  <none>
Status:       Running
IP:           10.40.0.1
IPs:
  IP:  10.40.0.1
Containers:
  nginx:
    Container ID:   containerd://d7ae9933e65477eed7ff04a107fb3a3adb6a634bc713282421bbdf0e1c30bf7b
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:ecc068890de55a75f1a32cc8063e79f90f0b043d70c5fcf28f1713395a4b3d49
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 07 Aug 2022 08:53:30 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tmjgq (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-tmjgq:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  16s   default-scheduler  Successfully assigned default/nginx to ip-172-31-25-32
  Normal  Pulling    16s   kubelet            Pulling image "nginx"
  Normal  Pulled     10s   kubelet            Successfully pulled image "nginx" in 5.387864178s
  Normal  Created    10s   kubelet            Created container nginx
  Normal  Started    10s   kubelet            Started container nginx

```

##### Verificar os últimos eventos do cluster

Você pode verificar quais são os últimos eventos do *cluster* com o comando ``kubectl get events``. Serão mostrados eventos como: o *download* de imagens do Docker Hub (ou de outro *registry* configurado), a criação/remoção de *pods*, etc.

A saída a seguir mostra o resultado da criação do nosso contêiner com Nginx.

```
kubectl get events

LAST SEEN   TYPE     REASON      OBJECT      MESSAGE
44s         Normal   Scheduled   pod/nginx   Successfully assigned default/nginx to ip-172-31-25-32
44s         Normal   Pulling     pod/nginx   Pulling image "nginx"
38s         Normal   Pulled      pod/nginx   Successfully pulled image "nginx" in 5.387864178s
38s         Normal   Created     pod/nginx   Created container nginx
38s         Normal   Started     pod/nginx   Started container nginx

```

No resultado do comando anterior é possível observar que a execução do nginx ocorreu no *namespace* default e que a imagem **nginx** não existia no repositório local e, sendo assim, teve de ser feito download da imagem.


##### Efetuar o dump de um objeto em formato YAML

Assim como quando se está trabalhando com *stacks* no Docker Swarm, normalmente recursos no k8s são declarados em arquivos **YAML** ou **JSON** e depois manipulados através do ``kubectl``.

Para nos poupar o trabalho de escrever o arquivo inteiro, pode-se utilizar como *template* o *dump* de um objeto já existente no k8s, como mostrado a seguir.

```
kubectl get pod nginx -o yaml > meu-primeiro.yaml
```

Será criado um novo arquivo chamado ``meu-primeiro.yaml``, resultante do redirecionamento da saída do comando ``kubectl get pod nginx -o yaml``.

Abrindo o arquivo com ``vim meu-primeiro.yaml`` (você pode utilizar o editor que você preferir), teremos o seguinte conteúdo.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2022-08-07T08:53:24Z"
  labels:
    run: nginx
  name: nginx
  namespace: default
  resourceVersion: "9598"
  uid: d0928186-bf6d-459b-aca6-9b0d84b40e9c
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
      name: kube-api-access-tmjgq
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: ip-172-31-25-32
  preemptionPolicy: PreemptLowerPriority
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
  - name: kube-api-access-tmjgq
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2022-08-07T08:53:24Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2022-08-07T08:53:30Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2022-08-07T08:53:30Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2022-08-07T08:53:24Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://d7ae9933e65477eed7ff04a107fb3a3adb6a634bc713282421bbdf0e1c30bf7b
    image: docker.io/library/nginx:latest
    imageID: docker.io/library/nginx@sha256:ecc068890de55a75f1a32cc8063e79f90f0b043d70c5fcf28f1713395a4b3d49
    lastState: {}
    name: nginx
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2022-08-07T08:53:30Z"
  hostIP: 172.31.25.32
  phase: Running
  podIP: 10.40.0.1
  podIPs:
  - ip: 10.40.0.1
  qosClass: BestEffort
  startTime: "2022-08-07T08:53:24Z"
```

Observando o arquivo anterior, notamos que este reflete o **estado** do *pod*. Nós desejamos utilizar tal arquivo apenas como um modelo, e sendo assim, podemos apagar as entradas que armazenam dados de estado desse *pod*, como *status* e todas as demais configurações que são específicas dele. O arquivo final ficará com o conteúdo semelhante a este:

```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    labels:
      run: nginx
    name: nginx
  spec:
    containers:
    - image: nginx
      name: nginx
      resources: {}
    dnsPolicy: ClusterFirst
    restartPolicy: Always
  status: {}
```

Vamos agora remover o nosso *pod* com o seguinte comando.

```
kubectl delete pod nginx
```

A saída deve ser algo como:

```
pod "nginx" deleted
```

Vamos recriá-lo, agora a partir do nosso arquivo YAML.

```
kubectl create -f meu-primeiro.yaml

pod/nginx created
```

Observe que não foi necessário informar ao ``kubectl`` qual tipo de recurso seria criado, pois isso já está contido dentro do arquivo.

Listando os *pods* disponíveis com o seguinte comando.

```
kubectl get pods
```

Deve-se obter uma saída similar à esta:

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          109s
```

Uma outra forma de criar um arquivo de *template* é através da opção ``--dry-run`` do ``kubectl``, com o funcionamento ligeiramente diferente dependendo do tipo de recurso que será criado. Exemplos:

Para a criação do template de um *pod*:

```
kubectl run meu-nginx --image nginx --dry-run=client -o yaml > pod-template.yaml
```

Para a criação do *template* de um *deployment*:

```
kubectl create deployment meu-nginx --image=nginx --dry-run=client -o yaml > deployment-template.yaml
```

A vantagem deste método é que não há a necessidade de limpar o arquivo, além de serem apresentadas apenas as opções necessárias do recurso.

#### Socorro, são muitas opções!

Calma, nós sabemos. Mas o ``kubectl`` pode lhe auxiliar um pouco em relação a isso. Ele contém a opção ``explain``, que você pode utilizar caso precise de ajuda com alguma opção em específico dos arquivos de recurso. A seguir alguns exemplos de sintaxe.

```
kubectl explain [recurso]

kubectl explain [recurso.caminho.para.spec]

kubectl explain [recurso.caminho.para.spec] --recursive
```

Exemplos:

```
kubectl explain deployment

kubectl explain pod --recursive

kubectl explain deployment.spec.template.spec
```

#### Expondo o pod e criando um Service

Dispositivos fora do *cluster*, por padrão, não conseguem acessar os *pods* criados, como é comum em outros sistemas de contêineres. Para expor um *pod*, execute o comando a seguir.

```
kubectl expose pod nginx
```

Será apresentada a seguinte mensagem de erro:

```
error: couldn't find port via --port flag or introspection
See 'kubectl expose -h' for help and examples
```

O erro ocorre devido ao fato do k8s não saber qual é a porta de destino do contêiner que deve ser exposta (no caso, a 80/TCP). Para configurá-la, vamos primeiramente remover o nosso *pod* antigo:

```
kubectl delete -f meu-primeiro.yaml
```

Abra agora o arquivo ``meu-primeiro.yaml`` e adicione o bloco a seguir.

```yaml
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

> **Atenção!!!** Arquivos YAML utilizam para sua tabulação dois espaços e não *tab*.

Feita a modificação no arquivo, salve-o e crie novamente o *pod* com o comando a seguir.

```
kubectl create -f meu-primeiro.yaml

pod/nginx created
```

Liste o pod.

```
kubectl get pod nginx

NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          32s
```

O comando a seguir cria um objeto do k8s chamado de *Service*, que é utilizado justamente para expor *pods* para acesso externo.

```
kubectl expose pod nginx
```

Podemos listar todos os *services* com o comando a seguir.

```
kubectl get services

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   8d
nginx        ClusterIP   10.105.41.192   <none>        80/TCP    2m30s
```

Como é possível observar, há dois *services* no nosso *cluster*: o primeiro é para uso do próprio k8s, enquanto o segundo foi o quê acabamos de criar. Utilizando o ``curl`` contra o endereço IP mostrado na coluna *CLUSTER-IP*, deve nos ser apresentada a tela principal do Nginx.

```
curl 10.105.41.192

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Este *pod* está disponível para acesso a partir de qualquer nó do *cluster*.


#### Limpando tudo e indo para casa

Para mostrar todos os recursos recém criados, pode-se utilizar uma das seguintes opções a seguir.

```
kubectl get all

kubectl get pod,service

kubectl get pod,svc
```

Note que o k8s nos disponibiliza algumas abreviações de seus recursos. Com o tempo você irá se familiar com elas. Para apagar os recursos criados, você pode executar os seguintes comandos.

```
kubectl delete -f meu-primeiro.yaml

kubectl delete service nginx
```

Liste novamente os recursos para ver se os mesmos ainda estão presentes.
