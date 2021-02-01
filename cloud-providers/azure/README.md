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
