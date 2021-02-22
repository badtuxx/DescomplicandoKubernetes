# Descomplicando Kubernetes Day 1

## Sumário

<!-- TOC -->
- [Descomplicando Kubernetes Day 1](#descomplicando-kubernetes-day-1)
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
- [Minikube](#minikube)
  - [Requisitos básicos](#requisitos-básicos)
  - [Instalação do Minikube no GNU/Linux](#instalação-do-minikube-no-gnulinux)
  - [Instalação do Minikube no MacOS](#instalação-do-minikube-no-macos)
  - [kubectl: alias e autocomplete](#kubectl-alias-e-autocomplete)
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
  - [Instalando o Microk8s no Mac](#instalando-o-microk8s-no-mac)
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
- [Instalação em cluster com três nós](#instalação-em-cluster-com-três-nós)
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

<!-- TOC -->

# O quê preciso saber antes de começar?

## Qual distro GNU/Linux devo usar?

Devido ao fato de algumas ferramentas importantes, como o ``systemd`` e ``journald``, terem se tornado padrão na maioria das principais distribuições disponíveis hoje, você não deve encontrar problemas para seguir o treinamento, caso você opte por uma delas, como Ubuntu, Debian, CentOS e afins.

## Alguns sites que devemos visitar

- [https://kubernetes.io](https://kubernetes.io)

- [https://github.com/kubernetes/kubernetes/](https://github.com/kubernetes/kubernetes/)

- [https://github.com/kubernetes/kubernetes/issues](https://github.com/kubernetes/kubernetes/issues)

- [https://www.cncf.io/certification/cka/](https://www.cncf.io/certification/cka/)

- [https://www.cncf.io/certification/ckad/](https://www.cncf.io/certification/ckad/)

- [https://12factor.net/pt_br/](https://12factor.net/pt_br/)

## E o k8s?

**Versão resumida:**

O projeto Kubernetes foi desenvolvido pela Google, em meados de 2014, para atuar como um orquestrador de contêineres para a empresa. O Kubernetes (k8s), cujo termo em Grego significa "timoneiro", é um projeto *opensource* que conta com *design* e desenvolvimento baseados no projeto Borg, que também é da Google [1](https://kubernetes.io/blog/2015/04/borg-predecessor-to-kubernetes/). Alguns outros produtos disponíveis no mercado, tais como o Apache Mesos e o Cloud Foundry, também surgiram a partir do projeto Borg.

Como Kubernetes é uma palavra difícil de se pronunciar - e de se escrever - a comunidade simplesmente o apelidou de **k8s**, seguindo o padrão [i18n](http://www.i18nguy.com/origini18n.html) (a letra "k" seguida por oito letras e o "s" no final), pronunciando-se simplesmente "kates".

**Versão longa:**

Praticamente todo software desenvolvido na Google é executado em contêiner [2](https://www.enterpriseai.news/2014/05/28/google-runs-software-containers/). A Google já gerencia contêineres em larga escala há mais de uma década, quando não se falava tanto sobre isso. Para atender a demanda interna, alguns desenvolvedores do Google construíram três sistemas diferentes de gerenciamento de contêineres: **Borg**, **Omega** e **Kubernetes**. Cada sistema teve o desenvolvimento bastante influenciado pelo antecessor, embora fosse desenvolvido por diferentes razões.

O primeiro sistema de gerenciamento de contêineres desenvolvido no Google foi o Borg, construído para gerenciar serviços de longa duração e jobs em lote, que anteriormente eram tratados por dois sistemas:  **Babysitter** e **Global Work Queue**. O último influenciou fortemente a arquitetura do Borg, mas estava focado em execução de jobs em lote. O Borg continua sendo o principal sistema de gerenciamento de contêineres dentro do Google por causa de sua escala, variedade de recursos e robustez extrema.

O segundo sistema foi o Omega, descendente do Borg. Ele foi impulsionado pelo desejo de melhorar a engenharia de software do ecossistema Borg. Esse sistema aplicou muitos dos padrões que tiveram sucesso no Borg, mas foi construído do zero para ter a arquitetura mais consistente. Muitas das inovações do Omega foram posteriormente incorporadas ao Borg.

O terceiro sistema foi o Kubernetes. Concebido e desenvolvido em um mundo onde desenvolvedores externos estavam se interessando em contêineres e o Google desenvolveu um negócio em amplo crescimento atualmente, que é a venda de infraestrutura de nuvem pública.

O Kubernetes é de código aberto - em contraste com o Borg e o Omega que foram desenvolvidos como sistemas puramente internos do Google.
O Kubernetes foi desenvolvido com um foco mais forte na experiência de desenvolvedores que escrevem aplicativos que são executados em um cluster: seu principal objetivo é facilitar a implantação e o gerenciamento de sistemas distribuídos, enquanto se beneficia do melhor uso de recursos de memória e processamento que os contêineres possibilitam.

Estas informações foram extraídas e adaptadas deste [artigo](https://static.googleusercontent.com/media/research.google.com/pt-BR//pubs/archive/44843.pdf), que descreve as lições aprendidas com o desenvolvimento e operação desses sistemas.

## Arquitetura do k8s

Assim como os demais orquestradores disponíveis, o k8s também segue um modelo *manager/worker*, constituindo assim um *cluster*, onde para seu funcionamento devem existir no mínimo três nós: o nó *master*, responsável (por padrão) pelo gerenciamento do *cluster*, e os demais como *workers*, executores das aplicações que queremos executar sobre esse *cluster*.

Embora exista a exigência de no mínimo três nós para a execução do k8s em um ambiente padrão, existem soluções para se executar o k8s em um único nó. Alguns exemplos são:

* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start): Uma ferramenta para execução de contêineres Docker que simulam o funcionamento de um cluster Kubernetes. É utilizado para fins didáticos, de desenvolvimento e testes. O **Kind não deve ser utilizado para produção**;

* [Minikube](https://github.com/kubernetes/minikube): ferramenta para implementar um *cluster* Kubernetes localmente com apenas um nó. Muito utilizado para fins didáticos, de desenvolvimento e testes. O **Minikube não deve ser utilizado para produção**;

* [MicroK8S](https://microk8s.io): Desenvolvido pela [Canonical](https://canonical.com), mesma empresa que desenvolve o [Ubuntu](https://ubuntu.com). Pode ser utilizado em diversas distribuições e **pode ser utilizada para ambientes de produção**, em especial para *Edge Computing* e IoT (*Internet of things*);

* [k3s](https://k3s.io): Desenvolvido pela [Rancher Labs](https://rancher.com), é um concorrente direto do MicroK8s, podendo ser executado inclusive em Raspberry Pi.

A figura a seguir mostra a arquitetura interna de componentes do k8s.

| ![Arquitetura Kubernetes](../images/kubernetes_architecture.png) |
|:---------------------------------------------------------------------------------------------:|
| *Arquitetura Kubernetes [Ref: phoenixnap.com KB article](https://phoenixnap.com/kb/understanding-kubernetes-architecture-diagrams)*                                                                      |

* **API Server**: É um dos principais componentes do k8s. Este componente fornece uma API que utiliza JSON sobre HTTP para comunicação, onde para isto é utilizado principalmente o utilitário ``kubectl``, por parte dos administradores, para a comunicação com os demais nós, como mostrado no gráfico. Estas comunicações entre componentes são estabelecidas através de requisições [REST](https://restfulapi.net);

* **etcd**: O etcd é um *datastore* chave-valor distribuído que o k8s utiliza para armazenar as especificações, status e configurações do *cluster*. Todos os dados armazenados dentro do etcd são manipulados apenas através da API. Por questões de segurança, o etcd é por padrão executado apenas em nós classificados como *master* no *cluster* k8s, mas também podem ser executados em *clusters* externos, específicos para o etcd, por exemplo;

* **Scheduler**: O *scheduler* é responsável por selecionar o nó que irá hospedar um determinado *pod* (a menor unidade de um *cluster* k8s - não se preocupe sobre isso por enquanto, nós falaremos mais sobre isso mais tarde) para ser executado. Esta seleção é feita baseando-se na quantidade de recursos disponíveis em cada nó, como também no estado de cada um dos nós do *cluster*, garantindo assim que os recursos sejam bem distribuídos. Além disso, a seleção dos nós, na qual um ou mais pods serão executados, também pode levar em consideração políticas definidas pelo usuário, tais como afinidade, localização dos dados a serem lidos pelas aplicações, etc;

* **Controller Manager**: É o *controller manager* quem garante que o *cluster* esteja no último estado definido no etcd. Por exemplo: se no etcd um *deploy* está configurado para possuir dez réplicas de um *pod*, é o *controller manager* quem irá verificar se o estado atual do *cluster* corresponde a este estado e, em caso negativo, procurará conciliar ambos;

* **Kubelet**: O *kubelet* pode ser visto como o agente do k8s que é executado nos nós workers. Em cada nó worker deverá existir um agente Kubelet em execução. O Kubelet é responsável por de fato gerenciar os *pods*, que foram direcionados pelo *controller* do *cluster*, dentro dos nós, de forma que para isto o Kubelet pode iniciar, parar e manter os contêineres e os pods em funcionamento de acordo com o instruído pelo controlador do cluster;

* **Kube-proxy**: Age como um *proxy* e um *load balancer*. Este componente é responsável por efetuar roteamento de requisições para os *pods* corretos, como também por cuidar da parte de rede do nó;

* **Container Runtime**: O *container runtime* é o ambiente de execução de contêineres necessário para o funcionamento do k8s. Em 2016 suporte ao [rkt](https://coreos.com/rkt/) foi adicionado, porém desde o início o Docker já é funcional e utilizado por padrão.

## Portas que devemos nos preocupar

**MASTER**

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

Caso você opte pelo [Weave](https://weave.works) como *pod network*, devem ser liberadas também as portas 6783 e 6784 TCP.

## Tá, mas qual tipo de aplicação eu devo rodar sobre o k8s?

O melhor *app* para executar em contêiner, principalmente no k8s, são aplicações que seguem o [The Twelve-Factor App](https://12factor.net/pt_br/).

## Conceitos-chave do k8s

É importante saber que a forma como o k8s gerencia os contêineres é ligeiramente diferente de outros orquestradores, como o Docker Swarm, sobretudo devido ao fato de que ele não trata os contêineres diretamente, mas sim através de *pods*. Vamos conhecer alguns dos principais conceitos que envolvem o k8s a seguir:

- **Pod**: é o menor objeto do k8s. Como dito anteriormente, o k8s não trabalha com os contêineres diretamente, mas organiza-os dentro de *pods*, que são abstrações que dividem os mesmos recursos, como endereços, volumes, ciclos de CPU e memória. Um pod, embora não seja comum, pode possuir vários contêineres;

- **Controller**: é o objeto responsável por interagir com o *API Server* e orquestrar algum outro objeto. Exemplos de objetos desta classe são os *Deployments* e *Replication Controllers*;

- **ReplicaSets**: é um objeto responsável por garantir a quantidade de pods em execução no nó;

- **Deployment**: É um dos principais *controllers* utilizados. O *Deployment*, em conjunto com o *ReplicaSet*, garante que determinado número de réplicas de um pod esteja em execução nos nós workers do cluster. Além disso, o Deployment também é responsável por gerenciar o ciclo de vida das aplicações, onde características associadas a aplicação, tais como imagem, porta, volumes e variáveis de ambiente, podem ser especificados em arquivos do tipo *yaml* ou *json* para posteriormente serem passados como parâmetro para o ``kubectl`` executar o deployment. Esta ação pode ser executada tanto para criação quanto para atualização e remoção do deployment;

- **Jobs e CronJobs**: são objetos responsáveis pelo gerenciamento de jobs isolados ou recorrentes.

# Aviso sobre os comandos

> Atenção!!! Antes de cada comando é apresentado o tipo prompt. Exemplos:

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

# Minikube

## Requisitos básicos

É importante frisar que o Minikube deve ser instalado localmente, e não em um *cloud provider*. Por isso, as especificações de *hardware* a seguir são referentes à máquina local.

* Processamento: 1 core;
* Memória: 2 GB;
* HD: 20 GB.

## Instalação do Minikube no GNU/Linux

Antes de mais nada, verifique se a sua máquina suporta virtualização. No GNU/Linux, isto pode ser realizado com:

```
grep -E --color 'vmx|svm' /proc/cpuinfo
```

Caso a saída do comando não seja vazia, o resultado é positivo.

Após isso, vamos instalar o ``kubectl`` com os seguintes comandos.

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
```

Há a possibilidade de não utilizar um *hypervisor* para a instalação do Minikube, executando-o ao invés disso sobre o próprio host. Iremos utilizar o Oracle VirtualBox como *hypervisor*, que pode ser encontrado [aqui](https://www.virtualbox.org).

Efetue o download e a instalação do ``Minikube`` utilizando os seguintes comandos.

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

chmod +x ./minikube

sudo mv ./minikube /usr/local/bin/minikube

minikube version
```

## Instalação do Minikube no MacOS

No MacOS, o comando para verificar se o processador suporta virtualização é:

```
# sysctl -a | grep -E --color 'machdep.cpu.features|VMX'
```

Se você visualizar `VMX` na saída, o resultado é positivo.

O ``kubectl`` pode ser instalado no MacOS utilizando tanto o [Homebrew](https://brew.sh), quanto o método tradicional. Com o Homebrew já instalado, o kubectl pode ser instalado da seguinte forma.

```
# brew install kubectl

kubectl version --client
```

Ou:

```
# brew install kubectl-cli

kubectl version --client
```

Já com o método tradicional, a instalação pode ser realizada com os seguintes comandos.

```
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
```

Por fim, efetue a instalação do Minikube com um dos dois métodos a seguir, podendo optar-se pelo Homebrew ou pelo método tradicional.

```
# brew install minikube

minikube version
```

Ou:

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

chmod +x ./minikube

sudo mv ./minikube /usr/local/bin/minikube

minikube version
```

## kubectl: alias e autocomplete

Execute o seguinte comando para configurar o alias e autocomplete para o ``kubectl``.

No Bash:

```bash
source <(kubectl completion bash) # configura o autocomplete na sua sessão atual (antes, certifique-se de ter instalado o pacote bash-completion).

echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanentemente ao seu shell.
```

Crie o alias ``k`` para ``kubectl``:

```
alias k=kubectl

complete -F __start_kubectl k
```

No ZSH:

```
source <(kubectl completion zsh)

echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)"
```

## Instalação do Minikube no Microsoft Windows

No Microsoft Windows, você deve executar o comando `systeminfo` no prompt de comando ou no terminal. Caso o retorno deste comando seja semelhante com o descrito a seguir, então a virtualização é suportada.

```textile
Hyper-V Requirements:     VM Monitor Mode Extensions: Yes
                          Virtualization Enabled In Firmware: Yes
                          Second Level Address Translation: Yes
                          Data Execution Prevention Available: Yes
```

Caso a linha a seguir também esteja presente, não é necessária a instalação de um *hypervisor* como o Oracle VirtualBox:

```textile
Hyper-V Requirements:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.
```

A instalação do ``kubectl`` pode ser realizada efetuando o download [neste link](https://storage.googleapis.com/kubernetes-release/release/v1.19.1/bin/windows/amd64/kubectl.exe). Feito isso, também deve ser realizado download e a instalação de um *hypervisor* (preferencialmente o [Oracle VirtualBox](https://www.virtualbox.org)), caso no passo anterior não tenha sido acusada a presença de um. Finalmente, efetue o download do instalador do Minikube [aqui](https://github.com/kubernetes/minikube/releases/latest) e execute-o.

## Iniciando, parando e excluindo o Minikube

Quando operando em conjunto com um *hypervisor*, o Minikube cria uma máquina virtual, onde dentro dela estarão todos os componentes do k8s para execução. Para realizar a inicialização desse ambiente, antes de executar o minikube, precisamos setar o VirtualBox como padrão para subir este ambiente, para que isso aconteça execute o comando:

```
minikube config set driver virtualbox
```

Caso não queria deixar o VirtualBox como padrão sempre que subir o ambiente novo, você deve digitar o comando ``minikube start --driver=virtualbox``. Mas como já setamos o VirtualBox como padrão para subir o ambiente do minikube, basta executar:

```
minikube start
```

Para criar um cluster com multi-node basta executar:

``` 
minikube start --nodes 2 -p multinode-demo
```

Caso deseje parar o ambiente:

```
minikube stop
```

Para excluir o ambiente:

```
minikube delete
```

## Certo, e como eu sei que está tudo funcionando como deveria?

Uma vez iniciado, você deve ter uma saída na tela similar à seguinte:

```
minikube start


🎉  minikube 1.10.0 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.10.0
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

🙄  minikube v1.9.2 on Darwin 10.11
✨  Using the virtualbox driver based on existing profile
👍  Starting control plane node m01 in cluster minikube
🔄  Restarting existing virtualbox VM for "minikube" ...
🐳  Preparing Kubernetes v1.19.1 on Docker 19.03.8 ...
🌟  Enabling addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube"
```

Você pode então listar os nós que fazem parte do seu *cluster* k8s com o seguinte comando:

```
kubectl get nodes
```

A saída será similar ao conteúdo a seguir:

Para um node:

```
kubectl get nodes

NAME       STATUS   ROLES    AGE   VERSION
minikube   Ready    master   8d    v1.19.1
```

Para multi-nodes:

```
NAME                 STATUS    ROLES     AGE       VERSION
multinode-demo       Ready     master    5m        v1.19.1
multinode-demo-m02   Ready     <none>    4m        v1.19.1
```

Inicialmente, a intenção do Minikube é executar o k8s em apenas um nó, porém a partir da versão 1.10.1 e possível usar a função de multi-node (Experimental).

Caso os comandos anteriores tenham sido executados sem erro, a instalação do Minikube terá sido realizada com sucesso.

## Descobrindo o endereço do Minikube

Como dito anteriormente, o Minikube irá criar uma máquina virtual, assim como o ambiente para a execução do k8s localmente. Ele também irá configurar o ``kubectl`` para comunicar-se com o Minikube. Para saber qual é o endereço IP dessa máquina virtual, pode-se executar:

```
minikube ip
```

O endereço apresentado é que deve ser utilizado para comunicação com o k8s.

## Acessando a máquina do Minikube via SSH

Para acessar a máquina virtual criada pelo Minikube, pode-se executar:

```
minikube ssh
```

## Dashboard

O Minikube vem com um *dashboard* *web* interessante para que o usuário iniciante observe como funcionam os *workloads* sobre o k8s. Para habilitá-lo, o usuário pode digitar:

```
minikube dashboard
```

## Logs

Os *logs* do Minikube podem ser acessados através do seguinte comando.

```
minikube logs
```

# Microk8s

## Requisitos básicos

Existem alguns tipos de instalação do Microk8s:

* GNU/Linux que suportam Snap;
* Windows - 4GB RAM e 40GB HD Livre;
* MacOS - Brew;
* RaspBerry.

## Instalação do MicroK8s no GNU/Linux

### Versões que suportam Snap

BASH:

```
sudo snap install microk8s --classic --channel=1.18/stable

sudo usermod -a -G microk8s $USER

sudo chown -f -R $USER ~/.kube

microk8s status --wait-ready

microk8s enable dns dashboard registry

alias kubectl='microk8s kubectl'
```

## Instalação no Windows

Somente é possível em versões do Windows Professional e Enterprise

Também será necessário a instalação por meio de um administrador de pacotes do Windows, o [Chocolatey
](https://chocolatey.org/install)

### Instalando o Chocolatey

PowerShell Admin:

```
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

#### Instalando o Multipass

PowerShell Admin:

```
# choco install multipass
```

### Utilizando Microk8s com Multipass

PowerShell Admin:

```
# multipass launch --name microk8s-vm --mem 4G --disk 40G

# multipass exec microk8s-vm -- snap install microk8s --classic

# multipass exec microk8s-vm -- iptables -P FORWARD ACCEPT

# multipass list

Name                    State             IPv4             Release
microk8s-vm             RUNNING           10.72.145.216    Ubuntu 18.04 LTS

# multipass shell microk8s-vm
```

Se quiser utilizar o Microk8s sem utilizar um shell criado pelo multipass utilize a seguinte expressão.

PowerShell Admin:

```
# multipass exec microk8s-vm -- /snap/bin/microk8s.<command>
```

## Instalando o Microk8s no Mac

Utilizando o gerenciador de pacotes do Mac `Brew`:

### Instalando o Brew

Se não tiver o ``brew`` instalado em sua máquina siga os passos a seguir. Caso já o possua, vá para o passo dois dessa seção.

BASH:

```
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

### Instalando o Microk8s via Brew

BASH:

```
sudo brew install ubuntu/microk8s/microk8s

sudo microk8s install

sudo microk8s kubectl get all --all-namespaces
```

Espere até que a configuração do microk8s esteja pronta para ser utilizada.

BASH:

```
microk8s status --wait-ready
```

Assim que o comentário: ``microk8s is running`` for exibido, execute o seguinte comando.

BASH:

```
microk8s kubectl <command>
```

# Kind

O Kind (Kubernetes in Docker) é outra alternativa para executar o Kubernetes num ambiente local para testes e aprendizado, mas não é recomendado para uso em produção.

## Instalação no GNU/Linux

Para fazer a instalação no GNU/Linux, execute os seguintes comandos.

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind
```

## Instalação no MacOS

Para fazer a instalação no MacOS, execute o seguinte comando.

```
sudo brew install kind
```

## Instalação no Windows

Para fazer a instalação no Windows, execute os seguintes comandos.

```
# curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.8.1/kind-windows-amd64

# Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
```

### Instalação no Windows via Chocolatey

Execute o seguinte comando para instalar o Kind no Windows usando o Chocolatey.

```
# choco install kind
```

## Criando um cluster com o Kind

Após realizar a instalação do Kind, vamos iniciar o nosso cluster.

```
kind create cluster

Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.19.1) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Thanks for using kind! 😊
```

É possível criar mais de um cluster e personalizar o seu nome.

```
kind create cluster --name giropops

Creating cluster "giropops" ...
 ✓ Ensuring node image (kindest/node:v1.19.1) 🖼
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

NAME                 STATUS   ROLES    AGE     VERSION
kind-control-plane   Ready    master   3m51s   v1.19.1
```

### Criando um cluster com múltiplos nós locais com o Kind

É possível para essa aula incluir múltiplos nós na estrutura do Kind, que foi mencionado anteriormente.

Execute o comando a seguir para selecionar e remover todos os clusters locais criados no Kind.

```
kind delete clusters $(kind get clusters)
```

Crie um arquivo de configuração para definir quantos e o tipo de nós no cluster que você deseja. No exemplo a seguir, será criado o arquivo de configuração ``kind-3nodes.yaml`` para especificar um cluster com 1 nó master (que executará o control plane) e 2 workers.

```
cat << EOF > kind-3nodes.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF
```

Crie um cluster chamado ``kind-multinodes`` utilizando as especificações definidas no arquivo ``kind-3nodes.yaml``.

```
kind create cluster --name kind-multinodes --config ./kind-3nodes.yaml

Creating cluster "kind-multinodes" ...
 ✓ Ensuring node image (kindest/node:v1.19.1) 🖼
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

NAME                            STATUS   ROLES    AGE     VERSION
kind-multinodes-control-plane   Ready    master   3m3s    v1.19.1
kind-multinodes-worker1          Ready    <none>   2m30s   v1.19.1
kind-multinodes-worker2         Ready    <none>   2m30s   v1.19.1
```

Mais informações sobre o Kind estão disponíveis em: https://kind.sigs.k8s.io

! Referência: [kind multi-cluster](https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/)

# k3s

Vamos aprender como instalar o renomado k3s e adicionar nodes no seu cluster!

Nesse exemplo eu estou usando o Raspberry Pi 4, a *master* com 4GB de memória RAM e 4 cores, e 2 workers com 2GB de memória RAM e 4 cores.

Para instalar o k3s, basta executar o seguinte comando:

```
curl -sfL https://get.k3s.io | sh -

[INFO]  Finding release for channel stable
[INFO]  Using v1.19.1+k3s1 as release
[INFO]  Downloading hash https://github.com/rancher/k3s/releases/download/v1.19.1+k3s1/sha256sum-arm.txt
[INFO]  Downloading binary https://github.com/rancher/k3s/releases/download/v1.19.1+k3s1/k3s-armhf
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating /usr/local/bin/ctr symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
```

Vamos ver se está tudo certo com o nosso node master.

```
kubectl get nodes

NAME        STATUS   ROLES    AGE   VERSION
elliot-01   Ready    master   15s   v1.19.1+k3s1
```

Vamos ver os pods em execução:

```
kubectl get pods

No resources found in default namespace.
```

Humm! Parece que não temos nenhum, mas será mesmo?

Vamos verificar novamente:

```
kubectl get pods --all-namespaces

NAMESPACE     NAME                                     READY   STATUS      RESTARTS   AGE
kube-system   metrics-server-7566d596c8-rdn5f          1/1     Running     0          7m5s
kube-system   local-path-provisioner-6d59f47c7-mfp89   1/1     Running     0          7m5s
kube-system   coredns-8655855d6-ns4d4                  1/1     Running     0          7m5s
kube-system   helm-install-traefik-mqmp4               0/1     Completed   2          7m5s
kube-system   svclb-traefik-t49cs                      2/2     Running     0          6m11s
kube-system   traefik-758cd5fc85-jwvmc                 1/1     Running     0          6m12s
```

Aí estão os pods que estão executando por padrão, que o próprio k8s cria para executar seus próprios componentes internos. Mas temos muito mais coisas além dos pods, vamos conferir tudo que está rodando no nosso lindo k3s:

```
kubectl get all --all-namespaces

NAMESPACE     NAME                                         READY   STATUS      RESTARTS   AGE
kube-system   pod/metrics-server-7566d596c8-rdn5f          1/1     Running     0          11m
kube-system   pod/local-path-provisioner-6d59f47c7-mfp89   1/1     Running     0          11m
kube-system   pod/coredns-8655855d6-ns4d4                  1/1     Running     0          11m
kube-system   pod/helm-install-traefik-mqmp4               0/1     Completed   2          11m
kube-system   pod/svclb-traefik-t49cs                      2/2     Running     0          10m
kube-system   pod/traefik-758cd5fc85-jwvmc                 1/1     Running     0          10m

NAMESPACE     NAME                         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
default       service/kubernetes           ClusterIP      10.43.0.1      <none>           443/TCP                      12m
kube-system   service/kube-dns             ClusterIP      10.43.0.10     <none>           53/UDP,53/TCP,9153/TCP       12m
kube-system   service/metrics-server       ClusterIP      10.43.181.42   <none>           443/TCP                      12m
kube-system   service/traefik-prometheus   ClusterIP      10.43.207.57   <none>           9100/TCP                     10m
kube-system   service/traefik              LoadBalancer   10.43.232.43   192.168.86.101   80:30953/TCP,443:31363/TCP   10m

NAMESPACE     NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/svclb-traefik   1         1         1       1            1           <none>          10m

NAMESPACE     NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/metrics-server           1/1     1            1           12m
kube-system   deployment.apps/local-path-provisioner   1/1     1            1           12m
kube-system   deployment.apps/coredns                  1/1     1            1           12m
kube-system   deployment.apps/traefik                  1/1     1            1           10m

NAMESPACE     NAME                                               DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/metrics-server-7566d596c8          1         1         1       11m
kube-system   replicaset.apps/local-path-provisioner-6d59f47c7   1         1         1       11m
kube-system   replicaset.apps/coredns-8655855d6                  1         1         1       11m
kube-system   replicaset.apps/traefik-758cd5fc85                 1         1         1       10m

NAMESPACE     NAME                             COMPLETIONS   DURATION   AGE
kube-system   job.batch/helm-install-traefik   1/1           55s        11m
```

Muito legal, bacana e sensacional né?

Porém ainda temos apenas 1 node, queremos adicionar mais nodes para que tenhamos alta disponibilidade para nossas aplicações.

Para fazer isso, primeiro vamos pegar o Token do nosso cluster pois iremos utilizá-lo para adicionar os outros nodes em nosso cluster.

```
# cat /var/lib/rancher/k3s/server/node-token

K10bded4a17f7674c322febfb517cde93afaa48c35b74528d9d2b7d20ec8e41a1ad::server:9d2c12e1112ecdc0d1f9a2fd0e2933fe
```

Mágica, achamos nosso Token.

Agora finalmente bora adicionar mais nodes em nosso cluster.

Calma, antes pegue o IP de seu master:

```
ifconfig

...
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.86.101  netmask 255.255.255.0  broadcast 192.168.86.255
        inet6 fe80::f58b:e4b:c74e:cbd  prefixlen 64  scopeid 0x20<link>
        ether dc:a6:32:08:c5:6d  txqueuelen 1000  (Ethernet)
        RX packets 117526  bytes 161460044 (153.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 17418  bytes 1180417 (1.1 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
...
```

Legal! Agora que você já tem o Token e o IP da master, bora para o outro node.

Já no outro node, nós vamos executar o comando para que ele seja adicionado:

```
# curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=XXX sh -
```

O comando ficará mais ou menos assim (lembre-se de trocar pelo seu IP e Token):

```
# curl -sfL https://get.k3s.io | K3S_URL=https://192.168.86.101:6443 K3S_TOKEN=K10bded4a17f7674c322febfb517cde93afaa48c35b74528d9d2b7d20ec8e41a1ad::server:9d2c12e1112ecdc0d1f9a2fd0e2933fe sh -

[INFO]  Finding release for channel stable
[INFO]  Using v1.19.1+k3s1 as release
[INFO]  Downloading hash https://github.com/rancher/k3s/releases/download/v1.19.1+k3s1/sha256sum-arm.txt
[INFO]  Downloading binary https://github.com/rancher/k3s/releases/download/v1.19.1+k3s1/k3s-armhf
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating /usr/local/bin/ctr symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-agent-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s-agent.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s-agent.service
[INFO]  systemd: Enabling k3s-agent unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s-agent.service → /etc/systemd/system/k3s-agent.service.
[INFO]  systemd: Starting k3s-agent
```

Perfeito! Agora vamos ver se esse node está no nosso cluster mesmo:

```
kubectl get nodes

NAME        STATUS   ROLES    AGE     VERSION
elliot-02   Ready    <none>   5m27s   v1.19.1+k3s1
elliot-01   Ready    master   34m     v1.19.1+k3s1
```

Olha ele ali, ``elliot-02`` já está lindo de bonito em nosso cluster, mágico não?

Quer adicionar mais nodes? Só copiar e colar aquele mesmo comando com o IP do master e o nosso Token no próximo node.

```
kubectl get nodes

NAME        STATUS   ROLES    AGE   VERSION
elliot-02   Ready    <none>   10m   v1.19.1+k3s1
elliot-01   Ready    master   39m   v1.19.1+k3s1
elliot-03   Ready    <none>   68s   v1.19.1+k3s1
```

Todos os elliots saudáveis!!!

Pronto!!! Agora temos um cluster com 3 nodes trabalhando, e as possibilidades são infinitas, divirta-se.

Para saber mais detalhes acesse as documentações oficiais do k3s:

* https://k3s.io/
* https://rancher.com/docs/k3s/latest/en/
* https://github.com/rancher/k3s

# Instalação em cluster com três nós

## Requisitos básicos

Como já dito anteriormente, o Minikube é ótimo para desenvolvedores, estudos e testes, mas não tem como propósito a execução em ambiente de produção. Dito isso, a instalação de um *cluster* k8s para o treinamento irá requerer pelo menos três máquinas, físicas ou virtuais, cada qual com no mínimo a seguinte configuração:

- Distribuição: Debian, Ubuntu, CentOS, Red Hat, Fedora, SuSE;

- Processamento: 2 *cores*;

- Memória: 2GB.

## Configuração de módulos de kernel

O k8s requer que certos módulos do kernel GNU/Linux estejam carregados para seu pleno funcionamento, e que esses módulos sejam carregados no momento da inicialização do computador. Para tanto, crie o arquivo ``/etc/modules-load.d/k8s.conf`` com o seguinte conteúdo em todos os seus nós.

```textile
br_netfilter
ip_vs
ip_vs_rr
ip_vs_sh
ip_vs_wrr
nf_conntrack_ipv4
```

## Atualização da distribuição

Em distribuições Debian e baseadas, como o Ubuntu, execute o comando a seguir, em cada um de seus nós, para executar atualização do sistema.

```
sudo apt update

sudo apt upgrade -y
```

Em distribuições Red Hat e baseadas, use o seguinte comando.

```
# yum upgrade -y
```

## Instalação do Docker e do Kubernetes

A instalação do Docker pode ser realizada com apenas um comando, que deve ser executado nos três nós:

```
# curl -fsSL https://get.docker.com | bash
```

Embora a maneira anterior seja a mais fácil, não permite o controle de opções. Por esse motivo, a documentação do Kubernetes sugere uma instalação mais controlada seguindo os passos disponíveis em: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

**Caso escolha o método mais fácil**, os próximos comandos são muito importantes, pois garantem que o driver ``Cgroup`` do Docker será configurado para o ``systemd``, que é o gerenciador de serviços padrão utilizado pelo Kubernetes.

Para a família Debian, execute o seguinte comando:

```
# cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```

Para a família Red Hat, execute o seguinte comando:

```
# cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
```

Os passos a seguir são iguais para ambas as famílias.

```
sudo mkdir -p /etc/systemd/system/docker.service.d
```

Agora basta reiniciar o Docker.

```
# systemctl daemon-reload
# systemctl restart docker
```

Para finalizar, verifique se o driver ``Cgroup`` foi corretamente definido.

```
# docker info | grep -i cgroup
```

Se a saída foi ``Cgroup Driver: systemd``, tudo certo!

O próximo passo é efetuar a adição dos repositórios do k8s e efetuar a instalação do ``kubeadm``.

Em distribuições Debian e baseadas, isso pode ser realizado com os comandos a seguir.

```
# apt-get update && apt-get install -y apt-transport-https gnupg2

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# apt-get update

# apt-get install -y kubelet kubeadm kubectl
```

Já em distribuições Red Hat e baseadas, adicione o repositório do k8s criando o arquivo ``/etc/yum.repos.d/kubernetes.repo`` com o conteúdo a seguir:

```
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
```

Os comandos a seguir desativam o *firewall*, instalam os pacotes do k8s e ativam o serviço do mesmo.

```
# setenforce 0

# systemctl stop firewalld

# systemctl disable firewalld

# yum install -y kubelet kubeadm kubectl

# systemctl enable docker && systemctl start docker

# systemctl enable kubelet && systemctl start kubelet
```

Ainda em distribuições Red Hat e baseadas, é necessário a configuração de alguns parâmetros extras no kernel por meio do **sysctl**. Estes podem ser setados criando o arquivo ``/etc/sysctl.d/k8s.conf`` com o seguinte conteúdo.

```
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

Em ambas distribuições GNU/Linux também é necessário desativar a memória swap em todos os nós com o comando a seguir.

```
# swapoff -a
```

Além de comentar a linha referente à mesma no arquivo ```/etc/fstab```.

Após esses procedimentos, é interessante a reinicialização de todos os nós do *cluster*.

## Inicialização do cluster

Antes de inicializarmos o *cluster*, vamos efetuar o *download* das imagens que serão utilizadas, executando o comando a seguir no nó que será o *master*.

```
# kubeadm config images pull
```

Execute o comando a seguir também apenas no nó *master* para a inicialização do cluster. Caso tudo esteja bem, será apresentada ao término de sua execução o comando que deve ser executado nos demais nós para ingressar no *cluster*.

```
# kubeadm init
```

A opção _--apiserver-advertise-address_ informa qual o endereço IP em que o servidor de API irá escutar. Caso este parâmetro não seja informado, a interface de rede padrão será usada. Opcionalmente, você também pode passar o cidr com a opção _--pod-network-cidr_. O comando obedecerá a seguinte sintaxe:

```
kubeadm init --apiserver-advertise-address 192.168.99.2 --pod-network-cidr 192.168.99.0/24
```

A saída do comando será algo similar ao mostrado a seguir.

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

Caso o servidor possua mais de uma interface de rede, você pode verificar se o IP interno do nó do seu cluster corresponde ao IP da interface esperada com o seguinte comando:

```
kubectl describe node elliot-1 | grep InternalIP
```

A saída será algo similar a seguir:

```
InternalIP:  192.168.99.2
```

Caso o Ip não corresponda ao da interface de rede escolhida, você pode ir até o arquivo localizado em _/etc/systemd/system/kubelet.service.d/10-kubeadm.conf_ com o editor da sua preferência, procurar por _KUBELET_CONFIG_ARGS_ e adicionar no final a instrução --node-ip=<IP Da sua preferência>. O trecho alterado será semelhante abaixo:

```
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --node-ip=192.168.99.2"
```

Salve o arquivo e execute os comandos abaixo para reiniciar a configuração e consequentemente o kubelet.

```
systemctl daemon-reload
systemctl restart kubelet
```

## Configuração do arquivo de contextos do kubectl

Como dito anteriormente e de forma similar ao Docker Swarm, o próprio kubeadm já mostrará os comandos necessários para a configuração do ``kubectl``, para que assim possa ser estabelecida comunicação com o cluster k8s. Para tanto, execute os seguintes comandos.

```
mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Inserindo os nós workers no cluster

Para inserir os nós *workers* no *cluster*, basta executar a linha que começa com ``kubeadm join`` nos mesmos.

### Múltiplas Interfaces

Caso algum dos nós que será utilizado tenha mais de uma interface de rede, verifique se ele consegue alcançar o `service` do `Kubernetes` através da rota padrão.

Para verificar, será necessário pegar o IP interno do `service` Kubernetes através do comando ``kubectl get services kubernetes``. Após obter o IP, basta ir no nó que será ingressado no cluster e rodar o comando ``curl -k https://SERVICE`` alterando o `SERVICE` para o IP do `service`. Exemplo: ``curl -k https://10.96.0.1``.

Caso a saída seja algo parecido com o exemplo a seguir, a conexão está acontecendo normalmente.

```json
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}
```

Caso a saída não seja parecido com o exemplo, será necessário adicionar uma rota com o seguinte comando.

```shell
ip route add REDE_DO_SERVICE/16 dev INTERFACE
```

Substitua a `REDE_DO SERVICE` com a rede do `service` (geralmente é um IP finalizando com 0).

Exemplo: Se o IP for `10.96.0.1` a rede é `10.96.0.0`) e a `INTERFACE` com a interface do nó que tem acesso ao `master` do cluster.

Exemplo de comando para adicionar uma rota:

```
# ip route add 10.96.0.0/16 dev eth1
```

Adicione a rota nas configurações de rede para que seja criada durante o boot.

## Instalação do pod network

Para os usuários do Docker Swarm, há uma diferença entre os dois orquestradores: o k8s por padrão não fornece uma solução de *networking* *out-of-the-box*. Para que isso ocorra, deve ser instalada uma solução de *pod networking* como *add-on*. Existem diversas opções disponíveis, cada qual com funcionalidades diferentes, tais como: [Flannel](https://github.com/coreos/flannel), [Calico](http://docs.projectcalico.org/), [Romana](http://romana.io), [Weave-net](https://www.weave.works/products/weave-net/), entre outros.

Mais informações sobre *pod networking* serão abordados nos demais dias do treinamento.

Caso você ainda não tenha reiniciado os nós que compõem o seu *cluster*, você pode carregar os módulos do kernel necessários com o seguinte comando.

```
# modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs
```

No curso, nós iremos utilizar o **Weave-net**, que pode ser instalado com o comando a seguir.

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

Para verificar se o *pod network* foi criado com sucesso, execute o seguinte comando.

```
kubectl get pods -n kube-system
```

O resultado deve ser semelhante ao mostrado a seguir.

```
NAME                                READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-pfm2c            1/1     Running   0          8d
coredns-66bff467f8-s8pk4            1/1     Running   0          8d
etcd-docker-01                      1/1     Running   0          8d
kube-apiserver-docker-01            1/1     Running   0          8d
kube-controller-manager-docker-01   1/1     Running   0          8d
kube-proxy-mdcgf                    1/1     Running   0          8d
kube-proxy-q9cvf                    1/1     Running   0          8d
kube-proxy-vf8mq                    1/1     Running   0          8d
kube-scheduler-docker-01            1/1     Running   0          8d
weave-net-7dhpf                     2/2     Running   0          8d
weave-net-fvttp                     2/2     Running   0          8d
weave-net-xl7km                     2/2     Running   0          8d
```

Pode-se observar que há três contêineres do Weave-net em execução provendo a *pod network* para o nosso *cluster*.

## Verificando a instalação

Para verificar se a instalação está funcionando, e se os nós estão se comunicando, você pode executar o comando ``kubectl get nodes`` no nó master, que deve lhe retornar algo como o conteúdo a seguir.

```
NAME        STATUS   ROLES    AGE   VERSION
elliot-01   Ready    master   8d    v1.19.1
elliot-02   Ready    <none>   8d    v1.19.1
elliot-03   Ready    <none>   8d    v1.19.1
```

# Primeiros passos no k8s

## Exibindo informações detalhadas sobre os nós

```
kubectl describe node [nome_do_no]
```

Exemplo:

```
kubectl describe node elliot-02

Name:               elliot-02
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=elliot-02
                    kubernetes.io/os=linux
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
```

## Exibindo novamente token para entrar no cluster

Para visualizar novamente o *token* para inserção de novos nós, execute o seguinte comando.

```
# kubeadm token create --print-join-command
```

## Ativando o autocomplete

Em distribuições Debian e baseadas, certifique-se que o pacote ``bash-completion`` esteja instalado. Instale-o com o comando a seguir.

```
sudo apt install -y bash-completion
```

Em sistemas Red Hat e baseados, execute:

```
# yum install -y bash-completion
```

Feito isso, execute o seguinte comando.

```
kubectl completion bash > /etc/bash_completion.d/kubectl
```

Efetue *logoff* e *login* para carregar o *autocomplete*. Caso não deseje, execute:

```
source < (kubectl completion bash)
```

## Verificando os namespaces e pods

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

NAME                                READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-pfm2c            1/1     Running   0          8d
coredns-66bff467f8-s8pk4            1/1     Running   0          8d
etcd-docker-01                      1/1     Running   0          8d
kube-apiserver-docker-01            1/1     Running   0          8d
kube-controller-manager-docker-01   1/1     Running   0          8d
kube-proxy-mdcgf                    1/1     Running   0          8d
kube-proxy-q9cvf                    1/1     Running   0          8d
kube-proxy-vf8mq                    1/1     Running   0          8d
kube-scheduler-docker-01            1/1     Running   0          8d
weave-net-7dhpf                     2/2     Running   0          8d
weave-net-fvttp                     2/2     Running   0          8d
weave-net-xl7km                     2/2     Running   0          8d
```

Será que há algum *pod* escondido em algum *namespace*? É possível listar todos os *pods* de todos os *namespaces* com o comando a seguir.

```
kubectl get pods --all-namespaces
```

Há a possibilidade ainda, de utilizar o comando com a opção ```-o wide```, que disponibiliza maiores informações sobre o recurso, inclusive em qual nó o *pod* está sendo executado. Exemplo:

```
kubectl get pods --all-namespaces -o wide

NAMESPACE     NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE        NOMINATED NODE   READINESS GATES
default       nginx                               1/1     Running   0          24m   10.44.0.1      docker-02   <none>           <none>
kube-system   coredns-66bff467f8-pfm2c            1/1     Running   0          8d    10.32.0.3      docker-01   <none>           <none>
kube-system   coredns-66bff467f8-s8pk4            1/1     Running   0          8d    10.32.0.2      docker-01   <none>           <none>
kube-system   etcd-docker-01                      1/1     Running   0          8d    172.16.83.14   docker-01   <none>           <none>
kube-system   kube-apiserver-docker-01            1/1     Running   0          8d    172.16.83.14   docker-01   <none>           <none>
kube-system   kube-controller-manager-docker-01   1/1     Running   0          8d    172.16.83.14   docker-01   <none>           <none>
kube-system   kube-proxy-mdcgf                    1/1     Running   0          8d    172.16.83.14   docker-01   <none>           <none>
kube-system   kube-proxy-q9cvf                    1/1     Running   0          8d    172.16.83.12   docker-03   <none>           <none>
kube-system   kube-proxy-vf8mq                    1/1     Running   0          8d    172.16.83.13   docker-02   <none>           <none>
kube-system   kube-scheduler-docker-01            1/1     Running   0          8d    172.16.83.14   docker-01   <none>           <none>
kube-system   weave-net-7dhpf                     2/2     Running   0          8d    172.16.83.12   docker-03   <none>           <none>
kube-system   weave-net-fvttp                     2/2     Running   0          8d    172.16.83.13   docker-02   <none>           <none>
kube-system   weave-net-xl7km                     2/2     Running   0          8d    172.16.83.14   docker-01   <none>           <none>
```

## Executando nosso primeiro pod no k8s

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
Node:         docker-02/172.16.83.13
Start Time:   Tue, 12 May 2020 02:29:38 -0300
Labels:       run=nginx
Annotations:  <none>
Status:       Running
IP:           10.44.0.1
IPs:
  IP:  10.44.0.1
Containers:
  nginx:
    Container ID:   docker://2719e2bc023944ee8f34db538094c96b24764a637574c703e232908b46b12a9f
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:86ae264c3f4acb99b2dee4d0098c40cb8c46dcf9e1148f05d3a51c4df6758c12
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 12 May 2020 02:29:42 -0300
```

## Verificar os últimos eventos do cluster

Você pode verificar quais são os últimos eventos do *cluster* com o comando ``kubectl get events``. Serão mostrados eventos como: o *download* de imagens do Docker Hub (ou de outro *registry* configurado), a criação/remoção de *pods*, etc.

A saída a seguir mostra o resultado da criação do nosso contêiner com Nginx.

```
LAST SEEN   TYPE     REASON      OBJECT      MESSAGE
5m34s       Normal   Scheduled   pod/nginx   Successfully assigned default/nginx to docker-02
5m33s       Normal   Pulling     pod/nginx   Pulling image "nginx"
5m31s       Normal   Pulled      pod/nginx   Successfully pulled image "nginx"
5m30s       Normal   Created     pod/nginx   Created container nginx
5m30s       Normal   Started     pod/nginx   Started container nginx
```

No resultado do comando anterior é possível observar que a execução do nginx ocorreu no *namespace* default e que a imagem **nginx** não existia no repositório local e, sendo assim, teve de ser feito download da imagem.

## Efetuar o dump de um objeto em formato YAML

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
  creationTimestamp: "2020-05-12T05:29:38Z"
  labels:
    run: nginx
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:labels:
          .: {}
          f:run: {}
      f:spec:
        f:containers:
          k:{"name":"nginx"}:
            .: {}
            f:image: {}
            f:imagePullPolicy: {}
            f:name: {}
            f:resources: {}
            f:terminationMessagePath: {}
            f:terminationMessagePolicy: {}
        f:dnsPolicy: {}
        f:enableServiceLinks: {}
        f:restartPolicy: {}
        f:schedulerName: {}
        f:securityContext: {}
        f:terminationGracePeriodSeconds: {}
    manager: kubectl
    operation: Update
    time: "2020-05-12T05:29:38Z"
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:status:
        f:conditions:
          k:{"type":"ContainersReady"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
          k:{"type":"Initialized"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
          k:{"type":"Ready"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
        f:containerStatuses: {}
        f:hostIP: {}
        f:phase: {}
        f:podIP: {}
        f:podIPs:
          .: {}
          k:{"ip":"10.44.0.1"}:
            .: {}
            f:ip: {}
        f:startTime: {}
    manager: kubelet
    operation: Update
    time: "2020-05-12T05:29:43Z"
  name: nginx
  namespace: default
  resourceVersion: "1673991"
  selfLink: /api/v1/namespaces/default/pods/nginx
  uid: 36506f7b-1f3b-4ee8-b063-de3e6d31bea9
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
      name: default-token-nkz89
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: docker-02
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
  - name: default-token-nkz89
    secret:
      defaultMode: 420
      secretName: default-token-nkz89
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2020-05-12T05:29:38Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2020-05-12T05:29:43Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2020-05-12T05:29:43Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2020-05-12T05:29:38Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://2719e2bc023944ee8f34db538094c96b24764a637574c703e232908b46b12a9f
    image: nginx:latest
    imageID: docker-pullable://nginx@sha256:86ae264c3f4acb99b2dee4d0098c40cb8c46dcf9e1148f05d3a51c4df6758c12
    lastState: {}
    name: nginx
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2020-05-12T05:29:42Z"
  hostIP: 172.16.83.13
  phase: Running
  podIP: 10.44.0.1
  podIPs:
  - ip: 10.44.0.1
  qosClass: BestEffort
  startTime: "2020-05-12T05:29:38Z"
```

Observando o arquivo anterior, notamos que este reflete o **estado** do *pod*. Nós desejamos utilizar tal arquivo apenas como um modelo, e sendo assim, podemos apagar as entradas que armazenam dados de estado desse *pod*, como *status* e todas as demais configurações que são específicas dele. O arquivo final ficará com o conteúdo semelhante a este:

```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    creationTimestamp: null
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

## Socorro, são muitas opções!

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

## Expondo o pod

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

> Atenção!!! Arquivos YAML utilizam para sua tabulação dois espaços e não *tab*.

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

## Limpando tudo e indo para casa

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
