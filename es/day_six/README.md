# Simplificando Kubernetes

## Día 6

&nbsp;

## Contenido del Día 6

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 6](#día-6)
  - [Contenido del Día 6](#contenido-del-día-6)
  - [Inicio de la Lección del Día 6](#inicio-de-la-lección-del-día-6)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
      - [¿Qué son los volúmenes?](#qué-son-los-volúmenes)
        - [EmpytDir](#empytdir)
        - [Clase de Almacenamiento (Storage Class)](#clase-de-almacenamiento-storage-class)
        - [PV - Persistent Volume](#pv---persistent-volume)
        - [PVC - Persistent Volume Claim](#pvc---persistent-volume-claim)
    - [Tu tarea](#tu-tarea)

## Inicio de la Lección del Día 6

&nbsp;

### ¿Qué veremos hoy?

¡Hoy es el día en que finalmente desmitificaremos los volúmenes en Kubernetes! \o/

Hoy vamos a entender y configurar qué es un `configmap`, un `persistent volume (PV)` y un `persistent volume claim (PVC)` (reclamo de volumen persistente). ¡Y para esto, vamos a utilizar ejemplos en diferentes tipos de clústeres Kubernetes! ¡Tranquilo, lo explicaré mejor!

Para ayudar en nuestro aprendizaje sobre volúmenes, vamos a utilizar diferentes clústeres Kubernetes. Tendremos ejemplos utilizando `EKS`, `kind` e instancias en proveedores de servicios en la nube.

Así que ten en cuenta que hoy es el día en que desmitificarás los volúmenes en Kubernetes. #VAIIII

&nbsp;

#### ¿Qué son los volúmenes?

Para simplificar tu comprensión en este momento, los volúmenes son básicamente directorios dentro del `Pod` que se pueden utilizar para almacenar datos. Pueden utilizarse para almacenar datos que necesitan persistirse, como datos de una base de datos o datos de un sistema de archivos distribuido.

Cuando hablamos de volúmenes en Kubernetes, es importante entender que básicamente hay dos tipos de volúmenes: los `ephemeral volumes` (volúmenes efímeros) y los `persistent volumes` (volúmenes persistentes).

Los `ephemeral volumes`, que ya hemos visto en el entrenamiento, como el `emptyDir`, son volúmenes que se crean y destruyen junto con el `Pod`. Es un volumen, pero con una diferencia: no es persistente. Si ocurre algún problema con el `Pod` y este se elimina, el `emptyDir` también se eliminará.

Por otro lado, cuando hablamos de volúmenes del tipo `persistent volumes`, nos referimos a volúmenes que se crean y no se destruyen junto con el `Pod`. Son persistentes; es decir, sus datos se mantienen aunque se elimine el `Pod`.

Este tipo de volumen es fundamental para aplicaciones que necesitan almacenar datos que deben mantenerse incluso si el `Pod` se elimina, como, por ejemplo, una base de datos.

##### EmpytDir

Un volumen del tipo EmptyDir es un volumen que se crea cuando se crea el Pod y se destruye cuando se destruye el Pod. En otras palabras, es un volumen temporal.

En la vida cotidiana, no utilizarás mucho este tipo de volumen, pero es importante que sepas que existe. Uno de los casos de uso más comunes es cuando necesitas compartir datos entre los contenedores de un Pod. Imagina que tienes dos contenedores en un Pod y uno de ellos tiene un directorio con datos, y quieres que el otro contenedor tenga acceso a esos datos. En este caso, puedes crear un volumen del tipo EmptyDir y compartirlo entre los dos contenedores.

Nombra al archivo `pod-emptydir.yaml`.

```yaml
apiVersion: v1 # Versión de la API de Kubernetes
kind: Pod # Tipo de objeto que estamos creando
metadata: # Metadatos del Pod
  name: giropops # Nombre del Pod
spec: # Especificación del Pod
  containers: # Lista de contenedores
  - name: girus # Nombre del contenedor
    image: ubuntu # Imagen del contenedor
    args: # Argumentos que se pasarán al contenedor
    - sleep # Usando el comando sleep para mantener el contenedor en ejecución
    - infinity # El argumento infinity hace que el contenedor espere indefinidamente
    volumeMounts: # Lista de montajes de volúmenes en el contenedor
    - name: primeiro-emptydir # Nombre del volumen
      mountPath: /giropops # Directorio donde se montará el volumen
  volumes: # Lista de volúmenes
  - name: primeiro-emptydir # Nombre del volumen
    emptyDir: # Tipo de volumen
      sizeLimit: 256Mi # Tamaño máximo del volumen
```

&nbsp;

Necesitamos entender lo que está sucediendo en nuestro archivo `pod-emptydir.yaml`, ahora que tenemos nueva información, como `volumeMounts` y `volumes`.

```yaml
    volumeMounts: # lista de volúmenes que se montarán en el contenedor
    - name: primero-emptydir # nombre del volumen
      mountPath: /giropops # directorio donde se montará el volumen 
  volumes: # lista de volúmenes
  - name: primero-emptydir # nombre del volumen
    emptyDir: # tipo de volumen
      sizeLimit: 256Mi # tamaño máximo del volumen
```

&nbsp;

Voy a detallar lo que está sucediendo en nuestro archivo `pod-emptydir.yaml`.

- `volumeMounts`: es una lista de volúmenes que se montarán en el contenedor. En este caso, estamos montando un volumen llamado `primer-emptydir` en el directorio `/giropops` dentro del contenedor.
  - `name`: es el nombre del volumen que se montará en el contenedor.
  - `mountPath`: es el directorio donde se montará el volumen en el contenedor.
- `volumes`: es una lista de volúmenes que se crearán cuando se cree el Pod. En este caso, estamos creando un volumen del tipo `emptyDir` llamado `primer-emptydir`.
  - `name`: es el nombre del volumen que se creará.
  - `emptyDir`: es el tipo de volumen que se creará.
    - `sizeLimit`: es el tamaño máximo del volumen que se creará.

&nbsp;

Estas son configuraciones básicas para crear un volumen del tipo EmptyDir. Si deseas saber más sobre este tipo de volumen, puedes acceder a la [documentación oficial](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir).

Ahora vamos a crear el Pod.

```bash
kubectl create -f pod-emptydir.yaml
```

Luego, verifiquemos si el Pod se ha creado.

```bash
kubectl get pods
```

Puedes ver la salida del comando `kubectl describe pod giropops` para ver el volumen que se ha creado.

```bash
kubectl describe pod giropops
```

Ahora ingresaremos al contenedor.

```bash
kubectl exec -it ubuntu -- bash
```

Ahora crearemos un archivo dentro del directorio `/giropops`.

```bash
touch /giropops/FUNCIONAAAAAA
```

Listo, nuestro archivo ha sido creado dentro del directorio `/giropops`, que es un directorio dentro del volumen de tipo EmptyDir.

Si escribes `mount`, verás que el directorio `/giropops` está montado correctamente dentro de nuestro contenedor.

Cuando elimines el Pod, el volumen de tipo EmptyDir también será eliminado.

```bash
kubectl delete pod giropops
```

&nbsp;

Creemos el Pod nuevamente.

```bash
kubectl create -f pod-emptydir.yaml
```

&nbsp;

Pod creado, ahora ingresamos al contenedor.

```bash
kubectl exec -it ubuntu -- bash
```

Verifiquemos si el archivo que creamos anteriormente aún existe.

```bash
ls /giropops
```

&nbsp;

Como puedes ver, el archivo que creamos anteriormente ya no existe, ya que el volumen de tipo EmptyDir se destruyó cuando se eliminó el Pod.

&nbsp;

##### Clase de Almacenamiento (Storage Class)

Una StorageClass en Kubernetes es un objeto que describe y define diferentes clases de almacenamiento disponibles en el clúster. Estas clases de almacenamiento se pueden usar para aprovisionar PersistentVolumes (PV) dinámicamente de acuerdo con los requisitos de PersistentVolumeClaims (PVC) creados por los usuarios.

La StorageClass es útil para administrar y organizar diferentes tipos de almacenamiento, como almacenamiento en disco rápido y costoso o almacenamiento en disco más lento y económico. Además, la StorageClass se puede utilizar para definir diferentes políticas de retención, aprovisionamiento y otras características de almacenamiento específicas.

Los administradores del clúster pueden crear y administrar varias StorageClasses para permitir que los usuarios finales elijan la clase de almacenamiento adecuada para sus necesidades.

Cada StorageClass se define con un aprovisionador, que es responsable de crear PersistentVolumes dinámicamente según sea necesario. Los aprovisionadores pueden ser internos (proporcionados por Kubernetes en sí) o externos (proporcionados por proveedores de almacenamiento específicos).

Incluso los aprovisionadores pueden ser diferentes para cada proveedor de nube o donde se esté ejecutando Kubernetes. A continuación, listaré algunos aprovisionadores que se utilizan y sus respectivos proveedores:

- `kubernetes.io/aws-ebs`: AWS Elastic Block Store (EBS)
- `kubernetes.io/azure-disk`: Azure Disk
- `kubernetes.io/gce-pd`: Google Compute Engine (GCE) Persistent Disk
- `kubernetes.io/cinder`: OpenStack Cinder
- `kubernetes.io/vsphere-volume`: vSphere
- `kubernetes.io/no-provisioner`: Volumenes locales
- `kubernetes.io/host-path`: Volumenes locales

Y si estás usando Kubernetes en un entorno local, como Minikube, el aprovisionador predeterminado es `kubernetes.io/host-path`, que crea PersistentVolumes en el directorio del host. En Kind, el aprovisionador predeterminado es `rancher.io/local-path`, que crea PersistentVolumes en el directorio del host.

Para ver la lista completa de aprovisionadores, consulta la documentación de Kubernetes en el enlace [https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner](https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner).

&nbsp;

Para ver las `Storage Classes` disponibles en tu clúster, simplemente ejecuta el siguiente comando:

```bash
kubectl get storageclass
```

&nbsp;

```bash
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  21m
```

&nbsp;

Como puedes ver, en Kind, el aprovisionador predeterminado es `rancher.io/local-path`, que crea PersistentVolumes en el directorio del host.

Mientras que en EKS, el aprovisionador predeterminado es `kubernetes.io/aws-ebs`, que crea PersistentVolumes en el EBS de AWS.

```bash
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  6h5m
```

&nbsp;

Veamos los detalles de nuestra `Storage Class` por defecto:

```bash
kubectl describe storageclass standard
```

&nbsp;

```bash
Name:            standard
IsDefaultClass:  Yes
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"},"name":"standard"},"provisioner":"rancher.io/local-path","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}
,storageclass.kubernetes.io/is-default-class=true
Provisioner:           rancher.io/local-path
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
```

&nbsp;

Una cosa que podemos notar es que nuestra `Storage Class` tiene la opción `IsDefaultClass` como `Yes`, lo que significa que es la `Storage Class` predeterminada en nuestro clúster. De esta manera, todos los `Persistent Volume Claims` que no tengan una `Storage Class` definida utilizarán esta `Storage Class` por defecto.

&nbsp;

Creemos una nueva `Storage Class` para nuestro clúster Kubernetes en Kind, con el nombre `local-storage`, y definamos el aprovisionador como `kubernetes.io/host-path`, que crea PersistentVolumes en el directorio del host.

```bash
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: giropops
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

&nbsp;

```bash
kubectl apply -f storageclass.yaml
```

&nbsp;

```bash
storageclass.storage.k8s.io/giropops created
```

&nbsp;

¡Listo! Ahora tenemos una nueva `Storage Class` creada en nuestro clúster Kubernetes en Kind, con el nombre `giropops`, y con el aprovisionador `kubernetes.io/no-provisioner`, que crea PersistentVolumes en el directorio del host.

Para obtener más detalles sobre la `Storage Class` que creamos, ejecuta el siguiente comando:

```bash
kubectl describe storageclass giropops
```

&nbsp;

```bash
Name:            giropops
IsDefaultClass:  No
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"giropops"},"provisioner":"kubernetes.io/no-provisioner","reclaimPolicy":"Retain","volumeBindingMode":"WaitForFirstConsumer"}

Provisioner:           kubernetes.io/no-provisioner
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Retain
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
```

&nbsp;

Recuerda que creamos esta `Storage Class` con el aprovisionador `kubernetes.io/no-provisioner`, pero puedes crear una `Storage Class` con cualquier aprovisionador que desees, como `kubernetes.io/aws-ebs`, que crea PersistentVolumes en EBS de AWS.

&nbsp;

##### PV - Persistent Volume

El PV (Persistent Volume) es un objeto que representa un recurso de almacenamiento físico en un clúster de Kubernetes. Puede ser un disco duro en un nodo del clúster, un dispositivo de almacenamiento en red (NAS) o incluso un servicio de almacenamiento en la nube, como AWS EBS o Google Cloud Persistent Disk.

El PV se utiliza para proporcionar almacenamiento duradero, lo que significa que los datos almacenados en el PV siguen estando disponibles incluso cuando el contenedor se reinicia o se mueve a otro nodo.

En Kubernetes, se pueden usar varias soluciones de almacenamiento como Persistent Volumes (PVs). Estas soluciones se pueden dividir en dos tipos: almacenamiento local y almacenamiento en red. Te daré ejemplos de algunas opciones populares de cada tipo:

**Almacenamiento local:**

- HostPath: Es una forma sencilla de utilizar un directorio en el nodo del clúster como almacenamiento. Es útil principalmente para pruebas y desarrollo, ya que no es apropiado para entornos de producción, dado que los datos almacenados solo están disponibles en el nodo específico.

**Almacenamiento en red:**

- NFS (Network File System): Es un sistema de archivos de red que permite compartir archivos entre varias máquinas en la red. Es una opción común para el almacenamiento compartido en un clúster de Kubernetes.

- iSCSI (Internet Small Computer System Interface): Es un protocolo que permite la conexión de dispositivos de almacenamiento de bloques, como SAN (Storage Area Network), a través de redes IP. Puede usarse como un PV en Kubernetes.

- Ceph RBD (RADOS Block Device): Es una solución de almacenamiento distribuido y altamente escalable que admite almacenamiento de bloques, objetos y archivos. Con RBD, puedes crear volúmenes de bloques virtualizados que se pueden montar como PVs en Kubernetes.

- GlusterFS: Es un sistema de archivos distribuido y escalable que permite crear volúmenes de almacenamiento compartido en varios nodos del clúster. Puede usarse como un PV en Kubernetes.

- Servicios de almacenamiento en la nube: Los proveedores de la nube como AWS, Google Cloud y Microsoft Azure ofrecen soluciones de almacenamiento que se pueden integrar en Kubernetes. Ejemplos incluyen AWS Elastic Block Store (EBS), Google Cloud Persistent Disk y Azure Disk Storage.

Ahora que sabemos qué es un PV, vamos a entender cómo podemos usar `kubectl` para administrar los PVs.

Primero, vamos a listar los PVs que tenemos en nuestro clúster:

```bash
kubectl get pv -A
```

```bash
No resources found
```

&nbsp;

Con el comando anterior estamos listando todos los PVs que tenemos en nuestro clúster, y como puedes ver, todavía no hemos creado ninguno. :)

Vamos a solucionarlo, ¿creamos un PV?

Para ello, creemos un archivo llamado `pv.yaml`:

```yaml
apiVersion: v1 # Versión de la API de Kubernetes
kind: PersistentVolume # Tipo de objeto que estamos creando, en este caso un PersistentVolume
metadata: # Información sobre el objeto
  name: mi-pv # Nombre de nuestro PV
  labels:
    storage: local
spec: # Especificaciones de nuestro PV
  capacity: # Capacidad del PV
    storage: 1Gi # 1 gigabyte de almacenamiento
  accessModes: # Modos de acceso al PV
    - ReadWriteOnce # Modo de acceso ReadWriteOnce, es decir, el PV se puede montar en modo lectura y escritura por un único nodo
  persistentVolumeReclaimPolicy: Retain # Política de reclamación persistente del PV, es decir, el PV no se eliminará cuando se elimine el PVC
  hostPath: # Tipo de almacenamiento que vamos a utilizar, en este caso un hostPath
    path: "/mnt/data" # Ruta del hostPath en nuestro nodo, donde se creará el PV
  storageClassName: standard # Nombre de la clase de almacenamiento que se utilizará
```

&nbsp;

Antes de crear el PV, es importante hablar un poco más sobre el archivo que creamos, especialmente sobre lo que tenemos de diferente en comparación con otros archivos que hemos creado hasta ahora.

- `kind: PersistentVolume`: Aquí estamos definiendo el tipo de objeto que estamos creando, en este caso, un `PersistentVolume`.

Otro punto importante a mencionar es la sección `spec`, donde definimos las especificaciones de nuestro PV.

- `spec.capacity.storage`: Aquí estamos definiendo la capacidad de nuestro PV, en este caso, 1 gigabyte de almacenamiento.
- `spec.accessModes`: Aquí estamos definiendo los modos de acceso al PV, en este caso, el modo `ReadWriteOnce`, lo que significa que el PV se puede montar como lectura y escritura por un único nodo. Aquí tenemos algunos modos de acceso adicionales:
  - `ReadOnlyMany`: El PV puede montarse como solo lectura por varios nodos.
  - `ReadWriteMany`: El PV puede montarse como lectura y escritura por varios nodos.
- `spec.persistentVolumeReclaimPolicy`: Aquí estamos definiendo la política de reclamación persistente del PV, en este caso, la política `Retain`, que significa que el PV no se eliminará cuando se elimine el PVC. Aquí tenemos algunas políticas adicionales:
  - `Recycle`: El PV se eliminará cuando se elimine el PVC, pero antes de eso se limpiará, es decir, se eliminarán todos los datos.
  - `Delete`: El PV se eliminará cuando se elimine el PVC.

Otra sección importante es `hostPath`, donde definimos el tipo de almacenamiento que vamos a utilizar, en este caso, `hostPath`. Detallaré a continuación los tipos de almacenamiento que podemos usar:

- `hostPath`: Es una forma sencilla de utilizar un directorio en el nodo del clúster como almacenamiento. Es útil principalmente para pruebas y desarrollo, ya que no es apropiado para entornos de producción, ya que los datos almacenados solo están disponibles en el nodo específico. Es ideal en escenarios de prueba con solo un nodo.
- `nfs`: Es un sistema de archivos de red que permite compartir archivos entre varias máquinas en la red. Es una opción común para el almacenamiento compartido en un clúster de Kubernetes.
- `iscsi`: Es un protocolo que permite la conexión de dispositivos de almacenamiento de bloques, como SAN (Storage Area Network), a través de redes IP.
- `csi`: Que significa Container Storage Interface, es un recurso que permite la integración de soluciones de almacenamiento de terceros con Kubernetes. El CSI permite a los proveedores de almacenamiento implementar sus propios complementos de almacenamiento e integrarlos con Kubernetes. Gracias al CSI, podemos usar soluciones de almacenamiento de terceros, como AWS EBS, Google Cloud Persistent Disk y Azure Disk Storage.
- `cephfs`: Es un sistema de archivos distribuido y escalable que permite crear volúmenes de almacenamiento compartido en varios nodos del clúster.
- `local`: Es un tipo de almacenamiento que permite crear volúmenes locales, donde puedes especificar la ruta del directorio donde se almacenarán los datos. Es útil principalmente para pruebas y desarrollo, ya que no es apropiado para entornos de producción, ya que los datos almacenados solo están disponibles en el nodo específico. La diferencia entre `hostPath` y `local` es que `local` es un recurso nativo de Kubernetes, mientras que `hostPath` es un recurso de Kubernetes que utiliza el recurso nativo de Docker y no se recomienda cuando hay más de un nodo en el clúster.
- `fc`: Es un protocolo que permite la conexión de dispositivos de almacenamiento de bloques utilizando redes de fibra óptica. Es una opción común para el almacenamiento compartido en un clúster de Kubernetes.

He enumerado solo los tipos de almacenamiento más comunes, pero puedes encontrar más información sobre los tipos de almacenamiento en la [Documentación de Kubernetes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes).

Por último, tenemos la sección `storageClassName`, donde definimos el nombre de la clase de almacenamiento a la que agregaremos el PV.

&nbsp;

A medida que avanzamos en el entrenamiento, conoceremos más detalles sobre cada tipo de almacenamiento.

Listo, todo está preparado para crear el PV.

```bash
kubectl apply -f pv.yaml
persistentvolume/mi-pv created
```

&nbsp;

Vamos a listar nuestro PV para ver si se creó correctamente.

```bash
kubectl get pv
```

&nbsp;

```bash
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
mi-pv   1Gi        RWO            Retain           Available           standard                10s
```

&nbsp;

El PV se creó con éxito.

Podemos ver que nuestro PV tiene el estado `Available`, lo que significa que está disponible para ser utilizado por un PVC.

Vamos a ver los detalles de nuestro PV.

```bash
kubectl describe pv mi-pv
```

&nbsp;

```bash
Name:            mi-pv
Labels:          storage=local
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    standard
Status:          Available
Claim:           
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /mnt/data
    HostPathType:  
Events:            <none>
```

&nbsp;

De esta manera, estamos creando el PV utilizando el provisionador `hostPath`, que es un provisionador para ser utilizado en pruebas y desarrollo, ya que los datos almacenados solo están disponibles en el nodo específico. Ahora vamos a otro ejemplo, pero esta vez utilizando el provisionador `nfs`, que es un sistema de archivos de red que permite compartir archivos entre varias máquinas en la red.

&nbsp;

Lo primero que haremos es crear el directorio que se compartirá entre los nodos del clúster. Recuerda que para este ejemplo, estoy utilizando una máquina Linux para crear la compartición NFS, pero puedes utilizar cualquier otro sistema operativo que admita NFS.

```bash
mkdir /mnt/nfs
```

&nbsp;

Necesitamos instalar los paquetes `nfs-kernel-server` y `nfs-common` para instalar el servidor NFS y el cliente NFS.

```bash
sudo apt-get install nfs-kernel-server nfs-common
```

&nbsp;

Vamos a editar el archivo `/etc/exports`, que es el archivo de configuración de NFS, y agregar el directorio que se compartirá entre los nodos del clúster.

```bash
sudo vi /etc/exports
```

&nbsp;

```bash
/mnt/nfs *(rw,sync,no_root_squash,no_subtree_check)
```

&nbsp;

Donde:

- `/mnt/nfs`: es el directorio que deseas compartir.

- `*`: permite que cualquier host acceda al directorio compartido. Para mayor seguridad, puedes reemplazar `*` por un rango de direcciones IP o por direcciones IP específicas de los clientes que tendrán acceso al directorio compartido. Por ejemplo, `192.168.1.0/24` permitirá que todos los hosts en la subred `192.168.1.0/24` accedan al directorio compartido.

- `rw`: otorga permisos de lectura y escritura a los clientes.

- `sync`: asegura que las solicitudes de escritura solo se confirmen cuando los cambios realmente se hayan escrito en el disco.

- `no_root_squash`: permite que el usuario root en un cliente NFS acceda a los archivos como root. De lo contrario, el acceso se limitaría a un usuario no privilegiado.

- `no_subtree_check`: desactiva la verificación de subárbol, lo que puede mejorar la confiabilidad en algunos casos. La verificación de subárbol normalmente verifica si un archivo forma parte del directorio exportado.

Ahora vamos a indicarle al NFS que el directorio `/mnt/nfs` está disponible para compartir.

```bash
sudo exportfs -arv
```

&nbsp;

¡Fantástico! Ahora verifiquemos si el NFS está funcionando correctamente.

```bash
showmount -e
```

&nbsp;

```bash
Export list for localhost:
/mnt/nfs *
```

&nbsp;

¡Listo! Nuestro NFS está funcionando correctamente. \o/

Ahora que tenemos nuestro NFS funcionando, creemos el StorageClass para el provisionador `nfs`.

Para este ejemplo, crearemos un archivo llamado `storageclass-nfs.yaml` y agregaremos el siguiente contenido.

```yaml
apiVersion: storage.k8s.io/v1 # Versión de la API de Kubernetes
kind: StorageClass # Tipo de objeto que estamos creando, en este caso, un StorageClass
metadata: # Información sobre el objeto
  name: nfs # Nombre de nuestro StorageClass
provisioner: kubernetes.io/no-provisioner # Provisionador que se utilizará para crear el PV
reclaimPolicy: Retain # Política de reclamación del PV, es decir, el PV no se eliminará cuando se elimine el PVC
volumeBindingMode: WaitForFirstConsumer
parameters: # Parámetros que se utilizarán por el provisionador
  archiveOnDelete: "false" # Parámetro que indica si los datos del PV deben archivarse cuando se elimine el PV
```

&nbsp;

Kubernetes no tiene un provisionador `nfs` nativo, por lo que no es posible hacer que el provisionador `kubernetes.io/no-provisioner` cree automáticamente un PV utilizando un servidor NFS. Para que esto sea posible, necesitamos utilizar un provisionador `nfs` externo, pero eso no es el enfoque en este momento. Por lo tanto, crearemos nuestro PV manualmente, después de todo, ¡ya somos expertos en PVs, verdad?

¡Vamos allá!

Entonces, ya podemos crear el PV y asociarlo con el Storage Class

. Para ello, creemos un nuevo archivo llamado `pv-nfs.yaml` y agreguemos el siguiente contenido.

```yaml
apiVersion: v1 # Versión de la API de Kubernetes
kind: PersistentVolume # Tipo de objeto que estamos creando, en este caso, un PersistentVolume
metadata: # Información sobre el objeto
  name: mi-pv-nfs # Nombre de nuestro PV
  labels:
    storage: nfs # Etiqueta que se utilizará para identificar el PV
spec: # Especificaciones de nuestro PV
  capacity: # Capacidad del PV
    storage: 1Gi # 1 gigabyte de almacenamiento
  accessModes: # Modos de acceso al PV
    - ReadWriteOnce # Modo de acceso ReadWriteOnce, es decir, el PV se puede montar como lectura y escritura por un único nodo
  persistentVolumeReclaimPolicy: Retain # Política de reclamación del PV, es decir, el PV no se eliminará cuando se elimine el PVC
  nfs: # Tipo de almacenamiento que vamos a utilizar, en este caso, nfs
    server: IP_DEL_SERVIDOR_NFS # Dirección IP del servidor NFS
    path: "/mnt/nfs" # Compartición del servidor NFS
  storageClassName: nfs # Nombre de la clase de almacenamiento que se utilizará
```

&nbsp;

Ahora podemos crear nuestro PV.

```bash
kubectl apply -f pv-nfs.yaml
```

&nbsp;

```bash
persistentvolume/mi-pv created
```

&nbsp;

Todo está bien con nuestro PV, ahora creo que podemos pasar al próximo tema, que es el PVC.

&nbsp;

##### PVC - Persistent Volume Claim

El PVC es una solicitud de almacenamiento realizada por usuarios o aplicaciones en el clúster de Kubernetes. Permite a los usuarios solicitar un volumen específico en función del tamaño, el tipo de almacenamiento y otras características. El PVC actúa como una "firma" que reclama un PV para ser utilizado por un contenedor. Kubernetes intenta asociar automáticamente un PVC con un PV compatible para asegurarse de que el almacenamiento se asigna correctamente.

A través del PVC, las personas pueden abstraer los detalles de cada tipo de almacenamiento, lo que permite una mayor flexibilidad y portabilidad entre diferentes entornos y proveedores de infraestructura. También permite a los usuarios solicitar volúmenes con diferentes características, como tamaño, tipo de almacenamiento y modo de acceso.

Cada PVC está asociado a una `Storage Class` o a un `Persistent Volume` (PV). La `Storage Class` es un objeto que describe y define diferentes clases de almacenamiento disponibles en el clúster. El `Persistent Volume`, por otro lado, es un recurso que representa un volumen de almacenamiento disponible para su uso por el clúster.

Vamos a crear nuestro primer PVC para el PV que creamos anteriormente.

Para ello, crearemos un archivo llamado `pvc.yaml` y añadiremos el siguiente contenido:

```yaml
apiVersion: v1 # versión de la API de Kubernetes
kind: PersistentVolumeClaim # tipo de recurso, en este caso, un PersistentVolumeClaim
metadata: # metadatos del recurso
  name: mi-pvc # nombre del PVC
spec: # especificación del PVC
  accessModes: # modo de acceso al volumen
    - ReadWriteOnce # modo de acceso RWO, es decir, solo lectura y escritura por un nodo
  resources: # recursos del PVC
    requests: # solicitud de recursos
      storage: 1Gi # tamaño del volumen que se solicitará
  storageClassName: nfs # nombre de la clase de almacenamiento que se utilizará
  selector: # selector de etiquetas
    matchLabels: # etiquetas que se utilizarán para seleccionar el PV
      storage: nfs # etiqueta que se utilizará para seleccionar el PV
```

Aquí estamos definiendo nuestro PVC, y hablaré un poco sobre las secciones principales de nuestro archivo.

La sección `accessModes` es donde definimos el modo de acceso al volumen, que puede ser `ReadWriteOnce` (RWO), `ReadOnlyMany` (ROM) o `ReadWriteMany` (RWM). RWO significa que el volumen se puede montar como solo lectura y escritura por un nodo. ROM significa que el volumen se puede montar como solo lectura por varios nodos. RWM significa que el volumen se puede montar como lectura y escritura por varios nodos.

La sección `resources` es donde definimos los recursos que el PVC solicitará. En este caso, estamos solicitando un volumen de 1Gi.

Todavía tenemos la sección `storageClassName`, donde definimos el nombre de la clase de almacenamiento que asociaremos al PVC.

Y por último, la sección `selector`, donde definimos el selector de etiquetas que se utilizará para seleccionar el PV que se asociará al PVC.

Creemos nuestro PVC.

```bash
kubectl apply -f pvc.yaml
persistentvolumeclaim/mi-pvc created
```

Listo, ¡PVC creado! Verifiquemos si se creó correctamente.

```bash
kubectl get pvc
```

```bash
NAME      STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mi-pvc   Pending                                      nfs            5s
```

Ahí está, pero el estado es `Pendiente`. Veamos si hay alguna información que nos ayude a entender qué está sucediendo.

```bash
kubectl describe pvc mi-pvc
```

```bash
Name:          mi-pvc
Namespace:     default
StorageClass:  nfs
Status:        Pending
Volume:        
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                Age                 From                         Message
  ----    ------                ----                ----                         -------
  Normal  WaitForFirstConsumer  15s (x4 over 1m5s)  persistentvolume-controller  waiting for first consumer to be created before binding
```

Observa la parte de los eventos, dice que el PVC está esperando a que se cree el primer consumidor antes de vincularlo. ¿Qué significa esto?

Significa que el PVC está esperando que se cree un Pod para que pueda vincularse al PV. ¡Así que creemos nuestro Pod!

Usaremos el conocido Nginx como ejemplo, así que crearemos un archivo llamado `pod.yaml` y añadiremos el siguiente contenido:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
    volumeMounts:
    - name: mi-pvc
      mountPath: /usr/share/nginx/html
  volumes:
  - name: mi-pvc
    persistentVolumeClaim:
      claimName: mi-pvc
```

Básicamente, lo que estamos haciendo aquí es:

- Crear un Pod con el nombre `nginx-pod`;
- Utilizar la imagen `nginx:latest` como base;
- Exponer el puerto 80;
- Definir un volumen llamado `mi-pvc` y montarlo en la ruta `/usr/share/nginx/html` dentro del contenedor;
- Por último, definir que el volumen `mi-pvc` es un `PersistentVolumeClaim` y que el nombre del PVC es `mi-pvc`.

Este fragmento del archivo `pod.yaml` es responsable de montar el volumen `mi-pvc` en la ruta `/usr/share/nginx/html` dentro del contenedor.

```yaml
    volumeMounts: # montar el volumen en el contenedor
    - name: mi-pvc  # nombre del volumen
      mountPath: /usr/share/nginx/html # ruta donde se montará el volumen en el contenedor
  volumes

: # definir el volumen que se utilizará en el Pod
  - name: mi-pvc # nombre del volumen
    persistentVolumeClaim: # tipo de volumen, en este caso, un PersistentVolumeClaim
      claimName: mi-pvc # nombre del PVC
```

¡Vamos a crear nuestro Pod!

```bash
kubectl apply -f pod.yaml
pod/nginx-pod created
```

Comprobemos si todo está correcto con nuestro Pod.

```bash
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          21s
```

¡Parece que sí! Ahora verifiquemos si nuestro PVC se vinculó al PV.

```bash
kubectl get pvc
```

```bash
NAME      STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mi-pvc   Bound    mi-pv-nfs   1Gi        RWO            nfs            3m8s
```

¡Vínculo realizado!

Verifiquemos si hay algo nuevo en la salida de `get pv`.

```bash
kubectl get pv
```

```bash
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   REASON   AGE
mi-pv-nfs   1Gi        RWO            Retain           Bound    default/mi-pvc   nfs                     3m42s
```

¡Ahora sí! Tenemos un PV con el estado `Bound` y un PVC también con el estado `Bound`. ¡Éxito!

Para finalizar nuestra primera prueba, comprobemos si nuestro Pod está utilizando nuestro volumen.

```bash
kubectl describe pod nginx-pod
```

```bash
Name:             nginx-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             kind-linuxtips-worker/172.18.0.4
Start Time:       Tue, 11 Apr 2023 01:47:48 +0200
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.2.3
IPs:
  IP:  10.244.2.3
Containers:
  nginx:
    Container ID:   containerd://b5946958f63c392c8a77b06811f7859113a1dd260ebcc2113579af6b32c4f549
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:2ab30d6ac53580a6db8b657abf0f68d75360ff5cc1670a85acb5bd85ba1b19c0
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 11 Apr 2023 01:47:50 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /usr/share/nginx/html from mi-pvc (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8874f (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  mi-pvc:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  mi-pvc
    ReadOnly:   false
  kube-api-access-8874f:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  8s    default-scheduler  Successfully assigned default/nginx-pod to kind-linuxtips-worker
  Normal  Pulling    7s    kubelet            Pulling image "nginx:latest"
  Normal  Pulled     6s    kubelet            Successfully pulled image "nginx:latest" in 799.112685ms (799.119928ms including waiting)
  Normal  Created    6s    kubelet            Created container nginx
  Normal  Started    6s    kubelet            Started container nginx
```

¡Listo! ¡Nuestro Pod está utilizando nuestro volumen! Todo el contenido creado dentro del Pod se almacenará en nuestro volumen, y aunque el Pod se elimine, el contenido no se perderá.

Ahora probemos nuestro volumen. Creemos un archivo HTML simple en el directorio `/mnt/data` de nuestro servidor NFS.

```bash
echo "<h1>GIROPOPS STRIGUS GIRUS</h1>" > /mnt/data/index.html
```

Comprobemos ahora si nuestro archivo se creó.

```bash
kubectl exec -it nginx-pod -- ls /usr/share/nginx/html
```

```bash
index.html
```

¡Ahí está! Hagamos un `curl` desde dentro del Pod para comprobar si Nginx está sirviendo nuestro archivo.

```bash
kubectl exec -it nginx-pod -- curl localhost
```

```bash
<h1>GIROPOPS STRIGUS GIRUS</h1>
```

¡Todo funciona maravillosamente bien! :D

### Tu tarea

Tu tarea es crear un despliegue de Nginx que tenga un volumen montado en `/usr/share/nginx/html`. Siéntete libre de utilizar diferentes tipos de provisionadores o diferentes tipos de PV. Déjate guiar por tu imaginación y aprovecha para explorar diferentes aplicaciones.

¡Fin del Día 6!

Durante el Día 6, ¡aprendiste todo sobre los volúmenes en Kubernetes! Aprendiste qué es una `Storage Class`, un `PV` y un `PVC`, y lo más importante, ¡aprendiste todo esto en la práctica! Ahora puedes comenzar a aplicar tus nuevos conocimientos para mejorar los despliegues en tu clúster. ¡Espero que hayas disfrutado y aprendido mucho!

¡Hasta la próxima!
