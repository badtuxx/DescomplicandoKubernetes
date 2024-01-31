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
 

 # O que iremos ver hoje?

 Hoje é dia de falar....



# RBAC

## O que é RBAC?

RBAC é um acrônimo para Role-Based Access Control, ou Controle de Acesso Baseado em Funções. É um método de controle de acesso que permite que um administrador defina permissões específicas para usuários e grupos de usuários. Isso significa que os administradores podem controlar quem tem acesso a quais recursos e o que eles podem fazer com esses recursos.

No Kubernetes é super importante você entender como funciona o RBAC, pois é através dele que você vai definir as permissões de acesso aos recursos do cluster, como por exemplo, quem pode criar um Pod, um Deployment, um Service, etc.

### Primeiro exemplo de RBAC

Vamos imaginar que precisamos dar acesso ao cluster a uma pessoa desenvolvedora da nossa empresa, mas não queremos que ela tenha acesso a todos os recursos do cluster, apenas aos recursos que ela precisa para desenvolver a sua aplicação.

Para isso, vamos criar um usuário chamado `developer` e vamos dar acesso a ele para criar e administrar os Pods no namespace `dev`.

Temos duas formas de fazer isso, a primeira e mais antiga é através da criação de um Token de acesso, e a segunda e mais nova é através da criação de um usuário.

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

Para isso, vamos precisar mudar para o contexto do usuário, para isso, vamos utilizar o comando `kubectl config use-context`:

```bash
kubectl config use-context developer
```