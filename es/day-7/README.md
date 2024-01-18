# Simplificando Kubernetes

## Día 7

&nbsp;

## Contenido del Día 7

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 7](#día-7)
  - [Contenido del Día 7](#contenido-del-día-7)
  - [Inicio de la Lección del Día 7](#inicio-de-la-lección-del-día-7)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
      - [¿Qué es un StatefulSet?](#qué-es-un-statefulset)
        - [¿Cuándo usar StatefulSets?](#cuándo-usar-statefulsets)
        - [¿Y cómo funcionan?](#y-cómo-funcionan)
        - [El StatefulSet y los volúmenes persistentes](#el-statefulset-y-los-volúmenes-persistentes)
        - [El StatefulSet y el Headless Service](#el-statefulset-y-el-headless-service)
        - [Creación de un StatefulSet](#creación-de-un-statefulset)
        - [Eliminando un StatefulSet](#eliminando-un-statefulset)
        - [Eliminando un Servicio Headless](#eliminando-un-servicio-headless)
        - [Eliminando un PVC](#eliminando-un-pvc)
      - [Servicios](#servicios)
        - [Tipos de Servicios](#tipos-de-servicios)
        - [Cómo funcionan los Servicios](#cómo-funcionan-los-servicios)
        - [Los Servicios y los Endpoints](#los-servicios-y-los-endpoints)
        - [Creando un Servicio](#creando-un-servicio)
          - [ClusterIP](#clusterip)
          - [NodePort](#nodeport)
          - [LoadBalancer](#loadbalancer)
          - [ExternalName](#externalname)
        - [Verificando los Services](#verificando-los-services)
        - [Verificando los Endpoints](#verificando-los-endpoints)
        - [Eliminando un Service](#eliminando-un-service)
    - [Tu tarea](#tu-tarea)

## Inicio de la Lección del Día 7

&nbsp;

### ¿Qué veremos hoy?

Hoy hablaremos sobre dos recursos muy importantes en Kubernetes: `StatefulSet` y `Service`.
Vamos a enseñarte cómo crear y administrar `StatefulSets` para que puedas desarrollar aplicaciones que necesiten mantener la identidad del `Pod` y persistir datos en volúmenes locales. Ejemplos comunes de uso de `StatefulSets` son bases de datos, sistemas de mensajería y sistemas de archivos distribuidos.

Otra pieza fundamental sobre la que hablaremos es el `Service`. El `Service` es un objeto que te permite exponer una aplicación al mundo exterior. Se encarga de balancear la carga entre los `Pods` expuestos y también de realizar la resolución de nombres DNS para los `Pods` expuestos.
Hay diversos tipos de `Services` sobre los que hablaremos hoy.

Así que prepárate para un viaje muy interesante acerca de estos dos recursos tan importantes para Kubernetes y para el día a día de aquellos que trabajan con él.

&nbsp;

#### ¿Qué es un StatefulSet?

Los `StatefulSets` son una funcionalidad de Kubernetes que gestiona la implementación y la escalabilidad de un conjunto de Pods, proporcionando garantías sobre el orden de implementación y la singularidad de estos Pods.

A diferencia de los `Deployments` y `Replicasets`, que se consideran sin estado (`stateless`), los `StatefulSets` se utilizan cuando se necesitan garantías adicionales sobre la implementación y la escalabilidad. Aseguran que los nombres y direcciones de los Pods sean consistentes y estables con el tiempo.

&nbsp;

##### ¿Cuándo usar StatefulSets?

Los `StatefulSets` son útiles para aplicaciones que requieran una o más de las siguientes características:

- Identidad de red estable y única.
- Almacenamiento persistente estable.
- Orden de implementación y escalabilidad garantizado.
- Orden de actualizaciones y regresiones garantizado.
- Algunas aplicaciones que cumplen con estos requisitos son bases de datos, sistemas de colas y cualquier aplicación que necesite persistencia de datos o identidad de red estable.

&nbsp;

##### ¿Y cómo funcionan?

Los `StatefulSets` funcionan creando una serie de Pods replicados. Cada réplica es una instancia de la misma aplicación creada a partir de la misma especificación (`spec`), pero se puede diferenciar por su índice y nombre de host.

A diferencia de los `Deployments` y `Replicasets`, donde las réplicas son intercambiables, cada `Pod` en un `StatefulSet` tiene un índice persistente y un nombre de host que se asocian a su identidad.

Por ejemplo, si un `StatefulSet` tiene el nombre `giropops` y una especificación con tres réplicas, creará tres Pods: `giropops-0`, `giropops-1`, `giropops-2`. Se garantiza el orden de los índices. El Pod `giropops-1` no se iniciará hasta que el Pod `giropops-0` esté disponible y listo.

La misma garantía de orden se aplica a la escalabilidad y las actualizaciones.

&nbsp;

##### El StatefulSet y los volúmenes persistentes

Un aspecto clave de los `StatefulSets` es la integración con los Volumes Persistentes. Cuando un `Pod` se recrea, se vuelve a conectar al mismo Volume Persistente, garantizando la persistencia de los datos entre las recreaciones de los `Pods`.

Por defecto, Kubernetes crea un `PersistentVolume` para cada `Pod` en un `StatefulSet`, que luego se vincula a ese `Pod` durante la vida útil del `StatefulSet`.

Esto es útil para aplicaciones que necesitan un almacenamiento persistente y estable, como bases de datos.

&nbsp;

##### El StatefulSet y el Headless Service

Para entender la relación entre el `StatefulSet` y el `Headless Service`, primero es necesario comprender qué es un `Headless Service`.

En Kubernetes, un servicio es una abstracción que define un conjunto lógico de `Pods` y una manera de acceder a ellos. Normalmente, un servicio tiene una dirección IP y enruta el tráfico hacia los `Pods`. Sin embargo, un `Headless Service` es un tipo especial de servicio que no tiene su propia dirección IP. En su lugar, devuelve directamente las direcciones IP de los `Pods` asociados a él.

Ahora bien, ¿qué relación tienen los `StatefulSets` con los `Headless Services`?

Los `StatefulSets` y los `Headless Services` generalmente trabajan juntos en la gestión de aplicaciones con estado. El `Headless Service` es responsable de permitir la comunicación de red entre los `Pods` en un `StatefulSet`, mientras que el `StatefulSet` gestiona la implementación y la escalabilidad de estos `Pods`.

Así es como funcionan juntos:

Cuando se crea un `StatefulSet`, normalmente se asocia con un `Headless Service`. Se utiliza para controlar el dominio DNS de los `Pods` creados por el `StatefulSet`. Cada `Pod` obtiene un nombre de host DNS que sigue el formato: `<nombre-del-pod>.<nombre-del-servicio>.<namespace>.svc.cluster.local`. Esto permite que cada `Pod` sea accesible individualmente.

Por ejemplo, si tienes un `StatefulSet` llamado `giropops` con tres réplicas y un `Headless Service` llamado `nginx`, los `Pods` creados serán `giropops-0`, `giropops-1`, `giropops-2` y tendrán las siguientes direcciones de host DNS: `giropops-0.nginx.default.svc.cluster.local`, `giropops-1.nginx.default.svc.cluster.local`, `giropops-2.nginx.default.svc.cluster.local`.

Esta combinación de `StatefulSets` y `Headless Services` permite que las aplicaciones con estado, como las bases de datos, tengan una identidad de red estable y predecible, facilitando la comunicación entre diferentes instancias de la misma aplicación.

Bueno, ahora que ya has comprendido cómo funciona esto, creo que ya podemos dar los primeros pasos con el `StatefulSet`.

&nbsp;

##### Creación de un StatefulSet

Para crear un `StatefulSet`, necesitamos un archivo de configuración que describa el `StatefulSet` que deseamos crear. No es posible crear un `StatefulSet` sin un manifiesto YAML, a diferencia de lo que ocurre con el `Pod` y el `Deployment`.

En nuestro ejemplo, utilizaremos `Nginx` como la aplicación que será gestionada por el `StatefulSet`, y haremos que cada `Pod` tenga un volumen persistente asociado a él. Con esto, obtendremos una página web diferente para cada `Pod`.

Para ello, crearemos el archivo `nginx-statefulset.yaml` con el siguiente contenido:

```yaml
apiVersion: apps/v1
kind: StatefulSet # Tipo de recurso que estamos creando, en este caso, un StatefulSet
metadata:
  name: nginx
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates: # Dado que estamos utilizando un StatefulSet, necesitamos crear una plantilla de reclamación de volumen para cada Pod. En lugar de crear un volumen directamente, creamos una plantilla que se utilizará para crear un volumen para cada Pod.
  - metadata:
      name: www # Nombre del volumen, de esta manera tendremos el volumen www-0, www-1 y www-2
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

&nbsp;

Ahora, crearemos el `StatefulSet` con el siguiente comando:

```bash
kubectl apply -f nginx-statefulset.yaml
```

&nbsp;

Para verificar si el `StatefulSet` se ha creado, podemos utilizar el siguiente comando:

```bash
kubectl get statefulset
NAME    READY   AGE
nginx   3/3     2m38s
```

&nbsp;

Si deseamos obtener más detalles, podemos utilizar el siguiente comando:

```bash
kubectl describe statefulset nginx

Name:               nginx
Namespace:          default
CreationTimestamp:  Thu, 18 May 2023 23:44:45 +0200
Selector:           app=nginx
Labels:             <none>
Annotations:        <none>
Replicas:           3 desired | 3 total
Update Strategy:    RollingUpdate
  Partition:        0
Pods Status:        3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /usr/share/nginx/html from www (rw)
  Volumes:  <none>
Volume Claims:
  Name:          www
  StorageClass:  
  Labels:        <none>
  Annotations:   <none>
  Capacity:      1Gi
  Access Modes:  [ReadWriteOnce]
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  112s  statefulset-controller  create Claim www-nginx-0 Pod nginx-0 in StatefulSet nginx success
  Normal  SuccessfulCreate  112s  statefulset-controller  create Pod nginx-0 in StatefulSet nginx successful
  Normal  SuccessfulCreate  102s  statefulset-controller  create Claim www-nginx-1 Pod nginx-1 in StatefulSet nginx success
  Normal  SuccessfulCreate  102s  statefulset-controller  create Pod nginx-1 in StatefulSet nginx successful
  Normal  SuccessfulCreate  96s   statefulset-controller  create Claim www-nginx-2 Pod nginx-2 in StatefulSet nginx success
  Normal  SuccessfulCreate  96s   statefulset-controller  create Pod nginx-2 in StatefulSet nginx successful

```

&nbsp;

Para verificar si los `Pods` se han creado, podemos utilizar el siguiente comando:

```bash
kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          24s
nginx-1   1/1     Running   0          14s
nginx-2   1/1     Running   0          8s
```

&nbsp;

Ahora tenemos nuestro `StatefulSet` creado, pero aún necesitamos crear el `Headless Service` para poder acceder a los `Pods` de manera individual. Para ello, crearemos el archivo `nginx-headless-service.yaml` con el siguiente contenido:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None # Dado que estamos creando un Headless Service, no queremos que tenga una dirección IP, así que definimos clusterIP como None
  selector:
    app: nginx
```

&nbsp;

Listo, con el archivo creado, es hora de crear el `Headless Service` con el siguiente comando:

```bash
kubectl apply -f nginx-headless-service.yaml
```

&nbsp;

Para verificar si el `Headless Service` se ha creado, podemos utilizar el siguiente comando:

```bash
nslookup nginx-0.nginx
```

&nbsp;

A continuación, accederemos al `Pod` utilizando la dirección IP. Para ello, utilizaremos el siguiente comando:

```bash
wget -O- http://<dirección-ip-del-pod>
```

&nbsp;

Necesitamos cambiar el contenido de la página web en cada `Pod` para verificar si estamos accediendo al `Pod` correcto. Para ello, utilizaremos el siguiente comando:

```bash
echo "Pod 0" > /usr/share/nginx/html/index.html
```

&nbsp;

Finalmente, accederemos al `Pod` nuevamente utilizando la dirección IP. Para ello, utilizaremos el siguiente comando:

```bash
wget -O- http://<dirección-ip-del-pod>
```

&nbsp;

La salida del comando debería ser:

```bash
Connecting to <endereço-ip-do-pod>:80 (<endereço-ip-do-pod>:80)
Pod 0
```

&nbsp;

Si lo deseas, puedes repetir los mismos pasos para los otros `Pods`, simplemente cambia el número del `Pod` en el comando `nslookup` y en el comando `echo`.

&nbsp;

##### Eliminando un StatefulSet

Para eliminar un `StatefulSet`, debemos usar el siguiente comando:

```bash
kubectl delete statefulset nginx
```

&nbsp;

También podemos eliminar el `StatefulSet` utilizando el siguiente comando:

```bash
kubectl delete -f nginx-statefulset.yaml
```

&nbsp;

##### Eliminando un Servicio Headless

Para eliminar un `Servicio Headless`, debemos usar el siguiente comando:

```bash
kubectl delete service nginx
```

&nbsp;

También podemos eliminar el `Servicio Headless` utilizando el siguiente comando:

```bash
kubectl delete -f nginx-headless-service.yaml
```

&nbsp;

##### Eliminando un PVC

Para eliminar un `Volume`, debemos usar el siguiente comando:

```bash
kubectl delete pvc www-0
```

&nbsp;

#### Servicios

Los servicios en Kubernetes son una abstracción que define un conjunto lógico de `Pods` y una política para acceder a ellos. Permiten exponer uno o varios `Pods` para que sean accesibles por otros `Pods`, sin importar dónde se estén ejecutando en el clúster.

Los servicios se definen utilizando la API de Kubernetes, normalmente a través de un archivo de manifiesto YAML.

&nbsp;

##### Tipos de Servicios

Existen cuatro tipos principales de servicios:

**ClusterIP** (por defecto): Expone el servicio en una dirección IP interna dentro del clúster. Este tipo hace que el servicio solo sea accesible dentro del clúster.

**NodePort**: Expone el servicio en el mismo puerto de cada nodo seleccionado en el clúster utilizando NAT. Hace que el servicio sea accesible desde fuera del clúster a través de <NodeIP>:<NodePort>.

**LoadBalancer**: Crea un balanceador de carga externo en el entorno de la nube actual (si es compatible) y asigna una dirección IP fija externa al clúster para el servicio.

**ExternalName**: Mapea el servicio al contenido del campo externalName (por ejemplo, foo.bar.example.com), devolviendo un registro CNAME con su valor.

&nbsp;

##### Cómo funcionan los Servicios

Los servicios en Kubernetes proporcionan una abstracción que define un conjunto lógico de `Pods` y una política para acceder a ellos. Los conjuntos de `Pods` se determinan mediante `selectores de etiquetas` (`Label Selectors`). Aunque cada `Pod` tiene una dirección IP única, estas direcciones IP no se exponen fuera del clúster sin un servicio.

Siempre es importante enfatizar la importancia de las "etiquetas" (`labels`) en Kubernetes, ya que son la base de la mayoría de las operaciones en Kubernetes, así que trata las etiquetas con cuidado.

&nbsp;

##### Los Servicios y los Endpoints

Como mencioné antes, los servicios en Kubernetes representan un conjunto estable de Pods que brindan una funcionalidad específica. La característica principal de los servicios es que mantienen una dirección IP y un puerto de servicio constantes a lo largo del tiempo, incluso si los Pods subyacentes se reemplazan.

Para implementar esta abstracción, Kubernetes utiliza otra abstracción llamada `Endpoint`. Cuando se crea un servicio, Kubernetes también crea un objeto `Endpoint` con el mismo nombre. Este objeto `Endpoint` realiza un seguimiento de las direcciones IP y los puertos de los `Pods` que cumplen con los criterios de selección del servicio.

Por ejemplo, cuando creas un `Service`, automáticamente se crea un `Endpoint` que representa los `Pods` que están siendo expuestos por el `Service`.

Para ver los `Endpoints` creados, puedes utilizar el siguiente comando:

```bash
kubectl get endpoints mi-servicio
```

&nbsp;

Veremos más detalles sobre esto más adelante, pero es importante que sepas qué son los `Endpoints` y cuál es su función en Kubernetes.

&nbsp;

##### Creando un Servicio

Para crear un `Service`, necesitamos utilizar el siguiente comando:

```bash
kubectl expose deployment MI_DEPLOYMENT --port=80 --type=NodePort
```

&nbsp;

Observe que en el comando anterior estamos creando un `Service` del tipo `NodePort`, lo que significa que el `Service` será accesible desde fuera del clúster usando <NodeIP>:<NodePort>.

También estamos proporcionando el parámetro `--port=80` para exponer el `Service` en el puerto 80.

Ah, y no olvides proporcionar el nombre de la implementación (`Deployment`) que deseas exponer. En el caso anterior, estamos exponiendo la implementación con el nombre `MI_DEPLOYMENT`. Podemos crear un `Service` para una Implementación (`Deployment`), un `Pod`, un `ReplicaSet`, un `ReplicationController` o incluso para otro `Service`.

¡Sí, incluso para otro `Service`!

La creación de un servicio basado en otro servicio es menos común, pero hay situaciones en las que puede ser útil.

Un buen ejemplo sería cuando deseas cambiar temporalmente el tipo de servicio de un `ClusterIP` a un `NodePort` o `LoadBalancer` con fines de resolución de problemas o mantenimiento, sin alterar la configuración del servicio original. En este caso, podrías crear un nuevo servicio que exponga el servicio `ClusterIP`, realizar tus tareas y luego eliminar el nuevo servicio, manteniendo intacta la configuración original.

Otro ejemplo es cuando deseas exponer la misma aplicación en diferentes contextos, con diferentes políticas de acceso. Por ejemplo, puedes tener un servicio `ClusterIP` para la comunicación interna entre microservicios, un servicio `NodePort` para el acceso desde la red interna de tu organización y un servicio `LoadBalancer` para el acceso desde internet. En este caso, los tres servicios podrían apuntar al mismo conjunto de `Pods`, pero cada uno proporcionaría una vía de acceso diferente, con diferentes políticas de seguridad y control de acceso.

Sin embargo, estos son casos de uso bastante específicos. En la mayoría de los escenarios, crearías servicios directamente para exponer `Deployments`, `StatefulSets` o `Pods`.

&nbsp;

Crearemos algunos `Services` para que puedas entender mejor cómo funcionan, y al final, realizaremos un ejemplo más completo utilizando el `Deployment` de Giropops-Senhas.

&nbsp;

###### ClusterIP

Para crear un servicio `ClusterIP` mediante `kubectl`, puedes utilizar el comando `kubectl expose` de la siguiente manera:

```bash
kubectl expose deployment mi-deployment --port=80 --target-port=8080
```

Este comando creará un servicio ClusterIP que expone el `mi-deployment` en el puerto 80, redirigiendo el tráfico al puerto 8080 de los Pods de esta implementación.

Para crear un servicio `ClusterIP` mediante YAML, puedes usar un archivo como este:

```yaml
apiVersion: v1
kind: Service # Tipo del objeto, en este caso, un Service
metadata:
  name: mi-servicio
spec:
  selector: # Selecciona los Pods que serán expuestos por el Service
    app: mi-aplicacion # En este caso, los Pods con la etiqueta app=mi-aplicacion
  ports:
    - protocol: TCP
      port: 80 # Puerto del Service
      targetPort: 8080 # Puerto de los Pods
```

&nbsp;

Este archivo YAML creará un servicio que corresponde a los `Pods` con la etiqueta `app=mi-aplicacion`, y redirige el tráfico del puerto 80 del servicio al puerto 8080 de los `Pods`. Observa que estamos usando el campo `selector` para definir qué `Pods` serán expuestos por el `Service`.

Como no hemos especificado el campo `type`, Kubernetes creará un `Service` del tipo `ClusterIP` de manera predeterminada.

¡Es bastante sencillo, verdad?

&nbsp;

###### NodePort

Para crear un servicio `NodePort` mediante la CLI, puedes usar el comando kubectl expose con la opción --type=NodePort. Por ejemplo:

```bash
kubectl expose deployment mi-deployment --type=NodePort --port=80 --target-port=8080
```

&nbsp;

Para crear un servicio `NodePort` mediante YAML, puedes usar un archivo como este:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mi-servicio
spec:
  type: NodePort # Tipo del Service
  selector:
    app: mi-aplicacion
  ports:
    - protocol: TCP
      port: 80 # Puerto del Service, que se mapeará al puerto 8080 del Pod
      targetPort: 8080 # Puerto de los Pods
      nodePort: 30080   # Puerto del Node, que se mapeará al puerto 80 del Service
```

&nbsp;

Aquí estamos especificando el campo `type` como `NodePort`, y también estamos especificando el campo `nodePort`, que define el puerto del Node que se mapeará al puerto 80 del Service. Recuerda que el puerto del Node debe estar entre 30000 y 32767, y cuando no especificamos el campo `nodePort`, Kubernetes elegirá automáticamente un puerto aleatorio dentro de este rango. :)

&nbsp;

###### LoadBalancer

El Service del tipo `LoadBalancer` es una de las formas más comunes de exponer un servicio al tráfico de internet en Kubernetes. Provisiona automáticamente un balanceador de carga del proveedor de nube en el que se está ejecutando el clúster Kubernetes, si está disponible.

Para crear un servicio `LoadBalancer` mediante la CLI, puedes usar el comando kubectl expose con la opción --type=LoadBalancer.

```bash
kubectl expose deployment mi-deployment --type=LoadBalancer --port=80 --target-port=8080
```

Si deseas crear un servicio `LoadBalancer` mediante YAML, puedes usar un archivo como este:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mi-servicio
spec:
  type: LoadBalancer
  selector:
    app: mi-aplicacion
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

&nbsp;

No hay nada nuevo aquí, solo el hecho de que le estás pidiendo a Kubernetes que cree un `Service` del tipo `LoadBalancer`.

Deseas exponer un servicio para que pueda ser accedido externamente por usuarios o sistemas que no están dentro de tu clúster Kubernetes. Este tipo de servicio puede ser útil cuando:

- **Proveedores de nube**: Tu clúster Kubernetes está alojado en un proveedor de nube que admite balanceadores de carga, como AWS, GCP, Azure, etc. En este caso, cuando se crea un servicio del tipo LoadBalancer, automáticamente se provisiona un balanceador de carga en el proveedor de nube.

- **Tráfico externo**: Necesitas que tu aplicación sea accesible fuera del clúster. El `LoadBalancer` expone una IP accesible externamente que dirige el tráfico hacia los pods del servicio.

Es importante recordar que el uso de `LoadBalancers` puede tener costos adicionales, ya que estás utilizando recursos adicionales de tu proveedor de nube. Por lo tanto, siempre es recomendable verificar los costos asociados antes de implementarlos. ;)

&nbsp;

###### ExternalName

El tipo de servicio `ExternalName` es un poco diferente de los otros tipos de servicio. No expone un conjunto de `Pods`, sino un nombre de host externo. Por ejemplo, puedes tener un servicio que exponga una base de datos externa o un servicio de correo electrónico externo.

El tipo `ExternalName` es útil cuando deseas:

- **Crear un alias para un servicio externo:** Supongamos que tienes una base de datos alojada fuera de tu clúster Kubernetes, pero quieres que tus aplicaciones dentro del clúster se refieran a ella por el mismo nombre, como si estuviera dentro del clúster. En este caso, puedes usar un ExternalName para crear un alias para la dirección de la base de datos.

- **Abstraer servicios dependientes del entorno:** Otro uso común para ExternalName es cuando tienes diferentes entornos, como producción y desarrollo, que tienen diferentes servicios externos. Puedes usar el mismo nombre de servicio en todos los entornos, pero apuntar a diferentes direcciones externas.

Lamentablemente, este tipo de servicio se utiliza poco debido a la falta de conocimiento de las personas, ¡pero eso no te pasará a ti!

Vamos a crear un ejemplo de `ExternalName` usando kubectl expose:

```bash
kubectl create service externalname mi-servicio --external-name mi-db.giropops.com.br
```

&nbsp;

Aquí estamos pasando como parámetro el nombre del servicio y la dirección externa que queremos exponer al clúster.

Ahora, si deseas crear un `ExternalName` mediante YAML, puedes usar un archivo como este:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mi-servicio
spec:
  type: ExternalName
  externalName: mi-db.giropops.com.br
```

&nbsp;

Aquí estamos especificando el campo `type` como `ExternalName` y también estamos especificando el campo `externalName`, que define la dirección externa que deseamos exponer al clúster. ¡Nada del otro mundo! :)

Ah, y recuerda que `ExternalName` no admite `selectors` ni `ports`, ya que no expone un conjunto de `Pods`, sino un nombre de host externo.

Y recuerda parte 2, `ExternalName` acepta un nombre de host válido de acuerdo con el estándar `DNS (RFC-1123)`, que puede ser un nombre de dominio o una dirección IP.

&nbsp;

##### Verificando los Services

Ahora que hemos creado algunos `Services`, es hora de aprender cómo ver los detalles de ellos.

Para visualizar los Services en ejecución en tu clúster Kubernetes en el espacio de nombres (`namespace`) por defecto, puedes usar el comando `kubectl get services`. Este comando listará todos los Services junto con información básica como el tipo de servicio, la dirección IP y el puerto.

```bash
kubectl get services
```

&nbsp;

Si deseas obtener los `Services` de un espacio de nombres específico, puedes usar el comando `kubectl get services -n <namespace>`. Por ejemplo:

```bash
kubectl get services -n kube-system
```

&nbsp;

Para visualizar los `Services` en todos los espacios de nombres, puedes usar el comando `kubectl get services --all-namespaces` o `kubectl get services -A`.

```bash
kubectl get services -A
```

&nbsp;

Para ver los detalles de un `Service` específico, puedes usar el comando `kubectl describe service`, pasando el nombre del `Service` como parámetro. Por ejemplo:

```bash
kubectl describe service mi-servicio
```

&nbsp;

##### Verificando los Endpoints

Los `Endpoints` son una parte importante de los `Services`, ya que son responsables de mantener la asociación entre el `Service` y los `Pods` que está exponiendo.

Con eso en mente, vamos a aprender cómo ver los detalles de los `Endpoints`.

Primero, para ver los `Endpoints` de un `Service` específico, puedes usar el siguiente comando:

```bash
kubectl get endpoints mi-servicio
```

&nbsp;

Para ver los `Endpoints` de todos los `Services`, puedes usar el siguiente comando:

```bash
kubectl get endpoints -A
```

&nbsp;

Ahora, para ver los detalles de un `Endpoints` específico, es tan sencillo como volar, solo usa el siguiente comando:

```bash
kubectl describe endpoints mi-servicio
```

&nbsp;

Con esto, podrás obtener información detallada sobre cómo los `Endpoints` están asociados con los `Pods` y cómo se maneja el tráfico dentro de tus `Services`.

&nbsp;

##### Eliminando un Service

Ahora que hemos aprendido mucho sobre los `Services`, vamos a aprender cómo eliminarlos.

Para eliminar un `Service` mediante la CLI, puedes usar el comando `kubectl delete service`, pasando el nombre del `Service` como parámetro. Por ejemplo:

```bash
kubectl delete service mi-servicio
```

&nbsp;

Para eliminar un `Service` mediante YAML, puedes usar el comando `kubectl delete`, pasando el archivo YAML como parámetro. Por ejemplo:

```bash
kubectl delete -f mi-servicio.yaml
```

&nbsp;

Con esto, hemos cubierto bastante sobre los `Services`. Creo que ya puedes actualizar tu currículum y decir que eres un experto en `Services` en Kubernetes. :)

&nbsp;

### Tu tarea

Te propongo crear y administrar un `StatefulSet` en tu propio entorno de Kubernetes. Comienza creando un `StatefulSet` simple con un par de `Pods` y luego intenta escalarlo a más `Pods`. Experimenta también eliminando un `Pod` y observa cómo Kubernetes maneja la situación.

Luego, juega un poco con los `Services`. Expón tu `StatefulSet` a través de un `Service` tipo `ClusterIP` y luego intenta cambiarlo a `NodePort` o `LoadBalancer`. Prueba la conectividad para asegurarte de que todo funcione correctamente.

Por último, pero no menos importante, crea un `Service` de tipo `ExternalName` y apúntalo a un servicio externo de tu elección. Verifica que el servicio externo sea accesible desde dentro de tus `Pods`.

Recuerda que la práctica hace al maestro, ¡así que no te saltes esta tarea! ;) Y si tienes preguntas o problemas, no dudes en pedir ayuda. ¡Estamos aquí para aprender juntos!

¡Hasta aquí llegamos por el Día 7! Durante este día, has aprendido acerca de dos recursos esenciales en Kubernetes: `StatefulSets` y `Services`. A través de ellos, puedes administrar aplicaciones que necesitan mantener la identidad del `Pod`, persistir datos y exponer esas aplicaciones al mundo exterior.

Espero que hayas disfrutado del contenido de hoy y recuerda hacer la tarea. La práctica es fundamental para consolidar todo este conocimiento y realmente marca la diferencia.

Nos vemos en el próximo día, donde continuaremos nuestra aventura en este mágico mundo de los contenedores. ¡Hasta entonces! **#VAIIII**
