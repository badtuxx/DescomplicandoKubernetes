# Simplificando Kubernetes

## Día 3

&nbsp;

### Contenido del Día 3

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 3](#día-3)
    - [Contenido del Día 3](#contenido-del-día-3)
    - [Inicio de la Lección del Día 3](#inicio-de-la-lección-del-día-3)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
    - [¿Qué es un Deployment?](#qué-es-un-deployment)
      - [Cómo crear un Deployment](#cómo-crear-un-deployment)
      - [¿Qué significa cada parte del archivo?](#qué-significa-cada-parte-del-archivo)
      - [¿Cómo aplicar el Deployment?](#cómo-aplicar-el-deployment)
      - [¿Cómo verificar si el Deployment se ha creado?](#cómo-verificar-si-el-deployment-se-ha-creado)
      - [¿Cómo verificar los Pods que el Deployment está gestionando?](#cómo-verificar-los-pods-que-el-deployment-está-gestionando)
      - [Cómo verificar el ReplicaSet que el Deployment está gestionando?](#cómo-verificar-el-replicaset-que-el-deployment-está-gestionando)
      - [Cómo verificar los detalles del Deployment?](#cómo-verificar-los-detalles-del-deployment)
      - [Cómo actualizar el Deployment?](#cómo-actualizar-el-deployment)
      - [¿Cuál es la estrategia de actualización predeterminada del Deployment?](#cuál-es-la-estrategia-de-actualización-predeterminada-del-deployment)
      - [Estrategias de actualización del Deployment](#estrategias-de-actualización-del-deployment)
        - [Estrategia RollingUpdate (Actualización gradual)](#estrategia-rollingupdate-actualización-gradual)
        - [Estrategia Recreate](#estrategia-recreate)
      - [Realizando un rollback de una actualización](#realizando-un-rollback-de-una-actualización)
      - [Eliminando un Deployment](#eliminando-un-deployment)
      - [Conclusión](#conclusión)

&nbsp;

### Inicio de la Lección del Día 3

&nbsp;

### ¿Qué veremos hoy?

Durante el día de hoy, aprenderemos acerca de un objeto muy importante en Kubernetes: el **Deployment** (Implementación). Veremos todos los detalles para obtener una comprensión completa de qué es un Deployment y cómo funciona. Ahora que ya sabemos todo acerca de cómo crear un Pod, creo que es momento de agregar un poco más de complejidad a nuestro escenario, ¿no te parece? ¡Vamos a por ello!
&nbsp;

### ¿Qué es un Deployment?

En Kubernetes, un **Deployment** es un objeto crucial que representa una aplicación. Su función principal es administrar los Pods que componen la aplicación. Un Deployment es una abstracción que nos permite actualizar los Pods e incluso realizar un rollback a una versión anterior en caso de problemas.

Cuando creamos un Deployment, podemos definir el número de réplicas que deseamos mantener. El Deployment se asegurará de que el número de Pods bajo su administración sea igual al número de réplicas definidas. Si un Pod falla, el Deployment creará un nuevo Pod para reemplazarlo. Esto resulta de gran ayuda para mantener alta la disponibilidad de la aplicación.

El enfoque del Deployment es declarativo, lo que significa que definimos el estado deseado y el propio Deployment se encarga de realizar las acciones necesarias para que el estado actual coincida con el deseado.

Cuando creamos un Deployment, automáticamente se genera un objeto llamado ReplicaSet. El ReplicaSet es el encargado de gestionar los Pods para el Deployment, mientras que el Deployment se encarga de administrar los ReplicaSets. Como mencioné, un ReplicaSet se crea automáticamente junto con el Deployment, pero también podemos crear un ReplicaSet de forma manual si es necesario. Abordaremos este tema con más detalle en el próximo día, ya que hoy nuestro enfoque está en el Deployment.

&nbsp;

#### Cómo crear un Deployment

Para crear un Deployment, necesitamos un archivo YAML. Creemos un archivo llamado **deployment.yaml** y agreguemos el siguiente contenido:

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
            cpu: "0.25"
            memory: 128Mi
```

&nbsp;

#### ¿Qué significa cada parte del archivo?

```yaml
apiVersion: apps/v1
kind: Deployment
```

Aquí estamos definiendo que el tipo de objeto que estamos creando es un Deployment y la versión de la API que estamos utilizando es **apps/v1**.

&nbsp;

```yaml
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
```

Aquí estamos definiendo el nombre del Deployment, que es **nginx-deployment**, y también estamos definiendo las etiquetas (labels) que se agregarán al Deployment. Las etiquetas se utilizan para identificar los objetos en Kubernetes.

&nbsp;

```yaml
spec:
  replicas: 3
```

Aquí estamos definiendo el número de réplicas que tendrá el Deployment. En este caso, estamos configurando el Deployment para tener 3 réplicas.

&nbsp;

```yaml
selector:
  matchLabels:
    app: nginx-deployment
```

Aquí estamos definiendo el selector que se utilizará para identificar los Pods que el Deployment gestionará. En este caso, estamos configurando el Deployment para gestionar los Pods que tengan la etiqueta **app: nginx-deployment**.

&nbsp;

```yaml
strategy: {}
```

Aquí estamos definiendo la estrategia que se utilizará para actualizar los Pods. En este caso, estamos dejando la estrategia predeterminada, que es la estrategia de Rolling Update, lo que significa que el Deployment actualizará los Pods uno por uno. Entraremos en más detalles sobre las estrategias más adelante.

&nbsp;

```yaml
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
          cpu: "0.25"
          memory: 128Mi
```

Aquí estamos definiendo la plantilla que se utilizará para crear los Pods. En este caso, estamos definiendo que la plantilla usará la imagen **nginx** y que el nombre del contenedor será **nginx**. También estamos definiendo los límites de CPU y memoria que el contenedor podrá utilizar. Esta definición es idéntica a lo que vimos en el Día 2, cuando creamos un Pod.
&nbsp;

Simple, ¿verdad? Ahora vamos a aplicar el Deployment.

#### ¿Cómo aplicar el Deployment?

Para aplicar el Deployment, necesitamos ejecutar el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

&nbsp;

#### ¿Cómo verificar si el Deployment se ha creado?

Para verificar si el Deployment se ha creado, debemos ejecutar el siguiente comando:

```bash
kubectl get deployments -l app=nginx-deployment
```

El resultado será el siguiente:

```bash
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-78cd4b8fd-r4zk8   1/1     Running   0          5s

```

#### ¿Cómo verificar los Pods que el Deployment está gestionando?

Para verificar los Pods que el Deployment está gestionando, debemos ejecutar el siguiente comando:

```bash
kubectl get pods -l app=nginx
```

El resultado será el siguiente:

```bash
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-78cd4b8fd-8b8mm   1/1     Running   0          44s
nginx-deployment-78cd4b8fd-kn4v8   1/1     Running   0          44s
nginx-deployment-78cd4b8fd-xqn5g   1/1     Running   0          44s
```

Esto sucede porque el selector del Deployment es **app: nginx** y las etiquetas de los Pods que el Deployment está gestionando son **app: nginx**, ¿recuerdas que definimos esto en la plantilla del Deployment?

&nbsp;

#### Cómo verificar el ReplicaSet que el Deployment está gestionando?

Si deseas listar los ReplicaSets que el Deployment está gestionando, puedes ejecutar el siguiente comando:

```bash
kubectl get replicasets -l app=nginx
```

El resultado será el siguiente:

```bash
NAME                         DESIRED   CURRENT   READY   AGE
nginx-deployment-78cd4b8fd   3         3         3       88s
```

Recuerda que entraremoen detalles sobre los ReplicaSets más adelante.

&nbsp;

#### Cómo verificar los detalles del Deployment?

Para verificar los detalles del Deployment, debemos ejecutar el siguiente comando:

```bash
kubectl describe deployment nginx-deployment
```

En la salida del comando `kubectl describe deployment nginx-deployment`, encontraremos información importante sobre el Deployment, como por ejemplo:

- El nombre del Deployment
- El Namespace en el que se encuentra el Deployment
- Las etiquetas que tiene el Deployment
- La cantidad de réplicas que tiene el Deployment
- El selector que el Deployment utiliza para identificar los Pods que gestionará
- Límites de CPU y memoria que el Deployment utilizará
- La plantilla del Pod que el Deployment utilizará para crear los Pods
- La estrategia que el Deployment utilizará para actualizar los Pods
- El ReplicaSet que el Deployment está gestionando
- Los eventos que han ocurrido en el Deployment

Vamos echar un vistazo a una parte de la salida del comando `kubectl describe deployment nginx-deployment`:

```bash
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Fri, 20 Jan 2023 19:05:29 +0100
Labels:                 app=nginx-deployment
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx-deployment
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx-deployment
  Containers:
   nginx:
    Image:      nginx
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        250m
      memory:     128Mi
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-78cd4b8fd (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m13s  deployment-controller  Scaled up replica set nginx-deployment-78cd4b8fd to 3
```

&nbsp;

#### Cómo actualizar el Deployment?

Supongamos que ahora necesitamos utilizar una versión específica de la imagen de Nginx en el Deployment, para lograrlo, necesitamos modificar el archivo `deployment.yaml` y cambiar la versión de la imagen por **nginx:1.16.0**, por ejemplo.

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
      - image: nginx:1.16.0
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: "0.25"
            memory: 128Mi
```

Ahora que hemos modificado la versión de la imagen de Nginx, necesitamos aplicar los cambios al Deployment. Para ello, ejecutamos el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment configured
```

"
Vamos a ver los detalles del Deployment para verificar si se ha modificado la versión de la imagen:

```bash
kubectl describe deployment nginx-deployment
```

En la salida del comando, podemos ver la línea donde se encuentra la versión de la imagen de Nginx:

```bash
Containers:
   nginx:
    Image:      nginx:1.16.0
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        250m
      memory:     128Mi
    Environment:  <none>
    Mounts:       <none>
```

&nbsp;

#### ¿Cuál es la estrategia de actualización predeterminada del Deployment?

Cuando creamos nuestro Deployment, no especificamos ninguna estrategia de actualización, por lo que Kubernetes utiliza la estrategia de actualización predeterminada, que es la estrategia RollingUpdate.

La estrategia RollingUpdate es la estrategia de actualización estándar en Kubernetes. Se utiliza para actualizar los Pods de un Deployment de manera gradual, es decir, actualiza un Pod a la vez o un grupo de Pods a la vez.

Podemos definir cómo será la actualización de los Pods, por ejemplo, podemos especificar la cantidad máxima de Pods que pueden estar no disponibles durante la actualización, o podemos definir la cantidad máxima de Pods que se pueden crear durante la actualización.

Vamos a comprender un poco mejor cómo funciona esto en el próximo tema.

#### Estrategias de actualización del Deployment

Kubernetes tiene 2 estrategias de actualización para los Deployments:

- RollingUpdate (Actualización gradual)
- Recreate (Recreación)

Vamos a entender un poco mejor cada una de estas estrategias.

##### Estrategia RollingUpdate (Actualización gradual)

La estrategia RollingUpdate es la estrategia de actualización predeterminada en Kubernetes. Se utiliza para actualizar los Pods de un Deployment de manera gradual, es decir, actualiza un Pod a la vez o un grupo de Pods a la vez.

Podemos definir cómo será la actualización de los Pods. Por ejemplo, podemos especificar la cantidad máxima de Pods que pueden estar no disponibles durante la actualización, o la cantidad máxima de Pods que se pueden crear durante la actualización.

También vamos a aumentar la cantidad de réplicas del Deployment a 10, para tener más Pods para actualizar.

Y para poder probar la estrategia RollingUpdate, vamos a cambiar la versión de la imagen de Nginx a 1.15.0.

Para configurar estas opciones, debemos modificar el archivo `deployment.yaml` y agregar las siguientes configuraciones:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 10
  selector:
    matchLabels:
      app: nginx-deployment
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 2
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.15.0
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: "0.25"
            memory: 128Mi
```

Lo que hemos hecho es agregar las siguientes configuraciones:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 2
```

Donde:

- `maxSurge`: define la cantidad máxima de Pods que pueden crearse durante la actualización. En otras palabras, durante el proceso de actualización, podemos tener 1 Pod más que la cantidad de Pods definida en el Deployment. Esto es útil para acelerar la actualización, ya que Kubernetes no tiene que esperar a que un Pod se actualice para crear un nuevo Pod.

- `maxUnavailable`: define la cantidad máxima de Pods que pueden quedar no disponibles durante la actualización. En otras palabras, durante el proceso de actualización, podemos tener 1 Pod no disponible a la vez. Esto es útil para garantizar que el servicio no quede no disponible durante la actualización.

- `type`: define el tipo de estrategia de actualización que se utilizará. En nuestro caso, estamos utilizando la estrategia RollingUpdate.

Ahora que hemos modificado el archivo `deployment.yaml`, debemos aplicar los cambios al Deployment. Para hacerlo, ejecutamos el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment configured
```

Vamos a verificar si los cambios han sido aplicados en el Deployment:

```bash
kubectl describe deployment nginx-deployment
```

En la salida del comando, podemos ver que las líneas donde se encuentran las configuraciones de actualización del Deployment han sido modificadas:

```bash
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  2 max unavailable, 1 max surge
```

Con esta configuración, le estamos indicando a Kubernetes que puede crear hasta 1 Pod adicional durante la actualización, y que puede tener hasta 2 Pods no disponibles durante la actualización, es decir, actualizará de 2 en 2 Pods.

Un comando muy útil para seguir el proceso de actualización de los Pods es:

```bash
kubectl rollout status deployment/nginx-deployment
```

El comando `rollout status` se utiliza para seguir el proceso de actualización de un Deployment, ReplicaSet, DaemonSet, StatefulSet, Job y CronJob. Este comando es muy útil ya que nos informa si el proceso de actualización está en progreso, si se completó con éxito o si falló.

Vamos a ejecutar el comando `rollout status` para seguir el proceso de actualización del Deployment:

```bash
kubectl rollout status deployment nginx-deployment
```

El resultado será el siguiente:

```bash
Waiting for deployment "nginx-deployment" rollout to finish: 9 of 10 updated replicas are available...
deployment "nginx-deployment" successfully rolled out
```

Como podemos ver, el proceso de actualización se ha completado con éxito.

Vamos a verificar si los Pods se han actualizado:

```bash
kubectl get pods -l app=nginx-deployment -o yaml
```

En la salida del comando, podremos ver que los Pods se han actualizado:

```bash
...
  - image: nginx:1.15.0
...
```

También podemos verificar la versión de la imagen de Nginx en el Pod:

```bash
kubectl exec -it nginx-deployment-7b7b9c7c9d-4j2xg -- nginx -v
```

El resultado será el siguiente:

```bash
nginx version: nginx/1.15.0
```

También podemos verificar la versión de la imagen de Nginx en el Pod:

```bash
kubectl exec -it nginx-deployment-7b7b9c7c9d-4j2xg -- nginx -v
```

El resultado será el siguiente:

```bash
nginx version: nginx/1.15.0
```

El comando `nginx -v` se utiliza para verificar la versión de Nginx.

Sin embargo, no siempre esta es la mejor estrategia de actualización, ya que puede haber aplicaciones que no admitan dos versiones del mismo servicio ejecutándose al mismo tiempo, por ejemplo.

Si todo funciona como deseamos, ahora podemos probar la estrategia Recreate.

&nbsp;

##### Estrategia Recreate

La estrategia Recreate es un enfoque de actualización que eliminará todos los Pods del Deployment y creará nuevos Pods con la nueva versión de la imagen. La ventaja es que la implementación será rápida, pero la desventaja es que el servicio no estará disponible durante el proceso de actualización.

Vamos a cambiar el archivo `deployment.yaml` para utilizar la estrategia Recreate:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 10
  selector:
    matchLabels:
      app: nginx-deployment
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.15.0
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: "0.25"
            memory: 128Mi
```

Observe que ahora solo tenemos la configuración `type: Recreate`. Recreate no tiene configuraciones de actualización, es decir, no puedes definir el número máximo de Pods no disponibles durante la actualización, ya que Recreate eliminará todos los Pods del Deployment y creará nuevos Pods.

Una vez que hayamos cambiado el archivo `deployment.yaml`, necesitamos aplicar los cambios en el Deployment. Para ello, ejecutamos el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment configured
```

Vamos a verificar si los cambios se han aplicado al Deployment:

```bash
kubectl describe deployment nginx-deployment
```

En la salida del comando, podremos observar que las líneas donde están las configuraciones de actualización del Deployment han cambiado:

```bash
StrategyType:           Recreate
```

Ahora vamos a cambiar nuevamente la versión de la imagen de Nginx a 1.16.0 en el archivo `deployment.yaml`:

```yaml
image: nginx:1.16.0
```

Una vez que hayamos realizado esta modificación en el archivo `deployment.yaml`, necesitamos aplicar los cambios en el Deployment ejecutando el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment configurado
```

Vamos a verificar los Pods del Despliegue:

```bash
kubectl get pods -l app=nginx-deployment
```

El resultado será el siguiente:

```bash
NOMBRE                               LISTO   ESTADO    REINICIOS   EDAD
nginx-deployment-7d9bcc6bc9-24c2j   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-5r69s   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-78mc9   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-7pb2v   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-gvtvl   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-kb9st   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-m69bm   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-qvppt   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-sqn6q   0/1     Pendiente   0          0s
nginx-deployment-7d9bcc6bc9-zthn4   0/1     Pendiente   0          0s
```

Podemos observar que los Pods están siendo creados nuevamente, pero con la nueva versión de la imagen del Nginx.

Vamos a verificar la versión de la imagen del Nginx en el Pod:

```bash
kubectl exec -it nginx-deployment-7d9bcc6bc9-24c2j -- nginx -v
```

El resultado será el siguiente:

```bash
nginx version: nginx/1.16.0
```

Listo, ahora tenemos la versión 1.16.0 de Nginx ejecutándose en nuestro clúster y ya comprendemos cómo funcionan las estrategias de actualización Rolling Update y Recreate.

&nbsp;

#### Realizando un rollback de una actualización

Ahora que entendemos cómo funcionan las estrategias Rolling Update y Recreate, vamos a aprender cómo hacer un rollback de una actualización.

Vamos a cambiar la versión de la imagen de Nginx a 1.15.0 en el archivo deployment.yaml:

```yaml
image: nginx:1.15.0
```

Ahora que hemos hecho los cambios en deployment.yaml, necesitamos aplicar las modificaciones al Despliegue. Para ello, debemos ejecutar el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment configured
```

Vamos a verificar los Pods del Despliegue:

```bash
kubectl get pods -l app=nginx-deployment
```

También vamos a verificar la versión de la imagen de Nginx en el Pod:

```bash
kubectl exec -it nginx-deployment-7d9bcc6bc9-24c2j -- nginx -v
```

El resultado será el siguiente:

```bash
nginx version: nginx/1.15.0
```

Ahora, imaginemos que queremos revertir la actualización a la versión 1.16.0 de Nginx. Para lograrlo, necesitamos ejecutar el siguiente comando:

```bash
kubectl rollout undo deployment nginx-deployment
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment rolled back
```

Estamos en el proceso de indicarle a Kubernetes que deseamos revertir la actualización a la versión anterior del Despliegue.

Vamos a verificar los Pods del Despliegue:

```bash
kubectl get pods -l app=nginx-deployment
```

También verifiquemos la versión de la imagen de Nginx en el Pod:

```bash
kubectl exec -it nginx-deployment-7d9bcc6bc9-24c2j -- nginx -v
```

El resultado será el siguiente:

```bash
nginx version: nginx/1.16.0
```

Listo, ahora tenemos la versión 1.16.0 de Nginx en funcionamiento en nuestro clúster y ya entendemos cómo hacer un rollback de una actualización. Pero, ¿cómo visualizamos el historial de actualizaciones del Despliegue?

Es sencillo, solo necesitamos ejecutar el siguiente comando:

```bash
kubectl rollout history deployment nginx-deployment
```

Esto nos mostrará el historial de actualizaciones del Despliegue:

```bash
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

En salida del comando, podemos ver que tenemos dos revisiones del Despliegue, la revisión 1 y la revisión 2.

Vamos a verificar el historial de actualizaciones de la revisión 1:

```bash
kubectl rollout history deployment nginx-deployment --revision=1
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment with revision #1
Pod Template:
  Labels: app=nginx-deployment
 pod-template-hash=c549ff78
  Containers:
   nginx:
    Image: nginx:1.16.0
    Port: <none>
    Host Port: <none>
    Limits:
      cpu: 500m
      memory: 256Mi
    Requests:
      cpu: 250m
      memory: 128Mi
    Environment: <none>
    Mounts: <none>
  Volumes: <none>
```

Vamos a verificar el historial de actualizaciones de la revisión 2:

```bash
kubectl rollout history deployment nginx-deployment --revision=2
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment with revision #2
Pod Template:
  Labels: app=nginx-deployment
 pod-template-hash=7d9bcc6bc9
  Containers:
   nginx:
    Image: nginx:1.15.0
    Port: <none>
    Host Port: <none>
    Limits:
      cpu: 500m
      memory: 256Mi
    Requests:
      cpu: 250m
      memory: 128Mi
    Environment: <none>
    Mounts: <none>
  Volumes: <none>
```

Es decir, como podemos ver, la revisión 1 es la versión 1.16.0 de Nginx y la revisión 2 es la versión 1.15.0 de Nginx.

Si deseas hacer un rollback a la revisión 1, simplemente ejecuta el siguiente comando:

```bash
kubectl rollout undo deployment nginx-deployment --to-revision=1
```

El resultado será el siguiente:

```bash
deployment.apps/nginx-deployment rolled back
```

Genial, ahora tenemos la versión 1.16.0 de Nginx ejecutándose en nuestro clúster y ya entendemos cómo hacer un rollback de una actualización, ¿simple, verdad?

El comando `kubectl rollout` es muy útil para nosotros, ya que nos ayuda a visualizar el historial de actualizaciones del Deployment, realizar un rollback de una actualización y mucho más.

Hemos visto algunas opciones del comando `kubectl rollout`, como por ejemplo `kubectl rollout history`, `kubectl rollout undo` y `kubectl rollout status`, pero hay otras opciones que podemos utilizar. Veamos algunas de ellas:

```bash
kubectl rollout pause deployment nginx-deployment
```

El comando `kubectl rollout pause` se utiliza para pausar el Deployment, es decir, detendrá el Deployment y no permitirá que realice ninguna actualización.

```bash
kubectl rollout resume deployment nginx-deployment
```

El comando `kubectl rollout resume` se utiliza para reanudar el Deployment, es decir, lo reactivará y permitirá que realice actualizaciones nuevamente.

```bash
kubectl rollout restart deployment nginx-deployment
```

El comando `kubectl rollout restart` se utiliza para reiniciar el Deployment, es decir, lo reiniciará reemplazando los Pods actuales por nuevos.

```bash
kubectl rollout status deployment nginx-deployment
```

El comando `kubectl rollout status` se utiliza para verificar el estado del Deployment, es decir, verifica el estado del rollout del Deployment.

```bash
kubectl rollout undo deployment nginx-deployment
```

El comando `kubectl rollout undo` se utiliza para hacer un rollback de una actualización, es decir, revertirá una actualización a la revisión anterior.

```bash
kubectl rollout history deployment nginx-deployment
```

El comando `kubectl rollout history` se utiliza para ver el historial de actualizaciones del Deployment.

```bash
kubectl rollout history deployment nginx-deployment --revision=1
```

Recuerda que podemos utilizar el comando `kubectl rollout` en Deployments, StatefulSets y DaemonSets.

&nbsp;

#### Eliminando un Deployment

Para eliminar un Deployment, necesitamos ejecutar el siguiente comando:

```bash
kubectl delete deployment nginx-deployment
```

El resultado será el siguiente:

```bash
deployment.apps "nginx-deployment" deleted
```

Si deseas eliminar el Deployment utilizando el manifiesto, simplemente ejecuta el siguiente comando:

```bash
kubectl delete -f deployment.yaml
```

El resultado será el siguiente:

```bash
deployment.apps "nginx-deployment" deleted
```

¡Listo! Ahora hemos eliminado el Deployment de nuestro clúster.

&nbsp;

#### Conclusión

Durante el día de hoy, hemos aprendido qué es un Deployment, cómo crear uno, cómo actualizarlo, cómo realizar un rollback de una actualización, cómo eliminarlo y mucho más. Con esto, hemos obtenido una sólida base para comenzar a trabajar con Deployments en Kubernetes.

Aún exploraremos mucho más sobre Deployments y conoceremos muchas otras opciones que nos ofrecen, pero por ahora eso es todo. Espero que hayan disfrutado y aprendido mucho del contenido de hoy.

#VAIIII
