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
| *Banco de dados chave valor* |

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

O ETCD como os demais serviços do Kuberentes utiliza uma certificados PKI para autenticação sobre TLS, essas chaves são declaradas no manifesto de configução em:

kubectl describe pod etcd-docker-01 -n kube-system

```
--cert-file
--key-file
--trusted-ca-file
```

Essas chaves vão ser utilizadas pelos demais componentes do cluster como por exemplo o API Server possam conectar e fazerem alteraçoes.

kubectl describe pod kube-apiserver -n kube-system

```
--etcd-cafile
--etcd-certfile
--etcd-keyfile
```

Então para toda interação com o ETCD vamos precisar utililizar esses certificados para nos autenticar.

# Interagindo com o ETCD

Para interarir com o ETCD vamos precisar o etcdctl ou utilizar o proprio container do etcd com o ```kubectl exec```

https://github.com/etcd-io/etcd/tree/master/etcdctl

Baixando a ultima verção do etcd


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

Como vimos anteriormente vamos precisar utilizar utilizar os certificados para nos conectar, vamos passsar os dados nos seguistes parametros:

```
--cacert
--key
--cert
```

Além disso vamos precisar do endpoint, caso esteja no container do ETCD seu endpoint será 127.0.0.1:2379
O sua URL para o endpoint vai estar na flag ```--advertise-client-urls``` nas configuraçoes do ETCD

O comando vai ser da seguinte forma:
```
ETCDCTL_API=3 etcdctl \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--key /etc/kubernetes/pki/etcd/server.key \
--cert /etc/kubernetes/pki/etcd/server.crt \
--endpoints $ADVERTISE_URL \
```

# Backup do ETCD no Kubernetes

Como sabemos, o ETCD é responsável por armazenar todo tipo de informação sobre o estado do nosso cluster.

Para realizarmos o backup (snapshot) do ETCD, precisamos utilizar alguns comandos built-in que já vem com o próprio ETCD. 

Esse snapshot, contém todos os dados do estado do cluster.

Para realizar o snapshot do ETCD sem **TLS habilitado**, precisamos executar o seguinte comando.

ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshotdb

Onde:

ETCDCTL_API=3 - versão do command line que queremos usar;

etcdctl - command line do cliente ETCD;

$ENDPOINT - Variável utilizada para o backup de onde o ETCD está em execução;
Nesse caso, o valor do endpoint será: [127.0.0.1:2379]  - Esse é o valor default de onde o ETCD está rodando no nó master com a porta padrão do ETCD, 2379;

snapshot - parâmetro utilizado para gerar o snapshot;

save - informamos que queremos realizar um save desse snapshot;

snapshotdb - nome do nosso snapshot;

Logo, nosso comando ficaria:

ETCDCTL_API=3 etcdctl --endpoints=[127.0.0.1:2379] snapshot save snapshotdb



ETCDCTL_API=3 etcdctl --write-out=table snapshot status snapshotdb
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| fe01cf57 |       10 |          7 | 2.1 MB     |
+----------+----------+------------+------------+


Existem algumas diferenças ao realizar o snapshot do ETCD com o **TLS habilitado** que são obrigatórias:

Além do --endpoits, precisamos adicionar as chaves e certificados referentes ao TLS que são:

--cacert - verifica os certificados dos servidores que estão com TLS habilitados;

--cert - identifica o cliente usando o certificado TLS;

--endpoints=[127.0.0.1:2379] - novamente, esse é o valor default de onde o ETCD está rodando no nó master com a porta padrão do ETCD, 2379;         This is the default as ETCD is running on master node and exposed on localhost 2379.

--key - identifica o cliente usando a chave TLS;
