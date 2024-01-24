# Descomplicando o Kubernetes
## DAY-12: Dominando Taints e Tolerations

## Conteúdo do Day-12

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-12: Dominando Taints e Tolerations](#day-12-dominando-taints-e-tolerations)
  - [Conteúdo do Day-12](#conteúdo-do-day-12)
    - [O que vamos ver no dia de hoje?](#o-que-vamos-ver-no-dia-de-hoje)
    - [O Nosso cluster de exemplo](#o-nosso-cluster-de-exemplo)
    - [O que são Taints?](#o-que-são-taints)
    - [O que são Tolerations?](#o-que-são-tolerations)
    - [O que são Affinity e Antiaffinity?](#o-que-são-affinity-e-antiaffinity)



### O que vamos ver no dia de hoje?

Hoje é dia de falar sobre Taints, Tolerations, Affinity e Antiaffinity. Vamos entender como eles podem nos ajudar no dia-a-dia na administração de um cluster Kubernetes.

Com eles podemos isolar workloads, garantir que Pods sejam agendados em Nodes específicos e até mesmo evitar que Pods sejam agendados em determinados Nodes do cluster.

Bora lá, pois o dia será intenso de coisas novas e com certeza você vai aprender muito! Bora?

### O Nosso cluster de exemplo

Para que possamos ter alguns exemplos mais divertido, vamos imaginar que temos um empresa chamada Strigus, e que essa empresa tem o seu cluster Kubernetes de produção composto por 08 nodes, sendo 4 control planes e 4 workers. Ele está dividido em duas regiões, São Paulo e Salvador, chamadas de strigus-br-sp e strigus-br-ssa respectivamente. E cada região tem dois datacenters, strigus-sp-1 e strigus-sp-2 em São Paulo e strigus-br-ssa-1 e strigus-br-ssa-2 em Salvador.

```bash
kubectl get nodes
NAME                     STATUS   ROLES           AGE     VERSION
strigus-control-plane1   Ready    control-plane   65d     v1.27.3
strigus-control-plane2   Ready    control-plane   65d     v1.27.3
strigus-control-plane3   Ready    control-plane   65d     v1.27.3
strigus-control-plane4   Ready    control-plane   65d     v1.27.3
strigus-worker1          Ready    <none>          65d     v1.27.3
strigus-worker2          Ready    <none>          65d     v1.27.3
strigus-worker3          Ready    <none>          65d     v1.27.3
strigus-worker4          Ready    <none>          65d     v1.27.3
```

A nossa missão é criar as Labels e Taints necessárias para que nosso cluster fique organizado, seguro e com alta disponibilidade. E com isso, com alguns ajustes em nossos deployments, garantir que nossos Pods sejam agendados nos Nodes corretos e distribuídos entre os datacenters corretamente.

A distribuição dos nossos nodes nas regiões e datacenters é a seguinte:

- strigus-br-sp
  - strigus-br-sp-1
    - strigus-control-plane1
    - strigus-worker3
  - strigus-br-sp-2
    - strigus-control-plane4
    - strigus-worker1

- strigus-br-ssa
  - strigus-br-ssa-1
    - strigus-control-plane2
    - strigus-worker2
  - strigus-br-ssa-2
    - strigus-control-plane3
    - strigus-worker4
  
A primeira coisa que precisamos fazer é criar as Labels em nossos Nodes. Para isso, vamos utilizar o comando `kubectl label nodes` e vamos adicionar as labels `region` e `datacenter` em cada um dos nossos Nodes.

```bash
kubectl label nodes strigus-control-plane1 region=strigus-br-sp datacenter=strigus-br-sp-1
kubectl label nodes strigus-control-plane2 region=strigus-br-ssa datacenter=strigus-br-ssa-1
kubectl label nodes strigus-control-plane3 region=strigus-br-ssa datacenter=strigus-br-ssa-2
kubectl label nodes strigus-control-plane4 region=strigus-br-sp datacenter=strigus-br-sp-2
kubectl label nodes strigus-worker1 region=strigus-br-sp datacenter=strigus-br-sp-2
kubectl label nodes strigus-worker2 region=strigus-br-ssa datacenter=strigus-br-ssa-1
kubectl label nodes strigus-worker3 region=strigus-br-sp datacenter=strigus-br-sp-1
kubectl label nodes strigus-worker4 region=strigus-br-ssa datacenter=strigus-br-ssa-2
```

Com o comando acima estamos utilizando o `kubectl label nodes` para adicionar as labels `region` e `datacenter` em cada um dos nossos Nodes. Agora, se executarmos o comando `kubectl get nodes strigus-control-plane1 --show-labels`, veremos algo como:

```bash
NAME                     STATUS   ROLES           AGE     VERSION   LABELS
strigus-control-plane1   Ready    control-plane   65d     v1.27.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,datacenter=strigus-br-sp-1,kubernetes.io/arch=amd64,kubernetes.io/hostname=strigus-control-plane1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,region=strigus-br-sp
```

Pronto, as nossas labels estão criadas, com isso já conseguimos ter um pouco mais de organização em nosso cluster.

Mas ainda não acabou o nosso trabalho, cada uma das regiões possui um node com um hardware especial, que é uma GPU. Vamos criar uma label para identificar esses nodes, mas por enquanto é somente para identificar, não vamos fazer nada com eles ainda.

```bash
kubectl label nodes strigus-worker1 gpu=true
kubectl label nodes strigus-worker4 gpu=true
```

Pronto, por enquanto isso resolve, mas com certeza precisaremos adicionar mais labels em nossos nodes no futuro, mas por enquanto isso já resolve o nosso problema.

Caso eu queira remover alguma Label, basta utilizar o comando `kubectl label nodes strigus-control-plane1 region-` e a label será removida.

Agora vamos entender como funcionam as Taints.


### O que são Taints?

Taints são "manchas" ou "marcações" aplicadas aos Nodes que os marcam para evitar que certos Pods sejam agendados neles. Essa é uma forma bastante comum de isolar workloads em um cluster Kubernetes, por exemplo em momentos de manutenção ou quando você tem Nodes com recursos especiais, como GPUs.

Os Taints são aplicados nos Nodes e podem ter um efeito de `NoSchedule`, `PreferNoSchedule` ou `NoExecute`. O efeito `NoSchedule` faz com que o Kubernetes não agende Pods nesse Node a menos que eles tenham uma Toleration correspondente. O efeito `PreferNoSchedule` faz com que o Kubernetes tente não agendar, mas não é uma garantia. E o efeito `NoExecute` faz com que os Pods existentes sejam removidos se não tiverem uma Toleration correspondente.


Agora vamos entender isso na prática!

Em nosso primeiro exemplo vamos conhecer a Taint `NoSchedule`. Para que você possa configurar um Taint em um Node, você utiliza o comando `kubectl taint`. Por exemplo:

```bash
kubectl taint nodes strigus-worker1 key=value:NoSchedule
```

No comando acima, estamos aplicando um Taint no Node `strigus-worker` com a chave `key` e o valor `value` e com o efeito `NoSchedule`. Isso significa que o Kubernetes não irá agendar nenhum Pod nesse Node a menos que ele tenha uma Toleration correspondente, que veremos mais adiante.

Nesse exemplo estamos utilizando a chave `key` e o valor `value`, mas você pode utilizar qualquer chave e valor que desejar. Por exemplo, você pode utilizar `environment=production` para marcar um Node como sendo de produção, ou `gpu=true` para marcar um Node com uma GPU.

Você irá entender melhor o porquê de utilizar Taints e o porquê de utilizar chaves e valores específicos quando falarmos sobre Tolerations.

Para visualizar os Taints aplicados em um Node, você pode utilizar o comando `kubectl describe node strigus-worker1`. Você verá algo como:

```bash
Taints:             key=value:NoSchedule
```

Está lá conforme esperado! Agora o que precisamos fazer é testar! 
O nosso cluster ainda não está com nenhuma aplicação em execução, somente os Pods do próprio Kubernetes, então vamos criar alguns para testar. :)

Para esse teste, vamos criar um Deployment com 10 réplicas do Nginx, e vamos ver o que acontece.

```bash
kubectl create deployment nginx --image=nginx --replicas=10
```

Agora vamos verificar se os Pods foram criados e se estão em execução.

```bash
kubectl get pods -o wide
```

A saída será algo como:

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE              NOMINATED NODE   READINESS GATES
nginx-77b4fdf86c-4rwb9   1/1     Running   0          12s   10.244.4.3   strigus-worker3   <none>           <none>
nginx-77b4fdf86c-chpgb   1/1     Running   0          12s   10.244.6.2   strigus-worker2   <none>           <none>
nginx-77b4fdf86c-dplq7   1/1     Running   0          12s   10.244.5.3   strigus-worker4   <none>           <none>
nginx-77b4fdf86c-l5vwq   1/1     Running   0          12s   10.244.6.4   strigus-worker2   <none>           <none>
nginx-77b4fdf86c-nwwvn   1/1     Running   0          12s   10.244.5.2   strigus-worker4   <none>           <none>
nginx-77b4fdf86c-qz9t4   1/1     Running   0          12s   10.244.5.4   strigus-worker4   <none>           <none>
nginx-77b4fdf86c-r4lt6   1/1     Running   0          12s   10.244.6.5   strigus-worker2   <none>           <none>
nginx-77b4fdf86c-rmqnm   1/1     Running   0          12s   10.244.4.4   strigus-worker3   <none>           <none>
nginx-77b4fdf86c-rsgbg   1/1     Running   0          12s   10.244.4.2   strigus-worker3   <none>           <none>
nginx-77b4fdf86c-wnxg7   1/1     Running   0          12s   10.244.6.3   strigus-worker2   <none>           <none>
```

Perceba que não temos nenhum Pod em execução no Node `strigus-worker1`, que é o Node que aplicamos o Taint. Isso acontece porque o Kubernetes não irá agendar nenhum Pod nesse Node a menos que ele tenha uma Toleration correspondente, que veremos mais adiante.

Agora vamos remover o Taint do Node `strigus-worker1` e ver o que acontece.

```bash
kubectl taint nodes strigus-worker1 key=value:NoSchedule-
```

Os Pods não serão movidos automaticamente para o Node `strigus-worker1`, mas podemos usar o comando `kubectl rollout restart deployment nginx` para reiniciar o Deployment e o Kubernetes redistribuirá os Pods entre os Nodes disponíveis.

```bash
kubectl rollout restart deployment nginx
```

Agora vamos verificar se os Pods foram criados e se estão em execução.

```bash
kubectl get pods -o wide
```

A saída será algo como:

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE              NOMINATED NODE   READINESS GATES
nginx-7c58f9889c-6qcpl   1/1     Running   0          28s   10.244.4.10   strigus-worker3   <none>           <none>
nginx-7c58f9889c-lj7p5   1/1     Running   0          29s   10.244.3.3    strigus-worker1   <none>           <none>
nginx-7c58f9889c-mdrj7   1/1     Running   0          29s   10.244.4.9    strigus-worker3   <none>           <none>
nginx-7c58f9889c-nr7h9   1/1     Running   0          29s   10.244.6.9    strigus-worker2   <none>           <none>
nginx-7c58f9889c-pqrb9   1/1     Running   0          26s   10.244.3.4    strigus-worker1   <none>           <none>
nginx-7c58f9889c-pzx7n   1/1     Running   0          29s   10.244.5.8    strigus-worker4   <none>           <none>
nginx-7c58f9889c-qn9hh   1/1     Running   0          28s   10.244.5.9    strigus-worker4   <none>           <none>
nginx-7c58f9889c-wmm2n   1/1     Running   0          26s   10.244.6.11   strigus-worker2   <none>           <none>
nginx-7c58f9889c-znrjt   1/1     Running   0          29s   10.244.3.2    strigus-worker1   <none>           <none>
nginx-7c58f9889c-zp9g9   1/1     Running   0          28s   10.244.6.10   strigus-worker2   <none>           <none>
```

Pronto, ele redistribuiu os Pods entre os Nodes disponíveis, e voltou a executar Pods no Node `strigus-worker1`, afinal, nós removemos o Taint dele.

Agora vamos testar o efeito `NoExecute`. Para isso, vamos aplicar um Taint no Node `strigus-worker1` com o efeito `NoExecute`.

```bash
kubectl taint nodes strigus-worker1 key=value:NoExecute
```

Diferente do efeito `NoSchedule`, o efeito `NoExecute` faz com que os Pods existentes sejam removidos se não tiverem uma Toleration correspondente. 

Vamos ver o que aconteceu com os nossos Pods.

```bash
NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE              NOMINATED NODE   READINESS GATES
nginx-7c58f9889c-6qcpl   1/1     Running   0          2m29s   10.244.4.10   strigus-worker3   <none>           <none>
nginx-7c58f9889c-gm6tb   1/1     Running   0          5s      10.244.4.11   strigus-worker3   <none>           <none>
nginx-7c58f9889c-lnhmf   1/1     Running   0          5s      10.244.5.10   strigus-worker4   <none>           <none>
nginx-7c58f9889c-mdrj7   1/1     Running   0          2m30s   10.244.4.9    strigus-worker3   <none>           <none>
nginx-7c58f9889c-mz78w   1/1     Running   0          5s      10.244.6.12   strigus-worker2   <none>           <none>
nginx-7c58f9889c-nr7h9   1/1     Running   0          2m30s   10.244.6.9    strigus-worker2   <none>           <none>
nginx-7c58f9889c-pzx7n   1/1     Running   0          2m30s   10.244.5.8    strigus-worker4   <none>           <none>
nginx-7c58f9889c-qn9hh   1/1     Running   0          2m29s   10.244.5.9    strigus-worker4   <none>           <none>
nginx-7c58f9889c-wmm2n   1/1     Running   0          2m27s   10.244.6.11   strigus-worker2   <none>           <none>
nginx-7c58f9889c-zp9g9   1/1     Running   0          2m29s   10.244.6.10   strigus-worker2   <none>           <none>
```

Funcionou! Os Pods que estavam executando no Node `strigus-worker1` foram removidos e agendados em outros Nodes.

Nesse caso, o Kubernetes não irá agendar nenhum Pod nesse Node a menos que ele tenha uma Toleration para o Taint que aplicamos.

Isso é interessante em momentos que você precisa realizar manutenção em um Node, garantindo que não teremos nenhum Pod executando nele e que nenhum Pod será agendado nesse Node.

Agora vamos remover o Taint do Node `strigus-worker1` e ver o que acontece.

```bash
kubectl taint nodes strigus-worker1 key=value:NoExecute-
```

Mais uma vez vale lembrar, o Kubernetes não irá mover os Pods automaticamente para o Node `strigus-worker1`, mas podemos usar o comando `kubectl rollout restart deployment nginx` para reiniciar o Deployment e o Kubernetes redistribuirá os Pods entre os Nodes disponíveis.

```bash
kubectl rollout restart deployment nginx
```

Simples como voar!

Agora vamos entender o efeito `PreferNoSchedule`. Para isso, vamos aplicar um Taint no Node `strigus-worker1` com o efeito `PreferNoSchedule`.

```bash
kubectl taint nodes strigus-worker1 key=value:PreferNoSchedule
```

Diferente do efeito `NoSchedule`, o efeito `PreferNoSchedule` faz com que o Kubernetes tente não agendar, mas não é uma garantia.

Ele tentará agendar os Pods em outros Nodes, mas se não for possível, ele irá agendar no Node que tem o Taint.

Os nossos Pods estão distribuidos da seguinte forma:

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE              NOMINATED NODE   READINESS GATES
nginx-67668985bc-6h2ml   1/1     Running   0          9s    10.244.3.5    strigus-worker1   <none>           <none>
nginx-67668985bc-dbnxr   1/1     Running   0          9s    10.244.5.11   strigus-worker4   <none>           <none>
nginx-67668985bc-hxkt8   1/1     Running   0          9s    10.244.3.6    strigus-worker1   <none>           <none>
nginx-67668985bc-ldwck   1/1     Running   0          9s    10.244.6.13   strigus-worker2   <none>           <none>
nginx-67668985bc-nvcd8   1/1     Running   0          7s    10.244.3.7    strigus-worker1   <none>           <none>
nginx-67668985bc-pwz4d   1/1     Running   0          9s    10.244.4.12   strigus-worker3   <none>           <none>
nginx-67668985bc-v2s2b   1/1     Running   0          7s    10.244.4.13   strigus-worker3   <none>           <none>
nginx-67668985bc-xdqjw   1/1     Running   0          7s    10.244.5.13   strigus-worker4   <none>           <none>
nginx-67668985bc-xkdt8   1/1     Running   0          7s    10.244.5.12   strigus-worker4   <none>           <none>
nginx-67668985bc-zdtsq   1/1     Running   0          7s    10.244.6.14   strigus-worker2   <none>           <none>
```

Temos Pods em execução no Node `strigus-worker1`, que é o Node que aplicamos o Taint, pois esses Pods já estavam em execução antes de aplicarmos o Taint.

Agora vamos aumentar o número de réplicas do nosso Deployment para 20 e ver o que acontece.

```bash
kubectl scale deployment nginx --replicas=20
```

Agora vamos verificar se os Pods foram criados e se estão em execução.

```bash
kubectl get pods -o wide
```

A saída será algo como:

```bash
NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE              NOMINATED NODE   READINESS GATES
nginx-67668985bc-6h2ml   1/1     Running   0          2m24s   10.244.3.5    strigus-worker1   <none>           <none>
nginx-67668985bc-9298b   1/1     Running   0          22s     10.244.5.17   strigus-worker4   <none>           <none>
nginx-67668985bc-c8nck   1/1     Running   0          22s     10.244.4.17   strigus-worker3   <none>           <none>
nginx-67668985bc-dbnxr   1/1     Running   0          2m24s   10.244.5.11   strigus-worker4   <none>           <none>
nginx-67668985bc-fds62   1/1     Running   0          22s     10.244.6.18   strigus-worker2   <none>           <none>
nginx-67668985bc-gtmq8   1/1     Running   0          22s     10.244.4.19   strigus-worker3   <none>           <none>
nginx-67668985bc-hxkt8   1/1     Running   0          2m24s   10.244.3.6    strigus-worker1   <none>           <none>
nginx-67668985bc-kbtqc   1/1     Running   0          22s     10.244.4.20   strigus-worker3   <none>           <none>
nginx-67668985bc-ldwck   1/1     Running   0          2m24s   10.244.6.13   strigus-worker2   <none>           <none>
nginx-67668985bc-mtsxv   1/1     Running   0          22s     10.244.6.19   strigus-worker2   <none>           <none>
nginx-67668985bc-nvcd8   1/1     Running   0          2m22s   10.244.3.7    strigus-worker1    <none>           <none>
nginx-67668985bc-pwz4d   1/1     Running   0          2m24s   10.244.4.12   strigus-worker3   <none>           <none>
nginx-67668985bc-snvnt   1/1     Running   0          22s     10.244.5.16   strigus-worker4   <none>           <none>
nginx-67668985bc-txgd4   1/1     Running   0          22s     10.244.4.18   strigus-worker3   <none>           <none>
nginx-67668985bc-v2s2b   1/1     Running   0          2m22s   10.244.4.13   strigus-worker3   <none>           <none>
nginx-67668985bc-w9hmj   1/1     Running   0          22s     10.244.6.20   strigus-worker2   <none>           <none>
nginx-67668985bc-xdqjw   1/1     Running   0          2m22s   10.244.5.13   strigus-worker4   <none>           <none>
nginx-67668985bc-xkdt8   1/1     Running   0          2m22s   10.244.5.12   strigus-worker4   <none>           <none>
nginx-67668985bc-zdtsq   1/1     Running   0          2m22s   10.244.6.14   strigus-worker2   <none>           <none>
nginx-67668985bc-zfglb   1/1     Running   0          22s     10.244.6.21   strigus-worker2   <none>           <none>
```

O que vemos na saída do comando é que o Kube-Scheduler agendou os Pods em outros Nodes, mantendo somente os Pods que já estavam em execução no Node `strigus-worker1`.

O Kube-scheduler somente irá agendar novos pods no Node `strigus-worker1` se não houver nenhum outro Node disponível. Simples demais, não?!?

### O que são Tolerations?

Agora que entendemos como os Taints funcionam e como eles influenciam o agendamento de Pods nos Nodes, vamos mergulhar no mundo das Tolerations. As Tolerations são como o "antídoto" para os Taints. Elas permitem que um Pod seja agendado em um Node que possui um Taint específico. Em outras palavras, elas "toleram" as Taints.

Vamos voltar ao nosso cluster da Strigus para entender melhor como isso funciona.

Imagine que temos um workload crítico que precisa ser executado em um Node com GPU. Já marcamos nossos Nodes com GPU com a label `gpu=true`, e agora vamos usar Tolerations para garantir que nosso Pod possa ser agendado nesses Nodes. Isso não faz com que o Pod seja agendado nesses Nodes, mas permite que ele seja agendado nesses Nodes. Entendeu a diferença?

Primeiro, vamos criar um Taint no Node `strigus-worker1`, que possui uma GPU.

```bash
kubectl taint nodes strigus-worker1 gpu=true:NoSchedule
```

Com esse Taint, estamos dizendo que nenhum Pod será agendado nesse Node, a menos que ele tenha uma Toleration específica para a Taint `gpu=true`.

Vamos criar um Deployment com 5 réplicas do Nginx e ver o que acontece.

```bash
kubectl create deployment nginx --image=nginx --replicas=5
```

Agora vamos verificar se os Pods foram criados e se estão em execução.

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE              NOMINATED NODE   READINESS GATES
nginx-77b4fdf86c-274jk   1/1     Running   0          5s    10.244.6.31   strigus-worker2   <none>           <none>
nginx-77b4fdf86c-97r8d   1/1     Running   0          5s    10.244.5.25   strigus-worker4   <none>           <none>
nginx-77b4fdf86c-cm96h   1/1     Running   0          5s    10.244.6.30   strigus-worker2   <none>           <none>
nginx-77b4fdf86c-rhdmh   1/1     Running   0          5s    10.244.4.29   strigus-worker3   <none>           <none>
nginx-77b4fdf86c-ttqzg   1/1     Running   0          5s    10.244.4.30   strigus-worker3   <none>           <none>
```

Como esperado, nenhum Pod foi agendado no Node `strigus-worker1`, que é o Node que aplicamos o Taint.

Agora, vamos modificar o nosso Deployment do Nginx para que ele tenha uma Toleration para a Taint `gpu=true`.

Para ficar mais fácil, vamos criar um manifesto para o nosso Deployment utilizando o comando `kubectl create deployment nginx --image=nginx --replicas=5 --dry-run=client -o yaml > gpu-deployment.yaml`.

Agora vamos editar o arquivo `gpu-deployment.yaml` e adicionar a Toleration para a Taint `gpu=true`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
      tolerations:
      - key: gpu
        operator: Equal
        value: "true"
        effect: NoSchedule
```

Vamos entender o que adicionamos no arquivo.

```yaml
      tolerations:
      - key: gpu
        operator: Equal
        value: "true"
        effect: NoSchedule
```

Onde:

- `key` é a chave do Taint que queremos tolerar.
- `operator` é o operador que queremos utilizar. Nesse caso, estamos utilizando o operador `Equal`, que significa que o valor do Taint precisa ser igual ao valor da Toleration.
- `value` é o valor do Taint que queremos tolerar.
- `effect` é o efeito do Taint que queremos tolerar. Nesse caso, estamos utilizando o efeito `NoSchedule`, que significa que o Kubernetes não irá agendar nenhum Pod nesse Node a menos que ele tenha uma Toleration correspondente.

Vamos aplicar esse Deployment e ver o que acontece.

```bash
kubectl apply -f gpu-deployment.yaml
```

Se verificarmos os Pods agora, veremos que o nosso Pod `gpu-pod` está rodando no Node `strigus-worker1`.

```bash
kubectl get pods -o wide
```

A saída mostrará algo como:

```bash
NAME                    READY   STATUS    RESTARTS   AGE   IP            NODE              NOMINATED NODE   READINESS GATES
nginx-7b68fffb4-czrpt   1/1     Running   0          11s   10.244.5.24   strigus-worker4   <none>           <none>
nginx-7b68fffb4-d577x   1/1     Running   0          11s   10.244.4.28   strigus-worker3   <none>           <none>
nginx-7b68fffb4-g2kxr   1/1     Running   0          11s   10.244.3.10   strigus-worker1    <none>           <none>
nginx-7b68fffb4-m5kln   1/1     Running   0          11s   10.244.6.29   strigus-worker2   <none>           <none>
nginx-7b68fffb4-n6kck   1/1     Running   0          11s   10.244.3.11   strigus-worker1    <none>           <none>
```

Isso demonstra o poder das Tolerations em combinação com os Taints. Podemos controlar com precisão onde nossos Pods são agendados, garantindo que workloads críticos tenham os recursos que necessitam.

Para remover o Taint do Node `strigus-worker1`, basta usar o comando `kubectl taint nodes strigus-worker1 gpu=true:NoSchedule-`.

Mas lembrando mais uma vez, as Tolerations não fazem com que o Pod seja agendado nesses Nodes, mas permite que ele seja agendado nesses Nodes.

Então, caso você queira garantir que determinado Pod seja executado em determinado Node, você precisa utilizar o conceito de Affinity, que veremos agora.


### O que são Affinity e Antiaffinity?

Affinity e Antiaffinity são conceitos que permitem que você defina regras para o agendamento de Pods em determinados Nodes. Com eles você pode definir regras para que Pods sejam agendados em Nodes específicos, ou até mesmo para que Pods não sejam agendados em Nodes específicos.

Vamos entender como isso funciona na prática.

Você se lembra que adicionamos a label `gpu=true` nos Nodes que possuem GPU? Então, vamos utilizar essa label para garantir que o nosso Pod seja agendado somente neles. Para isso, vamos utilizar o conceito de Affinity.

Vamos criar um Deployment com 5 réplicas do Nginx com a seguinte configuração:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: gpu
                operator: In
                values:
                - "true"
```

Vamos entender o que temos de novo:

```yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: gpu
                operator: In
                values:
                - "true"
```

Onde:

- `affinity` é o início da configuração de Affinity.
- `nodeAffinity` é o conceito de Affinity para Nodes.
- `requiredDuringSchedulingIgnoredDuringExecution` é usado para indicar que o Pod só pode ser agendado em um Node que atenda aos requisitos de Affinity, está falando que essa regra é obrigatória no momento do agendamento do Pod, mas que pode ser ignorada durante a execução do Pod.
- `nodeSelectorTerms` é usado para indicar os termos de seleção de Nodes, que será usado para selecionar os Nodes que atendem aos requisitos de Affinity.
- `matchExpressions` é usado para indicar as expressões de seleção de Nodes, ou seja, o nome da label, o operador e o valor da label.
- `key` é o nome da label que queremos utilizar para selecionar os Nodes.
- `operator` é o operador que queremos utilizar. Nesse caso, estamos utilizando o operador `In`, que significa que o valor da label precisa estar dentro dos valores que estamos informando.
- `values` é o valor da label que queremos utilizar para selecionar os Nodes.

Sendo assim, estamos falando para o Kubernetes que o nosso Pod só pode ser agendado em um Node que tenha a label `gpu=true`. Simples assim!

Vamos aplicar esse Deployment e ver o que acontece.

```bash
kubectl apply -f gpu-deployment.yaml
```

Se verificarmos os Pods agora, veremos que os nossos Pods estão rodando somente nos Nodes que possuem a label `gpu=true`.

```bash
kubectl get pods -o wide
```

A saída mostrará algo como:

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE              NOMINATED NODE   READINESS GATES
nginx-5dd89c4b9b-hwzcx   1/1     Running   0          4s    10.244.3.13   strigus-worker1    <none>           <none>
nginx-5dd89c4b9b-m4fj2   1/1     Running   0          4s    10.244.5.37   strigus-worker4   <none>           <none>
nginx-5dd89c4b9b-msnv8   1/1     Running   0          4s    10.244.3.14   strigus-worker1    <none>           <none>
nginx-5dd89c4b9b-nlcgs   1/1     Running   0          4s    10.244.5.36   strigus-worker4   <none>           <none>
nginx-5dd89c4b9b-trgw7   1/1     Running   0          4s    10.244.3.12   strigus-worker1    <none>           <none>
```

Isso demonstra o poder do Affinity. Podemos controlar com precisão onde nossos Pods são agendados, garantindo que workloads críticos tenham os recursos que necessitam. Sensacional demais!

Agora vamos entender o conceito de Antiaffinity.


TBD




