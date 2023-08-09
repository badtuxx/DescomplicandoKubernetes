# Descomplicando o Kubernetes
## DAY-4
&nbsp;

&nbsp;
## Conteúdo do Day-4

- [DAY-4](README.md)
- [Inicio da aula do Day-4](#inicio-da-aula-do-day-4)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
  - [ReplicaSet](#replicaset)
    - [O Deployment e o ReplicaSet](#o-deployment-e-o-replicaset)
    - [Criando um ReplicaSet](#criando-um-replicaset)
    - [Apagando o ReplicaSet](#apagando-o-replicaset)
  - [O DaemonSet](#o-daemonset)
    - [Criando um DaemonSet](#criando-um-daemonset)
    - [Criando um DaemonSet utilizando o comando kubectl create](#criando-um-daemonset-utilizando-o-comando-kubectl-create)
    - [Aumentando um node no cluster](#aumentando-um-node-no-cluster)
    - [Removendo um DaemonSet](#removendo-um-daemonset)
  - [As Probes do Kubernetes](#as-probes-do-kubernetes)
    - [O que são as Probes?](#o-que-sao-as-probes)
    - [Liveness Probe](#liveness-probe)
    - [Readiness Probe](#readiness-probe)
    - [Startup Probe](#startup-probe)
  - [A sua lição de casa](#a-sua-licao-de-casa)
  - [Final do Day-4](#final-do-day-4)
  

&nbsp;

## Inicio da aula do Day-4

### O que iremos ver hoje?

Hoje é dia de falar sobre dois objetos muito importantes no Kubernetes, os `ReplicaSets` e os `DaemonSets`.

Nós já sabemos o que é um `Deployment` e também já sabemos o que é um `Pod` no detalhe, então agora vamos conhecer essas duas figuras que estão super conectadas com o `Deployment` e com o `Pod`.
Quando falamos sobre `Deployment` é impossível não falar sobre `ReplicaSet`, pois o `Deployment` é um objeto que cria um `ReplicaSet` e o `ReplicaSet` é um objeto que cria um `Pod`, veja que tudo está conectado.

Já o nosso querido `DaemonSet` é um objeto que cria um `Pod` e esse `Pod` é um objeto que fica rodando em todos os nodes do cluster, super importante para nós, pois é com `DaemonSet` que nós conseguimos garantir que teremos pelo menos um `Pod` rodando em cada node do cluster. Por exemplo, imagine que você precisa de instalar os agente do `Datadog` ou ainda um `exporter` do `Prometheus` em todos os nodes do cluster, para isso você precisa de um `DaemonSet`.

Ainda no dia de hoje, nós iremos aprender como garantir que os nossos `Pods` estão rodando corretamente, através das `Probes` do Kubernetes.

Nós vamos falar sobre `Readiness Probe`, `Liveness Probe` e `Startup Probe`, e claro, mostrando todos os detalhes em exemplos práticos e super explicativos.

Hoje é o dia de você aprender sobre esses dois objetos que são super importantes, e ainda, garantir que nós nunca colocaremos os nossos `Pods` em produção sem antes garantir que eles estão rodando corretamente e sendo checados pelas `Probes` do Kubernetes.

Bora lá! #VAIIII

### ReplicaSet

Uma coisa é super importante de saber, quando estamos criando um `Deployment` no Kubernetes, automaticamente estamos criando além do `Deployment` um `ReplicaSet` e esse `ReplicaSet` é quem vai criar os `Pods` que estão dentro do `Deployment`.

Confuso, não?

Não, não é e vou te explicar.

Quando criamos um `Deployment`, o Kubernetes cria um `ReplicaSet` para criar e fazer o gerenciamento das réplicas dos `Pods` em nosso cluster. Ele é o responsável por ficar observando os `Pods` e garantir o número de réplicas que nós definimos no `Deployment`.

É possível criar um `ReplicaSet` sem um `Deployment`, mas não é uma boa prática, pois o `ReplicaSet` não tem a capacidade de fazer o gerenciamento de versões dos `Pods` e também não tem a capacidade de fazer o gerenciamento de `RollingUpdate` dos `Pods`.

E olha que interessante, quando estamos fazendo a atualização de uma versão de um `Pod` com o `Deployment`, o `Deployment` cria um novo `ReplicaSet` para fazer o gerenciamento das réplicas dos `Pods` e quando a atualização termina, o `Deployment` remove as réplicas do `ReplicaSet` antigo e deixa apenas as réplicas do `ReplicaSet` novo.

Mas ele não remove o `ReplicaSet` antigo, ele deixa ele lá, pois ele pode ser usado para fazer um `Rollback` da versão do `Pod` caso algo dê errado. Sim, quando precisamos fazer o `Rollback` de uma atualização em nossos `Pods`, o `Deployment` somente muda o `ReplicaSet` que está sendo usado para fazer o gerenciamento das réplicas dos `Pods`, passando a utilizar o `ReplicaSet` antigo.

Vamos fazer isso na prática?

Acho que vai te ajudar a entender melhor.

#### O Deployment e o ReplicaSet

Vamos criar um `Deployment` com o nome de `nginx-deployment` e vamos criar 3 réplicas do `Pod` do `nginx`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
```

&nbsp;

Vamos visualizar o `Deployment` foi criado.

```bash
kubectl get deployments
```

&nbsp;

A nossa saída será parecida com essa.

```bash
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   1/1     1            1           7s
```

&nbsp;

Simples, eu nós já sabiamos! Jeferson, eu quero saber sobre o `ReplicaSet`!

Calma, pois o nosso querido `Deployment` já criou o `ReplicaSet` para nós.

Vamos visualizar o `ReplicaSet` que foi criado.

```bash
kubectl get replicasets
```

A nossa saída será parecida com essa.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   1         1         1       37s
```

&nbsp;

Um coisa importante de observar na saída acima é que o `ReplicaSet` tem o mesmo nome do `Deployment` seguido de um sufixo aleatório, e ainda nessa saída podemos saber que o `ReplicaSet` atualmente tem 1 réplica do `Pod` do `nginx` rodando, de acordo com o que nós definimos no `Deployment`.

Vamos aumentar o número de réplicas do `Pod` do `nginx` para 3.

```bash
kubectl scale deployment nginx-deployment --replicas=3
```

&nbsp;

Essa é uma forma de aumentar o número de réplicas do `Pod` do `nginx` sem precisar editar o `Deployment`, eu não recomendo, eu prefiro editar o `Deployment` e fazer o `apply` novamente, mas isso é uma questão de gosto e organização. Eu não gosto da ideia de ter que ficar fazendo `scale` no `Deployment` para aumentar ou diminuir o número de réplicas do `Pod` do `nginx`, sem ter isso registrado no `git`, por exemplo.

Alterando o `Deployment` para 3 réplicas.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
```

&nbsp;

Pronto, você conhece as duas opções de aumentar o número de réplicas do `Pod` do `nginx`, fique a vonta para escolher a que você achar melhor.

Eu vou continuar usando a opção de editar o `Deployment` e fazer o `apply` novamente.

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

Vamos verificar o nosso `ReplicaSet` novamente.

```bash
kubectl get replicasets
```

&nbsp;

A nossa saída será parecida com essa.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   3         3         3       5m24s
```

&nbsp;

Perceba que o nome do `ReplicaSet` continua o mesmo, mas o número de réplicas mudou para 3. Quando somente alteramos o número de réplicas do nosso `Deployment`, o `ReplicaSet` permanece o mesmo, afinal sua principal função é fazer o gerenciamento das réplicas do `Pod` do `nginx`.

Agora vamos mudar a versão do `nginx` para a versão 1.19.2.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
```

&nbsp;

Vamos aplicar as alterações.

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

Pronto, agora o `Deployment` está usando a versão 1.19.2 do `nginx`.

Vamos verificar o nosso `ReplicaSet` novamente.

```bash
kubectl get replicasets
```

&nbsp;

Teremos agora a seguinte saída.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   0         0         0       8m53s
nginx-deployment-7858bcf56f   1         1         1       13s
```

&nbsp;

Agora sim nós temos um novo `ReplicaSet` com o nome de `nginx-deployment-7858bcf56f`, e o `ReplicaSet` antigo com o nome de `nginx-deployment-6dd8d7cfbd` foi esvaziado, pois ele não faz mais parte do `Deployment`, mas permanece no cluster, pois ele pode ser usado para fazer o rollback para a versão anterior do `nginx`.

Vamos ver um detalhe interessante em nosso `Deployment`.

```bash
kubectl describe deployment nginx-deployment
```

&nbsp;

Olha a linha referente ao `ReplicaSet` que está sendo gerenciado pelo `Deployment`.

```bash
NewReplicaSet:   nginx-deployment-7858bcf56f (3/3 replicas created)
```

&nbsp;

Sim, na saída do `describe` nós podemos ver que o `Deployment` está gerenciando o `ReplicaSet` com o nome de `nginx-deployment-7858bcf56f` e que ele tem 3 réplicas do `Pod` do `nginx` rodando.

Se você quiser fazer o rollback para a versão anterior do `nginx`, basta fazer o seguinte, conforme nós já vimos anteriormente.

```bash
kubectl rollout undo deployment nginx-deployment
```

&nbsp;

Com isso será feito o rollback para a versão anterior do `nginx` e o `ReplicaSet` com o nome de `nginx-deployment-7858bcf56f` será esvaziado e o `ReplicaSet` com o nome de `nginx-deployment-6dd8d7cfbd` será preenchido novamente com 3 réplicas do `Pod` do `nginx`.

Vamos listar novamente os nossos `ReplicaSet`.

```bash
kubectl get replicasets
```

&nbsp;

O que temos agora é isso.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   3         3         3       15m
nginx-deployment-7858bcf56f   0         0         0       6m28s
```

&nbsp;

E se olharmos o `Deployment` novamente.

```bash
kubectl describe deployment nginx-deployment
```

&nbsp;

Teremos a seguinte saída.

```bash
NewReplicaSet:   nginx-deployment-6dd8d7cfbd (3/3 replicas created)
```

&nbsp;

Simples demais, não é mesmo?

Então agora você já sabe como fazer o gerenciamento de réplicas do `Pod` do `nginx` usando o `Deployment`, e por consequência o `ReplicaSet`.

&nbsp;

#### Criando um ReplicaSet

Como foi falado anteriormente, é possível você criar um `ReplicaSet` sem ser através de um `Deployment`, apesar de insistir, não faça isso, pois o `Deployment` é a forma mais fácil de gerenciar os `ReplicaSet` e a saúde dos `Pods`.

Mas vamos lá, caso você queira criar um `ReplicaSet` sem ser através de um `Deployment`, basta fazer o seguinte.

Para o nosso exemplo, vamos criar um arquivo com o nome de `nginx-replicaset.yaml` e vamos colocar o seguinte conteúdo.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  labels:
    app: nginx-app
  name: nginx-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
```

&nbsp;

Antes de aplicar o nosso manifesto, vamos entender o que estamos fazendo.
Se você observar o nosso arquivo, não tem nada de novo, ou seja, nada que você já não tenha aprendido até agora. A principal diferença é que agora nós estamos usando o `kind: ReplicaSet` e não o `kind: Deployment`, até o `APIVersion` é a mesmo.

Agora vamos aplicar o nosso manifesto.

```bash
kubectl apply -f nginx-replicaset.yaml
```

&nbsp;

A saída será essa.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   3         3         3       21m
nginx-deployment-7858bcf56f   0         0         0       12m
nginx-replicaset              3         3         3       6s
```

&nbsp;

Agora nós temos 3 `ReplicaSet` sendo gerenciados pelo `Kubernetes`, sendo que 2 deles são gerenciados pelo `Deployment` e o outro foi o que acabamos de criar.

Vamos listar os `Pods` que estão rodando.

```bash
kubectl get pods
```

&nbsp;

Tudo rolando magicamente, certo?

Agora vamos fazer um teste, vamos alterar a versão do `nginx` para a versão 1.19.3, para isso vamos editar o nosso arquivo `nginx-replicaset.yaml` e vamos alterar a versão do `nginx` para a versão 1.19.3.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  labels:
    app: nginx-app
  name: nginx-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - image: nginx:1.19.3
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
```

&nbsp;

Pronto, agora vamos aplicar as alterações.

```bash
kubectl apply -f nginx-replicaset.yaml
```

&nbsp;

Vamos listar os `Pods` novamente.

```bash
kubectl get pods
```

&nbsp;

Perceba que nada aconteceu, ou seja, o `ReplicaSet` não fez o rollout da nova versão do `nginx`, isso acontece porque o `ReplicaSet` não faz o gerenciamento de versões, ele apenas garante que o número de réplicas do `Pod` esteja sempre ativo.

Se você olhar os detalhes do `ReplicaSet` você vai ver que ele está gerenciando 3 réplicas do `Pod` e que a imagem do `nginx` é a versão 1.19.3, porém ele não recriou os `Pods` com a nova versão do `nginx`, ele somente irá fazer isso se você apagar os `Pods` manualmente ou se o `Pod` morrer por algum motivo.

```bash
kubectl describe replicaset nginx-replicaset
```

&nbsp;

Agora vamos apagar um dos `Pods` para que o `ReplicaSet` crie um novo `Pod` com a nova versão do `nginx`.

```bash
kubectl delete pod nginx-replicaset-8r6md
```

&nbsp;

Agora o `ReplicaSet` vai criar um novo `Pod` com a nova versão do `nginx`, e gerando um problema para nós, pois agora nós temos duas versões do `nginx` rodando no nosso cluster.

```bash
kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\t"}{end}{end}'
```

&nbsp;

Essa é uma forma de você listar os `Pods` e as imagens que estão sendo usadas por eles, eu sei que é bastante esquisito, mas vou explicar o que está acontecendo.

- `kubectl get pods`: esse comando lista todos os Pods no cluster.

- `-o=jsonpath`: esse parâmetro especifica que queremos usar a saída em formato JSONPath para exibir as informações dos Pods.

- `'{range .items[*]}{"\n"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\t"}{end}{end}'`: essa é a expressão JSONPath que define o formato de saída do comando. Ela usa a função range para iterar sobre todos os objetos items (ou seja, os Pods) retornados pelo comando kubectl get pods. Em seguida, exibe o nome do Pod `({.metadata.name})` seguido de uma tabulação `(\t)`, e itera sobre todos os contêineres `({range .spec.containers[*]})` dentro do Pod, exibindo a imagem usada por cada um deles `({.image})`. Por fim, insere uma quebra de linha `(\n)` e fecha o segundo range com `{end}{end}`.

Sim, eu sei, continua confuso!

Mas vou te contar um segredo, somente com o tempo e utilizando repetidas vezes, as coisas começam a ficar mais fáceis, então não desista! Pra trás, nem pra pegar impulso!

Ainda vamos falar com mais detalhes sobre como utilizar `metadata` para ter uma saída mais amigável e precisa.

#### Apagando o ReplicaSet

Para remover o `ReplicaSet` e todos os `Pods` que ele está gerenciando, basta executar o comando abaixo.

```bash
kubectl delete replicaset nginx-replicaset
```

&nbsp;

Caso você queira fazer isso utilizando o arquivo de manifesto, basta executar o comando abaixo.

```bash
kubectl delete -f nginx-replicaset.yaml
```

&nbsp;

Pronto, o nosso `ReplicaSet` foi removido e todos os `Pods` que ele estava gerenciando também foram removidos.

Durante a nossa sessão, nós já aprendemos como criar um `ReplicaSet` e como ele funciona, mas ainda temos muito o que aprender, então vamos continuar.

&nbsp;

### O DaemonSet

Já sabemos o que é um `Pod`, um `Deployment` e um `ReplicaSet`, mas agora é a hora de conhecermos mais um objeto do `Kubernetes`, o `DaemonSet`.

O `DaemonSet` é um objeto que garante que todos os nós do cluster executem uma réplica de um `Pod`, ou seja, ele garante que todos os nós do cluster executem uma cópia de um `Pod`.

O `DaemonSet` é muito útil para executar `Pods` que precisam ser executados em todos os nós do cluster, como por exemplo, um `Pod` que faz o monitoramento de logs, ou um `Pod` que faz o monitoramento de métricas.

Alguns casos de uso de `DaemonSets` são:

- Execução de agentes de monitoramento, como o `Prometheus Node Exporter` ou o `Fluentd`.
- Execução de um proxy de rede em todos os nós do cluster, como  `kube-proxy`, `Weave Net`, `Calico` ou `Flannel`.
- Execução de agentes de segurança em cada nó do cluster, como  `Falco` ou `Sysdig`.


Portanto, se nosso cluster possuir 3 nós, o `DaemonSet` vai garantir que todos os nós executem uma réplica do `Pod` que ele está gerenciando, ou seja, 3 réplicas do `Pod`.

Caso adicionemos mais um `node` ao cluster, o `DaemonSet` vai garantir que todos os nós executem uma réplica do `Pod` que ele está gerenciando, ou seja, 4 réplicas do `Pod`.

#### Criando um DaemonSet

Vamos para o nosso primeiro exemplo, vamos criar um `DaemonSet` que vai garantir que todos os nós do cluster executem uma réplica do `Pod` do `node-exporter`, que é um exporter de métricas do `Prometheus`.

Para isso, vamos criar um arquivo chamado `node-exporter-daemonset.yaml` e vamos adicionar o seguinte conteúdo.

```yaml
apiVersion: apps/v1 # Versão da API do Kubernetes do objeto
kind: DaemonSet # Tipo do objeto
metadata: # Informações sobre o objeto
  name: node-exporter # Nome do objeto
spec: # Especificação do objeto
  selector: # Seletor do objeto
    matchLabels: # Labels que serão utilizadas para selecionar os Pods
      app: node-exporter # Label que será utilizada para selecionar os Pods
  template: # Template do objeto
    metadata: # Informações sobre o objeto
      labels: # Labels que serão adicionadas aos Pods
        app: node-exporter # Label que será adicionada aos Pods
    spec: # Especificação do objeto, no caso, a especificação do Pod
      hostNetwork: true # Habilita o uso da rede do host, usar com cuidado
      containers: # Lista de contêineres que serão executados no Pod
      - name: node-exporter # Nome do contêiner
        image: prom/node-exporter:latest # Imagem do contêiner
        ports: # Lista de portas que serão expostas no contêiner
        - containerPort: 9100 # Porta que será exposta no contêiner
          hostPort: 9100 # Porta que será exposta no host
        volumeMounts: # Lista de volumes que serão montados no contêiner, pois o node-exporter precisa de acesso ao /proc e /sys
        - name: proc # Nome do volume
          mountPath: /host/proc # Caminho onde o volume será montado no contêiner
          readOnly: true # Habilita o modo de leitura apenas
        - name: sys # Nome do volume 
          mountPath: /host/sys # Caminho onde o volume será montado no contêiner
          readOnly: true # Habilita o modo de leitura apenas
      volumes: # Lista de volumes que serão utilizados no Pod
      - name: proc # Nome do volume
        hostPath: # Tipo de volume 
          path: /proc # Caminho do volume no host
      - name: sys # Nome do volume
        hostPath: # Tipo de volume
          path: /sys # Caminho do volume no host
```

&nbsp;

Eu deixei o arquivo comentado para facilitar o entendimento, agora vamos criar o `DaemonSet` utilizando o arquivo de manifesto.

```bash
kubectl apply -f node-exporter-daemonset.yaml
```

&nbsp;

Agora vamos verificar se o `DaemonSet` foi criado.

```bash
kubectl get daemonset
```

&nbsp;

Como podemos ver, o `DaemonSet` foi criado com sucesso.

```bash
NAME            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
node-exporter   2         2         2       2            2           <none>          5m24s
```

&nbsp;

Caso você queira verificar os `Pods` que o `DaemonSet` está gerenciando, basta executar o comando abaixo.

```bash
kubectl get pods -l app=node-exporter
```

&nbsp;

Somente para lembrar, estamos utilizando o parâmetro `-l` para filtrar os `Pods` que possuem a label `app=node-exporter`, que é o caso do nosso `DaemonSet`.

Como podemos ver, o `DaemonSet` está gerenciando 2 `Pods`, um em cada nó do cluster.

```bash
NAME                  READY   STATUS    RESTARTS   AGE
node-exporter-k8wp9   1/1     Running   0          6m14s
node-exporter-q8zvw   1/1     Running   0          6m14s
```

&nbsp;

Os nossos `Pods` do `node-exporter` foram criados com sucesso, agora vamos verificar se eles estão sendo executados em todos os nós do cluster.

```bash
kubectl get pods -o wide -l app=node-exporter
```

&nbsp;

Com o comando acima, podemos ver em qual nó cada `Pod` está sendo executado.

```bash
NAME                                READY   STATUS    RESTARTS   AGE     IP               NODE                            NOMINATED NODE   READINESS GATES
node-exporter-k8wp9                 1/1     Running   0          3m49s   192.168.8.145    ip-192-168-8-145.ec2.internal   <none>           <none>
node-exporter-q8zvw                 1/1     Running   0          3m49s   192.168.55.68    ip-192-168-55-68.ec2.internal   <none>           <none>
```

&nbsp;

Como podemos ver, os `Pods` do `node-exporter` estão sendo executados em todos os dois nós do cluster.

Para ver os detalhes do `DaemonSet`, basta executar o comando abaixo.

```bash
kubectl describe daemonset node-exporter
```

&nbsp;

O comando acima vai retornar uma saída parecida com a abaixo.

```bash
Name:           node-exporter
Selector:       app=node-exporter
Node-Selector:  <none>
Labels:         <none>
Annotations:    deprecated.daemonset.template.generation: 1
Desired Number of Nodes Scheduled: 2
Current Number of Nodes Scheduled: 2
Number of Nodes Scheduled with Up-to-date Pods: 2
Number of Nodes Scheduled with Available Pods: 2
Number of Nodes Misscheduled: 0
Pods Status:  2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=node-exporter
  Containers:
   node-exporter:
    Image:        prom/node-exporter:latest
    Port:         9100/TCP
    Host Port:    9100/TCP
    Environment:  <none>
    Mounts:
      /host/proc from proc (ro)
      /host/sys from sys (ro)
  Volumes:
   proc:
    Type:          HostPath (bare host directory volume)
    Path:          /proc
    HostPathType:  
   sys:
    Type:          HostPath (bare host directory volume)
    Path:          /sys
    HostPathType:  
Events:
  Type    Reason            Age   From                  Message
  ----    ------            ----  ----                  -------
  Normal  SuccessfulCreate  9m6s  daemonset-controller  Created pod: node-exporter-q8zvw
  Normal  SuccessfulCreate  9m6s  daemonset-controller  Created pod: node-exporter-k8wp9
```

&nbsp;

Na saída acima, podemos ver algumas informações bem importantes relacionadas ao `DaemonSet`, como por exemplo, o número de nós que o `DaemonSet` está gerenciando, o número de `Pods` que estão sendo executados em cada nó, etc.

#### Criando um DaemonSet utilizando o comando kubectl create

Você ainda pode criar um `DaemonSet` utilizando o comando `kubectl create`, mas eu prefiro utilizar o arquivo de manifesto, pois assim eu consigo versionar o meu `DaemonSet`, mas caso você queira criar um `DaemonSet` utilizando o comando `kubectl create`, basta executar o comando abaixo.

```bash
kubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100
```

&nbsp;

Ficaram faltando alguns parâmetros no comando acima, mas eu deixei assim para facilitar o entendimento, caso você queira ver todos os parâmetros que podem ser utilizados no comando `kubectl create daemonset`, basta executar o comando abaixo.

```bash
kubectl create daemonset --help
```

&nbsp;

Eu gosto de utilizar o `kubectl create` somente para criar um arquivo exemplo, para que eu possa me basear na hora de criar o meu arquivo de manifesto, mas caso você queira criar um manifesto para criar `DaemonSet` utilizando o comando `kubectl create`, basta executar o comando abaixo.

```bash
kubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100 -o yaml --dry-run=client > node-exporter-daemonset.yaml
```

&nbsp;

Simples assim! Vou te explicar o que está acontecendo no comando acima.

- `kubectl create daemonset node-exporter` - Cria um `DaemonSet` chamado `node-exporter`.
- `--image=prom/node-exporter:latest` - Utiliza a imagem `prom/node-exporter:latest` para criar os `Pods`.
- `--port=9100` - Define a porta `9100` para o `Pod`.
- `--host-port=9100` - Define a porta `9100` para o nó.
- `-o yaml` - Define o formato do arquivo de manifesto como `yaml`.
- `--dry-run=client` - Executa o comando sem criar o `DaemonSet`, somente simula a criação do `DaemonSet`.
- `> node-exporter-daemonset.yaml` - Redireciona a saída do comando para o arquivo `node-exporter-daemonset.yaml`.

Ficou mais simples, certo?

#### Aumentando um node no cluster

Agora que já sabemos como criar um `DaemonSet`, vamos aumentar o número de nós do nosso cluster.

Nós estamos com duas réplicas nesse momento.

```bash
kubectl get nodes
```

&nbsp;

```bash
NAME                             STATUS   ROLES    AGE    VERSION
ip-192-168-55-68.ec2.internal    Ready    <none>   113m   v1.23.16-eks-48e63af
ip-192-168-8-145.ec2.internal    Ready    <none>   113m   v1.23.16-eks-48e63af
```

&nbsp;

Vamos aumentar o número de nós para 3.

Eu estou utilizando o `eksctl` para criar o cluster, então eu vou utilizar o comando `eksctl scale nodegroup` para aumentar o número de nós do cluster, mas caso você esteja utilizando outro gerenciador de cluster, você pode utilizar o comando que preferir para aumentar o número de nós do cluster.

```bash
eksctl scale nodegroup --cluster=eks-cluster --nodes 3 --name eks-cluster-nodegroup
```

&nbsp;

```bash
2023-03-11 13:31:48 [ℹ]  scaling nodegroup "eks-cluster-nodegroup" in cluster eks-cluster
2023-03-11 13:31:49 [ℹ]  waiting for scaling of nodegroup "eks-cluster-nodegroup" to complete
2023-03-11 13:33:17 [ℹ]  nodegroup successfully scaled
```

&nbsp;

Vamos verificar se o node foi adicionado ao cluster.

```bash
kubectl get nodes
```

&nbsp;

```bash
NAME                             STATUS   ROLES    AGE    VERSION
ip-192-168-45-194.ec2.internal   Ready    <none>   47s    v1.23.16-eks-48e63af
ip-192-168-55-68.ec2.internal    Ready    <none>   113m   v1.23.16-eks-48e63af
ip-192-168-8-145.ec2.internal    Ready    <none>   113m   v1.23.16-eks-48e63af
```

&nbsp;

Pronto, agora nós temos 3 nós no cluster.

Mas a pergunta que não quer calar é: O `DaemonSet` criou um `Pod` no novo nó?

Vamos verificar.

```bash
kubectl get pods -o wide -l app=node-exporter
```

&nbsp;

```bash
NAME                  READY   STATUS    RESTARTS   AGE   IP               NODE                             NOMINATED NODE   READINESS GATES
node-exporter-k8wp9   1/1     Running   0          20m   192.168.8.145    ip-192-168-8-145.ec2.internal    <none>           <none>
node-exporter-q8zvw   1/1     Running   0          20m   192.168.55.68    ip-192-168-55-68.ec2.internal    <none>           <none>
node-exporter-xffgq   1/1     Running   0          70s   192.168.45.194   ip-192-168-45-194.ec2.internal   <none>           <none>
```

&nbsp;

Parece que temos um novo `Pod` no nó `ip-192-168-45-194.ec2.internal`, mas vamos verificar se o `DaemonSet` está gerenciando esse nó.

```bash
kubectl describe daemonset node-exporter
```

&nbsp;

```bash
Desired Number of Nodes Scheduled: 3
Current Number of Nodes Scheduled: 3
Number of Nodes Scheduled with Up-to-date Pods: 3
Number of Nodes Scheduled with Available Pods: 3
Number of Nodes Misscheduled: 0
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
```

&nbsp;

Tudo em paz e harmonia, o `DaemonSet` está gerenciando o novo `Pod` no novo `node`.
E claro, se por algum motivo o `Pod` cair, o `DaemonSet` vai criar um novo `Pod` no mesmo `node`. 
E claro versão 2, se a quantidade de nodes diminuir, o `DaemonSet` vai remover os `Pods` que estão em excesso. E bem lembrado, deixa eu dimunuir o número de nós do cluster para salvar alguns doletas.

```bash
eksctl scale nodegroup --cluster=eks-cluster --nodes 2 --name eks-cluster-nodegroup
```

&nbsp;

#### Removendo um DaemonSet

Para remover o `DaemonSet` é bem simples, basta executar o comando `kubectl delete daemonset <nome-do-daemonset>`.

```bash
kubectl delete daemonset node-exporter
```

&nbsp;

```bash
daemonset.apps "node-exporter" deleted
```

&nbsp;

Ou ainda você pode remover o `DaemonSet` através do manifesto.

```bash
kubectl delete -f node-exporter-daemonset.yaml
```

&nbsp;

Simples assim!

Acho que o assunto `DaemonSet` já está bem claro. Ainda iremos ver todos esses objetos que vimos até aqui diversas vezes durante a nossa jornada, então não se preocupe pois iremos praticar muito mais.

&nbsp;


### As Probes do Kubernetes

Antes de seguir, eu queria trazer algo novo além dos dois novos objetos que você já aprendeu no dia de hoje.
Eu queria que você saisse do dia de hoje com a segurança que você e capaz de criar um `Pod`, um `Deployment`, um `ReplicaSet` ou um `DaemonSet`, mas também com a segurança que você pode monitorar o seus suas aplicações que estão rodando dentro do cluster de maneira efetiva e utilizando recursos que o Kubernetes já nos disponibiliza.

#### O que são as Probes?

As probes são uma forma de você monitorar o seu `Pod` e saber se ele está em um estado saudável ou não. Com elas é possível assegurar que seus `Pods` estão rodando e respondendo de maneira correta, e mais do que isso, que o Kubernetes está testando o que está sendo executado dentro do seu `Pod`.

Hoje nós temos disponíveis três tipos de probes, a `livenessProbe`, a `readinessProbe` e a `startupProbe`. Vamos ver no detalhe cada uma delas.

#### Liveness Probe

A `livenessProbe` é a nossa probe de verificação de integridade, o que ela faz é verificar se o que está rodando dentro do `Pod` está saudável. O que fazemos é criar uma forma de testar se o que temos dentro do `Pod` está respondendo conforme esperado. Se por acaso o teste falhar, o `Pod` será reiniciado.

Para ficar mais claro, vamos mais uma vez utilizar o exemplo com o `Nginx`. Gosto de usar o `Nginx` como exemplo, pois sei que toda pessoa já o conhece, e assim, fica muito mais fácil de entender o que está acontecendo. Afinal, você está aqui para aprender Kubernetes, e se for com algo que você já conhece, fica muito mais fácil de entender.

Bem, vamos lá, hora de criar um novo `Deployment` com o `Nginx`, vamos utilizar o exemplo que já utilizamos quando aprendemos sobre o `Deployment`.

Para isso, crie um arquivo chamado `nginx-liveness.yaml` e cole o seguinte conteúdo.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
        livenessProbe: # Aqui é onde vamos adicionar a nossa livenessProbe
          tcpSocket: # Aqui vamos utilizar o tcpSocket, onde vamos se conectar ao container através do protocolo TCP
            port: 80 # Qual porta TCP vamos utilizar para se conectar ao container
          initialDelaySeconds: 10 # Quantos segundos vamos esperar para executar a primeira verificação
          periodSeconds: 10 # A cada quantos segundos vamos executar a verificação
          timeoutSeconds: 5 # Quantos segundos vamos esperar para considerar que a verificação falhou
          failureThreshold: 3 # Quantos falhas consecutivas vamos aceitar antes de reiniciar o container
```

&nbsp;

Com isso temos algumas coisas novas, e utilizamos apenas uma `probe` que é a `livenessProbe`. 

O que declaramos com a regra acima é que queremos testar se o `Pod` está respondendo através do protocolo TCP, através da opção `tcpSocket`, na porta 80 que foi definida pela opção `port`. E também definimos que queremos esperar 10 segundos para executar a primeira verificação utilizando `initialDelaySeconds` e por conta da `periodSeconds`falamos que queremos que a cada 10 segundos seja realizada a verificação. Caso a verificação falhe, vamos esperar 5 segundos, por conta da `timeoutSeconds`, para tentar novamente, e como utilizamos o `failureThreshold`, se falhar mais 3 vezes, vamos reiniciar o `Pod`.
      
Ficou mais claro? Vamos para mais um exemplo.

Vamos imaginar que agora não queremos mais utilizar o `tcpSocket`, mas sim o `httpGet` para tentar acessar um endpoint dentro do nosso `Pod`.

Para isso, vamos alterar o nosso `nginx-deployment.yaml` para o seguinte.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
        livenessProbe: # Aqui é onde vamos adicionar a nossa livenessProbe
          httpGet: # Aqui vamos utilizar o httpGet, onde vamos se conectar ao container através do protocolo HTTP
            path: / # Qual o endpoint que vamos utilizar para se conectar ao container
            port: 80 # Qual porta TCP vamos utilizar para se conectar ao container
          initialDelaySeconds: 10 # Quantos segundos vamos esperar para executar a primeira verificação
          periodSeconds: 10 # A cada quantos segundos vamos executar a verificação
          timeoutSeconds: 5 # Quantos segundos vamos esperar para considerar que a verificação falhou
          failureThreshold: 3 # Quantos falhas consecutivas vamos aceitar antes de reiniciar o container
```

&nbsp;

Perceba que agora somente mudamos algumas coisas, apesar de seguir com o mesmo objetivo, que é verificar se o `Nginx` está respondendo corretamente, mudamos como iremos testar isso. Agora estamos utilizando o `httpGet` para testar se o `Nginx` está respondendo corretamente através do protocolo HTTP, e para isso, estamos utilizando o endpoint `/` e a porta 80.

O que temos de novo aqui é a opção `path`, que é o endpoint que vamos utilizar para testar se o `Nginx` está respondendo corretamente, e claro, a `httpGet` é a forma como iremos realizar o nosso teste, através do protocolo HTTP.

&nbsp;

Escolha qual dois dois exemplos você quer utilizar, e crie o seu `Deployment` através do comando abaixo.

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

Para verificar se o `Deployment` foi criado corretamente, execute o comando abaixo.

```bash
kubectl get deployments
```

&nbsp;

Você deve ver algo parecido com isso.

```bash
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-7557d7fc6c-dx48d   1/1     Running   0          14s
nginx-deployment-7557d7fc6c-tbk4w   1/1     Running   0          12s
nginx-deployment-7557d7fc6c-wv876   1/1     Running   0          16s
```

&nbsp;

Para que você possa ver mais detalhes sobre o seu `Pod` e saber se a nossa probe está funcionando corretamente, vamos utilizar o comando abaixo.

```bash
kubectl describe pod nginx-deployment-7557d7fc6c-dx48d
```

&nbsp;

A saída deve ser parecida com essa.

```bash
Name:             nginx-deployment-589d6fc888-42fmg
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip-192-168-39-119.ec2.internal/192.168.39.119
Start Time:       Thu, 16 Mar 2023 18:49:53 +0100
Labels:           app=nginx-deployment
                  pod-template-hash=589d6fc888
Annotations:      kubernetes.io/psp: eks.privileged
Status:           Running
IP:               192.168.49.40
IPs:
  IP:           192.168.49.40
Controlled By:  ReplicaSet/nginx-deployment-589d6fc888
Containers:
  nginx:
    Container ID:   docker://f7fc28a1fafbf53471ba144d4fb48bc029d289d93b3565b839ae89a1f38cd894
    Image:          nginx:1.19.2
    Image ID:       docker-pullable://nginx@sha256:c628b67d21744fce822d22fdcc0389f6bd763daac23a6b77147d0712ea7102d0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 16 Mar 2023 18:49:59 +0100
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        250m
      memory:     128Mi
    Liveness:     http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8srlq (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-8srlq:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  21s   default-scheduler  Successfully assigned default/nginx-deployment-589d6fc888-42fmg to ip-192-168-39-119.ec2.internal
  Normal  Pulling    20s   kubelet            Pulling image "nginx:1.19.2"
  Normal  Pulled     15s   kubelet            Successfully pulled image "nginx:1.19.2" in 4.280120301s (4.280125621s including waiting)
  Normal  Created    15s   kubelet            Created container nginx
  Normal  Started    15s   kubelet            Started container nginx
```

&nbsp;

Aqui temos a informação mais importante para nós nesse momento:

```bash
    Liveness:     http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=3
```

&nbsp;

A saída acima é parte da saída do comando `kubectl describe pod`. Tudo funcionando maravilhosamente bem.

Agora vamos fazer o seguinte, vamos alterar o nosso `Deployment`, para que a nossa probe falhe. Para isso vamos alterar o `endpoint` que estamos utilizando. Vamos alterar o `path` para `/giropops`.

&nbsp;

```yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
        livenessProbe: # Aqui é onde vamos adicionar a nossa livenessProbe
          httpGet: # Aqui vamos utilizar o httpGet, onde vamos se conectar ao container através do protocolo HTTP
            path: /giropops # Qual o endpoint que vamos utilizar para se conectar ao container
            port: 80 # Qual porta TCP vamos utilizar para se conectar ao container
          initialDelaySeconds: 10 # Quantos segundos vamos esperar para executar a primeira verificação
          periodSeconds: 10 # A cada quantos segundos vamos executar a verificação
          timeoutSeconds: 5 # Quantos segundos vamos esperar para considerar que a verificação falhou
          failureThreshold: 3 # Quantos falhas consecutivas vamos aceitar antes de reiniciar o container
```

&nbsp;

Vamos aplicar as alterações no nosso `Deployment`:

```bash
kubectl apply -f deployment.yaml
```

&nbsp;

Depois de um tempo, você perceberá que o Kubernetes finalizou a atualização do nosso `Deployment`. 
Se você aguardar um pouco mais, você irá perceber que os `Pods` estã̀o sendo reiniciados com frequência.

Tudo isso porque a nossa `livenessProbe` está falhando, afinal o nosso `endpoint` está errado.

Podemos ver mais detalhes sobre o que está acontecendo na saída do comando `kubectl describe pod`:

```bash
kubectl describe pod nginx-deployment-7557d7fc6c-dx48d
```

&nbsp;

```bash
Name:             nginx-deployment-7557d7fc6c-dx48d
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip-192-168-39-119.ec2.internal/192.168.39.119
Start Time:       Thu, 16 Mar 2023 18:51:00 +0100
Labels:           app=nginx-deployment
                  pod-template-hash=7557d7fc6c
Annotations:      kubernetes.io/psp: eks.privileged
Status:           Running
IP:               192.168.44.84
IPs:
  IP:           192.168.44.84
Controlled By:  ReplicaSet/nginx-deployment-7557d7fc6c
Containers:
  nginx:
    Container ID:   docker://c070d9c08bec40ad14562512d7bd8507a44279a327f1b3ecac1621da7ccf21b4
    Image:          nginx:1.19.2
    Image ID:       docker-pullable://nginx@sha256:c628b67d21744fce822d22fdcc0389f6bd763daac23a6b77147d0712ea7102d0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 16 Mar 2023 18:51:41 +0100
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 16 Mar 2023 18:51:02 +0100
      Finished:     Thu, 16 Mar 2023 18:51:40 +0100
    Ready:          True
    Restart Count:  1
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        250m
      memory:     128Mi
    Liveness:     http-get http://:80/giropops delay=10s timeout=5s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4sk2f (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-4sk2f:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  44s               default-scheduler  Successfully assigned default/nginx-deployment-7557d7fc6c-dx48d to ip-192-168-39-119.ec2.internal
  Normal   Pulled     4s (x2 over 43s)  kubelet            Container image "nginx:1.19.2" already present on machine
  Normal   Created    4s (x2 over 43s)  kubelet            Created container nginx
  Warning  Unhealthy  4s (x3 over 24s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    4s                kubelet            Container nginx failed liveness probe, will be restarted
  Normal   Started    3s (x2 over 42s)  kubelet            Started container nginx
```

&nbsp;

Na última parte da saída do comando `kubectl describe pod`, você pode ver que o Kubernetes está tentando executar a nossa `livenessProbe` e ela está falhando, inclusive ele mostra a quantidade de vezes que ele tentou executar a `livenessProbe` e falhou, e com isso, ele reiniciou o nosso `Pod`.

&nbsp;

Acho que agora ficou bem mais claro como a `livenessProbe` funciona, então é hora de partir para a próxima probe, a `readinessProbe`.

&nbsp;

#### Readiness Probe

A `readinessProbe` é uma forma de o Kubernetes verificar se o seu container está pronto para receber tráfego, se ele está pronto para receber requisições vindas de fora.

Essa é a nossa probe de leitura, ela fica verificando se o nosso container está pronto para receber requisições, e se estiver pronto, ele irá receber requisições, caso contrário, ele não irá receber requisições, pois será removido do `endpoint` do serviço, fazendo com que o tráfego não chegue até ele.

Ainda iremos ver o que é `service` e `endpoint`, mas por enquanto, basta saber que o `endpoint` é o endereço que o nosso `service` irá usar para acessar o nosso `Pod`. Mas vamos ter um dia inteiro para falar sobre `service` e `endpoint`, então, relaxa.

&nbsp;

Voltando ao assunto, a nossa probe da vez irá garantir que o nosso `Pod`está saudável para receber requisições.

Vamos para um exemplo para ficar mais claro.

Para o nosso exemplo, vamos criar um arquivo chamado `nginx-readiness.yaml` e vamos colocar o seguinte conteúdo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
        readinessProbe: # Onde definimos a nossa probe de leitura
          httpGet: # O tipo de teste que iremos executar, neste caso, iremos executar um teste HTTP
            path: / # O caminho que iremos testar
            port: 80 # A porta que iremos testar
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 2 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
```

&nbsp;

Vamos ver se os nossos `Pods` estão rodando:

```bash
kubectl get pods
```

&nbsp;

```bash
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-fbdc9b65f-trnnz   0/1     Running   0          6s
nginx-deployment-fbdc9b65f-z8n4m   0/1     Running   0          6s
nginx-deployment-fbdc9b65f-zn8zh   0/1     Running   0          6s
```

&nbsp;

Podemos ver que agora os `Pods` demoram um pouco mais para ficarem prontos, pois estamos executando a nossa `readinessProbe`, e por esse motivo temos que aguardar os 10 segundos inicias que definimos para que seja executada a primeira vez a nossa probe, lembra?

Se você aguardar um pouco, você verá que os `Pods` irão ficar prontos, e você pode ver isso executando o comando:

```bash
kubectl get pods
```

&nbsp;

```bash
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-fbdc9b65f-trnnz   1/1     Running   0          30s
nginx-deployment-fbdc9b65f-z8n4m   1/1     Running   0          30s
nginx-deployment-fbdc9b65f-zn8zh   1/1     Running   0          30s
```

&nbsp;

Pronto, como mágica agora os nossos `Pods` estão prontos para receber requisições.

Vamos dar uma olhada no `describe` do nosso `Pod`:

```bash
kubectl describe pod nginx-deployment-fbdc9b65f-trnnz
```

&nbsp;

```bash
Name:             nginx-deployment-fbdc9b65f-trnnz
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip-192-168-39-119.ec2.internal/192.168.39.119
Start Time:       Thu, 16 Mar 2023 19:10:07 +0100
Labels:           app=nginx-deployment
                  pod-template-hash=fbdc9b65f
Annotations:      kubernetes.io/psp: eks.privileged
Status:           Running
IP:               192.168.49.40
IPs:
  IP:           192.168.49.40
Controlled By:  ReplicaSet/nginx-deployment-fbdc9b65f
Containers:
  nginx:
    Container ID:   docker://09538e27e29c5c649efa88fe148336abd5a47dd4e5a8d32b40b268fb1818dfc4
    Image:          nginx:1.19.2
    Image ID:       docker-pullable://nginx@sha256:c628b67d21744fce822d22fdcc0389f6bd763daac23a6b77147d0712ea7102d0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 16 Mar 2023 19:10:08 +0100
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        250m
      memory:     128Mi
    Readiness:    http-get http://:80/ delay=10s timeout=5s period=10s #success=2 #failure=3
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zpfvb (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-zpfvb:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  60s   default-scheduler  Successfully assigned default/nginx-deployment-fbdc9b65f-trnnz to ip-192-168-39-119.ec2.internal
  Normal  Pulled     59s   kubelet            Container image "nginx:1.19.2" already present on machine
  Normal  Created    59s   kubelet            Created container nginx
  Normal  Started    59s   kubelet            Started container nginx
```

&nbsp;

Pronto, a nossa probe está lá e funcionando, e com isso podemos garantir que os nossos `Pods` estão prontos para receber requisições.

Vamos mudar o nosso `path` para `/giropops` e ver o que acontece:

```yaml
...
        readinessProbe: # Onde definimos a nossa probe de leitura
          httpGet: # O tipo de teste que iremos executar, neste caso, iremos executar um teste HTTP
            path: /giropops # O caminho que iremos testar
            port: 80 # A porta que iremos testar
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 2 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
```

&nbsp;

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

```bash
deployment.apps/nginx-deployment configured
```

&nbsp;

Muito bom, agora vamos ver o resultado dessa bagunça:

```bash
kubectl get pods
```

&nbsp;

Nesse ponto você pode ver que o Kubernetes está tentando realizar a atualização do nosso `Deployment`, mas não está conseguindo, pois no primeiro `Pod` que ele tentou atualizar, a probe falhou.

```bash
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5fd6c688d8-kjf8d   0/1     Running   0          93s
nginx-deployment-fbdc9b65f-trnnz    1/1     Running   0          9m21s
nginx-deployment-fbdc9b65f-z8n4m    1/1     Running   0          9m21s
nginx-deployment-fbdc9b65f-zn8zh    1/1     Running   0          9m21s
```

&nbsp;

Vamos ver o nosso `rollout`:

```bash
kubectl rollout status deployment/nginx-deployment
```

&nbsp;

```bash
Waiting for deployment "nginx-deployment" rollout to finish: 1 out of 3 new replicas have been updated...
```

&nbsp;

Mesmo depois de algum tempo o nosso `rollout` não terminou, ele continua esperando a nossa probe passar.

Podemos ver os detalhes do `Pod` que está com problema:

```bash
kubectl describe pod nginx-deployment-5fd6c688d8-kjf8d
```

&nbsp;

```bash
Events:
  Type     Reason     Age                   From               Message
  ----     ------     ----                  ----               -------
  Normal   Scheduled  4m4s                  default-scheduler  Successfully assigned default/nginx-deployment-5fd6c688d8-kjf8d to ip-192-168-8-176.ec2.internal
  Normal   Pulled     4m3s                  kubelet            Container image "nginx:1.19.2" already present on machine
  Normal   Created    4m3s                  kubelet            Created container nginx
  Normal   Started    4m3s                  kubelet            Started container nginx
  Warning  Unhealthy  34s (x22 over 3m44s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404
```

&nbsp;

Eu somente colei a parte final da saída, que é a parte mais interessante para esse momento. É nessa parte que podemos ver que o nosso `Pod` não está saudável, e por isso o Kubernetes não está conseguindo atualizar o nosso `Deployment`.

&nbsp;

#### Startup Probe

Chegou a hora de falar sobre a probe, que na minha humilde opinião, é a menos utilizada, mas que é muito importante, a `startupProbe`.

Ela é a responsável por verificar se o nosso container foi inicializado corretamente, e se ele está pronto para receber requisições.

Ele é muito parecido com a `readinessProbe`, mas a diferença é que a `startupProbe` é executada apenas uma vez no começo da vida do nosso container, e a `readinessProbe` é executada de tempos em tempos.

Para entender melhor, vamos ver um exemplo criando um arquivo chamado `nginx-startup.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
        startupProbe: # Onde definimos a nossa probe de inicialização
          httpGet: # O tipo de teste que iremos executar, neste caso, iremos executar um teste HTTP
            path: / # O caminho que iremos testar
            port: 80 # A porta que iremos testar
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 2 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
```

&nbsp;

Agora vamos aplicar a nossa configuração:

```bash
kubectl apply -f nginx-startup.yaml
```

&nbsp;

Quando você tentar aplicar, receberá um erro, pois a `successThreshold` não pode ser maior que 1, pois a `startupProbe` é executada apenas uma vez, lembra?

Da mesma forma o `failureThreshold` não pode ser maior que 1, então vamos alterar o nosso arquivo para:

```yaml
...
        startupProbe: # Onde definimos a nossa probe de inicialização
          httpGet: # O tipo de teste que iremos executar, neste caso, iremos executar um teste HTTP
            path: / # O caminho que iremos testar
            port: 80 # A porta que iremos testar
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 2 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
```

&nbsp;

Agora vamos aplicar novamente:

```bash
kubectl apply -f nginx-startup.yaml
```

&nbsp;

Pronto, aplicado! Ufa! \o/

Perceba que sua definição é super parecida com a `readinessProbe`, mas lembre-se, ela somente será executada uma vez, quando o container for inicializado. Portanto, se alguma coisa acontecer de errado depois disso, ele não irá te salvar, pois ele não irá executar novamente.

Por isso é super importante sempre ter uma combinação entre as probes, para que você tenha um container mais resiliente e que problemas possam ser detectados mais rapidamente.

Vamos ver se os nossos `Pods` estão saudáveis:

```bash
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6fbd5f9794-66sww   1/1     Running   0          2m12s
nginx-deployment-6fbd5f9794-cmwq8   1/1     Running   0          2m12s
nginx-deployment-6fbd5f9794-kvrp8   1/1     Running   0          2m12s
```

&nbsp;

Caso você queira conferir se a nossa probe está lá, basta usar o comando:

```bash
kubectl describe pod nginx-deployment-6fbd5f9794-66sww
```

&nbsp;

E você verá algo parecido com isso:

```bash
    Startup:      http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=1
```

&nbsp;

### Exemplo com todas as probes

Vamos para o nosso exemplo final de hoje, vamos utilizar todas as probes que vimos até aqui, e vamos criar um arquivo chamado `nginx-todas-probes.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.19.2
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
        livenessProbe: # Onde definimos a nossa probe de vida
          exec: # O tipo exec é utilizado quando queremos executar algo dentro do container.
            command: # Onde iremos definir qual comando iremos executar
              - curl
              - -f
              - http://localhost:80/
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 1 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
        readinessProbe: # Onde definimos a nossa probe de prontidão
          httpGet: # O tipo de teste que iremos executar, neste caso, iremos executar um teste HTTP
            path: / # O caminho que iremos testar
            port: 80 # A porta que iremos testar
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 1 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
        startupProbe: # Onde definimos a nossa probe de inicialização
          tcpSocket: # O tipo de teste que iremos executar, neste caso, iremos executar um teste TCP
            port: 80 # A porta que iremos testar
          initialDelaySeconds: 10 # O tempo que iremos esperar para executar a primeira vez a probe
          periodSeconds: 10 # De quanto em quanto tempo iremos executar a probe
          timeoutSeconds: 5 # O tempo que iremos esperar para considerar que a probe falhou
          successThreshold: 1 # O número de vezes que a probe precisa passar para considerar que o container está pronto
          failureThreshold: 3 # O número de vezes que a probe precisa falhar para considerar que o container não está pronto
```

&nbsp;

Pronto, estamos utilizando as três probes, vamos aplicar:

```bash
kubectl apply -f nginx-todas-probes.yaml
```

&nbsp;

E vamos ver se os nossos `Pods` estão saudáveis:

```bash

```

&nbsp;

Vamos ver na saída do `describe pods` se as nossa probes estão por lá.

```bash
...
    Liveness:     exec [curl -f http://localhost:80/] delay=10s timeout=5s period=10s #success=1 #failure=3
    Readiness:    http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=3
    Startup:      tcp-socket :80 delay=10s timeout=5s period=10s #success=1 #failure=3
```

&nbsp;

Todas lá! Maravilha!

Agora podemos dizer que já sabemos como cuidar bem dos nossos `Pods` e deixá-los sempre saudáveis e no controle.

Não esqueça de acessar a documentação oficial do Kubernetes para saber mais sobre as probes, e claro, se tiver alguma dúvida, não deixe de perguntar.

&nbsp;

      
### A sua lição de casa

A sua lição de casa é treinar tudo o que você aprendeu até aqui. O mais importante é você replicar todo o conteúdo que foi apresentado até aqui, para que você possa fixar, e o mais importante, deixar isso de forma mais natural na sua cabeça.

Crie seus exemplos, leia a documentação, faça perguntas, e claro, se tiver alguma dúvida, não deixe de perguntar.

Tudo o que você criar daqui pra frente, terá que ter as probes definidas para garantir um bom funcionamento do seu cluster.

Sem falar que é inadmissível você ter um cluster Kubernetes com seus `pods` rodando sem as probes devidamente configuradas, bem como os limites de recursos.

É isso, simples assim! :D


&nbsp;

### Final do Day-4

Durante o Day-4 você aprendeu tudo sobre `ReplicaSet` e `DaemonSet`. O dia de hoje foi importante para que você pudesse entender que um cluster Kubernetes é muito mais do que somente um monte de `Pods` rodando em um monte de `nodes`. E ainda estamos somente no ínicio da nossa jornada, ainda veremos diversos, talvez dezenas de objetos que irão nos ajudar a gerenciar o nosso cluster de maneira mais efetiva.

Hoje ainda você aprendeu como garantir testes em seus containers, seja no momento da inicialização, ou durante a execução, fazendo com que nossas aplicações sejam mais estáveis e confiáveis.