# O que preciso saber antes de começar?

ETCD é um dos componentes fundamentais que fazem o kubernetes funcionar.

# O que é o ETCD?

Basicamente, o ETCD é um database de armazenamento de chave-valor de alta disponibilidade.

Em um banco de dados relacional, nós temos colunas e dentro das colunas nós temos o tipo de informação que está sendo armazenada;

| ![Banco de dados relacional](https://cdn.hswstatic.com/gif/relational-database-chart.jpg)|
|:--:| 
| *Banco de dados relacional* |

Em um banco de dados de chave-valor, quando consultamos e obtemos a chave, é retornado o valor atribuido à aquela chave.

| ![Banco de dados chave valor](https://upload.wikimedia.org/wikipedia/commons/5/5b/KeyValue.PNG)|
|:--:| 
| *Banco de dados chave-valor* |

Quando consultamos a chave k1, o resultado  retornado é o valor : AAA,BBB,CCC

Quando consultamos a chave k5, o resultado retornado é o valor : 3,ZZZ,5623

# ETCD no Kubernetes

No kubernetes, o ETCD é responsável por registrar todo tipo de informação do cluster, como nodes, roles, pods, configs, accounts, secrets, etc. 

Quando o cluster é iniciado pelo ***kubeadm***, um pod do etcd é criado no master node.

Toda informação que é apresentada ao usuário quando executado "kubect get" são informações armazenadas no ETCD.

Vejamos se o *pod etcd* foi criado com sucesso com o comando ```kubectl get pods -n kube-system```:

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

# Certificados ETCD

O ETCD como os demais serviços do Kuberentes utilizam certificados PKI para autenticação sobre TLS, essas chaves são declaradas no manifesto de configuração em:

kubectl describe pod etcd-docker-01 -n kube-system

```
--cert-file
--key-file
--trusted-ca-file
```

Essas chaves vão ser utilizadas pelos demais componentes do cluster como por exemplo o API Server possam conectar e fazerem alterações.

kubectl describe pod kube-apiserver -n kube-system

```
--etcd-cafile
--etcd-certfile
--etcd-keyfile
```

Então para toda e qualquer interação com o ETCD vamos precisar utililizar esses certificados para nos autenticar.

# Interagindo com o ETCD

Para interagir com o ETCD vamos precisar o etcdctl ou utilizar o próprio container do etcd com o ```kubectl exec```

https://github.com/etcd-io/etcd/tree/master/etcdctl

Baixando a ultima versão do etc:

Linux:
```
ETCD_VER=v3.4.7

GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/tmp/etcd-download-test/etcd --version
/tmp/etcd-download-test/etcdctl version
```
https://github.com/etcd-io/etcd/releases

Como vimos anteriormente vamos precisar utilizar os certificados para nos autenticar, vamos fornecer os dados nos seguistes parâmetros no comando:
```
--cacert
--key
--cert
```

Além disso vamos precisar do endpoint, caso esteja no container do ETCD seu endpoint será 127.0.0.1:2379
O sua URL para o endpoint vai estar na flag ```--advertise-client-urls``` nas configurações do ETCD.

ETCDCTL:
```
ETCDCTL_API=3 etcdctl \
--cacert /var/lib/minikube/certs/etcd/ca.crt \
--key /var/lib/minikube/certs/etcd/server.key \
--cert /var/lib/minikube/certs/etcd/server.crt \
--endpoints $ADVERTISE_URL \
get / --prefix --keys-only
```

kubectl exec:
```
kubectl exec -it etcd-minikube -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/minikube/certs/etcd/ca.crt --key=/var/lib/minikube/certs/etcd/server.key --cert=/var/lib/minikube/certs/etcd/server.crt get / --prefix --keys-only
```

Output:
```
/registry/apiregistration.k8s.io/apiservices/v1.

/registry/apiregistration.k8s.io/apiservices/v1.admissionregistration.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.apiextensions.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.apps

/registry/apiregistration.k8s.io/apiservices/v1.authentication.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.authorization.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.autoscaling

/registry/apiregistration.k8s.io/apiservices/v1.batch

/registry/apiregistration.k8s.io/apiservices/v1.coordination.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.rbac.authorization.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.scheduling.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.storage.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1beta1.admissionregistration.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1beta1.apiextensions.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1beta1.authentication.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1beta1.authorization.k8s.io
```

Aqui temos uma parte do conteúdo da  resposta do get no "/" do ETCD, onde listamos todas as chaves do etcd. 

Em um exemplo um pouco mais pratico vamos listar apenas as chaves dos pods no namespace default, o parâmetro para que o output contenha apenas as chaves é ```--keys-only```

```
kubectl exec -it etcd-minikube -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/minikube/certs/etcd/ca.crt --key=/var/lib/minikube/certs/etcd/server.key --cert=/var/lib/minikube/certs/etcd/server.crt get /registry/pods/default --prefix=true -keys-only
```

Output:
```
/registry/pods/default/nginx
```

Agora vamos ver os valores contidos na chave /registry/pods/default/nginx onde estão as configurações do pod. Vamos remover o parâmetro ```--keys-only``` para que possamos ver os valores da chave.

```
kubectl exec -it etcd-minikube -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/minikube/certs/etcd/ca.crt --key=/var/lib/minikube/certs/etcd/server.key --cert=/var/lib/minikube/certs/etcd/server.crt get /registry/pods/default/nginx --prefix=true
```

Output:

```
k8s

v1Pod�
�
nginxdefault"*$a748750e-7582-4db5-ab63-0fab1d0c91542����Z

runnginxz��
kubectlUpdatev����FieldsV1:�
�{"f:metadata":{"f:labels":{".":{},"f:run":{}}},"f:spec":{"f:containers":{"k:{\"name\":\"nginx\"}":{".":{},"f:image":{},"f:imagePullPolicy":{},"f:name":{},"f:resources":{},"f:terminationMessagePath":{},"f:terminationMessagePolicy":{}}},"f:dnsPolicy":{},"f:enableServiceLinks":{},"f:restartPolicy":{},"f:schedulerName":{},"f:securityContext":{},"f:terminationGracePeriodSeconds":{}}}��
kubeletUpdatev����FieldsV1:�
�{"f:status":{"f:conditions":{"k:{\"type\":\"ContainersReady\"}":{".":{},"f:lastProbeTime":{},"f:lastTransitionTime":{},"f:status":{},"f:type":{}},"k:{\"type\":\"Initialized\"}":{".":{},"f:lastProbeTime":{},"f:lastTransitionTime":{},"f:status":{},"f:type":{}},"k:{\"type\":\"Ready\"}":{".":{},"f:lastProbeTime":{},"f:lastTransitionTime":{},"f:status":{},"f:type":{}}},"f:containerStatuses":{},"f:hostIP":{},"f:phase":{},"f:podIP":{},"f:podIPs":{".":{},"k:{\"ip\":\"172.17.0.5\"}":{".":{},"f:ip":{}}},"f:startTime":{}}}�
1
default-token-657qb2
default-token-657qb��
nginxnginx*BJJ
default-token-657qb-/var/run/secrets/kubernetes.io/serviceaccount"2j/dev/termination-logrAlways����FileAlways 2
                                                                                                               ClusterFirstBdefaultJdefaultminikubeX`hr���default-scheduler�6
node.kubernetes.io/not-readyExists"	NoExecute(��8
node.kubernetes.io/unreachableExists"	NoExecute(�����
Running#

InitializedTru����*2
ReadyTru����*2'
ContainersReadyTru����*2$

PodScheduledTru����*2"*
                       192.168.64.22
172.17.0.����B�
nginx


���� (2
       nginx:latest:_docker-pullable://nginx@sha256:86ae264c3f4acb99b2dee4d0098c40cb8c46dcf9e1148f05d3a51c4df6758c12BIdocker://4f42eaab397e862432c01d66d44b6e2d395ffae5e5dd16cfb83d906b3fc5022bHJ
BestEffortZb


172.17.0.5"
```

Isso foi um pouco de como podemos interagir diretamente com o ETCD.

# Backup do ETCD no Kubernetes

Como sabemos, o ETCD é responsável por armazenar todo tipo de informação sobre o estado do nosso cluster.

Para realizarmos o backup (snapshot) do ETCD, precisamos utilizar alguns comandos built-in que já vem com o próprio ETCD. 

Esse snapshot, contém todos os dados do estado do cluster.

Para realizar o snapshot do ETCD sem a autenticação **TLS habilitado**, precisamos executar o seguinte comando.

```
ETCDCTL_API=3 etcdctl \
--endpoints $ENDPOINT \
snapshot save snapshotdb
```

 ```
 ETCDCTL_API=3 etcdctl \
--write-out=table \
snapshot status snapshotdb

+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| fe01cf57 |       10 |          7 | 2.1 MB     |
+----------+----------+------------+------------+
```


Existem algumas diferenças ao realizar o snapshot do ETCD com o **TLS habilitado** que são obrigatórias:

Além do --endpoits, precisamos adicionar as chaves e certificados referentes ao TLS que são:

--cacert - verifica os certificados dos servidores que estão com TLS habilitados;

--cert - identifica o cliente usando o certificado TLS;

--endpoints=[127.0.0.1:2379] - novamente, esse é o valor default de onde o ETCD está rodando no nó master com a porta padrão do ETCD, 2379;         This is the default as ETCD is running on master node and exposed on localhost 2379.

--key - identifica o cliente usando a chave TLS;
