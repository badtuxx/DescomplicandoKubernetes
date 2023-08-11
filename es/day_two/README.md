
# Simplificando Kubernetes

&nbsp;

## Día 2

&nbsp;

### Índice

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 2](#día-2)
    - [Índice](#índice)
    - [Ínicio de la clase Día 2](#ínicio-de-la-clase-día-2)
    - [¿Qué vamos a ver hoy?](#qué-vamos-a-ver-hoy)
    - [¿Qué es un Pod?](#qué-es-un-pod)
      - [Creando un Pod](#creando-un-pod)
      - [Visualización de detalles sobre los Pods](#visualización-de-detalles-sobre-los-pods)
      - [Eliminando un Pod](#eliminando-un-pod)
      - [Creando un Pod mediante un archivo YAML](#creando-un-pod-mediante-un-archivo-yaml)
      - [Visualizando los registros (logs) del Pod](#visualizando-los-registros-logs-del-pod)
      - [Creando un Pod con múltiples contenedores](#creando-un-pod-con-múltiples-contenedores)
    - [Los comandos `attach` y `exec`](#los-comandos-attach-y-exec)
    - [Creando un contenedor con límites de memoria y CPU](#creando-un-contenedor-con-límites-de-memoria-y-cpu)
    - [Agregando un volumen EmptyDir al Pod](#agregando-un-volumen-emptydir-al-pod)

&nbsp;

### Ínicio de la clase Día 2

&nbsp;

### ¿Qué vamos a ver hoy?

Durante la clase de hoy, veremos todos los detalles importantes sobre la unidad más pequeña de Kubernetes, el Pod.
Vamos a abordar desde la creación de un Pod simple, pasando por Pods con múltiples contenedores, con volúmenes e incluso con limitación en el consumo de recursos, como CPU o memoria.
Y por supuesto, aprenderemos cómo ver todos los detalles de un Pod en funcionamiento y jugaremos bastante con nuestros archivos YAML.

### ¿Qué es un Pod?

Lo primero, el Pod es la unidad más pequeña dentro de un clúster de Kubernetes.

Cuando hablamos de Pod, debemos pensar en él como una caja que contiene uno o más contenedores. Estos contenedores comparten los mismos recursos del Pod, como por ejemplo, la dirección IP, el namespace, el volumen, etc.

Entonces, cuando hablamos de Pod, nos referimos a uno o más contenedores que comparten los mismos recursos, punto.
&nbsp;

#### Creando un Pod

Básicamente, existen dos formas de crear un Pod: la primera es mediante un comando en la terminal y la segunda es a través de un archivo YAML.

Comencemos creando un Pod mediante un comando en la terminal.

```bash
kubectl run giropops --image=nginx --port=80
```

El comando anterior creará un Pod llamado giropops, con una imagen de nginx y el puerto 80 expuesto.

#### Visualización de detalles sobre los Pods

Para ver el Pod creado, podemos utilizar el siguiente comando:

```bash
kubectl get pods
```

El comando anterior listará todos los Pods que están en ejecución en el clúster, en el espacio de nombres (namespace) predeterminado.

Sí, en Kubernetes tenemos espacios de nombres (namespaces), pero eso es tema para otro día. Por ahora, nos centraremos en los Pods y solo debemos saber que por defecto, Kubernetes creará todos los objetos dentro del espacio de nombres predeterminado si no especificamos otro.

Para ver los Pods en ejecución en todos los espacios de nombres, podemos usar el siguiente comando:

```bash
kubectl get pods --all-namespaces
```

O también, podemos utilizar el siguiente comando:

```bash
kubectl get pods -A
```

Ahora bien, si deseas ver todos los Pods de un espacio de nombres específico, puedes utilizar el siguiente comando:

```bash
kubectl get pods -n <namespace>
```

Por ejemplo:

```bash
kubectl get pods -n kube-system
```

El comando anterior listará todos los Pods en ejecución en el espacio de nombres kube-system, que es el espacio de nombres donde Kubernetes creará todos los objetos relacionados con el clúster, como los Pods de CoreDNS, Kube-Proxy, Kube-Controller-Manager, Kube-Scheduler, etc.

Si deseas obtener aún más detalles sobre el Pod, puedes solicitar a Kubernetes que muestre los detalles del Pod en formato YAML mediante el siguiente comando:

```bash
kubectl get pods <nombre-del-pod> -o yaml
```

Por ejemplo:

```bash
kubectl get pods giropops -o yaml
```

El comando anterior mostrará todos los detalles del Pod en formato YAML, prácticamente igual a lo que verías en el archivo YAML que creamos para crear el Pod, pero con algunos detalles adicionales, como el UID del Pod, el nombre del nodo donde se está ejecutando el Pod, etc. Después de todo, este Pod ya está en ejecución, por lo que Kubernetes ya tiene más detalles sobre él.

Otra salida interesante es el formato JSON, que puedes visualizar utilizando el siguiente comando:

```bash
kubectl get pods <nombre-del-pod> -o json
```

Por ejemplo:

```bash
kubectl get pods giropops -o json
```

En otras palabras, al usar el parámetro `-o`, puedes elegir el formato de salida que deseas ver, como yaml, json, wide, etc.

La salida 'wide' es interesante, ya que proporciona más detalles sobre el Pod, como la dirección IP del Pod y el nodo en el que se está ejecutando.

```bash
kubectl get pods <nombre-del-pod> -o wide
```

Por ejemplo:

```bash
kubectl get pods giropops -o wide
```

Ahora bien, si deseas ver los detalles del Pod en formato YAML pero sin necesidad de utilizar el comando `get`, puedes emplear el comando:

```bash
kubectl describe pods <nombre-del-pod>
```

Por ejemplo:

```bash
kubectl describe pods giropops
```

Mediante el comando `describe`, podrás visualizar todos los detalles del Pod, incluidos los detalles del contenedor que se encuentra dentro del Pod.

#### Eliminando un Pod

Ahora, vamos a eliminar el Pod que creamos utilizando el siguiente comando:

```bash
kubectl delete pods giropops
```

¿Fácil, verdad? Ahora, vamos a crear un Pod a través de un archivo YAML.

&nbsp;

#### Creando un Pod mediante un archivo YAML

Vamos a crear un archivo YAML llamado pod.yaml con el siguiente contenido:

```yaml
apiVersion: v1 # versión de la API de Kubernetes
kind: Pod # tipo de objeto que estamos creando
metadata: # metadatos del Pod 
  name: giropops # nombre del Pod que estamos creando
labels: # etiquetas del Pod
  run: giropops # etiqueta run con el valor giropops
spec: # especificación del Pod
  containers: # contenedores que están dentro del Pod
  - name: giropops # nombre del contenedor
    image: nginx # imagen del contenedor
    ports: # puertos que están siendo expuestos por el contenedor
    - containerPort: 80 # puerto 80 expuesto por el contenedor
```

Ahora, vamos a crear el Pod utilizando el archivo YAML que acabamos de crear.

```bash
kubectl apply -f pod.yaml
```

El comando anterior creará el Pod utilizando el archivo YAML que creamos.

Para ver el Pod creado, podemos utilizar el siguiente comando:

```bash
kubectl get pods
```

Dado que utilizamos el comando `apply`, creo que vale la pena explicar lo que hace.

El comando `apply` realiza lo que su nombre indica: aplica el archivo YAML al clúster, es decir, crea el objeto que se describe en el archivo YAML en el clúster. Si el objeto ya existe, actualizará el objeto con la información que se encuentra en el archivo YAML.

Otro comando que puedes utilizar para crear un objeto en el clúster es el comando `create`, que también crea el objeto que se describe en el archivo YAML en el clúster; sin embargo, si el objeto ya existe, devolverá un error. Por esta razón, el comando `apply` es más comúnmente utilizado, ya que actualiza el objeto en caso de que ya exista. :)

Ahora, vamos a ver los detalles del Pod que acabamos de crear.

```bash
kubectl describe pods giropops
```

#### Visualizando los registros (logs) del Pod

Otro comando muy útil para ver lo que está sucediendo con el Pod, específicamente para ver lo que el contenedor está registrando, es el siguiente:

```bash
kubectl logs giropops
```

Donde "giropops" es el nombre del Pod que creamos.

Si deseas ver los registros del contenedor en tiempo real, puedes utilizar el siguiente comando:

```bash
kubectl logs -f giropops
```

¡Simple, verdad? Ahora, vamos a eliminar el Pod que creamos, utilizando el comando:

```bash
kubectl delete pods giropops
```

&nbsp;

#### Creando un Pod con múltiples contenedores

Vamos a crear un archivo YAML llamado pod-multi-container.yaml con el siguiente contenido:

```yaml
apiVersion: v1 # versión de la API de Kubernetes
kind: Pod # tipo de objeto que estamos creando
metadata: # metadatos del Pod 
  name: giropops # nombre del Pod que estamos creando
labels: # etiquetas del Pod
  run: giropops # etiqueta run con el valor giropops
spec: # especificación del Pod
  containers: # contenedores que están dentro del Pod
  - name: girus # nombre del contenedor
    image: nginx # imagen del contenedor
    ports: # puertos que están siendo expuestos por el contenedor
    - containerPort: 80 # puerto 80 expuesto por el contenedor
  - name: strigus # nombre del contenedor
    image: alpine # imagen del contenedor
    args:
    - sleep
    - "1800"
```

Con el manifiesto anterior, estamos creando un Pod con dos contenedores: uno llamado "girus" con la imagen de nginx y otro llamado "strigus" con la imagen de alpine. Es importante recordar que el contenedor de Alpine se crea con el comando `sleep 1800` para que el contenedor no se detenga, a diferencia del contenedor de Nginx que tiene un proceso principal en ejecución en primer plano, lo que evita que el contenedor se detenga.

El Alpine es una distribución Linux muy ligera que no tiene un proceso principal en primer plano en funcionamiento. Por lo tanto, necesitamos ejecutar el comando `sleep 1800` para mantener en funcionamiento el contenedor, añadiendo así un proceso principal en primer plano.

Ahora, crearemos el Pod utilizando el archivo YAML que acabamos de crear.

```bash
kubectl apply -f pod-multi-container.yaml
```

Para ver el Pod creado, podemos usar el siguiente comando:

```bash
kubectl get pods
```

Ahora, vamos a ver los detalles del Pod que acabamos de crear.

```bash
kubectl describe pods giropops
```

### Los comandos `attach` y `exec`

Vamos a conocer dos nuevos comandos, `attach` y `exec`.

El comando `attach` se utiliza para conectarse a un contenedor que se está ejecutando dentro de un Pod. Por ejemplo, nos conectaremos al contenedor de Alpine que se está ejecutando dentro del Pod que creamos.

```bash
kubectl attach giropops -c strigus
```

Usar `attach` es similar a conectarse directamente a una consola de una máquina virtual; no estamos creando ningún proceso dentro del contenedor, solo nos estamos conectando a él.

Por esta razón, si intentamos utilizar `attach` para conectarnos al contenedor donde se está ejecutando Nginx, nos conectaremos al contenedor y quedaremos atrapados en el proceso de Nginx que se está ejecutando en primer plano, y no podremos ejecutar ningún otro comando.

```bash
kubectl attach giropops -c girus
```

Para salir del contenedor, simplemente presiona las teclas `Ctrl + C`.

¿Entendido? Solo utilizaremos `attach` para conectarnos a un contenedor que se está ejecutando dentro de un Pod, y no para ejecutar comandos dentro del contenedor.

Ahora bien, si deseas ejecutar comandos dentro del contenedor, puedes usar el comando `exec`.

El comando `exec` se utiliza para ejecutar comandos dentro de un contenedor que se está ejecutando dentro de un Pod. Por ejemplo, vamos a ejecutar el comando `ls` dentro del contenedor de Alpine que se está ejecutando dentro del Pod que creamos.

```bash
kubectl exec giropops -c strigus -- ls
```

También podemos utilizar `exec` para conectarnos a un contenedor que se está ejecutando dentro de un Pod; sin embargo, para hacerlo, debemos pasar el parámetro `-it` al comando `exec`.

```bash
kubectl exec giropops -c strigus -it -- sh
```

El parámetro `-it` se utiliza para que el comando `exec` cree un proceso dentro del contenedor con interactividad y un terminal, haciendo que el comando `exec` se comporte de manera similar al comando `attach`, pero con la diferencia de que el comando `exec` crea un proceso dentro del contenedor, en este caso, el proceso `sh`. Es por esta razón que el comando `exec` se utiliza con mayor frecuencia, ya que crea un proceso dentro del contenedor, a diferencia del comando `attach`, que no crea ningún proceso dentro del contenedor.

En este caso, incluso podemos conectarnos al contenedor de Nginx, ya que se conectará al contenedor creando un proceso que es nuestro intérprete de comandos `sh`, lo que nos permitirá ejecutar cualquier comando dentro del contenedor, ya que tenemos un shell para interactuar con él.

```bash
kubectl exec giropops -c girus -it -- sh
```

Para salir del contenedor, simplemente presiona la tecla `Ctrl + D`.

&nbsp;

### Creando un contenedor con límites de memoria y CPU

Vamos a crear un archivo YAML llamado pod-limitado.yaml con el siguiente contenido:

```yaml
apiVersion: v1 # versión de la API de Kubernetes
kind: Pod # tipo de objeto que estamos creando
metadata: # metadatos del Pod
  name: giropops # nombre del Pod que estamos creando
labels: # etiquetas del Pod
  run: giropops # etiqueta run con el valor giropops
spec: # especificación del Pod 
  containers: # contenedores que están dentro del Pod 
  - name: girus # nombre del contenedor 
    image: nginx # imagen del contenedor
    ports: # puertos que están siendo expuestos por el contenedor
    - containerPort: 80 # puerto 80 expuesto por el contenedor
    resources: # recursos que están siendo utilizados por el contenedor
      limits: # límites máximos de recursos que el contenedor puede utilizar
        memory: "128Mi" # límite de memoria que está siendo utilizado por el contenedor, en este caso 128 megabytes como máximo 
        cpu: "0.5" # límite máximo de CPU que el contenedor puede utilizar, en este caso 50% de una CPU como máximo
      requests: # recursos garantizados al contenedor
        memory: "64Mi" # memoria garantizada al contenedor, en este caso 64 megabytes
        cpu: "0.3" # CPU garantizada al contenedor, en este caso 30% de una CPU
```

Observe que estamos introduciendo algunos nuevos campos, como `resources`, `limits` y `requests`.

El campo `resources` se utiliza para definir los recursos que utiliza el contenedor, y dentro de él encontramos los campos `limits` y `requests`.

El campo `limits` se utiliza para definir los límites máximos de recursos que puede utilizar el contenedor, y el campo `requests` se utiliza para definir los recursos garantizados al contenedor.

¡Super simple!

Los valores que pasamos para los campos `limits` y `requests` fueron:

- `memory`: la cantidad de memoria que el contenedor puede utilizar, por ejemplo, `128Mi` o `1Gi`. El valor `Mi` significa mebibytes y el valor `Gi` significa gibibytes. El valor `M` significa megabytes y el valor `G` significa gigabytes. El valor `Mi` se utiliza para definir el límite de memoria en mebibytes, ya que Kubernetes utiliza el sistema de unidades binarias, y no el sistema de unidades decimales. El valor `M` se utiliza para definir el límite de memoria en megabytes, ya que Docker utiliza el sistema de unidades decimales, y no el sistema de unidades binarias. Por lo tanto, si estás utilizando Docker, puedes usar el valor `M` para definir el límite de memoria, pero si estás utilizando Kubernetes, debes usar el valor `Mi` para definir el límite de memoria.

Ahora vamos a crear el Pod con los límites de memoria y CPU.

```bash
kubectl create -f pod-limitado.yaml
```

Ahora verifiquemos si el Pod ha sido creado.

```bash
kubectl get pods
```

Comprobemos los detalles del Pod.

```bash
kubectl describe pod giropops
```

Observe que el Pod se creó exitosamente y los límites de memoria y CPU se establecieron según el archivo YAML.

A continuación, se muestra la parte de la salida del comando `describe` que muestra los límites de memoria y CPU.

```bash
Containers:
  girus:
    Container ID:   docker://e7b0c7b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 01 Jan 2023 00:00:00 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        300m
      memory:     64Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-0b0b0 (ro)
```

Observe en la salida anterior que se muestra el campo CPU con el valor `500m`. Esto significa que el contenedor puede utilizar como máximo el 50% de una CPU, ya que una CPU equivale a 1000 milicpus, y el 50% de 1000 milicpus son 500 milicpus.

Por lo tanto, si deseas establecer un límite de CPU al 50% de una CPU, puedes definir el valor `500m`, o puedes establecer el valor `0.5`, que es lo mismo que establecer el valor `500m`.

Para probar los límites de memoria y CPU, puedes ejecutar el comando `stress` dentro del contenedor. Este es un comando que hace que el contenedor consuma recursos de CPU y memoria. Recuerda instalar el comando `stress`, ya que no está instalado por defecto.

Para facilitar las pruebas, crearemos un Pod con Ubuntu y limitaremos la memoria, además, instalaremos el comando `stress` dentro del contenedor.

Llama al archivo `pod-ubuntu-limitado.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: giropops
spec:
  containers:
  - name: girus
    image: ubuntu
    args:
    - sleep
    - infinity
    resources:
      limits:
        memory: "128Mi"
        cpu: "0.5"
      requests:
        memory: "64Mi"
        cpu: "0.3"
```

Observa que usamos el parámetro `infinity`, el cual hace que el contenedor espere indefinidamente y, por lo tanto, permanezca en ejecución.

Ahora crearemos el Pod.

```bash
kubectl create -f pod-ubuntu-limitado.yaml
```

Una vez creado, el contenedor de Ubuntu con los límites de memoria y CPU se ejecutará. Luego, podrás conectarte a él y probar el comando `stress` para ver cómo afecta el consumo de recursos en el contenedor.

Ahora verificaremos si el Pod ha sido creado.

```bash
kubectl get pods
```

Luego, accederemos al interior del contenedor.

```bash
kubectl exec -it giropops -- bash
```

A continuación, instalaremos el comando `stress`.

```bash
apt update
apt install -y stress
```

Finalmente, ejecutaremos el comando `stress` para consumir memoria.

```bash
stress --vm 1 --vm-bytes 100M
```

Hasta aquí todo está bien, ya que definimos el límite de memoria en 128Mi, y el comando `stress` está consumiendo 100M, así que está todo correcto.

Ahora vamos a aumentar el consumo de memoria a 200M.

```bash
stress --vm 1 --vm-bytes 200M
```

Observa que el comando `stress` no puede consumir 200M, ya que el límite de memoria es de 128Mi, que es menor que 200M. Esto generará un error y el comando `stress` se detendrá.

¡Hemos alcanzado nuestro objetivo, hemos alcanzado el límite de nuestro contenedor! :D

¿Quieres jugar un poco más con el comando `stress`? Echa un vistazo a su `--help`.

```bash
stress --help
```

Este comando ofrece varias opciones para experimentar con el consumo de memoria y CPU. Puedes explorar estas opciones para entender mejor cómo el comando `stress` puede simular diferentes cargas en tu contenedor y probar cómo responde ante distintas condiciones. ¡Diviértete probando y descubriendo cómo puedes ajustar el rendimiento del contenedor con el uso de `stress`!

&nbsp;

### Agregando un volumen EmptyDir al Pod

Una cosa, no es el momento adecuado para entrar en detalles más profundos sobre volúmenes. Tendremos todo un día para hablar sobre volúmenes, así que no te preocupes por eso por ahora.

Hoy nos centraremos en asegurarnos de estar muy cómodos con los Pods, desde su creación, administración, ejecución de comandos, etc.

Así que vamos a crear un Pod con un volumen EmptyDir.

Pero primero, ¿qué es un volumen EmptyDir?

Un volumen del tipo EmptyDir es un volumen que se crea cuando se crea el Pod y se destruye cuando el Pod se elimina, es decir, es un volumen temporal.

En el día a día, es posible que no uses mucho este tipo de volumen, pero es importante que sepas que existe. Uno de los casos de uso más comunes es cuando necesitas compartir datos entre los contenedores de un Pod. Imagina que tienes dos contenedores en un Pod y uno de ellos tiene un directorio con datos, y deseas que el otro contenedor tenga acceso a esos datos. En este caso, puedes crear un volumen del tipo EmptyDir y compartirlo entre los dos contenedores.

Llama al archivo `pod-emptydir.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: giropops
spec:
  containers:
  - name: girus
    image: ubuntu
    args:
    - sleep
    - infinity
    volumeMounts:
    - name: primeiro-emptydir
      mountPath: /giropops
  volumes:
  - name: primeiro-emptydir
    emptyDir:
      sizeLimit: 256Mi
```

Ahora crearemos el Pod.

```bash
kubectl create -f pod-emptydir.yaml
```

Ahora verificaremos si el Pod ha sido creado.

```bash
kubectl get pods
```

Puedes observar la salida del comando `kubectl describe pod giropops` para ver el volumen que se ha creado.

```bash
kubectl describe pod giropops
```

Luego, accederemos al interior del contenedor.

```bash
kubectl exec -it giropops -- bash
```

A continuación, crearemos un archivo dentro del directorio `/giropops`.

```bash
touch /giropops/FUNCIONAAAAAA
```

Listo, hemos creado nuestro archivo dentro del directorio `/giropops`, que es un directorio dentro del volumen de tipo EmptyDir. :-)

Recordando una vez más que aún veremos mucho, muchísimo más sobre volúmenes, así que no te preocupes por eso por ahora.
