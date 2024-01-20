# Descomplicando o Kubernetes
## DAY-12: Dominando Taints e Tolerations

## Conteúdo do Day-12

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-12: Dominando Taints e Tolerations](#day-12-dominando-taints-e-tolerations)
  - [Conteúdo do Day-12](#conteúdo-do-day-12)
    - [Introdução](#introdução)
    - [O que são Taints e Tolerations?](#o-que-são-taints-e-tolerations)
    - [Por que usar Taints e Tolerations?](#por-que-usar-taints-e-tolerations)
    - [Anatomia de um Taint](#anatomia-de-um-taint)
    - [Anatomia de uma Toleration](#anatomia-de-uma-toleration)
    - [Aplicando Taints](#aplicando-taints)
    - [Configurando Tolerations](#configurando-tolerations)
    - [Cenários de Uso](#cenários-de-uso)
      - [Isolamento de Workloads](#isolamento-de-workloads)
      - [Nodes Especializados](#nodes-especializados)
      - [Evacuação e Manutenção de Nodes](#evacuação-e-manutenção-de-nodes)
    - [Combinando Taints e Tolerations com Affinity Rules](#combinando-taints-e-tolerations-com-affinity-rules)
    - [Exemplos Práticos](#exemplos-práticos)
      - [Exemplo 1: Isolamento de Workloads](#exemplo-1-isolamento-de-workloads)
      - [Exemplo 2: Utilizando Hardware Especializado](#exemplo-2-utilizando-hardware-especializado)
      - [Exemplo 3: Manutenção de Nodes](#exemplo-3-manutenção-de-nodes)
    - [Conclusão](#conclusão)
    - [Tarefas do Dia](#tarefas-do-dia)
- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes-1)
  - [DAY-12+1: Entendendo e Dominando os Selectors](#day-121-entendendo-e-dominando-os-selectors)
  - [Conteúdo do Day-12+1](#conteúdo-do-day-121)
    - [Introdução](#introdução-1)
    - [O que são Selectors?](#o-que-são-selectors)
    - [Tipos de Selectors](#tipos-de-selectors)
      - [Equality-based Selectors](#equality-based-selectors)
      - [Set-based Selectors](#set-based-selectors)
    - [Selectors em Ação](#selectors-em-ação)
      - [Em Services](#em-services)
      - [Em ReplicaSets](#em-replicasets)
      - [Em Jobs e CronJobs](#em-jobs-e-cronjobs)
    - [Selectors e Namespaces](#selectors-e-namespaces)
    - [Cenários de Uso](#cenários-de-uso-1)
      - [Roteamento de Tráfego](#roteamento-de-tráfego)
      - [Scaling Horizontal](#scaling-horizontal)
      - [Desastre e Recuperação](#desastre-e-recuperação)
    - [Dicas e Armadilhas](#dicas-e-armadilhas)
    - [Exemplos Práticos](#exemplos-práticos-1)
      - [Exemplo 1: Selector em um Service](#exemplo-1-selector-em-um-service)
      - [Exemplo 2: Selector em um ReplicaSet](#exemplo-2-selector-em-um-replicaset)
      - [Exemplo 3: Selectors Avançados](#exemplo-3-selectors-avançados)
    - [Conclusão](#conclusão-1)


### Introdução

Olá, galera! No capítulo de hoje, vamos mergulhar fundo em um dos conceitos mais poderosos e flexíveis do Kubernetes: Taints e Tolerations. Prepare-se, pois este capítulo vai além do básico e entra em detalhes que você não vai querer perder. #VAIIII

### O que são Taints e Tolerations?

Taints são "manchas" ou "marcações" aplicadas aos Nodes que os marcam para evitar que certos Pods sejam agendados neles. Por outro lado, Tolerations são configurações que podem ser aplicadas aos Pods para permitir que eles sejam agendados em Nodes com Taints específicos.

### Por que usar Taints e Tolerations?

Em um cluster Kubernetes diversificado, nem todos os Nodes são iguais. Alguns podem ter acesso a recursos especiais como GPUs, enquanto outros podem ser reservados para workloads críticos. Taints e Tolerations fornecem um mecanismo para garantir que os Pods sejam agendados nos Nodes apropriados.

### Anatomia de um Taint

Um Taint é composto por uma `chave`, um `valor` e um `efeito`. O efeito pode ser:

- `NoSchedule`: O Kubernetes não agenda o Pod a menos que ele tenha uma Toleration correspondente.
- `PreferNoSchedule`: O Kubernetes tenta não agendar, mas não é uma garantia.
- `NoExecute`: Os Pods existentes são removidos se não tiverem uma Toleration correspondente.

### Anatomia de uma Toleration

Uma Toleration é definida pelos mesmos elementos de um Taint: `chave`, `valor` e `efeito`. Além disso, ela contém um `operador`, que pode ser `Equal` ou `Exists`.

### Aplicando Taints

Para aplicar um Taint a um Node, você utiliza o comando `kubectl taint`. Por exemplo:

```bash
kubectl taint nodes node1 key=value:NoSchedule
```

### Configurando Tolerations

Tolerations são configuradas no PodSpec. Aqui está um exemplo:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

### Cenários de Uso

#### Isolamento de Workloads

Imagine um cenário onde você tem Nodes que devem ser dedicados a workloads de produção e não devem executar Pods de desenvolvimento.

Aplicar Taint:

```bash
kubectl taint nodes prod-node environment=production:NoSchedule
```

Toleration em Pod de produção:

```yaml
tolerations:
- key: "environment"
  operator: "Equal"
  value: "production"
  effect: "NoSchedule"
```

#### Nodes Especializados

Se você tem Nodes com GPUs e quer garantir que apenas Pods que necessitem de GPUs sejam agendados ali.

Aplicar Taint:

```bash
kubectl taint nodes gpu-node gpu=true:NoSchedule
```

Toleration em Pod que necessita de GPU:

```yaml
tolerations:
- key: "gpu"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
```

#### Evacuação e Manutenção de Nodes

Se você precisa realizar manutenção em um Node e quer evitar que novos Pods sejam agendados nele.

Aplicar Taint:

```bash
kubectl taint nodes node1 maintenance=true:NoExecute
```

### Combinando Taints e Tolerations com Affinity Rules

Você pode combinar Taints e Tolerations com regras de afinidade para um controle ainda mais granular.

### Exemplos Práticos

#### Exemplo 1: Isolamento de Workloads

Vamos criar um Node com um Taint e tentar agendar um Pod sem a Toleration correspondente.

```bash
# Aplicar Taint
kubectl taint nodes dev-node environment=development:NoSchedule

# Tentar agendar Pod
kubectl run nginx --image=nginx
```

Observe que o Pod não será agendado até que uma Toleration seja adicionada.

#### Exemplo 2: Utilizando Hardware Especializado

Vamos criar um Node com uma GPU e aplicar um Taint correspondente.

```bash
# Aplicar Taint
kubectl taint nodes gpu-node gpu=true:NoSchedule

# Agendar Pod com Toleration
kubectl apply -f gpu-pod.yaml
```

Onde `gpu-pod.yaml` contém a Toleration correspondente.

#### Exemplo 3: Manutenção de Nodes

Vamos simular uma manutenção, aplicando um Taint em um

 Node e observando como os Pods são removidos.

```bash
# Aplicar Taint
kubectl taint nodes node1 maintenance=true:NoExecute
```

### Conclusão

Taints e Tolerations são ferramentas poderosas para o controle refinado do agendamento de Pods. Com elas, você pode isolar workloads, aproveitar hardware especializado e até gerenciar manutenções de forma mais eficaz.

### Tarefas do Dia

1. Aplique um Taint em um dos seus Nodes e tente agendar um Pod sem a Toleration correspondente.
2. Remova o Taint e observe o comportamento.
3. Adicione uma Toleration ao Pod e repita o processo.

# Descomplicando o Kubernetes
## DAY-12+1: Entendendo e Dominando os Selectors

## Conteúdo do Day-12+1





### Introdução

E aí, pessoal! No capítulo de hoje, vamos nos aprofundar em um dos recursos mais versáteis e fundamentais do Kubernetes: os Selectors. Preparados? Então #VAIIII!

### O que são Selectors?

Selectors são formas de selecionar recursos, como Pods, com base em suas labels. Eles são a cola que une vários componentes do Kubernetes, como Services e ReplicaSets.

### Tipos de Selectors

#### Equality-based Selectors

Estes são os mais simples, usando operadores como `=`, `==`, e `!=`.

Exemplo:

```bash
kubectl get pods -l environment=production
```

#### Set-based Selectors

Estes são mais complexos e usam operadores como `in`, `notin`, e `exists`.

Exemplo:

```bash
kubectl get pods -l 'environment in (production, qa)'
```

### Selectors em Ação

#### Em Services

Services usam selectors para direcionar tráfego para Pods específicos.

Exemplo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
```

#### Em ReplicaSets

ReplicaSets usam selectors para saber quais Pods gerenciar.

Exemplo:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
spec:
  selector:
    matchLabels:
      app: MyApp
```

#### Em Jobs e CronJobs

Jobs e CronJobs também podem usar selectors para executar tarefas em Pods específicos.

### Selectors e Namespaces

É crucial entender que os selectors não atravessam namespaces; eles são eficazes apenas dentro do namespace atual, a menos que especificado de outra forma.

### Cenários de Uso

#### Roteamento de Tráfego

Use selectors em Services para direcionar tráfego para versões específicas de uma aplicação.

#### Scaling Horizontal

Use selectors em Horizontal Pod Autoscalers para escalar apenas os Pods que atendem a critérios específicos.

#### Desastre e Recuperação

Em casos de failover, você pode usar selectors para direcionar tráfego para Pods em um cluster secundário.

### Dicas e Armadilhas

- Não mude as labels de Pods que são alvos de Services sem atualizar o selector do Service.
- Use selectors de forma consistente para evitar confusões.

### Exemplos Práticos

#### Exemplo 1: Selector em um Service

Vamos criar um Service que seleciona todos os Pods com a label `frontend`.

```bash
kubectl apply -f frontend-service.yaml
```

#### Exemplo 2: Selector em um ReplicaSet

Vamos criar um ReplicaSet que gerencia todos os Pods com a label `backend`.

```bash
kubectl apply -f backend-replicaset.yaml
```

#### Exemplo 3: Selectors Avançados

Vamos fazer uma query complexa para selecionar Pods com base em múltiplas labels.

```bash
kubectl get pods -l 'release-version in (v1, v2),environment!=debug'
```

### Conclusão

Selectors são uma ferramenta poderosa e flexível no Kubernetes, permitindo um controle fino sobre como os recursos interagem. Dominar este conceito é fundamental para qualquer um que trabalhe com Kubernetes.
