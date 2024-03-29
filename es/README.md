# Simplificando Kubernetes

Este material es parte del curso "Simplificando Kubernetes" de LINUXtips. Ha sido diseñado para capacitar a la persona estudiante o profesional de TI a trabajar con Kubernetes en entornos críticos.

El curso consta de material escrito, clases grabadas en vídeo y clases en vivo. Durante el curso, la persona será evaluada de manera práctica y deberá completar desafíos reales para avanzar en el curso.

El enfoque del curso es capacitar a la persona para trabajar con Kubernetes de manera eficiente y estar completamente preparada para trabajar en entornos críticos que utilizan contenedores.

¡Siéntase libre de aprender mucho sobre Kubernetes utilizando este libro!

## Contenido

<details>
<summary>DAY-1</summary>

- [Simplificando Kubernetes](day-1/README.md#simplificando-kubernetes)
  - [Día 1](day-1/README.md##día-1)
    - [Contenido del Día 1](day-1/README.md#contenido-del-día-1)
    - [¿Qué vamos a ver hoy?](day-1/README.md#qué-vamos-a-ver-hoy)
    - [Início de la clase Día 1](day-1/README.md#início-de-la-clase-día-1)
    - [¿Cual distribución GNU/Linux debo utilizar?](day-1/README.md#cual-distribución-gnulinux-debo-utilizar)
    - [Algunos sitios web que debemos visitar](day-1/README.md#algunos-sitios-web-que-debemos-visitar)
    - [El Container Engine](day-1/README.md#el-container-engine)
      - [OCI - Open Container Initiative](day-1/README.md#oci---open-container-initiative)
      - [El Container Runtime](day-1/README.md#el-container-runtime)
    - [¿Qué es Kubernetes?](day-1/README.md#qué-es-kubernetes)
    - [Arquitectura de k8s](day-1/README.md#arquitectura-de-k8s)
    - [Puertos de los que debemos preocuparnos](day-1/README.md#puertos-de-los-que-debemos-preocuparnos)
      - [CONTROL PLANE](day-1/README.md#control-plane)
    - [Conceptos clave de k8s](day-1/README.md#conceptos-clave-de-k8s)
    - [Instalación y personalización de Kubectl](day-1/README.md#instalación-y-personalización-de-kubectl)
      - [Instalación de Kubectl en GNU/Linux](day-1/README.md#instalación-de-kubectl-en-gnulinux)
      - [Instalación de Kubectl en macOS](day-1/README.md#instalación-de-kubectl-en-macos)
      - [Instalación de Kubectl en Windows](day-1/README.md#instalación-de-kubectl-en-windows)
    - [Personalización de kubectl](day-1/README.md#personalización-de-kubectl)
      - [Auto-completado](day-1/README.md#auto-completado)
      - [Creando un alias para kubectl](day-1/README.md#creando-un-alias-para-kubectl)
    - [Creando un clúster Kubernetes](day-1/README.md#creando-un-clúster-kubernetes)
    - [Creando el clúster en tu máquina local](day-1/README.md#creando-el-clúster-en-tu-máquina-local)
      - [Minikube](day-1/README.md#minikube)
        - [Requisitos básicos](day-1/README.md#requisitos-básicos)
        - [Instalación de Minikube en GNU/Linux](day-1/README.md#instalación-de-minikube-en-gnulinux)
        - [Instalación de Minikube en MacOS](day-1/README.md#instalación-de-minikube-en-macos)
        - [Instalación de Minikube en Microsoft Windows](day-1/README.md#instalación-de-minikube-en-microsoft-windows)
        - [Iniciando, deteniendo y eliminando Minikube](day-1/README.md#iniciando-deteniendo-y-eliminando-minikube)
        - [Bien, ¿cómo puedo saber si todo está funcionando correctamente?](day-1/README.md#bien-cómo-puedo-saber-si-todo-está-funcionando-correctamente)
        - [Ver detalles sobre el clúster](day-1/README.md#ver-detalles-sobre-el-clúster)
        - [Descubriendo la dirección de Minikube](day-1/README.md#descubriendo-la-dirección-de-minikube)
        - [Accediendo a la máquina de Minikube a través de SSH](day-1/README.md#accediendo-a-la-máquina-de-minikube-a-través-de-ssh)
        - [Panel de control de Minikube](day-1/README.md#panel-de-control-de-minikube)
        - [Logs de Minikube](day-1/README.md#logs-de-minikube)
        - [Eliminar el clúster](day-1/README.md#eliminar-el-clúster)
      - [Kind](day-1/README.md#kind)
        - [Instalación en GNU/Linux](day-1/README.md#instalación-en-gnulinux)
        - [Instalación en MacOS](day-1/README.md#instalación-en-macos)
        - [Instalación en Windows](day-1/README.md#instalación-en-windows)
          - [Instalación en Windows via Chocolatey](day-1/README.md#instalación-en-windows-via-chocolatey)
        - [Creando un clúster con Kind](day-1/README.md#creando-un-clúster-con-kind)
        - [Creando un clúster con múltiples nodos locales usando Kind](day-1/README.md#creando-un-clúster-con-múltiples-nodos-locales-usando-kind)
    - [Primeros pasos en k8s](day-1/README.md#primeros-pasos-en-k8s)
      - [Verificación de namespaces y pods](day-1/README.md#verificación-de-namespaces-y-pods)
        - [Ejecutando nuestro primer pod en k8s](day-1/README.md#ejecutando-nuestro-primer-pod-en-k8s)
        - [Ejecutando nuestro primer pod en k8s](day-1/README.md#ejecutando-nuestro-primer-pod-en-k8s-1)
      - [Exponiendo el pod y creando un Service](day-1/README.md#exponiendo-el-pod-y-creando-un-service)
      - [Limpiando todo y yendo a casa](day-1/README.md#limpiando-todo-y-yendo-a-casa)

</details>

<details>
<summary>DAY-2</summary>

- [Simplificando Kubernetes](day-2/README.md#simplificando-kubernetes)
  - [Día 2](day-2/README.md#día-2)
    - [Contenido del Día 2](day-2/README.md#contenido-del-día-2)
    - [Ínicio de la clase Día 2](day-2/README.md#ínicio-de-la-clase-día-2)
    - [¿Qué vamos a ver hoy?](day-2/README.md#qué-vamos-a-ver-hoy)
    - [¿Qué es un Pod?](day-2/README.md#qué-es-un-pod)
      - [Creando un Pod](day-2/README.md#creando-un-pod)
      - [Visualización de detalles sobre los Pods](day-2/README.md#visualización-de-detalles-sobre-los-pods)
      - [Eliminando un Pod](day-2/README.md#eliminando-un-pod)
      - [Creando un Pod mediante un archivo YAML](day-2/README.md#creando-un-pod-mediante-un-archivo-yaml)
      - [Visualizando los registros (logs) del Pod](day-2/README.md#visualizando-los-registros-logs-del-pod)
      - [Creando un Pod con múltiples contenedores](day-2/README.md#creando-un-pod-con-múltiples-contenedores)
    - [Los comandos `attach` y `exec`](day-2/README.md#los-comandos-attach-y-exec)
    - [Creando un contenedor con límites de memoria y CPU](day-2/README.md#creando-un-contenedor-con-límites-de-memoria-y-cpu)
    - [Agregando un volumen EmptyDir al Pod](day-2/README.md#agregando-un-volumen-emptydir-al-pod)

</details>

<details>
<summary>DAY-3</summary>

- [Simplificando Kubernetes](day-3/README.md#simplificando-kubernetes)
  - [Día 3](day-3/README.md#día-3)
    - [Contenido del Día 3](day-3/README.md#contenido-del-día-3)
    - [Inicio de la Lección del Día 3](day-3/README.md#inicio-de-la-lección-del-día-3)
    - [¿Qué veremos hoy?](day-3/README.md#qué-veremos-hoy)
    - [¿Qué es un Deployment?](day-3/README.md#qué-es-un-deployment)
      - [Cómo crear un Deployment](day-3/README.md#cómo-crear-un-deployment)
      - [¿Qué significa cada parte del archivo?](day-3/README.md#qué-significa-cada-parte-del-archivo)
      - [¿Cómo aplicar el Deployment?](day-3/README.md#cómo-aplicar-el-deployment)
      - [¿Cómo verificar si el Deployment se ha creado?](day-3/README.md#cómo-verificar-si-el-deployment-se-ha-creado)
      - [¿Cómo verificar los Pods que el Deployment está gestionando?](day-3/README.md#cómo-verificar-los-pods-que-el-deployment-está-gestionando)
      - [Cómo verificar el ReplicaSet que el Deployment está gestionando?](day-3/README.md#cómo-verificar-el-replicaset-que-el-deployment-está-gestionando)
      - [Cómo verificar los detalles del Deployment?](day-3/README.md#cómo-verificar-los-detalles-del-deployment)
      - [Cómo actualizar el Deployment?](day-3/README.md#cómo-actualizar-el-deployment)
      - [¿Cuál es la estrategia de actualización predeterminada del Deployment?](day-3/README.md#cuál-es-la-estrategia-de-actualización-predeterminada-del-deployment)
      - [Estrategias de actualización del Deployment](day-3/README.md#estrategias-de-actualización-del-deployment)
        - [Estrategia RollingUpdate (Actualización gradual)](day-3/README.md#estrategia-rollingupdate-actualización-gradual)
        - [Estrategia Recreate](day-3/README.md#estrategia-recreate)
      - [Realizando un rollback de una actualización](day-3/README.md#realizando-un-rollback-de-una-actualización)
      - [Eliminando un Deployment](day-3/README.md#eliminando-un-deployment)
      - [Conclusión](day-3/README.md#conclusión)

</details>

<details>
<summary>DAY-4</summary>

- [Simplificando Kubernetes](day-4/README.md#simplificando-kubernetes)
  - [Día 4](day-4/README.md#día-4)
  - [Contenido del Día 4](day-4/README.md#contenido-del-día-4)
  - [Inicio de la Lección del Día 4](day-4/README.md#inicio-de-la-lección-del-día-4)
    - [¿Qué veremos hoy?](day-4/README.md#qué-veremos-hoy)
    - [ReplicaSet](day-4/README.md#replicaset)
      - [El Deployment y el ReplicaSet](day-4/README.md#el-deployment-y-el-replicaset)
      - [Creando un ReplicaSet](day-4/README.md#creando-un-replicaset)
      - [Desactivando el ReplicaSet](day-4/README.md#desactivando-el-replicaset)
    - [El DaemonSet](day-4/README.md#el-daemonset)
      - [Creando un DaemonSet](day-4/README.md#creando-un-daemonset)
      - [Creación de un DaemonSet utilizando el comando kubectl create](day-4/README.md#creación-de-un-daemonset-utilizando-el-comando-kubectl-create)
      - [Añadiendo un nodo al clúster](day-4/README.md#añadiendo-un-nodo-al-clúster)
      - [Eliminando un DaemonSet](day-4/README.md#eliminando-un-daemonset)
    - [Las sondas de Kubernetes](day-4/README.md#las-sondas-de-kubernetes)
      - [¿Qué son las sondas?](day-4/README.md#qué-son-las-sondas)
      - [Sonda de Integridad (Liveness Probe)](day-4/README.md#sonda-de-integridad-liveness-probe)
      - [Sonda de preparación (Readiness Probe)](day-4/README.md#sonda-de-preparación-readiness-probe)
      - [Sonda de Inicio](day-4/README.md#sonda-de-inicio)
    - [Ejemplo con todas las sondas](day-4/README.md#ejemplo-con-todas-las-sondas)
    - [Tu tarea](day-4/README.md#tu-tarea)
    - [Final del Día 4](day-4/README.md#final-del-día-4)
  
</details>

<details>
<summary>DAY-5</summary>

- [Simplificando Kubernetes - Expert Mode](day-5/README.md#simplificando-kubernetes---expert-mode)
  - [Día 5](day-5/README.md#día-5)
  - [Contenido del Día 5](day-5/README.md#contenido-del-día-5)
  - [Inicio de la Lección del Día 5](day-5/README.md#inicio-de-la-lección-del-día-5)
    - [¿Qué veremos hoy?](day-5/README.md#qué-veremos-hoy)
    - [Instalación de un cluster Kubernetes](day-5/README.md#instalación-de-un-cluster-kubernetes)
      - [¿Qué es un clúster de Kubernetes?](day-5/README.md#qué-es-un-clúster-de-kubernetes)
    - [Formas de instalar Kubernetes](day-5/README.md#formas-de-instalar-kubernetes)
    - [Creando un clúster Kubernetes con kubeadm](day-5/README.md#creando-un-clúster-kubernetes-con-kubeadm)
      - [Instalación de kubeadm](day-5/README.md#instalación-de-kubeadm)
      - [Deshabilitar el uso de swap en el sistema](day-5/README.md#deshabilitar-el-uso-de-swap-en-el-sistema)
      - [Cargar los módulos del kernel](day-5/README.md#cargar-los-módulos-del-kernel)
        - [Configurando parámetros del sistema](day-5/README.md#configurando-parámetros-del-sistema)
        - [Instalando los paquetes de Kubernetes](day-5/README.md#instalando-los-paquetes-de-kubernetes)
        - [Instalando containerd](day-5/README.md#instalando-containerd)
        - [Configurando containerd](day-5/README.md#configurando-containerd)
        - [Habilitando el servicio kubelet](day-5/README.md#habilitando-el-servicio-kubelet)
        - [Configurando los puertos](day-5/README.md#configurando-los-puertos)
        - [Inicializando el clúster](day-5/README.md#inicializando-el-clúster)
        - [Comprendiendo el archivo admin.conf](day-5/README.md#comprendiendo-el-archivo-adminconf)
          - [Clusters](day-5/README.md#clusters)
          - [Contextos](day-5/README.md#contextos)
          - [Contexto actual](day-5/README.md#contexto-actual)
          - [Preferencias](day-5/README.md#preferencias)
          - [Usuarios](day-5/README.md#usuarios)
        - [Agregando los demás nodos al clúster](day-5/README.md#agregando-los-demás-nodos-al-clúster)
        - [Instalando Weave Net](day-5/README.md#instalando-weave-net)
        - [¿Qué es CNI?](day-5/README.md#qué-es-cni)
      - [Visualizando detalles de los nodos](day-5/README.md#visualizando-detalles-de-los-nodos)
    - [Tu tarea](day-5/README.md#tu-tarea)
  - [Final del Día 5](day-5/README.md#final-del-día-5)

</details>

<details>
<summary>DAY-6</summary>

- [Simplificando Kubernetes](day-6/README.md#simplificando-kubernetes)
  - [Día 6](day-6/README.md#día-6)
  - [Contenido del Día 6](day-6/README.md#contenido-del-día-6)
  - [Inicio de la Lección del Día 6](day-6/README.md#inicio-de-la-lección-del-día-6)
    - [¿Qué veremos hoy?](day-6/README.md#qué-veremos-hoy)
      - [¿Qué son los volúmenes?](day-6/README.md#qué-son-los-volúmenes)
        - [EmpytDir](day-6/README.md#empytdir)
        - [Clase de Almacenamiento (Storage Class)](day-6/README.md#clase-de-almacenamiento-storage-class)
        - [PV - Persistent Volume](day-6/README.md#pv---persistent-volume)
        - [PVC - Persistent Volume Claim](day-6/README.md#pvc---persistent-volume-claim)
    - [Tu tarea](day-6/README.md#tu-tarea)

</details>

<details>
<summary>DAY-7</summary>

- [Simplificando Kubernetes](day-7/README.md#simplificando-kubernetes)
  - [Día 7](day-7/README.md#día-7)
  - [Contenido del Día 7](day-7/README.md#contenido-del-día-7)
  - [Inicio de la Lección del Día 7](day-7/README.md#inicio-de-la-lección-del-día-7)
    - [¿Qué veremos hoy?](day-7/README.md#qué-veremos-hoy)
      - [¿Qué es un StatefulSet?](day-7/README.md#qué-es-un-statefulset)
        - [¿Cuándo usar StatefulSets?](day-7/README.md#cuándo-usar-statefulsets)
        - [¿Y cómo funcionan?](day-7/README.md#y-cómo-funcionan)
        - [El StatefulSet y los volúmenes persistentes](day-7/README.md#el-statefulset-y-los-volúmenes-persistentes)
        - [El StatefulSet y el Headless Service](day-7/README.md#el-statefulset-y-el-headless-service)
        - [Creación de un StatefulSet](day-7/README.md#creación-de-un-statefulset)
        - [Eliminando un StatefulSet](day-7/README.md#eliminando-un-statefulset)
        - [Eliminando un Servicio Headless](day-7/README.md#eliminando-un-servicio-headless)
        - [Eliminando un PVC](day-7/README.md#eliminando-un-pvc)
      - [Servicios](day-7/README.md#servicios)
        - [Tipos de Servicios](day-7/README.md#tipos-de-servicios)
        - [Cómo funcionan los Servicios](day-7/README.md#cómo-funcionan-los-servicios)
        - [Los Servicios y los Endpoints](day-7/README.md#los-servicios-y-los-endpoints)
        - [Creando un Servicio](day-7/README.md#creando-un-servicio)
          - [ClusterIP](day-7/README.md#clusterip)
          - [NodePort](day-7/README.md#nodeport)
          - [LoadBalancer](day-7/README.md#loadbalancer)
          - [ExternalName](day-7/README.md#externalname)
        - [Verificando los Services](day-7/README.md#verificando-los-services)
        - [Verificando los Endpoints](day-7/README.md#verificando-los-endpoints)
        - [Eliminando un Service](day-7/README.md#eliminando-un-service)
    - [Tu tarea](day-7/README.md#tu-tarea)

</details>

<details>
<summary>DAY-8</summary>

- [Simplificando Kubernetes](day-8/#simplificando-kubernetes)
  - [Día 8](day-8/#día-8)
    - [Contenido del Día 8](day-8/#contenido-del-día-8)
    - [¿Qué veremos hoy?](day-8/#qué-veremos-hoy)
      - [¿Qué son los Secrets?](day-8/#qué-son-los-secrets)
        - [¿Cómo funcionan los Secrets?](day-8/#cómo-funcionan-los-secrets)
        - [Tipos de Secrets](day-8/#tipos-de-secrets)
        - [Antes de crear un Secret, el Base64](day-8/#antes-de-crear-un-secret-el-base64)
        - [Creando nuestro primer Secret](day-8/#creando-nuestro-primer-secret)
        - [Usando nuestro primer Secret](day-8/#usando-nuestro-primer-secret)
        - [Creando un Secreto para almacenar credenciales de Docker](day-8/#creando-un-secreto-para-almacenar-credenciales-de-docker)
        - [Creando un Secret TLS](day-8/#creando-un-secret-tls)
      - [ConfigMaps](day-8/#configmaps)
      - [Operador de Secretos Externos](day-8/#operador-de-secretos-externos)
        - [El Rol Destacado del ESO](day-8/#el-rol-destacado-del-eso)
        - [Conceptos Clave del Operador de Secretos Externos](day-8/#conceptos-clave-del-operador-de-secretos-externos)
        - [SecretStore](day-8/#secretstore)
        - [ExternalSecret](day-8/#externalsecret)
        - [ClusterSecretStore](day-8/#clustersecretstore)
        - [Control de Acceso y Seguridad](day-8/#control-de-acceso-y-seguridad)
      - [Configurando el External Secrets Operator](day-8/#configurando-el-external-secrets-operator)
        - [¿Qué es Vault?](day-8/#qué-es-vault)
        - [¿Por Qué Usar Vault?](day-8/#por-qué-usar-vault)
        - [Comandos Básicos de Vault](day-8/#comandos-básicos-de-vault)
        - [El Vault en el Contexto de Kubernetes](day-8/#el-vault-en-el-contexto-de-kubernetes)
        - [Instalación y Configuración de Vault en Kubernetes](day-8/#instalación-y-configuración-de-vault-en-kubernetes)
        - [Requisitos Previos](day-8/#requisitos-previos)
        - [Instalando y Configurando Vault con Helm](day-8/#instalando-y-configurando-vault-con-helm)
        - [Agregar el Repositorio del Operador de Secretos Externos a Helm](day-8/#agregar-el-repositorio-del-operador-de-secretos-externos-a-helm)
        - [Instalando el Operador de Secretos Externos](day-8/#instalando-el-operador-de-secretos-externos)
        - [Verificación de la Instalación de ESO](day-8/#verificación-de-la-instalación-de-eso)
        - [Creación de un Secreto en Kubernetes](day-8/#creación-de-un-secreto-en-kubernetes)
        - [Configuración del ClusterSecretStore](day-8/#configuración-del-clustersecretstore)
        - [Creación de un ExternalSecret](day-8/#creación-de-un-externalsecret)
  - [Final del Día 8](day-8/#final-del-día-8)

&nbsp;
</details>

<details>
<summary>DAY-9</summary>

- [Simplificando Kubernetes](day-9/#simplificando-kubernetes)
  - [DÍA 9](day-9/#día-9)
    - [¿Qué veremos hoy?](day-9/#qué-veremos-hoy)
    - [Contenido del Día 9](day-9/#contenido-del-día-9)
- [¿Qué es Ingress?](day-9/#qué-es-ingress)
- [Componentes de Ingress](day-9/#componentes-de-ingress)
  - [Componentes Clave](day-9/#componentes-clave)
    - [Ingress Controller](day-9/#ingress-controller)
    - [Ingress Resources](day-9/#ingress-resources)
    - [Anotaciones y Personalizaciones](day-9/#anotaciones-y-personalizaciones)
    - [Instalación del Nginx Ingress Controller](day-9/#instalación-del-nginx-ingress-controller)
      - [Instalación del Ingress Controller Nginx en Kind](day-9/#instalación-del-ingress-controller-nginx-en-kind)
        - [Creación del Clúster con Configuraciones Especiales](day-9/#creación-del-clúster-con-configuraciones-especiales)
        - [Instalación de un Ingress Controller](day-9/#instalación-de-un-ingress-controller)
    - [Instalación de Giropops-Senhas en el Cluster](day-9/#instalación-de-giropops-senhas-en-el-cluster)
    - [Creación de un Recurso de Ingress](day-9/#creación-de-un-recurso-de-ingress)
- [TBD (Por determinar)](day-9/#tbd-por-determinar)

&nbsp;
</details>

<details>
<summary>DAY-10</summary>
TO DO
</details>

<details>
<summary>DAY-11</summary>

- [Simplificando Kubernetes](day-11/#simplificando-kubernetes)
  - [Día 11](day-11/#día-11)
  - [Contenido del Día 11](day-11/#contenido-del-día-11)
    - [Comienzo de la lección del Día 11](day-11/#comienzo-de-la-lección-del-día-11)
      - [¿Qué veremos hoy?](day-11/#qué-veremos-hoy)
      - [Introducción al Escalador Automático de Pods Horizontales (HPA)](day-11/#introducción-al-escalador-automático-de-pods-horizontales-hpa)
      - [¿Cómo funciona el HPA?](day-11/#cómo-funciona-el-hpa)
  - [Introducción al Metrics Server](day-11/#introducción-al-metrics-server)
    - [¿Por qué es importante el Metrics Server para el HPA?](day-11/#por-qué-es-importante-el-metrics-server-para-el-hpa)
    - [Instalación del Metrics Server](day-11/#instalación-del-metrics-server)
      - [En Amazon EKS y la mayoría de los clústeres Kubernetes](day-11/#en-amazon-eks-y-la-mayoría-de-los-clústeres-kubernetes)
      - [En Minikube](day-11/#en-minikube)
      - [En KinD (Kubernetes in Docker)](day-11/#en-kind-kubernetes-in-docker)
      - [Verificando la Instalación del Metrics Server](day-11/#verificando-la-instalación-del-metrics-server)
      - [Obteniendo Métricas](day-11/#obteniendo-métricas)
    - [Creando un HPA](day-11/#creando-un-hpa)
    - [Ejemplos Prácticos con HPA](day-11/#ejemplos-prácticos-con-hpa)
      - [Escalado automático basado en el uso de CPU](day-11/#escalado-automático-basado-en-el-uso-de-cpu)
      - [Escalado automático basado en el uso de Memoria](day-11/#escalado-automático-basado-en-el-uso-de-memoria)
      - [Configuración Avanzada de HPA: Definición del Comportamiento de Escalado](day-11/#configuración-avanzada-de-hpa-definición-del-comportamiento-de-escalado)
      - [ContainerResource](day-11/#containerresource)
      - [Detalles del Algoritmo de Escalado](day-11/#detalles-del-algoritmo-de-escalado)
      - [Configuraciones Avanzadas y Uso Práctico](day-11/#configuraciones-avanzadas-y-uso-práctico)
      - [Integración del HPA con Prometheus para Métricas Personalizadas](day-11/#integración-del-hpa-con-prometheus-para-métricas-personalizadas)
    - [Tu Tarea](day-11/#tu-tarea)
    - [Fin del Día 11](day-11/#fin-del-día-11)

&nbsp;
</details>

<details>
<summary>DAY-12</summary>

- [Simplificando Kubernetes](day-12/#simplificando-kubernetes)
  - [Día 12: Dominando Taints y Tolerations](day-12/#día-12-dominando-taints-y-tolerations)
  - [Contenido del Día 12](day-12/#contenido-del-día-12)
    - [Introducción](day-12/#introducción)
    - [¿Qué son Taints y Tolerations?](day-12/#qué-son-taints-y-tolerations)
    - [¿Por qué usar Taints y Tolerations?](day-12/#por-qué-usar-taints-y-tolerations)
    - [Anatomía de un Taint](day-12/#anatomía-de-un-taint)
    - [Anatomía de una Tolerations](day-12/#anatomía-de-una-tolerations)
    - [Aplicación de Taints](day-12/#aplicación-de-taints)
    - [Configuración de Tolerations](day-12/#configuración-de-tolerations)
    - [Escenarios de Uso](day-12/#escenarios-de-uso)
      - [Aislamiento de Cargas de Trabajo](day-12/#aislamiento-de-cargas-de-trabajo)
      - [Nodos Especializados](day-12/#nodos-especializados)
      - [Toleration en un Pod que Requiere GPU:](day-12/#toleration-en-un-pod-que-requiere-gpu)
      - [Evacuación y Mantenimiento de Nodos](day-12/#evacuación-y-mantenimiento-de-nodos)
      - [Combinando Taints y Tolerations con Reglas de Afinidad](day-12/#combinando-taints-y-tolerations-con-reglas-de-afinidad)
    - [Ejemplos Prácticos](day-12/#ejemplos-prácticos)
      - [Ejemplo 1: Aislamiento de Cargas de Trabajo](day-12/#ejemplo-1-aislamiento-de-cargas-de-trabajo)
      - [Ejemplo 2: Utilización de Hardware Especializado](day-12/#ejemplo-2-utilización-de-hardware-especializado)
      - [Ejemplo 3: Mantenimiento de Nodos](day-12/#ejemplo-3-mantenimiento-de-nodos)
    - [Conclusión](day-12/#conclusión)
    - [Tareas del Día](day-12/#tareas-del-día)
  - [DÍA 12+1: Comprendiendo y Dominando los Selectores](day-12/#día-121-comprendiendo-y-dominando-los-selectores)
    - [Introducción 12+1](day-12/#introducción-121)
    - [¿Qué son los Selectors?](day-12/#qué-son-los-selectors)
    - [Tipos de Selectors](day-12/#tipos-de-selectors)
      - [Equality-based Selectors](day-12/#equality-based-selectors)
      - [Set-based Selectors](day-12/#set-based-selectors)
    - [Selectors en acción](day-12/#selectors-en-acción)
      - [En Services](day-12/#en-services)
      - [En ReplicaSets](day-12/#en-replicasets)
      - [En Jobs y CronJobs](day-12/#en-jobs-y-cronjobs)
    - [Selectores y Namespaces](day-12/#selectores-y-namespaces)
    - [Escenarios de uso](day-12/#escenarios-de-uso-1)
      - [Enrutamiento de tráfico](day-12/#enrutamiento-de-tráfico)
      - [Escalado horizontal](day-12/#escalado-horizontal)
      - [Desastre y recuperación](day-12/#desastre-y-recuperación)
    - [Consejos y trampas](day-12/#consejos-y-trampas)
    - [Ejemplos prácticos](day-12/#ejemplos-prácticos-1)
      - [Ejemplo 1: Selector en un Service](day-12/#ejemplo-1-selector-en-un-service)
      - [Ejemplo 2: Selector en un ReplicaSet](day-12/#ejemplo-2-selector-en-un-replicaset)
      - [Ejemplo 3: Selectors avanzados](day-12/#ejemplo-3-selectors-avanzados)
    - [Conclusión 12+1](day-12/#conclusión-121)

</details>

<details>
<summary>DAY-13</summary>

- [Simplificando Kubernetes](day-13/#simplificando-kubernetes)
  - [Día 13: Simplificando Kyverno y las Policies en Kubernetes](day-13/#día-13-simplificando-kyverno-y-las-policies-en-kubernetes)
  - [Contenido del Día 13](day-13/#contenido-del-día-13)
  - [¿Qué veremos hoy?](day-13/#qué-veremos-hoy)
  - [Comienzo del Día 13](day-13/#comienzo-del-día-13)
    - [Introducción a Kyverno](day-13/#introducción-a-kyverno)
    - [Instalación de Kyverno](day-13/#instalación-de-kyverno)
      - [Usando Helm](day-13/#usando-helm)
    - [Verificación de la Instalación](day-13/#verificación-de-la-instalación)
    - [Creación de nuestra primera política](day-13/#creación-de-nuestra-primera-política)
      - [Ejemplo de Política: Agregar Etiqueta al Namespace](day-13/#ejemplo-de-política-agregar-etiqueta-al-namespace)
        - [Detalles de la Política: Agregar Etiqueta al Namespace](day-13/#detalles-de-la-política-agregar-etiqueta-al-namespace)
        - [Archivo de Política: `add-label-namespace.yaml`](day-13/#archivo-de-política-add-label-namespaceyaml)
        - [Uso de la Política: Agregar Etiqueta al Namespace](day-13/#uso-de-la-política-agregar-etiqueta-al-namespace)
      - [Ejemplo de Política: Prohibir Usuario Root](day-13/#ejemplo-de-política-prohibir-usuario-root)
        - [Detalles de la Política: Prohibir Usuario Root](day-13/#detalles-de-la-política-prohibir-usuario-root)
        - [Archivo de la Política: `disallow-root-user.yaml`](day-13/#archivo-de-la-política-disallow-root-useryaml)
        - [Implementación y Efecto](day-13/#implementación-y-efecto)
      - [Ejemplo de Política: Generar ConfigMap para Namespace](day-13/#ejemplo-de-política-generar-configmap-para-namespace)
        - [Detalles de la Política: Generar ConfigMap para Namespace](day-13/#detalles-de-la-política-generar-configmap-para-namespace)
        - [Archivo de Política: `generar-configmap-para-namespace.yaml`](day-13/#archivo-de-política-generar-configmap-para-namespaceyaml)
        - [Implementación y Utilidad](day-13/#implementación-y-utilidad)
      - [Ejemplo de Política: Permitir Solo Repositorios de Confianza](day-13/#ejemplo-de-política-permitir-solo-repositorios-de-confianza)
        - [Detalles de la Política: Permitir Solo Repositorios de Confianza](day-13/#detalles-de-la-política-permitir-solo-repositorios-de-confianza)
        - [Archivo de Política: `repositorio-permitido.yaml`](day-13/#archivo-de-política-repositorio-permitidoyaml)
        - [Implementación e Impacto](day-13/#implementación-e-impacto)
        - [Ejemplo de Política: Require Probes](day-13/#ejemplo-de-política-require-probes)
        - [Detalles de la Política: Require Probes](day-13/#detalles-de-la-política-require-probes)
        - [Archivo de Política: `require-probes.yaml`](day-13/#archivo-de-política-require-probesyaml)
        - [Implementación e Impacto: Require Probes](day-13/#implementación-e-impacto-require-probes)
      - [Ejemplo de Política: Uso del Exclude](day-13/#ejemplo-de-política-uso-del-exclude)
        - [Detalles de la Política: Uso del Exclude](day-13/#detalles-de-la-política-uso-del-exclude)
        - [Archivo de Política](day-13/#archivo-de-política)
        - [Implementación y Efectos: Uso del Exclude](day-13/#implementación-y-efectos-uso-del-exclude)
    - [Conclusión](day-13/#conclusión)
      - [Puntos Clave Aprendidos](day-13/#puntos-clave-aprendidos)

</details>

<details>
<summary>DAY-14</summary>

- [Simplificando Kubernetes](day-14/#simplificando-kubernetes)
  - [Día 14: Network Policies no Kubernetes](day-14/#día-14-network-policies-no-kubernetes)
  - [Contenido del Día 14](day-14/#contenido-del-día-14)
  - [Lo que veremos hoy](day-14/#lo-que-veremos-hoy)
    - [¿Qué son las Network Policies?](day-14/#qué-son-las-network-policies)
      - [¿Para qué sirven las Network Policies?](day-14/#para-qué-sirven-las-network-policies)
      - [Conceptos Fundamentales: Ingress y Egress](day-14/#conceptos-fundamentales-ingress-y-egress)
      - [¿Cómo funcionan las Network Policies?](day-14/#cómo-funcionan-las-network-policies)
      - [Aún no es estándar](day-14/#aún-no-es-estándar)
      - [Creación de un clúster EKS con Network Policies](day-14/#creación-de-un-clúster-eks-con-network-policies)
      - [Instalación de EKSCTL](day-14/#instalación-de-eksctl)
      - [Instalación de AWS CLI](day-14/#instalación-de-aws-cli)
        - [Creación del Cluster EKS](day-14/#creación-del-cluster-eks)
        - [Instalando el complemento AWS VPC CNI](day-14/#instalando-el-complemento-aws-vpc-cni)
        - [Habilitación de Network Policy en las Configuraciones Avanzadas del CNI](day-14/#habilitación-de-network-policy-en-las-configuraciones-avanzadas-del-cni)
      - [Instalación del Controlador de Ingress Nginx](day-14/#instalación-del-controlador-de-ingress-nginx)
    - [Instalando un Controlador de Ingress Nginx](day-14/#instalando-un-controlador-de-ingress-nginx)
      - [Nuestra Aplicación de Ejemplo](day-14/#nuestra-aplicación-de-ejemplo)
    - [Creación de Reglas de Política de Red](day-14/#creación-de-reglas-de-política-de-red)
      - [Ingress](day-14/#ingress)
      - [Egress](day-14/#egress)

</details>

<details>
<summary>DAY-15</summary>

- [Simplificando Kubernetes](day-15/#simplificando-kubernetes)
  - [Día 15: Descomplicando RBAC e controle de acesso no Kubernetes](day-15/#día-15-descomplicando-rbac-e-controle-de-acesso-no-kubernetes)
  - [Contenido del Día 15](day-15/#contenido-del-día-15)
- [¿Qué vamos a aprender hoy?](day-15/#qué-vamos-a-aprender-hoy)
- [RBAC](day-15/#rbac)
  - [¿Qué es RBAC?](day-15/#qué-es-rbac)
    - [Primer ejemplo de RBAC](day-15/#primer-ejemplo-de-rbac)
      - [Creación de un Usuario para Acceso al clúster](day-15/#creación-de-un-usuario-para-acceso-al-clúster)
      - [Creando un Rol para nuestro usuario](day-15/#creando-un-rol-para-nuestro-usuario)
      - [apiGroups](day-15/#apigroups)
      - [Verbos](day-15/#verbos)
      - [Agregando el certificado del usuario al kubeconfig](day-15/#agregando-el-certificado-del-usuario-al-kubeconfig)
      - [Accediendo al clúster con el nuevo usuario](day-15/#accediendo-al-clúster-con-el-nuevo-usuario)

</details>

&nbsp;

## El entrenamiento Simplificando Kubernetes

Hemos diseñado un entrenamiento verdaderamente práctico en el que podrás aprender los conceptos y la teoría con una excelente didáctica, utilizando ejemplos y desafíos prácticos para que puedas aplicar todo el conocimiento adquirido. Esto es fundamental para que puedas asimilar y explorar aún más el contenido del entrenamiento.
Y finalmente, simularemos algunas conversaciones para que se asemeje un poco más al día a día en el entorno laboral.

Durante el entrenamiento, abordaremos todos los temas importantes de Kubernetes, para que al final del mismo, tengas todo el conocimiento y la confianza necesaria para implementar y administrar Kubernetes en entornos críticos y complejos.

¿Estás listo para comenzar nuestro viaje?
&nbsp;

### El contenido del programa

El contenido aún se está ajustando, y al final del entrenamiento tendremos el contenido completo.

&nbsp;

### ¿Cómo adquirir el entrenamiento?

Para adquirir el entrenamiento [Simplificando Kubernetes](https://www.linuxtips.io/), debes visitar la tienda de [LINUXtips](https://www.linuxtips.io/).

&nbsp;

## La idea del formato del entrenamiento

Enseñar Kubernetes de una manera más real, entregando todo el contenido de forma práctica y conectándolo con el entorno real de trabajo.

Este es el primer entrenamiento sobre Kubernetes de forma realmente práctica, basado en la vida real. Entendemos que la práctica es el conjunto de comprensión de un tema, seguido de ejemplos reales que pueden ser reproducidos y conectando todo esto con la forma en que trabajamos.

Así, la definición de práctica se convierte en un enfoque en el conocimiento de la herramienta y agregando la realidad de un profesional en su día a día al aprender una nueva tecnología, una nueva herramienta.

Prepárate para un nuevo tipo de entrenamiento, y lo mejor, prepárate para un nuevo concepto de entrenamiento práctico y aprendizaje de tecnología.
&nbsp;

El contenido de este material está dividido en partes llamadas, a las que llamamos "día" (day_one, day_two, day_three, etc.), para facilitar el aprendizaje. La idea es que el estudiante se enfoque en aprender por etapas y, por lo tanto, recomendamos que pase a la siguiente parte solo cuando se sienta completamente cómodo con el contenido actual.

En este material, encontrarás contenido que abarca desde nivel principiante hasta avanzado sobre Kubernetes, y ahora que se ha vuelto de código abierto, con la ayuda de todos, construiremos el material más grande y completo sobre Kubernetes del mundo.

Contamos con tu colaboración para hacer que este material sea aún más completo, ¡colabora! Para contribuir con mejoras en el contenido, sigue las instrucciones de este [tutorial](CONTRIBUTING.md).

Mira los videos sobre Kubernetes, DevOps, Automatización y otros temas relacionados con la tecnología en los canales de LINUXtips:

- [Canal de LINUXtips en YouTube](https://www.youtube.com/LINUXtips)

- [Canal de LINUXtips en Twitch](https://www.twitch.com/LINUXtips)

Consulta los cursos disponibles de LINUXtips:

- [Sitio Oficial de LINUXtips](https://linuxtips.io/)

Principales enlaces de LINUXtips:

- [Todos los Enlaces de LINUXtips](https://linktr.ee/LINUXtips)

Acceso al Libro Simplificando Kubernetes:

- [LIBRO - Simplificando Kubernetes](SUMMARY.md)
