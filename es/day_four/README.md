# Simplificando Kubernetes

## Día 4

&nbsp;

## Contenido del Día 4

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 4](#día-4)
  - [Contenido del Día 4](#contenido-del-día-4)
  - [Inicio de la Lección del Día 4](#inicio-de-la-lección-del-día-4)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
    - [ReplicaSet](#replicaset)
      - [El Deployment y el ReplicaSet](#el-deployment-y-el-replicaset)
      - [Creando un ReplicaSet](#creando-un-replicaset)
      - [Desactivando el ReplicaSet](#desactivando-el-replicaset)
    - [El DaemonSet](#el-daemonset)
      - [Creando un DaemonSet](#creando-un-daemonset)
      - [Creación de un DaemonSet utilizando el comando kubectl create](#creación-de-un-daemonset-utilizando-el-comando-kubectl-create)
      - [Añadiendo un nodo al clúster](#añadiendo-un-nodo-al-clúster)
      - [Eliminando un DaemonSet](#eliminando-un-daemonset)
    - [Las sondas de Kubernetes](#las-sondas-de-kubernetes)
      - [¿Qué son las sondas?](#qué-son-las-sondas)
      - [Sonda de Integridad (Liveness Probe)](#sonda-de-integridad-liveness-probe)
      - [Sonda de preparación (Readiness Probe)](#sonda-de-preparación-readiness-probe)
      - [Sonda de Inicio](#sonda-de-inicio)
    - [Ejemplo con todas las sondas](#ejemplo-con-todas-las-sondas)
    - [Tu tarea](#tu-tarea)
    - [Final del Día 4](#final-del-día-4)
  
&nbsp;

## Inicio de la Lección del Día 4

### ¿Qué veremos hoy?

Hoy es el día para hablar sobre dos objetos muy importantes en Kubernetes: los `ReplicaSets` y los `DaemonSets`.

Ya sabemos lo que es un `Deployment` y también entendemos los detalles de un `Pod`, así que ahora vamos a conocer estos dos conceptos que están fuertemente relacionados con los `Deployment` y los `Pod`. Cuando hablamos de `Deployment`, es imposible no mencionar los `ReplicaSets`, ya que un `Deployment` es un objeto que crea un `ReplicaSet`, y a su vez, un `ReplicaSet` es un objeto que crea un `Pod`. Todo está conectado.

Por otro lado, nuestro querido `DaemonSet` es un objeto que crea un `Pod`, y este `Pod` es un objeto que se ejecuta en todos los nodos del clúster. Es sumamente importante para nosotros, ya que con un `DaemonSet` podemos asegurarnos de tener al menos un `Pod` funcionando en cada nodo del clúster. Por ejemplo, imagina que necesitas instalar los agentes de `Datadog` o un `exporter` de `Prometheus` en todos los nodos del clúster. Para eso, necesitas un `DaemonSet`.

A lo largo del día de hoy, aprenderemos cómo asegurarnos de que nuestros `Pods` estén funcionando correctamente utilizando las `Probes` de Kubernetes.

Hablaremos sobre las `Readiness Probe`, `Liveness Probe` y `Startup Probe`, y por supuesto, proporcionaremos ejemplos prácticos y detallados.

Hoy es el día en el que aprenderás sobre estos dos objetos tan importantes y asegurarte de que nunca implementemos nuestros `Pods` en producción sin verificar primero que estén funcionando correctamente y siendo supervisados por las `Probes` de Kubernetes.

¡Vamos allá! #VAIIII

### ReplicaSet

Una cosa es muy importante de saber: cuando creamos un `Deployment` en Kubernetes, automáticamente estamos creando, además del `Deployment`, un `ReplicaSet`, y este `ReplicaSet` es quien crea los `Pods` que están dentro del `Deployment`.

¿Confuso, verdad?

No, no lo es, y te lo explicaré.

Cuando creamos un `Deployment`, Kubernetes crea un `ReplicaSet` para generar y gestionar las réplicas de los `Pods` en nuestro clúster. Este es el encargado de observar los `Pods` y garantizar el número de réplicas que hemos definido en el `Deployment`.

Es posible crear un `ReplicaSet` sin un `Deployment`, pero no es una buena práctica, ya que el `ReplicaSet` no tiene la capacidad de gestionar versiones de `Pods` ni de realizar `RollingUpdate` de los `Pods`.

Y aquí está lo interesante: cuando actualizamos la versión de un `Pod` con el `Deployment`, este crea un nuevo `ReplicaSet` para gestionar las réplicas de los `Pods`. Una vez que la actualización termina, el `Deployment` elimina las réplicas del `ReplicaSet` antiguo y solo deja las réplicas del nuevo `ReplicaSet`.

Sin embargo, no se elimina el `ReplicaSet` antiguo; se mantiene allí, ya que puede usarse para hacer un `Rollback` de la versión del `Pod` en caso de problemas. Sí, cuando necesitamos hacer un `Rollback` de una actualización en nuestros `Pods`, el `Deployment` simplemente cambia el `ReplicaSet` que se utiliza para gestionar las réplicas de los `Pods`, utilizando el `ReplicaSet` antiguo.

¿Lo hacemos en la práctica?

Creo que te ayudará a entenderlo mejor.

#### El Deployment y el ReplicaSet

Crearemos un `Deployment` con el nombre de `nginx-deployment` y crearemos 3 réplicas del `Pod` de `nginx`.

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

Verifiquemos si se ha creado el `Deployment`.

```bash
kubectl get deployments
```

&nbsp;

Nuestra salida se verá similar a esto.

```bash
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           7s
```

&nbsp;

¡Simple, ya lo sabíamos! ¡Jeferson, quiero saber sobre el `ReplicaSet`!

Calma, porque nuestro querido `Deployment` ya ha creado el `ReplicaSet` por nosotros.

Verifiquemos el `ReplicaSet` que se ha creado.

```bash
kubectl get replicasets
```

Nuestra salida se verá similar a esto.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   1         1         1       37s
```

&nbsp;

Un detalle importante en la salida anterior es que el `ReplicaSet` tiene el mismo nombre que el `Deployment`, seguido de un sufijo aleatorio. Además, en esta salida podemos ver que el `ReplicaSet` actualmente tiene 1 réplica del `Pod` de `nginx` en ejecución, según lo que definimos en el `Deployment`.

Aumentemos el número de réplicas del `Pod` de `nginx` a 3.

```bash
kubectl scale deployment nginx-deployment --replicas=3
```

&nbsp;

Esta es una forma de aumentar el número de réplicas del `Pod` de `nginx` sin necesidad de editar el `Deployment`. Sin embargo, no lo recomiendo; prefiero editar el `Deployment` y luego aplicar los cambios nuevamente. Esto es una cuestión de preferencia y organización. Personalmente, no me gusta la idea de tener que usar `scale` en el `Deployment` para aumentar o disminuir el número de réplicas del `Pod` de `nginx`, sin tener ese cambio registrado en `git`, por ejemplo.

Modifiquemos el `Deployment` para tener 3 réplicas.

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

¡Listo! Ahora conoces las dos opciones para aumentar el número de réplicas del `Pod` de `nginx`. Siéntete libre de elegir la opción que te parezca mejor.

Yo continuaré usando la opción de editar el `Deployment` y luego aplicar los cambios.

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

Verifiquemos nuevamente nuestro `ReplicaSet`.

```bash
kubectl get replicasets
```

&nbsp;

Nuestra salida será similar a esta.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   3         3         3       5m24s
```

&nbsp;

Observe que el nombre del `ReplicaSet` sigue siendo el mismo, pero el número de réplicas cambió a 3. Cuando solo modificamos el número de réplicas en nuestro `Deployment`, el `ReplicaSet` permanece igual, ya que su función principal es administrar las réplicas del `Pod` de `nginx`.

Ahora cambiemos la versión de `nginx` a la 1.19.2.

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

Aplicaremos los cambios.

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

¡Listo! Ahora el `Deployment` está utilizando la versión 1.19.2 de `nginx`.

Vamos verificar nuevamente nuestro `ReplicaSet`.

```bash
kubectl get replicasets
```

&nbsp;

Tendremos la siguiente salida.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   0         0         0       8m53s
nginx-deployment-7858bcf56f   1         1         1       13s
```

&nbsp;

Ahora sí, tenemos un nuevo `ReplicaSet` con el nombre `nginx-deployment-7858bcf56f`, y el antiguo `ReplicaSet` con el nombre `nginx-deployment-6dd8d7cfbd` ha sido vaciado, ya que ya no forma parte del `Deployment`, pero permanece en el clúster, ya que puede usarse para hacer un rollback a la versión anterior de `nginx`.

Vamos a ver un detalle interesante en nuestro `Deployment`.

```bash
kubectl describe deployment nginx-deployment
```

&nbsp;

Observa la línea relacionada con el `ReplicaSet` que está siendo gestionado por el `Deployment`.

```bash
NewReplicaSet:   nginx-deployment-7858bcf56f (3/3 replicas created)
```

&nbsp;

Sí, en la salida de `describe` podemos ver que el `Deployment` está gestionando el `ReplicaSet` con el nombre `nginx-deployment-7858bcf56f` y que tiene 3 réplicas del `Pod` de `nginx` en ejecución.

Si deseas hacer el rollback a la versión anterior de `nginx`, simplemente sigue los pasos que ya vimos anteriormente.

```bash
kubectl rollout undo deployment nginx-deployment
```

&nbsp;

Con esto se realizará el rollback a la versión anterior de `nginx` y el `ReplicaSet` con el nombre `nginx-deployment-7858bcf56f` se vaciará, mientras que el `ReplicaSet` con el nombre `nginx-deployment-6dd8d7cfbd` se llenará nuevamente con 3 réplicas del `Pod` de `nginx`.

Volvamos a listar nuestros `ReplicaSets`.

```bash
kubectl get replicasets
```

&nbsp;

Lo que tenemos ahora es esto.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   3         3         3       15m
nginx-deployment-7858bcf56f   0         0         0       6m28s
```

&nbsp;

Y si volvemos a observar el `Deployment`.

```bash
kubectl describe deployment nginx-deployment
```

&nbsp;

Tendremos la siguiente salida.

```bash
NewReplicaSet:   nginx-deployment-6dd8d7cfbd (3/3 replicas created)
```

&nbsp;

¡Realmente es bastante simple, verdad?

Ahora ya sabes cómo gestionar las réplicas del `Pod` de `nginx` usando el `Deployment` y, por consiguiente, el `ReplicaSet`.

&nbsp;

#### Creando un ReplicaSet

Como se mencionó anteriormente, es posible crear un `ReplicaSet` sin usar un `Deployment`, aunque insisto, no lo hagas, ya que el `Deployment` es la forma más fácil de gestionar los `ReplicaSets` y la salud de los `Pods`.

Pero adelante, si deseas crear un `ReplicaSet` sin utilizar un `Deployment`, simplemente sigue estos pasos.

Para nuestro ejemplo, crearemos un archivo llamado `nginx-replicaset.yaml` y colocaremos el siguiente contenido:

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

Antes de aplicar nuestro manifiesto, comprendamos lo que estamos haciendo.
Si observas el archivo, no hay nada nuevo, es decir, nada que no hayas aprendido hasta ahora. La principal diferencia es que ahora estamos usando `kind: ReplicaSet` en lugar de `kind: Deployment`, e incluso la `APIVersion` es la misma.

Ahora apliquemos nuestro manifiesto.

```bash
kubectl apply -f nginx-replicaset.yaml
```

&nbsp;

La salida será la siguiente.

```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-6dd8d7cfbd   3         3         3       21m
nginx-deployment-7858bcf56f   0         0         0       12m
nginx-replicaset              3         3         3       6s
```

&nbsp;

Ahora tenemos 3 `ReplicaSets` siendo gestionados por Kubernetes, de los cuales 2 están siendo gestionados por el `Deployment` y el otro es el que acabamos de crear.

Veamos la lista de los `Pods` en ejecución.

```bash
kubectl get pods
```

&nbsp;

Todo funcionando mágicamente, ¿verdad?

Ahora hagamos una prueba, cambiemos la versión de `nginx` a la versión 1.19.3. Para ello, editaremos el archivo `nginx-replicaset.yaml` y cambiaremos la versión de `nginx` a la 1.19.3.

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

Listo, ahora vamos a aplicar los cambios.

```bash
kubectl apply -f nginx-replicaset.yaml
```

&nbsp;

Vamos a listar los `Pods` nuevamente.

```bash
kubectl get pods
```

&nbsp;

Observe que no ocurrió nada, es decir, el `ReplicaSet` no realizó el rollout de la nueva versión de `nginx`. Esto sucede porque el `ReplicaSet` no gestiona las versiones, solo se asegura de que el número de réplicas del `Pod` esté siempre activo.

Si observas los detalles del `ReplicaSet`, verás que está gestionando 3 réplicas del `Pod` y que la imagen de `nginx` es la versión 1.19.3, sin embargo, no recreó los `Pods` con la nueva versión de `nginx`, lo hará solo si eliminas manualmente los `Pods` o si el `Pod` muere por alguna razón.

```bash
kubectl describe replicaset nginx-replicaset
```

&nbsp;

Ahora vamos a eliminar uno de los `Pods` para que el `ReplicaSet` cree un nuevo `Pod` con la nueva versión de `nginx`.

```bash
kubectl delete pod nginx-replicaset-8r6md
```

&nbsp;

Ahora el `ReplicaSet` creará un nuevo `Pod` con la nueva versión de `nginx`, lo que nos generará un problema, ya que ahora tendremos dos versiones de `nginx` ejecutándose en nuestro clúster.

```bash
kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\t"}{end}{end}'
```

&nbsp;

Esta es una forma de listar los `Pods` y las imágenes que están utilizando, sé que es bastante extraño, pero explicaré lo que está sucediendo.

- `kubectl get pods`: este comando lista todos los Pods en el clúster.

- `-o=jsonpath`: este parámetro especifica que queremos usar la salida en formato JSONPath para mostrar la información de los Pods.

- `'{range .items[*]}{"\n"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\t"}{end}{end}'`: esta es la expresión JSONPath que define el formato de salida del comando. Utiliza la función range para iterar sobre todos los objetos `items` (es decir, los Pods) devueltos por el comando `kubectl get pods`. Luego muestra el nombre del Pod `({.metadata.name})` seguido de un tabulador `(\t)`, e itera sobre todos los contenedores `({range .spec.containers[*]})` dentro del Pod, mostrando la imagen utilizada por cada uno `({.image})`. Finalmente, agrega un salto de línea `(\n)` y cierra el segundo rango con `{end}{end}`.

Sí, lo sé, sigue siendo confuso.

Pero te contaré un secreto, con el tiempo y utilizando esto repetidamente, las cosas empiezan a volverse más fáciles, ¡así que no te rindas! ¡Hacia adelante, ni para tomar impulso!

Aún hablaremos con más detalles sobre cómo usar `metadata` para tener una salida más amigable y precisa.

#### Desactivando el ReplicaSet

Para eliminar el `ReplicaSet` y todos los `Pods` que está gestionando, simplemente ejecuta el siguiente comando.

```bash
kubectl delete replicaset nginx-replicaset
```

&nbsp;

Si deseas hacerlo utilizando el archivo de manifiesto, ejecuta el siguiente comando.

```bash
kubectl delete -f nginx-replicaset.yaml
```

&nbsp;

Listo, se ha eliminado nuestro `ReplicaSet` y todos los `Pods` que estaba gestionando.

A lo largo de nuestra sesión, ya hemos aprendido cómo crear un `ReplicaSet` y cómo funciona, pero aún hay mucho más que aprender, así que continuemos.

&nbsp;

### El DaemonSet

Ya sabemos qué es un `Pod`, un `Deployment` y un `ReplicaSet`, pero ahora es el momento de conocer otro objeto en Kubernetes: el `DaemonSet`.

El `DaemonSet` es un objeto que garantiza que todos los nodos en el clúster ejecuten una réplica de un `Pod`. En otras palabras, asegura que todos los nodos del clúster tengan una copia del mismo `Pod`.

El `DaemonSet` es muy útil para ejecutar `Pods` que deben ejecutarse en todos los nodos del clúster, como por ejemplo, un `Pod` que realiza el monitoreo de registros o un `Pod` que realiza el monitoreo de métricas.

Algunos casos de uso comunes de los `DaemonSets` son:

- Ejecutar agentes de monitoreo, como el `Prometheus Node Exporter` o `Fluentd`.
- Ejecutar un proxy de red en todos los nodos del clúster, como `kube-proxy`, `Weave Net`, `Calico` o `Flannel`.
- Ejecutar agentes de seguridad en cada nodo del clúster, como `Falco` o `Sysdig`.

Por lo tanto, si nuestro clúster tiene 3 nodos, el `DaemonSet` garantizará que todos los nodos ejecuten una réplica del `Pod` que está gestionando, es decir, 3 réplicas del `Pod`.

Si agregamos otro nodo al clúster, el `DaemonSet` garantizará que todos los nodos ejecuten una réplica del `Pod` que está gestionando, es decir, 4 réplicas del `Pod`.

#### Creando un DaemonSet

Vamos con nuestro primer ejemplo, vamos a crear un `DaemonSet` que asegurará que todos los nodos del clúster ejecuten una réplica del `Pod` del `node-exporter`, que es un exportador de métricas para `Prometheus`.

Para lograrlo, vamos a crear un archivo llamado `node-exporter-daemonset.yaml` y agregar el siguiente contenido.

```yaml
apiVersion: apps/v1 # Versión de la API de Kubernetes del objeto
kind: DaemonSet # Tipo de objeto
metadata: # Información sobre el objeto
  name: node-exporter # Nombre del objeto
spec: # Especificación del objeto
  selector: # Selector del objeto
    matchLabels: # Etiquetas que se usarán para seleccionar los Pods
      app: node-exporter # Etiqueta que se usará para seleccionar los Pods
  template: # Plantilla del objeto
    metadata: # Información sobre el objeto
      labels: # Etiquetas que se agregarán a los Pods
        app: node-exporter # Etiqueta que se agregará a los Pods
    spec: # Especificación del objeto, en este caso, la especificación del Pod
      hostNetwork: true # Habilita el uso de la red del host, usar con precaución
      containers: # Lista de contenedores que se ejecutarán en el Pod
      - name: node-exporter # Nombre del contenedor
        image: prom/node-exporter:latest # Imagen del contenedor
        ports: # Lista de puertos que se expondrán en el contenedor
        - containerPort: 9100 # Puerto que se expondrá en el contenedor
          hostPort: 9100 # Puerto que se expondrá en el host
        volumeMounts: # Lista de puntos de montaje de volúmenes en el contenedor, ya que node-exporter necesita acceso a /proc y /sys
        - name: proc # Nombre del volumen
          mountPath: /host/proc # Ruta donde se montará el volumen en el contenedor
          readOnly: true # Habilita el modo de solo lectura
        - name: sys # Nombre del volumen
          mountPath: /host/sys # Ruta donde se montará el volumen en el contenedor
          readOnly: true # Habilita el modo de solo lectura
      volumes: # Lista de volúmenes que se utilizarán en el Pod
      - name: proc # Nombre del volumen
        hostPath: # Tipo de volumen
          path: /proc # Ruta del volumen en el host
      - name: sys # Nombre del volumen
        hostPath: # Tipo de volumen
          path: /sys # Ruta del volumen en el host
```

&nbsp;

He dejado el archivo comentado para facilitar la comprensión, ahora vamos a crear el `DaemonSet` utilizando el archivo de manifiesto.

```bash
kubectl apply -f node-exporter-daemonset.yaml
```

&nbsp;

Ahora verifiquemos si el `DaemonSet` se ha creado.

```bash
kubectl get daemonset
```

&nbsp;

Como podemos ver, el `DaemonSet` se ha creado exitosamente.

```bash
NAME            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
node-exporter   2         2         2       2            2           <none>          5m24s
```

&nbsp;

Si deseamos verificar los `Pods` que el `DaemonSet` está gestionando, solo ejecutamos el siguiente comando.

```bash
kubectl get pods -l app=node-exporter
```

&nbsp;

Solo para recordar, estamos utilizando el parámetro `-l` para filtrar los `Pods` que tienen la etiqueta `app=node-exporter`, que es el caso de nuestro `DaemonSet`.

Como podemos ver, el `DaemonSet` está gestionando 2 `Pods`, uno en cada nodo del clúster.

```bash
NAME                  READY   STATUS    RESTARTS   AGE
node-exporter-k8wp9   1/1     Running   0          6m14s
node-exporter-q8zvw   1/1     Running   0          6m14s
```

&nbsp;

Nuestros `Pods` de `node-exporter` se han creado con éxito, ahora verifiquemos si se están ejecutando en todos los nodos del clúster.

```bash
kubectl get pods -o wide -l app=node-exporter
```

&nbsp;

Con el comando anterior, podemos ver en qué nodo se está ejecutando cada `Pod`.

```bash
NAME                                READY   STATUS    RESTARTS   AGE     IP               NODE                            NOMINATED NODE   READINESS GATES
node-exporter-k8wp9                 1/1     Running   0          3m49s   192.168.8.145    ip-192-168-8-145.ec2.internal   <none>           <none>
node-exporter-q8zvw                 1/1     Running   0          3m49s   192.168.55.68    ip-192-168-55-68.ec2.internal   <none>           <none>
```

&nbsp;

Como podemos ver, los `Pods` de `node-exporter` se están ejecutando en ambos nodos del clúster.

Para ver los detalles del `DaemonSet`, solo ejecutamos el siguiente comando.

```bash
kubectl describe daemonset node-exporter
```

&nbsp;

El comando anterior devolverá una salida similar a la siguiente.

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

En la salida anterior, podemos ver información muy importante relacionada con el `DaemonSet`, como por ejemplo, el número de nodos que el `DaemonSet` está gestionando, el número de `Pods` que se están ejecutando en cada nodo, etc.

#### Creación de un DaemonSet utilizando el comando kubectl create

Aún puedes crear un `DaemonSet` utilizando el comando `kubectl create`, pero prefiero usar el archivo de manifiesto, ya que así puedo versionar mi `DaemonSet`. Sin embargo, si deseas crear un `DaemonSet` utilizando el comando `kubectl create`, simplemente ejecuta el siguiente comando.

```bash
kubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100
```

&nbsp;

En el comando anterior, faltan algunos parámetros, pero los dejé así para facilitar la comprensión. Si deseas ver todos los parámetros que se pueden usar en el comando `kubectl create daemonset`, simplemente ejecuta el siguiente comando.

```bash
kubectl create daemonset --help
```

&nbsp;

A mí me gusta usar `kubectl create` solo para crear un archivo de ejemplo, para que pueda basarme en él al crear mi archivo de manifiesto. Sin embargo, si deseas crear un manifiesto para un `DaemonSet` utilizando el comando `kubectl create`, simplemente ejecuta el siguiente comando.

```bash
kubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100 -o yaml --dry-run=client > node-exporter-daemonset.yaml
```

&nbsp;

¡Así de simple! Te explicaré lo que está sucediendo en el comando anterior.

- `kubectl create daemonset node-exporter` - Crea un `DaemonSet` llamado `node-exporter`.
- `--image=prom/node-exporter:latest` - Utiliza la imagen `prom/node-exporter:latest` para crear los `Pods`.
- `--port=9100` - Define el puerto `9100` para el `Pod`.
- `--host-port=9100` - Define el puerto `9100` para el nodo.
- `-o yaml` - Define el formato del archivo de manifiesto como `yaml`.
- `--dry-run=client` - Ejecuta el comando sin crear el `DaemonSet`, solo simula la creación del `DaemonSet`.
- `> node-exporter-daemonset.yaml` - Redirige la salida del comando al archivo `node-exporter-daemonset.yaml`.

¡Más sencillo, ¿verdad?

#### Añadiendo un nodo al clúster

Ahora que ya sabemos cómo crear un `DaemonSet`, vamos a aumentar el número de nodos en nuestro clúster.

Actualmente tenemos dos réplicas.

```bash
kubectl get nodes
```

&nbsp;

```bash
NAME                             STATUS   ROLES    AGE    VERSION
ip-192-168-55-68.ec2.internal    Ready    <ninguno>   113m   v1.23.16-eks-48e63af
ip-192-168-8-145.ec2.internal    Ready    <ninguno>   113m   v1.23.16-eks-48e63af
```

&nbsp;

Vamos a aumentar el número de nodos a 3.

Estoy utilizando `eksctl` para crear el clúster, por lo que utilizaré el comando `eksctl scale nodegroup` para aumentar el número de nodos en el clúster. Si estás utilizando otro administrador de clúster, puedes usar el comando que prefieras para aumentar el número de nodos en el clúster.

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

Verifiquemos si el nodo ha sido agregado al clúster.

```bash
kubectl get nodes
```

&nbsp;

```bash
NAME                             STATUS   ROLES    AGE    VERSION
ip-192-168-45-194.ec2.internal   Ready    <ninguno>   47s    v1.23.16-eks-48e63af
ip-192-168-55-68.ec2.internal    Ready    <ninguno>   113m   v1.23.16-eks-48e63af
ip-192-168-8-145.ec2.internal    Ready    <ninguno>   113m   v1.23.16-eks-48e63af
```

&nbsp;

Listo, ahora tenemos 3 nodos en el clúster.

Pero la pregunta que no quiere callar es: ¿El `DaemonSet` ha creado un `Pod` en el nuevo nodo?

Vamos a verificarlo.

```bash
kubectl get pods -o wide -l app=node-exporter
```

&nbsp;

```bash
NAME                  READY   STATUS    RESTARTS   AGE   IP               NODE                             NOMINATED NODE   READINESS GATES
node-exporter-k8wp9   1/1     Running   0          20m   192.168.8.145    ip-192-168-8-145.ec2.internal    <ninguno>           <ninguno>
node-exporter-q8zvw   1/1     Running   0          20m   192.168.55.68    ip-192-168-55-68.ec2.internal    <ninguno>           <ninguno>
node-exporter-xffgq   1/1     Running   0          70s   192.168.45.194   ip-192-168-45-194.ec2.internal   <ninguno>           <ninguno>
```

&nbsp;

Parece que tenemos un nuevo `Pod` en el nodo `ip-192-168-45-194.ec2.internal`, pero verifiquemos si el `DaemonSet` está gestionando ese nodo.

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

Todo está en paz y armonía, el `DaemonSet` está gestionando el nuevo `Pod` en el nuevo `nodo`. Y, por supuesto, si por alguna razón el `Pod` se cae, el `DaemonSet` creará un nuevo `Pod` en el mismo `nodo`. Y, por supuesto, en la versión 2, si la cantidad de nodos disminuye, el `DaemonSet` eliminará los `Pods` en exceso. Y hablando de eso, déjame disminuir el número de nodos en el clúster para ahorrar algunos Dólares/Euros.

```bash
eksctl scale nodegroup --cluster=eks-cluster --nodes 2 --name eks-cluster-nodegroup
```

&nbsp;

#### Eliminando un DaemonSet

Para eliminar un `DaemonSet` es muy sencillo, simplemente ejecuta el comando `kubectl delete daemonset <nombre-del-daemonset>`.

```bash
kubectl delete daemonset node-exporter
```

&nbsp;

```bash
daemonset.apps "node-exporter" eliminado
```

&nbsp;

O también puedes eliminar el `DaemonSet` a través del manifiesto.

```bash
kubectl delete -f node-exporter-daemonset.yaml
```

&nbsp;

¡Así de simple!

Creo que el tema del `DaemonSet` ya está bastante claro. Aún veremos todos estos objetos que hemos aprendido hasta ahora varias veces a lo largo de nuestro recorrido, así que no te preocupes, practicaremos mucho más.

&nbsp;

### Las sondas de Kubernetes

Antes de continuar, quería presentarte algo nuevo además de los dos nuevos objetos que ya has aprendido hoy. Quería que terminaras este día sintiéndote seguro de que eres capaz de crear un `Pod`, un `Deployment`, un `ReplicaSet` o un `DaemonSet`, pero también de que puedes supervisar tus aplicaciones que se ejecutan dentro del clúster de manera efectiva y utilizando los recursos que Kubernetes ya nos proporciona.

#### ¿Qué son las sondas?

Las sondas son una forma de supervisar tu `Pod` y saber si está en un estado saludable o no. Con ellas, puedes asegurarte de que tus `Pods` se están ejecutando y respondiendo de manera correcta, y lo que es más importante, que Kubernetes está evaluando lo que se está ejecutando dentro de tu `Pod`.

Hoy en día, tenemos disponibles tres tipos de sondas: `livenessProbe`, `readinessProbe` y `startupProbe`. Vamos a explorar en detalle cada una de ellas.

#### Sonda de Integridad (Liveness Probe)

La `livenessProbe` es nuestra sonda de verificación de integridad, lo que hace es comprobar si lo que se está ejecutando dentro del `Pod` está saludable. Creamos una forma de probar si lo que tenemos dentro del `Pod` está respondiendo como se espera. Si la prueba falla, el `Pod` se reiniciará.

Para que quede más claro, utilizaremos nuevamente el ejemplo con `Nginx`. Me gusta usar `Nginx` como ejemplo porque sé que todos lo conocen, y así es mucho más fácil entender lo que está sucediendo. Después de todo, estás aquí para aprender Kubernetes, y si es con algo que ya conoces, es mucho más fácil de entender.

Bueno, vamos allá. Es hora de crear un nuevo `Deployment` con `Nginx`. Utilizaremos el ejemplo que ya utilizamos cuando aprendimos sobre `Deployment`.

Para ello, crea un archivo llamado `nginx-liveness.yaml` y pega el siguiente contenido.

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
        livenessProbe: # Aquí es donde agregaremos nuestra livenessProbe
          tcpSocket: # Aquí usaremos tcpSocket para conectarnos al contenedor a través del protocolo TCP
            port: 80 # Puerto TCP al que nos conectaremos en el contenedor
          initialDelaySeconds: 10 # Cuántos segundos esperaremos antes de realizar la primera verificación
          periodSeconds: 10 # Cada cuántos segundos realizaremos la verificación
          timeoutSeconds: 5 # Cuántos segundos esperaremos antes de considerar que la verificación ha fallado
          failureThreshold: 3 # Cuántos fallos consecutivos aceptaremos antes de reiniciar el contenedor
```

&nbsp;

Con esto tenemos algunas novedades, y solo utilizamos una sonda, que es la `livenessProbe`.

Lo que declaramos con la regla anterior es que queremos probar si el `Pod` está respondiendo a través del protocolo TCP, utilizando la opción `tcpSocket`, en el puerto 80 que se definió mediante la opción `port`. También hemos definido que queremos esperar 10 segundos para realizar la primera verificación utilizando `initialDelaySeconds`, y debido a `periodSeconds`, queremos que se realice la verificación cada 10 segundos. Si la verificación falla, esperaremos 5 segundos, debido a `timeoutSeconds`, para volver a intentarlo, y como usamos `failureThreshold`, si falla 3 veces seguidas, reiniciaremos el `Pod`.

¿Quedó más claro? Sigamos con otro ejemplo.

Digamos que ya no queremos utilizar `tcpSocket`, sino `httpGet` para intentar acceder a un endpoint dentro de nuestro `Pod`.

Para ello, modifiquemos nuestro `nginx-deployment.yaml` de la siguiente manera.

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
        livenessProbe: # Aquí es donde agregaremos nuestra livenessProbe
          httpGet: # Aquí usaremos httpGet para conectarnos al contenedor a través del protocolo HTTP
            path: / # Endpoint que usaremos para conectarnos al contenedor
            port: 80 # Puerto TCP al que nos conectaremos en el contenedor
          initialDelaySeconds: 10 # Cuántos segundos esperaremos antes de realizar la primera verificación
          periodSeconds: 10 # Cada cuántos segundos realizaremos la verificación
          timeoutSeconds: 5 # Cuántos segundos esperaremos antes de considerar que la verificación ha fallado
          failureThreshold: 3 # Cuántos fallos consecutivos aceptaremos antes de reiniciar el contenedor
```

&nbsp;

Observa que ahora hemos cambiado algunas cosas, aunque mantenemos el mismo objetivo: verificar si `Nginx` está respondiendo correctamente. Cambiamos la forma en que lo probamos. Ahora estamos usando `httpGet` para verificar si `Nginx` responde correctamente a través del protocolo HTTP, y para eso, usamos el endpoint `/` y el puerto 80.

Lo nuevo aquí es la opción `path`, que es el endpoint que usaremos para verificar si `Nginx` responde correctamente, y, por supuesto, `httpGet` es la forma en que realizamos nuestra prueba, utilizando el protocolo HTTP.

&nbsp;

Elige cuál de los dos ejemplos prefieres y crea tu `Deployment` con el siguiente comando.

```bash
kubectl apply -f nginx-deployment.yaml
```

&nbsp;

Para verificar si el `Deployment` se creó correctamente, ejecuta el siguiente comando.

```bash
kubectl get deployments
```

&nbsp;

Deberías ver algo similar a esto.

```bash
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-7557d7fc6c-dx48d   1/1     Running   0          14s
nginx-deployment-7557d7fc6c-tbk4w   1/1     Running   0          12s
nginx-deployment-7557d7fc6c-wv876   1/1     Running   0          16s
```

&nbsp;

Para obtener más detalles sobre tu `Pod` y verificar si nuestra sonda está funcionando correctamente, usa el siguiente comando.

```bash
kubectl describe pod nginx-deployment-7557d7fc6c-dx48d
```

&nbsp;

La salida debería ser similar a esta.

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

Aquí tenemos la información más importante para nosotros en este momento:

```bash
    Liveness:     http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=3
```

&nbsp;

La salida de arriba es parte de la salida del comando `kubectl describe pod`. Todo está funcionando maravillosamente bien.

Ahora, hagamos lo siguiente: cambiemos nuestro `Deployment` para que nuestra sonda falle. Para ello, vamos a cambiar el `endpoint` que estamos usando. Cambiaremos el `path` a `/giropops`.

&nbsp;

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
        livenessProbe: # Aquí es donde vamos a agregar nuestra sonda de integridad (`livenessProbe`).
          httpGet: # Aquí vamos a utilizar `httpGet`, donde nos conectaremos al contenedor a través del protocolo HTTP.
            path: /giropops # ¿Qué `endpoint` vamos a utilizar para conectarnos al contenedor?
            port: 80 # ¿Qué puerto TCP vamos a utilizar para conectarnos al contenedor?
          initialDelaySeconds: 10 # ¿Cuántos segundos vamos a esperar para realizar la primera verificación?
          periodSeconds: 10 # ¿Cada cuántos segundos vamos a ejecutar la verificación?
          timeoutSeconds: 5 # ¿Cuántos segundos vamos a esperar antes de considerar que la verificación ha fallado?
          failureThreshold: 3 # ¿Cuántas fallas consecutivas vamos a permitir antes de reiniciar el contenedor?
```

&nbsp;

Vamos aplicar los cambios en nuestro `Deployment`:

```bash
kubectl apply -f deployment.yaml
```

&nbsp;

Después de un tiempo, notarás que Kubernetes ha finalizado la actualización de nuestro `Deployment`.
Si esperas un poco más, te darás cuenta de que los `Pods` se están reiniciando con frecuencia.

Todo esto se debe a que nuestra `livenessProbe` está fallando, ya que el `endpoint` está incorrecto.

Podemos ver más detalles sobre lo que está ocurriendo en la salida del comando `kubectl describe pod`:

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

En la última parte de la salida del comando `kubectl describe pod`, puedes observar que Kubernetes está intentando ejecutar nuestra `livenessProbe` y está fallando. Incluso muestra cuántas veces ha intentado ejecutar la `livenessProbe` y ha fallado, lo que resultó en la reinicialización de nuestro `Pod`.

Creo que ahora está más claro cómo funciona la `livenessProbe`. Ahora es el momento de pasar a la siguiente sonda, la `readinessProbe`.

#### Sonda de preparación (Readiness Probe)

La `readinessProbe` es una forma en que Kubernetes verifica si su contenedor está listo para recibir tráfico, es decir, si está preparado para recibir solicitudes externas.

Esta es nuestra sonda de lectura, que comprueba si nuestro contenedor está listo para recibir solicitudes. Si está listo, aceptará solicitudes; de lo contrario, no las aceptará y se eliminará de la dirección del servicio. Esto impide que el tráfico llegue a él.

Aunque aún veremos qué son los `service` y `endpoint`, por ahora basta con saber que el `endpoint` es la dirección que nuestro `service` usará para acceder a nuestro `Pod`. Sin embargo, dedicaremos todo un día a hablar sobre `service` y `endpoint`, así que por ahora, relájate.

Retomando el tema, nuestra sonda actual garantizará que nuestro `Pod` esté en condiciones de recibir solicitudes.

Vamos a un ejemplo para aclarar esto. Para ello, crearemos un archivo llamado `nginx-readiness.yaml` y agregaremos el siguiente contenido:

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
        readinessProbe: # Donde definimos nuestra sonda de preparación
          httpGet: # El tipo de prueba que vamos a ejecutar, en este caso, una prueba HTTP
            path: / # La ruta que vamos a probar
            port: 80 # El puerto que vamos a probar
          initialDelaySeconds: 10 # El tiempo que esperaremos antes de ejecutar la sonda por primera vez
          periodSeconds: 10 # Cada cuánto tiempo vamos a ejecutar la sonda
          timeoutSeconds: 5 # Cuánto tiempo esperaremos antes de considerar que la sonda ha fallado
          successThreshold: 2 # Cuántas veces la sonda debe pasar para considerar que el contenedor está listo
          failureThreshold: 3 # Cuántas veces la sonda debe pasar para considerar que el contenedor NO está listo
```

&nbsp;

Vamos a verificar si nuestros `Pods` están en funcionamiento:

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

Podemos observar que ahora los `Pods` tardan un poco más en estar listos, ya que estamos ejecutando nuestra `readinessProbe`, y por esta razón debemos esperar los 10 segundos iniciales que definimos para que se ejecute la prueba por primera vez, ¿recuerdas?

Si esperas un momento, verás que los `Pods` estarán listos, y puedes comprobarlo ejecutando el comando:

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

Listo, como por arte de magia, ahora nuestros `Pods` están listos para recibir solicitudes.

Echemos un vistazo a la descripción de nuestro `Pod`:

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

Listo, nuestra sonda está ahí y funcionando, y con esto podemos asegurarnos de que nuestros `Pods` estén listos para recibir solicitudes.

Vamos a cambiar nuestro `path` a `/giropops` y ver qué sucede:

```yaml
...
        readinessProbe: # Aquí es donde definimos nuestra sonda de lectura
          httpGet: # El tipo de prueba que vamos a realizar, en este caso, vamos a realizar una prueba HTTP
            path: /giropops # La ruta que vamos a probar
            port: 80 # El puerto que vamos a probar
          initialDelaySeconds: 10 # El tiempo que vamos a esperar para ejecutar la sonda por primera vez
          periodSeconds: 10 # Con qué frecuencia vamos a ejecutar la sonda
          timeoutSeconds: 5 # El tiempo que vamos a esperar para considerar que la sonda falló
          successThreshold: 2 # El número de veces que la sonda debe pasar para considerar que el contenedor está listo
          failureThreshold: 3 # El número de veces que la sonda debe fallar para considerar que el contenedor no está listo
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

Muy bien, ahora veamos el resultado de este lío:

```bash
kubectl get pods
```

En este punto, puedes ver que Kubernetes está intentando actualizar nuestro `Deployment`, pero no está teniendo éxito, ya que la sonda falló en el primer `Pod` que intentó actualizar.

```bash
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5fd6c688d8-kjf8d   0/1     Running   0          93s
nginx-deployment-fbdc9b65f-trnnz    1/1     Running   0          9m21s
nginx-deployment-fbdc9b65f-z8n4m    1/1     Running   0          9m21s
nginx-deployment-fbdc9b65f-zn8zh    1/1     Running   0          9m21s
```

&nbsp;

Vamos a verificar nuestro `rollout`:

```bash
kubectl rollout status deployment/nginx-deployment
```

```bash
Esperando a que el despliegue "nginx-deployment" termine: 1 de 3 nuevas réplicas han sido actualizadas...
```

Aun después de un tiempo, nuestro `rollout` no ha finalizado, sigue esperando a que la sonda pase.

Podemos ver los detalles del `Pod` con problema:

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

Solamente he pegado la parte final de la salida, que es la parte más interesante en este momento. Es en esta parte donde podemos ver que nuestro `Pod` no está saludable, y por lo tanto, Kubernetes no puede actualizar nuestro `Deployment`.

&nbsp;

#### Sonda de Inicio

Ha llegado el momento de hablar sobre la sonda de inicio (`startupProbe`), que en mi humilde opinión, es la menos utilizada pero muy importante.

Esta sonda es responsable de verificar si nuestro contenedor se ha iniciado correctamente y si está listo para recibir solicitudes.

Es bastante similar a la sonda de preparación (`readinessProbe`), pero la diferencia es que la sonda de inicio (`startupProbe`) se ejecuta solo una vez al comienzo de la vida de nuestro contenedor, mientras que la sonda de preparación (`readinessProbe`) se ejecuta periódicamente.

Para entenderlo mejor, veamos un ejemplo creando un archivo llamado `nginx-startup.yaml`:"

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
        startupProbe: # Donde definimos nuestra sonda de inicio
          httpGet: # El tipo de prueba que ejecutaremos, en este caso, ejecutaremos una prueba HTTP
            path: / # La ruta que probaremos
            port: 80 # El puerto que probaremos
          initialDelaySeconds: 10 # El tiempo que esperaremos para ejecutar la sonda por primera vez
          periodSeconds: 10 # Cada cuánto tiempo ejecutaremos la sonda
          timeoutSeconds: 5 # El tiempo que esperaremos para considerar que la sonda falló
          successThreshold: 2 # El número de veces que la sonda debe pasar para considerar que el contenedor está listo
          failureThreshold: 3 # El número de veces que la sonda debe fallar para considerar que el contenedor no está listo
```

&nbsp;

Vamos a aplicar nuestra configuración:

```bash
kubectl apply -f nginx-startup.yaml
```

Cuando intentes aplicarla, recibirás un error porque `successThreshold` no puede ser mayor que 1, ya que `startupProbe` se ejecuta solo una vez, ¿recuerdas?

De la misma manera, `failureThreshold` tampoco puede ser mayor que 1, así que vamos a modificar nuestro archivo a:

```yaml
...
        startupProbe: # Donde definimos nuestra sonda de inicio
          httpGet: # El tipo de prueba que ejecutaremos, en este caso, ejecutaremos una prueba HTTP
            path: / # La ruta que probaremos
            port: 80 # El puerto que probaremos
          initialDelaySeconds: 10 # El tiempo que esperaremos para ejecutar la sonda por primera vez
          periodSeconds: 10 # Cada cuánto tiempo ejecutaremos la sonda
          timeoutSeconds: 5 # El tiempo que esperaremos para considerar que la sonda falló
          successThreshold: 1 # El número de veces que la sonda debe pasar para considerar que el contenedor está listo
          failureThreshold: 1 # El número de veces que la sonda debe fallar para considerar que el contenedor no está listo
```

&nbsp;

Ahora aplicamos la configuración nuevamente:

```bash
kubectl apply -f nginx-startup.yaml
```

&nbsp;

Listo, ¡aplicado! ¡Uf! \o/

Observe que tu definición es muy similar a la `readinessProbe`, pero recuerda que solo se ejecutará una vez, cuando se inicie el contenedor. Por lo tanto, si algo sale mal después de eso, no te ayudará, ya que no se ejecutará de nuevo.

Por esta razón, es muy importante siempre tener una combinación de sondas, para tener un contenedor más resistente y poder detectar problemas más rápidamente.

Vamos a verificar si nuestros `Pods` están saludables:

```bash
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6fbd5f9794-66sww   1/1     Running   0          2m12s
nginx-deployment-6fbd5f9794-cmwq8   1/1     Running   0          2m12s
nginx-deployment-6fbd5f9794-kvrp8   1/1     Running   0          2m12s
```

&nbsp;

Si deseas verificar si nuestra sonda está presente, simplemente usa el siguiente comando:

```bash
kubectl describe pod nginx-deployment-6fbd5f9794-66sww
```

Verás algo similar a esto:

```bash
    Startup:      http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=1
```

### Ejemplo con todas las sondas

Vamos a nuestro ejemplo final de hoy, utilizaremos todas las sondas que hemos visto hasta ahora. Crearemos un archivo llamado `nginx-todas-probes.yaml`:

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
        livenessProbe: # Donde definimos nuestra sonda de vida
          exec: # El tipo exec se utiliza cuando queremos ejecutar algo dentro del contenedor.
            command: # Donde definiremos qué comando ejecutaremos
              - curl
              - -f
              - http://localhost:80/
          initialDelaySeconds: 10 # El tiempo que esperaremos para ejecutar la sonda por primera vez
          periodSeconds: 10 # Cada cuánto tiempo ejecutaremos la sonda
          timeoutSeconds: 5 # El tiempo que esperaremos para considerar que la sonda falló
          successThreshold: 1 # Cuántas veces debe pasar la sonda para considerar que el contenedor está listo
          failureThreshold: 3 # Cuántas veces debe fallar la sonda para considerar que el contenedor no está listo
        readinessProbe: # Donde definimos nuestra sonda de disponibilidad
          httpGet: # El tipo de prueba que ejecutaremos, en este caso, ejecutaremos una prueba HTTP
            path: / # La ruta que probaremos
            port: 80 # El puerto que probaremos
          initialDelaySeconds: 10 # El tiempo que esperaremos para ejecutar la sonda por primera vez
          periodSeconds: 10 # Cada cuánto tiempo ejecutaremos la sonda
          timeoutSeconds: 5 # El tiempo que esperaremos para considerar que la sonda falló
          successThreshold: 1 # Cuántas veces debe pasar la sonda para considerar que el contenedor está listo
          failureThreshold: 3 # Cuántas veces debe fallar la sonda para considerar que el contenedor no está listo
        startupProbe: # Donde definimos nuestra sonda de inicio
          tcpSocket: # El tipo de prueba que ejecutaremos, en este caso, ejecutaremos una prueba TCP
            port: 80 # El puerto que probaremos
          initialDelaySeconds: 10 # El tiempo que esperaremos para ejecutar la sonda por primera vez
          periodSeconds: 10 # Cada cuánto tiempo ejecutaremos la sonda
          timeoutSeconds: 5 # El tiempo que esperaremos para considerar que la sonda falló
          successThreshold: 1 # Cuántas veces debe pasar la sonda para considerar que el contenedor está listo
          failureThreshold: 3 # Cuántas veces debe fallar la sonda para considerar que el contenedor no está listo
```

Listo, estamos utilizando las tres sondas, vamos a aplicarlas:

```bash
kubectl apply -f nginx-todas-probes.yaml
```

Y veremos si nuestros `Pods` están saludables:

```bash
kubectl get pods
```

Revisa la salida del `describe pods` para ver si nuestras sondas están presentes:

```bash
...
    Liveness:     exec [curl -f http://localhost:80/] delay=10s timeout=5s period=10s #success=1 #failure=3
    Readiness:    http-get http://:80/ delay=10s timeout=5s period=10s #success=1 #failure=3
    Startup:      tcp-socket :80 delay=10s timeout=5s period=10s #success=1 #failure=3
```

¡Todas están ahí! ¡Maravilloso!

Ahora podemos decir que sabemos cómo cuidar bien de nuestros `Pods`, mantenerlos siempre saludables y bajo control.

No olvides consultar la documentación oficial de Kubernetes para obtener más información sobre las sondas y, por supuesto, si tienes alguna pregunta, no dudes en preguntar.

### Tu tarea

Tu tarea es practicar todo lo que has aprendido hasta ahora. Lo más importante es replicar todo el contenido que se ha presentado hasta ahora para que puedas afianzarlo y, lo más importante, interiorizarlo.

Crea tus propios ejemplos, lee la documentación, haz preguntas y, por supuesto, si tienes alguna pregunta, no dudes en preguntar.

Todo lo que crees a partir de ahora debería tener sondas definidas para garantizar el buen funcionamiento de tu clúster.

Sin olvidar que es inadmisible tener un clúster de Kubernetes con tus `pods` en ejecución sin sondas configuradas adecuadamente, así como límites de recursos.

¡Eso es todo, así de simple! :D

### Final del Día 4

Durante el Día 4, aprendiste todo sobre `ReplicaSet` y `DaemonSet`. Hoy fue importante para entender que un clúster de Kubernetes es mucho más que un conjunto de `Pods` ejecutándose en un grupo de nodos. Y aún estamos al principio de nuestra jornada, todavía veremos muchos, quizás decenas de objetos que nos ayudarán a administrar nuestro clúster de manera más efectiva.

Hoy también aprendiste cómo garantizar pruebas en tus contenedores, ya sea en el momento del inicio o durante la ejecución, para que nuestras aplicaciones sean más estables y confiables."
