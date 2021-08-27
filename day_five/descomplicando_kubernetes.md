
# Descomplicando Kubernetes dia 5

## Sumário

- [Ingress](#ingress)
- [RASCUNHO](#rascunho)

# Ingress

Normalmente quando executamos um Pod no Kubernetes, todo o tráfego é roteado somente pela rede do cluster, e todo tráfego externo acaba sendo descartado ou encaminhado para outro local. Um ingress é um conjunto de regras para permitir que as conexões externas de entrada atinjam os serviços dentro do cluster

Vamos criar nosso primeiro Ingress, mas primeiro vamos gerar dois deployments e dois services:

```
vim app1.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - image: dockersamples/static-site
        name: app1
        env:
        - name: AUTHOR
          value: GIROPOPS
        ports:
        - containerPort: 80
```

```
vim app2.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - image: dockersamples/static-site
        name: app2
        env:
        - name: AUTHOR
          value: STRIGUS
        ports:
        - containerPort: 80
```

Vamos criar os deployments no cluster com os seguintes comandos:

```
kubectl create -f app1.yaml 

deployment.apps/app1 created
```

```
kubectl create -f app2.yaml 

deployment.apps/app2 created
```

```
vim svc-app1.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: appsvc1
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: app1
```

```
vim svc-app2.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: appsvc2
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: app2
```

Vamos criar os services no cluster com os seguintes comandos:

```
kubectl create -f svc-app1.yaml 

service/appsvc1 created
```

```
kubectl create -f svc-app2.yaml 

service/appsvc2 created
```

Acabamos de criar dois Pods com imagens de um site estático.

Vamos visualizar os deployments:

```
kubectl get deploy

NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
app1      2         2         2            2           3m
app2      2         2         2            2           3m
```

Vamos visualizar os services:

```
kubectl get services

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
appsvc1      ClusterIP   10.107.228.40   <none>        80/TCP    2m
appsvc2      ClusterIP   10.97.250.131   <none>        80/TCP    2m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   11d
```

Vamos listar os Endpoints dos services:

```
kubectl get ep

NAME         ENDPOINTS                     AGE
appsvc1      10.44.0.11:80,10.44.0.12:80   4m
appsvc2      10.32.0.4:80,10.44.0.13:80    4m
kubernetes   10.142.0.5:6443               11d
```

Agora vamos acessar os sites e ver se tudo deu certo com as variáveis de ambiente que  configuramos nos Deployments.

```
curl 10.44.0.11

...
<h1 id="toc_0">Hello GIROPOPS!</h1>

<p>This is being served from a <b>docker</b><br>
container running Nginx.</p>
```

```
curl  10.32.0.4
h1 id="toc_0">Hello STRIGUS!</h1>

<p>This is being served from a <b>docker</b><br>
container running Nginx.</p>
```

Vamos criar um deployment para o backend:

```
vim default-backend.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: default-backend
  template:
    metadata:
      labels:
        app: default-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-backend
        image: gcr.io/google_containers/defaultbackend:1.0
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
```

Atenção para os seguintes parâmetros no arquivo anterior:

* **terminationGracePeriodSeconds** => Tempo em segundos que ele irá aguardar o pod ser finalizado com o sinal SIGTERM, antes de realizar a finalização forçada com o sinal de SIGKILL.
* **livenessProbe** => Verifica se o pod continua em execução, caso não esteja, o ``kubelet`` irá remover o contêiner e iniciará outro em seu lugar.
* **readnessProbe** => Verifica se o container está pronto para receber requisições vindas do service.
* **initialDelaySeconds** => Diz ao ``kubelet`` quantos segundos ele deverá aguardar para realizar a execução da primeira checagem da livenessProbe
* **timeoutSeconds** => Tempo em segundos que será considerado o timeout da execução da probe, o valor padrão é 1.
* **periodSeconds** => Determina de quanto em quanto tempo será realizada a verificação do livenessProbe.

Crie o namespace ``ingress``:

```
kubectl create namespace ingress

namespace/ingress created
```

Crie o deployment do backend no namespace ``ingress``:

```
kubectl create -f default-backend.yaml -n ingress 

deployment.apps/default-backend created
```

Crie um arquivo para definir um service para o backend:

```
vim default-backend-service.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: default-backend
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: default-backend
```

Crie o service para o backend no namespace ``ingress``:

```
kubectl create -f default-backend-service.yaml -n ingress 

service/default-backend created
```

Visualize novamente os deployments no namespace ``default``:

```
kubectl get deployments.

NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
app1      2         2         2            2           29m
app2      2         2         2            2           28m
```

Visualize o deployment no namespace ``ingress``:

```
kubectl get deployments. -n ingress

NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
default-backend   2         2         2            2           27s
```

Visualize novamente os services no namespace ``default``:

```
kubectl get service

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
appsvc1      ClusterIP   10.98.174.69    <none>        80/TCP    28m
appsvc2      ClusterIP   10.96.193.198   <none>        80/TCP    28m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   11d
```

Visualize o service no namespace ``ingress``:

```
kubectl get service -n ingress

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
default-backend   ClusterIP   10.99.233.157   <none>        80/TCP    38s
```

Visualize o endpoint no namespace ``ingress``:

```
kubectl get ep -n ingress

NAME              ENDPOINTS                        AGE
default-backend   10.32.0.14:8080,10.40.0.4:8080   2m
```

Agora crie o um arquivo para definir um ``configMap`` a ser utilizado pela nossa aplicação:

```
vim nginx-ingress-controller-config-map.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-ingress-controller-conf
  labels:
    app: nginx-ingress-lb
data:
  enable-vts-status: 'true'
```

Crie o configMap no namespace ``ingress``:

```
kubectl create -f nginx-ingress-controller-config-map.yaml -n ingress

configmap/nginx-ingress-controller-conf created
```

Visualize o configMap no namespace ``ingress``:

```
kubectl get configmaps -n ingress

NAME                            DATA      AGE
nginx-ingress-controller-conf   1         20s
```

Visualize os detalhes do configMap recém criado no namespace ``ingress``:

```
kubectl describe configmaps nginx-ingress-controller-conf -n ingress

Name:         nginx-ingress-controller-conf
Namespace:    ingress
Labels:       app=nginx-ingress-lb
Annotations:  <none>
Data
====
enable-vts-status:
----
true
Events:  <none>
```

Vamos criar os arquivos para definir as permissões para o nosso deployment:

```
vim nginx-ingress-controller-service-account.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx
  namespace: ingress
```

```
vim nginx-ingress-controller-clusterrole.yaml
```

Informe o seguinte conteúdo:

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nginx-role
rules:
- apiGroups:
  - ""
  - "extensions"
  resources:
  - configmaps
  - secrets
  - endpoints
  - ingresses
  - nodes
  - pods
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - list
  - watch
  - get
  - update
- apiGroups:
  - "extensions"
  resources:
  - ingresses
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
- apiGroups:
  - "extensions"
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - create
```

```
vim nginx-ingress-controller-clusterrolebinding.yaml
```

Informe o seguinte conteúdo:

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nginx-role
  namespace: ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-role
subjects:
- kind: ServiceAccount
  name: nginx
  namespace: ingress
```

Aplique as permissões no namespace ``ingress`` com os seguintes comandos:

```
kubectl create -f nginx-ingress-controller-service-account.yaml -n ingress 

serviceaccount/nginx created
```

```
kubectl create -f nginx-ingress-controller-clusterrole.yaml -n ingress

clusterrole.rbac.authorization.k8s.io/nginx-role created
```

```
kubectl create -f nginx-ingress-controller-clusterrolebinding.yaml -n ingress 

clusterrolebinding.rbac.authorization.k8s.io/nginx-role created
```

Visualize os serviceAccount e roles recém criados no namespace ``ingress`` com os seguintes comandos:

```
kubectl get serviceaccounts -n ingress
```

```
kubectl get clusterrole -n ingress
```

```
kubectl get clusterrolebindings -n ingress
```

Agora crie um arquivo para definir outro deployment:

```
vim nginx-ingress-controller-deployment.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-ingress-lb
  revisionHistoryLimit: 3
  template:
    metadata:
      labels:
        app: nginx-ingress-lb
    spec:
      terminationGracePeriodSeconds: 60
      serviceAccount: nginx
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.9.0
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
          livenessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            timeoutSeconds: 5
          args:
            - /nginx-ingress-controller
            - --default-backend-service=ingress/default-backend
            - --configmap=ingress/nginx-ingress-controller-conf
            - --v=2
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - containerPort: 80
            - containerPort: 18080
```

Crie o deployment no namespace ``ingress``:

```
kubectl create -f nginx-ingress-controller-deployment.yaml -n ingress

deployment.apps/nginx-ingress-controller created
```

Visualize o deployment recém criado no namespace ``ingress``:

```
kubectl get deployments -n ingress

NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
default-backend            2         2         2            2           53m
nginx-ingress-controller   1         1         1            1           23s
```

Visualize todos os pods:

```
kubectl get pods --all-namespaces

NAMESPACE     NAME                                        READY     STATUS    RESTARTS   AGE
default       app1-6b65555ff9-s7dh4                       1/1       Running   0          1h
default       app1-6b65555ff9-z6wj6                       1/1       Running   0          1h
default       app2-d956f58df-dp79f                        1/1       Running   0          1h
default       app2-d956f58df-fsjtf                        1/1       Running   0          1h
ingress       default-backend-5cb55f8865-2wp5m            1/1       Running   0          54m
ingress       default-backend-5cb55f8865-9jgr4            1/1       Running   0          54m
ingress       nginx-ingress-controller-65fbdc747b-mlb9k   1/1       Running   0          1m
```

Agora crie um arquivo para definir o ingress que redirecionará para o backend:

```
vim nginx-ingress.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: ec2-54-198-119-88.compute-1.amazonaws.com # Mude para o seu endereço dns
    http:
      paths:
      - backend:
          service:
            name: nginx-ingress
            port:
              number: 18080
        path: /nginx_status
        pathType: Prefix
```

Agora crie um arquivo para definir o ingress que redirecionará para os serviços das aplicações que criamos no início desta seção:

```
vim app-ingress.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: app-ingress
spec:
  rules:
  - host: ec2-54-198-119-88.compute-1.amazonaws.com # Mude para o seu endereço dns
    http:
      paths:
      - backend:
          service:
            name: appsvc1
            port:
              number: 80
        path: /app1
        pathType: Prefix
      - backend:
          service:
            name: appsvc2
            port:
              number: 80
        path: /app2
        pathType: Prefix
```

Crie os ingresses no namespace ``ingress`` e ``default`` com os seguintes comandos, respectivamente:

```
kubectl create -f nginx-ingress.yaml -n ingress

ingress.networking.k8s.io/nginx-ingress created
```

```
kubectl create -f app-ingress.yaml

ingress.networking.k8s.io/app-ingress created
```

Visualize os ingresses recém criados:

```
kubectl get ingresses -n ingress

NAME            HOSTS                                        ADDRESS   PORTS     AGE
nginx-ingress   ec2-54-159-116-229.compute-1.amazonaws.com             80        35s
```

```
kubectl get ingresses

NAME          HOSTS                                        ADDRESS   PORTS     AGE
app-ingress   ec2-54-159-116-229.compute-1.amazonaws.com             80        16s
```

Visualize os detalhes do ingress que redireciona para o backend no namespace ``ingress``:

```
kubectl describe ingresses.extensions nginx-ingress -n ingress

Name:             nginx-ingress
Namespace:        ingress
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                                        Path  Backends
  ----                                        ----  --------
  ec2-54-159-116-229.compute-1.amazonaws.com
                                              /nginx_status   nginx-ingress:18080 (<none>)
Annotations:
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  CREATE  50s   nginx-ingress-controller  Ingress ingress/nginx-ingress
```

Visualize os detalhes do ingress que redireciona para a aplicação no namespace ``default``:

```
kubectl describe ingresses.extensions app-ingress

Name:             app-ingress
Namespace:        default
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                                        Path  Backends
  ----                                        ----  --------
  ec2-54-159-116-229.compute-1.amazonaws.com
                                              /app1   appsvc1:80 (<none>)
                                              /app2   appsvc2:80 (<none>)
Annotations:
  nginx.ingress.kubernetes.io/rewrite-target:  /
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  CREATE  1m    nginx-ingress-controller  Ingress default/app-ingress
```

Crie um arquivo para definir um service do tipo nodePort:

```
vim nginx-ingress-controller-service.yaml
```

Informe o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30000
      name: http
    - port: 18080
      nodePort: 32000
      name: http-mgmt
  selector:
    app: nginx-ingress-lb
```

Agora crie o service do tipo nodePort:

```
kubectl create -f nginx-ingress-controller-service.yaml -n=ingress

service/nginx-ingress created
```

Pronto! Agora você já pode acessar suas apps pela URL que você configurou. Abra o navegador e adicione os seguintes endereços:

```
http://SEU-ENDEREÇO:30000/app1

http://SEU-ENDEREÇO:30000/app2

http://SEU-ENDEREÇO:32000/nginx_status
```

Ou ainda via curl:

```
curl http://SEU-ENDEREÇO:30000/app1

curl http://SEU-ENDEREÇO:30000/app2

curl http://SEU-ENDEREÇO:32000/nginx_status
```

---

# RASCUNHO

Caso você queira fazer a instalação utilizando o repositório do Jeferson, ao invés de criar todos os arquivos, abaixo os comandos necessários para realizar o deploy:

Criando o Cluster:

```
curl -fsSL https://get.docker.com | bash
vim /etc/modules-load.d/k8s.conf
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >  /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo kubeadm config images pull
sudo kubeadm init
mkdir -p $HOME/.kube
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
cat /etc/modules-load.d/k8s.conf
sudo modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs
kubectl get nodes
```

Realizando o clone do repositório:

```
git clone https://github.com/badtuxx/ingress.git
```

Iniciando o deploy de nossa app e também do Nginx Ingress.

```
cd ingress/
kubectl create -f app-deployment.yaml
kubectl create -f app-service.yaml
kubectl get pods
kubectl get ep
kubectl create namespace ingress
kubectl create -f default-backend-deployment.yaml -n ingress
kubectl create -f default-backend-service.yaml -n ingress
kubectl get deployments. -n ingress
kubectl get service
kubectl get service -n ingress
kubectl create -f nginx-ingress-controller-config-map.yaml -n ingress
kubectl create -f nginx-ingress-controller-roles.yaml -n ingress
kubectl create -f nginx-ingress-controller-deployment.yaml -n ingress
kubectl create -f nginx-ingress-controller-service.yaml -n=ingress
kubectl get pods
kubectl get pods -n ingress
kubectl create -f nginx-ingress.yaml -n ingress
kubectl create -f app-ingress.yaml
kubectl get pods -n ingress
kubectl get pods
kubectl get services
kubectl get services -n ingress
kubectl get ingress
kubectl get deploy
kubectl get deploy -n ingress
```

Pronto! Agora você já pode acessar suas apps pela URL que você configurou. Abra o navegador e adicione os seguintes endereços:

```
http://SEU-ENDEREÇO:30000/app1

http://SEU-ENDEREÇO:30000/app2

http://SEU-ENDEREÇO:32000/nginx_status
```

Ou ainda via curl:

```
curl http://SEU-ENDEREÇO:30000/app1

curl http://SEU-ENDEREÇO:30000/app2

curl http://SEU-ENDEREÇO:32000/nginx_status
```