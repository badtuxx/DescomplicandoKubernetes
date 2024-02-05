# Descomplicando o Kubernetes
## DAY-15: Descomplicando RBAC e controle de acesso no Kubernetes

## Conteúdo do Day-15

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
  - [DAY-15: Descomplicando RBAC e controle de acesso no Kubernetes](#day-15-descomplicando-rbac-e-controle-de-acesso-no-kubernetes)
  - [Conteúdo do Day-15](#conteúdo-do-day-15)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
  - [RBAC](#rbac)
    - [O que é RBAC?](#o-que-é-rbac)
    - [Primeiro exemplo de RBAC](#primeiro-exemplo-de-rbac)
      - [Criando um Usuário para acesso ao cluster](#criando-um-usuário-para-acesso-ao-cluster)
      - [Criando um Role para o nosso usuário](#criando-um-role-para-o-nosso-usuário)
      - [apiGroups](#apigroups)
      - [Recursos](#recursos)
      - [Verbos](#verbos)
      - [Criando a Role](#criando-a-role)
      - [Criando um RoleBinding para o nosso usuário](#criando-um-rolebinding-para-o-nosso-usuário)
      - [Adicionando o certificado do usuário no kubeconfig](#adicionando-o-certificado-do-usuário-no-kubeconfig)
      - [Acessando o cluster com o novo usuário](#acessando-o-cluster-com-o-novo-usuário)
      - [ClusterRole e ClusterRoleBinding](#clusterrole-e-clusterrolebinding)
      - [ClusterRole e ClusterRoleBinding para o usuário admin](#clusterrole-e-clusterrolebinding-para-o-usuário-admin)
      - [Removendo o usuário](#removendo-o-usuário)
    - [Utilizando Tokens para Service Accounts](#utilizando-tokens-para-service-accounts)
      - [Criando um Service Account](#criando-um-service-account)
      - [Criando um Secret para o Service Account](#criando-um-secret-para-o-service-account)
      - [Utilizando o Token do Service Account](#utilizando-o-token-do-service-account)
      - [Removendo o Service Account](#removendo-o-service-account)
  - [Final do Day-15](#final-do-day-15)
 

 ## O que iremos ver hoje?

Hoje, conheceremos profundamente o mundo do RBAC (Role-Based Access Control) no Kubernetes. O RBAC é um mecanismo essencial que permite a administradores de sistemas definirem regras de acesso específicas para usuários e serviços dentro de um cluster Kubernetes. Você aprenderá sobre a importância do RBAC para a segurança e a gestão eficaz dos recursos de um cluster, incluindo como criar e gerenciar usuários, atribuir papéis e permissões específicas, e configurar acessos baseados em funções para diferentes tipos de usuários e serviços. Vamos explorar exemplos práticos de como aplicar o RBAC para controlar o acesso a recursos do cluster, como pods, deployments e serviços, garantindo que apenas usuários autorizados possam executar operações específicas. Ao final deste guia, você terá um entendimento sólido sobre como implementar e gerenciar o controle de acesso baseado em funções no Kubernetes, proporcionando um ambiente de cluster mais seguro e eficiente.


## RBAC

### O que é RBAC?

RBAC é um acrônimo para Role-Based Access Control, ou Controle de Acesso Baseado em Funções. É um método de controle de acesso que permite que um administrador defina permissões específicas para usuários e grupos de usuários. Isso significa que os administradores podem controlar quem tem acesso a quais recursos e o que eles podem fazer com esses recursos.

No Kubernetes é super importante você entender como funciona o RBAC, pois é através dele que você vai definir as permissões de acesso aos recursos do cluster, como por exemplo, quem pode criar um Pod, um Deployment, um Service, etc.

### Primeiro exemplo de RBAC

Vamos imaginar que precisamos dar acesso ao cluster a uma pessoa desenvolvedora da nossa empresa, mas não queremos que ela tenha acesso a todos os recursos do cluster, apenas aos recursos que ela precisa para desenvolver a sua aplicação.

Para isso, vamos criar um usuário chamado `developer` e vamos dar acesso a ele para criar e administrar os Pods no namespace `dev`.

Temos duas formas de fazer isso, a primeira e mais antiga é através da criação de um Token de acesso, e a que iremos abordar na sequência é através da criação de um certificado. O Token é mais utilizado para dar acesso a um ServiceAccount, que é um usuário que não é humano. Por exemplo, podemos ter um ServiceAccount para o Prometheus poder coletar métricas do cluster, ou um ServiceAccount para o Fluentd poder coletar os logs do cluster. E podemos ter um User para um usuário humano, como por exemplo, o usuário `developer` que iremos criar.

#### Criando um Usuário para acesso ao cluster

Bem, agora que já sabemos quais serão as permissões do nosso novo usuário, já podemos iniciar a sua criação.

Primeira coisa que precisamos é criar uma chave privada para o nosso usuário. Para isso, vamos utilizar o comando `openssl`:

```bash
openssl genrsa -out developer.key 2048
```

Com o comando acima estamos criando uma chave privadas de 2048 bits e salvando ela no arquivo `developer.key`. O parametro `genrsa` indica que queremos gerar uma chave privada, e o parametro `-out` indica o nome do arquivo que queremos salvar a chave.


Com a chave criada, precisa agora criar a um CSR, ou Certificate Signing Request, que é um arquivo que contém o certificado que criamos, e que será enviado para o Kubernetes assinar e gerar o certificado final.

```bash
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"
```

No comando acima estamos criando um certificado para o nosso usuário, utilizando a chave privada que criamos anteriormente. O parametro `req` indica que queremos criar um certificado, o parametro `-key` indica o nome do arquivo da chave privada que queremos utilizar, o parametro `-out` indica o nome do arquivo que queremos salvar o certificado, e o parametro `-subj` indica o nome do usuário que queremos criar.

Pronto, agora com os dois arquivos em mãos, já podemos iniciar a criação do nosso usuário no cluster, mas antes, precisamos criar um CSR, ou Certificate Signing Request, que é um arquivo que contém o certificado que criamos, e que será enviado para o Kubernetes assinar e gerar o certificado final.

Mas para que possamos criar o arquivo, precisamos antes ter o conteúdo do certificado em base64, para isso, vamos utilizar o comando `base64`:

```bash
cat developer.csr | base64 | tr -d '\n'
```

Com o comando acima estamos lendo o conteúdo do arquivo `developer.csr`, convertendo ele para base64, e removendo a quebra de linha.

O conteúdo do certificado em base64 será algo parecido com isso:

```bash
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dUQ0NBVUVDQVFBd0ZERVNNQkFHQTFVRUF3d0paR1YyWld4dmNHVnlNSUlCSWpBTkJna3Foa2lHOXcwQgpBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF5OFN1Y25JWjJjL0k3dXQvS0EwSXhvN0RZa0hkSUxrbmxZOWNwMkVlClJJSzRzU1NzZnA2SzBhbWZlYWtRaEdXT2NWMmFaeEtTM0xrNERNNlVmb3ZucEQvOXpidDl0em44UUpMTDZxREEKeHFxbzVSbEt4QnpEV3lQT2JkUStMWnI2VjFQZ2wxYms2c3o0d2lWek52a2NhT0doSDdlSU90QVI0U096MjNJdAowZ0xiZHBDalFITFIvNlFuSXBjY3h3bDBGa1FtL3RVeHdRa0x1NXNpSTNKOGRiUkQwcnlFdGxReWQ5elhLM29rCjBRbVpLZDVpV1p2aDU3R1lrV1kweGMzV0J5aXY5OURQYVE3WTB4MFNaWGlPL2w0bTRzazJ3RjYwa2dUa1NJZmQKdEMxN2Y1ZzVWVzhOTW02amNpMFRXeDk5Z0REcmpHanJpaExHeTBLUWdRa2p3d0lEQVFBQm9BQXdEUVlKS29aSQpodmNOQVFFTEJRQURnZ0VCQUllZVdLbjAwZkk5ekw3MUVQNFNpOUVxVUFNUnBYT0dkT1Aybm8rMTV2VzJ5WmpwCmhsTWpVTjMraVZubkh2QVBvWFVLKzBYdXdmaklHMjBQTjA5UEd1alU4aUFIeVZRbFZRS0VaOWpRcENXYnQybngKVlZhYUw0N0tWMUpXMnF3M1YybmNVNkhlNHdtQzVqUE9vU29vVGtrVlF5Uml4bkcyVVQrejI3M2xpaTY3RkFXegpBZ1QvczlVa3gvS1dxRjIzczVuUk9TTlZUS2xCSG5LMU40YkN6RHBqZnN5V01GUXdnazhxRCtlOXp0cTh2c1VhCi9Say9jUWNyS2wxVDMyM0xDcG1TekhnM3hDdjFqdzJUVFFINm1yWlBBa2doa2R2YlNnalp6Y1JRZWNqSEpNeTMKTzFJQXJ6V3pWbU1hRTJqeGhUV1JwbkJkcVZjZERTUERiNkNXaktVPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K%
```

Lembre-se de remover a quebra de linha do final do arquivo, representada pelo `%`.

Agora que já temos o conteúdo do certificado em base64, copie ele e cole no arquivo `developer.yaml` que vamos criar agora:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
 name: developer
spec:
 request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dUQ0NBVUVDQVFBd0ZERVNNQkFHQTFVRUF3d0paR1YyWld4dmNHVnlNSUlCSWpBTkJna3Foa2lHOXcwQgpBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF5OFN1Y25JWjJjL0k3dXQvS0EwSXhvN0RZa0hkSUxrbmxZOWNwMkVlClJJSzRzU1NzZnA2SzBhbWZlYWtRaEdXT2NWMmFaeEtTM0xrNERNNlVmb3ZucEQvOXpidDl0em44UUpMTDZxREEKeHFxbzVSbEt4QnpEV3lQT2JkUStMWnI2VjFQZ2wxYms2c3o0d2lWek52a2NhT0doSDdlSU90QVI0U096MjNJdAowZ0xiZHBDalFITFIvNlFuSXBjY3h3bDBGa1FtL3RVeHdRa0x1NXNpSTNKOGRiUkQwcnlFdGxReWQ5elhLM29rCjBRbVpLZDVpV1p2aDU3R1lrV1kweGMzV0J5aXY5OURQYVE3WTB4MFNaWGlPL2w0bTRzazJ3RjYwa2dUa1NJZmQKdEMxN2Y1ZzVWVzhOTW02amNpMFRXeDk5Z0REcmpHanJpaExHeTBLUWdRa2p3d0lEQVFBQm9BQXdEUVlKS29aSQpodmNOQVFFTEJRQURnZ0VCQUllZVdLbjAwZkk5ekw3MUVQNFNpOUVxVUFNUnBYT0dkT1Aybm8rMTV2VzJ5WmpwCmhsTWpVTjMraVZubkh2QVBvWFVLKzBYdXdmaklHMjBQTjA5UEd1alU4aUFIeVZRbFZRS0VaOWpRcENXYnQybngKVlZhYUw0N0tWMUpXMnF3M1YybmNVNkhlNHdtQzVqUE9vU29vVGtrVlF5Uml4bkcyVVQrejI3M2xpaTY3RkFXegpBZ1QvczlVa3gvS1dxRjIzczVuUk9TTlZUS2xCSG5LMU40YkN6RHBqZnN5V01GUXdnazhxRCtlOXp0cTh2c1VhCi9Say9jUWNyS2wxVDMyM0xDcG1TekhnM3hDdjFqdzJUVFFINm1yWlBBa2doa2R2YlNnalp6Y1JRZWNqSEpNeTMKTzFJQXJ6V3pWbU1hRTJqeGhUV1JwbkJkcVZjZERTUERiNkNXaktVPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K 
 signerName: kubernetes.io/kube-apiserver-client
 expirationSeconds: 31536000 # 1 year
 usages:
 - client auth
```

No arquivo acima, estamos definindo as seguintes informações:

- `apiVersion`: Versão da API que estamos utilizando para criar o nosso usuário.
- `kind`: Tipo do recurso que estamos criando, no caso, um CSR.
- `metadata.name`: Nome do nosso usuário.
- `spec.request`: Conteúdo do certificado em base64.
- `spec.signerName`: Nome do assinador do certificado, que no caso é o kube-apiserver, que será o responsável por assinar o nosso certificado.
- `spec.expirationSeconds`: Tempo de expiração do certificado, que no caso é de 1 ano.
- `spec.usages`: Tipo de uso do certificado, que no caso é `client auth`.

Agora que já temos o nosso arquivo criado, vamos aplicar ele no cluster:

```bash
kubectl apply -f developer.yaml
```

Vamos listar os CSR's do cluster para ver o status do nosso usuário:

```bash
kubectl get csr
```

O resultado será algo parecido com isso:

```bash
NAME        AGE   SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
csr-4zd8k   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-68wsv   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-jkm8t   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-r2hcr   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-x52kj   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
developer   3s    kubernetes.io/kube-apiserver-client           kubernetes-admin          365d                Pending
```

Perceba que o nosso usuário está com o status `Pending`, isso porque o kube-apiserver ainda não assinou o nosso certificado. Você pode acompanhar o status do seu usuário através do comando:

```bash
kubectl describe csr developer
```

O resultado será algo parecido com isso:

```bash
Name:         developer
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"certificates.k8s.io/v1","kind":"CertificateSigningRequest","metadata":{"annotations":{},"name":"developer"},"spec":{"expirationSeconds":31536000,"request":"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dUQ0NBVUVDQVFBd0ZERVNNQkFHQTFVRUF3d0paR1YyWld4dmNHVnlNSUlCSWpBTkJna3Foa2lHOXcwQgpBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF5OFN1Y25JWjJjL0k3dXQvS0EwSXhvN0RZa0hkSUxrbmxZOWNwMkVlClJJSzRzU1NzZnA2SzBhbWZlYWtRaEdXT2NWMmFaeEtTM0xrNERNNlVmb3ZucEQvOXpidDl0em44UUpMTDZxREEKeHFxbzVSbEt4QnpEV3lQT2JkUStMWnI2VjFQZ2wxYms2c3o0d2lWek52a2NhT0doSDdlSU90QVI0U096MjNJdAowZ0xiZHBDalFITFIvNlFuSXBjY3h3bDBGa1FtL3RVeHdRa0x1NXNpSTNKOGRiUkQwcnlFdGxReWQ5elhLM29rCjBRbVpLZDVpV1p2aDU3R1lrV1kweGMzV0J5aXY5OURQYVE3WTB4MFNaWGlPL2w0bTRzazJ3RjYwa2dUa1NJZmQKdEMxN2Y1ZzVWVzhOTW02amNpMFRXeDk5Z0REcmpHanJpaExHeTBLUWdRa2p3d0lEQVFBQm9BQXdEUVlKS29aSQpodmNOQVFFTEJRQURnZ0VCQUllZVdLbjAwZkk5ekw3MUVQNFNpOUVxVUFNUnBYT0dkT1Aybm8rMTV2VzJ5WmpwCmhsTWpVTjMraVZubkh2QVBvWFVLKzBYdXdmaklHMjBQTjA5UEd1alU4aUFIeVZRbFZRS0VaOWpRcENXYnQybngKVlZhYUw0N0tWMUpXMnF3M1YybmNVNkhlNHdtQzVqUE9vU29vVGtrVlF5Uml4bkcyVVQrejI3M2xpaTY3RkFXegpBZ1QvczlVa3gvS1dxRjIzczVuUk9TTlZUS2xCSG5LMU40YkN6RHBqZnN5V01GUXdnazhxRCtlOXp0cTh2c1VhCi9Say9jUWNyS2wxVDMyM0xDcG1TekhnM3hDdjFqdzJUVFFINm1yWlBBa2doa2R2YlNnalp6Y1JRZWNqSEpNeTMKTzFJQXJ6V3pWbU1hRTJqeGhUV1JwbkJkcVZjZERTUERiNkNXaktVPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K","signerName":"kubernetes.io/kube-apiserver-client","usages":["client auth"]}}

CreationTimestamp:   Wed, 31 Jan 2024 11:52:24 +0100
Requesting User:     kubernetes-admin
Signer:              kubernetes.io/kube-apiserver-client
Requested Duration:  365d
Status:              Pending
Subject:
         Common Name:    developer
         Serial Number:  
Events:  <none>
```

Tudo certo até aqui, agora precisamos assinar o nosso certificado, para isso, vamos utilizar o comando `kubectl certificate approve`:

```bash
kubectl certificate approve developer
```

Agora vamos listar os CSR's do cluster novamente:

```bash
kubectl get csr
```

O resultado será algo parecido com isso:

```bash
NAME        AGE   SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
csr-4zd8k   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-68wsv   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-jkm8t   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-r2hcr   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-x52kj   16m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
developer   88s   kubernetes.io/kube-apiserver-client           kubernetes-admin          365d                Approved,Issued
```

Pronto, o nosso certificado foi assinado com sucesso, agora podemos pegar o certificado do nosso usuário e salvar em um arquivo, para isso, vamos utilizar o comando `kubectl get csr`:

```bash
kubectl get csr developer -o jsonpath='{.status.certificate}' | base64 --decode > developer.crt
```

No comando acima, estamos pegando o certificado do nosso usuário, convertendo ele para base64, e salvando ele no arquivo `developer.crt`.

Para pegar o certificado, estamos usando o parametro `-o jsonpath='{.status.certificate}'`, para que o comando retorne apenas o certificado do usuário, e não todas as informações do CSR.

Você pode conferir o conteúdo do certificado através do comando:

```bash
cat developer.crt
```

Pronto, agora temos o nosso certificado final criado, e podemos utilizá-lo para acessar o cluster, mas antes precisamos definir o que o nosso usuário pode fazer no cluster.

#### Criando um Role para o nosso usuário

Quando criamos um novo Usuário ou ServiceAccount no Kubernetes, ele não tem acesso a nada no cluster, para que ele possa acessar os recursos do cluster, precisamos criar um Role e associar ele ao usuário.

A definição da Role consiste em um arquivo onde definimos quais são as permissões que o usuário terá no cluster, e para quais recursos ele terá acesso. Dentro da Role é onde definimos:

- Qual é o namespace que o usuário terá acesso.
- Quais apiGroups o usuário terá acesso.
- Quais recursos o usuário terá acesso.
- Quais verbos o usuário terá acesso.


#### apiGroups

São os grupos de recursos do Kubernetes, que são divididos em `core` e `named`, você pode consultar todos os grupos de recursos do Kubernetes através do comando `kubectl api-resources`.

Vamos listar os grupos de recursos do Kubernetes:

```bash
kubectl api-resources
```

A lista é longa, mas o resultado será algo parecido com isso:

```bash
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
limitranges                       limits       v1                                     true         LimitRange
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1              false        APIService
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler
cronjobs                          cj           batch/v1                               true         CronJob
jobs                                           batch/v1                               true         Job
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
leases                                         coordination.k8s.io/v1                 true         Lease
endpointslices                                 discovery.k8s.io/v1                    true         EndpointSlice
events                            ev           events.k8s.io/v1                       true         Event
flowschemas                                    flowcontrol.apiserver.k8s.io/v1beta3   false        FlowSchema
prioritylevelconfigurations                    flowcontrol.apiserver.k8s.io/v1beta3   false        PriorityLevelConfiguration
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
ingresses                         ing          networking.k8s.io/v1                   true         Ingress
networkpolicies                   netpol       networking.k8s.io/v1                   true         NetworkPolicy
runtimeclasses                                 node.k8s.io/v1                         false        RuntimeClass
poddisruptionbudgets              pdb          policy/v1                              true         PodDisruptionBudget
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1           true         Role
priorityclasses                   pc           scheduling.k8s.io/v1                   false        PriorityClass
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver
csinodes                                       storage.k8s.io/v1                      false        CSINode
csistoragecapacities                           storage.k8s.io/v1                      true         CSIStorageCapacity
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
```

Onde a primeira coluna é o nome do recurso, a segunda coluna é o nome abreviado do recurso, a terceira coluna é a versão da API que o recurso está, a quarta coluna indica se o recurso é ou não Namespaced, e a quinta coluna é o tipo do recurso.

Vamos dar uma olhada em um recurso específico, por exemplo, o recurso `pods`:

```bash
kubectl api-resources | grep pods
```

O resultado será algo parecido com isso:

```bash
NAME       SHORTNAMES   APIVERSION     NAMESPACED   KIND
pods       po           v1             true         Pod
```

Onde:

- `NAME`: Nome do recurso.
- `SHORTNAMES`: Nome abreviado do recurso.
- `APIVERSION`: Versão da API que o recurso está.
- `NAMESPACED`: Indica se o recurso é ou não Namespaced.
- `KIND`: Tipo do recurso.

Mas o que é um recurso Namespaced? Um recurso Namespaced é um recurso que pode ser criado dentro de um namespace, por exemplo, um Pod, um Deployment, um Service, etc. Já um recurso que não é Namespaced, é um recurso que não pode ser criado dentro de um namespace, por exemplo, um Node, um PersistentVolume, um ClusterRole, etc. Fácil né?

Agora, como eu sei qual é o apiGroup de um recurso? Bem, o apiGroup de um recurso é o nome do grupo de recursos que ele pertence, por exemplo, o recurso `pods` pertence ao grupo de recursos `core`, e o recurso `deployments` pertence ao grupo de recursos `apps`. Quando o recurso é do tipo `core` ele não precisa ser especificado no apiGroup, pois o Kubernetes já entende que ele pertence ao grupo de recursos `core`, esse é o famoso `apiVersion: v1`.

Ja o `apiVersion: apps/v1` indica que o recurso pertence ao grupo de recursos `apps`, e a versão da API é a `v1`. No `apps` temos recursos importantes como o `deployments`, `replicasets`, `daemonsets`, `statefulsets`, etc.


#### Recursos

São os recursos do Kubernetes, que são divididos em `core` e `named`, você pode consultar todos os recursos do Kubernetes através do comando `kubectl api-resources`.

Os recursos chamados de `core` são os recursos que já vem instalados no Kubernetes, e os recursos chamados de `named` são os recursos que são instalados através de Custom Resource Definitions, ou CRD's, como por exemplo o `ServiceMonitor` do Prometheus.

Vamos listar os recursos do Kubernetes:

```bash
kubectl api-resources --namespaced=false
```

O resultado será algo parecido com isso:

```bash
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
componentstatuses                 cs           v1                                     false        ComponentStatus
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumes                 pv           v1                                     false        PersistentVolume
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1              false        APIService
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
flowschemas                                    flowcontrol.apiserver.k8s.io/v1beta3   false        FlowSchema
prioritylevelconfigurations                    flowcontrol.apiserver.k8s.io/v1beta3   false        PriorityLevelConfiguration
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
runtimeclasses                                 node.k8s.io/v1                         false        RuntimeClass
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
priorityclasses                   pc           scheduling.k8s.io/v1                   false        PriorityClass
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver
csinodes                                       storage.k8s.io/v1                      false        CSINode
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
```

Assim podemos saber quais são os recursos que são nativos do Kubernetes, e quais são os recursos que são instalados através de CRD's, que são os Custom Resources Definitions.

Então o nome do recurso é o nome que utilizamos para criar o recurso, por exemplo, `pods`, `deployments`, `services`, etc.

#### Verbos

Os verbos definem o que o usuário pode fazer com o recurso, por exemplo, o usuário pode criar, listar, atualizar, deletar, etc.

Para que você possa visualizar os verbos que podem ser utilizados, vamos utilizar o comando `kubectl api-resources` com o parametro `-o wide`:

```bash
kubectl api-resources -o wide
```

O resultado será algo parecido com isso:

```bash
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND                             VERBS                                                        CATEGORIES
bindings                                       v1                                     true         Binding                          create                                                       
componentstatuses                 cs           v1                                     false        ComponentStatus                  get,list                                                     
configmaps                        cm           v1                                     true         ConfigMap                        create,delete,deletecollection,get,list,patch,update,watch   
endpoints                         ep           v1                                     true         Endpoints                        create,delete,deletecollection,get,list,patch,update,watch   
events                            ev           v1                                     true         Event                            create,delete,deletecollection,get,list,patch,update,watch   
limitranges                       limits       v1                                     true         LimitRange                       create,delete,deletecollection,get,list,patch,update,watch   
namespaces                        ns           v1                                     false        Namespace                        create,delete,get,list,patch,update,watch                    
nodes                             no           v1                                     false        Node                             create,delete,deletecollection,get,list,patch,update,watch   
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim            create,delete,deletecollection,get,list,patch,update,watch   
persistentvolumes                 pv           v1                                     false        PersistentVolume                 create,delete,deletecollection,get,list,patch,update,watch   
pods                              po           v1                                     true         Pod                              create,delete,deletecollection,get,list,patch,update,watch   all
podtemplates                                   v1                                     true         PodTemplate                      create,delete,deletecollection,get,list,patch,update,watch   
replicationcontrollers            rc           v1                                     true         ReplicationController            create,delete,deletecollection,get,list,patch,update,watch   all
resourcequotas                    quota        v1                                     true         ResourceQuota                    create,delete,deletecollection,get,list,patch,update,watch   
secrets                                        v1                                     true         Secret                           create,delete,deletecollection,get,list,patch,update,watch   
serviceaccounts                   sa           v1                                     true         ServiceAccount                   create,delete,deletecollection,get,list,patch,update,watch   
services                          svc          v1                                     true         Service                          create,delete,deletecollection,get,list,patch,update,watch   all
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration     create,delete,deletecollection,get,list,patch,update,watch   api-extensions
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration   create,delete,deletecollection,get,list,patch,update,watch   api-extensions
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition         create,delete,deletecollection,get,list,patch,update,watch   api-extensions
apiservices                                    apiregistration.k8s.io/v1              false        APIService                       create,delete,deletecollection,get,list,patch,update,watch   api-extensions
controllerrevisions                            apps/v1                                true         ControllerRevision               create,delete,deletecollection,get,list,patch,update,watch   
daemonsets                        ds           apps/v1                                true         DaemonSet                        create,delete,deletecollection,get,list,patch,update,watch   all
deployments                       deploy       apps/v1                                true         Deployment                       create,delete,deletecollection,get,list,patch,update,watch   all
replicasets                       rs           apps/v1                                true         ReplicaSet                       create,delete,deletecollection,get,list,patch,update,watch   all
statefulsets                      sts          apps/v1                                true         StatefulSet                      create,delete,deletecollection,get,list,patch,update,watch   all
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview                      create                                                       
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview         create                                                       
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview          create                                                       
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview           create                                                       
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview              create                                                       
horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler          create,delete,deletecollection,get,list,patch,update,watch   all
cronjobs                          cj           batch/v1                               true         CronJob                          create,delete,deletecollection,get,list,patch,update,watch   all
jobs                                           batch/v1                               true         Job                              create,delete,deletecollection,get,list,patch,update,watch   all
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest        create,delete,deletecollection,get,list,patch,update,watch   
leases                                         coordination.k8s.io/v1                 true         Lease                            create,delete,deletecollection,get,list,patch,update,watch   
endpointslices                                 discovery.k8s.io/v1                    true         EndpointSlice                    create,delete,deletecollection,get,list,patch,update,watch   
events                            ev           events.k8s.io/v1                       true         Event                            create,delete,deletecollection,get,list,patch,update,watch   
flowschemas                                    flowcontrol.apiserver.k8s.io/v1beta3   false        FlowSchema                       create,delete,deletecollection,get,list,patch,update,watch   
prioritylevelconfigurations                    flowcontrol.apiserver.k8s.io/v1beta3   false        PriorityLevelConfiguration       create,delete,deletecollection,get,list,patch,update,watch   
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass                     create,delete,deletecollection,get,list,patch,update,watch   
ingresses                         ing          networking.k8s.io/v1                   true         Ingress                          create,delete,deletecollection,get,list,patch,update,watch   
networkpolicies                   netpol       networking.k8s.io/v1                   true         NetworkPolicy                    create,delete,deletecollection,get,list,patch,update,watch   
runtimeclasses                                 node.k8s.io/v1                         false        RuntimeClass                     create,delete,deletecollection,get,list,patch,update,watch   
poddisruptionbudgets              pdb          policy/v1                              true         PodDisruptionBudget              create,delete,deletecollection,get,list,patch,update,watch   
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding               create,delete,deletecollection,get,list,patch,update,watch   
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole                      create,delete,deletecollection,get,list,patch,update,watch   
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding                      create,delete,deletecollection,get,list,patch,update,watch   
roles                                          rbac.authorization.k8s.io/v1           true         Role                             create,delete,deletecollection,get,list,patch,update,watch   
priorityclasses                   pc           scheduling.k8s.io/v1                   false        PriorityClass                    create,delete,deletecollection,get,list,patch,update,watch   
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver                        create,delete,deletecollection,get,list,patch,update,watch   
csinodes                                       storage.k8s.io/v1                      false        CSINode                          create,delete,deletecollection,get,list,patch,update,watch   
csistoragecapacities                           storage.k8s.io/v1                      true         CSIStorageCapacity               create,delete,deletecollection,get,list,patch,update,watch   
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass                     create,delete,deletecollection,get,list,patch,update,watch   
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment                 create,delete,deletecollection,get,list,patch,update,watch  
```

Perceba que agora temos uma nova coluna, a coluna `VERBS`, onde temos todos os verbos que podem ser utilizados com o recurso, e a coluna `CATEGORIES`, onde temos a categoria do recurso. Mas o nosso foco aqui é nos verbos, então vamos dar uma olhada neles.

Os verbos são divididos em:

- `create`: Permite que o usuário crie um recurso.
- `delete`: Permite que o usuário delete um recurso.
- `deletecollection`: Permite que o usuário delete uma coleção de recursos.
- `get`: Permite que o usuário obtenha um recurso.
- `list`: Permite que o usuário liste os recursos.
- `patch`: Permite que o usuário atualize um recurso.
- `update`: Permite que o usuário atualize um recurso.
- `watch`: Permite que o usuário acompanhe as alterações de um recurso.

Com isso, vamos pegar exemplo da linha do recurso `pods`:

```bash
NAME   SHORTNAMES   APIVERSION     NAMESPACED   KIND     VERBS                     CATEGORIES
pods   po           v1             true         Pod      create,delete,deletecollection,get,list,patch,update,watch   all
```

Com isso sabemos que o usuário pode criar, deletar, deletar uma coleção, obter, listar, atualizar e acompanhar as alterações de um Pod. Simplão demais, hein!

#### Criando a Role

Agora que já sabemos muito sobre os `resources`, `apiGroups` e `verbs`, vamos criar a nossa Role para o nosso usuário.

Para isso, vamos criar um arquivo chamado `developer-role.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
 name: developer
 namespace: dev
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list", "update", "create", "delete"]
```

No arquivo acima, estamos definindo as seguintes informações:

- `apiVersion`: Versão da API que estamos utilizando para criar o nosso usuário.
- `kind`: Tipo do recurso que estamos criando, no caso, uma Role.
- `metadata.name`: Nome da nossa Role.
- `metadata.namespace`: Namespace que a nossa Role será criada.
- `rules`: Regras da nossa Role.
- `rules.apiGroups`: Grupos de recursos que a nossa Role terá acesso.
- `rules.resources`: Recursos que a nossa Role terá acesso.
- `rules.verbs`: Verbos que a nossa Role terá acesso.

Eu tenho certeza que está fácil para você fazer a leitura da Role, que é basicamente o que o nosso usuário pode fazer no cluster, mas em resumo o que estamos falando é que o usuário que estiver usando essa Role, poderá fazer tudo com o recurso `pods` no namespace `dev`. Simples como voar!

Lembre-se que essa Role pode ser reutilizada por outros usuários, e que você pode criar quantas Roles quiser, e que você pode criar Roles para outros perfis de usuários e para outros recursos, como por exemplo, `deployments`, `services`, `configmaps`, etc.

Ahhh, antes de mais nada, vamos criar o namespace `dev`:

```bash
kubectl create ns dev
```

Agora que já temos o nosso arquivo e a namespace criados, vamos aplicar ele no cluster:

```bash
kubectl apply -f developer-role.yaml
```

Para verificar se a nossa Role foi criada com sucesso, vamos listar as Roles do cluster:

```bash
kubectl get roles -n dev
```

A saída:
  
```bash
NAME        CREATED AT
developer   2024-01-31T11:32:08Z
```

Para ver os detalhes da Role, vamos utilizar o comando `kubectl describe`:

```bash
kubectl describe role developer -n dev
```

A saída será algo parecido com isso:

```bash
Name:         developer
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list update create delete]
```

Pronto, a nossa Role já está criada, porém ainda não associamos ela ao nosso usuário, para isso, vamos criar um RoleBinding.

#### Criando um RoleBinding para o nosso usuário

A RoleBinding é o recurso que associa um usuário a uma Role, ou seja, é através da RoleBinding que definimos qual usuário terá acesso a qual Role, é como se tivessemos um crachá de Developer, a Role seria o crachá, e a RoleBinding seria o crachá com o nome do usuário. Faz sentindo?

Para isso, vamos criar um arquivo chamado `developer-rolebinding.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: DeveloperRoleBinding
  namespace: dev
subjects:
- kind: User
  name: developer
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

No arquivo acima, estamos definindo as seguintes informações:

- `apiVersion`: Versão da API que estamos utilizando para criar o nosso usuário.
- `kind`: Tipo do recurso que estamos criando, no caso, um RoleBinding.
- `metadata.name`: Nome da nossa RoleBinding.
- `metadata.namespace`: Namespace que a nossa RoleBinding será criada.
- `subjects`: Usuários que terão acesso a Role.
- `subjects.kind`: Tipo do usuário, que no caso é `User`.
- `subjects.name`: Nome do usuário, que no caso é `developer`.
- `roleRef`: Referência da Role que o usuário terá acesso.
- `roleRef.kind`: Tipo da Role, que no caso é `Role`.
- `roleRef.name`: Nome da Role, que no caso é `developer`.
- `roleRef.apiGroup`: Grupo de recursos da Role, que no caso é `rbac.authorization.k8s.io`.

Nada de outro mundo, e mais uma vez está super claro o que iremos ter, que é o usuário `developer` com a Role `developer` no namespace `dev`.

Agora que já temos o nosso arquivo criado, bora aplica-lo:

```bash
kubectl apply -f developer-rolebinding.yaml
```

Para verificar se a nossa RoleBinding foi criada com sucesso, vamos listar as RoleBindings do cluster:

```bash
kubectl get rolebindings -n dev
```

A saída:

```bash
NAME                   ROLE             AGE
DeveloperRoleBinding   Role/developer   9s
```

Para ver detalhes da RoleBinding, vamos utilizar o comando `kubectl describe`:

```bash
kubectl describe rolebinding DeveloperRoleBinding -n dev
```

A saída será algo parecido com isso:

```bash
Name:         DeveloperRoleBinding
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  developer
Subjects:
  Kind  Name       Namespace
  ----  ----       ---------
  User  developer  
```

Pronto, RoleBinding criada com sucesso, agora vamos testar o nosso usuário.

#### Adicionando o certificado do usuário no kubeconfig

Agora que já temos o nosso usuário criado, precisamos adicionar o certificado do usuário no kubeconfig, para que possamos acessar o cluster com o nosso usuário.

Para isso, vamos utilizar o comando `kubectl config set-credentials`:

```bash
kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --embed-certs=true
```

O comando `kubectl config set-credentials` é utilizado para adicionar um novo usuário no kubeconfig, e ele recebe os seguintes parametros:

- `--client-certificate`: Caminho do certificado do usuário.
- `--client-key`: Caminho da chave do usuário.
- `--embed-certs`: Indica se o certificado deve ser embutido no kubeconfig.

No nosso caso, estamos passando o caminho do certificado e da chave do usuário, e estamos indicando que o certificado deve ser embutido no kubeconfig.

Agora precisamos criar um contexto para o nosso usuário, para isso, vamos utilizar o comando `kubectl config set-context`:

```bash
kubectl config set-context developer --cluster=NOME-DO-CLUSTER --namespace=dev --user=developer
```

Caso você não se lembre o que é um contexto no Kubernetes, eu vou te ajudar a relembrar. Um contexto é um conjunto de configurações que definem o acesso a um cluster, ou seja, um contexto é composto por um cluster, um usuário e um namespace. Quando você cria um novo usuário, você precisa criar um novo contexto para ele, para que ele possa acessar o cluster.

Para que você possa pegar os nomes do cluster, basta utilizar o comando `kubectl config get-clusters`, assim você poderá pegar o nome do cluster que você quer utilizar.

Com isso, o nosso novo usuário está pronto para ser utilizado, mas antes vamos verificar se ele está funcionando.

#### Acessando o cluster com o novo usuário

Uma vez que o nosso usuário está criado, e que o certificado do usuário está no kubeconfig e que já temos um contexto para o usuário, podemos testar o acesso ao cluster.

Antes de mais nada, vamos listar todos os contextos do kubeconfig:

```bash
kubectl config get-contexts
```

O nosso novo contexto deve aparecer na lista, e deve ser algo parecido com isso:

```bash
CURRENT   NAME                CLUSTER        AUTHINFO       NAMESPACE
*         developer           kind-strigus   developer      dev
          kind-strigus        kind-strigus   kind-strigus   
```

Então bora o utilizar o nosso novo contexto:

```bash
kubectl config use-context developer
```

Pronto, nesse momento estamos utilizando o nosso novo usuário através do nosso novo contexto, agora vamos testar o acesso ao cluster:

```bash
kubectl get pods
```

Tudo funcionando, certo?

Perceba que o Namespace que estamos utilizando é o `dev`, onde ele pode fazer tudo com o recurso `pods`, e que ele não pode fazer nada com os outros recursos, como por exemplo, `deployments`, `services`, `configmaps`, etc. Isso porque a nossa Role está limitada ao recurso `pods`, e ao namespace `dev`.

Vamos testar o acesso a um recurso que ele não tem permissão:

```bash
kubectl get deployments
```

O resultado será algo parecido com isso:

```bash
Error from server (Forbidden): deployments.apps is forbidden: User "developer" cannot list resource "deployments" in API group "apps" in the namespace "dev"
```

Tudo funcionando perfeitamente! Pra finalizar, vamos criar um Pod simples do Nginx, ele deve ser criado com sucesso, pois o nosso usuário tem permissão para criar Pods no namespace `dev`:

```bash
kubectl run nginx --image=nginx -n dev
```

Criado!

Vamos listar os Pods do namespace `dev`:

```bash
kubectl get pods
```

E veremos o nosso Pod do Nginx criado:

```bash
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          5s
```

Pronto! O nosso usuário está criado e funcionando perfeitamente!

#### ClusterRole e ClusterRoleBinding

Até agora nós criamos uma Role e uma RoleBinding, que são recursos Namespaced, ou seja, eles só podem ser criados dentro de um namespace, mas e se você quiser criar um usuário que tenha acesso a todos os namespaces do cluster? Para isso, você precisa criar um ClusterRole e um ClusterRoleBinding. 

Basicamente eles são iguais a Role e RoleBinding, porém com maior escopo, pois eles refletem em todo o cluster, e não apenas em um namespace específico.

Agora, precisamos criar um novo usuário, que será do time de Platform, e que terá acesso a todos os namespaces do cluster, pois ele precisa criar e gerenciar recursos em todos os namespaces.

Ele precisa ter acesso a Deployments, Services, ConfigMaps, Secrets, Ingress e Pods, por enquanto.

Então vamos começar criando a chave privada e o CSR do usuário:

```bash
openssl genrsa -out platform.key 2048
openssl req -new -key platform.key -out platform.csr -subj "/CN=platform/O=platform"
```

Pegue o conteúdo do arquivo `platform.csr`, use o base64 para codificar o conteúdo, e cole o resultado no campo `request` do arquivo `platform-csr.yaml`:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: platform
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2F6Q0NBVk1DQVFBd0pqRVJNQThHQTFVRUF3d0ljR3hoZEdadmNtMHhFVEFQQmdOVkJBb01DSEJzWVhSbQpiM0p0TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFyd3ZaT1NNeUlsTFlUYlR0CjEzYmNMOWtqK0hyOXl5ekpPQnU1Z1hLSUljM3NhdGg1Q1BMOHNvRFN4dzNrbkVOQklsQlE5YlYxNWRJNDQwSnoKdDRDT0ZpR1lTSGt2WGNuVFRGTlpHSlFxemwxZ2JvZ1VldlZxS0tYM0c2ZFhUZ3BrYjNaNTZQRHV2MlF3VlZ6cApYRWE1VlpLZFF6Nmd2LzdFNzV2YWdDOUhxdXVYWWtQYWN4ajRvTERZL2xxNzRpMlBlb1B2L0VNd2NsVEpSV01NCk5ESmNDZmIyLzl3bU1vVEg3N3BpYUNaRlBGWG1XOStHcmhrcGY5VDNua1dST2doL2s3b2RBcjc4ekNUVTZ3a0MKa0p3QWJNR1lkaEpaZHpJLzZWTVJPUHhxV01RckVzR005MzkzNUNPSmZVYlRzOEoreEZQb2l2eWJPbXdzQWFYMgpNM0U4clFJREFRQUJvQUF3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUdTUlRtVEU1bjBIK2VFZ2ZFdmdqWFRxCitucmdlSEJka3JvK3BlMTFOM1pONjVubVhaWEQ3cFJ0U3RZamtma2p1RG1OdDcrN0Q0NW1hOXEyeDZ1aGV2eFkKMWhCNEcxOWNCS0dTVWM1QzlBbnJNemtsY29Ic1JTYjhwZkhXcmNpak4rVEQ1MkNZWC9XMVEyY28xQ2pTMWI1bgpTWG8rRE1vdkZRVHhDbnFGdTVCMVlsVXdGWkhDVW5qOXp6SUJjQmRBekUzT3VZSVdyYWFFOXNNZUU5ZC9OVE11CkVvL3lSVVJ0THlaQUtWc3NTQ2k2NEk0dVlGV3Y3WXlKbG00RTVuUDQ1YUhJd1pzdVFlZ2RwOEZhOVVZVFBLaksKbmVjWEJGdVlhekRxYlRiWHhRN1QvUW44VWhZbGIybVZ3UUpsbUpoeTEweXYwZW1DeTVPVGFDZ2ZiUlh5bk9rPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K
 signerName: kubernetes.io/kube-apiserver-client
 expirationSeconds: 31536000 # 1 year
 usages:
 - client auth
```

Agora vamos aplicar:
  
```bash
kubectl apply -f platform-csr.yaml
```

Para verificar se o CSR foi criado com sucesso, vamos listar os CSR's do cluster:

```bash
kubectl get csr
```

A saída:

```bash
NAME        AGE   SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
csr-648l9   82m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-hn4d4   82m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-qd72l   82m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-r24pf   82m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-rswk4   82m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
developer   79m   kubernetes.io/kube-apiserver-client           kubernetes-admin          365d                Approved,Issued
platform    87s   kubernetes.io/kube-apiserver-client           kubernetes-admin          365d                Pending
```

Vamos aprovar o CSR:

```bash
kubectl certificate approve platform
```

Agora vamos pegar o certificado do usuário:

```bash
kubectl get csr platform -o jsonpath='{.status.certificate}' | base64 --decode > platform.crt
```

Eu não vou explicar novamente tudo o que estamos fazendo, pois boa parte é igual ao que já fizemos anteriormente, então se você não se lembra, volte e leia novamente. :D

Pronto, o que está faltando agora são os recursos ClusterRole e ClusterRoleBinding, então vamos criar o arquivo `platform-clusterrole.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: platform
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["deployments", "services", "configmaps", "secrets", "ingresses", "pods"]
  verbs: ["get", "watch", "list", "update", "create", "delete"]
```

Como pode ver, a configuração é muito parecida com a Role, porém agora estamos criando um ClusterRole. A diferença na definção da Role e do ClusterRole é que o ClusterRole o Kind é `ClusterRole`, e também não tem o campo `namespace`, pois o ClusterRole não é Namespaced.

Agora vamos criar o arquivo `platform-clusterrolebinding.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: PlatformClusterRoleBinding
subjects:
- kind: User
  name: platform
roleRef:
  kind: ClusterRole
  name: platform
  apiGroup: rbac.authorization.k8s.io
```

Mesma coisa aqui, a configuração é super parecida com a RoleBinding, mudando somente o Kind, que agora é `ClusterRoleBinding`, e também não tem o campo `namespace`.

Bora aplicar os arquivos:

```bash
kubectl apply -f platform-clusterrole.yaml
kubectl apply -f platform-clusterrolebinding.yaml
```

Para verificar se os recursos foram criados com sucesso, vamos listar os ClusterRoles e ClusterRoleBindings do cluster:

```bash
kubectl get clusterroles
kubectl get clusterrolebindings
```

Estão criados!

Agora vamos adicionar o certificado do usuário no kubeconfig:

```bash
kubectl config set-credentials platform --client-certificate=platform.crt --client-key=platform.key --embed-certs=true
```

Falta agora criar o contexto para o usuário:

```bash
kubectl config set-context platform --cluster=NOME-DO-CLUSTER --user=platform
```

E já era! Agora vamos testar o acesso ao cluster:

```bash
kubectl config use-context platform
kubectl get pods --all-namespaces
```

Tudo funcionando lindamente!

Agora vamos tentar listar os Nodes do cluster:

```bash
kubectl get nodes
```

O resultado será algo parecido com isso:

```bash
Error from server (Forbidden): nodes is forbidden: User "platform" cannot list resource "nodes" in API group "" at the cluster scope
```

Ou seja, o usuário `platform` não tem permissão para listar os Nodes do cluster, pois ele só tem permissão para listar os recursos `deployments`, `services`, `configmaps`, `secrets`, `ingresses` e `pods` conforme definido na nossa ClusterRole. 

Simples como voar!

#### ClusterRole e ClusterRoleBinding para o usuário admin

Agora vamos criar um usuário que terá acesso total ao cluster, ou seja, ele terá acesso a todos os recursos do cluster, e a todos os namespaces do cluster.

Primeiro vamos criar a chave privada e o CSR do usuário:

```bash
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -out admin.csr -subj "/CN=admin/O=admin"
```

Converta o conteúdo do arquivo `admin.csr` para base64, e cole o resultado no campo `request` do arquivo `admin-csr.yaml`:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
 name: admin
spec:
 request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1pUQ0NBVTBDQVFBd0lERU9NQXdHQTFVRUF3d0ZZV1J0YVc0eERqQU1CZ05WQkFvTUJXRmtiV2x1TUlJQgpJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBb2NtUUxVdVc1TEpKM0p4YmZFdmY1a2xGClRCdWZrb2h3SFBiS1FVYVdmNWErc3FrRzBlS2NSMXplVmhwZXNnYUh3WG9uRnVYakdzc3BHaHJnL21XcWFQSG4KNU14SE1uc1lmWE9VV2diOWIrT3VtRFV1Qmh3eE5EL0c1eSswMmhORUIybzdaTzltcUlCNkdZWlo2d3dHQ01vSgpVVGFzM2tCNVBXaUg4eXFISDZhdFhPNlBteG5Ba0Iyb3praHQ0NWp0ZlNVeDI1UzQvN00zVTVwSjhOTG9jU3N1CjE3d0wvRWdhQitpaThVa0t3MnNvZlZTM2hwQlNxNVNNbzNqZ2dCQ3R3eWN0UzhOWG9wb2M4Rlg5SzFWeFBGMXEKSnpGK2N2UFZVZHNWUUNJWm45Vkt6ZTV4T2JBT2ZYL2hrallrdFhJS0VIU2dIYTZvTXdOT0hXWlBxQVUrVndJRApBUUFCb0FBd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFJeFJJeVN6TzY0Vi95ZHRoNVVSS09IcXdBM3JKb2U0CnJFc3A3Nkp2VTNjcVFtUVVFem9nR2RzdHMxWEFGVzA5cGJxZTdJa1pXTktOemp2NjZyTThkeDBnazRpSWdCdGkKeXovWDI5ZE5KUEVqRCthTW1sSWJ1VEpnZkpSYmx0a1lDYVpPN2tqWUJlMXRNNWE5U0dCQXg3bkt0RnlTNzArMwpTN2VaQmhYNlY2K080Z1FsZlEzT1ZxMzlzSzN5QnBPallYTDQxak5HZmh0TkRTcjNMWExodzd2MjhJb2xUZXQ5CnZJSUw0S3hjQ3kvUTROUTFXSnlKdkpWODZJS01BT2tabjJtUnY0UWFoUEVRM1grS21RbmxpQ01QYnFic2l3czUKL1pTKzA1QUp2QytLalhjcXpHZ016V21rbDlZOXV4RENVVE5paXdmQkJiOGhvRW9PV2lzcENHcz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
 signerName: kubernetes.io/kube-apiserver-client
 expirationSeconds: 31536000 # 1 year
 usages:
 - client auth
```

Agora vamos aplicar:

```bash
kubectl apply -f admin-csr.yaml
```

Hora de aprovar o CSR:

```bash
kubectl certificate approve admin
```

Agora vamos pegar o certificado do usuário:

```bash
kubectl get csr admin -o jsonpath='{.status.certificate}' | base64 --decode > admin.crt
```

Agora bora criar o arquivo `admin-clusterrole.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: admin
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["*"]
  verbs: ["*"]
```

Perceba que nesse caso, nós estamos utilizando o `*` para indicar que o usuário terá acesso a todos os recursos do cluster, e a todos os namespaces do cluster.

Agora vamos criar o arquivo `admin-clusterrolebinding.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: AdminClusterRoleBinding
subjects:
- kind: User
  name: admin
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
```

Agora vamos aplicar os arquivos:

```bash
kubectl apply -f admin-clusterrole.yaml
kubectl apply -f admin-clusterrolebinding.yaml
```

Para verificar se os recursos foram criados com sucesso, vamos listar os ClusterRoles e ClusterRoleBindings do cluster:

```bash
kubectl get clusterroles
kubectl get clusterrolebindings
```

Estão lá! Hora de adicionar o certificado do usuário no kubeconfig:

```bash
kubectl config set-credentials admin --client-certificate=admin.crt --client-key=admin.key --embed-certs=true
```

E criar o contexto para o usuário:

```bash
kubectl config set-context admin --cluster=NOME-DO-CLUSTER --user=admin
```

Fim! hahahah

Agora é só testar, então vamos:
  
```bash
kubectl config use-context admin
kubectl get pods --all-namespaces
```

Você pode usar um comando super útil para saber tudo o que o usuário pode fazer no cluster:

```bash
kubectl auth can-i --list
```

A saída é gigante, então vou colocar somente o começo dela:

```bash
Resources                                        Non-Resource URLs   Resource Names   Verbs
leases.coordination.k8s.io                       []                  []               [create delete deletecollection get list patch update watch]
rolebindings.rbac.authorization.k8s.io           []                  []               [create delete deletecollection get list patch update watch]
roles.rbac.authorization.k8s.io                  []                  []               [create delete deletecollection get list patch update watch]
configmaps                                       []                  []               [create delete deletecollection patch update get list watch]
events                                           []                  []               [create delete deletecollection patch update get list watch]
persistentvolumeclaims                           []                  []               [create delete deletecollection patch update get list watch]
...
```

Um bom teste é você comparar com o usuário `developer` e com o usuário `platform`, assim você poderá ver a diferença entre eles do que eles podem fazer no cluster.

Acho que deu pra entender bem como funciona o RBAC, e como criar usuários com diferentes níveis de acesso ao cluster, e como criar Roles e ClusterRoles para diferentes perfis de usuários.

Agora é só praticar!

#### Removendo o usuário

Para remover o usuário é super simples, basta remover o CSR e o RoleBinding relacionado ao usuário.

```bash
kubectl delete csr NOME-DO-CSR
kubectl delete rolebinding NOME-DO-ROLEBINDING
```

E para remover do seu kubeconfig, basta utilizar o comando `kubectl config unset`:

```bash
kubectl config unset users.NOME-DO-USUARIO
```

Pronto, usuário removido!

### Utilizando Tokens para Service Accounts

Uma das formas de autentição no Kubernetes é através de Tokens, que são utilizados para autenticar Service Accounts, que são contas de serviço utilizadas, normalmente, por aplicações que rodam no cluster ou serviços que precisam acessar o cluster.

Os Tokens são gerados automaticamente pelo Kubernetes, e são utilizados para autenticar Service Accounts, e eles são armazenados em Secrets, que são recursos do Kubernetes que armazenam informações sensíveis, como por exemplo, chaves privadas, senhas, tokens, etc.

O primeiro passo para a criação de um Service Account utilizando Tokens é criar o Service Account, então bora começar os trablahos!

#### Criando um Service Account

Podemos criar service accounts utilizando o comando `kubectl` ou através de um arquivo YAML, e é isso que vamos fazer, criar um arquivo chamado `service-account.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: service-account-example
  namespace: default
```

Nada de novo acima, certo? No arquivo estamos definindo o seguinte:

- `apiVersion`: Versão da API que estamos utilizando para criar o nosso Service Account.
- `kind`: Tipo do recurso que estamos criando, no caso, um Service Account.
- `metadata.name`: Nome do nosso Service Account.
- `metadata.namespace`: Namespace que o nosso Service Account será criado.
```

Agora vamos aplicar o arquivo no cluster:

```bash
kubectl apply -f service-account.yaml
```

Caso queira criar utilizando a linha de comando, basta utilizar o comando `kubectl create serviceaccount NOME-DO-SERVICE-ACCOUNT`.

Agora vamos ver os detalhes da nossa Service Account:

```bash
kubectl get serviceaccounts service-account-example -o yaml
```

A saída será algo parecido com isso:

```bash
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"ServiceAccount","metadata":{"annotations":{},"name":"service-account-example","namespace":"default"}}
  creationTimestamp: "2024-02-05T10:20:19Z"
  name: service-account-example
  namespace: default
  resourceVersion: "2472"
  uid: 0d21af3f-e242-477b-8557-983533562274
```

Pronto, Service Account criado com sucesso!

Agora vamos criar o Secret que irá armazenar o Token do Service Account.

#### Criando um Secret para o Service Account

Novamente aqui podemos utilizar o comando `kubectl` ou um arquivo YAML, e é isso que vamos fazer, criar um arquivo chamado `service-account-secret.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: service-account-example-token
  annotations:
    kubernetes.io/service-account.name: service-account-example
type: kubernetes.io/service-account-token
```

Aqui estamos falando o seguinte para o Kubernetes:

- `apiVersion`: Versão da API que estamos utilizando para criar o nosso Secret.
- `kind`: Tipo do recurso que estamos criando, no caso, um Secret.
- `metadata.name`: Nome do nosso Secret.
- `metadata.annotations`: Anotações do nosso Secret.
- `metadata.annotations.kubernetes.io/service-account.name`: Nome do nosso Service Account.
- `type`: Tipo do Secret, que no caso é `kubernetes.io/service-account-token`.

Pronto, hora de aplicar o arquivo:

```bash
kubectl apply -f service-account-secret.yaml
```

Vamos ver se está tudo certo com o nosso Secret:

```bash
kubectl get secrets service-account-example-token -o yaml
```

A saída será algo parecido com isso:

```bash
Name:         service-account-example-token
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: service-account-example
              kubernetes.io/service-account.uid: 0d21af3f-e242-477b-8557-983533562274

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1099 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IkhicVNQcnRtbVBOa0tzVm00WUJfZjMwajNMZVN1bl9peXo0WVpUUHVjSTQifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InNlcnZpY2UtYWNjb3VudC1leGFtcGxlLXRva2VuIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InNlcnZpY2UtYWNjb3VudC1leGFtcGxlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiMGQyMWFmM2YtZTI0Mi00NzdiLTg1NTctOTgzNTMzNTYyMjc0Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6c2VydmljZS1hY2NvdW50LWV4YW1wbGUifQ.B_N9F9gTucLFryhyTMNJxjCoEAa1q5NmbtUJ95RUNwEUUKY3KapDxezrFMZCA7VG-I7YbukRdYKusYmtWnZLvlgm2UHw1CY4dmzlqBwu3-XhOms8OHVAu1JVbGujgjljPEQy8jPFrkYRz356L_5FUzka9Noj3i2pj5R1wOrJz1O2KAw99RhKI1ctKtXnk4O0VJJ4fdmDUf0Ox0PQt4oNgGr28ZRIpyZkB0RSjhO3Wb6QgsGPoTBKHYnRo3zcCNymEkF8iJBGyyv4WyMx5zr4prCUpeSHqg-2m6vI_KZ9pu0pCJVJ1wV25vU6WOsyY56UR87a7jeBh83m-sOM8SAqOA
```

Já era! Secret está lá e com o Token do Service Account.
Nós não precisamos gerar o Token, isso foi feito automaticamente pelo Kubernetes, pois quando criamos a nossa Secret, nós informamos que a Secret é do tipo `kubernetes.io/service-account-token`, e também informamos o nome do nosso Service Account. Com isso o Kubernetes gerou automaticamente o Token para o nosso Service Account especificado e armazenou na Secret. Simples como voar!

Agora, para acessar o nosso Token, uma forma que eu gosto bastante é utilizando o comando `kubectl get secret`, e com o comando `kubectl get secret NOME-DO-SECRET -o jsonpath='{.data.token}' | base64 --decode`, assim você consegue pegar o Token do Service Account.

Olha o comando completo:

```bash
kubectl get secret service-account-example-token -o jsonpath='{.data.token}' | base64 --decode
```

Dessa forma você consegue pegar o Token do Service Account, já decodificado, e utilizar para autenticar a sua aplicação ou serviço no cluster.

Agora precisamos criar uma Role para o nosso Service Account.

Aqui não temos nada de novo, pois já vimos como criar Roles, então vamos criar um arquivo chamado `service-account-role.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: service-account-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

Com a definição da Role acima, estamos falando que quem utilizar essa Role terá permissão para `get`, `list` e `watch` nos recursos `pods` do namespace `default`, somente!

Vamos aplicar o arquivo:

```bash
kubectl apply -f service-account-role.yaml
```

Agora precisamos criar um RoleBinding para o nosso Service Account.

Vamos criar um arquivo chamado `service-account-rolebinding.yaml` com o seguinte conteúdo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: service-account-rolebinding
  namespace: default
subjects:
- kind: ServiceAccount
  name: service-account-example
  namespace: default
roleRef:
  kind: Role
  name: service-account-role
  apiGroup: rbac.authorization.k8s.io
```

Aqui estamos conectando a nossa Role com o nosso Service Account, e estamos dizendo que o nosso Service Account terá todas as permissões definidas na Role `service-account-role` no namespace `default`.

Vamos aplicar o arquivo:

```bash
kubectl apply -f service-account-rolebinding.yaml
```

Vamos listar as Roles e RoleBindings do namespace `default`:

```bash
kubectl get roles
kubectl get rolebindings
```

Estão lá, mais uma etapa concluída!

Agora que temos tudo o que precisamos, a nossa Service Account está pronta para ser utilizada.

#### Utilizando o Token do Service Account

Para o nossa exemplo, vamos criar um Pod que irá utilizar o Token do Service Account para acessar o cluster.

Vamos criar um arquivo chamado `pod-service-account.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-service-account
  namespace: default
spec:
  serviceAccountName: service-account-example
  containers:
  - name: curl-container
    image: curlimages/curl
    command: ["sleep", "infinity"]
```

A informação nova que temos nessa definição de Pod é o campo `serviceAccountName`, que é onde informamos o nome do nosso Service Account.

Vamos aplicar o arquivo:

```bash
kubectl apply -f pod-service-account.yaml
```

Agora vamos listar os Pods do namespace `default`:

```bash
NAME                  READY   STATUS    RESTARTS   AGE
pod-service-account   1/1     Running   0          6s
```

Os Tokens são montados dentro do container do Pod no caminho `/var/run/secrets/kubernetes.io/serviceaccount`, e o Token do Service Account está no arquivo `token`, vamos confirmar isso:

```bash
kubectl exec -it pod-service-account -- ls /var/run/secrets/kubernetes.io/serviceaccount
```

A saída será algo parecido com isso:

```bash
ca.crt     namespace  token
```

Onde: 

- `ca.crt`: É o certificado do cluster.
- `namespace`: É o namespace do Pod.
- `token`: É o Token do Service Account.

Vamos dar uma olhada no conteúdo do arquivo `token`:

```bash
kubectl exec -it pod-service-account -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

Agora temos o nosso Token:
  
```bash
eyJhbGciOiJSUzI1NiIsImtpZCI6IkhicVNQcnRtbVBOa0tzVm00WUJfZjMwajNMZVN1bl9peXo0WVpUUHVjSTQifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzM4NjY1OTY3LCJpYXQiOjE3MDcxMjk5NjcsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJwb2Qtc2VydmljZS1hY2NvdW50IiwidWlkIjoiY2MyNmQ1MTUtZjYwMS00MTU3LWIzNDAtZDUzM2Q0OTdhZjE5In0sInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJzZXJ2aWNlLWFjY291bnQtZXhhbXBsZSIsInVpZCI6IjBkMjFhZjNmLWUyNDItNDc3Yi04NTU3LTk4MzUzMzU2MjI3NCJ9LCJ3YXJuYWZ0ZXIiOjE3MDcxMzM1NzR9LCJuYmYiOjE3MDcxMjk5NjcsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnNlcnZpY2UtYWNjb3VudC1leGFtcGxlIn0.O-XrTx9b1ZqvFpedKH6lBsQeHeP2qn3bEuL1WVKjCgMhd2TtjKAJOgDJH2Spye-7BQF1bwa2KyAwoWCauDDZ4I0XqwjVRSUF8dUahFmbAL9fMzrieEA2oPkNuPnwCCF57Csls52J-1z9GdIElgG-Z48aksrl0iIB1l7y5TBKS3Za7W2XDBdl1sFx1fKsAlz6k_NPaC49I21NJlmk9i3LxwctvDn6oxMjbCjBVk4fFVnK3y1HsdR_3trCLKH-FDgy59jD96Ume4VPgQMfmXNigObyJ6t3qcL53IRnqdY0xrFNOwHjwIMxBqQSTGSf42xUBWVjfKHZ_gMTX_Va-Nyk9A%
```

Agora vamos fazer um bom teste utilizando o nosso Token.

No Kubernetes é possível listar os recursos do cluster utilizando a API do Kubernetes, e para isso podemos utilizar o comando `curl`, mas antes vamos entender como funciona a autenticação com o Token.

Para autenticar com o Token, precisamos enviar o Token no header `Authorization` da requisição, e o valor do header `Authorization` deve ser `Bearer` seguido do Token.

Vamos entender o endereco da API do Kubernetes, que é `https://kubernetes.default.svc`, e o recurso que queremos listar, que é `pods`, e o namespace que queremos listar, que é `default`, então a URL da nossa requisição será:

`https://kubernetes.default.svc/api/v1/namespaces/default/pods`

Se eu quiser listar todos os Services do namespace `default`, a URL será:

`https://kubernetes.default.svc/api/v1/namespaces/default/services`

Se for em um namespace específico, basta trocar o `default` pelo nome do namespace.

Agora vamos fazer a requisição utilizando o `curl`, mas antes precisamos entrar no container do Pod, então vamos fazer isso:

```bash
kubectl exec -it pod-service-account -- sh
```

Agora vamos fazer a requisição utilizando o `curl`:

```bash
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/pods
```

Com isso estamos utilizando o curl para fazer a requisição para a API do Kubernetes, passando o Token do Service Account no header `Authorization`, e estamos listando os Pods do namespace `default`.

Eu não vou colar a saída aqui, pois ela é gigante, então faça o teste e veja os detalhes dos Pods do namespace `default`.

Se você tentar listar os Pods de outro namespace, você não terá permissão, pois a Role que criamos para o nosso Service Account é somente para o namespace `default`, e a mesma coisa para os outros recursos do cluster como Services, Deployments, etc.

Vamos tentar listar os Services do namespace `default`:

```bash
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/services
```

Recebemos um erro, pois o nosso Service Account não tem permissão para listar os Services do namespace `default`.

```bash
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "services is forbidden: User \"system:serviceaccount:default:service-account-example\" cannot list resource \"services\" in API group \"\" in the namespace \"default\"",
  "reason": "Forbidden",
  "details": {
    "kind": "services"
  },
  "code": 403
}
```

Pronto, com isso o nosso teste está completo, e vimos como utilizar o Token do Service Account para autenticar na API do Kubernetes.

Agora é só praticar e ficar uma pessoa expert no assunto!

#### Removendo o Service Account

Para remover o Service Account é super simples, basta remover o Service Account, o Secret e a RoleBinding relacionado ao Service Account.

```bash
kubectl delete serviceaccount NOME-DO-SERVICE-ACCOUNT
kubectl delete secret NOME-DO-SECRET
kubectl delete rolebinding NOME-DO-ROLEBINDING
```

Pronto, cluster limpo!

## Final do Day-15

Hoje o dia foi especial e super focado em entender como podemos criar usuários e Service Accounts no Kubernetes, e como podemos definir permissões para esses usuários e Service Accounts utilizando Roles e ClusterRoles.

Fizemos diversos exemplos para que ajude a entender como funciona o RBAC no Kubernetes, e como administrar como esses usuários e Service Accounts podem interagir com o cluster.

Agora é com você, pratique diferentes exemplos e veja como funciona na prática. Comece entendendo as permissões que cada usuário e Service Account tem, e depois vá criando diferentes Roles e ClusterRoles para diferentes perfis de usuários e Service Accounts. Utilize as Roles que já existem no cluster para ter um ponto de partida, e vá criando novas Roles e ClusterRoles conforme a necessidade.
