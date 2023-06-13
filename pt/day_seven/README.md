# Descomplicando o Kubernetes

## DAY-7
&nbsp;

&nbsp;
## Conteúdo do Day-7

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-7](#day-7)
  - [Conteúdo do Day-7](#conteúdo-do-day-7)
    - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
      - [O que é um StatefulSet?](#o-que-é-um-statefulset)
        - [Quando usar StatefulSets?](#quando-usar-statefulsets)
        - [E como ele funciona?](#e-como-ele-funciona)
        - [O StatefulSet e os volumes persistentes](#o-statefulset-e-os-volumes-persistentes)
        - [O StatefulSet e o Headless Service](#o-statefulset-e-o-headless-service)
        - [Criando um StatefulSet](#criando-um-statefulset)
        - [Excluindo um StatefulSet](#excluindo-um-statefulset)
        - [Excluindo um Headless Service](#excluindo-um-headless-service)
        - [Excluindo um PVC](#excluindo-um-pvc)
      - [Services](#services)
        - [Tipos de Services](#tipos-de-services)
        - [Como os Services funcionam](#como-os-services-funcionam)
        - [Os Services e os Endpoints](#os-services-e-os-endpoints)
        - [Criando um Service](#criando-um-service)
          - [ClusterIP](#clusterip)
          - [NodePort](#nodeport)
          - [LoadBalancer](#loadbalancer)
          - [ExternalName](#externalname)
        - [Verificando os Services](#verificando-os-services)
        - [Verificando os Endpoints](#verificando-os-endpoints)
        - [Removendo um Service](#removendo-um-service)
    - [A sua lição de casa](#a-sua-lição-de-casa)
  - [Final do Day-7](#final-do-day-7)

&nbsp;

### O que iremos ver hoje?

Hoje é dia de falar sobre dois resources muito importantes para o Kubernetes, o `StatefulSet` e o `Service`.
Vamos mostrar como criar e administrar `StatefulSets` para que você possa criar aplicações que precisam manter a identidade do `Pod` e persistir dados em volumes locais. Caos bem comuns de uso de `StatefulSets` são bancos de dados, sistemas de mensageria e sistemas de arquivos distribuídos.

Outra peça super importante que iremos falar hoje é sobre o `Service`. O `Service` é um objeto que permite que você expor uma aplicação para o mundo externo. Ele é responsável por fazer o balanceamento de carga entre os `Pods` que estão sendo expostos e também por fazer a resolução de nomes DNS para os `Pods` que estão sendo expostos.
Temos diversos tipos de `Services` e iremos falar sobre eles hoje.

Então esteja preparado para uma viajem muito interessante sobre esses dois recursos que são muito importantes para o Kubernetes e para o dia a dia de uma pessoa que trabalha com ele.

#### O que é um StatefulSet?

Os `StatefulSets` são uma funcionalidade do Kubernetes que gerencia o deployment e o scaling de um conjunto de Pods, fornecendo garantias sobre a ordem de deployment e a singularidade desses Pods.

Diferente dos Deployments e Replicasets que são considerados stateless (sem estado), os `StatefulSets` são utilizados quando você precisa de mais garantias sobre o deployment e scaling. Eles garantem que os nomes e endereços dos Pods sejam consistentes e estáveis ao longo do tempo.

&nbsp;

##### Quando usar StatefulSets?

Os `StatefulSets` são úteis para aplicações que necessitam de um ou mais dos seguintes:

- Identidade de rede estável e única.
- Armazenamento persistente estável.
- Ordem de deployment e scaling garantida.
- Ordem de rolling updates e rollbacks garantida.
- Algumas aplicações que se encaixam nesses requisitos são bancos de dados, sistemas de filas e quaisquer aplicativos que necessitam de persistência de dados ou identidade de rede estável.

##### E como ele funciona?

Os `StatefulSets` funcionam criando uma série de Pods replicados. Cada réplica é uma instância da mesma aplicação que é criada a partir do mesmo spec, mas pode ser diferenciada por seu índice e hostname.

Ao contrário dos Deployments e Replicasets, onde as réplicas são intercambiáveis, cada Pod em um StatefulSet tem um índice persistente e um hostname que se vinculam a sua identidade.

Por exemplo, se um StatefulSet tiver um nome giropops e um spec com três réplicas, ele criará três Pods: giropops-0, giropops-1, giropops-2. A ordem dos índices é garantida. O Pod giropops-1 não será iniciado até que o Pod giropops-0 esteja disponível e pronto.

A mesma garantia de ordem é aplicada ao scaling e aos updates.

##### O StatefulSet e os volumes persistentes

Um aspecto chave dos `StatefulSets` é a integração com Volumes Persistentes. Quando um Pod é recriado, ele se reconecta ao mesmo Volume Persistente, garantindo a persistência dos dados entre as recriações dos Pods.

Por padrão, o Kubernetes cria um PersistentVolume para cada Pod em um StatefulSet, que é então vinculado a esse Pod para a vida útil do StatefulSet.

Isso é útil para aplicações que precisam de um armazenamento persistente e estável, como bancos de dados.

##### O StatefulSet e o Headless Service

Para entender a relação entre o StatefulSet e o Headless Service, é preciso primeiro entender o que é um Headless Service.

No Kubernetes, um serviço é uma abstração que define um conjunto lógico de Pods e uma maneira de acessá-los. Normalmente, um serviço tem um IP e encaminha o tráfego para os Pods. No entanto, um Headless Service é um tipo especial de serviço que não tem um IP próprio. Em vez disso, ele retorna diretamente os IPs dos Pods que estão associados a ele.

Agora, o que isso tem a ver com os `StatefulSets`?

Os `StatefulSets` e os `Headless Services` geralmente trabalham juntos no gerenciamento de aplicações stateful. O `Headless Service` é responsável por permitir a comunicação de rede entre os Pods em um `StatefulSet`, enquanto o ` gerencia o deployment e o scaling desses Pods.

Aqui está como eles funcionam juntos:

Quando um `StatefulSet` é criado, ele geralmente é associado a um `Headless Service`. Ele é usado para controlar o domínio DNS dos `Pods` criados pelo `StatefulSet`. Cada `Pod` obtém um nome de host DNS que segue o formato: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`. Isso permite que cada `Pod` seja alcançado individualmente.

Por exemplo, se você tiver um `StatefulSet` chamado giropops com três réplicas e um `Headless Service` chamado `nginx`, os `Pods` criados serão giropops-0, giropops-1, giropops-2 e eles terão os seguintes endereços de host DNS: giropops-0.nginx.default.svc.cluster.local, giropops-1.nginx.default.svc.cluster.local, giropops-2.nginx.default.svc.cluster.local.

Essa combinação de `StatefulSets` com `Headless Services` permite que aplicações `stateful`, como bancos de dados, tenham uma identidade de rede estável e previsível, facilitando a comunicação entre diferentes instâncias da mesma aplicação.

Bem, agora que você já entendeu como isso funciona, eu acho que já podemos dar os primeiros passos com o `StatefulSet`.

##### Criando um StatefulSet

Para a criação de um `StatefulSet` precisamos de um arquivo de configuração que descreva o `StatefulSet` que queremos criar. Não é possível criar um `StatefulSet` sem um manifesto yaml, diferente do que acontece com o `Pod` e o `Deployment`.

Para o nosso exemplo, vamos utilizar o Nginx como aplicação que será gerenciada pelo `StatefulSet`, e vamos fazer com que cada `Pod` tenha um volume persistente associado a ele, e com isso, vamos ter uma página web diferente para cada `Pod`.

Para isso, vamos criar o arquivo `nginx-statefulset.yaml` com o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: StatefulSet # Tipo do recurso que estamos criando, no caso, um StatefulSet
metadata:
  name: nginx
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates: # Como estamos utilizando StatefulSet, precisamos criar um template de volume para cada Pod, entã ao invés de criarmos um volume diretamente, criamos um template que será utilizado para criar um volume para cada Pod
  - metadata:
      name: www # Nome do volume, assim teremos o volume www-0, www-1 e www-2
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

&nbsp;

Agora, vamos criar o `StatefulSet` com o comando:

```bash
kubectl apply -f nginx-statefulset.yaml
```

&nbsp;

Para verificar se o `StatefulSet` foi criado, podemos utilizar o comando:

```bash
kubectl get statefulset
NAME    READY   AGE
nginx   3/3     2m38s
```

&nbsp;

Caso queira ver com mais detalhes, podemos utilizar o comando:

```bash
kubectl describe statefulset nginx

Name:               nginx
Namespace:          default
CreationTimestamp:  Thu, 18 May 2023 23:44:45 +0200
Selector:           app=nginx
Labels:             <none>
Annotations:        <none>
Replicas:           3 desired | 3 total
Update Strategy:    RollingUpdate
  Partition:        0
Pods Status:        3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /usr/share/nginx/html from www (rw)
  Volumes:  <none>
Volume Claims:
  Name:          www
  StorageClass:  
  Labels:        <none>
  Annotations:   <none>
  Capacity:      1Gi
  Access Modes:  [ReadWriteOnce]
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  112s  statefulset-controller  create Claim www-nginx-0 Pod nginx-0 in StatefulSet nginx success
  Normal  SuccessfulCreate  112s  statefulset-controller  create Pod nginx-0 in StatefulSet nginx successful
  Normal  SuccessfulCreate  102s  statefulset-controller  create Claim www-nginx-1 Pod nginx-1 in StatefulSet nginx success
  Normal  SuccessfulCreate  102s  statefulset-controller  create Pod nginx-1 in StatefulSet nginx successful
  Normal  SuccessfulCreate  96s   statefulset-controller  create Claim www-nginx-2 Pod nginx-2 in StatefulSet nginx success
  Normal  SuccessfulCreate  96s   statefulset-controller  create Pod nginx-2 in StatefulSet nginx successful

```

&nbsp;

Para verificar se os `Pods` foram criados, podemos utilizar o comando:

```bash
kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          24s
nginx-1   1/1     Running   0          14s
nginx-2   1/1     Running   0          8s
```

&nbsp;

O nosso `StatefulSet` está criado, mas ainda temos que criar o `Headless Service` para que possamos acessar os `Pods` individualmente, e para isso, vamos criar o arquivo `nginx-headless-service.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None # Como estamos criando um Headless Service, não queremos que ele tenha um IP, então definimos o clusterIP como None
  selector:
    app: nginx
```

&nbsp;

Pronto, arquivo criado, hora de criar o `Headless Service` com o comando:

```bash
kubectl apply -f nginx-headless-service.yaml
```

&nbsp;

Para verificar se o `Headless Service` foi criado, podemos utilizar o comando:

```bash
kubectl get service

```

&nbsp;

Caso queira ver com mais detalhes, podemos utilizar o comando:

```bash
kubectl describe service nginx
```

&nbsp;

Agora que já temos o `StatefulSet` e o `Headless Service` criados, podemos acessar cada `Pod` individualmente, para isso, vamos utilizar o comando:

```bash
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
```

&nbsp;

Agora vamos utilizar o comando `nslookup` para verificar o endereço IP de cada `Pod`, para isso, vamos utilizar o comando:

```bash
nslookup nginx-0.nginx
```

&nbsp;

Agora vamos acessar o `Pod` utilizando o endereço IP, para isso, vamos utilizar o comando:

```bash
wget -O- http://<endereço-ip-do-pod>
```

&nbsp;

Precisamos mudar a página web de cada `Pod` para que possamos verificar se estamos acessando o `Pod` correto, para isso, vamos utilizar o comando:

```bash
echo "Pod 0" > /usr/share/nginx/html/index.html
```

&nbsp;

Agora vamos acessar o `Pod` novamente, para isso, vamos utilizar o comando:

```bash
wget -O- http://<endereço-ip-do-pod>
```

&nbsp;

A saída do comando deve ser:

```bash
Connecting to <endereço-ip-do-pod>:80 (<endereço-ip-do-pod>:80)
Pod 0
```

&nbsp;

Caso queira, você pode fazer o mesmo para os outros `Pods`, basta mudar o número do `Pod` no comando `nslookup` e no comando `echo`.

&nbsp;

##### Excluindo um StatefulSet

Para excluir um `StatefulSet` precisamos utilizar o comando:

```bash
kubectl delete statefulset nginx
```

&nbsp;

Ou ainda podemos excluir o `StatefulSet` utilizando o comando:

```bash
kubectl delete -f nginx-statefulset.yaml
```

&nbsp;

##### Excluindo um Headless Service

Para excluir um `Headless Service` precisamos utilizar o comando:

```bash
kubectl delete service nginx
```

&nbsp;

Ou ainda podemos excluir o `Headless Service` utilizando o comando:

```bash
kubectl delete -f nginx-headless-service.yaml
```

&nbsp;

##### Excluindo um PVC

Para excluir um `Volume` precisamos utilizar o comando:

```bash
kubectl delete pvc www-0
```

&nbsp;




#### Services

Os Services no Kubernetes são uma abstração que define um conjunto lógico de Pods e uma política para acessá-los. Eles permitem que você exponha uma ou mais Pods para serem acessados por outros Pods, independentemente de onde eles estejam em execução no cluster.

Os Services são definidos usando a API do Kubernetes, normalmente através de um arquivo de manifesto YAML.

##### Tipos de Services

Existem quatro tipos principais de Services:

**ClusterIP** (padrão): Expõe o Service em um IP interno no cluster. Este tipo torna o Service acessível apenas dentro do cluster.

**NodePort**: Expõe o Service na mesma porta de cada Node selecionado no cluster usando NAT. Torna o Service acessível de fora do cluster usando <NodeIP>:<NodePort>.

**LoadBalancer**: Cria um balanceador de carga externo no ambiente de nuvem atual (se suportado) e atribui um IP fixo, externo ao cluster, ao Service.

**ExternalName**: Mapeia o Service para o conteúdo do campo externalName (por exemplo, foo.bar.example.com), retornando um registro CNAME com seu valor.

##### Como os Services funcionam

Os Services no Kubernetes fornecem uma abstração que define um conjunto lógico de Pods e uma política para acessá-los. Os conjuntos de Pods são determinados por meio de seletores de rótulo (Label Selectors). Embora cada Pod tenha um endereço IP único, esses IPs não são expostos fora do cluster sem um serviço.

Sempre é bom reforçar a importância dos `Labels` no Kubernetes, pois eles são a base para a maioria das operações no Kubernetes, então cuide com carinho dos seus `Labels`.

##### Os Services e os Endpoints

Como eu já disse, os Services no Kubernetes representam um conjunto estável de Pods que fornecem determinada funcionalidade. A principal característica dos Services é que eles mantêm um endereço IP estável e uma porta de serviço que permanecem constantes ao longo do tempo, mesmo que os Pods subjacentes sejam substituídos.

Para implementar essa abstração, o Kubernetes usa uma outra abstração chamada Endpoint. Quando um Service é criado, o Kubernetes também cria um objeto Endpoint com o mesmo nome. Esse objeto Endpoint rastreia os IPs e as portas dos Pods que correspondem aos critérios de seleção do Service.

Por exemplo, quando você cria um `Service` automaticamente é criado os `EndPoints` que representam os `Pods` que estão sendo expostos pelo `Service`.

Para você ver os `EndPoints` criados, você pode utilizar o comando:

```bash
kubectl get endpoints meu-service
```

&nbsp;

Nós vamos ver com mais detalhes mais pra frente, mas é importante você saber o que são os `EndPoints` e qual o papel deles no Kubernetes.

&nbsp;

##### Criando um Service

Para criar um `Service` precisamos utilizar o comando:

```bash
kubectl expose deployment MEU_DEPLOYMENT --port=80 --type=NodePort
```

&nbsp;

Perceba que no comando acima estamos criando um `Service` do tipo `NodePort`, ou seja, o `Service` será acessível de fora do cluster usando <NodeIP>:<NodePort>.

Estamos ainda passando o parâmetro `--port=80` para que o `Service` seja exposto na porta 80.

Ahhh, e não podemos esquecer de passar o nome do `Deployment` que queremos expor, no caso acima, estamos expondo o `Deployment` com o nome `MEU_DEPLOYMENT`. Estamos criando um `Service` para um Deployment, mas também podemos criar um `Service` para um `Pod`, um `ReplicaSet`, um `ReplicationController` ou até mesmo para outro `Service`.

Sim, para outro `Service`!

A criação de um serviço baseado em outro serviço é menos comum, mas existem algumas situações em que isso pode ser útil.

Um bom exemplo seria quando você quer mudar temporariamente o tipo de serviço de um `ClusterIP` para um `NodePort` ou `LoadBalancer` para fins de troubleshooting ou manutenção, sem alterar a configuração do serviço original. Nesse caso, você poderia criar um novo serviço que expõe o serviço `ClusterIP`, realizar suas tarefas e, em seguida, excluir o novo serviço, mantendo a configuração original intacta.

Outro exemplo é quando você quer expor o mesmo aplicativo em diferentes contextos, com diferentes políticas de acesso. Por exemplo, você pode ter um serviço `ClusterIP` para comunicação interna entre microserviços, um serviço `NodePort` para acesso a partir da rede interna de sua organização, e um serviço `LoadBalancer` para acesso a partir da internet. Nesse caso, todos os três serviços poderiam apontar para o mesmo conjunto de `Pods`, mas cada um deles forneceria um caminho de acesso diferente, com diferentes políticas de segurança e controle de acesso.

No entanto, esses são casos de uso bastante específicos. Na maioria dos cenários, você criaria serviços diretamente para expor `Deployments`, `StatefulSets` ou `Pods`.

&nbsp;

Vamos criar alguns `Services` para que você entenda melhor como eles funcionam e no final vamos para um exemplo mais completo utilizando como `Deployment` o Giropops-Senhas!

&nbsp;

###### ClusterIP

Para criar um serviço ClusterIP via kubectl, você pode usar o comando kubectl expose conforme mostrado abaixo:

```bash
kubectl expose deployment meu-deployment --port=80 --target-port=8080
```
Este comando criará um serviço ClusterIP que expõe o meu-deployment na porta 80, encaminhando o tráfego para a porta 8080 dos Pods deste deployment.

Para criar um serviço ClusterIP via YAML, você pode usar um arquivo como este:


```yaml
apiVersion: v1
kind: Service # Tipo do objeto, no caso, um Service
metadata:
  name: meu-service
spec:
  selector: # Seleciona os Pods que serão expostos pelo Service
    app: meu-app # Neste caso, os Pods com o label app=meu-app
  ports:
    - protocol: TCP
      port: 80 # Porta do Service
      targetPort: 8080 # Porta dos Pods
```

&nbsp;

Este arquivo YAML irá criar um serviço que corresponde aos Pods com o `label` `app=meu-app`, e encaminha o tráfego da porta 80 do serviço para a porta 8080 dos Pods. Perceba que estamos usando o `selector` para definir quais `Pods` serão expostos pelo `Service`.

Como não especificamos o campo `type`, o Kubernetes irá criar um `Service` do tipo `ClusterIP` por padrão.

Simples demais, não?


&nbsp;

###### NodePort

Para criar um serviço NodePort via CLI, você pode usar o comando kubectl expose com a opção --type=NodePort. Por exemplo:

```bash
kubectl expose deployment meu-deployment --type=NodePort --port=80 --target-port=8080
```

&nbsp;

Já para criar um serviço NodePort via YAML, você pode usar um arquivo como este:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: meu-service
spec:
  type: NodePort # Tipo do Service
  selector:
    app: meu-app
  ports:
    - protocol: TCP
      port: 80 # Porta do Service, que será mapeada para a porta 8080 do Pod
      targetPort: 8080 # Porta dos Pods
      nodePort: 30080   # Porta do Node, que será mapeada para a porta 80 do Service
```

&nbsp;

Aqui estamos especificando o campo `type` como `NodePort`, e também estamos especificando o campo `nodePort`, que define a porta do Node que será mapeada para a porta 80 do Service. Vale lembrar que a porta do Node deve estar entre 30000 e 32767, e quando não especificamos o campo `nodePort`, o Kubernetes irá escolher uma porta aleatória dentro deste range. :)

###### LoadBalancer

O Service do tipo LoadBalancer é uma das formas mais comuns de expor um serviço ao tráfego da internet no Kubernetes. Ele provisiona automaticamente um balanceador de carga do provedor de nuvem onde seu cluster Kubernetes está rodando, se houver algum disponível.


Para criar um serviço LoadBalancer via CLI, você pode usar o comando kubectl expose com a opção --type=LoadBalancer.

```bash
kubectl expose deployment meu-deployment --type=LoadBalancer --port=80 --target-port=8080
```

&nbsp;

Caso queira criar um serviço LoadBalancer via YAML, você pode usar um arquivo como este:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: meu-service
spec:
  type: LoadBalancer
  selector:
    app: meu-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

&nbsp;

Nada novo aqui, somente o fato que estamos pedindo para o Kubernetes criar um `Service` do tipo `LoadBalancer`.

ê deseja expor um serviço a ser acessado externamente por usuários ou sistemas que não estão dentro do seu cluster Kubernetes. Este tipo de serviço pode ser considerado quando:

- **Provedores de nuvem**: Seu cluster Kubernetes está hospedado em um provedor de nuvem que suporta balanceadores de carga, como AWS, GCP, Azure, etc. Nesse caso, quando um serviço do tipo LoadBalancer é criado, um balanceador de carga é automaticamente provisionado no provedor de nuvem.

- **Tráfego externo**: Você precisa que sua aplicação seja acessível fora do cluster. O LoadBalancer expõe uma IP acessível externamente que encaminha o tráfego para os pods do serviço.

É importante lembrar que o uso de `LoadBalancers` pode ter custos adicionais, pois você está usando recursos adicionais do seu cloud provider. Portanto, é sempre bom verificar os custos associados antes de implementar. ;)

&nbsp;

###### ExternalName

O tipo de serviço ExternalName é um pouco diferente dos outros tipos de serviço. Ele não expõe um conjunto de `Pods`, mas sim um nome de host externo. Por exemplo, você pode ter um serviço que expõe um banco de dados externo, ou um serviço que expõe um serviço de e-mail externo.

O tipo `ExternalName` é útil quando você deseja:

- **Criar um alias para um serviço externo:** Suponha que você tenha um banco de dados hospedado fora do seu cluster Kubernetes, mas você deseja que suas aplicações dentro do cluster se refiram a ele pelo mesmo nome, como se estivesse dentro do cluster. Nesse caso, você pode usar um ExternalName para criar um alias para o endereço do banco de dados.

- **Abstrair serviços dependentes do ambiente:** Outro uso comum para ExternalName é quando você tem ambientes diferentes, como produção e desenvolvimento, que possuem serviços externos diferentes. Você pode usar o mesmo nome de serviço em todos os ambientes, mas apontar para diferentes endereços externos.

Infelizmente ele é pouco usado por conta da falta de conhecimento das pessoas, mas com você não será assim, não é mesmo? :)

&nbsp;

Vamos criar um exemplo de `ExternalName` usando o kubectl expose:

```bash
kubectl create service externalname meu-service --external-name meu-db.giropops.com.br
```

&nbsp;

Onde estamos passando como parâmetro o nome do serviço, e o endereço externo que queremos expor para o cluster.

Agora, caso você queira criar um `ExternalName` via YAML, você pode usar um arquivo como este:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: meu-service
spec:
  type: ExternalName
  externalName: meu-db.giropops.com.br
```

&nbsp;

Aqui estamos especificando o campo `type` como `ExternalName`, e também estamos especificando o campo `externalName`, que define o endereço externo que queremos expor para o cluster, nada de outro mundo. :)

Ahhh, e lembre-se que o `ExternalName` não tem suporte para `selectors` ou `ports`, pois ele não expõe um conjunto de `Pods`, mas sim um nome de host externo. 

E lembre-se parte 2, o `ExternalName` aceita um nome de host válido de acordo com o `DNS (RFC-1123)`, que pode ser um nome de domínio ou um endereço IP.

&nbsp;


##### Verificando os Services

Agora que já criamos alguns `Services`, está na hora de aprender como ver os detalhes deles.

Para visualizar os Services em execução no seu cluster Kubernetes na namespace default, você pode usar o comando kubectl get services. Esse comando listará todos os Services, junto com informações básicas como o tipo de serviço, o endereço IP e a porta.

```bash
kubectl get services
```

&nbsp;

Caso queira pegar os `Services` de uma `namespace` específica, você pode usar o comando kubectl get services -n <namespace>. Por exemplo:

```bash
kubectl get services -n kube-system
```

&nbsp;

Para visualizar os `Services` em todas as `namespaces`, você pode usar o comando `kubectl get services --all-namespaces` ou `kubectl get services -A`.

```bash
kubectl get services -A
```

&nbsp;

Para visualizar os detalhes de um `Service` específico, você pode usar o comando kubectl describe service, passando o nome do `Service` como parâmetro. Por exemplo:

```bash
kubectl describe service meu-service
```

&nbsp;

##### Verificando os Endpoints

Os `Endpoints` são uma parte importante dos `Services`, pois eles são responsáveis por manter o mapeamento entre o `Service` e os `Pods` que ele está expondo.

Sabendo disso, bora aprender como ver os detalhes dos `Endpoints`.

Primeira coisa, para visualizar os `EndPoints` de determinado `Service`, você pode usar o comando abaixo:

```bash
kubectl get endpoints meu-service
```

&nbsp;

Para visualizar os `EndPoints` de todos os `Services`, você pode usar o comando abaixo:

```bash
kubectl get endpoints -A
```

&nbsp;

Agora, para ver os detalhes de um `Endpoints` específico, é simples como voar, basta usar o comando abaixo:

```bash
kubectl describe endpoints meu-service
```

&nbsp;


##### Removendo um Service

Agora que já vimos muita coisa sobre os `Services`, vamos aprender como removê-los.

Para remover um `Service` via CLI, você pode usar o comando kubectl delete service, passando o nome do `Service` como parâmetro. Por exemplo:

```bash
kubectl delete service meu-service
```

&nbsp;

Para remover um `Service` via YAML, você pode usar o comando kubectl delete, passando o arquivo YAML como parâmetro. Por exemplo:

```bash
kubectl delete -f meu-service.yaml
```

&nbsp;

Agora já deu, já falamos bastante sobre `Services`, acho que você já pode atualizar o seu currículo e colocar que é um expert em `Services` no Kubernetes. :)

&nbsp;


### A sua lição de casa

Quero que você crie e gerencie um `StatefulSet` em seu próprio ambiente Kubernetes. Comece criando um `StatefulSet` simples com um par de `Pods` e depois tente escalá-lo para mais `Pods`. Experimente também apagar um `Pod` e veja como o Kubernetes lida com isso.

Em seguida, brinque com os `Services`. Exponha seu `StatefulSet` através de um `Service` do tipo `ClusterIP` e depois tente mudar para um `NodePort` ou `LoadBalancer`. Teste a conectividade para garantir que tudo está funcionando corretamente.

E por último, mas não menos importante, crie um `Service` do tipo `ExternalName` e aponte-o para um serviço externo de sua escolha. Verifique se o serviço externo está acessível de dentro de seus `Pods`.

Lembre-se, a prática leva à perfeição, então não pule essa lição de casa! ;) E quando tiver dúvidas ou enfrentar problemas, não hesite em procurar ajuda. Estamos todos aqui para aprender juntos!

&nbsp;

## Final do Day-7

Durante o Day-7 você aprendeu dois recursos essenciais do Kubernetes: `StatefulSets` e `Services`. Através deles, podemos gerenciar aplicações que precisam manter a identidade do `Pod`, persistir dados e ainda expor essas aplicações para o mundo externo.

Espero que você tenha curtido o conteúdo de hoje e lembre-se de fazer a lição de casa! A prática é fundamental para fixar todo esse conhecimento e, acredite, faz toda a diferença.

Então é isso. Nos vemos no próximo dia, onde continuaremos nossa aventura nesse mundinho mágico do containers. Até lá! **#VAIIII**