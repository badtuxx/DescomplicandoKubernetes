# Descomplicando o Kubernetes
## DAY-16: Descomplicando Helm

## Conteúdo do Day-16

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-16: Descomplicando Helm](#day-16-descomplicando-helm)
  - [Conteúdo do Day-16](#conteúdo-do-day-16)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
    - [O que é o Helm?](#o-que-é-o-helm)
    - [O que é um Chart?](#o-que-é-um-chart)
    - [Criando o nosso primeiro Chart](#criando-o-nosso-primeiro-chart)
      - [Instalando o nosso Chart](#instalando-o-nosso-chart)
      - [Atualizando o nosso Chart](#atualizando-o-nosso-chart)
      - [Utilizando `range`  e o `if` no Helm](#utilizando-range--e-o-if-no-helm)
      - [Utilizando `default`, `toYaml` e `toJson` no Helm](#utilizando-default-toyaml-e-tojson-no-helm)
      - [O Que São Helpers no Helm?](#o-que-são-helpers-no-helm)
        - [Por Que Usar Helpers?](#por-que-usar-helpers)
        - [Criando o Nosso Primeiro Helper](#criando-o-nosso-primeiro-helper)
        - [Helpers Avançados: Exemplos Práticos](#helpers-avançados-exemplos-práticos)
          - [Exemplo 1: Controlando a Complexidade](#exemplo-1-controlando-a-complexidade)
          - [Exemplo 2: Personalização Baseada em Ambiente](#exemplo-2-personalização-baseada-em-ambiente)
        - [Melhores Práticas ao Usar Helpers](#melhores-práticas-ao-usar-helpers)
      - [Criando o `_helpers.tpl` da nossa App](#criando-o-_helperstpl-da-nossa-app)
        - [Passo 1: Criando o arquivo `_helpers.tpl`](#passo-1-criando-o-arquivo-_helperstpl)
          - [Labels](#labels)
          - [Resources](#resources)
          - [Ports](#ports)
      - [Passo 2: Refatorando `Deployments.yaml` e `Services.yaml`](#passo-2-refatorando-deploymentsyaml-e-servicesyaml)
          - [O nosso `Deployments.yaml`](#o-nosso-deploymentsyaml)
          - [O nosso `Services.yaml`](#o-nosso-servicesyaml)
      - [Passo 3: Refatorando os ConfigMaps](#passo-3-refatorando-os-configmaps)
        - [Atualizando o `_helpers.tpl`](#atualizando-o-_helperstpl)
        - [Refatorando `config-map-dp.yaml`](#refatorando-config-map-dpyaml)
        - [Refatorando `config-map-obs.yaml`](#refatorando-config-map-obsyaml)
      - [Criando um repositório de Helm Charts](#criando-um-repositório-de-helm-charts)
        - [Criando o repositório no Github](#criando-o-repositório-no-github)
        - [Inicializando o repositório](#inicializando-o-repositório)
        - [Configurando o GitHub Pages](#configurando-o-github-pages)
      - [Utilizando o nosso repositório de Helm Charts](#utilizando-o-nosso-repositório-de-helm-charts)
      - [O que vimos no dia de hoje](#o-que-vimos-no-dia-de-hoje)

## O que iremos ver hoje?

Hoje é dia de falar sobre uma peça super importante quando estamos falando sobre como gerenciar aplicações no Kubernetes. O Helm é um gerenciador de pacotes para Kubernetes que facilita a definição, instalação e atualização de aplicações complexas no Kubernetes.

Durante o dia de hoje, nós iremos descomplicar de uma vez por todas as suas dúvidas no momento de utilizar o Helm para gerencia de aplicações no Kubernetes.

Bora!

### O que é o Helm?

O Helm é um gerenciador de pacotes para Kubernetes que facilita a definição, instalação e atualização de aplicações complexas no Kubernetes. Com ele você pode definir no detalhe como a sua aplicação será instalada, quais configurações serão utilizadas e como será feita a atualização da aplicação.

Mas para que você possa utilizar o Helm, a primeira coisa é fazer a sua instalação. Vamos ver como realizar a instalação do Helm na sua máquina Linux.

Lembrando que o Helm é um projeto da CNCF e é mantido pela comunidade, ele funciona em máquinas Linux, Windows e MacOS.

Para realizar a instalação no Linux, podemos utilizar diferentes formas, como baixar o binário e instalar manualmente, utilizar o gerenciador de pacotes da sua distribuição ou utilizar o script de instalação preparado pela comunidade.

Vamos ver como realizar a instalação do Helm no Linux utilizando o script de instalação, mas fique a vontade de utilizar a forma que você achar mais confortável, e tire todas as suas dúvidas no site da documentação oficial do Helm.

Para fazer a instalação, vamos fazer o seguinte:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

Com o comando acima, você irá baixar o script de instalação utilizando o curl, dar permissão de execução para o script e executar o script para realizar a instalação do Helm na sua máquina.

A saída será algo assim:
  
```bash
Downloading https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
```

Vamos ver se a instalação foi realizada com sucesso, executando o comando `helm version`:

```bash
helm version
```

No meu caso, no momento de criação desse material eu tenho a seguinte saída:

```bash
version.BuildInfo{Version:"v3.14.0", GitCommit:"3fc9f4b2638e76f26739cd77c7017139be81d0ea", GitTreeState:"clean", GoVersion:"go1.21.5"}
```

Pronto, agora que já temos o Helm instalado, já podemos começar a nossa brincadeira.

Durante o dia de hoje, eu quero ensinar o Helm de uma maneira diferente do que estamos acostumados a ver por aí. Vamos focar inicialmente na criação de Charts, e depois vamos ver como instalar e atualizar aplicações utilizando o Helm, de uma maneira mais natural e prática.

### O que é um Chart?

Um Chart é um pacote que contém informações necessárias para criar instâncias de aplicações Kubernetes. É com ele que iremos definir como a nossa aplicação será instalada, quais configurações serão utilizadas e como será feita a atualização da aplicação.

Um Chart, normalmente é composto por um conjunto de arquivos que definem a aplicação, e um conjunto de templates que definem como a aplicação será instalada no Kubernetes.

Vamos parar de falar e vamos criar o nosso primeiro Chart, acho que ficará mais fácil de entender.

### Criando o nosso primeiro Chart

Para o nosso exemplo, vamos usar novamente a aplicação de exemplo chamada Giropops-Senhas, que é uma aplicação que gera senhas aleatórias que criamos durante uma live no canal da LINUXtips.

Ela é uma aplicação simples, é uma aplicação em Python, mas especificamente uma aplicação Flask, que gera senhas aleatórias e exibe na tela. Ela utiliza um Redis para armazenar temporariamente as senhas geradas.

Simples como voar!

A primeira coisa que temos que fazer é clonar o repositório da aplicação, para isso, execute o comando abaixo:

```bash
git clone git@github.com:badtuxx/giropops-senhas.git
```

Com isso temos um diretório chamado `giropops-senhas` com o código da aplicação, vamos acessa-lo:

```bash
cd giropops-senhas
```

O conteúdo do diretório é o seguinte:

```bash
app.py  LICENSE  requirements.txt  static  tailwind.config.js  templates
```

Pronto, o nosso repo já está clonado, agora vamos começar com o nosso Chart.

A primeira coisa que iremos fazer, somente para facilitar o nosso entendimento, é criar os manifestos do Kubernetes para a nossa aplicação. Vamos criar um Deployment e um Service para o Giropops-Senhas e para o Redis.

Vamos começar com o Deployment do Redis, para isso, crie um arquivo chamado `redis-deployment.yaml` com o seguinte conteúdo:

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

Agora vamos criar o Service do Redis, para isso, crie um arquivo chamado `redis-service.yaml` com o seguinte conteúdo:

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

Agora vamos criar o Deployment do Giropops-Senhas, para isso, crie um arquivo chamado `giropops-senhas-deployment.yaml` com o seguinte conteúdo:

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
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
```

E finalmente, vamos criar o Service do Giropops-Senhas, para isso, crie um arquivo chamado `giropops-senhas-service.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: giropops-senhas
  labels:
    app: giropops-senhas
spec:
  selector:
    app: giropops-senhas
  ports:
    - protocol: TCP
      port: 5000
      nodePort: 32500
      targetPort: 5000
      name: tcp-app
  type: NodePort
```

Manifesos criados! Perceba que não temos nada de novo até agora, somente criamos os manifestos do Kubernetes para a nossa aplicação como já fizemos anteriormente.

Mas o pq eu fiz isso? Simples, para que você possa entender que um Chart é basicamente isso, um conjunto de manifestos do Kubernetes que definem como a sua aplicação será instalada no Kubernetes.

E você deve estar falando: Esse Jeferson está de brincadeira, pois eu já sei como fazer isso, cadê a novidade? Cadê o Helm? Calma calabrezo! :D

Bem, a ideia de criar os manifestos é somente para nos guiar durante a criação do nosso Chart.

Com os arquivos para nos ajudar, vamos criar o nosso Chart.


Para criar o nosso Chart, poderiamos utilizar o comando `helm create`, mas eu quero fazer de uma maneira diferente, quero criar o nosso Chart na mão, para que você possa entender como ele é composto, e depois voltamos para o `helm create` para criar os nossos próximos Charts.

Bem, a primeira coisa que temos que fazer é criar um diretório para o nosso Chart, vamos criar um diretório chamado `giropops-senhas-chart`:

```bash
mkdir giropops-senhas-chart
```

Agora vamos acessar o diretório:

```bash
cd giropops-senhas-chart
```

Bem, agora vamos começar a criar a nossa estrutura de diretórios para o nosso Chart, e o primeiro cara que iremos criar é o Chart.yaml, que é o arquivo que contém as informações sobre o nosso Chart, como o nome, a versão, a descrição, etc.

Vamos criar o arquivo Chart.yaml com o seguinte conteúdo:

```yaml
apiVersion: v2
name: giropops-senhas
description: Esse é o chart do Giropops-Senhas, utilizados nos laboratórios de Kubernetes.
version: 0.1.0
appVersion: 0.1.0
sources:
  - https://github.com/badtuxx/giropops-senhas
```

Nada de novo até aqui, somente criamos o arquivo Chart.yaml com as informações sobre o nosso Chart. Agora vamos para o nosso próximo passo, criar o diretório `templates` que é onde ficarão os nossos manifestos do Kubernetes.

Vamos criar o diretório `templates`:

```bash
mkdir templates
```

Vamos mover os manifestos que criamos anteriormente para o diretório `templates`:

```bash
mv ../redis-deployment.yaml templates/
mv ../redis-service.yaml templates/
mv ../giropops-senhas-deployment.yaml templates/
mv ../giropops-senhas-service.yaml templates/
```

Vamos deixar eles quietinhos lá por enquanto, e vamos criar o próximo arquivo que é o `values.yaml`. Esse é uma peça super importante do nosso Chart, pois é nele que iremos definir as variáveis que serão utilizadas nos nossos manifestos do Kubernetes, é nele que o Helm irá se basear para criar os manifestos do Kubernetes, ou melhor, para renderizar os manifestos do Kubernetes.

Quando criamos os manifestos para a nossa App, nós deixamos ele da mesma forma como usamos para criar os manifestos do Kubernetes, mas agora, com o Helm, nós podemos utilizar variáveis para definir os valores que serão utilizados nos manifestos, e é isso que iremos fazer, e é isso que é uma das mágicas do Helm.

Vamos criar o arquivo `values.yaml` com o seguinte conteúdo:

```yaml
giropops-senhas:
  name: "giropops-senhas"
  image: "linuxtips/giropops-senhas:1.0"
  replicas: "3"
  port: 5000
  labels:
    app: "giropops-senhas"
    env: "labs"
    live: "true"
  service:
    type: "NodePort"
    port: 5000
    targetPort: 5000
    name: "giropops-senhas-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"

redis:
  image: "redis"
  replicas: 1
  port: 6379
  labels:
    app: "redis"
    env: "labs"
    live: "true"
  service:
    type: "ClusterIP"
    port: 6379
    targetPort: 6379
    name: "redis-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"
```

Não confunda o arquivo acima com os manifestos do Kubernetes, o arquivo acima é apenas algumas definições que iremos usar no lugar das variáveis que defineremos nos manifestos do Kubernetes.

Precisamos entender como ler o arquivo acima, e é bem simples, o arquivo acima é um arquivo YAML, e nele temos duas chaves, `giropops-senhas` e `redis`, e dentro de cada chave temos as definições que iremos utilizar, por exemplo:

- `giropops-senhas`:
  - `image`: A imagem que iremos utilizar para o nosso Deployment
  - `replicas`: A quantidade de réplicas que iremos utilizar para o nosso Deployment
  - `port`: A porta que iremos utilizar para o nosso Service
  - `labels`: As labels que iremos utilizar para o nosso Deployment
  - `service`: As definições que iremos utilizar para o nosso Service
  - `resources`: As definições de recursos que iremos utilizar para o nosso Deployment
- `redis`:
  - `image`: A imagem que iremos utilizar para o nosso Deployment
  - `replicas`: A quantidade de réplicas que iremos utilizar para o nosso Deployment
  - `port`: A porta que iremos utilizar para o nosso Service
  - `labels`: As labels que iremos utilizar para o nosso Deployment
  - `service`: As definições que iremos utilizar para o nosso Service
  - `resources`: As definições de recursos que iremos utilizar para o nosso Deployment

E nesse caso, caso eu queira usar o valor que está definido para `image`, eu posso utilizar a variável `{{ .Values.giropops-senhas.image }}` no meu manifesto do Kubernetes, onde:

- {{ Values }}: É a variável que o Helm utiliza para acessar as variáveis que estão definidas no arquivo `values.yaml`, e o resto é a chave que estamos acessando.

Entendeu? Eu sei que é meu confuso no começo, mas treinando irá ficar mais fácil.

Vamos fazer um teste rápido, como eu vejo o valor da porta que está definida para o Service do Redis?

Pensou?

Já sabemos que temos que começar com .Values, para representar o arquivo `values.yaml`, e depois temos que acessar a chave `redis`, e depois a chave `service`, e depois a chave `port`, então, o valor que está definido para a porta que iremos utilizar para o Service do Redis é `{{ .Values.redis.service.port }}`.

Sempre você tem que respeitar a indentação do arquivo `values.yaml`, pois é ela que define como você irá acessar as chaves, certo?

Dito isso, já podemos começar a substituir os valores do que está definido nos manifestos do Kubernetes pelos valores que estão definidos no arquivo `values.yaml`. Iremos sair da forma estática para a forma dinâmica, é o Helm em ação!

Vamos começar com o arquivo `redis-deployment.yaml`, e vamos substituir o que está definido por variáveis, e para isso, vamos utilizar o seguinte conteúdo:

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
      - image: {{ .Values.redis.image }}
        name: redis
        ports:
          - containerPort: {{ .Values.redis.port }}
        resources:
          limits:
            memory: {{ .Values.redis.resources.limits.memory }}
            cpu: {{ .Values.redis.resources.limits.cpu }}
          requests:
            memory: {{ .Values.redis.resources.requests.memory }}
            cpu: {{ .Values.redis.resources.requests.cpu }}
```

Veja que estamos usando e abusando das variáveis que estão definidas no arquivo `values.yaml`, agora vou explicar o que estamos fazendo:
```yaml
- `image`: Estamos utilizando a variável `{{ .Values.redis.image }}` para definir a imagem que iremos utilizar para o nosso Deployment
- `name`: Estamos utilizando a variável `{{ .Values.redis.name }}` para definir o nome que iremos utilizar para o nosso Deployment
- `replicas`: Estamos utilizando a variável `{{ .Values.redis.replicas }}` para definir a quantidade de réplicas que iremos utilizar para o nosso Deployment
- `resources`: Estamos utilizando as variáveis `{{ .Values.redis.resources.limits.memory }}`, `{{ .Values.redis.resources.limits.cpu }}`, `{{ .Values.redis.resources.requests.memory }}` e `{{ .Values.redis.resources.requests.cpu }}` para definir as definições de recursos que iremos utilizar para o nosso Deployment.
```

Com isso, ele irá utilizar os valores que estão definidos no arquivo `values.yaml` para renderizar o nosso manifesto do Kubernetes, logo, quando precisar alterar alguma configuração, basta alterar o arquivo `values.yaml`, e o Helm irá renderizar os manifestos do Kubernetes com os valores definidos.

Vamos fazer o mesmo para os outros manifestos do Kubernetes, e depois vamos ver como instalar a nossa aplicação utilizando o Helm.

Vamos fazer o mesmo para o arquivo `redis-service.yaml`:

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
      port: {{ .Values.redis.service.port }}
      targetPort: {{ .Values.redis.service.port }}
  type: {{ .Values.redis.service.type }}
```

E para o arquivo `giropops-senhas-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: giropops-senhas
  name: giropops-senhas
spec:
  replicas: {{ .Values.giropops-senhas.replicas }}
  selector:
    matchLabels:
      app: giropops-senhas
  template:
    metadata:
      labels:
        app: giropops-senhas
    spec:
      containers:
      - image: {{ .Values.giropops-senhas.image }}
        name: giropops-senhas
        ports:
        - containerPort: {{ .Values.giropops-senhas.service.port }}
        imagePullPolicy: Always
        resources:
          limits:
            memory: {{ .Values.giropops-senhas.resources.limits.memory }}
            cpu: {{ .Values.giropops-senhas.resources.limits.cpu }}
          requests:
            memory: {{ .Values.giropops-senhas.resources.requests.memory }}
            cpu: {{ .Values.giropops-senhas.resources.requests.cpu }}
```

E para o arquivo `giropops-senhas-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: giropops-senhas
  labels:
    app: giropops-senhas
spec:
  selector:
    app: giropops-senhas
  ports:
    - protocol: TCP
      port: {{ .Values.giropops-senhas.service.port }}
      nodePort: {{ .Values.giropops-senhas.service.nodePort }}
      targetPort: {{ .Values.giropops-senhas.service.port }}
  type: {{ .Values.giropops-senhas.service.type }}
```

Agora já temos todos os nosso manifestos mais dinâmicos, e portanto já podemos chama-los de Templates, que é o nome que o Helm utiliza para os manifestos do Kubernetes que são renderizados utilizando as variáveis.

Ahhh, temos que criar um diretório chamado `charts` para que o Helm possa gerenciar as dependências do nosso Chart, mas como não temos dependências, podemos criar um diretório vazio, vamos fazer isso:

```bash
mkdir charts
```

Pronto, já temos o nosso Chart criado!

Agora vamos testa-lo para ver se tudo está funcionando como esperamos.

#### Instalando o nosso Chart

Para que possamos utilizar o nosso Chart, precisamos utilizar o comando `helm install`, que é o comando que utilizamos para instalar um Chart no Kubernetes.

Vamos instalar o nosso Chart, para isso, execute o comando abaixo:

```bash
helm install giropops-senhas ./
```

Se tudo ocorrer bem, você verá a seguinte saída:

```bash
NAME: giropops-senhas
LAST DEPLOYED: Thu Feb  8 16:37:58 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

O nosso Chart foi instalado com sucesso!

Vamos listar os Pods para ver se eles estão rodando, execute o comando abaixo:

```bash
kubectl get pods
```

A saída será algo assim:

```bash
NAME                                READY   STATUS    RESTARTS      AGE
giropops-senhas-7d4fddc49f-9zfj9    1/1     Running   0             42s
giropops-senhas-7d4fddc49f-dn996    1/1     Running   0             42s
giropops-senhas-7d4fddc49f-fpvh6    1/1     Running   0             42s
redis-deployment-76c5cdb57b-wf87q   1/1     Running   0             42s
```

Perceba que temos 3 Pods rodando para a nossa aplicação Giropops-Senhas, e 1 Pod rodando para o Redis, conforme definimos no arquivo `values.yaml`.

Agora vamos listar os Charts que estão instalados no nosso Kubernetes, para isso, execute o comando abaixo:

```bash
helm list
```

Se você quiser ver de alguma namespace específica, você pode utilizar o comando `helm list -n <namespace>`, mas no nosso caso, como estamos utilizando a namespace default, não precisamos especificar a namespace.

Para ver mais detalhes do Chart que instalamos, você pode utilizar o comando `helm get`, para isso, execute o comando abaixo:

```bash
helm get all giropops-senhas
```

A saída será os detalhes do Chart e os manifestos que foram renderizados pelo Helm.

Vamos fazer uma alteração no nosso Chart, e vamos ver como atualizar a nossa aplicação utilizando o Helm.

#### Atualizando o nosso Chart

Vamos fazer uma alteração no nosso Chart, e vamos ver como atualizar a nossa aplicação utilizando o Helm.

Vamos editar o `values.yaml` e alterar a quantidade de réplicas que estamos utilizando para a nossa aplicação Giropops-Senhas, para isso, edite o arquivo `values.yaml` e altere a quantidade de réplicas para 5:

```yaml
giropops-senhas:
  name: "giropops-senhas"
  image: "linuxtips/giropops-senhas:1.0"
  replicas: "5"
  port: 5000
  labels:
    app: "giropops-senhas"
    env: "labs"
    live: "true"
  service:
    type: "NodePort"
    port: 5000
    targetPort: 5000
    name: "giropops-senhas-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"
redis:
  image: "redis"
  replicas: 1
  port: 6379
  labels:
    app: "redis"
    env: "labs"
    live: "true"
  service:
    type: "ClusterIP"
    port: 6379
    targetPort: 6379
    name: "redis-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"
```

A única coisa que alteramos foi a quantidade de réplicas que estamos utilizando para a nossa aplicação Giropops-Senhas, de 3 para 5.

Vamos agora pedir para o Helm atualizar a nossa aplicação, para isso, execute o comando abaixo:

```bash
helm upgrade giropops-senhas ./
```

Se tudo ocorrer bem, você verá a seguinte saída:

```bash
Release "giropops-senhas" has been upgraded. Happy Helming!
NAME: giropops-senhas
LAST DEPLOYED: Thu Feb  8 16:46:26 2024
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
```

Agora vamos ver se o número de réplicas foi alterado, para isso, execute o comando abaixo:

```bash
giropops-senhas-7d4fddc49f-9zfj9    1/1     Running   0             82s
giropops-senhas-7d4fddc49f-dn996    1/1     Running   0             82s
giropops-senhas-7d4fddc49f-fpvh6    1/1     Running   0             82s
redis-deployment-76c5cdb57b-wf87q   1/1     Running   0             82s
giropops-senhas-7d4fddc49f-ll25z    1/1     Running   0             18s
giropops-senhas-7d4fddc49f-w8p7r    1/1     Running   0             18s
```

Agora temos mais dois Pods em execução, da mesma forma que definimos no arquivo `values.yaml`.

Agora vamos remover a nossa aplicação:

```bash
helm uninstall giropops-senhas
```

A saída será algo assim:

```bash
release "giropops-senhas" uninstalled
```

Já era, a nossa aplicação foi removida com sucesso!

Como eu falei, nesse caso criamos tudo na mão, mas eu poderia ter usado o comando `helm create` para criar o nosso Chart, e ele teria criado a estrutura de diretórios e os arquivos que precisamos para o nosso Chart, e depois teríamos que fazer as alterações que fizemos manualmente.

A estrutura de diretórios que o `helm create` cria é a seguinte:

```bash
giropops-senhas-chart/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

Eu não criei dessa forma, pois acho que iria complicar um pouco o nosso entendimento inicial, pois ele iria criar mais coisas que iriamos utilizar, mas em contrapartida, podemos utiliza-lo para nos basear para os nossos próximos Charts.
Ele é o nosso amigo, e sim, ele pode nos ajudar! hahaha

Agora eu preciso que você pratique o máximo possível, brincando com as diversas opções que temos disponíveis no Helm, e o mais importante, use e abuse da documentação oficial do Helm, ela é muito rica e tem muitos exemplos que podem te ajudar.

Bora deixar o nosso Chart ainda mais legal?

#### Utilizando `range`  e o `if` no Helm

O Helm tem uma funcionalidade muito legal que é o `range`, que é uma estrutura de controle que nos permite iterar sobre uma lista de itens, e isso é muito útil quando estamos trabalhando com listas de itens, como por exemplo, quando estamos trabalhando com os manifestos do Kubernetes.

Para que você consiga utilizar o `range`, precisamos antes entender sua estrutura básica, por exemplo, temos um arquivo com 4 frutas, e queremos listar todas elas, como eu faria isso?

Primeiro, vamos criar um arquivo chamado `frutas.yaml` com o seguinte conteúdo:

```yaml
frutas:
  - banana
  - maçã
  - uva
  - morango
```

Agora vamos pegar fruta por fruta, e colocando a seguinte frase antes de cada uma delas: "Eu gosto de". 

Para isso, vamos criar um arquivo chamado `eu-gosto-frutas.yaml` com o seguinte conteúdo:

```yaml
{{- range .Values.frutas }}
Eu gosto de {{ . }}
{{- end }}
```

O resultado será:

```bash
Eu gosto de banana
Eu gosto de maçã
Eu gosto de uva
Eu gosto de morango
```

Ficou fácil, certo?
O `range` percorreu toda a lista e ainda adicionou a frase que queríamos. 

Vamos imaginar que eu tenho uma lista de portas que eu quero expor para a minha aplicação, e eu quero criar um Service para cada porta que eu tenho na minha lista, como eu faria isso?

Por exemplo, a nossa aplicação Giropops-Senhas, ela tem 2 portas que ela expõe, a porta 5000 e a porta 8088. A porta 5000 é a porta que a aplicação escuta, e a porta 8088 é a porta que a aplicação expõe as métricas para o Prometheus.

Outra função super interessante e que é muito útil é o `if`, que é uma estrutura de controle que nos permite fazer uma verificação se uma condição é verdadeira ou falsa, e baseado nisso, podemos fazer alguma coisa ou não.

a Estrutura básica do `if` é a seguinte:

```yaml
{{- if eq .Values.giropopsSenhas.service.type "NodePort" }}
  nodePort: {{ .Values.giropopsSenhas.service.nodePort }}
  targetPort: {{ .Values.giropopsSenhas.service.targetPort }}
{{- else }}
  targetPort: {{ .Values.giropopsSenhas.service.targetPort }}
{{- end }}
```

Onde:

```yaml
- `{{- if eq .Values.giropopsSenhas.service.type "NodePort" }}`: Verifica se o valor que está definido para a chave `type` é igual a `NodePort`
- `nodePort: {{ .Values.giropopsSenhas.service.nodePort }}`: Se a condição for verdadeira, ele irá renderizar o valor que está definido para a chave `nodePort`
- `targetPort: {{ .Values.giropopsSenhas.service.targetPort }}`: Se a condição for verdadeira, ele irá renderizar o valor que está definido para a chave `targetPort`
- `{{- else }}`: Se a condição for falsa, ele irá renderizar o valor que está definido para a chave `targetPort`
- `{{- end }}`: Finaliza a estrutura de controle
```

Simples como voar! Bora lá utilizar essas duas fun´ções para deixar o nosso Chart ainda mais legal.

Vamos começar criando um arquivo chamado `giropops-senhas-service.yaml` com o seguinte conteúdo:

```yaml
{{- range .Values.giropops-senhas.ports }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  labels:
    app: {{ .name }}
spec:
  type: {{ .serviceType }}
  ports:
  - name: {{ .name }}
    port: {{ .port }}
{{- if eq .serviceType "NodePort" }}
    nodePort: {{ .NodePort }}
{{- end }}
    targetPort: {{ .targetPort }}
  selector:
    app: giropops-senhas
---
{{- end }}
```

No arquivo acima, estamos utilizando a função `range` para iterar sobre a lista de portas que queremos expor para a nossa aplicação, e estamos utilizando a função `if` para verificar se a porta que estamos expondo é do tipo `NodePort`, e baseado nisso, estamos renderizando o valor que está definido para a chave `nodePort`.

Agora vamos alterar o arquivo `values.yaml` e adicionar a lista de portas que queremos expor para a nossa aplicação, para isso, edite o arquivo `values.yaml` e adicione a lista de portas que queremos expor para a nossa aplicação:

```yaml
giropops-senhas:
  name: "giropops-senhas"
  image: "linuxtips/giropops-senhas:1.0"
  replicas: "3"
  ports:
    - port: 5000
      targetPort: 5000
      name: "giropops-senhas-port"
      serviceType: NodePort
      NodePort: 32500
    - port: 8088
      targetPort: 8088
      name: "giropops-senhas-metrics"
      serviceType: ClusterIP
  labels:
    app: "giropops-senhas"
    env: "labs"
    live: "true"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"
redis:
  image: "redis"
  replicas: 1
  port: 6379
  labels:
    app: "redis"
    env: "labs"
    live: "true"
  service:
    type: "ClusterIP"
    port: 6379
    targetPort: 6379
    name: "redis-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"
```

Temos algumas coisas novas no arquivo `values.yaml`. O objetivo da mudança é deixar o arquivo ainda mais dinâmico, e para isso, adicionamos adicionamos mais informações sobre as portas que iremos utilizar. Deixamos as informações mais organizadas para facilitar a dinâmica criada no arquivo `giropops-senhas-service.yaml`.

Poderiamos ainda criar um único template para realizar o deploy do Redis e do Giropops-Senhas, somente para que possamos gastar um pouquinho mais do nosso conhecimento, ou seja, isso aqui é muito mais para fins didáticos do que para a vida real, mas vamos lá, vamos criar um arquivo chamado `giropops-senhas-deployment.yaml` com o seguinte conteúdo:

```yaml
{{- range $component, $config := .Values.deployments }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $component }}
  labels:
    app: {{ $config.labels.app }}
spec:
  replicas: {{ $config.replicas }}
  selector:
    matchLabels:
      app: {{ $config.labels.app }}
  template:
    metadata:
      labels:
        app: {{ $config.labels.app }}
    spec:
      containers:
      - name: {{ $component }}
        image: {{ $config.image }}
        ports:
        {{- range $config.ports }}
        - containerPort: {{ .port }}
        {{- end }}
        resources:
          requests:
            memory: {{ $config.resources.requests.memory }}
            cpu: {{ $config.resources.requests.cpu }}
          limits:
            memory: {{ $config.resources.limits.memory }}
            cpu: {{ $config.resources.limits.cpu }}
{{- if $config.env }}
        env:
        {{- range $config.env }}
        - name: {{ .name }}
          value: {{ .value }}
        {{- end }}
{{- end }}
---
{{- end }}
```

Estamos utilizando a função `range` logo no inicio do arquivo, e com ele estamos interando sobre a lista de componentes que temos no nosso arquivo `values.yaml`, ou seja, o Redis e o Giropops-Senhas. Mas também estamos utilizando o `range` para interar sobre a lista de outras configurações que temos no nosso arquivo `values.yaml`, como por exemplo, as portas que queremos expor para a nossa aplicação e o limite de recursos que queremos utilizar. Ele definiu duas variáveis, `$component` e `$config`, onde `$component` é o nome do componente que estamos interando, e `$config` é a configuração que estamos interando, fácil!

Agora vamos instalar a nossa aplicação com o comando abaixo:

```bash
helm install giropops-senhas ./
```

A saída será algo assim:

```bash
Error: INSTALLATION FAILED: parse error at (giropops-senhas/templates/services.yaml:1): bad character U+002D '-'
```

Parece que alguma coisa de errado não está certo, certo? hahaha

O que aconteceu foi o seguinte:

Quando estamos utilizando o nome do componente com um hífen, e tentamos passar na utilização do `range`, o Helm não entende que aquele é o nome do recurso que estamos utilizando, e retorna o erro de `bad character U+002D '-'`.

Para resolver isso, vamos utilizar mais uma função do Helm, que é a função `index`.

A função `index` nos permite acessar um valor de um mapa baseado na chave que estamos passando, nesse caso seria o `.Values`, e ainda buscar um valor baseado na chave que estamos passando, que é o nome do componente que estamos interando. Vamos ver como ficaria o nosso `services.yaml` com a utilização da função `index`:

```yaml
{{- range (index .Values "giropops-senhas").ports }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  labels:
    app: {{ .name }}
spec:
  type: {{ .serviceType }}
  ports:
  - name: {{ .name }}
    port: {{ .port }}
{{- if eq .serviceType "NodePort" }}
    nodePort: {{ .NodePort }}
{{- end }}
    targetPort: {{ .targetPort }}
  selector:
    app: giropops-senhas
---
{{- end }}
```

Pronto, agora acredito que tudo terá um final feliz, para ter certeza, vamos instalar a nossa aplicação com o comando abaixo:

```bash
helm install giropops-senhas ./
```

Se tudo ocorrer bem, você verá a seguinte saída:

```bash
NAME: giropops-senhas
LAST DEPLOYED: Sat Feb 10 12:19:27 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Vamos ver se deu bom!

```bash
kubectl get deployment
```

Temos a saída abaixo:

```bash
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
giropops-senhas-deployment   3/3     3            3           4m1s
redis-deployment             1/1     1            1           4m1s
```

Agora os Pods:

```bash
kubectl get pods
```

A saída:

```bash
NAME                                         READY   STATUS    RESTARTS   AGE
giropops-senhas-deployment-5c547c9cf-979vp   1/1     Running   0          4m40s
giropops-senhas-deployment-5c547c9cf-s5k9x   1/1     Running   0          4m39s
giropops-senhas-deployment-5c547c9cf-zp4s4   1/1     Running   0          4m39s
redis-deployment-69c5869684-cxslb            1/1     Running   0          4m40s
```

Vamos ver os Services:

```bash
kubectl get svc
```

Se a sua saída trouxe os dois serviços, com os nomes `giropops-senhas-port` e `giropops-senhas-metrics`, e com os tipos `NodePort` e `ClusterIP`, respectivamente, é um sinal de que deu super bom!

```bash
NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
giropops-senhas-app       NodePort    10.96.185.6    <none>        5000:32500/TCP   5m1s
giropops-senhas-metrics   ClusterIP   10.96.107.37   <none>        8088/TCP         5m1s
kubernetes                ClusterIP   10.96.0.1      <none>        443/TCP          3d21h
```

Parece que deu ruim, certo?

Ficou faltando o Service do Redis. :/

Vamos resolver, mas antes, vamos mudar um pouco a organização em nosso `values.yaml`.

```yaml
deployments:
  giropops-senhas:
    name: "giropops-senhas"
    image: "linuxtips/giropops-senhas:1.0"
    replicas: "3"
    labels:
      app: "giropops-senhas"
      env: "labs"
      live: "true"
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
  redis:
    image: "redis"
    replicas: 1
    port: 6379
    labels:
      app: "redis"
      env: "labs"
      live: "true"
    service:
      type: "ClusterIP"
      port: 6379
      targetPort: 6379
      name: "redis-port"
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
services:
  giropops-senhas:
    ports:
      - port: 5000
        targetPort: 5000
        name: "giropops-senhas-app"
        serviceType: NodePort
        NodePort: 32500
      - port: 8088
        targetPort: 8088
        name: "giropops-senhas-metrics"
        serviceType: ClusterIP
    labels:
      app: "giropops-senhas"
      env: "labs"
      live: "true"
  redis:
    ports:
      - port: 6379
        targetPort: 6378
        name: "redis-port"
        serviceType: ClusterIP
    labels:
      app: "redis"
      env: "labs"
      live: "true"
```

Precisamos agora atualizar os nossos templates para que eles possam utilizar as novas chaves que criamos no arquivo `values.yaml`.

Vamos atualizar o `services.yaml` para que ele possa utilizar as novas chaves que criamos no arquivo `values.yaml`:

```yaml
{{- range $component, $config := .Values.services }}
  {{ range $port := $config.ports }}
apiVersion: v1
kind: Service
metadata:
  name: {{ $component }}-{{ $port.name }}
  labels:
    app: {{ $config.labels.app }}
spec:
  type: {{ $port.serviceType }}
  ports:
  - port: {{ $port.port }}
    targetPort: {{ $port.targetPort }}
    protocol: TCP
    name: {{ $port.name }}
    {{ if eq $port.serviceType "NodePort" }}
    nodePort: {{ $port.nodePort }}
    {{ end }}
  selector:
    app: {{ $config.labels.app }}
---
  {{ end }}
{{- end }}
```

Adicionamos um novo `range` para interar sobre a lista de portas que queremos expor para a nossa aplicação, e utilizamos a função `index` para acessar o valor que está definido para a chave `services` no arquivo `values.yaml`.

Como o nosso `deployments.yaml` já está atualizado, não precisamos fazer nenhuma alteração nele, o que precisamos é deployar o nosso Chart novamente e ver se as nossas mondificações funcionaram.

Temos duas opções, ou realizamos o `uninstall` e o `install` novamente, ou realizamos o `upgrade` da nossa aplicação.

Vou realizar o `uninstall` e o `install` novamente, para isso, execute os comandos abaixo:

```bash
helm uninstall giropops-senhas
```

E agora:

```bash
helm install giropops-senhas ./
```

Caso eu queira fazer o `upgrade`, eu poderia utilizar o comando abaixo:

```bash
helm upgrade giropops-senhas ./
```

Pronto, se tudo estiver certinho, temos uma saída parecida com a seguinte:

```bash
NAME: giropops-senhas
LAST DEPLOYED: Sat Feb 10 14:05:37 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Vamos listar os recursos:
  
```bash
kubectl get deployments,pods,svc
```

Assim ele trará todos os nossos recursos utilizados pela nossa aplicação.

```bash
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/giropops-senhas   3/3     3            3           69s
deployment.apps/redis             1/1     1            1           69s

NAME                                   READY   STATUS    RESTARTS   AGE
pod/giropops-senhas-8598bc5699-68sn6   1/1     Running   0          69s
pod/giropops-senhas-8598bc5699-wgnxj   1/1     Running   0          69s
pod/giropops-senhas-8598bc5699-xqssx   1/1     Running   0          69s
pod/redis-69c5869684-62d2h             1/1     Running   0          69s

NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/giropops-senhas-app       NodePort    10.96.119.23   <none>        5000:30032/TCP   69s
service/giropops-senhas-metrics   ClusterIP   10.96.110.83   <none>        8088/TCP         69s
service/kubernetes                ClusterIP   10.96.0.1      <none>        443/TCP          3d22h
service/redis-service             ClusterIP   10.96.77.187   <none>        6379/TCP         69s
```

Pronto! Tudo criado com sucesso!

Agora você já sabe como utilizar o `range`, `index` e o `if` no Helm, e já sabe como criar um Chart do zero, e já sabe como instalar, atualizar e remover a sua aplicação utilizando o Helm.


#### Utilizando `default`, `toYaml` e `toJson` no Helm

Vamos comecer mais algumas funções do Helm, que são o `default`, `toYaml` e `toJson`, que nos ajudarão a deixar o nosso Chart ainda mais dinâmico e customizável.

Suponhamos que queremos garantir que sempre haja um valor padrão para o número de réplicas nos nossos deployments, mesmo que esse valor não tenha sido especificamente definido no `values.yaml`. Podemos modificar o nosso `giropops-senhas-deployment.yaml` para incluir a função `default`:

```yaml
replicas: {{ .Values.giropopsSenhas.replicas | default 3 }}
```

Agora vamos adicionar a configuração necessária para a observabilidade da nossa aplicação "Giropops-Senhas", que inclui diversos parâmetros de configuração, e precisamos passá-la como uma string JSON para um ConfigMap. E o `toJson` irá nos salvar:

No `values.yaml`, adicionamos uma configuração complexa:

```yaml
observability:
  giropops-senhas:
    logging: true
    metrics:
      enabled: true
      path: "/metrics"
```

Agora vamos criar um ConfigMap que inclui essa configuração como uma string JSON:

```yaml
{{- range $component, $config := .Values.observability }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $component }}-observability-config
data:
  app-config.json: | 
    {{ toJson $config }}
{{- end }}
```

Dessa forma, transformamos a configuração definida no `values.yaml` em uma string JSON formatada, que é injetada diretamente no ConfigMap. A função `nindent 4` garante que iremos usar com 4 espaços de indentação a cada linha do conteúdo injetado.

```json
{
    "logging": true,
    "metrics": {
        "enabled": true,
        "path": "/metrics"
    }
}
```

Fácil!

E por fim, vamos adicionar o endereço de um banco de dados como uma configuração YAML, e precisamos passá-la como uma string YAML para um ConfigMap. E o `toYaml` é a função que irá garantir que a configuração seja injetada corretamente:

A configuração no `values.yaml`:

```yaml
databases:
  giropops-senhas:
    type: "MySQL"
      host: "mysql.svc.cluster.local"
      port: 3306
      name: "MyDB"
```

Com isso, já podemos criar um ConfigMap que inclui essa configuração como uma string YAML:

```yaml
{{- range $component, $config := .Values.databases }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $component }}-db-config
data:
  app-config.yaml: |
    {{- toYaml $config | nindent 4 }}
{{- end }}
```

Dessa forma, transformamos a configuração definida no `values.yaml` em uma string YAML formatada, que é injetada diretamente no ConfigMap. A função `nindent 2` garante que o conteúdo injetado esteja corretamente indentado, pois ela adiciona 2 espaços de indentação a cada linha do conteúdo injetado.

Para que possamos aplicar essas modificações, precisamos realizar o `upgrade` da nossa aplicação, para isso, execute o comando abaixo:

```bash
helm upgrade giropops-senhas ./
```

Agora já temos além dos deployments e services, também os ConfigMaps para a nossa aplicação.

Para ver os ConfigMaps, execute o comando abaixo:

```bash
kubectl get configmaps
```

Para ver os detalhes de cada ConfigMap, execute o comando abaixo:

```bash
kubectl get configmap <configmap-name> -o yaml
```

Chega a ser lacrimejante de tão lindo! :D


#### O Que São Helpers no Helm?

Helpers no Helm são funções definidas em arquivos `_helpers.tpl` dentro do diretório `templates` de um gráfico Helm. Eles permitem a reutilização de código e lógicas complexas em seus templates, promovendo práticas de codificação DRY (Don't Repeat Yourself). Isso significa que, em vez de repetir o mesmo código em vários lugares, você pode definir uma função helper e chamá-la sempre que precisar.

##### Por Que Usar Helpers?

- **Reutilização de Código:** Evita duplicação e facilita a manutenção.
- **Abstração de Complexidade:** Encapsula lógicas complexas, tornando os templates mais limpos e fáceis de entender.
- **Personalização e Flexibilidade:** Permite a criação de templates mais dinâmicos e adaptáveis às necessidades específicas do usuário.

##### Criando o Nosso Primeiro Helper

Para ilustrar a criação e o uso de helpers, vamos começar com um exemplo prático. Imagine que você precisa incluir o nome padrão do seu aplicativo em vários recursos Kubernetes no seu chart Helm. Em vez de escrever manualmente o nome em cada recurso, você pode definir um helper para isso.

1. **Definindo um Helper:**
   No diretório `templates`, crie um arquivo chamado `_helpers.tpl` e adicione o seguinte conteúdo:


```yaml
{% raw %}
{{/*
Define um helper para o nome do aplicativo.
*/}}
{{- define "meuapp.name" -}}
{{- default .Chart.Name .Values.appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{% endraw %}
```


   Esta função define um nome padrão para o seu aplicativo, usando o nome do gráfico (`Chart.Name`) ou um nome personalizado definido em `Values.appName`, limitando-o a 63 caracteres e removendo quaisquer hífens no final.

2. **Usando o Helper:**
   Agora, você pode usar este helper em seus templates para garantir que o nome do aplicativo seja consistente em todos os recursos. Por exemplo, em um template de Deployment, você pode usar:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "meuapp.name" . }}
  labels:
    app: {{ include "meuapp.name" . }}
```

##### Helpers Avançados: Exemplos Práticos

À medida que você se familiariza com os helpers, pode começar a explorar usos mais avançados. Aqui estão alguns exemplos que demonstram a flexibilidade e o poder dos helpers no Helm.

###### Exemplo 1: Controlando a Complexidade

Imagine que você tenha múltiplos serviços que precisam ser configurados de maneira ligeiramente diferente com base em certos valores de entrada. Você pode criar um helper complexo que gera a configuração apropriada para cada serviço.

```yaml
{{/*
Gerar configuração específica do serviço.
*/}}
{{- define "meuapp.serviceConfig" -}}
{{- if eq .Values.serviceType "frontend" -}}
# Configuração específica do frontend
{{- else if eq .Values.serviceType "backend" -}}
# Configuração específica do backend
{{- end -}}
{{- end -}}
```

###### Exemplo 2: Personalização Baseada em Ambiente

Em ambientes de desenvolvimento, você pode querer configurar seus serviços de maneira diferente do que em produção. Um helper pode ajudar a injetar essas configurações com base no ambiente.

```yaml
{{/*
Ajustar configurações com base no ambiente.
*/}}
{{- define "meuapp.envConfig" -}}
{{- if eq .Values.environment "prod" -}}
# Configurações de produção
{{- else -}}
# Configurações de desenvolvimento
{{- end

 -}}
{{- end -}}
```

##### Melhores Práticas ao Usar Helpers

- **Mantenha os Helpers Simples:** Funções muito complexas podem ser difíceis de manter e entender.
- **Nomeie os Helpers de Forma Clara:** Os nomes devem refletir o propósito da função para facilitar a compreensão e o uso.
- **Documente Seus Helpers:** Comentários claros sobre o que cada helper faz ajudam outros desenvolvedores a entender seu código mais rapidamente.
- **Use Helpers para Lógicas Recorrentes:** Aproveite os helpers para evitar a repetição de lógicas complexas ou padrões comuns em seus templates.



#### Criando o `_helpers.tpl` da nossa App

Chegou o momento de chamar os Helpers do Helm para nos ajudar a dimunir a repetição de códigos e também para reduzir a complexidade de nossos Templates.

Vamos dividir em algumas etapas para ficar fácil o entendimento sobre o que estamos fazendo em cada passo. :)

##### Passo 1: Criando o arquivo `_helpers.tpl`

Como já vimos, o arquivo `_helpers.tpl` contém definições de templates que podem ser reutilizadas em vários lugares. Aqui estão alguns templates úteis para o nosso caso:

###### Labels

Para reutilizar as labels de aplicativos em seus deployments e services:

```yaml
{{/*
Generate application labels
*/}}
{{- define "app.labels" -}}
app: {{ .labels.app }}
env: {{ .labels.env }}
live: {{ .labels.live }}
{{- end }}
```

No arquivo acima estamos definindo um helper que gera as labels do aplicativo com base nas configurações fornecidas. Isso nos permite reutilizar as mesmas labels em vários recursos, garantindo consistência e facilitando a manutenção.


###### Resources

Template para definir os requests e limits de CPU e memória:

```yaml
{{/*
Generate container resources
*/}}
{{- define "app.resources" -}}
requests:
  memory: {{ .resources.requests.memory }}
  cpu: {{ .resources.requests.cpu }}
limits:
  memory: {{ .resources.limits.memory }}
  cpu: {{ .resources.limits.cpu }}
{{- end }}
```

Aqui estamos definindo um helper que gera as configurações de recursos para um contêiner com base nas configurações fornecidas.

###### Ports

Template para a definição de portas no deployment:

```yaml
{{/*
Generate container ports
*/}}
{{- define "app.ports" -}}
{{- range .ports }}
- containerPort: {{ .port }}
{{- end }}
{{- end }}
```

#### Passo 2: Refatorando `Deployments.yaml` e `Services.yaml`

Com os helpers definidos, já podemos refatorar nossos arquivos `Deployments.yaml` e `Services.yaml` para utilizar esses templates.

###### O nosso `Deployments.yaml`

```yaml
{{- range $component, $config := .Values.deployments }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $component }}
  labels:
    {{- include "app.labels" $config | nindent 4 }}
spec:
  replicas: {{ $config.replicas | default 3 }}
  selector:
    matchLabels:
      app: {{ $config.labels.app }}
  template:
    metadata:
      labels:
        {{- include "app.labels" $config | nindent 8 }}
    spec:
      containers:
      - name: {{ $component }}
        image: {{ $config.image }}
        ports:
        {{- include "app.ports" $config | nindent 10 }}
        resources:
          {{- include "app.resources" $config | nindent 12 }}
{{- if $config.env }}
        env:
        {{- range $config.env }}
        - name: {{ .name }}
          value: {{ .value }}
        {{- end }}
{{- end }}
---
{{- end }}
```

###### O nosso `Services.yaml`

```yaml
{{- range $component, $config := .Values.services }}
  {{- range $port := $config.ports }}
apiVersion: v1
kind: Service
metadata:
  name: {{ $component }}-{{ $port.name }}
  labels:
    {{- include "app.labels" $config | nindent 4 }}
spec:
  type: {{ $port.serviceType }}
  ports:
  - port: {{ $port.port }}
    targetPort: {{ $port.targetPort }}
    protocol: TCP
    name: {{ $port.name }}
    {{- if eq $port.serviceType "NodePort" }}
    nodePort: {{ $port.nodePort }}
    {{- end }}
  selector:
    app: {{ $config.labels.app }}
---
  {{- end }}
{{- end }}
```

Pronto! Agora já temos o `_helpers.tpl` criado e os templates atualizados!

Caso queira testar, basta instalar ou fazer o upgrade do nosso Chart. Não vou fazer aqui novamente pois já executamos mais de 1 milhão de vezes, você já sabe como fazer isso com os pés nas costas. :)

#### Passo 3: Refatorando os ConfigMaps

Ainda precisamos trabalhar com os nosso ConfigMaps, e para isso eu pensei em executar algo um pouco mais complexo, somente para que possamos gastar todo o nosso conhecimento. hahaha

Para tornar os arquivos `config-map-dp.yaml` e `config-map-obs.yaml` mais inteligentes e menos complexos com a ajuda do arquivo `_helpers.tpl`, podemos adicionar mais definições de template que facilitam a criação de ConfigMaps para bases de dados e configurações de observabilidade. Vou adicionar templates específicos para esses dois tipos de ConfigMap no arquivo `_helpers.tpl` e, em seguida, refatorar os arquivos de ConfigMap para utilizar esses templates.

##### Atualizando o `_helpers.tpl`

Adicionaremos templates para gerar ConfigMaps de bancos de dados e observabilidade:

```yaml
{{/*
Generate database config map
*/}}
{{- define "database.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .component }}-db-config
data:
  app-config.yaml: |
    {{- toYaml .config | nindent 4 }}
{{- end }}

{{/*
Generate observability config map
*/}}
{{- define "observability.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .component }}-observability-config
data:
  app-config.json: | 
    {{ toJson .config }}
{{- end }}
```

Agora estamos praticamente colocando todo o conteúdo dos ConfigMaps aqui, isso fará com que os nossos arquivos fiquem bem pequenos e somente utilizando a combinação do `values.yaml` e o `_helpers.tpl`.


##### Refatorando `config-map-dp.yaml`

Para utilizar o template do `_helpers.tpl`, bora modificar o arquivo `config-map-dp.yaml` da seguinte forma:

```yaml
{{- range $component, $config := .Values.databases }}
  {{- $data := dict "component" $component "config" $config }}
  {{- include "database.configmap" $data | nindent 0 }}
{{- end }}
```

Isso irá percorrer todos os componentes definidos em `.Values.databases` e aplicar o template definido para criar um ConfigMap para cada banco de dados.

##### Refatorando `config-map-obs.yaml`

Da mesma forma, modifique o arquivo `config-map-obs.yaml` para usar o template de observabilidade:

```yaml
{{- range $component, $config := .Values.observability }}
  {{- $data := dict "component" $component "config" $config }}
  {{- include "observability.configmap" $data | nindent 0 }}
{{- end }}
```

Isso irá iterar sobre os componentes definidos em `.Values.observability` e aplicar o template para criar um ConfigMap de observabilidade para cada componente.

Ahhh, o nosso arquivo `_helpers.tpl` ficou da seguinte maneira:

```yaml
{{/* Define a base para reutilização de labels */}}
{{- define "app.labels" -}}
app: {{ .labels.app }}
env: {{ .labels.env }}
live: {{ .labels.live }}
{{- end }}

{{/* Template para especificações de recursos de containers */}}
{{- define "app.resources" -}}
requests:
  memory: {{ .resources.requests.memory }}
  cpu: {{ .resources.requests.cpu }}
limits:
  memory: {{ .resources.limits.memory }}
  cpu: {{ .resources.limits.cpu }}
{{- end }}

{{/* Template para definição de portas em containers */}}
{{- define "app.ports" -}}
{{- range .ports }}
- containerPort: {{ .port }}
{{- end }}
{{- end }}

{{/* Template para gerar um ConfigMap para configurações de banco de dados */}}
{{- define "database.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .component }}-db-config
data:
  app-config.yaml: |
    {{- toYaml .config | nindent 4 }}
{{- end }}

{{/* Template para gerar um ConfigMap para configurações de observabilidade */}}
{{- define "observability.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .component }}-observability-config
data:
  app-config.json: | 
    {{ toJson .config }}
{{- end }}
```

Veja o quanto conseguimos modificar os nossos Templates utilizando o nosso `_helpers.tpl`, isso é mágico demais! Porém é importante lembrar que não devemos usar os helpers para deixar as coisas mais complexas, e sim, facilitar e diminuir a nossa carga cognitiva e a repetição de códigos. Aqui estamos trabalhando de forma que fique mais didática, porém isso não quer dizer que você deva repetir isso em sua produção. Tudo depende, e dito isso, agora que você já conhece bem o que são os Helm Charts, acho que já podemos conhecer como criar o nosso repositório de Helm Charts!

#### Criando um repositório de Helm Charts

É bem comum que você tenha um repositório interno para armazenar os seus Helm Charts, para que outras pessoas consigam utilizar e ajudar no gerenciamento do repositório.

A criação de um repositório é bastante simples, e para o nosso exemplo vamos utilizar o Github para ser o nosso repo de Charts. Esse repositório pode ser público ou privado, depende da sua necessidade.

Vou colocar alguns passos para que você possa criar o seu repositório no Github, antes da gente começar a começar a trabalhar com o nosso repositório de Helm Charts.

##### Criando o repositório no Github

1. Acesse o Github e faça o login na sua conta.
2. Clique no ícone de "+" no canto superior direito e selecione "New repository".
3. Nomeie o seu repositório (por exemplo, meu-repo-charts).
4. Deixe o repositório público ou privado, conforme sua necessidade.
5. Clique em "Create repository".
  
Pronto, repo criado!

Agora vamos clona-lo para a nossa máquina e começar a trabalhar com ele.

```bash
git clone < endereço do seu repo >
```

Agora acesse o diretório do seu repositório e vamos começar a brincadeira do lado do Helm.

##### Inicializando o repositório

Primeira coisa, vamos criar o diretórios charts e acessa-lo:

```bash
mkdir charts
cd charts
```

Agora vamos copiar o nosso Chart para o diretório `charts`:

```bash
cp -r <diretório do seu Chart> ./
```

O conteúdo será algo assim:

```bash
.
├── charts
│   └── giropops-senhas
│       ├── charts
│       ├── Chart.yaml
│       ├── templates
│       │   ├── configmap-db.yaml
│       │   ├── configmap-observability.yaml
│       │   ├── deployments.yaml
│       │   ├── _helpers.tpl
│       │   └── services.yaml
│       └── values.yaml
└── README.md
```

Vamos aproveitar e conhecer dois comandos que irão nos ajudar a ter certeza que está tudo certo com o nosso Chart.

O primeiro é o `lint`, usado para ver como está a qualidade do nosso Chart:

```bash
helm lint giropops-senhas
```

Com isso, se tudo estiver bem você verá a seguinte saída:

```bash
==> Linting charts/giropops-senhas
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

Temos um aviso, mas isso não é um problema, é apenas uma recomendação.

Outro comando que nos ajuda a ter certeza que está tudo certo com o nosso Chart é o `template`, que irá renderizar o nosso Chart e verificar se está tudo certo:

```bash
helm template charts/giropops-senhas
```

Com isso você verá a saída do seu Chart renderizado, e assim você consegue conferir os manifestos gerados e ver se está tudo certo. :)

O próximo passo é criar um pacote do nosso Chart, que nada mais é que um .tgz que contém o nosso Chart, e para isso, execute o comando abaixo:

```bash
helm package charts/giropops-senhas
```

A saída:

```bash
Successfully packaged chart and saved it to: /home/LINUXtips/meu-repo/giropops-senhas-0.1.0.tgz
```

Agora que já temosk o tarball do nosso Chart, vamos adicionar ele ao nosso repositório, e para que isso seja possível vamos conhecer um comando que irá nos ajudar nessa tarefa, que é o `repo index`.

O `repo index` irá criar um arquivo index.yaml que contém as informações sobre os pacotes disponíveis no repositório, e para isso, execute o comando abaixo:

```bash
helm repo index --url <URL do seu repo no github> .
```

Perceba que ele criou um arquivo chamado `index.yaml`, e nesse arquivo temos informções sobre o nosso Chart, como o nome, a versão, a descrição, o tipo de aplicação, e o endereço do Chart.

Vamos dar um `cat` nesse arquivo para ver o que temos:

```bash
cat index.yaml
```

```yaml
apiVersion: v1
entries:
  giropops-senhas:
  - apiVersion: v2
    appVersion: 0.1.0
    created: "2024-02-13T11:40:40.803868957+01:00"
    description: Esse é o chart do Giropops-Senhas, utilizados nos laboratórios de
      Kubernetes.
    digest: 05bc20f073f5e7824ok43o4k3okfdfac1be5c46e4bdc0ac3a8a45eec
    name: giropops-senhas
    sources:
    - https://github.com/seu-user/seu-repo
    urls:
    - https://github.com/seu-user/seu-repo/giropops-senhas-0.1.0.tgz
    version: 0.1.0
generated: "2024-02-13T11:40:40.803383504+01:00"
```

Com o index.yaml, precisamos ir para o próximo passo, que é fazer o commit e o push do nosso repositório.

```bash
git add .
git commit -m "Adicionando o Chart do Giropops-Ssenhas"
git push origin main
```

Pronto, o nosso código está no repo lá no GitHub. \o/

Mas o nosso trabalho não para por aqui, precisamos configurar o GitHub Pages para o nosso repositório de Helm Charts.

##### Configurando o GitHub Pages

Siga os passos abaixo para configurar o seu GitHub Pages:

1. Acesse o repositório no Github.
2. Clique na aba "Settings".
3. Role a página até a seção "Pages".
4. Selecione a branch `main` e a pasta `root` e clique em "Save".
5. Aguarde alguns minutos e copie o link que aparecerá na seção "Pages".


Algo parecido com a imagem abaixo:

![Alt text](images/github-pages.png?raw=true "GitHub Pages")

Pronto, o nosso repositorio de Helm Charts está configurado e pronto para ser utilizado!

Um coisa importante é alterar o `index.yaml` para que ele aponte para o endereço do GitHub Pages, e para isso, execute o comando abaixo:

```bash
helm repo index --url <URL do seu repo no github> .
```

Com isso, o seu `index.yaml` estará apontando para o endereço do GitHub Pages, do contrário o seu repositório não funcionará.

Agora que já temos o nosso repositório de Helm Charts, vamos ver como utilizá-lo.

#### Utilizando o nosso repositório de Helm Charts

Deu trabalho, mas agora já temos o nosso repo de Helm Charts criado com sucesso, porém ainda não sabemos qual o seu gostinho, afinal ainda não utilizamos ele.

Vamos resolver isso!

Primeira coisa, para que possamos utilizar o Chart de um determinado repositório, precisamos adicionar esse repositório ao Helm, e para isso, execute o comando abaixo:

```bash
helm repo add meu-repo <URL do seu repo no github>
```

Vamos listar os repositórios que temos no Helm:

```bash
helm repo list
```

A minha saída:

```bash
NAME            URL                                              
metrics-server  https://kubernetes-sigs.github.io/metrics-server/
kyverno         https://kyverno.github.io/kyverno/               
meurepo         https://badtuxx.github.io/charts-example/  
```

Veja que o nosso repo está lá! Além do nosso repo, temos mais dois outros repos adicionados por mim anteriomente, que são o `metrics-server` e o `kyverno`. É com esse comando que conseguimos ver todos os repositórios que temos no Helm.

Podemos listar os Charts que temos no nosso repositório da seguinte maneira:

```bash
helm search repo meu-repo
```

A saída:

```bash
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
meure2po/giropops-senhas        0.1.0           0.1.0           Esse é o chart do Giropops-Senhas, utilizados n...
```

O nosso está lá, e o melhor, pronto para ser utilizado!

Agora, caso você queria instalar o Chart do Giropops-Senhas, basta executar o comando abaixo:

```bash
helm install giropops-senhas meu-repo/giropops-senhas
```

E pronto, o seu Chart já está instalado e funcionando!

Caso você queira personalizar o seu Chart, basta criar um arquivo `values.yaml` e passar as configurações que você deseja, e depois passar esse arquivo para o Helm, da seguinte maneira:

```bash
helm install giropops-senhas meu-repo/giropops-senhas -f values.yaml
```

E para atualizar um Chart que já está instalado, basta executar o comando abaixo:

```bash
helm upgrade giropops-senhas meu-repo/giropops-senhas
```

Quer ver os detalhes do seu Chart? Execute o comando abaixo:

```bash
helm show all meu-repo/giropops-senhas
```

O que teremos será uma descrição do nosso Chart, com todas as informações que definimos no `Chart.yaml` e no `values.yaml`, algo como a saida abaixo:
  
```bash
apiVersion: v2
appVersion: 0.1.0
description: Esse é o chart do Giropops-Senhas, utilizados nos laboratórios de Kubernetes.
name: giropops-senhas
sources:
- https://github.com/badtuxx/giropops-senhas
version: 0.1.0

---
giropopsSenhas:
  name: "giropops-senhas"
  image: "linuxtips/giropops-senhas:1.0"
  replicas: "3"
  port: 5000
  labels:
    app: "giropops-senhas"
    env: "labs"
    live: "true"
  service:
    type: "NodePort"
    port: 5000
    targetPort: 5000
    name: "giropops-senhas-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"

redis:
  image: "redis"
  replicas: 1
  port: 6379
  labels:
    app: "redis"
    env: "labs"
    live: "true"
  service:
    type: "ClusterIP"
    port: 6379
    targetPort: 6379
    name: "redis-port"
  resources:
    requests:
      memory: "128Mi"
      cpu: "250m"
    limits:
      memory: "256Mi"
      cpu: "500m"
```

E por fim, caso você queira remover o seu Chart, basta executar o comando abaixo:

```bash
helm uninstall giropops-senhas
```

Simples como voar! Sim, eu sei, chega a ser lacrimejante, mas agora eu já posso dizer que você domina o Helm!

#### O que vimos no dia de hoje

Hoje o dia foi intenso, pois conseguimos descomplicar como usar o Helm para deixar a nossa vida ainda melhor. Aprendemos a criar um Chart do zero, utilizando diversas técnicas e deixando muito conhecimento para que você possa utilizar em sua vida! 
Agora eu quero que você me manda algum Chart que você criou com o que você aprendeu por aqui! Deixa o tio Jefinho feliz! hahahha

E por hoje é só! #VAIIII
