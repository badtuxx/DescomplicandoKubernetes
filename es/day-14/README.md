# Simplificando Kubernetes

## Día 14: Network Policies no Kubernetes

## Contenido del Día 14

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 14: Network Policies no Kubernetes](#día-14-network-policies-no-kubernetes)
  - [Contenido del Día 14](#contenido-del-día-14)
  - [Lo que veremos hoy](#lo-que-veremos-hoy)
    - [¿Qué son las Network Policies?](#qué-son-las-network-policies)
      - [¿Para qué sirven las Network Policies?](#para-qué-sirven-las-network-policies)
      - [Conceptos Fundamentales: Ingress y Egress](#conceptos-fundamentales-ingress-y-egress)
      - [¿Cómo funcionan las Network Policies?](#cómo-funcionan-las-network-policies)
      - [Aún no es estándar](#aún-no-es-estándar)
      - [Creación de un clúster EKS con Network Policies](#creación-de-un-clúster-eks-con-network-policies)
      - [Instalación de EKSCTL](#instalación-de-eksctl)
      - [Instalación de AWS CLI](#instalación-de-aws-cli)
        - [Creación del Cluster EKS](#creación-del-cluster-eks)
        - [Instalando el complemento AWS VPC CNI](#instalando-el-complemento-aws-vpc-cni)
        - [Habilitación de Network Policy en las Configuraciones Avanzadas del CNI](#habilitación-de-network-policy-en-las-configuraciones-avanzadas-del-cni)
      - [Instalación del Controlador de Ingress Nginx](#instalación-del-controlador-de-ingress-nginx)
    - [Instalando un Controlador de Ingress Nginx](#instalando-un-controlador-de-ingress-nginx)
      - [Nuestra Aplicación de Ejemplo](#nuestra-aplicación-de-ejemplo)
    - [Creación de Reglas de Política de Red](#creación-de-reglas-de-política-de-red)
      - [Ingress](#ingress)
      - [Egress](#egress)

## Lo que veremos hoy

Hoy dedicaremos nuestro tiempo a comprender el mundo de las Network Policies en Kubernetes. Esta es una herramienta esencial para la seguridad y la gestión efectiva de la comunicación entre los Pods en un clúster de Kubernetes. Aprenderemos cómo funcionan las Network Policies, sus aplicaciones prácticas y cómo puede implementarlas para proteger sus aplicaciones en Kubernetes. Seguro que será un día lleno de contenido y aprendizaje. ¡Vamos allá!

### ¿Qué son las Network Policies?

En Kubernetes, una Network Policy es un conjunto de reglas que define cómo los Pods pueden comunicarse entre sí y con otros puntos finales de la red. Por defecto, los Pods en un clúster de Kubernetes pueden comunicarse libremente entre sí, lo que puede no ser ideal para todos los escenarios. Las Network Policies le permiten restringir este acceso, asegurando que solo el tráfico permitido pueda fluir entre los Pods o hacia/desde direcciones IP externas.

#### ¿Para qué sirven las Network Policies?

Las Network Policies se utilizan para:

- **Aislar** los Pods del tráfico no autorizado.
- **Controlar** el acceso a servicios específicos.
- **Implementar** estándares de seguridad y cumplimiento.

#### Conceptos Fundamentales: Ingress y Egress

- **Ingress**: Las reglas de ingreso controlan el tráfico de entrada a un Pod.
- **Egress**: Las reglas de egreso controlan el tráfico de salida de un Pod.

Comprender estos conceptos es fundamental para entender cómo funcionan las Network Policies, ya que deberá especificar si una regla se aplica al tráfico de entrada o de salida.

#### ¿Cómo funcionan las Network Policies?

Las Network Policies utilizan `SELECTORS` para identificar grupos de Pods y establecer reglas de tráfico para ellos. La política puede especificar:

- **Ingress (entrada)**: qué Pods o direcciones IP pueden conectarse a los Pods seleccionados.
- **Egress (salida)**: a qué Pods o direcciones IP pueden conectarse los Pods seleccionados.

#### Aún no es estándar

Desafortunadamente, las Network Policies aún no son una característica estándar en todos los clústeres de Kubernetes. Recientemente, AWS anunció el soporte de Network Policies en EKS, pero aún no es una característica estándar. Para usar Network Policies en EKS, debe instalar el CNI de AWS y luego habilitar Network Policy en la configuración avanzada del CNI.

Para verificar si su clúster admite Network Policies, puede ejecutar el siguiente comando:

```bash
kubectl api-versions | grep networking
```

Si recibe el mensaje `networking.k8s.io/v1`, significa que su clúster admite Network Policies. Si recibe el mensaje `networking.k8s.io/v1beta1`, significa que su clúster no admite Network Policies.

Si su clúster no admite Network Policies, puede utilizar Calico para implementar Network Policies en su clúster. Para hacerlo, debe instalar Calico en su clúster. Puede encontrar más información sobre Calico [aquí](https://docs.projectcalico.org/getting-started/kubernetes/).

Otros CNIs que admiten Network Policies son Weave Net y Cilium, entre otros.

#### Creación de un clúster EKS con Network Policies

Supongo que, a estas alturas de la formación, ya sabe lo que es un clúster EKS, ¿verdad?

Pero aún así, haré una breve presentación solo para refrescar su memoria o ayudar a quienes acaban de unirse aquí. Hahaha.

EKS es Kubernetes gestionado por AWS, pero, ¿qué significa eso?

Cuando hablamos de clústeres Kubernetes gestionados, nos referimos a que no tendremos que preocuparnos por la instalación y configuración de Kubernetes, ya que AWS se encargará de ello. Solo necesitaremos crear nuestro clúster y gestionar nuestras aplicaciones.

Como ya sabe, tenemos dos tipos de nodos, los nodos del plano de control y los nodos trabajadores. En EKS, los nodos del plano de control son gestionados por AWS, es decir, no tendremos que preocuparnos por ellos. En cuanto a los trabajadores, en la mayoría de los casos, deberemos crearlos y gestionarlos nosotros mismos.

Antes de empezar, entendamos los tres tipos de clústeres EKS que podemos tener:

- **Grupos de nodos administrados**: en este tipo de clúster, los nodos trabajadores son gestionados por AWS, es decir, no tendremos que preocuparnos por ellos. AWS creará y gestionará los nodos trabajadores para nosotros. Este tipo de clúster es ideal para quienes no desean preocuparse por la administración de los nodos trabajadores.
- **Grupos de nodos autoadministrados**: en este tipo de clúster, los nodos trabajadores son gestionados por nosotros, lo que significa que deberemos crearlos y gestionarlos. Este tipo de clúster es ideal para quienes desean tener un control total sobre los nodos trabajadores.
- **Fargate**: en este tipo de clúster, los nodos trabajadores son gestionados por AWS, pero no tendremos que preocuparnos por ellos, ya que AWS creará y gestionará los nodos trabajadores para nosotros. Este tipo de clúster es ideal para quienes no desean preocuparse por la administración de los nodos trabajadores, pero tampoco quieren preocuparse por crearlos y gestionarlos.

Claramente, cada tipo tiene sus ventajas y desventajas, y debe analizar su situación para elegir el tipo de clúster que mejor se adapte a sus necesidades.

En la mayoría de los casos de entornos de producción, optaremos por el tipo de "Grupos de nodos autoadministrados", ya que de esta manera tendremos un control total sobre los nodos trabajadores, pudiendo personalizarlos y gestionarlos de la manera que consideremos mejor. Ahora bien, si no desea preocuparse por la administración de los nodos trabajadores, puede optar por "Grupos de nodos administrados" o "Fargate".

Cuando optamos por "Fargate", debemos tener en cuenta que no tendremos acceso a los nodos trabajadores, ya que son gestionados por AWS. Esto significa menos libertad y recursos, pero también menos preocupación y menos trabajo en la administración de los nodos trabajadores.

Para nuestro ejemplo, elegiremos el tipo de "Grupos de nodos administrados", ya que de esta manera no tendremos que preocuparnos por la administración de los nodos trabajadores. Sin embargo, recuerde que puede elegir el tipo que mejor se adapte a sus necesidades.

Para crear el clúster, utilizaremos EKSCTL, que es una herramienta de línea de comandos que nos ayuda a crear y gestionar clústeres EKS. Puede encontrar más información sobre EKSCTL [aquí](https://eksctl.io/).

Se ha convertido en una de las formas oficiales de crear y gestionar clústeres EKS y es la herramienta que más utilizo para ello. De hecho, creo que es la herramienta más utilizada para crear clústeres EKS cuando no estamos utilizando una herramienta de infraestructura como código (IaC) como Terraform, por ejemplo.

#### Instalación de EKSCTL

Para instalar EKSCTL, puede seguir las instrucciones [aquí](https://eksctl.io/installation/).

Está disponible para Linux, MacOS y Windows. También es posible ejecutarlo en un contenedor Docker.

En nuestro ejemplo, vamos a utilizar Linux, ¡por supuesto! jajaja

Para instalar EKSCTL en Linux, puede ejecutar el siguiente comando:

```bash
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin
```

Literalmente copié y pegué el comando anterior del sitio web de EKSCTL, así que no hay margen de error. Sin embargo, recuerde siempre consultar el sitio oficial para asegurarse de que no haya habido cambios.

Aquí estamos haciendo lo siguiente:

- Definiendo la arquitectura de nuestro sistema, en mi caso, `amd64`. Puede verificar la arquitectura de su sistema ejecutando el comando `uname -m`.
- Definiendo la plataforma de nuestro sistema, en mi caso, `Linux_amd64`.
- Descargando el binario de EKSCTL.
- Descomprimiendo el binario de EKSCTL.
- Moviendo el binario de EKSCTL al directorio `/usr/local/bin`.

Validación de la instalación de EKSCTL:

```bash
eksctl version
```

La salida debe ser algo similar a esto:

```bash
0.169.0
```

Esta es la versión de EKSCTL que estamos utilizando en el momento de la creación de este curso, pero es posible que esté utilizando una versión más reciente.

#### Instalación de AWS CLI

Ahora que tenemos EKSCTL instalado, necesitamos tener AWS CLI instalado y configurado, ya que EKSCTL utiliza AWS CLI para comunicarse con AWS. Puede encontrar más información sobre AWS CLI [aquí](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

AWS CLI es una herramienta de línea de comandos que nos ayuda a interactuar con los servicios de AWS. Es muy poderosa y una de las herramientas más utilizadas para interactuar con los servicios de AWS.

Aquí están los comandos para instalar AWS CLI en Linux, pero recuerde que siempre es bueno consultar el sitio web oficial para verificar si ha habido algún cambio.

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Validación de la instalación de AWS CLI:

```bash
aws --version
```

En mi caso, la versión que estoy utilizando es la siguiente:

```bash
aws-cli/2.15.10 Python/3.11.6 Linux/6.5.0-14-generic exe/x86_64.zorin.17 prompt/off
```

Ahora que tenemos AWS CLI instalado, necesitamos configurar AWS CLI. Para hacerlo, puede ejecutar el siguiente comando:

```bash
aws configure
```

Aquí deberá proporcionar sus credenciales de AWS, que puede encontrar [aquí](https://console.aws.amazon.com/iam/home?#/security_credentials).

La información que debe proporcionar incluye:

- AWS Access Key ID
- AWS Secret Access Key
- Default region name
- Default output format

Su Access Key ID y Secret Access Key se pueden encontrar [aquí](https://console.aws.amazon.com/iam/home?#/security_credentials). Luego, la región es a su elección; yo usaré la región `us-east-1`, pero puede elegir la región que prefiera. Finalmente, el formato de salida, yo usaré el formato `json`, pero puede elegir otra opción, como `text`, por ejemplo.

##### Creación del Cluster EKS

Ahora que tenemos AWS CLI instalado y configurado, podemos crear nuestro cluster EKS.

Podemos crearlo solo a través de la línea de comandos o podemos crear un archivo de configuración para facilitar la creación del cluster.

Primero proporcionaré el comando que utilizaremos y luego explicaré lo que estamos haciendo y proporcionaré el archivo de configuración.

```bash
eksctl create cluster --name=eks-cluster --version=1.28 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

Aquí estamos haciendo lo siguiente:

- `eksctl create cluster`: Comando para crear el cluster.
- `--name`: Nombre del cluster.
- `--version`: Versión de Kubernetes que utilizaremos, en mi caso, `1.28`.
- `--region`: Región donde se creará el cluster, en mi caso, `us-east-1`.
- `--nodegroup-name`: Nombre del grupo de nodos.
- `--node-type`: Tipo de instancia que utilizaremos para los nodos workers, en mi caso, `t3.medium`.
- `--nodes`: Cantidad de nodos workers que crearemos, en mi caso, `2`.
- `--nodes-min`: Cantidad mínima de nodos workers que crearemos, en mi caso, `1`.
- `--nodes-max`: Cantidad máxima de nodos workers que crearemos, en mi caso, `3`.
- `--managed`: Tipo de grupo de nodos que utilizaremos, en mi caso, `managed`.

La salida del comando debería verse algo como esto:


```bash
2024-01-26 16:12:39 [ℹ]  eksctl version 0.168.0
2024-01-26 16:12:39 [ℹ]  using region us-east-1
2024-01-26 16:12:40 [ℹ]  skipping us-east-1e from selection because it doesn't support the following instance type(s): t3.medium
2024-01-26 16:12:40 [ℹ]  setting availability zones to [us-east-1c us-east-1d]
2024-01-26 16:12:40 [ℹ]  subnets for us-east-1c - public:192.168.0.0/19 private:192.168.64.0/19
2024-01-26 16:12:40 [ℹ]  subnets for us-east-1d - public:192.168.32.0/19 private:192.168.96.0/19
2024-01-26 16:12:40 [ℹ]  nodegroup "eks-cluster-nodegroup" will use "" [AmazonLinux2/1.28]
2024-01-26 16:12:40 [ℹ]  using Kubernetes version 1.28
2024-01-26 16:12:40 [ℹ]  creating EKS cluster "eks-cluster" in "us-east-1" region with managed nodes
2024-01-26 16:12:40 [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
2024-01-26 16:12:40 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=eks-cluster'
2024-01-26 16:12:40 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "eks-cluster" in "us-east-1"
2024-01-26 16:12:40 [ℹ]  CloudWatch logging will not be enabled for cluster "eks-cluster" in "us-east-1"
2024-01-26 16:12:40 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=us-east-1 --cluster=eks-cluster'
2024-01-26 16:12:40 [ℹ]  
2 sequential tasks: { create cluster control plane "eks-cluster", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create managed nodegroup "eks-cluster-nodegroup",
    } 
}
2024-01-26 16:12:40 [ℹ]  building cluster stack "eksctl-eks-cluster-cluster"
2024-01-26 16:12:40 [ℹ]  deploying stack "eksctl-eks-cluster-cluster"
2024-01-26 16:13:10 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-cluster"
2024-01-26 16:13:41 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-cluster"
2024-01-26 16:14:41 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-cluster"
2024-01-26 16:24:48 [ℹ]  building managed nodegroup stack "eksctl-eks-cluster-nodegroup-eks-cluster-nodegroup"
2024-01-26 16:24:49 [ℹ]  deploying stack "eksctl-eks-cluster-nodegroup-eks-cluster-nodegroup"
2024-01-26 16:24:49 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-nodegroup-eks-cluster-nodegroup"
2024-01-26 16:27:40 [ℹ]  waiting for the control plane to become ready
2024-01-26 16:27:40 [✔]  saved kubeconfig as "/home/jeferson/.kube/config"
2024-01-26 16:27:40 [ℹ]  no tasks
2024-01-26 16:27:40 [✔]  all EKS cluster resources for "eks-cluster" have been created
2024-01-26 16:27:41 [ℹ]  nodegroup "eks-cluster-nodegroup" has 2 node(s)
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-55-232.ec2.internal" is ready
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-7-245.ec2.internal" is ready
2024-01-26 16:27:41 [ℹ]  waiting for at least 1 node(s) to become ready in "eks-cluster-nodegroup"
2024-01-26 16:27:41 [ℹ]  nodegroup "eks-cluster-nodegroup" has 2 node(s)
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-55-232.ec2.internal" is ready
2024-01-26 16:27:41 [ℹ]  node "ip-192-168-7-245.ec2.internal" is ready
2024-01-26 16:27:42 [ℹ]  kubectl command should work with "/home/jeferson/.kube/config", try 'kubectl get nodes'
2024-01-26 16:27:42 [✔]  EKS cluster "eks-cluster" in "us-east-1" region is ready
```

¡Cluster de EKS creado con éxito! :D

Para visualizar nuestro cluster, podemos ejecutar el siguiente comando:

```bash
kubectl get nodes
```

La salida debería verse algo como esto:

```bash
ip-192-168-22-217.ec2.internal   Ready    <none>   20m   v1.28.5-eks-5e0fdde
ip-192-168-50-0.ec2.internal     Ready    <none>   20m   v1.28.5-eks-5e0fdde
```

Ahora, vamos a crear un archivo de configuración para EKSCTL que facilitará la creación del cluster la próxima vez. Para hacerlo, vamos a crear un archivo llamado `eksctl.yaml` y agregar el siguiente contenido:

```yaml
apiVersion: eksctl.io/v1alpha5 # Versión de la API de EKSCTL
kind: ClusterConfig # Tipo de recurso que estamos creando

metadata: # Metadatos del recurso
  name: eks-cluster # Nombre del cluster
  region: us-east-1 # Región donde se creará el cluster

managedNodeGroups: # Grupos de nodos que se crearán, estamos utilizando el tipo Managed Node Groups
- name: eks-cluster-nodegroup # Nombre del grupo de nodos
  instanceType: t3.medium # Tipo de instancia que utilizaremos para los nodos workers
  desiredCapacity: 2 # Cantidad de nodos workers que crearemos
  minSize: 1 # Cantidad mínima de nodos workers que crearemos
  maxSize: 3 # Cantidad máxima de nodos workers que crearemos
```

Como puedes ver, estamos creando un cluster EKS con la misma configuración que utilizamos anteriormente, pero ahora estamos utilizando un archivo de configuración para hacerlo más fácil y ordenado. :D

Para crear el cluster utilizando el archivo de configuración, puedes ejecutar el siguiente comando:

```bash
eksctl create cluster -f eksctl.yaml
```

La salida debería ser similar a la que obtuvimos anteriormente, no hay nada nuevo que agregar aquí.

Ahora que tenemos nuestro cluster de EKS creado, vamos a instalar el CNI de AWS y habilitar la Network Policy en la configuración avanzada del CNI.

##### Instalando el complemento AWS VPC CNI

El complemento AWS VPC CNI es un complemento de red que permite que los Pods se comuniquen entre sí y con los servicios dentro del clúster. También permite que los Pods se comuniquen con servicios fuera del clúster, como Amazon S3, por ejemplo.

Usaremos EKSCTL para instalar el complemento AWS VPC CNI. Para hacerlo, puedes ejecutar el siguiente comando:

```bash
eksctl create addon --name vpc-cni --version v1.16.0-eksbuild.1 --cluster eks-cluster --force
```

Recuerda que debes reemplazar el nombre del clúster y la versión del CNI por la versión de tu clúster.

Puedes consultar el enlace a continuación para verificar la versión del CNI que debes usar:

https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html

Debes elegir la versión del CNI de acuerdo con la versión de Kubernetes que estás utilizando, así que tenlo en cuenta.

Bueno, volviendo al comando, lo que estamos haciendo aquí es lo siguiente:

- `eksctl create addon`: Comando para instalar un complemento en el clúster.
- `--name`: Nombre del complemento.
- `--version`: Versión del complemento.
- `--cluster`: Nombre del clúster.
- `--force`: Forzar la instalación del complemento.

La salida debería verse algo como esto:

```bash
2024-01-28 14:12:44 [!]  no IAM OIDC provider associated with cluster, try 'eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=eks-cluster'
2024-01-28 14:12:44 [ℹ]  Kubernetes version "1.28" in use by cluster "eks-cluster"
2024-01-28 14:12:44 [!]  OIDC is disabled but policies are required/specified for this addon. Users are responsible for attaching the policies to all nodegroup roles
2024-01-28 14:12:45 [ℹ]  creating addon
2024-01-28 14:13:49 [ℹ]  addon "vpc-cni" active
```

A pesar de ser el CNI predeterminado de EKS, no se instala por defecto, por lo que debemos instalarlo manualmente.

Si deseas ver los complementos instalados en tu clúster, puedes ejecutar el siguiente comando:

```bash
eksctl get addon --cluster eks-cluster
```

La salida debería verse algo como esto:

```bash
2024-01-28 14:16:44 [ℹ]  Kubernetes version "1.28" in use by cluster "eks-cluster"
2024-01-28 14:16:44 [ℹ]  getting all addons
2024-01-28 14:16:45 [ℹ]  to see issues for an addon run `eksctl get addon --name <addon-name> --cluster <cluster-name>`
NAME	VERSION			STATUS	ISSUES	IAMROLE	UPDATE AVAILABLE	CONFIGURATION VALUES
vpc-cni	v1.16.0-eksbuild.1	ACTIVE	0		v1.16.2-eksbuild.1	
```

O puedes acceder a la consola de AWS y verificar los complementos instalados en tu clúster, como se muestra en la siguiente imagen:

![Imagen](images/image-1.png?raw=true "EKS Cluster")

¡Listo, el CNI se ha instalado con éxito! :D

##### Habilitación de Network Policy en las Configuraciones Avanzadas del CNI

Ahora que tenemos el CNI de AWS instalado, debemos habilitar la Network Policy en las configuraciones avanzadas del CNI. Para hacerlo, debemos acceder a la consola de AWS y seguir los siguientes pasos:

- Acceder a la consola de AWS.
- Acceder al servicio EKS.
- Seleccionar su clúster.
- Seleccionar la pestaña `Add-ons` (Complementos).
- Hacer clic en Edit en el Addon `vpc-cni`.
- Configuración Avanzada del CNI.
- Habilitar el Network Policy.

![Alt text](images/image-2.png?raw=true "Clúster de EKS")

Después de algunos minutos, puede volver a acceder al Addon `vpc-cni` y verificar si la Network Policy está habilitada y actualizada con el Network Policy habilitado.

![Alt text](images/image-3.png?raw=true "Clúster de EKS")

¡Listo, el clúster está configurado! Ahora podemos continuar con nuestro ejemplo. :D

#### Instalación del Controlador de Ingress Nginx

### Instalando un Controlador de Ingress Nginx

Para que todo funcione correctamente en nuestro ejemplo, debemos instalar el Controlador de Ingress Nginx. Es importante tener en cuenta la versión del Controlador de Ingress que está instalando, ya que las versiones más recientes o más antiguas pueden no ser compatibles con la versión de Kubernetes que está utilizando. Para este tutorial, utilizaremos la versión 1.9.5.

En su terminal, ejecute los siguientes comandos:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
```

Verifique si el Controlador de Ingress se ha instalado correctamente:

```bash
kubectl get pods -n ingress-nginx
```

También puede usar la opción `wait` de `kubectl`, que esperará hasta que los pods estén listos antes de liberar la terminal. Vea:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

¡Listo, el Controlador de Ingress se ha instalado correctamente! :D

Ahora continuemos y creemos nuestra aplicación de ejemplo.

#### Nuestra Aplicación de Ejemplo

Para demostrar el funcionamiento de las Network Policies, utilizaremos una aplicación de ejemplo llamada "Giropops-Senhas". Esta aplicación consta de una aplicación Flask que utiliza Redis para almacenar las últimas contraseñas generadas. La aplicación Flask utiliza el puerto 5000, mientras que Redis utiliza el puerto 6379.

Para permitir que los usuarios accedan a nuestro clúster, la aplicación se expone a través de un Controlador de Ingress configurado con la dirección `giropops-senhas.containers.expert`. Redis se expone a través de un Service con tipo ClusterIP configurado con la dirección `redis-service.giropops.svc.cluster.local`. La dirección interna de nuestra aplicación dentro del clúster es `giropops.giropops.svc.cluster.local`. Como puede ver, tenemos tres direcciones diferentes para nuestra aplicación, cada una con un propósito diferente.

Recuerde que nuestra aplicación se ejecuta en el espacio de nombres `giropops`.

Para implementar nuestra aplicación, cree un archivo llamado `giropops-deployment.yaml` con el siguiente contenido:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: giropops-senhas
  name: giropops-senhas
spec:
  replicas: 2
  selector:
    matchLabels:
      app: giropops-senhas
  template:
    metadata:
      labels:
        app: giropops-senhas
    spec:
      containers:
      - image: linuxtips/giropops-senhas:1.0
        name: giropops-senhas
        ports:
        - containerPort: 5000
        imagePullPolicy: Always
```

E para crear nuestro Service, crearemos un archivo llamado `giropops-service.yaml` con el siguiente contenido:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: giropops-senhas
spec:
  selector:
    app: giropops-senhas
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  type: ClusterIP
```

Necesitamos el servicio Redis, que vamos a crear con el archivo `redis-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - image: redis
        name: redis
        ports:
          - containerPort: 6379
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
```

Y el servicio de Redis lo crearemos con el archivo `redis-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
  type: ClusterIP
```

Finalmente, crearemos nuestro controlador de Ingress con el archivo `giropops-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: giropops-senhas.containers.expert
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: giropops-senhas
            port:
              number: 5000
```

Crearemos el espacio de nombres (namespace) `giropops` utilizando el siguiente comando:

```bash
kubectl create namespace giropops
```

Listo, ahora que tenemos todos los archivos necesarios, desplegaremos nuestra aplicación con los siguientes comandos:

```bash
kubectl apply -f giropops-deployment.yaml -n giropops
kubectl apply -f giropops-service.yaml -n giropops
kubectl apply -f redis-deployment.yaml -n giropops
kubectl apply -f redis-service.yaml -n giropops 
kubectl apply -f giropops-ingress.yaml -n giropops
```

Verifiquemos si nuestra aplicación se está ejecutando correctamente:

```bash
kubectl get pods -n giropops
```

Asegúrese de que los servicios y el controlador de Ingress estén funcionando correctamente:

```bash
kubectl get svc -n giropops
kubectl get ingress -n giropops
```

Parece que todo funciona correctamente. Probemos nuestra aplicación:

```bash
curl giropops-senhas.containers.expert
```

Recuerde que la dirección `giropops-senhas.containers.expert` solo funcionará en mi ejemplo, ya que ya tengo la configuración DNS para esta dirección. Para probar su aplicación, deberá agregar la dirección de su aplicación en el archivo `/etc/hosts` de su computadora. Para hacerlo, agregue su dirección IP y la dirección `giropops-senhas.containers.expert` al archivo `/etc/hosts`. Por ejemplo:

```bash
192.168.100.10 giropops-senhas.containers.expert
```

### Creación de Reglas de Política de Red

#### Ingress

En nuestro ejemplo, tanto nuestra aplicación como Redis se están ejecutando en el mismo espacio de nombres, el espacio de nombres `giropops`. Por defecto, los Pods pueden comunicarse libremente entre sí. Vamos a crear una Política de Red para restringir el acceso a Redis, permitiendo que solo los Pods del espacio de nombres `giropops` puedan acceder a Redis.

Para hacerlo, creemos el archivo `permitir-redis-somente-mesmo-ns.yaml` con el siguiente contenido:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: redis-allow-same-namespace
  namespace: giropops
spec:
  podSelector:
    matchLabels:
      app: redis
  ingress:
  - from:
    - podSelector: {}
```

Vamos a entender lo que estamos haciendo aquí:

- `apiVersion`: La versión de la API que estamos utilizando.
- `kind`: El tipo de recurso que estamos creando.
- `metadata`: Metadatos del recurso.
  - `name`: El nombre de la Política de Red.
  - `namespace`: El espacio de nombres donde se creará la Política de Red.
- `spec`: La especificación de la Política de Red.
  - `podSelector`: El selector de Pods que se verán afectados por la Política de Red.
    - `matchLabels`: Las etiquetas de los Pods que se verán afectadas por la Política de Red.
  - `ingress`: Las reglas de entrada.
    - `from`: El origen del tráfico.
      - `podSelector`: El selector de Pods que pueden acceder a los Pods seleccionados, en este caso, todos los Pods del espacio de nombres `giropops`.

Siempre que vea `{}`, significa que estamos seleccionando todos los Pods que cumplen con los criterios especificados, en este caso, todos los Pods del espacio de nombres `giropops`, ya que no estamos especificando ningún criterio adicional.

Vamos a aplicar nuestra Política de Red:

```bash
kubectl apply -f permitir-redis-somente-mesmo-ns.yaml -n giropops
```

Vamos a probar el acceso a Redis desde un Pod fuera del espacio de nombres `giropops`, para ello utilizaremos el comando `redis ping`:

```bash
kubectl run -it --rm --image redis redis-client -- redis-cli -h redis-service.giropops.svc.cluster.local ping
```

Si todo está funcionando correctamente, no recibirás ninguna respuesta ya que el acceso a Redis está bloqueado para los Pods fuera del espacio de nombres `giropops`.

Ahora, si ejecutas el mismo comando desde dentro del espacio de nombres `giropops`, deberías recibir el mensaje `PONG`, ya que el acceso a Redis está permitido para los Pods dentro del espacio de nombres `giropops`. :D

Vamos a probarlo:

```bash
kubectl run -it --rm -n giropops --image redis redis-client -- redis-cli -h redis-service.giropops.svc.cluster.local ping
```

La salida debe ser algo similar a esto:

```bash
If you don't see a command prompt, try pressing enter.

PONG
Session ended, resume using 'kubectl attach redis-client -c redis-client -i -t' command when the pod is running
pod "redis-client" deleted
```

Listo, ahora que nuestra Política de Red está funcionando.

Ahora, queremos bloquear todo el acceso de entrada a los Pods en el espacio de nombres `giropops`. Para ello, crearemos el archivo `nao-permitir-nada-externo.yaml` con el siguiente contenido:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Listo, ahora que nuestra Política de Red está funcionando.

Ahora deseamos bloquear todo el acceso de entrada a los Pods del espacio de nombres `giropops`. Para ello, crearemos el archivo `nao-permitir-nada-externo.yaml` con el siguiente contenido:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Lo que ha cambiado aquí es lo siguiente:

- `policyTypes`: Tipo de política que estamos creando, en este caso, estamos creando una política de entrada.
- `ingress`: Reglas de entrada.
  - `from`: Origen del tráfico.
    - `namespaceSelector`: Selector de Espacios de nombres que pueden acceder a los Pods seleccionados, en este caso, solo el espacio de nombres `giropops`.
    - `matchLabels`: Etiquetas de los Espacios de nombres que pueden acceder a los Pods seleccionados, en este caso, solo el espacio de nombres `giropops`.
    - `kubernetes.io/metadata.name`: Nombre del Espacio de nombres.
    - `giropops`: Valor del Nombre del Espacio de nombres.

De esta manera, estamos bloqueando todo el tráfico de entrada a los Pods del espacio de nombres `giropops`, excepto para los Pods del propio espacio de nombres `giropops`.

Aplicaremos nuestra Política de Red de la siguiente manera:

```bash
kubectl apply -f nao-permitir-nada-externo.yaml -n giropops
```

Vamos probar el acceso a Redis desde un Pod fuera del espacio de nombres `giropops` utilizando el comando `redis ping`:

```bash
kubectl run -it --rm --image redis redis-client -- redis-cli -h redis-service.giropops.svc.cluster.local ping
```

Nada nuevo hasta ahora, ¿verdad? Sin embargo, vamos a probar el acceso a nuestra aplicación desde un Pod fuera del espacio de nombres `giropops` utilizando el comando `curl`:

```bash
kubectl run -it --rm --image curlimages/curl curl-client -- curl giropops-senhas.giropops.svc
```

Si todo funciona correctamente, no recibirás ninguna respuesta, ya que el acceso a nuestra aplicación está bloqueado para Pods fuera del espacio de nombres `giropops`.

Ahora, si ejecutas el mismo comando desde dentro del espacio de nombres `giropops`, deberías recibir el mensaje `Giropops Senhas`, ya que el acceso a nuestra aplicación está permitido para los Pods dentro del espacio de nombres `giropops`. ¡Probemoslo!

```bash
kubectl run -it --rm -n giropops --image curlimages/curl curl-client -- curl giropops-senhas.giropops.svc
```

Todo funciona de manera excelente. Desde el mismo espacio de nombres, podemos acceder a nuestra aplicación y a Redis, pero desde fuera del espacio de nombres, ¡no podemos acceder a nada! :D

Sin embargo, surge un problema: nuestro controlador de ingreso (Ingress Controller) no puede acceder a nuestra aplicación porque se encuentra fuera del espacio de nombres `giropops`. Así que vamos a crear una Política de red para permitir el acceso a nuestro Controlador de Ingreso.

Para ello, crearemos el archivo `permitir-ingress-controller.yaml` con el siguiente contenido:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns-and-ingress-controller
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Aquí, la solución fue muy simple: simplemente agregamos un selector de espacios de nombres adicional para permitir el acceso a nuestro Controlador de Ingreso. Con esto, todo lo que esté dentro del espacio de nombres `ingress-nginx` y `giropops` podrá acceder a los Pods del espacio de nombres `giropops`.

Podríamos mejorar el código utilizando `matchExpressions`, así:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-ns-and-ingress-controller
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: In
          values: ["ingress-nginx", "giropops"]
```

El resultado sería el mismo, pero el código estaría más limpio y sería más fácil de entender.

Ahora puedes probar el acceso a nuestra aplicación desde un Pod fuera del espacio de nombres `giropops` utilizando el comando `curl`:

```bash
kubectl run -it --rm --image curlimages/curl curl-client -- curl giropops-senhas.giropops.svc
```

Aquí no podrás acceder a nuestra aplicación porque el acceso está bloqueado para Pods fuera del espacio de nombres `giropops`. Sin embargo, si ejecutas el mismo comando desde el espacio de nombres `giropops`, todo funcionará correctamente.

Sin embargo, siempre que utilices la dirección de ingreso (Ingress) de nuestra aplicación, podrás acceder normalmente, ya que hemos permitido el acceso a nuestro Controlador de Ingreso. Por lo tanto, los clientes de nuestra aplicación que accedan desde Internet podrán hacerlo con normalidad, pero los Pods fuera del espacio de nombres `giropops` no podrán acceder a nuestra aplicación. ¿No es genial? :D

Solo una nota importante:

```yaml
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

Una cosa que debes comprender claramente al crear tus reglas son los operadores lógicos, ya que pueden cambiar por completo el resultado de tu Política de red. En nuestro ejemplo, estamos utilizando el operador lógico `OR`, es decir, estamos permitiendo el acceso a nuestro Controlador de Ingreso O a nuestro espacio de nombres `giropops`.

Si deseas permitir el acceso tanto a nuestro Ingress Controller COMO a nuestro namespace `giropops`, debes utilizar el operador lógico `AND`, como se muestra a continuación:

```yaml
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
```

En este caso, la regla funcionará de la siguiente manera: solo los Pods que estén en el espacio de nombres `ingress-nginx` Y en el espacio de nombres `giropops` podrán acceder a los Pods del espacio de nombres `giropops`. Esto podría causar problemas.

Puedes probarlo y ver qué sucede. :D

Podemos seguir un enfoque diferente, donde primero bloqueamos todo el tráfico de entrada y luego creamos reglas para permitir el tráfico de entrada a los Pods que lo necesitan. Observa:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

En este caso, bloqueamos completamente el tráfico de entrada para los Pods en el espacio de nombres `giropops`. Esto se logra utilizando `ingress: []` para bloquear todo el tráfico de entrada. Nuevamente, utilizamos `[]` vacío para seleccionar todos los Pods y bloquear todo el tráfico de entrada, ya que no especificamos ningún criterio.

El campo `policyTypes` es obligatorio, y en él debes especificar el tipo de política que estás creando. En este caso, estamos creando una política que afecta tanto al tráfico de entrada (Ingress) como al tráfico de salida (Egress).

Vamos aplicar estas reglas:

```bash
kubectl apply -f deny-all-ingress.yaml -n giropops
kubectl apply -f allow-redis-app-only.yaml -n giropops
```

Ahora, vamos crear una regla para permitir que nuestra aplicación acceda al Redis. Observa:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-redis-app-only
  namespace: giropops
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: giropops-senhas
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: giropops
    ports:
    - protocol: TCP
      port: 6379
```

Con esto, hemos creado una regla adicional que permite el acceso entre nuestra aplicación y el Redis, pero solo entre ellos y solo en los puertos 6379 y 5000.

Vamos aplicar esta regla:

```bash
kubectl apply -f permitir-ingress-controller.yaml -n giropops
```

Hemos añadido otra capa de seguridad; ahora solo nuestra aplicación puede acceder al Redis, y solo en los puertos 6379 y 5000. Sin embargo, todavía enfrentamos un problema: nuestro Controlador de Ingreso no puede acceder a nuestra aplicación, lo que significa que nuestros clientes no podrán acceder a ella. Para solucionar esto, creemos una Network Policy para permitir el acceso a nuestro Controlador de Ingreso, como se muestra a continuación:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 5000
```

Ahora, nuestro Controlador de Ingreso puede acceder a nuestra aplicación, y como resultado, nuestros clientes también pueden hacerlo.

Vamos aplicar esta regla para permitir el acceso al DNS del clúster, lo que permitirá que los Pods de nuestra aplicación accedan al Redis sin problemas:

```bash
kubectl apply -f permitir-acceso-dns.yaml -n giropops
```

Hemos resuelto un problema, ¡pero aún hay otro por resolver!

Cuando creamos la regla de Egress que bloquea todo el tráfico de salida, también bloqueamos el tráfico de salida de todos los Pods en el espacio de nombres `giropops`. Esto significa que nuestro Pod de la aplicación no puede acceder al Redis.

Para solucionar esto, creamos una Network Policy adicional para permitir el tráfico de salida hacia el Redis en el mismo espacio de nombres:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-redis
  namespace: giropops
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: redis
```

Ahora, con estas reglas, creo que hemos resuelto todos los problemas y deberíamos poder acceder a nuestra aplicación y al Redis con normalidad. ¡Listo! :D

Otra opción interesante que puedes utilizar es `ipBlock`, que te permite especificar una dirección IP o un CIDR para permitir el acceso. Aquí tienes un ejemplo:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ip-block
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.18.0.0/16
```

Con la regla anterior, estamos permitiendo el acceso solo desde el rango de direcciones IP dentro del CIDR `172.18.0.0/16`. Esto significa que solo los Pods que estén dentro de ese rango de direcciones IP podrán acceder a los Pods en el espacio de nombres `giropops`.

Todavía podemos agregar una regla de excepción, como se muestra a continuación:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ip-block
  namespace: giropops
spec:
  policyTypes:
  - Ingress
  podSelector: {}
  ingress:
  - from:
    - ipBlock:
        cidr: 172.18.0.0/16
        except:
        - 172.18.0.112/32
```

Con la regla anterior, toda la red `172.18.0.0/16` tendrá acceso, excepto la IP `172.18.0.112`, que no tendrá acceso a los Pods en el espacio de nombres `giropops`.

Hemos creado muchas Network Policies, pero no nos hemos centrado en cómo verificar si están creadas y en sus detalles. Así que veamos cómo hacerlo.

Para ver las Network Policies creadas en tu clúster, puedes ejecutar el siguiente comando:

```bash
kubectl get networkpolicies -n giropops
```

Para ver los detalles de una Network Policy en particular, puedes ejecutar el siguiente comando:

```bash
kubectl describe networkpolicy <nombre-de-la-network-policy> -n giropops
```

Para eliminar una Network Policy, puedes ejecutar el siguiente comando:

```bash
kubectl delete networkpolicy <nombre-de-la-network-policy> -n giropops
```

Es tan sencillo como volar, ¿verdad?

#### Egress

Hemos hablado mucho sobre cómo crear reglas de Ingress, es decir, reglas de entrada, pero ¿qué hay de las reglas de Egress? ¿Cómo podemos crear reglas de salida?

Para esto, tenemos el `egress`, que es muy similar al `ingress`, pero con algunas diferencias, como se muestra a continuación:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress
  namespace: giropops
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

Con la regla anterior, estamos permitiendo el acceso a los Pods que cumplen con los criterios especificados, en este caso, solo los Pods que tengan la etiqueta `app: redis` podrán acceder a los Pods del espacio de nombres `giropops` en el puerto 6379. Con esto, todos los Pods del espacio de nombres `giropops` podrán acceder a los Pods que tengan la etiqueta `app: redis` en el puerto 6379.

Ahora bien, si deseamos que solo nuestra aplicación pueda acceder a Redis, podemos hacer lo siguiente:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-only-app
  namespace: giropops
spec:
  policyTypes:
  - Egress
  podSelector: 
    matchLabels:
      app: giropops-senhas
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

Con la regla anterior, solo nuestra aplicación podrá acceder a Redis, ya que estamos utilizando `podSelector` para seleccionar solo los Pods que tengan la etiqueta `app: giropops-senhas`, es decir, solo nuestra aplicación tendrá acceso a Redis.

¡Es realmente sencillo!
