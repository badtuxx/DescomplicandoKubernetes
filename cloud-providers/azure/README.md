> Esta documentação foi baseada na live #AULAOKUBERNETES realizado no YouTube no canal da LINUXtips #VAIIII

Esta documentação tem como objetivo descrever como é feito a criação e a configuração de um cluster com Kubernetes rodando no Azure AKS.

# Pré-requisitos

Para configurar um cluster do zero na Azure através do AKS, é necessário ter uma conta na Azure. Caso não tenha, pode estar criando no link abaixo:

> https://azure.microsoft.com/en-us/free/

Você pode estar criando uma conta para testar os serviços de forma gratuita, válida por 12 meses.

# Configurando o ambiente

## Instalando o Azure CLI

Primeiro, instale o azure-cli na sua máquina através do link abaixo:

> https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

Você poderá escolher qual sistema operacional deseja instalar o azure-cli. Basta clicar no link do respectivo sistema operacional, que será redirecionado para a página de instalação. Caso você esteja utilizando linux, basta instalar com o curl. Simples e rápido.

## Configurando o Azure CLI

Com o azure-cli instalado e sua conta já criada, precisamos agora fazer o login do azure por linha de comando. Abra seu terminal e rode o seguinte comando:

```
$ az login
```

Este comando, irá fazer com que você se autentique com sua conta do Azure, podendo assim utilizar os serviços providos por eles. O comando abrirá uma página no navegador para que você realize o login. Então, basta você preencher os campos com seu usuário e senha correspondentes da conta Azure. Ao efetuar o login, será informado uma série de informações sobre a sua conta como o seu ID da conta, o nome da conta (exemplo: “Free-Trial”), o estado (exemplo: “Enable”), informações do nome do usuário, entre outras.

## Instalando o Helm

Helm é um gerenciador de pacotes do Kubernetes que vamos utilizar neste tutorial. A instalação do Helm é simples, basta executar o comando curl no seu terminal:

```
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

Para mais informações sobre o Helm basta acessar a [página oficial](https://helm.sh/).

# Criação do Cluster

> Referência: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

## Criando Resource Group

Inicie a criação do cluster criando um grupo de recursos informando o nome e a localização. No exemplo abaixo foi criado um resource group com o nome LIVE indicando a localização nos Estados Unidos.

```
$ az group create --name LIVE --location eastus
```

Comando executado deverá retornar um json que traz uma série de informações sobre o resource group criado, como o id, location, name, entre outros.

## Criando Cluster AKS

Para criar o cluster utilizando o AKS da Azure, basta rodar o comando abaixo:

```
$ az aks create --resource-group LIVE \
                --name LIVE-AKS \
                --node-count 2 \
                --enable-addons monitoring \
                --generate-ssh-keys
```

O comando ```az aks create``` precisa ser informado uma série de parâmetros. No ```resource-group``` é informado o nome do grupo já existente no cluster. O ```name``` é o nome do cluster que será criado. Para o parâmetro ```node-count``` é necessário passar a quantidade de nós que serão criados para o cluster, neste exemplo foi utilizado apenas dois. No parâmetro ```enable-addons``` é interessante ressaltar que ao ativá-lo, será possível visualizar e monitorar o cluster na plataforma Azure. Por fim, é informado o ```generate-ssh-keys``` para termos acesso.

Vai levar um tempinho até finalizar, então basta aguardar até finalizar a instalação. Quando finalizado, irá retornar um json contendo diversas informações do cluster.

> ps: Quando realizei esta etapa acompanhando a live, ocorreu um erro bem específico quando tentei criar com três nodes. O comando retornou uma mensagem "BadRequestError" na qual dizia que existe uma “cota”, um limite de núcleos por região. Então acabei preferindo diminuir a quantidade de nodes. Porém depois descobri que poderia só ter trocado de região.

# Configuração do Cluster

> Referência: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster

## Instalando as dependências

Agora que você tem o seu cluster criado e rodando bonitinho, já podemos iniciar a configuração. O primeiro passo é instalar o kubectl para gerenciar o cluster com Kubernetes. Para instalar basta rodar o comando abaixo:

```
$ sudo az aks install-cli
```

## Gerenciando a conexão com o Cluster

Como o cluster está rodando na nuvem, precisamos buscar as credenciais deste cluster para gerenciar de forma remota. Para isso, basta rodar o comando “az aks get-credentials”, informando o nome do resource group através do parâmetro “--resource-group” e o nome do seu cluster através do parâmetro “--name”. Exemplo do comando:

```
$ az aks get-credentials --resource-group LIVE --name LIVE-AKS
```

Este comando irá adicionar as credenciais do cluster criado no seu arquivo de configuração na sua máquina.

## Listando todos os nodes

Para verificar se toda a configuração foi realizada com sucesso, podemos listar os nodes criados no nosso cluster. Para isso, basta acessar seu terminal e executar o comando abaixo:

```
$ kubectl get nodes
```

Este comando irá retornar as informações dos nodes criados no cluster, contendo o nome de cada node, o status, o tempo em que o node está de pé, entre outros dados interessantes.
