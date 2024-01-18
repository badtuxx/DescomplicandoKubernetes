# Descomplicando o Kubernetes
## DAY-11

&nbsp;

## Conteúdo do Day-11

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-11](#day-11)
  - [Conteúdo do Day-11](#conteúdo-do-day-11)
    - [Início da aula do Day-11](#início-da-aula-do-day-11)
      - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
      - [Introdução ao Horizontal Pod Autoscaler (HPA)](#introdução-ao-horizontal-pod-autoscaler-hpa)
      - [Como o HPA Funciona?](#como-o-hpa-funciona)
  - [Introdução ao Metrics Server](#introdução-ao-metrics-server)
    - [Por que o Metrics Server é importante para o HPA?](#por-que-o-metrics-server-é-importante-para-o-hpa)
    - [Instalando o Metrics Server](#instalando-o-metrics-server)
      - [No Amazon EKS e na maioria dos clusters Kubernetes](#no-amazon-eks-e-na-maioria-dos-clusters-kubernetes)
      - [No Minikube:](#no-minikube)
      - [No KinD (Kubernetes in Docker):](#no-kind-kubernetes-in-docker)
      - [Verificando a Instalação do Metrics Server](#verificando-a-instalação-do-metrics-server)
      - [Obtendo Métricas](#obtendo-métricas)
    - [Criando um HPA](#criando-um-hpa)
    - [Exemplos Práticos com HPA](#exemplos-práticos-com-hpa)
      - [Autoscaling com base na utilização de CPU](#autoscaling-com-base-na-utilização-de-cpu)
      - [Autoscaling com base na utilização de Memória](#autoscaling-com-base-na-utilização-de-memória)
      - [Configuração Avançada de HPA: Definindo Comportamento de Escalonamento](#configuração-avançada-de-hpa-definindo-comportamento-de-escalonamento)
      - [ContainerResource](#containerresource)
      - [Detalhes do Algoritmo de Escalonamento](#detalhes-do-algoritmo-de-escalonamento)
      - [Configurações Avançadas e Uso Prático](#configurações-avançadas-e-uso-prático)
      - [Integrando HPA com Prometheus para Métricas Customizadas](#integrando-hpa-com-prometheus-para-métricas-customizadas)
    - [A sua lição de casa](#a-sua-lição-de-casa)
    - [Final do Day-11](#final-do-day-11)
  
&nbsp;

### Início da aula do Day-11

#### O que iremos ver hoje?

Hoje é um dia particularmente fascinante! Vamos desbravar os territórios do Kubernetes, explorando a magia do Horizontal Pod Autoscaler (HPA), uma ferramenta indispensável para quem almeja uma operação eficiente e resiliente. Portanto, afivelem os cintos e preparem-se para uma jornada de descobertas. A aventura #VAIIII começar!

#### Introdução ao Horizontal Pod Autoscaler (HPA)

O Horizontal Pod Autoscaler, carinhosamente conhecido como HPA, é uma das joias brilhantes incrustadas no coração do Kubernetes. Com o HPA, podemos ajustar automaticamente o número de réplicas de um conjunto de pods, assegurando que nosso aplicativo tenha sempre os recursos necessários para performar eficientemente, sem desperdiçar recursos. O HPA é como um maestro que, com a batuta das métricas, rege a orquestra de pods, assegurando que a harmonia seja mantida mesmo quando a sinfonia do tráfego de rede atinge seu crescendo.

#### Como o HPA Funciona?

O HPA é o olheiro vigilante que monitora as métricas dos nossos pods. A cada batida do seu coração métrico, que ocorre em intervalos regulares, ele avalia se os pods estão suando a camisa para atender às demandas ou se estão relaxando mais do que deveriam. Com base nessa avaliação, ele toma a decisão sábia de convocar mais soldados para o campo de batalha ou de dispensar alguns para um merecido descanso.

Certamente! O Metrics Server é uma componente crucial para o funcionamento do Horizontal Pod Autoscaler (HPA), pois fornece as métricas necessárias para que o HPA tome decisões de escalonamento. Vamos entender um pouco mais sobre o Metrics Server e como instalá-lo em diferentes ambientes Kubernetes, incluindo Minikube e KinD.

---

## Introdução ao Metrics Server

Antes de começarmos a explorar o Horizontal Pod Autoscaler (HPA), é essencial termos o Metrics Server instalado em nosso cluster Kubernetes. O Metrics Server é um agregador de métricas de recursos de sistema, que coleta métricas como uso de CPU e memória dos nós e pods no cluster. Essas métricas são vitais para o funcionamento do HPA, pois são usadas para determinar quando e como escalar os recursos.

### Por que o Metrics Server é importante para o HPA?

O HPA utiliza métricas de uso de recursos para tomar decisões inteligentes sobre o escalonamento dos pods. Por exemplo, se a utilização da CPU de um pod exceder um determinado limite, o HPA pode decidir aumentar o número de réplicas desse pod. Da mesma forma, se a utilização da CPU for muito baixa, o HPA pode decidir reduzir o número de réplicas. Para fazer isso de forma eficaz, o HPA precisa ter acesso a métricas precisas e atualizadas, que são fornecidas pelo Metrics Server.
Portanto, precisamos antes conhecer essa peça fundamental para o dia de hoje! :D

### Instalando o Metrics Server

#### No Amazon EKS e na maioria dos clusters Kubernetes

Durante a nossa aula, estou com um cluster EKS, e para instalar o Metrics Server, podemos usar o seguinte comando:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Esse comando aplica o manifesto do Metrics Server ao seu cluster, instalando todos os componentes necessários.

#### No Minikube:

A instalação do Metrics Server no Minikube é bastante direta. Use o seguinte comando para habilitar o Metrics Server:

```bash
minikube addons enable metrics-server
```

Após a execução deste comando, o Metrics Server será instalado e ativado em seu cluster Minikube.

#### No KinD (Kubernetes in Docker):

Para o KinD, você pode usar o mesmo comando que usou para o EKS:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### Verificando a Instalação do Metrics Server

Após a instalação do Metrics Server, é uma boa prática verificar se ele foi instalado corretamente e está funcionando como esperado. Execute o seguinte comando para obter a lista de pods no namespace `kube-system` e verificar se o pod do Metrics Server está em execução:

```bash
kubectl get pods -n kube-system | grep metrics-server
```

#### Obtendo Métricas

Com o Metrics Server em execução, agora você pode começar a coletar métricas de seu cluster. Aqui está um exemplo de como você pode obter métricas de uso de CPU e memória para todos os seus nodes:

```bash
kubectl top nodes
```

E para obter métricas de uso de CPU e memória para todos os seus pods:

```bash
kubectl top pods
```

Esses comandos fornecem uma visão rápida da utilização de recursos em seu cluster, o que é crucial para entender e otimizar o desempenho de seus aplicativos.

### Criando um HPA

Antes de nos aprofundarmos no HPA, vamos recapitular criando um deployment simples para o nosso confiável servidor Nginx.

```yaml
# Definição de um Deployment para o servidor Nginx
apiVersion: apps/v1  # Versão da API que define um Deployment
kind: Deployment     # Tipo de recurso que estamos definindo
metadata:
  name: nginx-deployment  # Nome do nosso Deployment
spec:
  replicas: 3             # Número inicial de réplicas
  selector:
    matchLabels:
      app: nginx         # Label que identifica os pods deste Deployment
  template:
    metadata:
      labels:
        app: nginx       # Label aplicada aos pods
    spec:
      containers:
      - name: nginx      # Nome do contêiner
        image: nginx:latest  # Imagem do contêiner
        ports:
        - containerPort: 80  # Porta exposta pelo contêiner
        resources:
          limits:
            cpu: 500m        # Limite de CPU
            memory: 256Mi    # Limite de memória
          requests:
            cpu: 250m        # Requisição de CPU
            memory: 128Mi    # Requisição de memória
```

Agora, com nosso deployment pronto, vamos dar o próximo passo na criação do nosso HPA.

```yaml
# Definição do HPA para o nginx-deployment
apiVersion: autoscaling/v2  # Versão da API que define um HPA
kind: HorizontalPodAutoscaler  # Tipo de recurso que estamos definindo
metadata:
  name: nginx-deployment-hpa  # Nome do nosso HPA
spec:
  scaleTargetRef:
    apiVersion: apps/v1        # A versão da API do recurso alvo
    kind: Deployment           # O tipo de recurso alvo
    name: nginx-deployment     # O nome do recurso alvo
  minReplicas: 3               # Número mínimo de réplicas
  maxReplicas: 10              # Número máximo de réplicas
  metrics:
  - type: Resource             # Tipo de métrica (recurso do sistema)
    resource:
      name: cpu                # Nome da métrica (CPU neste caso)
      target:
        type: Utilization      # Tipo de alvo (utilização)
        averageUtilization: 50 # Valor alvo (50% de utilização)
```

Neste exemplo, criamos um HPA que monitora a utilização da CPU do nosso `nginx-deployment`. O HPA se esforçará para manter a utilização da CPU em torno de 50%, ajustando o número de réplicas entre 3 e 10 conforme necessário.

Para aplicar esta configuração ao seu cluster Kubernetes, salve o conteúdo acima em um arquivo chamado

 `nginx-deployment-hpa.yaml` e execute o seguinte comando:

```bash
kubectl apply -f nginx-deployment-hpa.yaml
```

Agora, você tem um HPA monitorando e ajustando a escala do seu `nginx-deployment` baseado na utilização da CPU. Fantástico, não é?

### Exemplos Práticos com HPA

Agora que você já entende o básico sobre o HPA, é hora de rolar as mangas e entrar na prática. Vamos explorar como o HPA responde a diferentes métricas e cenários.

#### Autoscaling com base na utilização de CPU

Vamos começar com um exemplo clássico de escalonamento baseado na utilização da CPU, que já discutimos anteriormente. Para tornar a aprendizagem mais interativa, vamos simular um aumento de tráfego e observar como o HPA responde a essa mudança.

```bash
kubectl run -i --tty load-generator --image=busybox /bin/sh

while true; do wget -q -O- http://nginx-deployment.default.svc.cluster.local; done
```

Este script simples cria uma carga constante no nosso deployment, fazendo requisições contínuas ao servidor Nginx. Você poderá observar como o HPA ajusta o número de réplicas para manter a utilização da CPU em torno do limite definido.

#### Autoscaling com base na utilização de Memória

O HPA não é apenas um mestre em lidar com a CPU, ele também tem um olho afiado para a memória. Vamos explorar como configurar o HPA para escalar baseado na utilização de memória.

```yaml
# Definição do HPA para escalonamento baseado em memória
apiVersion: autoscaling/v2  # Versão da API que define um HPA
kind: HorizontalPodAutoscaler    # Tipo de recurso que estamos definindo
metadata:
  name: nginx-deployment-hpa-memory  # Nome do nosso HPA
spec:
  scaleTargetRef:
    apiVersion: apps/v1              # A versão da API do recurso alvo
    kind: Deployment                 # O tipo de recurso alvo
    name: nginx-deployment           # O nome do recurso alvo
  minReplicas: 3                     # Número mínimo de réplicas
  maxReplicas: 10                    # Número máximo de réplicas
  metrics:
  - type: Resource                   # Tipo de métrica (recurso do sistema)
    resource:
      name: memory                   # Nome da métrica (memória neste caso)
      target:
        type: Utilization            # Tipo de alvo (utilização)
        averageUtilization: 70       # Valor alvo (70% de utilização)
```

Neste exemplo, o HPA vai ajustar o número de réplicas para manter a utilização de memória em cerca de 70%. Assim, nosso deployment pode respirar livremente mesmo quando a demanda aumenta.

#### Configuração Avançada de HPA: Definindo Comportamento de Escalonamento

O HPA é flexível e permite que você defina como ele deve se comportar durante o escalonamento para cima e para baixo. Vamos explorar um exemplo:

```yaml
# Definição de HPA com configurações avançadas de comportamento
apiVersion: autoscaling/v2      # Versão da API que define um HPA
kind: HorizontalPodAutoscaler        # Tipo de recurso que estamos definindo
metadata:
  name: nginx-deployment-hpa         # Nome do nosso HPA
spec:
  scaleTargetRef:
    apiVersion: apps/v1              # A versão da API do recurso alvo
    kind: Deployment                 # O tipo de recurso alvo
    name: nginx-deployment           # O nome do recurso alvo
  minReplicas: 3                     # Número mínimo de réplicas
  maxReplicas: 10                    # Número máximo de réplicas
  metrics:
  - type: Resource                   # Tipo de métrica (recurso do sistema)
    resource:
      name: cpu                      # Nome da métrica (CPU neste caso)
      target:
        type: Utilization            # Tipo de alvo (utilização)
        averageUtilization: 50       # Valor alvo (50% de utilização)
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0  # Período de estabilização para escalonamento para cima
      policies:
      - type: Percent                # Tipo de política (percentual)
        value: 100                   # Valor da política (100%)
        periodSeconds: 15            # Período da política (15 segundos)
    scaleDown:
      stabilizationWindowSeconds: 300  # Período de estabilização para escalonamento para baixo
      policies:
      - type: Percent                  # Tipo de política (percentual)
        value: 100                     # Valor da política (100%)
        periodSeconds: 15              # Período da política (15 segundos)
```

Neste exemplo, especificamos um comportamento de escalonamento onde o HPA pode escalar para cima imediatamente, mas vai esperar por 5 minutos (300 segundos) após o último escalonamento para cima antes de considerar um escalonamento para baixo. Isso ajuda a evitar flutuações rápidas na contagem de réplicas, proporcionando um ambiente mais estável para nossos pods.


#### ContainerResource

O tipo de métrica `ContainerResource` no Kubernetes permite que você especifique métricas de recursos específicas do container para escalar. Diferente das métricas de recurso comuns que são aplicadas a todos os contêineres em um Pod, as métricas `ContainerResource` permitem especificar métricas para um contêiner específico dentro de um Pod. Isso pode ser útil em cenários onde você tem múltiplos contêineres em um Pod, mas quer escalar com base na utilização de recursos de um contêiner específico.

Aqui está um exemplo de como você pode configurar um Horizontal Pod Autoscaler (HPA) usando uma métrica `ContainerResource` para escalar um Deployment com base na utilização de CPU de um contêiner específico:

```yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: ContainerResource
    containerResource:
      name: cpu
      container: nginx-NOME-COMPLETO-DO-CONTAINER
      target:
        type: Utilization
        averageUtilization: 50
```

No exemplo acima:

- O tipo de métrica é definido como `ContainerResource`.
- Dentro do bloco `containerResource`, especificamos o nome da métrica (`cpu`), o nome do contêiner (`my-container`) e o alvo de utilização (`averageUtilization: 50`).

Isso significa que o HPA vai ajustar o número de réplicas do Deployment `my-app` para manter a utilização média de CPU do contêiner `nginx-NOME-COMPLETO-DO-CONTAINER` em torno de 50%.

Este tipo de configuração permite um controle mais granular sobre o comportamento de autoscaling, especialmente em ambientes onde os Pods contêm múltiplos contêineres com diferentes perfis de utilização de recursos.


#### Detalhes do Algoritmo de Escalonamento

**Cálculo do Número de Réplicas**
O núcleo do Horizontal Pod Autoscaler (HPA) é o seu algoritmo de escalonamento, que determina o número ideal de réplicas com base nas métricas fornecidas. A fórmula básica utilizada pelo HPA para calcular o número desejado de réplicas é:

\[ \text{desiredReplicas} = \lceil \text{currentReplicas} \times \left( \frac{\text{currentMetricValue}}{\text{desiredMetricValue}} \right) \rceil \]

**Exemplos com Valores Específicos:**
1. **Exemplo de Escala para Cima:**
   - Réplicas atuais: 2
   - Valor atual da métrica (CPU): 80%
   - Valor desejado da métrica (CPU): 50%
   - Cálculo: \(\lceil 2 \times (80\% / 50\%) \rceil = \lceil 3.2 \rceil = 4\) réplicas

2. **Exemplo de Escala para Baixo:**
   - Réplicas atuais: 5
   - Valor atual da métrica (CPU): 30%
   - Valor desejado da métrica (CPU): 50%
   - Cálculo: \(\lceil 5 \times (30\% / 50\%) \rceil = \lceil 3 \rceil = 3\) réplicas

**Considerações Sobre Métricas e Estado dos Pods:**
- **Métricas de Recurso por Pod e Personalizadas:** O HPA pode ser configurado para usar métricas padrão (como CPU e memória) ou métricas personalizadas definidas pelo usuário, permitindo maior flexibilidade.
- **Tratamento de Pods sem Métricas ou Não Prontos:** Se um Pod não tiver métricas disponíveis ou não estiver pronto, ele pode ser excluído do cálculo de média, evitando decisões de escalonamento baseadas em dados incompletos.

#### Configurações Avançadas e Uso Prático

**Configurando Métricas Personalizadas e Múltiplas Métricas:**
O HPA não se limita apenas a métricas de CPU e memória; ele pode ser configurado para usar uma variedade de métricas personalizadas.

**Uso de Métricas Personalizadas: Exemplos e Dicas:**
- **Exemplo:** Suponha que você tenha um serviço que deve escalar com base no número de solicitações HTTP por segundo. Você pode configurar o HPA para escalar com base nessa métrica personalizada.
- **Dicas:** Ao usar métricas personalizadas, assegure-se de que as métricas sejam um indicador confiável da carga de trabalho e que o serviço de métricas esteja corretamente configurado e acessível pelo HPA.

**Escalonamento com Base em Várias Métricas:**
- O HPA pode ser configurado para levar em conta várias métricas ao mesmo tempo, permitindo um controle mais refinado do escalonamento.
- Por exemplo, você pode configurar o HPA para escalar com base tanto na utilização de CPU quanto na memória, ou qualquer combinação de métricas padrão e personalizadas.


#### Integrando HPA com Prometheus para Métricas Customizadas

Para levar o autoscaling para o próximo nível, podemos integrar o HPA com o Prometheus. Com essa integração, podemos usar métricas do Prometheus para informar nossas decisões de autoscaling.

A integração geralmente envolve a configuração de um adaptador de métricas personalizadas, como o `k8s-prometheus-adapter`. Uma vez configurado, o HPA pode acessar métricas do Prometheus e usá-las para tomar decisões de autoscaling. A documentação completa sobre como integrar o HPA com o Prometheus pode ser encontrada [aqui](#adicionar-link).

### A sua lição de casa

Agora que você foi equipado com o conhecimento sobre o HPA, é hora de colocar esse conhecimento em prática. Configure um HPA em seu ambiente e experimente com diferentes métricas: CPU, memória e métricas personalizadas. Documente suas observações e compreenda como o HPA responde a diferentes cargas e situações.

### Final do Day-11

E assim, chegamos ao fim do Day-11, uma jornada repleta de aprendizado e exploração. Hoje, você descobriu o poder do Horizontal Pod Autoscaler e como ele pode ajudar a manter seu aplicativo performando de maneira eficiente, mesmo sob diferentes condições de carga. Você não apenas aprendeu como ele funciona, mas também colocou a mão na massa com exemplos práticos. Continue praticando e explorando, e nos vemos no próximo dia da nossa aventura pelo Kubernetes! #VAIIII