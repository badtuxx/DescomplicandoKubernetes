# Descomplicando o Kubernetes
## DAY-10: Descomplicando Ingress com TLS, Labels, Annotations e o Cert-manager
&nbsp;

## Conteúdo do Day-10
&nbsp;

### O que iremos ver hoje?

Agora que você já sabe o que é o ingress e como ele funciona, vamos adicionar o Cert-Manager com o Let's Encrypt ao cluster e criar um certificado SSL para o nosso domínio. Além disso, vamos aprender o que são e como funcionam as `Annotations` e `Labels` no Kubernetes.


&nbsp;
### Conteúdo do Day-10

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-10: Descomplicando Ingress com TLS, Labels, Annotations e o Cert-manager](#day-10-descomplicando-ingress-com-tls-labels-annotations-e-o-cert-manager)
    - [Conteúdo do Day-10](#conteúdo-do-day-10)
        - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
- [O que é o Cert-Manager?](#o-que-é-o-cert-manager)
    - [Instalando e configurando o Cert-Manager](#instalando-e-configurando-o-cert-manager)
    - [Configurando o Ingress para usar o Cert-Manager e ter o HTTPS](#configurando-o-ingress-para-usar-o-cert-manager-e-ter-o-https)
- [O que são os Annotations e as Labels no Kubernetes?](#o-que-são-os-annotations-e-as-labels-no-kubernetes)
    - [Explorando um pouco mais as Labels](#explorando-um-pouco-mais-as-labels)
    - [Explorando as Annotations no Kubernetes](#explorando-as-annotations-no-kubernetes)
    - [Adicionando Autenticação ao Ingress](#adicionando-autenticação-ao-ingress)
    - [Configurando Affinity Cookie no Ingress](#configurando-affinity-cookie-no-ingress)
    - [Configurando Upsream Hashing no Ingress](#configurando-upsream-hashing-no-ingress)
    - [Canary Deployments com o Ingress no Kubernetes](#canary-deployments-com-o-ingress-no-kubernetes)
    - [Limitando requisições as nossas aplicações com o Ingress](#limitando-requisições-as-nossas-aplicações-com-o-ingress)
- [Final do Day-10](#final-do-day-10)

&nbsp;

# O que é o Cert-Manager?

O `Cert-Manager` é um controlador do Kubernetes que automatiza a solicitação, emissão, renovação e rotação de certificados TLS de uma maneira muito fácil. Ele é capaz de gerenciar certificados de diferentes autoridades de certificação, como o Let's Encrypt, Venafi, Vault, entre outros. Além disso, o `Cert-Manager` é um projeto open-source membro da Cloud Native Computing Foundation (CNCF).

O `Cert-Manager` utiliza dois tipos recursos do Kubernetes para gerenciar os certificados TLS: `Issuers` e `ClusterIssuers`. Os `Issuers` são recursos que permitem a emissão de certificados para um único namespace, enquanto os `ClusterIssuers` permitem a emissão de certificados para todos os namespaces do cluster.

Enquanto estamos desenvolvendo a nossa aplicação, é uma boa prática utilizar um `Issuer` para o ambiente de desenvolvimento e um `ClusterIssuer` para o ambiente de produção. Dessa forma, podemos testar a emissão de certificados no ambiente de desenvolvimento e garantir que tudo está funcionando corretamente antes de ir para o ambiente de produção. Já que a utilização de um `ClusterIssuer` de produção no ambiente de desenvolvimento pode acabar bloqueando a emissão de certificados devido aos limites pré-estabelecidos pela autoridade certificadora.

Vamos utilizar o `Let's Encrypt` como autoridade de certificação para o nosso ambiente de desenvolvimento, para isso precisamos entender como é feita a verificação do domínio. O `Let's Encrypt` utiliza o protocolo `ACME` (Automatic Certificate Management Environment) para verificar a propriedade do domínio. O `ACME` utiliza dois tipos de desafios para verificar a propriedade do domínio: `HTTP-01` e `DNS-01`.

O desafio `HTTP-01` é feito através da criação de um arquivo com um token específico no servidor web que está respondendo pelas requisições do domínio. Já o desafio `DNS-01` é feito através da criação de um registro `TXT` no servidor de DNS do domínio.

## Instalando e configurando o Cert-Manager

Para instalar o `Cert-Manager` no seu cluster, você pode utilizar o `Helm` ou instalar diretamente com o `kubectl`. No nosso caso, vamos instalar o `Cert-Manager` utilizando o `Kubectl`.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.yaml
```

Vamos confirmar se o `Cert-Manager` foi instalado corretamente.

```bash
kubectl get pods -n cert-manager
```

Com o `Cert-Manager` instalado, vamos criar o `Issuer` para o ambiente de desenvolvimento e o `ClusterIssuer` para o ambiente de produção.

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: example@mail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
```

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: example@mail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
```

Aplique os arquivos no seu cluster.

```bash
kubectl apply -f issuer-staging.yaml
kubectl apply -f cluster-issuer-prod.yaml
```

Com os `Issuers` e `ClusterIssuers` criados, podemos obter mais informações sobre eles.

```bash
kubectl get issuers
kubectl get clusterissuers
```

```bash
kubectl describe issuer letsencrypt-staging
kubectl describe clusterissuer letsencrypt-prod
```

## Configurando o Ingress para usar o Cert-Manager e ter o HTTPS

Já temos o `Cert-Manager` instalado e configurado, agora precisamos configurar o `Ingress` para utilizar o `Cert-Manager` e ter o HTTPS. Para isso, vamos criar um `Ingress` para a nossa aplicação e adicionar a anotação `cert-manager.io/cluster-issuer` utilizando o `ClusterIssuer` que criamos anteriormente.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - giropops.containers.expert
    secretName: giropops-containers-expert-tls
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

Aplique o arquivo no seu cluster.

```bash
kubectl apply -f ingress.yaml
```

Agora, vamos verificar se o `Cert-Manager` criou o certificado para o nosso domínio.

```bash
kubectl get certificates
kubectl describe certificate giropops-containers-expert-tls
```

Também é possível ver as `Order` criadas pelo `Cert-Manager` para a emissão do certificado.

```bash
kubectl get orders
kubectl describe order giropops-containers-expert-tls
```

Com o `Cert-Manager` configurado e o `Ingress` utilizando o `ClusterIssuer` para a emissão de certificados, a nossa aplicação já está disponível com o HTTPS. Podemos verificar o certificado acessando a aplicação pelo navegador e clicando no cadeado ao lado do domínio.

# O que são os Annotations e as Labels no Kubernetes?

As `Annotations` e `Labels` são recursos do Kubernetes que permitem adicionar metadados aos recursos do cluster. 

- As `Annotations` são pares chave-valor que podem ser utilizados para adicionar metadados adicionais aos recursos do cluster. Como por exemplo, adicionar informações sobre a versão da aplicação, parâmetros de configuração, entre outros.

- As `Labels` também são pares chave-valor, mas são utilizadas para identificar e selecionar recursos do cluster. Como por exemplo, adicionar uma label `app: giropops` para identificar todos os recursos relacionados a aplicação `giropops`.

## Explorando um pouco mais as Labels

As `Labels` são utilizadas para identificar e selecionar recursos do cluster. Elas são utilizadas para identificar recursos de maneira mais fácil e rápida. Por exemplo, podemos adicionar a label `jeferson: gostoso` para identificar os recursos relacionados a aplicação `giropops`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: giropops-senhas
  labels:
    app: giropops
    jeferson: gostoso
spec:
  replicas: 3
  selector:
    matchLabels:
      app: giropops
  template:
    metadata:
      labels:
        app: giropops
    spec:
      containers:
      - name: giropops-senhas
        image: containers-expert/giropops-senhas:1.0
        ports:
        - containerPort: 5000
```

Se quisermos listar os recursos que possuem a label `jeferson: gostoso`, podemos utilizar o comando `kubectl get` com a flag `--selector`.

```bash
kubectl get deployments --selector descomplicando=kubernetes
```

Nesse exemplo, adicionamos a label `jeferson: gostoso` ao `Deployment` da aplicação `giropops`. Mas e se quisermos adicionar a label `jeferson: gostoso` aos nossos `Pods`? Para isso, devemos adicionar a label no campo `metadata` do `Pod`, dentro de `spec`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: giropops-senhas
  labels:
    app: giropops
    jeferson: gostoso
spec:
  replicas: 3
  selector:
    matchLabels:
      app: giropops
  template:
    metadata:
      labels:
        app: giropops
        jeferson: gostoso
    spec:
      containers:
      - name: giropops-senhas
        image: containers-expert/giropops-senhas:1.0
        ports:
        - containerPort: 5000
```

Agora, se quisermos listar os `Pods` que possuem a label `jeferson: gostoso`, podemos utilizar o comando `kubectl get` com a flag `--selector`.

```bash
kubectl get pods --selector jeferson=gostoso
```

Ou podemos listar todos os recursos que possuem a label `jeferson: gostoso` utilizando o comando `kubectl get` com a flag `--selector` e o nome do recurso.

```bash
kubectl get all --selector jeferson=gostoso
```

Também podemos adicionar uma label utilizando o comando `kubectl label`. Vamos então adicionar a label `jeferson: lindo` ao `Pod` da aplicação `Redis`.

```bash
kubectl label pods redis jeferson=lindo
```

E se precisarmos mudar o valor da label `jeferson` para `gostoso`? Podemos utilizar o comando `kubectl label` com a flag `--overwrite`.

```bash
kubectl label pods redis jeferson=gosotoso --overwrite
```

E podemos remover uma label utilizando o comando `kubectl label` com a flag `-`.

```bash
kubectl label pods redis jeferson-
```

Para uma lista de todas as opções disponíveis para o comando `kubectl label`, você pode utilizar o comando `kubectl label --help`.

## Explorando as Annotations no Kubernetes

As `annotation` são utilizadas para adicionar metadados adicionais aos recursos do cluster. Elas são utilizadas para adicionar informações sobre a versão da aplicação, parâmetros de configuração, entre outros.

Vamos adicionar uma `annotation` ao `Pod` do `Redis` utilizando o comando `kubectl annotate`.

```bash
kubectl annotate pods redis description="Pod do redis para ser usado com o giropops-senhas"
```

Assim como subistituir o valor de uma `Label`, podemos subistituir o valor de uma `annotation` utilizando a flag `--overwrite`.

```bash
kubectl annotate pods redis description="Pod do redis" --overwrite
```

E para apagar uma `annotation` também é tão simples quanto apagar uma `Label`. Basta utilizar o comando `kubectl annotate` com a flag `-`.

```bash
kubectl annotate pods redis description-
```

Podemos utilizar o comando `kubectl describe` para ver as `annotations` e `Labels` de um recurso. Mas e se quisermos uma visão somente das `annotations`? Podemos utilizar o comando `kubectl get` com a flag `-o` com o formato `jsonpath`.

```bash
kubectl get pods redis -o jsonpath='{.metadata.annotations}'
```

Quando passamos o valor `{.metadata.annotations}` para a flag `-o jsonpath`, estamos pedindo para o `kubectl` retornar somente as `annotations` que estão no campo `metadata` do recurso `Pod` (identificado pelo `.`).

```bash
apiVersion: v1
kind: Pod
metadata:
  annotations:
    description: Pod do redis para ser usado com o giropops-senhas
```

## Adicionando Autenticação ao Ingress

Vamos adicionar autenticação ao `Ingress` utilizando as `Annotations` do `Nginx Ingress Controller`. Utilizaremos a autenticação do tipo `basic` e um `secret` para armazenar os usuários e senhas.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/auth-type: "basic"
    nginx.ingress.kubernetes.io/auth-secret: "giropops-senhas-users"
    nginx.ingress.kubernetes.io/auth-realm: "Autenicação necessária"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - giropops.containers.expert
    secretName: giropops-containers-expert-tls
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

Agora, vamos criar o usuário e a senha para a autenticação utilizando o comando `htpasswd` do `Apache`.

```bash
htpasswd -c auth jeferson
```

O comando `htpasswd` irá pedir para você digitar a senha do usuário. Após digitar a senha, o arquivo `auth` será criado no diretório onde você executou o comando. Agora, vamos criar um `secret` no Kubernetes com o arquivo `auth`.

```bash
kubectl create secret generic giropops-senhas-users --from-file=auth
```

Aplique o arquivo no seu cluster.

```bash
kubectl apply -f ingress2.yaml
```

Agora, a nossa aplicação `giropops-senhas` está protegida com autenticação do tipo `basic`. Se você tentar acessar a aplicação pelo navegador, será solicitado um usuário e senha.

## Configurando Affinity Cookie no Ingress

Algumas vezes, precisamos garantir que um usuário sempre seja direcionado para o mesmo `Pod` da aplicação. Uma das maneiras de fazer isso é utilizando o `Affinity Cookie` do `Nginx Ingress Controller`. O `Affinity Cookie` é um cookie que é adicionado na resposta do `Pod` e utilizado para direcionar o usuário para o mesmo `Pod` na próxima requisição.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    # nginx.ingress.kubernetes.io/auth-type: "basic"
    # nginx.ingress.kubernetes.io/auth-secret: "giropops-senhas-users"
    # nginx.ingress.kubernetes.io/auth-realm: "Autenicação necessária"
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "giropops-cookie"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - giropops.containers.expert
    secretName: giropops-containers-expert-tls
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

Aplique o arquivo no seu cluster.

```bash
kubectl apply -f ingress3.yaml
```

Para testar o `Affinity Cookie`, vamos utilizar o comando `curl` com a flag `-v` para ver os cabeçalhos da resposta.

```bash
curl -v https://giropops.containers.expert
```

Na saída do comando `curl` você verá a linha `set-Cookie` com o valor `giropops-cookie`. Esse é o cookie que será utilizado para direcionar o usuário para o mesmo `Pod` na próxima requisição.

## Configurando Upsream Hashing no Ingress

Além do `Affinity Cookie`, o `Nginx Ingress Controller` também suporta o `Upsream Hashing`. O `Upsream Hashing` é uma técnica mais avançada que utiliza um valor do cabeçalho da requisição para direcionar o usuário para o mesmo `Pod` da aplicação. No nosso exemplo, vamos utilizar o `$request_uri` para identificar o `Pod` que irá responder a requisição por meio da URI da requisição.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    # nginx.ingress.kubernetes.io/auth-type: "basic"
    # nginx.ingress.kubernetes.io/auth-secret: "giropops-senhas-users"
    # nginx.ingress.kubernetes.io/auth-realm: "Autenicação necessária"
    # nginx.ingress.kubernetes.io/affinity: "cookie"
    # nginx.ingress.kubernetes.io/session-cookie-name: "giropops-cookie"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - giropops.containers.expert
    secretName: giropops-containers-expert-tls
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

Aplique o arquivo no seu cluster.

```bash
kubectl apply -f ingress4.yaml
```

Além do `$request_uri`, o `Nginx Ingress Controller` suporta outros mérodos para o `Upsream Hashing`. Você pode ver a lista completa na documentação do `Nginx Ingress Controller`.

## Canary Deployments com o Ingress no Kubernetes

Os `Canary Deployments` são uma técnica de implantação que permite testar uma nova versão da aplicação em um subconjunto de usuários antes de implantar a nova versão para todos os usuários. No Kubernetes, podemos utilizar o `Ingress` para fazer `Canary Deployments` utilizando a anotação `nginx.ingress.kubernetes.io/canary` e `nginx.ingress.kubernetes.io/canary-weight`.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas-canary
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    # nginx.ingress.kubernetes.io/auth-type: "basic"
    # nginx.ingress.kubernetes.io/auth-secret: "giropops-senhas-users"
    # nginx.ingress.kubernetes.io/auth-realm: "Autenicação necessária"
    # nginx.ingress.kubernetes.io/affinity: "cookie"
    # nginx.ingress.kubernetes.io/session-cookie-name: "giropops-cookie"
    # nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
    # cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - giropops.containers.expert
    secretName: giropops-containers-expert-tls
  rules:
    - host: giropops.containers.expert
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service: 
                name: nginx
                port:
                  number: 80
```

Como estamos direcionando o tráfego para o `Nginx`, precisamos criar o nosso `Pod` e expor ele, vamos utilizar os comandos `kubectl run` e `kubectl expose`:

```bash
kubectl run nginx --image=nginx --port=80
```

```bash
kubectl expose deployment nginx --port=80
```

Agora vamos criar o `Ingress` no nosso cluster que vai ser responsável por gerenciar o tráfego do `Canary Deployment` para o `Pod` do `Nginx`.

```bash
kubectl apply -f ingress5.yaml
```

Acessando a aplicação pelo navegador, você verá que 10% das requisições estão indo para o `Pod` do `Nginx`. Isso é o `Canary Deployment` em ação. Você pode aumentar o peso do `Canary Deployment`, alterando o valor da anotação `nginx.ingress.kubernetes.io/canary-weight` para o valor desejado.

Você pode utilizar o `Canary Deployment` em conjunto com o `Affinity Cookie` e/ou `Upsream Hashing` para garantir que o usuário sempre seja direcionado para o mesmo `Pod` durante o `Canary Deployment`, garantindo que ele sempre veja a mesma versão da aplicação.

## Limitando requisições das nossas aplicações com o Ingress

Outra funcionalidade interessante do `Nginx Ingress Controller` é a capacidade de limitar o número de requisições que uma aplicação pode receber. Isso é útil para proteger a aplicação de ataques de negação de serviço (DDoS) e garantir que a aplicação sempre esteja disponível para os usuários.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/limit-rps: "2"
    nginx.ingress.kubernetes.io/rewrite-target: /
    # nginx.ingress.kubernetes.io/auth-type: "basic"
    # nginx.ingress.kubernetes.io/auth-secret: "giropops-senhas-users"
    # nginx.ingress.kubernetes.io/auth-realm: "Autenicação necessária"
    # nginx.ingress.kubernetes.io/affinity: "cookie"
    # nginx.ingress.kubernetes.io/session-cookie-name: "giropops-cookie"
    # nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    # cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - giropops.containers.expert
    secretName: giropops-containers-expert-tls
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

Aplique o arquivo no seu cluster.

```bash
kubectl apply -f ingress6.yaml
```

Agora, a nossa aplicação `giropops-senhas` está limitada a 2 requisições por segundo. Se você tentar fazer mais de 2 requisições por segundo, você verá o erro `503 Service Temporarily Unavailable`. Claro que utilizar o valor `2` para o `limit-rps` pode não ser o ideal, você deve ajustar o valor para o que for mais adequado para a sua aplicação.


## Final do Day-10

Durante o Day-10 você aprendeu como adicionar o `Cert-Manager` ao seu cluster e criar um certificado SSL para o seu domínio. Além disso, vimos o que são e como funcionam as `Annotations` e `Labels` no Kubernetes. Como adicionar a autenticação com usuário e senha. O `Affinity Cookie` e `Upsream Hashing` para direcionar o usuário para o mesmo `Pod` sempre que necessário. O `Canary Deployments` para testar uma nova versão da aplicação em um subconjunto de usuários antes de implantar a nova versão para todos os usuários. E por fim, você aprendeu como limitar as requisições nas suas aplicações com o `limit-rps`.

&nbsp;