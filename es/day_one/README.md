
# Simplificando Kubernetes

## Día 1

### Índice

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 1](#día-1)
    - [Índice](#índice)
    - [¿Qué vamos a ver hoy?](#qué-vamos-a-ver-hoy)
    - [Início de la clase Día 1](#início-de-la-clase-día-1)
    - [¿Cual distribución GNU/Linux debo utilizar?](#cual-distribución-gnulinux-debo-utilizar)
    - [Algunos sitios web que debemos visitar](#algunos-sitios-web-que-debemos-visitar)
    - [El Container Engine](#el-container-engine)
      - [OCI - Open Container Initiative](#oci---open-container-initiative)
      - [El Container Runtime](#el-container-runtime)
    - [¿Qué es Kubernetes?](#qué-es-kubernetes)
    - [Arquitectura de k8s](#arquitectura-de-k8s)
    - [Puertos de los que debemos preocuparnos](#puertos-de-los-que-debemos-preocuparnos)
      - [CONTROL PLANE](#control-plane)
    - [Conceptos clave de k8s](#conceptos-clave-de-k8s)
    - [Instalación y personalización de Kubectl](#instalación-y-personalización-de-kubectl)
      - [Instalación de Kubectl en GNU/Linux](#instalación-de-kubectl-en-gnulinux)
      - [Instalación de Kubectl en macOS](#instalación-de-kubectl-en-macos)
      - [Instalación de Kubectl en Windows](#instalación-de-kubectl-en-windows)
    - [Personalización de kubectl](#personalización-de-kubectl)
      - [Auto-completado](#auto-completado)
      - [Creando un alias para kubectl](#creando-un-alias-para-kubectl)
    - [Creando un clúster Kubernetes](#creando-un-clúster-kubernetes)
    - [Creando el clúster en tu máquina local](#creando-el-clúster-en-tu-máquina-local)
      - [Minikube](#minikube)
        - [Requisitos básicos](#requisitos-básicos)
        - [Instalación de Minikube en GNU/Linux](#instalación-de-minikube-en-gnulinux)
        - [Instalación de Minikube en MacOS](#instalación-de-minikube-en-macos)
        - [Instalación de Minikube en Microsoft Windows](#instalación-de-minikube-en-microsoft-windows)
        - [Iniciando, deteniendo y eliminando Minikube](#iniciando-deteniendo-y-eliminando-minikube)
        - [Bien, ¿cómo puedo saber si todo está funcionando correctamente?](#bien-cómo-puedo-saber-si-todo-está-funcionando-correctamente)
        - [Ver detalles sobre el clúster](#ver-detalles-sobre-el-clúster)
        - [Descubriendo la dirección de Minikube](#descubriendo-la-dirección-de-minikube)
        - [Accediendo a la máquina de Minikube a través de SSH](#accediendo-a-la-máquina-de-minikube-a-través-de-ssh)
        - [Panel de control de Minikube](#panel-de-control-de-minikube)
        - [Logs de Minikube](#logs-de-minikube)
        - [Eliminar el clúster](#eliminar-el-clúster)
      - [Kind](#kind)
        - [Instalación en GNU/Linux](#instalación-en-gnulinux)
        - [Instalación en MacOS](#instalación-en-macos)
        - [Instalación en Windows](#instalación-en-windows)
          - [Instalación en Windows via Chocolatey](#instalación-en-windows-via-chocolatey)
        - [Creando un clúster con Kind](#creando-un-clúster-con-kind)
        - [Creando un clúster con múltiples nodos locales usando Kind](#creando-un-clúster-con-múltiples-nodos-locales-usando-kind)
    - [Primeros pasos en k8s](#primeros-pasos-en-k8s)
      - [Verificación de namespaces y pods](#verificación-de-namespaces-y-pods)
        - [Ejecutando nuestro primer pod en k8s](#ejecutando-nuestro-primer-pod-en-k8s)
        - [Ejecutando nuestro primer pod en k8s](#ejecutando-nuestro-primer-pod-en-k8s-1)
      - [Exponiendo el pod y creando un Service](#exponiendo-el-pod-y-creando-un-service)
      - [Limpiando todo y yendo a casa](#limpiando-todo-y-yendo-a-casa)

&nbsp;

### ¿Qué vamos a ver hoy?

Durante el Día 1 vamos a comprender qué es un contenedor, vamos a hablar sobre la importancia del container runtime y del container engine. Durante el Día 1 vamos a entender qué es Kubernetes y su arquitectura, vamos a hablar sobre el control plane, los workers, el apiserver, el scheduler, el controller y mucho más.
Aquí es donde vamos a crear nuestro primer clúster Kubernetes y desplegar un pod de Nginx.
El Día 1 está diseñado para que me sienta más cómodo con Kubernetes y sus conceptos iniciales.

&nbsp;

### Início de la clase Día 1

&nbsp;

### ¿Cual distribución GNU/Linux debo utilizar?

Debido al hecho de que algunas herramientas importantes, como ``systemd`` y ``journald``, se han convertido en estándar en la mayoría de las principales distribuciones disponibles hoy en día, no deberías encontrar problemas para seguir el entrenamiento si optas por alguna de ellas, como Ubuntu, Debian, CentOS y similares.

&nbsp;

### Algunos sitios web que debemos visitar

A continuación, tenemos los sitios web oficiales del proyecto Kubernetes:

- [https://kubernetes.io](https://kubernetes.io)

- [https://github.com/kubernetes/kubernetes/](https://github.com/kubernetes/kubernetes/)

- [https://github.com/kubernetes/kubernetes/issues](https://github.com/kubernetes/kubernetes/issues)

&nbsp;
A continuación, tenemos las páginas oficiales de las certificaciones de Kubernetes (CKA, CKAD y CKS):

- [https://www.cncf.io/certification/cka/](https://www.cncf.io/certification/cka/)

- [https://www.cncf.io/certification/ckad/](https://www.cncf.io/certification/ckad/)

- [https://www.cncf.io/certification/cks/](https://www.cncf.io/certification/cks/)

&nbsp;

### El Container Engine

Antes de comenzar a hablar un poco más sobre Kubernetes, primero debemos entender algunos componentes importantes en el ecosistema de Kubernetes. Uno de estos componentes es el Container Engine.

El *Container Engine* es el encargado de gestionar las imágenes y volúmenes; es quien garantiza que los recursos que utilizan los contenedores estén debidamente aislados, incluyendo la vida del contenedor, el almacenamiento, la red, entre otros.

Hoy en día, tenemos varias opciones para utilizar como *Container Engine*, ya que hasta hace poco solo teníamos a Docker para este propósito

Opciones como Docker, CRI-O y Podman son bien conocidas y están preparadas para entornos de producción. Docker, como todos saben, es el Container Engine más popular y utiliza como Container Runtime (Container Runtime) el containerd.

¿Container Runtime? ¿Qué es eso?

Tranquilo/a, te lo explicaré en un momento, pero antes debemos hablar sobre la OCI. :)

&nbsp;

#### OCI - Open Container Initiative

OCI es una organización sin ánimo de lucro cuyo objetivo es estandarizar la creación de contenedores para que puedan ejecutarse en cualquier entorno. OCI fue fundada en 2015 por Docker, CoreOS, Google, IBM, Microsoft, Red Hat y VMware, y actualmente forma parte de la Fundación Linux.

El proyecto principal creado por OCI es *runc*, que es el principal container runtime de nivel bajo y es utilizado por diferentes *Container Engines*, como Docker.
*runc* es un proyecto de código abierto escrito en Go y su código está disponible en GitHub.

Ahora sí, ya podemos hablar de lo que es el Container Runtime.

&nbsp;

#### El Container Runtime

Para que sea posible ejecutar los contenedores en los nodos, es necesario tener un *Container Runtime* instalado en cada uno de ellos.

El *Container Runtime* es el encargado de ejecutar los contenedores en los nodos. Cuando estás utilizando Docker o Podman para ejecutar contenedores en tu máquina, por ejemplo, estás utilizando algún *Container Runtime*, o más precisamente, tu Container Engine está utilizando algún *Container Runtime*.

Tenemos tres tipos de *Container Runtime*:

- Low-level: son los *Container Runtime* que se ejecutan directamente en el Kernel, como runc, crun y runsc.

- High-level: son los *Container Runtime* que se ejecutan a través de un *Container Engine*, como containerd, CRI-O y Podman.

- Sandbox: son los *Container Runtime* que se ejecutan a través de un *Container Engine* y son responsables de ejecutar contenedores de manera segura en unikernels o utilizando algún proxy para comunicarse con el Kernel. gVisor es un ejemplo de *Container Runtime* tipo Sandbox.

- Virtualized: son los *Container Runtime* que se ejecutan a través de un *Container Engine* y son responsables de ejecutar contenedores de manera segura en máquinas virtuales. El rendimiento aquí es un poco menor que cuando se ejecuta nativamente.
Kata Containers es un ejemplo de *Container Runtime* tipo Virtualized.

&nbsp;

### ¿Qué es Kubernetes?

**Versión resumida:**

El proyecto Kubernetes fue desarrollado por Google a mediados de 2014 para actuar como un orquestador de contenedores para la empresa. Kubernetes (k8s), cuyo término en griego significa "timonel", es un proyecto de código abierto que se basa en el diseño y desarrollo del proyecto Borg, también de Google [1](https://kubernetes.io/blog/2015/04/borg-predecessor-to-kubernetes/). Algunos otros productos disponibles en el mercado, como Apache Mesos y Cloud Foundry, también surgieron a partir del proyecto Borg.

Dado que Kubernetes es una palabra difícil de pronunciar y escribir, la comunidad simplemente lo apodó como **k8s**, siguiendo el estándar [i18n](http://www.i18nguy.com/origini18n.html) (la letra "k" seguida de ocho letras y la "s" al final), pronunciándolo simplemente como "kates".

**Versión extensa:**

Prácticamente todo el software desarrollado en Google se ejecuta en contenedores [2](https://www.enterpriseai.news/2014/05/28/google-runs-software-containers/). Google ha estado gestionando contenedores a gran escala durante más de una década, cuando no se hablaba tanto de ello. Para satisfacer la demanda interna, algunos desarrolladores de Google construyeron tres sistemas diferentes de gestión de contenedores: **Borg**, **Omega** y **Kubernetes**. Cada sistema fue ampliamente influenciado por su predecesor, aunque se desarrollaron por diferentes motivos.

El primer sistema de gestión de contenedores desarrollado en Google fue Borg, construido para gestionar servicios de larga duración y trabajos por lotes, que anteriormente eran manejados por dos sistemas: **Babysitter** y **Global Work Queue**. El último influyó fuertemente en la arquitectura de Borg, pero se centraba en la ejecución de trabajos por lotes. Borg sigue siendo el principal sistema de gestión de contenedores dentro de Google debido a su escala, variedad de recursos y extrema robustez.

El segundo sistema fue Omega, descendiente de Borg. Fue impulsado por el deseo de mejorar la ingeniería de software en el ecosistema de Borg. Este sistema aplicó muchos de los patrones exitosos de Borg, pero se construyó desde cero para tener una arquitectura más coherente. Muchas de las innovaciones de Omega se incorporaron posteriormente a Borg.

El tercer sistema fue Kubernetes. Fue concebido y desarrollado en un mundo en el que los desarrolladores externos se interesaban por los contenedores y Google estaba desarrollando un negocio en crecimiento, que es la venta de infraestructura de nube pública.

Kubernetes es de código abierto, a diferencia de Borg y Omega, que se desarrollaron como sistemas puramente internos de Google. Kubernetes se desarrolló con un enfoque más fuerte en la experiencia de los desarrolladores que escriben aplicaciones que se ejecutan en un clúster: su objetivo principal es facilitar la implementación y gestión de sistemas distribuidos, aprovechando al máximo el uso eficiente de recursos de memoria y procesamiento que permiten los contenedores.

Esta información se extrajo y adaptó de este [artículo](https://static.googleusercontent.com/media/research.google.com/pt-BR//pubs/archive/44843.pdf), que describe las lecciones aprendidas con el desarrollo y operación de estos sistemas.
&nbsp;

### Arquitectura de k8s

Al igual que otros orquestadores disponibles, k8s también sigue un modelo de *control plane/workers*, constituyendo así un *cluster*, en el cual para su funcionamiento se recomienda tener al menos tres nodos: el nodo *control-plane*, responsable (por defecto) de la gestión del *cluster*, y los demás como *workers*, ejecutores de las aplicaciones que deseamos correr en este *cluster*.

Es posible crear un cluster Kubernetes ejecutándolo en un solo nodo, sin embargo, esto es recomendado únicamente para propósitos de estudio y nunca debe ser ejecutado en un entorno de producción.

Si deseas utilizar Kubernetes en tu máquina local, en tu escritorio, existen varias soluciones que crearán un cluster Kubernetes utilizando máquinas virtuales o Docker, por ejemplo.

Con esto podrás tener un cluster Kubernetes con varios nodos, aunque todos se ejecutan en tu máquina local, en tu escritorio.

Algunos ejemplos son:

- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start): Una herramienta para ejecutar contenedores Docker que simulan el funcionamiento de un cluster Kubernetes. Se utiliza para fines didácticos, desarrollo y pruebas. **Kind no debe ser utilizado en producción**;

- [Minikube](https://github.com/kubernetes/minikube): Una herramienta para implementar un cluster Kubernetes local con solo un nodo. Ampliamente utilizado para fines didácticos, desarrollo y pruebas. **Minikube no debe ser utilizado en producción**;

- [MicroK8S](https://microk8s.io): Desarrollado por [Canonical](https://canonical.com), la misma empresa que desarrolla [Ubuntu](https://ubuntu.com). Puede ser utilizado en varias distribuciones y **puede ser utilizado en entornos de producción**, especialmente para *Edge Computing* e IoT (*Internet de las cosas*);

- [k3s](https://k3s.io): Desarrollado por [Rancher Labs](https://rancher.com), es un competidor directo de MicroK8s y puede ser ejecutado incluso en Raspberry Pi;

- [k0s](https://k0sproject.io): Desarrollado por [Mirantis](https://www.mirantis.com), la misma empresa que adquirió la parte empresarial de [Docker](https://www.docker.com). Es una distribución de Kubernetes con todos los recursos necesarios para funcionar en un solo binario, lo que proporciona simplicidad en la instalación y mantenimiento del cluster. Se pronuncia como "kay-zero-ess" y tiene como objetivo reducir el esfuerzo técnico y el desgaste en la instalación de un cluster Kubernetes, de ahí que su nombre haga alusión a *Zero Friction*. **k0s puede ser utilizado en entornos de producción**;

- **API Server**: Es uno de los componentes principales de k8s. Este componente proporciona una API que utiliza JSON sobre HTTP para la comunicación. Para esto, se utiliza principalmente la utilidad ``kubectl`` por parte de los administradores para comunicarse con los demás nodos, como se muestra en el gráfico (#PV-Revisar donde está el gráfico). Estas comunicaciones entre componentes se establecen a través de peticiones [REST](https://restfulapi.net);

- **etcd**: etcd es un almacén de datos distribuido clave-valor que k8s utiliza para almacenar las especificaciones, el estado y las configuraciones del *cluster*. Todos los datos almacenados en etcd se manipulan únicamente a través de la API. Por razones de seguridad, etcd se ejecuta de forma predeterminada solo en nodos clasificados como *control plane* en el *cluster* k8s, pero también se pueden ejecutar en *clusters* externos específicos para etcd, por ejemplo;

- **Scheduler**: El *scheduler* es responsable de seleccionar el nodo que alojará un *pod* específico (la unidad más pequeña de un *cluster* k8s - no te preocupes por esto por ahora, hablaremos más sobre ello más adelante) para su ejecución. Esta selección se basa en la cantidad de recursos disponibles en cada nodo, así como en el estado de cada uno de los nodos del *cluster*, garantizando así una distribución equitativa de los recursos. Además, la selección de los nodos en los que se ejecutarán uno o más pods también puede tener en cuenta políticas definidas por el usuario, como afinidad, ubicación de los datos que las aplicaciones deben leer, etc;

- **Controller Manager**: Es el *controller manager* quien se asegura de que el *cluster* esté en el último estado definido en etcd. Por ejemplo: si en etcd se configura un *deploy* para tener diez réplicas de un *pod*, es el *controller manager* quien verificará si el estado actual del *cluster* coincide con este estado y, si no lo hace, buscará conciliar ambos;

- **Kubelet**: El *kubelet* puede verse como el representante de k8s que se ejecuta en los nodos workers. En cada nodo worker debe haber un agente Kubelet en ejecución. Kubelet es responsable de gestionar los *pods* que son dirigidos por el *controller* del *cluster* en los nodos, de modo que Kubelet puede iniciar, detener y mantener los contenedores y los pods en funcionamiento según lo instruido por el controlador del cluster;

- **Kube-proxy**: Actúa como un *proxy* y un *balanceador de carga*. Este componente es responsable de enrutar solicitudes a los *pods* correctos, así como de encargarse de la parte de la red del nodo;

&nbsp;

### Puertos de los que debemos preocuparnos

#### CONTROL PLANE

Protocolo|Dirección|Rango de Puertos|Propósito|Utilizado Por
--------|---------|----------|-------|-------
TCP|Entrada|6443*|Servidor de API de Kubernetes|Todos
TCP|Entrada|2379-2380|Cliente API de servidor etcd|kube-apiserver, etcd
TCP|Entrada|10250|API Kubelet|Propio, Control plane
TCP|Entrada|10251|kube-scheduler|Propio
TCP|Entrada|10252|kube-controller-manager|Propio

- Cualquier puerto marcado con * es personalizable. Asegúrate de que el puerto modificado también esté abierto.

&nbsp;
**WORKERS**

Protocolo|Dirección|Rango de Puertos|Propósito|Utilizado Por
--------|---------|----------|-------|-------
TCP|Entrada|10250|API Kubelet|Propio, Control plane
TCP|Entrada|30000-32767|NodePort|Servicios Todos

&nbsp;

### Conceptos clave de k8s

Es importante saber que la forma en que k8s gestiona los contenedores es ligeramente diferente a otros orquestadores, como Docker Swarm, principalmente debido a que no maneja los contenedores directamente, sino a través de *pods*. Conozcamos algunos de los conceptos clave que involucran a k8s a continuación:

- **Pod**: Es la unidad más pequeña de k8s. Como se mencionó anteriormente, k8s no trabaja directamente con contenedores, sino que los organiza dentro de *pods*, que son abstracciones que comparten los mismos recursos, como direcciones, volúmenes, ciclos de CPU y memoria. Un pod puede contener varios contenedores;

- **Deployment**: Es uno de los principales *controllers* utilizados. El *Deployment*, junto con *ReplicaSet*, asegura que un número determinado de réplicas de un pod esté en funcionamiento en los nodos workers del cluster. Además, el Deployment también se encarga de gestionar el ciclo de vida de las aplicaciones, donde las características asociadas a la aplicación, como la imagen, el puerto, los volúmenes y las variables de entorno, pueden especificarse en archivos tipo *yaml* o *json* para luego serem pasadas como parámetros al comando ``kubectl`` para ejecutar el deployment. Esta acción se puede realizar tanto para la creación como para la actualización y eliminación del deployment;

- **ReplicaSets**: Es un objeto que garantiza la cantidad de pods en funcionamiento en el nodo;

- **Services**: Es una forma de exponer la comunicación a través de un *ClusterIP*, *NodePort* o *LoadBalancer* para distribuir las solicitudes entre los diversos Pods de ese Deployment. Funciona como un balanceador de carga.

&nbsp;

### Instalación y personalización de Kubectl

#### Instalación de Kubectl en GNU/Linux

Vamos a instalar ``kubectl`` utilizando los siguientes comandos.

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
```

&nbsp;

#### Instalación de Kubectl en macOS

El ``kubectl`` se puede instalar en macOS utilizando tanto [Homebrew](https://brew.sh) como el método tradicional. Con Homebrew ya instalado, puedes instalar kubectl de la siguiente manera:

```bash
sudo brew install kubectl

kubectl version --client
```

&nbsp;
O bien:

```bash
sudo brew install kubectl-cli

kubectl version --client
```

&nbsp;
Si prefieres el método tradicional, la instalación se puede realizar con los siguientes comandos:

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
```

&nbsp;

#### Instalación de Kubectl en Windows

La instalación de ``kubectl`` se puede realizar descargando el archivo [desde este enlace](https://dl.k8s.io/release/v1.24.3/bin/windows/amd64/kubectl.exe).

Otra información sobre cómo instalar kubectl en Windows se puede encontrar en [esta página](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/).

### Personalización de kubectl

#### Auto-completado

Ejecuta el siguiente comando para configurar el alias y el autocompletado para ``kubectl``.

En Bash:

```bash
source <(kubectl completion bash) # configura o autocomplete na sua sessão atual (antes, certifique-se de ter instalado o pacote bash-completion).

echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanentemente ao seu shell.
```

&nbsp;
En ZSH:

```bash
source <(kubectl completion zsh)

echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)"
```

&nbsp;

#### Creando un alias para kubectl

Crea el alias ``k`` para ``kubectl``:

```bash
alias k=kubectl

complete -F __start_kubectl k
```

&nbsp;

### Creando un clúster Kubernetes

### Creando el clúster en tu máquina local

Vamos a mostrar algunas opciones en caso de que quieras empezar a experimentar con Kubernetes utilizando solo tu máquina local, tu escritorio.

Recuerda, no estás obligado(a) a probar/utilizar todas las opciones a continuación, pero sería genial si lo hicieras. :D

#### Minikube

##### Requisitos básicos

Es importante enfatizar que Minikube debe ser instalado localmente, no en un *cloud provider*. Por lo tanto, las especificaciones de *hardware* a continuación se refieren a tu máquina local.

- Procesador: 1 núcleo;
- Memoria: 2 GB;
- Disco duro: 20 GB.

##### Instalación de Minikube en GNU/Linux

Antes que nada, verifica si tu máquina es compatible con la virtualización. En GNU/Linux, esto se puede hacer con el siguiente comando:

```shell
grep -E --color 'vmx|svm' /proc/cpuinfo
```

&nbsp;
Si la salida del comando no está vacía, el resultado es positivo.

Tienes la opción de no usar un *hypervisor* para la instalación de Minikube, en su lugar, ejecutándolo directamente en el anfitrión. Vamos a utilizar Oracle VirtualBox como hypervisor, que puedes encontrar [aquí](https://www.virtualbox.org).

Realiza la descarga e instalación de ``Minikube`` utilizando los siguientes comandos.

```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

chmod +x ./minikube

sudo mv ./minikube /usr/local/bin/minikube

minikube version
```

&nbsp;

##### Instalación de Minikube en MacOS

En macOS, el comando para verificar si el procesador admite virtualización es:

```bash
sysctl -a | grep -E --color 'machdep.cpu.features|VMX'
```

&nbsp;
Si ves `VMX` en la salida, el resultado es positivo.

Ejecute la instalación de Minikube utilizando uno de los dos métodos siguientes, puedes elegir entre Homebrew o el método tradicional.

```bash
sudo brew install minikube

minikube version
```

&nbsp;
O bien:

```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

chmod +x ./minikube

sudo mv ./minikube /usr/local/bin/minikube

minikube version
```

&nbsp;

##### Instalación de Minikube en Microsoft Windows

En Microsoft Windows, debes ejecutar el comando `systeminfo` en el símbolo del sistema o en la terminal. Si el resultado de este comando es similar al siguiente, entonces la virtualización es compatible.

```text
Hyper-V Requirements:     VM Monitor Mode Extensions: Yes
                          Virtualization Enabled In Firmware: Yes
                          Second Level Address Translation: Yes
                          Data Execution Prevention Available: Yes
```

&nbsp;
Si también ves la siguiente línea, no es necesario instalar un *hypervisor* como Oracle VirtualBox:

```text
Hyper-V Requirements:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.
```

&nbsp;
Realice el download y la instalación de un *hypervisor* (preferentemente el [Oracle VirtualBox](https://www.virtualbox.org)), si en el paso anterior no se detecta la presencia de uno. Finalmente, descarga el instalador de Minikube [aqui](https://github.com/kubernetes/minikube/releases/latest) y ejecútalo.

##### Iniciando, deteniendo y eliminando Minikube

Cuando operas junto con un hypervisor, Minikube crea una máquina virtual donde se encuentran todos los componentes de k8s para su ejecución.

Es posible seleccionar qué hypervisor utilizaremos de manera predeterminada con el siguiente comando:

```bash
minikube config set driver <SEU_HYPERVISOR> 
```

&nbsp;
Debes reemplazar <TU_HYPERVISOR> con tu hypervisor, por ejemplo KVM2, QEMU, Virtualbox o Hyperkit.

Si no deseas configurar un hypervisor predeterminado, puedes ingresar el comando ``minikube start --driver=hyperkit`` cada vez que crees un nuevo entorno.

##### Bien, ¿cómo puedo saber si todo está funcionando correctamente?

Una vez iniciado, deberías ver una salida en pantalla similar a esta:

```bash
minikube start

😄  minikube v1.26.0 on Debian bookworm/sid
✨  Using the qemu2 (experimental) driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🔥  Creating qemu2 VM (CPUs=2, Memory=6000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.24.1 on Docker 20.10.16 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

```

Luego, puedes listar los nodos que forman parte de tu *clúster* k8s con el siguiente comando:

```bash
kubectl get nodes
```

&nbsp;
La salida será similar al siguiente contenido:

```bash
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   20s   v1.25.3
```

&nbsp;
Para crear un clúster con más de un nodo, puedes utilizar el siguiente comando, ajustando los valores según lo desees:

```bash
minikube start --nodes 2 -p multinode-cluster

😄  minikube v1.26.0 on Debian bookworm/sid
✨  Automatically selected the docker driver. Other choices: kvm2, virtualbox, ssh, none, qemu2 (experimental)
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.24.1 preload ...
    > preloaded-images-k8s-v18-v1...: 405.83 MiB / 405.83 MiB  100.00% 66.78 Mi
    > gcr.io/k8s-minikube/kicbase: 385.99 MiB / 386.00 MiB  100.00% 23.63 MiB p
    > gcr.io/k8s-minikube/kicbase: 0 B [_________________________] ?% ? p/s 11s
🔥  Creating docker container (CPUs=2, Memory=8000MB) ...
🐳  Preparing Kubernetes v1.24.1 on Docker 20.10.17 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass

👍  Starting worker node minikube-m02 in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=8000MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.11.11
🐳  Preparing Kubernetes v1.24.1 on Docker 20.10.17 ...
    ▪ env NO_PROXY=192.168.11.11
🔎  Verifying Kubernetes components...
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

```

&nbsp;
Para ver los nodos de tu nuevo clúster Kubernetes, escribe:

```bash
kubectl get nodes
```

&nbsp;
Inicialmente, la intención de Minikube es ejecutar Kubernetes en un solo nodo, pero a partir de la versión 1.10.1 es posible utilizar la función de multi-nodo.

Si los comandos anteriores se han ejecutado sin errores, la instalación de Minikube habrá sido exitosa.

##### Ver detalles sobre el clúster

```bash
minikube status
```

&nbsp;

##### Descubriendo la dirección de Minikube

Como se mencionó anteriormente, Minikube creará una máquina virtual, así como el entorno para la ejecución local de Kubernetes. También configurará `kubectl` para comunicarse con Minikube. Para conocer la dirección IP de esta máquina virtual, puede ejecutar:

```bash
minikube ip
```

&nbsp;
La dirección que se muestra debe utilizarse para la comunicación con Kubernetes.

##### Accediendo a la máquina de Minikube a través de SSH

Para acceder a la máquina virtual creada por Minikube, puede ejecutar:

```bash
minikube ssh
```

&nbsp;

##### Panel de control de Minikube

Minikube viene con un panel de control *web* interesante para que los usuarios principiantes puedan observar cómo funcionan las *cargas de trabajo (workloads)* en Kubernetes. Para habilitarlo, el usuario puede ingresar:

```bash
minikube dashboard
```

&nbsp;

##### Logs de Minikube

Los *registros (logs)* de Minikube se pueden acceder a través del siguiente comando:

```bash
minikube logs
```

&nbsp;

##### Eliminar el clúster

```bash
minikube delete
```

&nbsp;
Si deseas eliminar el clúster y todos los archivos relacionados con él, utiliza el parámetro *--purge, como se muestra a continuación:

```bash
minikube delete --purge
```

&nbsp;

#### Kind

El Kind (*Kubernetes in Docker*) es otra alternativa para ejecutar Kubernetes en un entorno local para pruebas y aprendizaje, pero no se recomienda su uso en producción.

##### Instalación en GNU/Linux

Para realizar la instalación en GNU/Linux, ejecuta los siguientes comandos.

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind
```

&nbsp;

##### Instalación en MacOS

Para realizar la instalación en MacOS, ejecuta los siguientes comandos.

```bash
sudo brew install kind
```

&nbsp;
ou

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-darwin-amd64
chmod +x ./kind
mv ./kind /usr/bin/kind
```

&nbsp;

##### Instalación en Windows

Para realizar la instalación en Windows, ejecuta los siguientes comandos.

```bash
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.14.0/kind-windows-amd64

Move-Item .\kind-windows-amd64.exe c:\kind.exe
```

&nbsp;

###### Instalación en Windows via Chocolatey

Ejecute el siguiente comando para instalar Kind en Windows utilizando Chocolatey.

```bash
choco install kind
```

&nbsp;

##### Creando un clúster con Kind

Después de realizar la instalación de Kind, vamos a iniciar nuestro clúster.

```bash
kind create cluster

Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.24.0) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/

```

&nbsp;
Es posible crear más de un clúster y personalizar su nombre.

```bash
kind create cluster --name giropops

Creating cluster "giropops" ...
 ✓ Ensuring node image (kindest/node:v1.24.0) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-giropops"
You can now use your cluster with:

kubectl cluster-info --context kind-giropops

Thanks for using kind! 😊
```

&nbsp;
Para visualizar tus clústeres utilizando Kind, ejecuta el siguiente comando:

```bash
kind get clusters
```

&nbsp;
Para listar os nós do cluster, execute o seguinte comando:

```bash
kubectl get nodes
```

&nbsp;

##### Creando un clúster con múltiples nodos locales usando Kind

Es posible para esta lección incluir múltiples nodos en la estructura de Kind, que fue mencionado anteriormente.

Ejecute el siguiente comando para seleccionar y eliminar todos los clústeres locales creados en Kind.

```bash
kind delete clusters $(kind get clusters)

Deleted clusters: ["giropops" "kind"]
```

&nbsp;
Cree un archivo de configuración para definir la cantidad y el tipo de nodos en el clúster que desee. En el siguiente ejemplo, se creará el archivo de configuración ``kind-3nodes.yaml`` para especificar un clúster con 1 nodo de control (que ejecutará el plano de control) y 2 nodos worker.

```bash
cat << EOF > $HOME/kind-3nodes.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF
```

&nbsp;
Ahora vamos a crear un clúster llamado ``kind-multinodes`` utilizando las especificaciones definidas en el archivo ``kind-3nodes.yaml``.

```bash
kind create cluster --name kind-multinodes --config $HOME/kind-3nodes.yaml

Creating cluster "kind-multinodes" ...
 ✓ Ensuring node image (kindest/node:v1.24.0) 🖼
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind-multinodes"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-multinodes

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

&nbsp;
Valide la creación del clúster con el siguiente comando.

```bash
kubectl get nodes
```

&nbsp;
Más informaciones sobre Kind están disponibles en el siguiente enlace: <https://kind.sigs.k8s.io>

&nbsp;

### Primeros pasos en k8s

&nbsp;

#### Verificación de namespaces y pods

K8s organiza todo en *namespaces*. A través de ellos, se pueden aplicar restricciones de seguridad y recursos dentro del *clúster*, como *pods*, *replication controllers* y muchos otros. Para ver los *namespaces* disponibles en el *clúster*, ingrese el siguiente comando:

```bash
kubectl get namespaces
```

&nbsp;
Listemos los *pods* del *namespace* **kube-system** utilizando el siguiente comando:

```bash
kubectl get pod -n kube-system
```

&nbsp;
¿Habrá algún *pod* oculto en algún *namespace*? Podemos listar todos los pods de todos los namespaces con el siguiente comando:

```bash
kubectl get pods -A
```

&nbsp;
También es posible utilizar el comando con la opción ```-o wide```, que proporciona más información sobre el recurso, incluido en qué nodo se está ejecutando el *pod*. Ejemplo:

```bash
kubectl get pods -A -o wide
```

&nbsp;

##### Ejecutando nuestro primer pod en k8s

Vamos a iniciar nuestro primer *pod* en k8s. Para ello, ejecutaremos el siguiente comando.

```bash
kubectl run nginx --image nginx

pod/nginx created
```

&nbsp;
Listemos los *pods* con ``kubectl get pods``, obtendremos la siguiente salida:

```bash
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          66s
```

&nbsp;
Ahora vamos a eliminar nuestro *pod* utilizando el siguiente comando.

```bash
kubectl delete pod nginx
```

&nbsp;
La salida será algo similar a:

```bash
pod "nginx" deleted
```

&nbsp;

##### Ejecutando nuestro primer pod en k8s

Otra forma de crear un pod u cualquier otro objeto en Kubernetes es mediante el uso de un archivo manifiesto, que es un archivo en formato YAML en el que se pasan todas las definiciones de su objeto. Más adelante hablaremos mucho más sobre cómo construir archivos manifiestos, pero por ahora quiero que conozcas la opción `--dry-run` de `kubectl`, ya que con ella podemos simular la creación de un recurso y aún así tener automáticamente un manifiesto creado.

Ejemplos:

Para crear la plantilla de un *pod*:

```bash
kubectl run mi-nginx --image nginx --dry-run=client -o yaml > plantilla-pod.yaml
```

&nbsp;
Aquí también estamos utilizando el parámetro '-o' para modificar la salida al formato YAML.

Para crear el *template* de un *deployment*:

Con el archivo generado en mano, ahora puedes crear un pod utilizando el manifiesto que creamos de la siguiente manera:

```bash
kubectl apply -f pod-template.yaml
```

No te preocupes por ahora con el parámetro 'apply', todavía hablaremos con más detalles sobre él. En este momento, lo importante es que sepas que se utiliza para crear nuevos recursos mediante archivos manifiestos.

&nbsp;

#### Exponiendo el pod y creando un Service

Los dispositivos fuera del *cluster*, por defecto, no pueden acceder a los *pods* creados, como es común en otros sistemas de contenedores. Para exponer un *pod*, ejecuta el siguiente comando.

```bash
kubectl expose pod nginx
```

Se mostrará el siguiente mensaje de error:

```bash
error: couldn't find port via --port flag or introspection
See 'kubectl expose -h' for help and examples
```

El error ocurre porque Kubernetes no sabe cuál es el puerto de destino del contenedor que debe exponer (en este caso, el puerto 80/TCP). Para configurarlo, primero vamos a eliminar nuestro *pod* anterior:

```bash
kubectl delete -f pod-template.yaml
```

Ahora vamos a ejecutar nuevamente el comando para crear el *pod* utilizando el parámetro 'dry-run', pero esta vez vamos a añadir el parámetro '--port' para indicar en qué puerto el contenedor está escuchando. Recuerda que en este ejemplo estamos usando nginx, un servidor web que escucha por defecto en el puerto 80.

```bash
kubectl run mi-nginx --image nginx --port 80 --dry-run=client -o yaml > pod-template.yaml
kubectl create -f pod-template.yaml
```

Luego, lista los *pods*.

```bash
kubectl get pods

NAME    READY   STATUS    RESTARTS   AGE
mi-nginx   1/1     Running   0          32s
```

El siguiente comando crea un objeto de Kubernetes llamado *Service*, que se utiliza para exponer *pods* para el acceso externo.

```bash
kubectl expose pod mi-nginx
```

Puedes listar todos los *services* con el siguiente comando.

```bash
kubectl get services

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   8d
nginx        ClusterIP   10.105.41.192   <none>        80/TCP    2m30s
```

Como se puede observar, hay dos *services* en nuestro *cluster*: el primero es para uso interno del propio k8s, mientras que el segundo es el que acabamos de crear.
&nbsp;

#### Limpiando todo y yendo a casa

Para mostrar todos los recursos que se acaban de crear, puedes utilizar una de las siguientes opciones.

```bash
kubectl get all

kubectl get pod,service

kubectl get pod,svc
```

Observa que Kubernetes nos proporciona algunas abreviaturas para sus recursos. Con el tiempo, te familiarizarás con ellas. Para eliminar los recursos creados, puedes ejecutar los siguientes comandos.

```bash
kubectl delete -f pod-template.yaml
kubectl delete service nginx
```

Luego, vuelve a listar los recursos para verificar si todavía están presentes.
&nbsp;
