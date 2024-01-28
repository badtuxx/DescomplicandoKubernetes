# Descomplicando o Kubernetes
## DAY-14: Descomplicando Network Policies no Kubernetes

## Conteúdo do Day-14

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-14: Descomplicando Network Policies no Kubernetes](#day-14-descomplicando-network-policies-no-kubernetes)
  - [Conteúdo do Day-14](#conteúdo-do-day-14)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
    - [O que são Network Policies?](#o-que-são-network-policies)
      - [Para que Servem as Network Policies?](#para-que-servem-as-network-policies)
      - [Conceitos Fundamentais: Ingress e Egress](#conceitos-fundamentais-ingress-e-egress)
      - [Como Funcionam as Network Policies?](#como-funcionam-as-network-policies)
      - [Ainda não é padrão](#ainda-não-é-padrão)
      - [Criando um Cluster EKS com Network Policies](#criando-um-cluster-eks-com-network-policies)
        - [Instalando o EKSCTL](#instalando-o-eksctl)
        - [Instalando o AWS CLI](#instalando-o-aws-cli)
        - [Criando o Cluster EKS](#criando-o-cluster-eks)
        - [Instalando o AWS VPC CNI Plugin](#instalando-o-aws-vpc-cni-plugin)
        - [Habilitando o Network Policy nas Configurações Avançadas do CNI](#habilitando-o-network-policy-nas-configurações-avançadas-do-cni)
      - [Instalando o Nginx Ingress Controller](#instalando-o-nginx-ingress-controller)
    - [Instalando um Nginx Ingress Controller](#instalando-um-nginx-ingress-controller)
      - [Nossa Aplicação de Exemplo](#nossa-aplicação-de-exemplo)
    - [Criando Regras de Network Policy](#criando-regras-de-network-policy)
      - [Ingress](#ingress)
      - [Egress](#egress)


## O que iremos ver hoje?

Hoje vamos dedicar o nosso tempo para entender o mundo das Network Policies no Kubernetes. Essa é uma ferramenta essencial para a segurança e o gerenciamento eficaz da comunicação entre os Pods em um cluster Kubernetes. Vamos aprender como as Network Policies funcionam, suas aplicações práticas e como você pode implementá-las para proteger suas aplicações no Kubernetes.
Com certeza será um dia com muito conteúdo e aprendizado. Bora lá?

### O que são Network Policies?

No Kubernetes, uma Network Policy é um conjunto de regras que definem como os Pods podem se comunicar entre si e com outros endpoints de rede. Por padrão, os Pods em um cluster Kubernetes podem se comunicar livremente entre si, o que pode não ser ideal para todos os cenários. As Network Policies permitem que você restrinja esse acesso, garantindo que apenas o tráfego permitido possa fluir entre os Pods ou para/endereços IP externos.

#### Para que Servem as Network Policies?

Network Policies são usadas para:
- **Isolar** Pods de tráfego não autorizado.
- **Controlar** o acesso à serviços específicos.
- **Implementar** padrões de segurança e conformidade.

#### Conceitos Fundamentais: Ingress e Egress

- **Ingress**: Regras de ingresso controlam o tráfego de entrada para um Pod.
- **Egress**: Regras de saída controlam o tráfego de saída de um Pod.

Ter o entendimento desses conceitos é fundamental para entender como as Network Policies funcionam, pois você precisará especificar se uma regra se aplica ao tráfego de entrada ou de saída.

#### Como Funcionam as Network Policies?

Network Policies utilizam `SELECTORS` para identificar grupos de Pods e definir regras de tráfego para eles. A política pode especificar:

- **Ingress (entrada)**: quais Pods ou endereços IP podem se conectar a Pods selecionados.
- **Egress (saída)**: para quais Pods ou endereços IP os Pods selecionados podem se conectar.

#### Ainda não é padrão

Infelizmente, as Network Policies ainda não são um recurso padrão em todos os clusters Kubernetes. Recentemente a AWS anunciou o suporte a Network Policies no EKS, mas ainda não é um recurso padrão, para que você possa utilizar as Network Policies no EKS, você precisa instalar o CNI da AWS e depois habilitar o Network Policy nas configurações avançadas do CNI.

Para verificar se o seu cluster suporta Network Policies, você pode executar o seguinte comando:

```bash
kubectl api-versions | grep networking
```

Se você receber a mensagem `networking.k8s.io/v1`, significa que o seu cluster suporta Network Policies. Se você receber a mensagem `networking.k8s.io/v1beta1`, significa que o seu cluster não suporta Network Policies.

Se o seu cluster não suportar Network Policies, você pode utilizar o Calico para implementar as Network Policies no seu cluster. Para isso, você precisa instalar o Calico no seu cluster. Você pode encontrar mais informações sobre o Calico [aqui](https://docs.projectcalico.org/getting-started/kubernetes/).

Outros CNI que suportam Network Policies são o Weave Net e o Cilium, por exemplo.


#### Criando um Cluster EKS com Network Policies

Eu acredito que nessa altura do treinamento, você já saiba o que é um cluster EKS, certo?

Mas mesmo assim, eu vou fazer um pequena apresentação somente para resfrescar a sua memória ou então ajudar quem está chegando agora por aqui. hahaha

O EKS é o Kubernetes gerenciado pela AWS, mas o que isso significa?

Quando falamos sobre clusters Kubernetes gerenciados, estamos falando que que não precisaremos nos preocupar com a instalação e configuração do Kubernetes, pois isso será feito pela AWS. Nós precisaremos apenas criar o nosso cluster e gerenciar as nossas aplicações.

Como você já sabe, nós temos dois tipos de Nodes, os Nodes do Control Plane e os Nodes Workers. No EKS, os Nodes do Control Plane são gerenciados pela AWS, ou seja, não precisaremos nos preocupar com eles. Já os Workers, nós precisaremos criar e gerenciar, pelo menos na maioria dos casos.

Antes de começar, vamos entender os três tipos de cluster EKS que podemos ter:

- **Managed Node Groups**: Nesse tipo de cluster, os Nodes Workers são gerenciados pela AWS, ou seja, não precisaremos nos preocupar com eles. A AWS irá criar e gerenciar os Nodes Workers para nós. Esse tipo de cluster é ideal para quem não quer se preocupar com a administração dos Nodes Workers.
- **Self-Managed Node Groups**: Nesse tipo de cluster, os Nodes Workers são gerenciados por nós, ou seja, precisaremos criar e gerenciar os Nodes Workers. Esse tipo de cluster é ideal para quem quer ter o controle total sobre os Nodes Workers.
- **Fargate**: Nesse tipo de cluster, os Nodes Workers são gerenciados pela AWS, mas não precisaremos nos preocupar com eles, pois a AWS irá criar e gerenciar os Nodes Workers para nós. Esse tipo de cluster é ideal para quem não quer se preocupar com a administração dos Nodes Workers, mas também não quer se preocupar com a criação e gerenciamento dos Nodes Workers.


Evidentemente, cada tipo tem os seus prós e contras, e você precisa analisar o seu cenário para escolher o tipo de cluster que melhor se encaixa nas suas necessidades.

Na maioria dos casos de ambientes produtivos, iremos optar pelo tipo Self-Managed Node Groups, pois assim teremos o controle total sobre os Nodes Workers, podendo customiza-lo e gerencia-lo da forma que acharmos melhor. Agora, se você não quer se preocupar com a administração dos Nodes Workers, você pode optar pelo tipo Managed Node Groups ou Fargate.

Quando optamos pelo Fargate, temos que levar em consideração que não teremos acesso aos Nodes Workers, pois eles são gerenciados pela AWS. Isso significa menos liberdade e recursos, mas também significa menos preocupação e menos trabalho com a administração dos Nodes Workers.

Para o nosso exemplo, vamos escolher do tipo 'Managed Node Groups', pois assim não precisaremos nos preocupar com a administração dos Nodes Workers, mas lembre-se que você pode escolher o tipo que melhor se encaixa nas suas necessidades.

Para criar o cluster vamos utilizar o EKSCTL, que é uma ferramenta de linha de comando que nos ajuda a criar e gerenciar clusters EKS. Você pode encontrar mais informações sobre o EKSCTL [aqui](https://eksctl.io/).

Ela acabou se tornando uma das formas oficiais de criar e gerenciar clusters EKS, e é a ferramenta que eu mais utilizo para criar e gerenciar clusters EKS. Alias, acredito que seja a ferramenta mais utilizada para criar clusters EKS, quando não estamos utilizando alguma ferramenta de IaC, como o Terraform, por exemplo.


##### Instalando o EKSCTL

Para instalar o EKSCTL, você pode seguir as instruções [aqui](https://eksctl.io/installation/).

Ele está disponível para Linux, MacOS e Windows. Além de ser possível de rodar em um container Docker.

Em nosso exemplo, vamos utilizar o Linux, claro! hahaha

Para instalar o EKSCTL no Linux, você pode executar o seguinte comando:

```bash
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin
```

Eu literalmente copiei e colei o comando acima do site do EKSCTL, então não tem erro. Mas lembrando, sempre é bom consultar o site oficial para verificar se não houve nenhuma alteração.

Aqui estamos fazendo o seguinte:

- Definindo a arquitetura do nosso sistema, no meu caso, `amd64`. Você pode verificar a arquitetura do seu sistema executando o comando `uname -m`.
- Definindo a plataforma do nosso sistema, no meu caso, `Linux_amd64`. 
- Baixando o binário do EKSCTL.
- Descompactando o binário do EKSCTL.
- Movendo o binário do EKSCTL para o diretório `/usr/local/bin`.

Validando a instalação do EKSCTL:

```bash
eksctl version
```

A saída deve ser algo parecido com isso:

```bash
0.169.0
```

Essa é a versão do EKSCTL que estamos utilizando no momento de criação desse treinamento, mas você pode estar utilizando uma versão mais recente.

##### Instalando o AWS CLI

Agora que temos o EKSCTL instalado, precisamos ter o AWS CLI instalado e configurado, pois o EKSCTL utiliza o AWS CLI para se comunicar com a AWS. Você pode encontrar mais informações sobre o AWS CLI [aqui](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

O AWS CLI é uma ferramenta de linha de comando que nos ajuda a interagir com os serviços da AWS, ele é super poderoso e é uma das ferramentas mais utilizadas para interagir com os serviços da AWS.

Vou colar abaixo os comandos para instalar o AWS CLI no Linux, mas lembre-se, sempre é bom consultar o site oficial para verificar se não houve nenhuma alteração.

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Validando a instalação do AWS CLI:

```bash
aws --version
```

No meu caso, a versão que estou utilizando é a seguinte:

```bash
aws-cli/2.15.10 Python/3.11.6 Linux/6.5.0-14-generic exe/x86_64.zorin.17 prompt/off
```

Agora que temos o AWS CLI instalado, precisamos configurar o AWS CLI, para isso, você pode executar o seguinte comando:

```bash
aws configure
```

Aqui você precisa informar as suas credenciais da AWS, que você pode encontrar [aqui](https://console.aws.amazon.com/iam/home?#/securi
ty_credentials).

As informações que você precisa informar são:

- AWS Access Key ID
- AWS Secret Access Key
- Default region name
- Default output format

O seu Access Key ID e o Secret Access Key pode ser encontrados [aqui](https://console.aws.amazon.com/iam/home?#/security_credentials). Já a região fica a seu critero, eu vou utilizar a região `us-east-1`, mas você pode utilizar a região que preferir. E por fim, o formato de saída, eu vou utilizar o formato `json`, mas você pode utilizar outra opção, como `text`, por exemplo.



##### Criando o Cluster EKS

Agora que temos o AWS CLI instalado e configurado, podemos criar o nosso cluster EKS.

Podemos cria-lo através da linha de comando somente ou então podemos criar um arquivo de configuração para facilitar a criação do cluster.

Primeiro vou trazer o comando que iremos utilizar e na sequência vou explicar o que estamos fazendo e trazer o arquivo de configuração.

```bash
eksctl create cluster --name=eks-cluster --version=1.28 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

Aqui estamos fazendo o seguinte:

- `eksctl create cluster`: Comando para criar o cluster.
- `--name`: Nome do cluster.
- `--version`: Versão do Kubernetes que iremos utilizar, no meu caso, `1.28`.
- `--region`: Região onde o cluster será criado, no meu caso, `us-east-1`.
- `--nodegroup-name`: Nome do Node Group.
- `--node-type`: Tipo de instância que iremos utilizar para os Nodes Workers, no meu caso, `t3.medium`.
- `--nodes`: Quantidade de Nodes Workers que iremos criar, no meu caso, `2`.
- `--nodes-min`: Quantidade mínima de Nodes Workers que iremos criar, no meu caso, `1`.
- `--nodes-max`: Quantidade máxima de Nodes Workers que iremos criar, no meu caso, `3`.
- `--managed`: Tipo de Node Group que iremos utilizar, no meu caso, `managed`.


A saída do comando deve ser algo parecido com isso:

```bash
2024-01-26 16:12:39 [ℹ]  eksctl version 0.168.0
2024-01-26 16:12:39 [ℹ]  using region us-east-1
2024-01-26 16:12:40 [ℹ]  skipping us-east-1e from selection because it doesn't support the following instance type(s): t3.medium
2024-01-26 16:12:40 [ℹ]  setting availability zones to [us-east-1c us-east-1d]
2024-01-26 16:12:40 [ℹ]  subnets for us-east-1c - public:192.168.0.0/19 private:192.168.64.0/19
2024-01-26 16:12:40 [ℹ]  subnets for us-east-1d - public:192.168.32.0/19 private:192.168.96.0/19
2024-01-26 16:12:40 [ℹ]  nodegroup "eks-cluster-nodegroup" will use "" [AmazonLinux2/1.28]
2024-01-26 16:12:40 [ℹ]  using Kubernetes version 1.28
2024-01-26 16:12:40 [ℹ]  creating EKS cluster "eks-cluster" in "us-east-1" region with managed nodes
2024-01-26 16:12:40 [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
2024-01-26 16:12:40 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=eks-cluster'
2024-01-26 16:12:40 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "eks-cluster" in "us-east-1"
2024-01-26 16:12:40 [ℹ]  CloudWatch logging will not be enabled for cluster "eks-cluster" in "us-east-1"
2024-01-26 16:12:40 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=us-east-1 --cluster=eks-cluster'
2024-01-26 16:12:40 [ℹ]  
2 sequential tasks: { create cluster control plane "eks-cluster", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create managed nodegroup "eks-cluster-nodegroup",
    } 
}
2024-01-26 16:12:40 [ℹ]  building cluster stack "eksctl-eks-cluster-cluster"
2024-01-26 16:12:40 [ℹ]  deploying stack "eksctl-eks-cluster-cluster"
2024-01-26 16:13:10 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-cluster"
2024-01-26 16:13:41 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-cluster"
2024-01-26 16:14:41 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-cluster"
2024-01-26 16:24:48 [ℹ]  building managed nodegroup stack "eksctl-eks-cluster-nodegroup-eks-cluster-nodegroup"
2024-01-26 16:24:49 [ℹ]  deploying stack "eksctl-eks-cluster-nodegroup-eks-cluster-nodegroup"
2024-01-26 16:24:49 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-nodegroup-eks-cluster-nodegroup"
2024-01-26 16:27:40 [ℹ]  waiting for the control plane to become ready
2024-01-26 16:27:40 [✔]  saved kubeconfig as "/home/jeferson/.kube/config"
2024-01-26 16:27:40 [ℹ]  no tasks
2024-01-26 16:27:40 [✔]  all EKS cluster resources for "eks-cluster" have been created
2024-01-26 16:27:41 [ℹ]  nodegroup "eks-cluster-nodegroup" has 2 node(s)
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-55-232.ec2.internal" is ready
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-7-245.ec2.internal" is ready
2024-01-26 16:27:41 [ℹ]  waiting for at least 1 node(s) to become ready in "eks-cluster-nodegroup"
2024-01-26 16:27:41 [ℹ]  nodegroup "eks-cluster-nodegroup" has 2 node(s)
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-55-232.ec2.internal" is ready
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-7-245.ec2.internal" is ready
2024-01-26 16:27:42 [ℹ]  kubectl command should work with "/home/jeferson/.kube/config", try 'kubectl get nodes'
2024-01-26 16:27:42 [✔]  EKS cluster "eks-cluster" in "us-east-1" region is ready
```

Pronto, cluster deployado com sucesso! :D

Para vizualizar o nosso cluster, podemos executar o seguinte comando:

```bash
kubectl get nodes
```

A saída deve ser algo parecido com isso:

```bash
ip-192-168-22-217.ec2.internal   Ready    <none>   20m   v1.28.5-eks-5e0fdde
ip-192-168-50-0.ec2.internal     Ready    <none>   20m   v1.28.5-eks-5e0fdde
```

Agora vamos fazer o seguinte, vamos criar arquivo de configuração do EKSCTL para facilitar a criação do cluster da próxima vez. Para isso, vamos criar um arquivo chamado `eksctl.yaml` e adicionar o seguinte conteúdo:

```yaml
apiVersion: eksctl.io/v1alpha5 # Versão da API do EKSCTL
kind: ClusterConfig # Tipo de recurso que estamos criando

metadata: # Metadados do recurso
  name: eks-cluster # Nome do cluster
  region: us-east-1 # Região onde o cluster será criado

managedNodeGroups: # Node Groups que serão criados, estamos utilizando o tipo Managed Node Groups
- name: eks-cluster-nodegroup # Nome do Node Group
  instanceType: t3.medium # Tipo de instância que iremos utilizar para os Nodes Workers
  desiredCapacity: 2 # Quantidade de Nodes Workers que iremos criar
  minSize: 1 # Quantidade mínima de Nodes Workers que iremos criar
  maxSize: 3 # Quantidade máxima de Nodes Workers que iremos criar
```

Conforme você pode ver, estamos criando um cluster EKS com a mesma configuração que utilizamos anteriormente, mas agora estamos utilizando um arquivo de configuração para facilitar e deixar tudo mais bonitinho. :D

Para criar o cluster utilizando o arquivo de configuração, você pode executar o seguinte comando:

```bash
eksctl create cluster -f eksctl.yaml
```

A saída deve ser algo parecido com a que tivemos anteriormente, nada de novo para acrescentar aqui.

Pronto, agora que temos o nosso cluster EKS criado, vamos instalar o CNI da AWS e habilitar o Network Policy nas configurações avançadas do CNI.

##### Instalando o AWS VPC CNI Plugin

O AWS VPC CNI Plugin é um plugin de rede que permite que os Pods se comuniquem com outros Pods e serviços dentro do cluster. Ele também permite que os Pods se comuniquem com serviços fora do cluster, como o Amazon S3, por exemplo.

Vamos utilizar o EKSCTL para instalar o AWS VPC CNI Plugin, para isso, você pode executar o seguinte comando:

```bash
eksctl create addon --name vpc-cni --version v1.16.0-eksbuild.1 --cluster eks-cluster --force
```

Lembrando que você precisa substituir o nome do cluster e a versão do CNI pela versão do seu cluster.

Você pode verificar o link abaixo para verificar a versão do CNI que você precisa utilizar:

https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html

Você deve escolher a versão do CNI de acordo com a versão do Kubernetes que você está utilizando, então fique atento a isso.

Bem, voltando ao comando, o que estamos fazendo aqui é o seguinte:

- `eksctl create addon`: Comando para instalar um Addon no cluster.
- `--name`: Nome do Addon.
- `--version`: Versão do Addon.
- `--cluster`: Nome do cluster.
- `--force`: Forçar a instalação do Addon.


A saída deve ser algo parecido com isso:

```bash
2024-01-28 14:12:44 [!]  no IAM OIDC provider associated with cluster, try 'eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=eks-cluster'
2024-01-28 14:12:44 [ℹ]  Kubernetes version "1.28" in use by cluster "eks-cluster"
2024-01-28 14:12:44 [!]  OIDC is disabled but policies are required/specified for this addon. Users are responsible for attaching the policies to all nodegroup roles
2024-01-28 14:12:45 [ℹ]  creating addon
2024-01-28 14:13:49 [ℹ]  addon "vpc-cni" active
```

Apesar de ser o CNI padrão do EKS, ele não vem instalado por padrão, então precisamos instala-lo manualmente.

Caso queira visualizar os Addons instalados no seu cluster, você pode executar o seguinte comando:

```bash
eksctl get addon --cluster eks-cluster
```

A saída deve ser algo parecido com isso:

```bash
2024-01-28 14:16:44 [ℹ]  Kubernetes version "1.28" in use by cluster "eks-cluster"
2024-01-28 14:16:44 [ℹ]  getting all addons
2024-01-28 14:16:45 [ℹ]  to see issues for an addon run `eksctl get addon --name <addon-name> --cluster <cluster-name>`
NAME	VERSION			STATUS	ISSUES	IAMROLE	UPDATE AVAILABLE	CONFIGURATION VALUES
vpc-cni	v1.16.0-eksbuild.1	ACTIVE	0		v1.16.2-eksbuild.1	
```

Ou então acessar o console da AWS e verificar os Addons instalados no seu cluster, conforme a imagem abaixo:

![Alt text](images/image-1.png?raw=true "EKS Cluster")


Pronto, CNI instalado com sucesso! :D

##### Habilitando o Network Policy nas Configurações Avançadas do CNI

Agora que temos o CNI da AWS instalado, precisamos habilitar o Network Policy nas configurações avançadas do CNI, para isso, precisamos acessar o console da AWS e seguir os seguintes passos:

- Acessar o console da AWS.
- Acessar o serviço EKS.
- Selecionar o seu cluster.
- Selecionar a aba `Add-ons`.
- Selecionar o edit do Addon `vpc-cni`.
- Configuração Avançada do CNI.
- Habilitar o Network Policy.

![Alt text](images/image-2.png?raw=true "EKS Cluster")


Depois de alguns minutos, você pode acessar o Addon `vpc-cni` novamente e verificar se o Network Policy está habilitado e atualizado com o Network Policy habilitado.

![Alt text](images/image-3.png?raw=true "EKS Cluster")

Pronto, cluster configurado! Agora já podemos continuar com o nosso exemplo. :D


#### Instalando o Nginx Ingress Controller

### Instalando um Nginx Ingress Controller

Para que tudo funcione bem em nosso exemplo, vamos instalar o Nginx Ingress Controller. É importante observar a versão do Ingress Controller que você está instalando, pois as versões mais recentes ou mais antigas podem não ser compatíveis com o Kubernetes que você está usando. Para este tutorial, vamos usar a versão 1.9.5.
No seu terminal, execute os seguintes comandos:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
```

Verifique se o Ingress Controller foi instalado corretamente:

```bash
kubectl get pods -n ingress-nginx
```

Você pode utilizar a opção `wait` do `kubectl`, assim quando os pods estiverem prontos, ele irá liberar o shell, veja:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

Pronto, Ingress Controller instalado com sucesso! :D

Vamos seguir em frente e criar a nossa aplicação de exemplo.

#### Nossa Aplicação de Exemplo

Para que possamos brincar com as Network Policies, vamos utilizar uma aplicação de exemplo, o nosso já conhecido Giropops-Senhas. Essa aplicação é composta por uma aplicação Flask, e utiliza o Redis para armazenar as últimas senhas criadas. A aplicação Flask utiliza a porta 5000 e o Redis utiliza a porta 6379.
Para que nossos usuários possam ter acesso ao cluster, a nossa aplicação está exposta através de um Ingress Controller, que está configurado para utilizar o endereço `giropops-senhas.containers.expert`. Já o nosso Redis está exposto através de um Service do tipo ClusterIP, que está configurado para utilizar o endereço `redis-service.giropops.svc.cluster.local`. O endereço da nossa aplicação dentro do cluster é `giropops.giropops.svc.cluster.local`. Como podemos ver, temos 3 endereços diferentes para a nossa aplicação, e cada um deles é utilizado para um propósito diferente.

Vale lembrar que a nossa aplicação está rodando no namespace `giropops`.

Para que você possa fazer o deploy da nossa aplicação, vamos criar um arquivo chamado `giropops-deployment.yaml` com o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: giropops-senhas
  name: giropops-senhas
spec:
  replicas: 2
  selector:
    matchLabels:
      app: giropops-senhas
  template:
    metadata:
      labels:
        app: giropops-senhas
    spec:
      containers:
      - image: linuxtips/giropops-senhas:1.0
        name: giropops-senhas
        ports:
        - containerPort: 5000
        imagePullPolicy: Always
```

E para criar o nosso Service, vamos criar um arquivo chamado `giropops-service.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: giropops-senhas
spec:
  selector:
    app: giropops-senhas
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
  type: ClusterIP
```

Precisamos ainda do Redis, que vamos criar com o arquivo `redis-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - image: redis
        name: redis
        ports:
          - containerPort: 6379
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
```

E o Service do Redis, que vamos criar com o arquivo `redis-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
  type: ClusterIP
```

E por fim, vamos criar o nosso Ingress Controller, que vamos criar com o arquivo `giropops-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: giropops-senhas.containers.expert
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: giropops-senhas
            port:
              number: 5000
```

Vamos criar o namespace `giropops`:

```bash
kubectl create namespace giropops
```

Pronto, agora que temos todos os arquivos necessários, vamos fazer o deploy da nossa aplicação:

```bash
kubectl apply -f giropops-deployment.yaml -n giropops
kubectl apply -f giropops-service.yaml -n giropops
kubectl apply -f redis-deployment.yaml -n giropops
kubectl apply -f redis-service.yaml -n giropops 
kubectl apply -f giropops-ingress.yaml -n giropops
```

Vamos verificar se a nossa aplicação está rodando corretamente:

```bash
kubectl get pods -n giropops
```

Verifique se os Serviços e o Ingress Controller estão rodando corretamente:

```bash
kubectl get svc -n giropops
kubectl get ingress -n giropops
```

Parece que tudo está funcionando corretamente. Vamos testar a nossa aplicação:

```bash
curl giropops-senhas.containers.expert
```

Ahhhh, vale lembrar que o endereço `giropops-senhas.containers.expert` somente funcionará aqui no meu exemplo, pois eu já tenho o DNS configurado para esse endereço. Para que você possa testar a sua aplicação, você precisará adicionar o endereço da nossa aplicação no arquivo `/etc/hosts` do seu computador. Para isso, você precisa adicionar o seu endereço IP e o endereço `giropops-senhas.containers.expert` no arquivo `/etc/hosts`. Por exemplo:

```bash
192.168.100.10 giropops-senhas.containers.expert
```

Agora sim, vamos testar a nossa aplicação:

```bash
curl giropops-senhas.containers.expert
```

Você pode acessar o endereço `giropops-senhas.containers.expert` no seu navegador para verificar se a aplicação está funcionando corretamente.

Pronto, agora que temos a nossa aplicação rodando, vamos começar a brincar com as Network Policies.




### Criando Regras de Network Policy

#### Ingress

Em nosso exemplo, tanto a nossa aplicação quanto o Redis estão rodando no mesmo namespace, o namespace `giropops`. Por padrão, os Pods podem se comunicar livremente entre si. Vamos criar uma Network Policy para restringir o acesso ao Redis, permitindo que somente que pods do namespace `giropops` possam acessar o Redis.

Para isso, vamos criar o arquivo `permitir-redis-somente-mesmo-ns.yaml` com o seguinte conteúdo:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: redis-allow-same-namespace
  namespace: giropops
spec:
  podSelector:
    matchLabels:
      app: redis
  ingress:
  - from:
    - podSelector: {}
```

Vamos entender o que estamos fazendo aqui:

- `apiVersion`: Versão da API que estamos utilizando.
- `kind`: Tipo de recurso que estamos criando.
- `metadata`: Metadados do recurso.
  - `name`: Nome da Network Policy.
  - `namespace`: Namespace onde a Network Policy será criada.
- `spec`: Especificação da Network Policy.
  - `podSelector`: Seletor de Pods que serão afetados pela Network Policy.
    - `matchLabels`: Labels dos Pods que serão afetados pela Network Policy.
  - `ingress`: Regras de entrada.
    - `from`: Origem do tráfego.
      - `podSelector`: Seletor de Pods que podem acessar os Pods selecionados, nesse caso, todos os Pods do namespace `giropops`.

Sempre que tiver o `{}` significa que estamos selecionando todos os Pods que atendem aos critérios especificados, nesse caso, todos os Pods do namespace `giropops` pois não estamos especificando nenhum critério.


Vamos aplicar a nossa Network Policy:

```bash
kubectl apply -f permitir-redis-somente-mesmo-ns.yaml -n giropops
```

Vamos testar o acesso ao Redis a partir de um Pod fora do namespace `giropops`, para isso vamos user o comando `redis ping`:

```bash
kubectl run -it --rm --image redis redis-client -- redis-cli -h redis-service.giropops.svc.cluster.local ping
```

Se tudo estiver funcionando corretamente, você não receberá nenhuma resposta, pois o acesso ao Redis está bloqueado para Pods fora do namespace `giropops`.

Agora, se você executar o mesmo comando, porém de dentro da Namespace `giropops`, você deverá receber a mensagem `PONG`, pois o acesso ao Redis está permitido para Pods dentro do namespace `giropops`! :D

Vamos testar:

```bash
kubectl run -it --rm -n giropops --image redis redis-client -- redis-cli -h redis-service.giropops.svc.cluster.local ping
```

A saída deve ser algo parecido com isso:

```bash
If you don't see a command prompt, try pressing enter.

PONG
Session ended, resume using 'kubectl attach redis-client -c redis-client -i -t' command when the pod is running
pod "redis-client" deleted
```

Pronto, agora que temos a nossa Network Policy funcionando!

Agora vamos queremos bloquear todo o acesso de entrada para os Pods do namespace `giropops`, para isso, vamos criar o arquivo `nao-permitir-nada-externo.yaml` com o seguinte conteúdo:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

O que mudou aqui foi o seguinte:

- `policyTypes`: Tipo de política que estamos criando, nesse caso, estamos criando uma política de entrada.
- `ingress`: Regras de entrada.
  - `from`: Origem do tráfego.
    - `namespaceSelector`: Seletor de Namespaces que podem acessar os Pods selecionados, nesse caso, somente o namespace `giropops`.
    - `matchLabels`: Labels dos Namespaces que podem acessar os Pods selecionados, nesse caso, somente o namespace `giropops`.
    - `kubernetes.io/metadata.name`: Nome do Namespace.
    - `giropops`: Valor do Nome do Namespace.

Simples, assim, estamos bloqueando todo o tráfego de entrada para os Pods do namespace `giropops`, menos para os Pods do próprio namespace `giropops`.

Vamos aplicar a nossa Network Policy:

```bash
kubectl apply -f nao-permitir-nada-externo.yaml -n giropops
```

Vamos testar o acesso ao Redis a partir de um Pod fora do namespace `giropops`, para isso vamos user o comando `redis ping`:

```bash
kubectl run -it --rm --image redis redis-client -- redis-cli -h redis-service.giropops.svc.cluster.local ping
```

Nada de novo, certo, porém vamos testar o acesso a nossa aplicação a partir de um Pod fora do namespace `giropops`, para isso vamos user o comando `curl`:

```bash
kubectl run -it --rm --image curlimages/curl curl-client -- curl giropops-senhas.giropops.svc
```

Se tudo estiver funcionando corretamente, você não receberá nenhuma resposta, pois o acesso a nossa aplicação está bloqueado para Pods fora do namespace `giropops`.

Agora, se você executar o mesmo comando, porém de dentro da Namespace `giropops`, você deverá receber a mensagem `Giropops Senhas`, pois o acesso a nossa aplicação está permitido para Pods dentro do namespace `giropops`! :D

Vamos testar:

```bash
kubectl run -it --rm -n giropops --image curlimages/curl curl-client -- curl giropops-senhas.giropops.svc
```

Tudo funcionando maravilhosamente bem! De dentro do mesmo namespace, podemos acessar a nossa aplicação e o Redis, mas de fora do namespace, não podemos acessar nada! :D

Mas com isso temos um problema, pois o nosso Ingress Controller não consegue acessar a nossa aplicação, pois ele está fora do namespace `giropops`, então vamos criar uma Network Policy para permitir o acesso ao nosso Ingress Controller.

Para isso, vamos criar o arquivo `permitir-ingress-controller.yaml` com o seguinte conteúdo:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns-and-ingress-controller
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Aqui a solução foi super simples, pois somente adicionamos mais um seletor de Namespaces, para permitir o acesso ao nosso Ingress Controller. Com isso, tudo que estiver dentro do namespace `ingress-nginx` e `giropops` poderá acessar os Pods do namespace `giropops`.

Aqui poderiamos ter uma melhoria no código utilizando o matchExpressions, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns-and-ingress-controller
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: In
          values: ["ingress-nginx", "giropops"]
```

O resultado seria o mesmo, porém o código ficaria mais limpo e mais fácil de entender.

Agora pode testar o acesso a nossa aplicação a partir de um Pod fora do namespace `giropops`, para isso vamos user o comando `curl`:

```bash
kubectl run -it --rm --image curlimages/curl curl-client -- curl giropops-senhas.giropops.svc
```

Aqui você não conseguirá acessar a nossa aplicação, pois o acesso a nossa aplicação está bloqueado para Pods fora do namespace `giropops`, agora se você executar o mesmo comando, porém de dentro da Namespace `giropops`, tudo funcionará bem!

Porém, sempre que você utilizar o endereço do Ingress da nossa aplicação, você conseguirá normalmente, pois liberamos o acesso ao nosso Ingress Controller, portanto os clientes da nossa app que acessarão via internet, conseguirão acessar normalmente, porém Pods fora do namespace `giropops` não conseguirão acessar a nossa aplicação. Lindo não é mesmo? :D

Somente uma observação importante:

```yaml
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Um coisa que deve ser bem entendido no momento de criar as suas regras são os operadores lógicos, pois eles podem mudar completamente o resultado da sua Network Policy. No nosso exemplo, estamos utilizando o operador lógico `OR`, ou seja, estamos permitindo o acesso ao nosso Ingress Controller OU ao nosso namespace `giropops`. 

Se você quiser permitir o acesso ao nosso Ingress Controller E ao nosso namespace `giropops`, você deve utilizar o operador lógico `AND`, veja:

```yaml
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Nesse caso a regra funcionará da seguinte forma, somente os Pods que estiverem dentro do namespace `ingress-nginx` E do namespace `giropops` poderão acessar os Pods do namespace `giropops`, ou seja, teriamos problemas.

Teste aí e veja o que acontece. :D

Nós podemos ter uma abortagem diferente, podemos ter um regra que irá bloquear todo o tráfego de entrada, e depois criar regras para permitir o tráfego de entrada para os Pods que precisam, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

Agora estamos bloqueando todo o tráfego de entrada para os Pods do namespace `giropops`, pois estamos utilizando o `ingress: []` para bloquear todo o tráfego de entrada. Mais uma vez, estamos usando o `[]` vazio para selecionar todos os Pods e bloquear todo o tráfego de entrada, pois não estamos especificando nenhum critério.
O policyTypes é um campo obrigatório, e nele você deve especificar o tipo de política que você está criando, nesse caso, estamos criando uma política de entrada e saída, por isso estamos utilizando o `Ingress` e o `Egress`.


Vamos aplicar:
  
```bash
kubectl apply -f deny-all-ingress.yaml -n giropops
```

Agora vamos criar uma regra para que a nossa App consiga acessar o Redis, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-redis-app-only
  namespace: giropops
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: giropops-senhas
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
    ports:
    - protocol: TCP
      port: 6379
```

Com isso temos mais um regra para permitir o acesso ao Redis e a App somente entre eles e somente nas portas 6379 e 5000.

Vamos aplicar:

```bash
kubectl apply -f permitir-somente-ingress-entre-app-redis-mesmo-ns.yaml -n giropops
```

Pronto, fizemos mais uma camada de segurança, agora somente a nossa aplicação pode acessar o Redis, e somente nas portas 6379 e 5000, mas ainda temos um problema, pois o nosso Ingress Controller não consegue acessar a nossa aplicação, e com isso, nossos clientes não irão conseguir acessar a nossa aplicação, então vamos criar uma Network Policy para permitir o acesso ao nosso Ingress Controller, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 5000
```

Pronto, agora o nosso Ingress Controller consegue acessar a nossa aplicação, e com isso, nossos clientes também conseguem acessar a nossa aplicação! 

Outra opção bem interessante de utilizar é o `ipBlock`, com ele você pode especificar um endereço IP ou um CIDR para permitir o acesso, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ip-block
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.18.0.0/16
```

Com a regra acima estamos falando que nós queremos permitir o acesso somente para o range de IPs dentro do CIDR `172.18.0.0/16`, ou seja, somente os Pods que estiverem dentro desse range de IPs poderão acessar os Pods do namespace `giropops`.

Ainda podemos adionar uma regra de exceção, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ip-block
  namespace: giropops
spec:
  policyTypes:
  - Ingress
  podSelector: {}
  ingress:
  - from:
    - ipBlock:
        cidr: 172.18.0.0/16
        except:
        - 172.18.0.112/32
```

Com a regra acima, toda a rede `172.18.0.0/16` terá acesso, menos o IP `172.18.0.112` que não terá acesso aos Pods do namespace `giropops`.

Nós criamos um monte de Network Policies, mas não nos concentramos em entender como ver se elas estão criadas e seus detalhes, então vamos ver como podemos fazer isso.

Para visualizar as Network Policies que estão criadas no seu cluster, você pode executar o seguinte comando:

```bash
kubectl get networkpolicies -n giropops
```

Para ver os detalhes de uma Network Policy, você pode executar o seguinte comando:

```bash
kubectl describe networkpolicy <nome-da-network-policy> -n giropops
```

Para deletar uma Network Policy, você pode executar o seguinte comando:

```bash
kubectl delete networkpolicy <nome-da-network-policy> -n giropops
```

Simples como voar, não?


#### Egress

Nós falamos muito como criar regras de Ingres, ou seja, regras de entrada, mas e as regras de saída? Como podemos criar regras de saída?

Para isso temos o `egress`, que é muito parecido com o `ingress`, mas com algumas diferenças, veja:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Egrees
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

Com a regra acima, estamos liberando o acesso para os Pods que atendem aos critérios especificados, nesse caso, somente os Pods que tiverem o label `app: redis` poderão acessar os Pods do namespace `giropops` na porta 6379. Com isso, todos os Pods da namespace `giropops` poderão acessar os Pods que tiverem o label `app: redis` na porta 6379.

Agora, se quisermos que somente a nossa aplicação possa acessar o Redis, podemos fazer o seguinte:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-only-app
  namespace: giropops
spec:
  policyTypes:
  - Egrees
  podSelector: 
    matchLabels:
      app: giropops-senhas
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

Com a regra acima, somente a nossa aplicação poderá acessar o Redis, pois estamos utilizando o `podSelector` para selecionar somente os Pods que tiverem o label `app: giropops-senhas`, ou seja, somente a nossa aplicação poderá acessar o Redis.

Simples demais!