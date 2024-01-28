# Descomplicando o Kubernetes
## DAY-9: Descomplicando o Ingress no Kubernetes

## Conteúdo do Day-9
&nbsp;

## O que iremos ver hoje?

Se você está aqui, provavelmente já tem alguma noção do que o Kubernetes faz. Mas como expor seus serviços ao mundo externo de forma eficiente e segura? É aí que entra o nosso protagonista do dia: o Ingress. Nesta seção, vamos desvendar o que é o Ingress, para que serve e como ele se diferencia de outras formas de expor aplicações no Kubernetes.


&nbsp;
### Conteúdo do Day-9

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-9: Descomplicando o Ingress no Kubernetes](#day-9-descomplicando-o-ingress-no-kubernetes)
  - [Conteúdo do Day-9](#conteúdo-do-day-9)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
    - [Conteúdo do Day-9](#conteúdo-do-day-9-1)
- [O Que é o Ingress?](#o-que-é-o-ingress)
  - [O que é Ingress?](#o-que-é-ingress)
- [Componentes do Ingress](#componentes-do-ingress)
  - [Componentes Chave](#componentes-chave)
    - [Ingress Controller](#ingress-controller)
    - [Ingress Resources](#ingress-resources)
    - [Annotations e Customizations](#annotations-e-customizations)
    - [Instalando um Nginx Ingress Controller](#instalando-um-nginx-ingress-controller)
      - [Instalando o Nginx Ingress Controller no Kind](#instalando-o-nginx-ingress-controller-no-kind)
          - [Criando o Cluster com Configurações Especiais](#criando-o-cluster-com-configurações-especiais)
        - [Instalando um Ingress Controller](#instalando-um-ingress-controller)
    - [Instalando o Giropops-Senhas no Cluster](#instalando-o-giropops-senhas-no-cluster)
    - [Criando um Recurso de Ingress](#criando-um-recurso-de-ingress)
- [TBD](#tbd)

&nbsp;


# O Que é o Ingress?

## O que é Ingress?

O Ingress é um recurso do Kubernetes que gerencia o acesso externo aos serviços dentro de um cluster. Ele funciona como uma camada de roteamento HTTP/HTTPS, permitindo a definição de regras para direcionar o tráfego externo para diferentes serviços back-end. O Ingress é implementado através de um controlador de Ingress, que pode ser alimentado por várias soluções, como NGINX, Traefik ou Istio, para citar alguns.

Tecnicamente, o Ingress atua como uma abstração de regras de roteamento de alto nível que são interpretadas e aplicadas pelo controlador de Ingress. Ele permite recursos avançados como balanceamento de carga, SSL/TLS, redirecionamento, reescrita de URL, entre outros.

Principais Componentes e Funcionalidades:
Controlador de Ingress: É a implementação real que satisfaz um recurso Ingress. Ele pode ser implementado através de várias soluções de proxy reverso, como NGINX ou HAProxy.

**Regras de Roteamento:** Definidas em um objeto YAML, essas regras determinam como as requisições externas devem ser encaminhadas aos serviços internos.

**Backend Padrão:** Um serviço de fallback para onde as requisições são encaminhadas se nenhuma regra de roteamento for correspondida.

**Balanceamento de Carga:** Distribuição automática de tráfego entre múltiplos pods de um serviço.

**Terminação SSL/TLS:** O Ingress permite a configuração de certificados SSL/TLS para a terminação de criptografia no ponto de entrada do cluster.

**Anexos de Recurso:** Possibilidade de anexar recursos adicionais como ConfigMaps ou Secrets, que podem ser utilizados para configurar comportamentos adicionais como autenticação básica, listas de controle de acesso etc.


# Componentes do Ingress

Agora que já sabemos o que é o Ingress e o porquê de usá-lo, é hora de mergulharmos nos componentes que o compõem. Como um bom "porteiro" do nosso cluster Kubernetes, o Ingress não trabalha sozinho; ele é composto por várias "peças" que orquestram o tráfego. Vamos explorá-las!

## Componentes Chave

### Ingress Controller

O Ingress Controller é o motor por trás do objeto Ingress. Ele é responsável por aplicar as regras de roteamento definidas no recurso de Ingress. Exemplos populares incluem Nginx Ingress Controller, Traefik e HAProxy Ingress.

### Ingress Resources

Os Ingress Resources são as configurações que você define para instruir o Ingress Controller sobre como o tráfego deve ser roteado. Estas são definidas em arquivos YAML e aplicadas no cluster.

### Annotations e Customizations

Annotations permitem personalizar o comportamento padrão do seu Ingress. Você pode, por exemplo, forçar o redirecionamento de HTTP para HTTPS, ou ainda adicionar políticas de segurança, como proteção contra ataques DDoS.

### Instalando um Nginx Ingress Controller

Vamos instalar o Nginx Ingress Controller. É importante observar a versão do Ingress Controller que você está instalando, pois as versões mais recentes ou mais antigas podem não ser compatíveis com o Kubernetes que você está usando. Para este tutorial, vamos usar a versão 1.9.5.
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

No comando acima, estamos esperando que os pods do Ingress Controller estejam prontos, com o label `app.kubernetes.io/component=controller`, no namespace `ingress-nginx`, e caso não estejam prontos em 90 segundos, o comando irá falhar.

#### Instalando o Nginx Ingress Controller no Kind

KinD é uma ferramenta muito útil para testes e desenvolvimento com Kubernetes. Nesta seção atualizada, fornecemos detalhes específicos para garantir que o Ingress funcione como esperado em um cluster KinD.

###### Criando o Cluster com Configurações Especiais

Ao criar um cluster KinD, podemos especificar várias configurações que incluem mapeamentos de portas e rótulos para nós.

1. Crie um arquivo chamado `kind-config.yaml` com o conteúdo abaixo:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
```

2. Em seguida, crie o cluster usando este arquivo de configuração:

```bash
kind create cluster --config kind-config.yaml
```

##### Instalando um Ingress Controller

Vamos continuar usando o Nginx Ingress Controller como exemplo, que é amplamente adotado e bem documentado.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

Você pode utilizar a opção `wait` do `kubectl`, assim quando os pods estiverem prontos, ele irá liberar o shell, veja:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

No comando acima, estamos esperando que os pods do Ingress Controller estejam prontos, com o label `app.kubernetes.io/component=controller`, no namespace `ingress-nginx`, e caso não estejam prontos em 90 segundos, o comando irá falhar.


### Instalando o Giropops-Senhas no Cluster

Para a instalação do Giropops-Senhas, vamos utilizar os arquivos abaixo:

Arquivo: app-deployment.yaml

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
        env:
        - name: REDIS_HOST
          value: redis-service
        ports:
        - containerPort: 5000
        imagePullPolicy: Always
```

Arquivo: app-service.yaml

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
      targetPort: 5000
      name: tcp-app
  type: ClusterIP
```

Arquivo: redis-deployment.yaml

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

Arquivo: redis-service.yaml

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

Com os arquivos acima, estamos criando um Deployment e um Service para o Giropops-Senhas, e um Deployment e um Service para o Redis.

Para aplicar, basta executar:

```bash
kubectl apply -f app-deployment.yaml
kubectl apply -f app-service.yaml
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml
```

Para verificar se os pods estão rodando, execute:

```bash
kubectl get pods
```

Para verificar se os serviços estão rodando, execute:

```bash
kubectl get services
```

Você pode acessar a app do Giropops-Senhas através do comando:

```bash
kubectl port-forward service/giropops-senhas 5000:5000
```

Isso se você estiver usando o Kind, caso contrário, você precisa pegar o endereço IP do seu Ingress, que veremos mais adiante.

Para testar, você pode acessar o endereço http://localhost:5000 no seu navegador.

### Criando um Recurso de Ingress

Agora, vamos criar um recurso de Ingress para nosso serviço `giropops-senhas` criado anteriormente. Crie um arquivo chamado `ingress-1.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /giropops-senhas
        pathType: Prefix
        backend:
          service: 
            name: giropops-senhas
            port:
              number: 5000

```

Após criar o arquivo, aplique-o:

```bash
kubectl apply -f ingress-1.yaml
```

Agora vamos ver se o nosso Ingress foi criado corretamente:

```bash
kubectl get ingress
```

Para ver com mais detalhes, você pode usar o comando `describe`:

```bash
kubectl describe ingress giropops-senhas
```

Tanto na saída do comando `get` quanto na saída do comando `describe`, você deve ver o endereço IP do seu Ingress no campo `Address`.

Você pode pegar esse IP através do comando:

```bash
kubectl get ingress giropops-senhas -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Caso você esteja utilizando um cluster gerenciado por algum provedor de nuvem, como o GKE, você pode utilizar o comando:

```bash
kubectl get ingress giropops-senhas -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Isso porque quando você possui um cluster EKS, AKS, GCP, etc, o Ingress Controller irá criar um LoadBalancer para você, e o endereço IP do LoadBalancer será o endereço IP do seu Ingress, simples assim.

Para testar, você pode usar o comando curl com o IP, hostname ou load balancer do seu Ingress:

```bash
curl ENDEREÇO_DO_INGRESS/giropops-senhas
```

# TBD