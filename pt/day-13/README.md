# Descomplicando o Kubernetes
## DAY-13: Descomplicando Kyverno e as Policies no Kubernetes

## Conteúdo do Day-13

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-13: Descomplicando Kyverno e as Policies no Kubernetes](#day-13-descomplicando-kyverno-e-as-policies-no-kubernetes)
  - [Conteúdo do Day-13](#conteúdo-do-day-13)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
  - [Inicio do Day-13](#inicio-do-day-13)
    - [Introdução ao Kyverno](#introdução-ao-kyverno)
    - [Instalando o Kyverno](#instalando-o-kyverno)
      - [Utilizando Helm](#utilizando-helm)
    - [Verificando a Instalação](#verificando-a-instalação)
    - [Criando a nossa primeira Policy](#criando-a-nossa-primeira-policy)
    - [Mais exemplos de Policies](#mais-exemplos-de-policies)
      - [Exemplo de Política: Adicionar Label ao Namespace](#exemplo-de-política-adicionar-label-ao-namespace)
        - [Detalhes da Política](#detalhes-da-política)
        - [Arquivo de Política: `add-label-namespace.yaml`](#arquivo-de-política-add-label-namespaceyaml)
        - [Utilização da Política](#utilização-da-política)
      - [Exemplo de Política: Proibir Usuário Root](#exemplo-de-política-proibir-usuário-root)
        - [Detalhes da Política](#detalhes-da-política-1)
        - [Arquivo de Política: `disallow-root-user.yaml`](#arquivo-de-política-disallow-root-useryaml)
        - [Implementação e Efeito](#implementação-e-efeito)
      - [Exemplo de Política: Gerar ConfigMap para Namespace](#exemplo-de-política-gerar-configmap-para-namespace)
        - [Detalhes da Política](#detalhes-da-política-2)
        - [Arquivo de Política: `generate-configmap-for-namespace.yaml`](#arquivo-de-política-generate-configmap-for-namespaceyaml)
        - [Implementação e Utilidade](#implementação-e-utilidade)
      - [Exemplo de Política: Permitir Apenas Repositórios Confiáveis](#exemplo-de-política-permitir-apenas-repositórios-confiáveis)
        - [Detalhes da Política](#detalhes-da-política-3)
        - [Arquivo de Política: `registry-allowed.yaml`](#arquivo-de-política-registry-allowedyaml)
        - [Implementação e Impacto](#implementação-e-impacto)
        - [Exemplo de Política: Require Probes](#exemplo-de-política-require-probes)
        - [Detalhes da Política](#detalhes-da-política-4)
        - [Arquivo de Política: `require-probes.yaml`](#arquivo-de-política-require-probesyaml)
        - [Implementação e Impacto](#implementação-e-impacto-1)
      - [Exemplo de Política: Usando o Exclude](#exemplo-de-política-usando-o-exclude)
        - [Detalhes da Política](#detalhes-da-política-5)
        - [Arquivo de Política](#arquivo-de-política)
        - [Implementação e Efeitos](#implementação-e-efeitos)
    - [Conclusão](#conclusão)
      - [Pontos-Chave Aprendidos](#pontos-chave-aprendidos)

## O que iremos ver hoje?

Hoje, exploraremos as funcionalidades e aplicações do Kyverno, uma ferramenta de gerenciamento de políticas essencial para a segurança e eficiência de clusters Kubernetes. Com uma abordagem detalhada e prática, você aprenderá a usar o Kyverno para automatizar tarefas cruciais, garantir a conformidade com normas e regras estabelecidas e melhorar a administração geral de seus ambientes Kubernetes.

**Principais Tópicos Abordados:**

1. **Introdução ao Kyverno:** Uma visão geral do Kyverno, destacando sua importância e as principais funções de validação, mutação e geração de recursos.

2. **Instalação e Configuração:** Passo a passo para a instalação do Kyverno, incluindo métodos usando o Helm e arquivos YAML, e como verificar se a instalação foi bem-sucedida.

3. **Desenvolvendo Políticas Eficientes:** Aprenda a criar políticas para diferentes cenários, desde garantir limites de CPU e memória em Pods até aplicar automaticamente labels a namespaces e restringir a execução de containers como root.

4. **Exemplos Práticos:** Vários exemplos de políticas, ilustrando como o Kyverno pode ser aplicado para resolver problemas reais e melhorar a segurança e conformidade dos clusters Kubernetes.

5. **Dicas de Uso e Melhores Práticas:** Orientações sobre como aproveitar ao máximo o Kyverno, incluindo dicas de segurança, eficiência e automatização de processos.

Ao final deste e-book, você terá uma compreensão abrangente do Kyverno e estará equipado com o conhecimento e as habilidades para implementá-lo efetivamente em seus próprios clusters Kubernetes. Este e-book é projetado tanto para iniciantes quanto para profissionais experientes, proporcionando informações valiosas e práticas para todos os níveis de expertise.


## Inicio do Day-13

### Introdução ao Kyverno

Kyverno é uma ferramenta de gerenciamento de políticas para Kubernetes, focada na automação de várias tarefas relacionadas à segurança e configuração dos clusters de Kubernetes. Ele permite que você defina, gerencie e aplique políticas de forma declarativa para garantir que os clusters e suas cargas de trabalho estejam em conformidade com as regras e normas definidas.

**Principais Funções do Kyverno:**

1. **Validação de Recursos:** Verifica se os recursos do Kubernetes estão em conformidade com as políticas definidas. Por exemplo, pode garantir que todos os Pods tenham limites de CPU e memória definidos.

2. **Mutação de Recursos:** Modifica automaticamente os recursos do Kubernetes para atender às políticas definidas. Por exemplo, pode adicionar automaticamente labels específicos a todos os novos Pods.

3. **Geração de Recursos:** Cria recursos adicionais do Kubernetes com base nas políticas definidas. Por exemplo, pode gerar NetworkPolicies para cada novo Namespace criado.


### Instalando o Kyverno
  
A instalação do Kyverno em um cluster Kubernetes pode ser feita de várias maneiras, incluindo a utilização de um gerenciador de pacotes como o Helm, ou diretamente através de arquivos YAML. Aqui estão os passos básicos para instalar o Kyverno:

#### Utilizando Helm

O Helm é um gerenciador de pacotes para Kubernetes, que facilita a instalação e gerenciamento de aplicações. Para instalar o Kyverno com Helm, siga estes passos:

1. **Adicione o Repositório do Kyverno:**
   
   ```shell
   helm repo add kyverno https://kyverno.github.io/kyverno/
   helm repo update
   ```

2. **Instale o Kyverno:**
   
   Você pode instalar o Kyverno no namespace `kyverno` usando o seguinte comando:

   ```shell
   helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
   ```

### Verificando a Instalação

Após a instalação, é importante verificar se o Kyverno foi instalado corretamente e está funcionando como esperado.

- **Verifique os Pods:**

  ```shell
  kubectl get pods -n kyverno
  ```

  Este comando deve mostrar os pods do Kyverno em execução no namespace especificado.

- **Verifique os CRDs:**

  ```shell
  kubectl get crd | grep kyverno
  ```

  Este comando deve listar os CRDs relacionados ao Kyverno, indicando que foram criados corretamente.

Lembrando que é sempre importante consultar a documentação oficial para obter as instruções mais atualizadas e detalhadas, especialmente se estiver trabalhando com uma configuração específica ou uma versão mais recente do Kyverno ou do Kubernetes.


### Criando a nossa primeira Policy

Kyverno permite que você defina, gerencie e aplique políticas de forma declarativa para garantir que os clusters e suas cargas de trabalho estejam em conformidade com as regras e normas definidas.

As políticas, ou as policies em inglês, do Kyverno podem ser aplicadas de duas maneiras principais: a nível de cluster (`ClusterPolicy`) ou a nível de namespace específico (`Policy`).

1. **ClusterPolicy**: Quando você define uma política como `ClusterPolicy`, ela é aplicada a todos os namespaces no cluster. Ou seja, as regras definidas em uma `ClusterPolicy` são automaticamente aplicadas a todos os recursos correspondentes em todos os namespaces, a menos que especificamente excluídos.

2. **Policy**: Se você deseja aplicar políticas a um namespace específico, você usaria o tipo `Policy`. As políticas definidas como `Policy` são aplicadas apenas dentro do namespace onde são criadas.

Se você não especificar nenhum namespace na política ou usar `ClusterPolicy`, o Kyverno assumirá que a política deve ser aplicada globalmente, ou seja, em todos os namespaces.


**Exemplo de Políticas do Kyverno:**

1. **Política de Limites de Recursos:** Garantir que todos os containers em um Pod tenham limites de CPU e memória definidos. Isso pode ser importante para evitar o uso excessivo de recursos em um cluster compartilhado.

**Arquivo `require-resources-limits.yaml`:**
   ```yaml
   apiVersion: kyverno.io/v1
   kind: ClusterPolicy
   metadata:
     name: require-cpu-memory-limits
   spec:
     validationFailureAction: enforce
     rules:
     - name: validate-limits
       match:
         resources:
           kinds:
           - Pod
       validate:
         message: "CPU and memory limits are required"
         pattern:
           spec:
             containers:
             - name: "*"
               resources:
                 limits:
                   memory: "?*"
                   cpu: "?*"
   ```


Depois do arquivo criado, agora bastar realizar o deploy em nosso cluster Kubernetes.

```bash
kubectl apply -f require-resources-limits.yaml
```

Agora, tenta realizar o deploy de um simples Nginx sem definir o limite para os recursos.

**Arquivo `pod.yaml`:**
```bash
apiVersion: v1
kind: Pod
metadata:
  name: exemplo-pod
spec:
  containers:
  - name: exemplo-container
    image: nginx
```

```bash
kubectl apply -f pod.yaml
```

### Mais exemplos de Policies
Continuando com a explicação e exemplos de políticas do Kyverno para gerenciamento de clusters Kubernetes:

Entendi, vou formatar o texto para que esteja pronto para ser copiado para o Google Docs:


#### Exemplo de Política: Adicionar Label ao Namespace

A política `add-label-namespace` é projetada para automatizar a adição de um label específico a todos os Namespaces em um cluster Kubernetes. Esta abordagem é essencial para a organização, monitoramento e controle de acesso em ambientes complexos.

##### Detalhes da Política

O label adicionado por esta política é `Jeferson: "Lindo_Demais"`. A aplicação deste label a todos os Namespaces facilita a identificação e a categorização dos mesmos, permitindo uma gestão mais eficiente e uma padronização no uso de labels.

##### Arquivo de Política: `add-label-namespace.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-label-namespace
spec:
  rules:
  - name: add-label-ns
    match:
      resources:
        kinds:
        - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            Jeferson: "Lindo_Demais"
```

##### Utilização da Política

Esta política garante que cada Namespace no cluster seja automaticamente etiquetado com `Jeferson: "Lindo_Demais"`. Isso é particularmente útil para garantir a conformidade e a uniformidade na atribuição de labels, facilitando operações como filtragem e busca de Namespaces com base em critérios específicos.


#### Exemplo de Política: Proibir Usuário Root

A política `disallow-root-user` é uma regra de segurança crítica no gerenciamento de clusters Kubernetes. Ela proíbe a execução de containers como usuário root dentro de Pods. Este controle ajuda a prevenir possíveis vulnerabilidades de segurança e a reforçar as melhores práticas no ambiente de contêineres.

##### Detalhes da Política

O principal objetivo desta política é garantir que nenhum Pod no cluster execute containers como o usuário root. A execução de containers como root pode expor o sistema a riscos de segurança, incluindo acessos não autorizados e potenciais danos ao sistema host.

##### Arquivo de Política: `disallow-root-user.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-root-user
spec:
  validationFailureAction: Enforce
  rules:
  - name: check-runAsNonRoot
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Running as root is not allowed. Set runAsNonRoot to true."
      pattern:
        spec:
          containers:
          - securityContext:
              runAsNonRoot: true
```

##### Implementação e Efeito

Ao aplicar esta política, todos os Pods que tentarem executar containers como usuário root serão impedidos, com a exibição de uma mensagem de erro indicando que a execução como root não é permitida. Isso assegura uma camada adicional de segurança no ambiente Kubernetes, evitando práticas que possam comprometer a integridade e a segurança do cluster.


#### Exemplo de Política: Gerar ConfigMap para Namespace

A política `generate-configmap-for-namespace` é uma estratégia prática no gerenciamento de Kubernetes para automatizar a criação de ConfigMaps em Namespaces. Esta política simplifica a configuração e a gestão de múltiplos ambientes dentro de um cluster.

##### Detalhes da Política

Esta política é projetada para criar automaticamente um ConfigMap em cada Namespace recém-criado. O ConfigMap gerado, denominado `default-configmap`, inclui um conjunto padrão de chaves e valores, facilitando a configuração inicial e a padronização dos Namespaces.

##### Arquivo de Política: `generate-configmap-for-namespace.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-configmap-for-namespace
spec:
  rules:
    - name: generate-namespace-configmap
      match:
        resources:
          kinds:
            - Namespace
      generate:
        kind: ConfigMap
        name: default-configmap
        namespace: "{{request.object.metadata.name}}"
        data:
          data:
            key1: "value1"
            key2: "value2"
```

##### Implementação e Utilidade

A aplicação desta política resulta na criação automática de um ConfigMap padrão em cada Namespace novo, proporcionando uma forma rápida e eficiente de distribuir configurações comuns e informações essenciais. Isso é particularmente útil em cenários onde a consistência e a automatização de configurações são cruciais.


#### Exemplo de Política: Permitir Apenas Repositórios Confiáveis

A política `ensure-images-from-trusted-repo` é essencial para a segurança dos clusters Kubernetes, garantindo que todos os Pods utilizem imagens provenientes apenas de repositórios confiáveis. Esta política ajuda a prevenir a execução de imagens não verificadas ou potencialmente mal-intencionadas.

##### Detalhes da Política

Esta política impõe que todas as imagens de containers usadas nos Pods devem ser originárias de repositórios especificados e confiáveis. A estratégia é crucial para manter a integridade e a segurança do ambiente de containers, evitando riscos associados a imagens desconhecidas ou não autorizadas.

##### Arquivo de Política: `registry-allowed.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: ensure-images-from-trusted-repo
spec:
  validationFailureAction: enforce
  rules:
  - name: trusted-repo-check
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Only images from trusted repositories are allowed"
      pattern:
        spec:
          containers:
          - name: "*"
            image: "trustedrepo.com/*"
```

##### Implementação e Impacto

Com a implementação desta política, qualquer tentativa de implantar um Pod com uma imagem de um repositório não confiável será bloqueada. A política assegura que apenas imagens de fontes aprovadas sejam usadas, fortalecendo a segurança do cluster contra vulnerabilidades e ataques externos.


##### Exemplo de Política: Require Probes

A política `require-readinessprobe` desempenha um papel crucial no gerenciamento de tráfego e na garantia da disponibilidade de serviços em um cluster Kubernetes. Ela exige que todos os Pods tenham uma sonda de prontidão (readiness probe) configurada, assegurando que o tráfego seja direcionado para os Pods apenas quando estiverem prontos para processar solicitações.

##### Detalhes da Política

Esta política visa melhorar a confiabilidade e eficiência dos serviços executados no cluster, garantindo que os Pods estejam prontos para receber tráfego antes de serem expostos a solicitações externas. A sonda de prontidão verifica se o Pod está pronto para atender às solicitações, ajudando a evitar interrupções e problemas de desempenho.

##### Arquivo de Política: `require-probes.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-readinessprobe
spec:
  validationFailureAction: Enforce
  rules:
    - name: require-readinessProbe
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Readiness probe is required."
        pattern:
          spec:
            containers:
              - readinessProbe:
                  httpGet:
                    path: "/"
                    port: 8080
```

##### Implementação e Impacto

Com a aplicação desta política, todos os novos Pods ou Pods atualizados devem incluir uma configuração de sonda de prontidão, que normalmente envolve a especificação de um caminho e porta para checagem HTTP. Isso assegura que o serviço só receba tráfego quando estiver totalmente operacional, melhorando a confiabilidade e a experiência do usuário.


#### Exemplo de Política: Usando o Exclude

A política `require-resources-limits` é uma abordagem proativa para gerenciar a utilização de recursos em um cluster Kubernetes. Ela garante que todos os Pods tenham limites de recursos definidos, como CPU e memória, mas com uma exceção específica para um namespace.

##### Detalhes da Política

Essa política impõe que cada Pod no cluster tenha limites explícitos de CPU e memória configurados. Isso é crucial para evitar o consumo excessivo de recursos, que pode afetar outros Pods e a estabilidade geral do cluster. No entanto, esta política exclui especificamente o namespace `giropops` desta regra.

##### Arquivo de Política

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resources-limits
spec:
  validationFailureAction: Enforce
  rules:
  - name: validate-limits
    match:
      resources:
        kinds:
        - Pod
    exclude:
      resources:
        namespaces:
        - giropops
    validate:
      message: "Precisa definir o limites de recursos"
      pattern:
        spec:
          containers:
          - name: "*"
            resources:
              limits:
                cpu: "?*"
                memory: "?*"
```

##### Implementação e Efeitos

Ao aplicar esta política, todos os Pods novos ou atualizados precisam ter limites de recursos claramente definidos, exceto aqueles no namespace `giropops`. Isso assegura uma melhor gestão de recursos e evita situações onde alguns Pods possam monopolizar recursos em detrimento de outros.


### Conclusão

Ao longo deste artigo, exploramos as capacidades e funcionalidades do Kyverno, uma ferramenta inovadora e essencial para o gerenciamento de políticas em clusters Kubernetes. Compreendemos como o Kyverno simplifica e automatiza tarefas críticas relacionadas à segurança, conformidade e configuração, tornando-se um componente indispensável na administração de ambientes Kubernetes.

#### Pontos-Chave Aprendidos

1. **Automação e Conformidade:** Vimos como o Kyverno permite definir, gerenciar e aplicar políticas de forma declarativa, garantindo que os recursos do Kubernetes estejam sempre em conformidade com as regras e normas estabelecidas. Esta abordagem reduz significativamente o esforço manual, minimiza erros e assegura uma maior consistência em todo o ambiente.

2. **Validação, Mutação e Geração de Recursos:** Aprendemos sobre as três funções principais do Kyverno – validação, mutação e geração de recursos – e como cada uma delas desempenha um papel vital na gestão eficaz do cluster. Estas funções proporcionam um controle granular sobre os recursos, desde a garantia de limites de CPU e memória até a aplicação automática de labels e a criação dinâmica de ConfigMaps.

3. **Flexibilidade de Políticas:** Discutimos a diferença entre `ClusterPolicy` e `Policy`, destacando como o Kyverno oferece flexibilidade para aplicar políticas em todo o cluster ou em namespaces específicos. Isso permite uma gestão personalizada e adaptada às necessidades de diferentes partes do cluster.

4. **Instalação e Verificação:** Abordamos as várias maneiras de instalar o Kyverno, com foco especial no uso do Helm, um gerenciador de pacotes popular para Kubernetes. Também exploramos como verificar a instalação correta do Kyverno, assegurando que tudo esteja funcionando conforme esperado.

5. **Práticas de Segurança:** O artigo enfatizou a importância da segurança em Kubernetes, demonstrada por políticas como a proibição de execução de containers como usuário root e a exigência de imagens provenientes de repositórios confiáveis. Essas políticas ajudam a prevenir vulnerabilidades e garantir a integridade do cluster.

6. **Automatização e Eficiência:** Por fim, aprendemos como o Kyverno facilita a automatização e a eficiência operacional. As políticas do Kyverno reduzem a necessidade de intervenção manual, aumentam a segurança e ajudam na conformidade regulatória, tornando a administração do Kubernetes mais simples e confiável.

Em resumo, o Kyverno é uma ferramenta poderosa que transforma a maneira como as políticas são gerenciadas em Kubernetes. Seu enfoque na automação, flexibilidade e segurança o torna um componente essencial para qualquer administrador de Kubernetes que deseja otimizar a gestão de clusters, assegurar a conformidade e reforçar a segurança. Com o Kyverno, podemos atingir um nível mais alto de eficiência e confiança nos nossos ambientes Kubernetes, preparando-nos para enfrentar os desafios de um ecossistema em constante evolução.

---