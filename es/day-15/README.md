# Simplificando Kubernetes

## Día 15: Descomplicando RBAC e controle de acesso no Kubernetes

## Contenido del Día 15

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 15: Descomplicando RBAC e controle de acesso no Kubernetes](#día-15-descomplicando-rbac-e-controle-de-acesso-no-kubernetes)
  - [Contenido del Día 15](#contenido-del-día-15)
- [¿Qué vamos a aprender hoy?](#qué-vamos-a-aprender-hoy)
- [RBAC](#rbac)
  - [¿Qué es RBAC?](#qué-es-rbac)
    - [Primer ejemplo de RBAC](#primer-ejemplo-de-rbac)
      - [Creación de un Usuario para Acceso al clúster](#creación-de-un-usuario-para-acceso-al-clúster)
      - [Creando un Rol para nuestro usuario](#creando-un-rol-para-nuestro-usuario)
      - [apiGroups](#apigroups)
      - [Verbos](#verbos)
      - [Agregando el certificado del usuario al kubeconfig](#agregando-el-certificado-del-usuario-al-kubeconfig)
      - [Accediendo al clúster con el nuevo usuario](#accediendo-al-clúster-con-el-nuevo-usuario)

# ¿Qué vamos a aprender hoy?

Hoy hablaremos de...

# RBAC

## ¿Qué es RBAC?

RBAC es un acrónimo que significa Control de Acceso Basado en Roles (Role-Based Access Control). Es un método de control de acceso que permite a un administrador definir permisos específicos para usuarios y grupos de usuarios. Esto significa que los administradores pueden controlar quién tiene acceso a qué recursos y qué pueden hacer con esos recursos.

En Kubernetes, es fundamental comprender cómo funciona RBAC, ya que a través de él se definen los permisos de acceso a los recursos del clúster, como quién puede crear un Pod, un Deployment, un Service, entre otros.

### Primer ejemplo de RBAC

Supongamos que necesitamos dar acceso al clúster a un desarrollador de nuestra empresa, pero no queremos que tenga acceso a todos los recursos del clúster, sino solo a los recursos necesarios para desarrollar su aplicación.

Para lograrlo, crearemos un usuario llamado `developer` y le daremos acceso para crear y administrar los Pods en el espacio de nombres `dev`.

Existen dos formas de hacerlo. La primera y más antigua es mediante la creación de un Token de acceso, y la segunda y más nueva es mediante la creación de un usuario.

#### Creación de un Usuario para Acceso al clúster

Bueno, ahora que ya sabemos cuáles serán los permisos de nuestro nuevo usuario, podemos comenzar a crearlo.

Lo primero que necesitamos hacer es generar una clave privada para nuestro usuario. Para ello, utilizaremos el comando `openssl`:

```bash
openssl genrsa -out developer.key 2048
```

Con el comando anterior, estamos creando una clave privada de 2048 bits y guardándola en el archivo `developer.key`. El parámetro `genrsa` indica que queremos generar una clave privada, y el parámetro `-out` indica el nombre del archivo en el que queremos guardar la clave.

Una vez creada la clave, debemos generar una Solicitud de Firma de Certificado (Certificate Signing Request o CSR), que es un archivo que contiene el certificado que hemos creado y que se enviará a Kubernetes para que lo firme y genere el certificado final.

```bash
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"
```

En el comando anterior, estamos creando un certificado para nuestro usuario utilizando la clave privada que creamos anteriormente. El parámetro `req` indica que queremos crear un certificado, el parámetro `-key` indica el nombre del archivo de la clave privada que queremos utilizar, el parámetro `-out` indica el nombre del archivo en el que queremos guardar el certificado, y el parámetro `-subj` indica el nombre del usuario que queremos crear.

Ahora, con los dos archivos en mano, podemos comenzar a crear nuestro usuario en el clúster, pero antes, necesitamos crear una Solicitud de Firma de Certificado (Certificate Signing Request o CSR), que es un archivo que contiene el certificado que hemos creado y que se enviará a Kubernetes para que lo firme y genere el certificado final.

Pero para crear el archivo, primero debemos tener el contenido del certificado en base64. Para ello, utilizaremos el comando `base64`:

```bash
cat developer.csr | base64 | tr -d '\n'
```

Con el comando anterior, estamos leyendo el contenido del archivo `developer.csr`, convirtiéndolo a base64 y eliminando el salto de línea.

El contenido del certificado en base64 será algo similar a esto:

```bash
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dUQ0NBVUVDQVFBd0ZERVNNQkFHQTFVRUF3d0paR1YyWld4dmNHVnlNSUlCSWpBTkJna3Foa2lHOXcwCgpBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF5OFN1Y25JWjJjL0k3dXQvS0EwSXhvN0RZa0hkSUxrbmxZOWNwMkVlClJJSzRzU1NzZnA2SzBhbWZlYWtRaEdXT2NWMmFaeEtTM0xrNERNNlVmb3ZucEQvOXpidDl0em44UUpMTDZxREEKeHFxbzVSbEt4QnpEV3lQT2JkUStMWnI2VjFQZ2wxYms2c3o0d2lWek52a2NhT0doSDdlSU90QVI0U096MjNJdAowZ0xiZHBDalFITFIvNlFuSXBjY3h3bDBGa1FtL3RVeHdRa0x1NXNpSTNKOGRiUkQwcnlFdGxReWQ5elhLM29rCjBRbVpLZDVpV1p2aDU3R1lrV1kweGMzV0J5aXY5OURQYVE3WTB4MFNaWGlPL2w0bTRzazJ3RjYwa2dUa1NJZmQKdEMxN2Y1ZzVWVzhOTW02amNpMFRXeDk5Z0REcmpHanJpaExHeTBLUWdRa2p3d0lEQVFBQm9BQXdEUVlKS29aSQpodmNOQVFFTEJRQURnZ0VCQUllZVdLbjAwZkk5ekw3MUVQNFNpOUVxVUFNUnBYT0dkT1Aybm8rMTV2VzJ5WmpwCmhsTWpVTjMraVZubkh2QVBvWFVLKzBYdXdmaklHMjBQTjA5UEd1alU4aUFIeVZRbFZRS0VaOWpRcENXYnQybngKVlZhYUw0N0tWMUpXMnF3M1YybmNVNkhlNHdtQzVqUE9vU29vVGtrVlF5Uml4bkcyVVQrejI3M2xpaTY3RkFXegpBZ1QvczlVa3gvS1dxRjIzczVuUk9TTlZUS2xCSG5LMU40YkN6RHBqZnN5V01GUXdnazhxRCtlOXp0cTh2c1VhCi9Say9jUWNyS2wxVDMyM0xDcG1TekhnM3hDdjFqdzJUVFFINm1yWlBBa2doa2R2YlNnalp6Y1JRZWNqSEpNeTMKTzFJQXJ6V3pWbU1hRTJqeGhUV1JwbkJkcVZjZERTUERiNkNXaktVPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K%
```

Recuerda eliminar el salto de línea al final del archivo, que se representa con el `%`.

Agora que tenemos el contenido del certificado en base64, cópielo y péguelo en el archivo `developer.yaml` que vamos a crear a continuación:

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

En el archivo anterior, estamos definiendo la siguiente información:

- `apiVersion`: La versión de la API que estamos utilizando para crear nuestro usuario.
- `kind`: El tipo de recurso que estamos creando, en este caso, una Solicitud de Firma de Certificado (CSR).
- `metadata.name`: El nombre de nuestro usuario.
- `spec.request`: El contenido del certificado en base64.
- `spec.signerName`: El nombre del firmante del certificado, que en este caso es el kube-apiserver, que será responsable de firmar nuestro certificado.
- `spec.expirationSeconds`: El tiempo de cad

ucidad del certificado, que en este caso es de 1 año.

- `spec.usages`: El tipo de uso del certificado, que en este caso es `client auth` (autenticación de cliente).

Una vez que haya creado este archivo y copiado el contenido del certificado en base64, puede aplicar el recurso utilizando el siguiente comando:

```bash
kubectl apply -f developer.yaml
```

Esto enviará la solicitud de firma de certificado al clúster Kubernetes para que sea firmada y se genere el certificado final para el usuario "developer".

```bash
kubectl apply -f developer.yaml
```

Vamos listar los CSR del clúster para ver el estado de nuestro usuario:

```bash
kubectl get csr
```

El resultado será algo similar a esto:

```bash
NAME        AGE   SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
csr-4zd8k   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-68wsv   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-jkm8t   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-r2hcr   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-x52kj   15m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
developer   3s    kubernetes.io/kube-apiserver-client           kubernetes-admin          365d                Pending
```

Observe que nuestro usuario tiene el estado `Pending` porque el kube-apiserver aún no ha firmado nuestro certificado. Puede seguir el estado de su usuario con el siguiente comando:

```bash
kubectl describe csr developer
```

El resultado será algo similar a esto:

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

Hasta ahora todo va bien, ahora debemos aprobar nuestro certificado utilizando el comando `kubectl certificate approve`:

```bash
kubectl certificate approve developer
```

Ahora vamos listar los CSR (Solicitudes de firma de certificado) del clúster nuevamente:

```bash
kubectl get csr
```

El resultado será algo parecido a esto:

```bash
NAME        AGE   SIGNERNAME                                    REQUESTOR                 REQUESTEDDURATION   CONDITION
csr-4zd8k   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-68wsv   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-jkm8t   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-r2hcr   17m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
csr-x52kj   16m   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   <none>              Approved,Issued
developer   88s   kubernetes.io/kube-apiserver-client           kubernetes-admin          365d                Approved,Issued
```

Listo, nuestro certificado ha sido firmado con éxito. Ahora podemos obtener el certificado de nuestro usuario y guardarlo en un archivo. Para ello, utilizaremos el comando `kubectl get csr`:

```bash
kubectl get csr developer -o jsonpath='{.status.certificate}' | base64 --decode > developer.crt
```

En el comando anterior, estamos obteniendo el certificado de nuestro usuario, decodificándolo en base64 y guardándolo en el archivo `developer.crt`.

Para obtener el certificado, estamos utilizando el parámetro `-o jsonpath='{.status.certificate}'` para que el comando devuelva solo el certificado del usuario y no toda la información del CSR.

Puede verificar el contenido del certificado mediante el comando:

```bash
cat developer.crt
```

Ahora tenemos nuestro certificado final creado y podemos utilizarlo para acceder al clúster, pero antes debemos definir lo que nuestro usuario puede hacer en el clúster.

#### Creando un Rol para nuestro usuario

Cuando creamos un nuevo usuario o ServiceAccount en Kubernetes, no tiene acceso a nada en el clúster. Para que pueda acceder a los recursos del clúster, debemos crear un Rol y asociarlo al usuario.

La definición de un Rol consiste en un archivo donde especificamos qué permisos tendrá el usuario en el clúster y para qué recursos tendrá acceso. Dentro del Rol es donde definimos:

- En qué espacio de nombres (namespace) tendrá acceso el usuario.
- A qué grupos de API (apiGroups) tendrá acceso el usuario.
- A qué recursos tendrá acceso el usuario.
- A qué verbos tendrá acceso el usuario.

#### apiGroups

Los grupos de API (apiGroups) son los grupos de recursos de Kubernetes, que se dividen en `core` y `named`. Puede consultar todos los grupos de recursos de Kubernetes mediante el comando `kubectl api-resources`.

Veamos la lista de grupos de recursos de Kubernetes:

```bash
kubectl api-resources
```

La lista es larga, pero el resultado será algo similar a esto:

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

Donde la primera columna es el nombre del recurso, la segunda columna es el nombre abreviado del recurso, la tercera columna es la versión de la API a la que pertenece el recurso, la cuarta columna indica si el recurso se encuentra o no en un espacio de nombres (Namespaced), y la quinta columna es el tipo de recurso.

Echemos un vistazo a un recurso específico, por ejemplo, el recurso `pods`:

```bash
kubectl api-resources | grep pods
```

El resultado será algo similar a esto:

```bash
NAME       SHORTNAMES   APIVERSION     NAMESPACED   KIND
pods       po           v1             true         Pod
```

Donde:

- `NAME`: Nombre del recurso.
- `SHORTNAMES`: Nombre abreviado del recurso.
- `APIVERSION`: Versión de la API a la que pertenece el recurso.
- `NAMESPACED`: Indica si el recurso se encuentra o no en un espacio de nombres.
- `KIND`: Tipo de recurso.

Pero, ¿qué significa que un recurso esté en un espacio de nombres (Namespaced)? Un recurso Namespaced es un recurso que puede crearse dentro de un espacio de nombres (namespace), por ejemplo, un Pod, un Deployment, un Service, etc. Por otro lado, un recurso que no es Namespaced es un recurso que no puede crearse dentro de un espacio de nombres, como un Nodo (Node), un Volumen Persistente (PersistentVolume), un ClusterRole, etc. ¿Sencillo, verdad?

Ahora bien, ¿cómo sabemos cuál es el apiGroup de un recurso? El apiGroup de un recurso es el nombre del grupo de recursos al que pertenece. Por ejemplo, el recurso `pods` pertenece al grupo de recursos `core`, y el recurso `deployments` pertenece al grupo de recursos `apps`. Cuando un recurso es de tipo `core`, no es necesario especificar su apiGroup, ya que Kubernetes asume automáticamente que pertenece al grupo de recursos `core`, y esto se refleja en `apiVersion: v1`.

Por otro lado, `apiVersion: apps/v1` indica que el recurso pertenece al grupo de recursos `apps`, y su versión de API es `v1`. Dentro del grupo `apps`, encontramos recursos importantes como `deployments`, `replicasets`, `daemonsets`, `statefulsets`, entre otros.

Los recursos son las entidades que Kubernetes administra y gestiona. Estos recursos se dividen en dos categorías principales: `core` y `named`. Puede consultar todos los recursos de Kubernetes utilizando el comando `kubectl api-resources`.

Los recursos denominados `core` son recursos predefinidos que vienen instalados con Kubernetes. Por otro lado, los recursos denominados `named` son recursos que se instalan mediante Custom Resource Definitions (CRD), como por ejemplo, el recurso `ServiceMonitor` utilizado por Prometheus.

A continuación, listaremos los recursos de Kubernetes que no están en un espacio de nombres (non-namespaced):

```bash
kubectl api-resources --namespaced=false
```

El resultado será similar a lo siguiente:

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

De esta manera, podemos identificar cuáles son los recursos nativos de Kubernetes y cuáles son los recursos instalados a través de CRD (Definiciones de Recursos Personalizados, por sus siglas en inglés), como por ejemplo, `ServiceMonitor` de Prometheus.

Por lo tanto, el nombre del recurso es el nombre que utilizamos para crear el recurso, como por ejemplo, `pods`, `deployments`, `services`, etc.

#### Verbos

Los verbos definen las acciones que un usuario puede realizar en un recurso determinado. Por ejemplo, los verbos pueden incluir crear, listar, actualizar, eliminar, etc.

Para que pueda ver los verbos que se pueden utilizar, vamos a utilizar el comando `kubectl api-resources` con la opción `-o wide`:

```bash
kubectl api-resources -o wide
```

El resultado se verá similar a esto:

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

Ahora, observe que tenemos una nueva columna llamada `VERBS`, que contiene todos los verbos que se pueden utilizar con el recurso, y la columna `CATEGORIES`, que muestra la categoría del recurso. Sin embargo, nuestro enfoque aquí está en los verbos, así que echemos un vistazo a ellos.

Los verbos se dividen en:

- `create`: Permite que el usuario cree un recurso.
- `delete`: Permite que el usuario elimine un recurso.
- `deletecollection`: Permite que el usuario elimine una colección de recursos.
- `get`: Permite que el usuario obtenga un recurso.
- `list`: Permite que el usuario liste los recursos.
- `patch`: Permite que el usuario actualice un recurso.
- `update`: Permite que el usuario actualice un recurso.
- `watch`: Permite que el usuario siga los cambios en un recurso.

Por ejemplo, tomemos la línea del recurso `pods`:

```bash
NAME   SHORTNAMES   APIVERSION     NAMESPACED   KIND     VERBS                     CATEGORIES
pods   po           v1             true         Pod      create,delete,deletecollection,get,list,patch,update,watch   all
```

Con esto, sabemos que el usuario puede crear, eliminar, eliminar una colección, obtener, listar, actualizar y seguir los cambios en un Pod. ¡Muy sencillo!

Ahora que conocemos bien los `resources`, `apiGroups` y `verbs`, crearemos nuestra Role para nuestro usuario.

Para ello, crearemos un archivo llamado `developer-role.yaml` con el siguiente contenido:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
 name: developer
 namespace: dev
rules:
- apiGroups: [""] # "" indica el grupo de recursos principal
  resources: ["pods"]
  verbs: ["get", "watch", "list", "update", "create", "delete"]
```

En el archivo anterior, definimos la siguiente información:

- `apiVersion`: Versión de la API que estamos utilizando para crear nuestro usuario.
- `kind`: Tipo de recurso que estamos creando, en este caso, una Role.
- `metadata.name`: Nombre de nuestra Role.
- `metadata.namespace`: Namespace en el que se creará nuestra Role.
- `rules`: Reglas de nuestra Role.
- `rules.apiGroups`: Grupos de recursos a los que tendrá acceso nuestra Role.
- `rules.resources`: Recursos a los que tendrá acceso nuestra Role.
- `rules.verbs`: Verbos a los que tendrá acceso nuestra Role.

Estoy seguro de que le resulta fácil comprender la Role, que básicamente establece lo que nuestro usuario puede hacer en el clúster. En resumen, estamos diciendo que el usuario que utilice esta Role podrá realizar todas las operaciones con el recurso `pods` en el espacio de nombres `dev`. ¡Tan sencillo como volar!

Recuerde que esta Role puede ser reutilizada por otros usuarios y que puede crear tantas Roles como desee, así como crear Roles para otros perfiles de usuarios y otros recursos, como `deployments`, `services`, `configmaps`, etc.

¡Ah, antes de continuar, creemos el espacio de nombres `dev`:

```bash
kubectl create ns dev
```

Ahora que hemos creado nuestro archivo y el espacio de nombres, vamos a aplicarlo en el clúster:

```bash
kubectl apply -f developer-role.yaml
```

Para verificar si nuestra Role se ha creado correctamente, enumeremos las Roles en el clúster:

```bash
kubectl get roles -n dev
```

La salida será algo como:

```bash
NAME        CREATED AT
developer   2024-01-31T11:32:08Z
```

Para ver los detalles de la Role, utilizaremos el comando `kubectl describe`:

```bash
kubectl describe role developer -n dev
```

La salida será algo parecida a esto:

```bash
Name:         developer
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list update create delete]
```

Listo, nuestra Role ya está creada, pero aún no la hemos asociado a nuestro usuario. Para hacerlo, crearemos un RoleBinding.

El RoleBinding es el recurso que asocia un usuario a una Role, es decir, a través del RoleBinding definimos qué usuario tiene acceso a qué Role. Puedes pensar en ello como si fuera una insignia de Desarrollador, donde la Role sería la insignia y el RoleBinding sería la insignia con el nombre del usuario. ¿Tiene sentido?

Para ello, crearemos un archivo llamado `developer-rolebinding.yaml` con el siguiente contenido:

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

En el archivo anterior, estamos definiendo la siguiente información:

- `apiVersion`: La versión de la API que estamos utilizando para crear nuestro usuario.
- `kind`: El tipo de recurso que estamos creando, en este caso, un RoleBinding.
- `metadata.name`: El nombre de nuestro RoleBinding.
- `metadata.namespace`: El espacio de nombres en el que se creará nuestro RoleBinding.
- `subjects`: Los usuarios que tendrán acceso a la Role.
- `subjects.kind`: El tipo de usuario, que en este caso es `User`.
- `subjects.name`: El nombre del usuario, que en este caso es `developer`.
- `roleRef`: La referencia a la Role a la que el usuario tendrá acceso.
- `roleRef.kind`: El tipo de Role, que en este caso es `Role`.
- `roleRef.name`: El nombre de la Role, que en este caso es `developer`.
- `roleRef.apiGroup`: El grupo de recursos de la Role, que en este caso es `rbac.authorization.k8s.io`.

No es nada complicado, y una vez más, está muy claro lo que estamos haciendo, que es darle acceso al usuario `developer` con la Role `developer` en el espacio de nombres `dev`.

Ahora que tenemos nuestro archivo creado, apliquémoslo:

```bash
kubectl apply -f developer-rolebinding.yaml
```

Para verificar si nuestro RoleBinding se creó correctamente, enumeremos los RoleBindings en el clúster:

```bash
kubectl get rolebindings -n dev
```

La salida será:

```bash
NAME                   ROLE             AGE
DeveloperRoleBinding   Role/developer   9s
```

Para ver los detalles del RoleBinding, utilizaremos el comando `kubectl describe`:

```bash
kubectl describe rolebinding DeveloperRoleBinding -n dev
```

La salida será algo similar a esto:

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

Listo, el RoleBinding se ha creado con éxito. Ahora, vamos a probar nuestro usuario.

#### Agregando el certificado del usuario al kubeconfig

Ahora que hemos creado con éxito nuestro usuario, debemos agregar el certificado del usuario al kubeconfig para poder acceder al clúster con nuestro usuario.

Para hacerlo, utilizaremos el comando `kubectl config set-credentials`:

```bash
kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --embed-certs=true
```

El comando `kubectl config set-credentials` se utiliza para agregar un nuevo usuario al kubeconfig y recibe los siguientes parámetros:

- `--client-certificate`: Ruta del certificado del usuario.
- `--client-key`: Ruta de la clave del usuario.
- `--embed-certs`: Indica si el certificado debe incrustarse en el kubeconfig.

En nuestro caso, estamos proporcionando la ruta del certificado y la clave del usuario, y estamos indicando que el certificado debe incrustarse en el kubeconfig.

Ahora debemos crear un contexto para nuestro usuario utilizando el comando `kubectl config set-context`:

```bash
kubectl config set-context developer --cluster=NOMBRE-DEL-CLÚSTER --namespace=dev --user=developer
```

Si no recuerdas qué es un contexto en Kubernetes, te ayudaré a recordarlo. Un contexto es un conjunto de configuraciones que define el acceso a un clúster, es decir, un contexto está compuesto por un clúster, un usuario y un espacio de nombres (namespace). Cuando creas un nuevo usuario, debes crear un nuevo contexto para él, de modo que pueda acceder al clúster.

Para obtener los nombres de los clústeres, puedes utilizar el comando `kubectl config get-clusters`, de esta manera podrás obtener el nombre del clúster que deseas utilizar.

Con esto, nuestro nuevo usuario está listo para ser utilizado, pero antes verifiquemos si funciona correctamente.

#### Accediendo al clúster con el nuevo usuario

Una vez que hemos creado nuestro usuario y que el certificado del usuario se ha agregado al kubeconfig, y que ya tenemos un contexto para el usuario, podemos probar el acceso al clúster.

Para hacerlo, debemos cambiar al contexto del usuario utilizando el comando `kubectl config use-context`:

```bash
kubectl config use-context developer
```
