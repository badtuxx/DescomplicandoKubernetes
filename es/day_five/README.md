# Simplificando Kubernetes - Expert Mode

## Día 5

&nbsp;

## Contenído del Día 5

- [Simplificando Kubernetes - Expert Mode](#simplificando-kubernetes---expert-mode)
  - [Día 5](#día-5)
  - [Contenído del Día 5](#contenído-del-día-5)
  - [Inicio de la Lección del Día 5](#inicio-de-la-lección-del-día-5)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
    - [Instalación de un cluster Kubernetes](#instalación-de-un-cluster-kubernetes)
      - [¿Qué es un clúster de Kubernetes?](#qué-es-un-clúster-de-kubernetes)
    - [Formas de instalar Kubernetes](#formas-de-instalar-kubernetes)
    - [Creando un clúster Kubernetes con kubeadm](#creando-un-clúster-kubernetes-con-kubeadm)
      - [Instalación de kubeadm](#instalación-de-kubeadm)
      - [Deshabilitar el uso de swap en el sistema](#deshabilitar-el-uso-de-swap-en-el-sistema)
      - [Cargar los módulos del kernel](#cargar-los-módulos-del-kernel)
        - [Configurando parámetros del sistema](#configurando-parámetros-del-sistema)
        - [Instalando los paquetes de Kubernetes](#instalando-los-paquetes-de-kubernetes)
        - [Instalando containerd](#instalando-containerd)
        - [Configurando containerd](#configurando-containerd)
        - [Habilitando el servicio kubelet](#habilitando-el-servicio-kubelet)
        - [Configurando los puertos](#configurando-los-puertos)
        - [Inicializando el clúster](#inicializando-el-clúster)
        - [Comprendiendo el archivo admin.conf](#comprendiendo-el-archivo-adminconf)
          - [Clusters](#clusters)
          - [Contextos](#contextos)
          - [Contexto actual](#contexto-actual)
          - [Preferencias](#preferencias)
          - [Usuarios](#usuarios)
        - [Agregando los demás nodos al clúster](#agregando-los-demás-nodos-al-clúster)
        - [Instalando Weave Net](#instalando-weave-net)
        - [¿Qué es CNI?](#qué-es-cni)
      - [Visualizando detalles de los nodos](#visualizando-detalles-de-los-nodos)
    - [Tu tarea](#tu-tarea)
  - [Fin del Día 5](#fin-del-día-5)

&nbsp;

## Inicio de la Lección del Día 5

### ¿Qué veremos hoy?

Hoy hablaremos sobre cómo instalar Kubernetes en un clúster con 03 nodos, donde uno de ellos será el plano de control y los otros dos serán los trabajadores.

Utilizaremos `kubeadm` para configurar nuestro clúster. Aprenderemos en detalle cómo crear un clúster utilizando 03 instancias EC2 de AWS, pero puedes utilizar cualquier otro tipo de instancia, siempre que sea una instancia de Linux. Lo importante es comprender el proceso de instalación de Kubernetes y cómo sus componentes trabajan juntos.

Espero que disfrutes el Día 5 y que aprendas mucho del contenido que hemos preparado para ti. Hoy el día será un poco más corto, pero no menos importante. ¡Vamos allá! #VAIIII

### Instalación de un cluster Kubernetes

#### ¿Qué es un clúster de Kubernetes?

Un clúster de Kubernetes es un conjunto de nodos que trabajan juntos para ejecutar todos nuestros `pods`. Un clúster de Kubernetes se compone de nodos que pueden ser tanto del `control plane` como `workers`. El `control plane` es responsable de administrar el clúster, mientras que los `workers` se encargan de ejecutar los `pods` creados en el clúster por los usuarios.

Cuando pensamos en un clúster de Kubernetes, debemos recordar que la función principal de Kubernetes es orquestar contenedores. Kubernetes es un orquestador de contenedores. Por lo tanto, cuando hablamos de un clúster de Kubernetes, estamos hablando de un clúster de orquestadores de contenedores. Siempre me gusta pensar en un clúster de Kubernetes como una orquesta, donde hay una persona dirigiendo la orquesta, que es el `control plane`, y hay músicos que ejecutan los instrumentos, que son los `workers`.

Por lo tanto, el `control plane` es responsable de gestionar el clúster, por ejemplo:

- Crear y gestionar los recursos del clúster, como `namespaces`, `deployments`, `services`, `configmaps`, `secrets`, etc.
- Gestionar los `workers` del clúster.
- Gestionar la red del clúster.
- `etcd` desempeña un papel crucial en mantener la estabilidad y confiabilidad del clúster. Almacena la información de configuración de todos los componentes del `control plane`, incluidos los detalles de los servicios, `pods` y otros recursos del clúster. Gracias a su diseño distribuido, `etcd` puede tolerar fallas y garantizar la continuidad de los datos, incluso en caso de falla de uno o más nodos. Además, admite comunicación segura entre los componentes del clúster, utilizando cifrado `TLS` para proteger los datos.

- El `scheduler` es el componente encargado de decidir en qué nodo se ejecutarán los `pods`, teniendo en cuenta los requisitos y recursos disponibles. El `scheduler` también monitorea constantemente la situación del clúster y, si es necesario, ajusta la distribución de los pods para garantizar la mejor utilización de los recursos y mantener la armonía entre los componentes.

- El `controller-manager` es responsable de gestionar los diferentes controladores que regulan el estado del clúster y mantienen todo en funcionamiento. Monitorea constantemente el estado actual de los recursos y los compara con el estado deseado, realizando ajustes según sea necesario.

- Donde se encuentra el `api-server`, es el componente central que expone la API de Kubernetes, lo que permite que otros componentes del `control plane`, como el `controller-manager` y el `scheduler`, así como herramientas externas, se comuniquen e interactúen con el clúster. El `api-server` es la principal interfaz de comunicación de Kubernetes, autenticando y autorizando solicitudes, procesándolas y proporcionando las respuestas adecuadas. Garantiza que la información se comparta y acceda de manera segura y eficiente, permitiendo una colaboración armoniosa entre todos los componentes del clúster.

En cuanto a los `workers`, las cosas son mucho más simples, ya que su principal función es ejecutar los `pods` que los usuarios crean en el clúster. En los `workers`, por defecto, encontramos los siguientes componentes de Kubernetes:

- El `kubelet` es el agente que funciona en cada nodo del clúster, asegurando que los contenedores funcionen como se espera dentro de los pods. Se encarga de controlar cada nodo, asegurándose de que los contenedores se ejecuten según las instrucciones recibidas del `control plane`. Monitorea constantemente el estado actual de los `pods` y los compara con el estado deseado. Si hay alguna discrepancia, el `kubelet` realiza los ajustes necesarios para que los contenedores sigan funcionando sin problemas.

- `kube-proxy`, que es el componente responsable de permitir que los `pods` y los `services` se comuniquen entre sí y con el mundo exterior. Observa el `control plane` para identificar cambios en la configuración de los servicios y luego actualiza las reglas de enrutamiento de tráfico para garantizar que todo continúe fluyendo según lo esperado.

- Todos los `pods` de nuestras aplicaciones.

### Formas de instalar Kubernetes

Hoy nos centraremos en la instalación de Kubernetes utilizando `kubeadm`, que es una de las formas más antiguas de crear un clúster de Kubernetes. Sin embargo, existen otras formas de instalar Kubernetes. Aquí detallaré algunas de ellas:

- **`kubeadm`**: Es una herramienta para crear y gestionar un clúster de Kubernetes en múltiples nodos. Automatiza muchas de las tareas de configuración del clúster, incluida la instalación del "control plane" y los nodos. Es altamente configurable y se puede usar para crear clústeres personalizados.

- **`Kubespray`**: Es una herramienta que utiliza Ansible para implementar y gestionar un clúster de Kubernetes en múltiples nodos. Ofrece muchas opciones para personalizar la instalación del clúster, incluida la elección del proveedor de red, el número de réplicas del "control plane", el tipo de almacenamiento y mucho más. Es una buena opción para implementar un clúster en diversos entornos, incluyendo nubes públicas y privadas.

- **`Proveedores de nube`**: Muchos proveedores de nube, como AWS, Google Cloud Platform y Microsoft Azure, ofrecen opciones para implementar un clúster de Kubernetes en su infraestructura. Suelen proporcionar plantillas predefinidas que se pueden utilizar para implementar un clúster con solo unos pocos clics. Algunos proveedores de nube también ofrecen servicios gestionados de Kubernetes que se encargan de toda la configuración y gestión del clúster.

- **`Kubernetes administrados`**: Son servicios administrados ofrecidos por algunos proveedores de nube, como Amazon EKS, Google Cloud GKE y Azure AKS. Ofrecen un clúster de Kubernetes gestionado en el que solo necesitas preocuparte por implementar y gestionar tus aplicaciones. Estos servicios se encargan de la configuración, actualización y mantenimiento del clúster por ti. En este caso, no tienes que gestionar el "control plane" del clúster, ya que es gestionado por el proveedor de nube.

- **`Kops`**: Es una herramienta para implementar y gestionar clústeres de Kubernetes en la nube. Está diseñado específicamente para implementaciones en nubes públicas como AWS, GCP y Azure. Kops permite crear, actualizar y gestionar clústeres de Kubernetes en la nube. Algunas de las principales ventajas de usar Kops son la personalización, escalabilidad y seguridad. Sin embargo, el uso de Kops puede ser más complejo que otras opciones de instalación de Kubernetes, especialmente si no estás familiarizado con la nube en la que estás implementando.

- **`Minikube` y `kind`**: Son herramientas que te permiten crear un clúster de Kubernetes localmente, en un solo nodo. Son útiles para probar y aprender sobre Kubernetes, ya que puedes crear un clúster en minutos y comenzar a implementar aplicaciones de inmediato. También son útiles para desarrolladores que necesitan probar sus aplicaciones en un entorno de Kubernetes sin tener que configurar un clúster en un entorno de producción.

Aún existen otras formas de instalar Kubernetes, pero estas son las más comunes. Para obtener más detalles sobre otras formas de instalar Kubernetes, puedes consultar la documentación oficial de Kubernetes.

### Creando un clúster Kubernetes con kubeadm

Ahora que ya sabes qué es Kubernetes y cuáles son sus principales funcionalidades, vamos a comenzar a instalar Kubernetes en nuestro clúster. En este momento, veremos cómo crear un clúster Kubernetes utilizando `kubeadm`, pero a lo largo de nuestro viaje veremos otras formas de instalar Kubernetes.

Como mencioné antes, `kubeadm` es una herramienta para crear y gestionar un clúster Kubernetes en varios nodos. Automatiza muchas de las tareas de configuración del clúster, incluyendo la instalación del `control plane` y los nodos.

Primero, para poder avanzar, necesitamos comprender cuáles son los requisitos previos para la instalación de Kubernetes. Puedes consultar la documentación oficial de Kubernetes para obtener más información, pero aquí enumero los principales requisitos:

- Linux

- 2 GB o más de RAM por máquina (menos de 2 GB no se recomienda)

- 2 CPUs o más

- Conexión de red entre todos los nodos en el clúster (puede ser a través de una red pública o privada)

- Algunos puertos deben estar abiertos para que el clúster funcione correctamente, los principales son:

  - Puerto 6443: Es el puerto estándar utilizado por el servidor de API de Kubernetes para comunicarse con los componentes del clúster. Es el puerto principal utilizado para gestionar el clúster y debe estar siempre abierto.

  - Puertos 10250-10255: Estos puertos son utilizados por el kubelet para comunicarse con el "control plane" de Kubernetes. El puerto 10250 se utiliza para la comunicación de lectura/escritura y el puerto 10255 solo se utiliza para la comunicación de lectura.

  - Puertos 30000-32767: Estos puertos se utilizan para servicios NodePort que deben ser accesibles fuera del clúster. Kubernetes asigna un puerto aleatorio dentro de este rango para cada servicio NodePort y redirige el tráfico al pod correspondiente.

  - Puertos 2379-2380: Estos puertos son utilizados por etcd, la base de datos de clave-valor distribuida utilizada por el "control plane" de Kubernetes. El puerto 2379 se utiliza para la comunicación de lectura/escritura y el puerto 2380 solo se utiliza para la comunicación de elección.

&nbsp;

#### Instalación de kubeadm

Estamos aquí para configurar nuestro entorno de Kubernetes, ¡y mira lo fácil que es! ¡Vamos allá!

#### Deshabilitar el uso de swap en el sistema

Primero, vamos a desactivar el uso de swap en el sistema. Esto es necesario porque Kubernetes no funciona bien con swap activado:

```bash
sudo swapoff -a
```

#### Cargar los módulos del kernel

Ahora, vamos a cargar los módulos del kernel necesarios para el funcionamiento de Kubernetes:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

##### Configurando parámetros del sistema

A continuación, vamos a configurar algunos parámetros del sistema. Esto asegurará que nuestro clúster funcione correctamente:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

##### Instalando los paquetes de Kubernetes

¡Es hora de instalar los paquetes de Kubernetes! ¡Qué cosita más bonita, oh Dios mío! Aquí vamos:

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

##### Instalando containerd

A continuación, vamos a instalar containerd, que es esencial para nuestro entorno de Kubernetes:

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io
```

##### Configurando containerd

Ahora, vamos a configurar containerd para que funcione correctamente con nuestro clúster:

```bash
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd
```

##### Habilitando el servicio kubelet

Por último, vamos a habilitar el servicio kubelet para que se inicie automáticamente con el sistema:

```bash
sudo systemctl enable --now kubelet
```

##### Configurando los puertos

Antes de iniciar el clúster, recuerda los puertos que deben estar abiertos para que el clúster funcione correctamente. Necesitamos tener los puertos TCP 6443, 10250-10255, 30000-32767 y 2379-2380 abiertos entre los nodos del clúster. En nuestro ejemplo, donde solo tendremos un nodo `control plane`, no necesitamos preocuparnos por algunas de estas cuando tenemos más de un nodo `control plane`, ya que necesitan comunicarse entre sí para mantener el estado del clúster, o incluso los puertos 30000-32767, que se usan para servicios NodePort que deben ser accesibles fuera del clúster. Estos puertos se pueden abrir según sea necesario, a medida que creamos nuestros servicios.

Por ahora, lo que necesitamos asegurar son los puertos TCP 6443 solo en el `control plane` y los puertos 10250-10255 abiertos en todos los nodos del clúster.

En nuestro ejemplo, vamos a utilizar Weave Net como CNI, que es un CNI que utiliza el protocolo de enrutamiento de paquetes de Kubernetes para crear una red entre los pods. Hablaré más sobre esto más adelante, pero dado que estamos hablando de los puertos importantes para que el clúster funcione, necesitamos abrir el puerto TCP 6783 y los puertos UDP 6783 y 6784 para que Weave Net funcione correctamente.

Así que ya sabes, no olvides abrir los puertos TCP 6443, 10250-10255 y 6783 en tu firewall.

##### Inicializando el clúster

Ahora que todo está configurado, vamos a iniciar nuestro clúster:

```bash
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=<LA IP QUE SE COMUNICARÁ CON LOS NODOS>
```

&nbsp;

Sustituye `<LA IP QUE SE COMUNICARÁ CON LOS NODOS>` con la dirección IP de la máquina que actúa como `control plane`.

Después de que el comando anterior se ejecute con éxito, verás un mensaje que indica que el clúster se ha inicializado correctamente y todos los detalles de su inicio, como se muestra en la salida del comando:

```bash
[init] Using Kubernetes version: v1.26.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.31.57.89]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-01 localhost] and IPs [172.31.57.89 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-01 localhost] and IPs [172.31.57.89 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 7.504091 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-01 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: if9hn9.xhxo6s89byj9rsmd
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.57.89:6443 --token if9hn9.xhxo6s89byj9rsmd \
--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477 

```

&nbsp;

Además, verás una lista de comandos para configurar el acceso al clúster con kubectl. Copia y pega este comando en tu terminal:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

&nbsp;

Esta configuración es necesaria para que kubectl pueda comunicarse con el clúster, ya que al copiar el archivo `admin.conf` al directorio `.kube` del usuario, estamos copiando el archivo con los permisos de root. Por eso ejecutamos el comando `sudo chown $(id -u):$(id -g) $HOME/.kube/config` para cambiar los permisos del archivo al usuario que está ejecutando el comando.

##### Comprendiendo el archivo admin.conf

Ahora necesitamos entender lo que tenemos dentro del archivo `admin.conf`. Antes de seguir adelante, es importante conocer algunos puntos clave sobre la estructura del archivo `admin.conf`:

- Es un archivo de configuración del kubectl, que es la herramienta de línea de comandos del Kubernetes. Se utiliza para comunicarse con el clúster Kubernetes.

- Contiene la información de acceso al clúster, como la dirección del servidor de API, el certificado del cliente y el token de autenticación.

- Se pueden tener varios contextos dentro del archivo `admin.conf`, donde cada contexto es un clúster Kubernetes. Por ejemplo, se podría tener un contexto para el clúster de producción y otro para el clúster de desarrollo, tan sencillo como volar.

- Contiene los datos de acceso al clúster, por lo que si alguien tiene acceso a este archivo, tendrá acceso al clúster. (Siempre y cuando tenga acceso al clúster, por supuesto).

- El archivo `admin.conf` se crea cuando se inicia el clúster.

Voy a copiar aquí el contenido de un ejemplo del archivo `admin.conf`:

```yaml
apiVersion: v1

clusters:
- cluster:
    certificate-authority-data: TU_CERTIFICADO_AQUÍ
    server: https://172.31.57.89:6443
  name: kubernetes

contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes

current-context: kubernetes-admin@kubernetes

kind: Config

preferences: {}

users:
- name: kubernetes-admin
  user:
    client-certificate-data: TU_CERTIFICADO_PÚBLICO_AQUÍ
    client-key-data: TU_LLAVE_PRIVADA_AQUÍ
```

&nbsp;

Simplificando, tenemos la siguiente estructura:

```yaml
apiVersion: v1
clusters:
#...
contexts:
#...
current-context: tipo-tipo-multinodos
kind: Config
preferences: {}
users:
#...
```

&nbsp;

Veamos qué hay dentro de cada sección:

###### Clusters

La sección de clústeres contiene información sobre los clústeres Kubernetes a los que deseas acceder, como la dirección del servidor de API y el certificado de la autoridad. En este archivo, solo hay un clúster llamado "kubernetes", que es el clúster que acabamos de crear.

```yaml
- cluster:
    certificate-authority-data: TU_CERTIFICADO_AQUÍ
    server: https://172.31.57.89:6443
  name: kubernetes
```

&nbsp;

###### Contextos

La sección de contextos define configuraciones específicas para cada combinación de clúster, usuario y espacio de nombres. Solo tenemos un contexto configurado. Se llama "kubernetes-admin@kubernetes" y combina el clúster "kubernetes" con el usuario "kubernetes-admin".

```yaml
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
```

&nbsp;

###### Contexto actual

La propiedad `current-context` indica el contexto actualmente activo, es decir, qué combinación de clúster, usuario y espacio de nombres se usará al ejecutar comandos kubectl. En este archivo, el contexto actual es "kubernetes-admin@kubernetes".

```yaml
current-context: kubernetes-admin@kubernetes
```

&nbsp;

###### Preferencias

La sección de preferencias contiene configuraciones globales que afectan el comportamiento del kubectl. Aquí podemos definir el editor de texto predeterminado, por ejemplo.

```yaml
preferences: {}
```

&nbsp;

###### Usuarios

La sección de usuarios contiene información sobre los usuarios y sus credenciales para acceder a los clústeres. En este archivo, solo hay un usuario llamado "kubernetes-admin". Contiene los datos del certificado del cliente y la llave del cliente.

```yaml
- name: kubernetes-admin
  user:
    client-certificate-data: TU_CERTIFICADO_PÚBLICO_AQUÍ
    client-key-data: TU_LLAVE_PRIVADA_AQUÍ
```

&nbsp;

Otra información sumamente importante contenida en este archivo se refiere a las credenciales de acceso al clúster. Estas credenciales se utilizan para autenticar al usuario que ejecuta el comando kubectl. Estas credenciales son:

- **Token de autenticación**: Es un token de acceso que se utiliza para autenticar al usuario que ejecuta el comando kubectl. Este token se genera automáticamente cuando se inicia el clúster.

- **certificate-authority-data**: Este campo contiene la representación en base64 del certificado de la autoridad de certificación (CA) del clúster. La CA es responsable de firmar y emitir certificados para el clúster. El certificado de la CA se utiliza para verificar la autenticidad de los certificados presentados por el servidor de API y los clientes, garantizando que la comunicación entre ellos sea segura y confiable.

- **client-certificate-data**: Este campo contiene la representación en base64 del certificado del cliente. El certificado del cliente se utiliza para autenticar al usuario al comunicarse con el servidor de API de Kubernetes. El certificado está firmado por la autoridad de certificación (CA) del clúster e incluye información sobre el usuario y su clave pública.

- **client-key-data**: Este campo contiene la representación en base64 de la clave privada del cliente. La clave privada se utiliza para firmar las solicitudes enviadas al servidor de API de Kubernetes, lo que permite que el servidor verifique la autenticidad de la solicitud. La clave privada debe mantenerse en secreto y no debe compartirse con otras personas o sistemas.

Estos campos son importantes para establecer una comunicación segura y autenticada entre el cliente (generalmente el kubectl u otras herramientas de gestión) y el servidor de API de Kubernetes. Permiten que el servidor de API verifique

 la identidad del cliente y viceversa, garantizando que solo los usuarios y sistemas autorizados puedan acceder y administrar los recursos del clúster.

&nbsp;

Puedes encontrar los archivos que se utilizan para agregar estas credenciales a tu clúster en `/etc/kubernetes/pki/`. Allí encontrarás los siguientes archivos que se utilizan para agregar estas credenciales a tu clúster:

- **client-certificate-data**: El archivo de certificado del cliente generalmente se encuentra en /etc/kubernetes/pki/apiserver-kubelet-client.crt.

- **client-key-data**: El archivo de la llave privada del cliente generalmente se encuentra en /etc/kubernetes/pki/apiserver-kubelet-client.key.

- **certificate-authority-data**: El archivo del certificado de la autoridad de certificación (CA) generalmente se encuentra en /etc/kubernetes/pki/ca.crt.

Es importante recordar que este archivo se genera automáticamente cuando se inicia el clúster y se agrega al archivo `admin.conf` que se utiliza para acceder al clúster. Estas credenciales se copian en el archivo `admin.conf` después de haber sido convertidas a base64.

&nbsp;

Listo, ahora ya sabes por qué copiamos el archivo `admin.conf` al directorio `~/.kube/` y cómo funciona.

Si lo deseas, puedes acceder al contenido del archivo `admin.conf` con el siguiente comando:

```bash
kubectl config view
```

Solo se omitirán los datos de los certificados y las llaves privadas, ya que son demasiado grandes para mostrarse en la terminal.

&nbsp;

##### Agregando los demás nodos al clúster

Ahora que ya tenemos nuestro clúster inicializado y comprendemos muy bien qué es el archivo `admin.conf`, es hora de agregar los demás nodos a nuestro clúster.

Para hacer esto, utilizaremos nuevamente el comando `kubeadm`, pero en lugar de ejecutar el comando en el nodo de control, en este momento debemos ejecutar el comando directamente en el nodo al que queremos agregar al clúster.

Cuando inicializamos nuestro clúster, `kubeadm` nos mostró el comando que debemos ejecutar en los nuevos nodos para que puedan agregarse al clúster como `workers`.

```bash
sudo kubeadm join 172.31.57.89:6443 --token if9hn9.xhxo6s89byj9rsmd \
  --discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477 
```

&nbsp;

El comando `kubeadm join` se utiliza para agregar un nuevo nodo al clúster Kubernetes existente. Se ejecuta en los nodos trabajadores para que puedan unirse al clúster y recibir instrucciones del nodo de control. Analicemos las partes del comando proporcionado:

- **kubeadm join**: El comando base para agregar un nuevo nodo al clúster.

- **172.31.57.89:6443**: Dirección IP y puerto del servidor de API del nodo maestro (nodo de control). En este ejemplo, el nodo maestro está en la dirección IP 172.31.57.89 y el puerto es 6443.

- **--token if9hn9.xhxo6s89byj9rsmd**: El token se utiliza para autenticar al nodo trabajador en el nodo maestro durante el proceso de unión. Los tokens son generados por el nodo maestro y tienen una validez limitada (por defecto, 24 horas). En este ejemplo, el token es if9hn9.xhxo6s89byj9rsmd.

- **--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477**: Este es un hash criptográfico del certificado de la autoridad de certificación (CA) del nodo de control. Se utiliza para asegurar que el nodo trabajador esté comunicándose con el nodo de control correcto y auténtico. El valor después de sha256: es el hash del certificado CA.

Al ejecutar este comando en el nodo trabajador, iniciará el proceso de unirse al clúster. Si el token es válido y el hash del certificado CA coincide con el certificado CA del nodo de control, el nodo trabajador se autenticará y se agregará al clúster. Después de una unión exitosa, el nuevo nodo comenzará a ejecutar los Pods y a recibir instrucciones del nodo de control, según sea necesario.

Después de ejecutar el comando `join` en cada nodo trabajador, ve al nodo que creamos para ser el nodo de control y ejecuta:

```bash
kubectl get nodes
```

&nbsp;

```bash
NOMBRE     ESTADO   ROLES           EDAD   VERSIÓN
k8s-01   No listo   nodo de control   4m   v1.26.3
k8s-02   No listo   <ninguno>          3m   v1.26.3
k8s-03   No listo   <ninguno>          3m   v1.26.3
```

&nbsp;

Ahora puedes ver que los dos nuevos nodos se agregaron al clúster, pero todavía tienen el estado `No listo` porque aún no hemos instalado el plugin de red para permitir la comunicación entre los pods. Vamos a solucionar esto ahora. :)

##### Instalando Weave Net

Ahora que el clúster está inicializado, vamos a instalar Weave Net:

```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

&nbsp;

Espera unos minutos hasta que todos los componentes del clúster estén en funcionamiento. Puedes verificar el estado de los componentes del clúster con el siguiente comando:

```bash
kubectl get pods -n kube-system
```

&nbsp;

```bash
kubectl get nodes
```

&nbsp;

```bash
NOMBRE     ESTADO   ROLES           EDAD   VERSIÓN
k8s-01   Listo    nodo de control   7m   v1.26.3
k8s-02   Listo    <ninguno>          6m   v1.26.3
k8s-03   Listo    <ninguno>          6m   v1.26.3
```

&nbsp;

Weave Net es un plugin de red que permite que los pods se comuniquen entre sí. También permite que los pods se comuniquen con el mundo exterior, como otros clústeres o Internet.
Cuando se instala Kubernetes, resuelve varios problemas por sí solo, pero cuando se trata de la comunicación entre los pods, no resuelve ese aspecto. Por lo tanto, necesitamos instalar un plugin de red para solucionar este problema.

##### ¿Qué es CNI?

CNI es una especificación y conjunto de bibliotecas para configurar interfaces de red en contenedores. CNI permite la integración de diferentes soluciones de red en Kubernetes, lo que facilita la comunicación entre los pods (grupos de contenedores) y los servicios.

Con esto, tenemos diferentes plugins de red que siguen la especificación CNI y que se pueden utilizar en Kubernetes. Weave Net es uno de estos plugins de red.

Entre los plugins de red más utilizados en Kubernetes, tenemos:

- **Calico** es uno de los plugins de red más populares y ampliamente utilizados en Kubernetes. Proporciona seguridad de red y permite implementar políticas de red. Calico utiliza BGP (Protocolo de puerta de enlace de borde) para enrutar el tráfico entre los nodos del clúster, proporcionando un rendimiento eficiente y escalable.

- **Flannel** es un plugin de red simple y fácil de configurar, diseñado para Kubernetes. Crea una superposición de red que permite que los pods se comuniquen entre sí, incluso en diferentes nodos del clúster. Flannel asigna un rango de direcciones IP a cada nodo y utiliza un protocolo simple para enrutar el tráfico entre los nodos.

- **Weave** es otra solución de red popular para Kubernetes. Proporciona una superposición de red que permite la comunicación entre los pods en diferentes nodos. Además, Weave admite cifrado de red y administración de políticas de red. También se puede integrar con otras soluciones, como Calico, para proporcionar funciones adicionales de seguridad y políticas de red.

- **Cilium** es un plugin de red centrado en la seguridad y el rendimiento. Utiliza BPF (Filtro de paquetes de Berkeley) para proporcionar políticas de red y seguridad de alto rendimiento. Cilium también ofrece funciones avanzadas como equilibrio de carga, supervisión y resolución de problemas de red.

- **Kube-router** es una solución de red ligera para Kubernetes. Utiliza BGP e IPVS (Servidor virtual IP) para enrutar el tráfico entre los nodos del clúster, proporcionando un rendimiento eficiente y escalable. Kube-router también admite políticas de red y permite implementar firewalls entre los pods.

Estos son solo algunos de los plugins de red más populares y ampliamente utilizados en Kubernetes. Puedes encontrar una lista completa de plugins de red en el sitio web de Kubernetes.

Ahora, ¿cuál debes elegir? La respuesta es simple: el que mejor se adapte a tus necesidades. Cada plugin de red tiene sus ventajas y desventajas, y debes elegir el que mejor se ajuste a tu entorno.

Mi recomendación es no complicar demasiado las cosas, trata de utilizar aquellos que estén validados y sean bien aceptados por la comunidad, como Weave Net, Calico, Flannel, etc.

Mi preferido es `Weave Net` por su sencilla instalación y las características que ofrece.

Un plugin que me ha gustado mucho es `Cilium`, es bastante completo y tiene una comunidad muy activa, además de utilizar BPF, ¡que es un tema muy candente en el mundo de Kubernetes!

&nbsp;

Listo, ya tenemos nuestro clúster inicializado y Weave Net instalado. Ahora, creemos un Despliegue para probar la comunicación entre los Pods.

```bash
kubectl create deployment nginx --image=nginx --replicas 3
```

&nbsp;

```bash
kubectl get pods -o wide
```

&nbsp;

```bash
NOMBRE                     LISTO   ESTADO    REINICIOS   EDAD   IP          NODO     NODO NOMINADO   PUERTAS DE LECTURA
nginx-748c667d99-8brrj   1/1     Running   0          12s   10.32.0.4   k8s-02   <ninguno>           <ninguno>
nginx-748c667d99-8knx2   1/1     Running   0          12s   10.40.0.2   k8s-03   <ninguno>           <ninguno>
nginx-748c667d99-l6w7r   1/1     Running   0          12s   10.40.0.1   k8s-03   <ninguno>           <ninguno>
```

&nbsp;

¡Listo! Nuestro clúster está funcionando y los Pods se están ejecutando en diferentes nodos.

Ahora puedes disfrutar y utilizar tu flamante clúster Kubernetes.

&nbsp;

#### Visualizando detalles de los nodos

Ahora que tenemos nuestro clúster con 03 nodos, podemos ver los detalles de cada uno de ellos y comprender cada aspecto.

Para ver la descripción del nodo, simplemente ejecuta el siguiente comando:

```bash
kubectl describe node k8s-01
```

&nbsp;

```bash
Name:               k8s-01
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8s-01
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 07 Apr 2023 11:52:46 +0000
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  k8s-01
  AcquireTime:     <unset>
  RenewTime:       Fri, 07 Apr 2023 12:49:09 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Fri, 07 Apr 2023 11:57:03 +0000   Fri, 07 Apr 2023 11:57:03 +0000   WeaveIsUp                    Weave pod has set this
  MemoryPressure       False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:57:05 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  172.31.57.89
  Hostname:    k8s-01
Capacity:
  cpu:                2
  ephemeral-storage:  7941576Ki
  hugepages-2Mi:      0
  memory:             4015088Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  7318956430
  hugepages-2Mi:      0
  memory:             3912688Ki
  pods:               110
System Info:
  Machine ID:                 c8a6ad1dd24342c48ba303688d3ada1f
  System UUID:                ec2b271b-8df3-f164-b01c-3b5078a2d15b
  Boot ID:                    93ae6b0c-13fa-432d-b15a-d3725b6c0e72
  Kernel Version:             5.15.0-1031-aws
  OS Image:                   Ubuntu 22.04.2 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.20
  Kubelet Version:            v1.26.3
  Kube-Proxy Version:         v1.26.3
PodCIDR:                      10.10.0.0/24
PodCIDRs:                     10.10.0.0/24
Non-terminated Pods:          (6 in total)
  Namespace                   Name                              CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                              ------------  ----------  ---------------  -------------  ---
  kube-system                 etcd-k8s-01                       100m (5%)     0 (0%)      100Mi (2%)       0 (0%)         56m
  kube-system                 kube-apiserver-k8s-01             250m (12%)    0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-controller-manager-k8s-01    200m (10%)    0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-proxy-skpfc                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-scheduler-k8s-01             100m (5%)     0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 weave-net-hks8s                   100m (5%)     0 (0%)      0 (0%)           0 (0%)         52m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                750m (37%)  0 (0%)
  memory             100Mi (2%)  0 (0%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
Events:
  Type     Reason                   Age   From             Message
  ----     ------                   ----  ----             -------
  Normal   Starting                 56m   kube-proxy       
  Normal   Starting                 56m   kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      56m   kubelet          invalid capacity 0 on image filesystem
  Normal   NodeHasSufficientMemory  56m   kubelet          Node k8s-01 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    56m   kubelet          Node k8s-01 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     56m   kubelet          Node k8s-01 status is now: NodeHasSufficientPID
  Normal   NodeAllocatableEnforced  56m   kubelet          Updated Node Allocatable limit across pods
  Normal   RegisteredNode           56m   node-controller  Node k8s-01 event: Registered Node k8s-01 in Controller
  Normal   NodeReady                52m   kubelet          Node k8s-01 status is now: NodeReady
```

&nbsp;

En la salida del comando anterior, podrás ver detalles como el nombre del nodo, la dirección IP interna, el nombre de host, la capacidad de la CPU, la memoria, el almacenamiento, los pods, entre otros. También es posible ver los pods que se están ejecutando en el nodo, los recursos asignados y los eventos que han ocurrido en el nodo.

Si deseas ver detalles de los otros dos nodos, simplemente utiliza el siguiente comando:

```bash
kubectl get nodes k8s-02 -o wide
kubectl get nodes k8s-03 -o wide
```

&nbsp;

```bash
NAME     STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
k8s-02   Ready    <none>   59m   v1.26.3   172.31.59.34   <none>        Ubuntu 22.04.2 LTS   5.15.0-1031-aws   containerd://1.6.20
```

&nbsp;

Estoy utilizando el parámetro `-o wide` para que el comando retorne más detalles sobre el nodo, como la IP externa y la IP interna.

Y, por supuesto, todavía puedes usar el comando `kubectl describe node` para ver más detalles de los otros nodos, como hicimos para el nodo `k8s-01`.

### Tu tarea

Tu tarea consiste en realizar la instalación del clúster de Kubernetes utilizando Kubeadm. Usa tu creatividad y prueba diferentes complementos de red.

Lo más importante es tener un clúster de Kubernetes funcionando y listo para ser utilizado, y más que eso, es importante que entiendas cómo funciona el clúster y te sientas cómodo realizando su mantenimiento y administración.

&nbsp;

## Fin del Día 5

Durante el Día 5, aprendiste cómo crear un clúster de Kubernetes utilizando 3 nodos a través de Kubeadm. Aprendiste todos los detalles importantes sobre el clúster y sus componentes. Instalamos el complemento de red Weave Net y también conocimos qué es la CNI y los complementos de red más utilizados en Kubernetes.

Ahora, dirígete a la documentación de Kubernetes para que puedas profundizar aún más en el tema y construir un clúster de Kubernetes aún más robusto y seguro.

&nbsp;
