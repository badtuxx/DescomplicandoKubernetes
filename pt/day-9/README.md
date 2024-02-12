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
    - [O que está acontecendo com o nosso Ingress?](#o-que-está-acontecendo-com-o-nosso-ingress)
    - [Configurando um Ingress para a nossa aplicação em Flask com Redis](#configurando-um-ingress-para-a-nossa-aplicação-em-flask-com-redis)
    - [Criando múltiplos Ingresses no mesmo Ingress Controller](#criando-múltiplos-ingresses-no-mesmo-ingress-controller)
- [Instalando um cluster EKS para os nossos testes com Ingress](#instalando-um-cluster-eks-para-os-nossos-testes-com-ingress)
  - [Instalando um cluster EKS para os nossos testes com Ingress](#instalando-um-cluster-eks-para-os-nossos-testes-com-ingress)
  - [Entendendo os Contexts do Kubernetes para gerenciar vários clusters](#entendendo-os-contexts-do-kubernetes-para-gerenciar-vários-clusters)
  - [Instalando o Ingress Nginx Controller no EKS](#instalando-o-ingress-nginx-controller-no-eks)
  - [Conhecendo o ingressClassName e configurando um novo Ingress](#conhecendo-o-ingressclassname-e-configurando-um-novo-ingress)
  - [Configurando um domínio válido para o nosso Ingress no EKS](#configurando-um-domínio-válido-para-o-nosso-ingress-no-eks)
- [Final do Day-9](#final-do-day-9)

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

### O que está acontecendo com o nosso Ingress?

Se você tentar acessar o endereço do seu Ingress, você verá que a aplicação não está funcionando corretamente. Para resolvermos isso precisamos entender melhor como o Ingress funciona.

Isso está acontecendo porque o Ingress Controller está encaminhando as requisições para o serviço `giropops-senhas`, mas a aplicação está esperando que as requisições sejam feitas para `/`, e não para `/giropops-senhas`.

Poderíamos resolver isso em contato com o time de desenvolvimento, colocando em práctica a cultura DevOps, alterando o código da aplicação para que ela funcione com o Ingress.

Mas vamos supor que o time de desenvolvimento não tenha tempo para isso, ou que a aplicação seja de terceiros, e não tenhamos acesso ao código fonte. Nesse caso, podemos "resolver" criando um novo recurso de Ingress, que irá encaminhar as requisições do `/static` para o `/` removendo a anotação `nginx.ingress.kubernetes.io/rewrite-target: /` 

Crie um arquivo chamado `ingress-2.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas-static
  annotations:
spec:
  rules:
  - http:
      paths:
      - path: /static
        pathType: Prefix
        backend:
          service: 
            name: giropops-senhas
            port:
              number: 5000

```

Agora vamos aplicar esse novo recurso de Ingress:

```bash
kubectl apply -f ingress-2.yaml
```

Podemos testar novamente:

```bash
curl ENDEREÇO_DO_INGRESS/static
```

Agora sim, a aplicação está funcionando. Não é a melhor solução, mas resolveu o problema. Lembrando que isso é apenas um exemplo, e que o ideal é que o time de desenvolvimento faça as alterações necessárias para que a aplicação funcione corretamente com o Ingress.

### Configurando um Ingress para a nossa aplicação em Flask com Redis

Nossa aplicação agora está carregando o CSS e o JS, mas ainda não está funcionando corretamente. Isso porque a aplicação está tentando se conectar ao Redis através do endereço `localhost`, e não está encontrando o Redis.

Então vamos criar um novo recurso de Ingress, indicando que o nosso `path` agora é `/` e não mais o `/giropops-senhas`.

Comece removendo os recursos que criamos anteriormente:

```bash
kubectl delete ingress giropops-senhas giropops-senhas-static
```

Agora crie um novo arquivo chamado `ingress-3.yaml`:

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
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: giropops-senhas
            port:
              number: 5000
```

Agora vamos aplicar esse novo recurso de Ingress:

```bash
kubectl apply -f ingress-3.yaml
```

Podemos testar novamente:

```bash
curl ENDEREÇO_DO_INGRESS
```

Com isso, a nossa aplicação está funcionando corretamente. Você pode acessar o endereço do seu Ingress no navegador, e testar a aplicação, inclusive gerando senhas.

### Criando múltiplos Ingresses no mesmo Ingress Controller

No exemplo anterior, criamos um Ingress para a nossa aplicação rodar no endereço `/`. Mas e se quisermos rodar mais de uma aplicação no mesmo Ingress Controller? Como faríamos?

Vamos supor que queremos rodar a nossa aplicação do NGINX no endereço `giropops.nginx.io`, enquanto a nossa aplicação em Flask com Redis continua rodando no `localhost`.

A primeira coisa que precisamos é criar o nosso Pod e o nosso Service para o NGINX. 

```bash
kubectl run nginx --image=nginx --port=80
```

```bash
kubectl expose pod nginx
```

Agora vamos criar o nosso Ingress para o NGINX. Crie um arquivo chamado `ingress-4.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: giropops.nginx.io
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: nginx
            port:
              number: 80
```

Agora vamos aplicar esse novo recurso de Ingress:

```bash
kubectl apply -f ingress-4.yaml
```

Como estamos usando o Kind, precisamos editar o arquivo `/etc/hosts` para que o endereço `giropops.nginx.io` aponte para o endereço IP do nosso Ingress. Para isso, execute:

```bash
sudo vim /etc/hosts
```

Adicione a linha abaixo no arquivo:

```bash
ENDEREÇO_IP_DO_INGRESS giropops.nginx.io
```

Agora vamos testar:

```bash
curl giropops.nginx.io
```

Podemos adicionar um novo Ingress para a nossa aplicação em Flask com Redis. Crie um arquivo chamado `ingress-5.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: giropops-senhas.io
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

Agora vamos aplicar esse novo recurso de Ingress:

```bash
kubectl apply -f ingress-5.yaml
```

Não se esqueça de editar o arquivo `/etc/hosts` para que o endereço `giropops-senhas.io` aponte para o endereço IP do nosso Ingress. Para isso, execute:

```bash
sudo vim /etc/hosts
```

Adicione a linha abaixo no arquivo:

```bash
ENDEREÇO_IP_DO_INGRESS giropops-senhas.io
```

Podemos testar que as duas aplicações estão funcionando corretamente acessando os endereços `giropops.nginx.io` e `giropops-senhas.io` no navegador.

# Instalando um cluster EKS para os nossos testes com Ingress

## Instalando um cluster EKS para os nossos testes com Ingress

Agora que já sabemos como criar um Ingress, e como ele funciona, vamos criar um cluster EKS para testar o Ingress utilizando o eksctl, que é uma ferramenta oficial da AWS para criar clusters EKS.

Para instalar o eksctl, siga as instruções do link: https://eksctl.io/installation/

Após instalar o eksctl, podemos criar o nosso cluster EKS com o comando:

```bash
eksctl create cluster --name=eks-cluster --version=1.24 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

## Entendendo os Contexts do Kubernetes para gerenciar vários clusters

Quando você está trabalhando com mais de um cluster Kubernetes, é importante entender como os contextos funcionam. Um contexto é um conjunto de parâmetros que determinam como interagir com um cluster Kubernetes. Isso inclui o cluster, o usuário e o namespace.

Você pode listar os contextos disponíveis no seu ambiente com o comando:

```bash
kubectl config get-contexts
```

Você pode ver qual é o contexto atual com o comando:

```bash
kubectl config current-context
```

Você pode mudar o contexto atual com o comando:

```bash
kubectl config use-context NOME_DO_CONTEXTO
```

## Instalando o Ingress Nginx Controller no EKS

Com o nosso cluster EKS criado, podemos instalar o Ingress Nginx Controller e fazer o deploy da nossa aplicação. 

Para instalar o Ingress Nginx Controller no EKS, vamos seguir o comando da documentação oficial do Nginx Ingress Controller para AWS:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml
```

Você pode utilizar a opção `wait` do `kubectl`, assim quando os pods estiverem prontos, ele irá liberar o shell, veja:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

A instalação do Ingress Nginx Controller no EKS já cria um LoadBalancer automaticamente na AWS, então podemos ver o endereço público do LoadBalancer com o comando:

```bash
kubectl get services -n ingress-nginx
```

Sempre utilize os logs para verificar se o Ingress Controller está funcionando corretamente:

```bash
kubectl logs -f -n ingress-nginx POD_DO_INGRESS_CONTROLLER
```

Acessando o endereço público do LoadBalancer no navegador, você verá a página padrão do Nginx Ingress Controller. Mas não é isso que queremos ver, queremos ver a nossa aplicação rodando. Então vamos fazer o deploy da nossa aplicação e criar um recurso de Ingress para ela.

```bash
kubectl apply -f app-deployment.yaml
kubectl apply -f app-service.yaml
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml
```

## Conhecendo o ingressClassName e configurando um novo Ingress 

O Ingress Class é um recurso do Kubernetes que permite que você defina qual controlador de Ingress deve ser utilizado para um determinado recurso de Ingress. Isso é útil quando você tem mais de um controlador de Ingress no seu cluster, e quer que um recurso de Ingress seja tratado por um controlador específico.

Até agora, nós não definimos um Ingress Class, já que no Kind temos apenas um controlador de Ingress, o Nginx Ingress Controller. Mas quando estamos trabalhando com um cluster EKS, precisamos obrigatoriamente definir um Ingress Class.

Vamos utilizar o arquivo `ingress-6.yaml` para criar um novo recurso de Ingress para a nossa aplicação:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: giropops-senhas
            port:
              number: 5000
```

Agora vamos aplicar esse novo recurso de Ingress:

```bash
kubectl apply -f ingress-6.yaml
```

Como não definimos um domínio válido para o nosso Ingress, vamos acessar a aplicação através do endereço do LoadBalancer. Você pode obter o endereço através do comando:

```bash
kubectl get ingress
```

## Configurando um domínio válido para o nosso Ingress no EKS

Já que estamos trabalhando com um cluster EKS, e queremos acessar a nossa aplicação através de um domínio, precisamos primeiro ter um domínio válido. Vamos utilizar como exemlo o https://containers.expert para criarmos o subdomínio https://giropops.containers.expert.

Após configurar o subdomínio no seu provedor de DNS, você pode criar um novo recurso de Ingress com o domínio configurado. Vamos utilizar o arquivo `ingress-7.yaml` para criar um novo recurso de Ingress para a nossa aplicação:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: giropops.containers.expert
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

Agora vamos aplicar esse novo recurso de Ingress:

```bash
kubectl apply -f ingress-7.yaml
```

Com nosso domínio e o Ingress configurados, podemos acessar a aplicação através do endereço https://giropops.containers.expert.

# Final do Day-9

Com isso, finalizamos o nosso Day-9. Nós vimos o que é o Ingress, como ele funciona, o que são as classes de Ingress, e como configurar um Ingress no Kubernetes, no Kind e na AWS com EKS. Espero que você tenha aprendido bastante sobre o Ingress, e que esteja pronto para aplicar esse conhecimento no seu dia a dia. Não esqueça de praticar tudo o que aprendeu, e de compartilhar esse conhecimento com outras pessoas.