# Simplificando Kubernetes

## Día 11

&nbsp;

## Contenido del Día 11

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 11](#día-11)
  - [Contenido del Día 11](#contenido-del-día-11)
    - [Comienzo de la lección del Día 11](#comienzo-de-la-lección-del-día-11)
      - [¿Qué veremos hoy?](#qué-veremos-hoy)
      - [Introducción al Escalador Automático de Pods Horizontales (HPA)](#introducción-al-escalador-automático-de-pods-horizontales-hpa)
      - [¿Cómo funciona el HPA?](#cómo-funciona-el-hpa)
  - [Introducción al Metrics Server](#introducción-al-metrics-server)
    - [¿Por qué es importante el Metrics Server para el HPA?](#por-qué-es-importante-el-metrics-server-para-el-hpa)
    - [Instalación del Metrics Server](#instalación-del-metrics-server)
      - [En Amazon EKS y la mayoría de los clústeres Kubernetes](#en-amazon-eks-y-la-mayoría-de-los-clústeres-kubernetes)
      - [En Minikube](#en-minikube)
      - [En KinD (Kubernetes in Docker)](#en-kind-kubernetes-in-docker)
      - [Verificando la Instalación del Metrics Server](#verificando-la-instalación-del-metrics-server)
      - [Obteniendo Métricas](#obteniendo-métricas)
    - [Creando un HPA](#creando-un-hpa)
    - [Ejemplos Prácticos con HPA](#ejemplos-prácticos-con-hpa)
      - [Escalado automático basado en el uso de CPU](#escalado-automático-basado-en-el-uso-de-cpu)
      - [Escalado automático basado en el uso de Memoria](#escalado-automático-basado-en-el-uso-de-memoria)
      - [Configuración Avanzada de HPA: Definición del Comportamiento de Escalado](#configuración-avanzada-de-hpa-definición-del-comportamiento-de-escalado)
      - [ContainerResource](#containerresource)
      - [Detalles del Algoritmo de Escalado](#detalles-del-algoritmo-de-escalado)
      - [Configuraciones Avanzadas y Uso Práctico](#configuraciones-avanzadas-y-uso-práctico)
      - [Integración del HPA con Prometheus para Métricas Personalizadas](#integración-del-hpa-con-prometheus-para-métricas-personalizadas)
    - [Tu Tarea](#tu-tarea)
    - [Fin del Día 11](#fin-del-día-11)

&nbsp;

### Comienzo de la lección del Día 11

#### ¿Qué veremos hoy?

¡Hoy es un día particularmente fascinante! Vamos a explorar los territorios de Kubernetes, adentrándonos en la magia del Escalador Automático de Pods Horizontales (Horizontal Pod Autoscaler - HPA, por sus siglas en inglés), una herramienta indispensable para aquellos que buscan una operación eficiente y resistente. Así que abróchense los cinturones y prepárense para un viaje de descubrimientos. ¡La aventura #VAIIII comienza!

#### Introducción al Escalador Automático de Pods Horizontales (HPA)

El Escalador Automático de Pods Horizontales, cariñosamente conocido como HPA, es una de las joyas brillantes incrustadas en el corazón de Kubernetes. Con el HPA, podemos ajustar automáticamente el número de réplicas de un conjunto de pods, asegurando que nuestra aplicación siempre tenga los recursos necesarios para funcionar de manera eficiente, sin desperdiciar recursos. El HPA es como un director de orquesta que, con la batuta de las métricas, dirige la orquesta de pods, asegurando que la armonía se mantenga incluso cuando la sinfonía del tráfico de red alcance su clímax.

#### ¿Cómo funciona el HPA?

El HPA es el vigilante que monitorea las métricas de nuestros pods. En cada latido de su corazón métrico, que ocurre a intervalos regulares, evalúa si los pods están esforzándose al máximo para satisfacer las demandas o si están descansando más de lo necesario. Basándose en esta evaluación, toma la sabia decisión de convocar a más soldados al campo de batalla o de darles un merecido descanso.

¿El servidor de métricas es importante para el funcionamiento del Escalador Automático de Pods Horizontales (HPA)? ¡Absolutamente! El servidor de métricas es un componente crucial, ya que proporciona las métricas necesarias para que el HPA tome decisiones de escalado. Ahora, profundicemos un poco más en el servidor de métricas y cómo instalarlo en diferentes entornos de Kubernetes, incluyendo Minikube y KinD.

## Introducción al Metrics Server

Antes de comenzar a explorar el Escalador Automático de Pods Horizontales (HPA), es esencial tener el Metrics Server instalado en nuestro clúster Kubernetes. El Metrics Server es un agregador de métricas de recursos del sistema que recopila métricas como el uso de la CPU y la memoria de los nodos y pods en el clúster. Estas métricas son vitales para el funcionamiento del HPA, ya que se utilizan para determinar cuándo y cómo escalar los recursos.

### ¿Por qué es importante el Metrics Server para el HPA?

El HPA utiliza métricas de uso de recursos para tomar decisiones inteligentes sobre la escalabilidad de los pods. Por ejemplo, si el uso de la CPU de un pod supera cierto límite, el HPA puede decidir aumentar el número de réplicas de ese pod. Del mismo modo, si el uso de la CPU es muy bajo, el HPA puede decidir reducir el número de réplicas. Para hacer esto de manera efectiva, el HPA necesita acceder a métricas precisas y actualizadas, que son proporcionadas por el Metrics Server.
Por lo tanto, es fundamental comprender esta pieza clave para el día de hoy. :D

### Instalación del Metrics Server

#### En Amazon EKS y la mayoría de los clústeres Kubernetes

Durante nuestra lección, estoy utilizando un clúster EKS, y para instalar el Metrics Server, podemos utilizar el siguiente comando:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Este comando aplica el manifiesto del Metrics Server a su clúster, instalando todos los componentes necesarios.

#### En Minikube

La instalación del Metrics Server en Minikube es bastante sencilla. Utilice el siguiente comando para habilitar el Metrics Server:

```bash
minikube addons enable metrics-server
```

Después de ejecutar este comando, el Metrics Server se instalará y activará en su clúster Minikube.

#### En KinD (Kubernetes in Docker)

Para KinD, puede utilizar el mismo comando que utilizó para EKS:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### Verificando la Instalación del Metrics Server

Después de instalar el Metrics Server, es una buena práctica verificar si se ha instalado correctamente y si está funcionando según lo previsto. Ejecute el siguiente comando para obtener la lista de pods en el espacio de nombres `kube-system` y verificar si el pod del Metrics Server está en ejecución:

```bash
kubectl get pods -n kube-system | grep metrics-server
```

#### Obteniendo Métricas

Con el Metrics Server en funcionamiento, ahora puede comenzar a recopilar métricas de su clúster. Aquí hay un ejemplo de cómo puede obtener métricas de uso de CPU y memoria para todos sus nodos:

```bash
kubectl top nodes
```

Y para obtener métricas de uso de CPU y memoria para todos sus pods:

```bash
kubectl top pods
```

Estos comandos proporcionan una visión rápida del uso de recursos en su clúster, lo cual es fundamental para comprender y optimizar el rendimiento de sus aplicaciones.

### Creando un HPA

Antes de profundizar en el HPA, hagamos un resumen creando un despliegue simple para nuestro confiable servidor Nginx.

```yaml
# Definición de un Despliegue para el servidor Nginx
apiVersion: apps/v1  # Versión de la API que define un Despliegue
kind: Deployment     # Tipo de recurso que estamos definiendo
metadata:
  name: nginx-deployment  # Nombre de nuestro Despliegue
spec:
  replicas: 3             # Número inicial de réplicas
  selector:
    matchLabels:
      app: nginx         # Etiqueta que identifica los pods de este Despliegue
  template:
    metadata:
      labels:
        app: nginx       # Etiqueta aplicada a los pods
    spec:
      containers:
      - name: nginx      # Nombre del contenedor
        image: nginx:latest  # Imagen del contenedor
        ports:
        - containerPort: 80  # Puerto expuesto por el contenedor
        resources:
          limits:
            cpu: 500m        # Límite de CPU
            memory: 256Mi    # Límite de memoria
          requests:
            cpu: 250m        # Solicitud de CPU
            memory: 128Mi    # Solicitud de memoria
```

Ahora, con nuestro despliegue listo, demos el siguiente paso en la creación de nuestro HPA.

```yaml
# Definición del HPA para nginx-deployment
apiVersion: autoscaling/v2  # Versión de la API que define un HPA
kind: HorizontalPodAutoscaler  # Tipo de recurso que estamos definiendo
metadata:
  name: nginx-deployment-hpa  # Nombre de nuestro HPA
spec:
  scaleTargetRef:
    apiVersion: apps/v1        # Versión de la API del recurso objetivo
    kind: Deployment           # Tipo de recurso objetivo
    name: nginx-deployment     # Nombre del recurso objetivo
  minReplicas: 3               # Número mínimo de réplicas
  maxReplicas: 10              # Número máximo de réplicas
  metrics:
  - type: Resource             # Tipo de métrica (recurso del sistema)
    resource:
      name: cpu                # Nombre de la métrica (CPU en este caso)
      target:
        type: Utilization      # Tipo de destino (utilización)
        averageUtilization: 50 # Valor objetivo (50% de utilización)
```

En este ejemplo, creamos un HPA que supervisa el uso de la CPU de nuestro `nginx-deployment`. El HPA se esforzará por mantener el uso de la CPU en torno al 50%, ajustando el número de réplicas entre 3 y 10 según sea necesario.

Para aplicar esta configuración a su clúster Kubernetes, guarde el contenido anterior en un archivo llamado `nginx-deployment-hpa.yaml` y ejecute el siguiente comando:

```bash
kubectl apply -f nginx-deployment-hpa.yaml
```

Ahora que tienes un HPA supervisando y ajustando la escala de tu `nginx-deployment` basado en el uso de la CPU. ¡Fantástico, ¿verdad?

### Ejemplos Prácticos con HPA

Ahora que ya tienes una comprensión básica del HPA, es hora de poner manos a la obra. Exploraremos cómo el HPA responde a diferentes métricas y escenarios.

#### Escalado automático basado en el uso de CPU

Comencemos con un ejemplo clásico de escalado basado en el uso de la CPU, que ya discutimos anteriormente. Para que el aprendizaje sea más interactivo, simularemos un aumento de tráfico y observaremos cómo el HPA responde a este cambio.

```bash
kubectl run -i --tty load-generator --image=busybox /bin/sh

while true; do wget -q -O- http://nginx-deployment.default.svc.cluster.local; done
```

Este sencillo script crea una carga constante en nuestro despliegue, realizando solicitudes continuas al servidor Nginx. Podrás observar cómo el HPA ajusta el número de réplicas para mantener el uso de la CPU cerca del límite definido.

#### Escalado automático basado en el uso de Memoria

El HPA no solo es experto en el manejo de la CPU, sino que también tiene un agudo sentido para la memoria. Exploraremos cómo configurar el HPA para escalar basado en el uso de la memoria.

```yaml
# Definición del HPA para escalado basado en memoria
apiVersion: autoscaling/v2  # Versión de la API que define un HPA
kind: HorizontalPodAutoscaler  # Tipo de recurso que estamos definiendo
metadata:
  name: nginx-deployment-hpa-memory  # Nombre de nuestro HPA
spec:
  scaleTargetRef:
    apiVersion: apps/v1  # Versión de la API del recurso objetivo
    kind: Deployment     # Tipo de recurso objetivo
    name: nginx-deployment  # Nombre del recurso objetivo
  minReplicas: 3          # Número mínimo de réplicas
  maxReplicas: 10         # Número máximo de réplicas
  metrics:
  - type: Resource        # Tipo de métrica (recurso del sistema)
    resource:
      name: memory        # Nombre de la métrica (memoria en este caso)
      target:
        type: Utilization  # Tipo de objetivo (utilización)
        averageUtilization: 70  # Valor objetivo (70% de utilización)
```

En este ejemplo, el HPA ajustará el número de réplicas para mantener el uso de la memoria en alrededor del 70%. De esta manera, nuestro despliegue puede funcionar sin problemas incluso cuando la demanda aumenta.

#### Configuración Avanzada de HPA: Definición del Comportamiento de Escalado

El HPA es flexible y te permite definir cómo debe comportarse durante el escalado hacia arriba y hacia abajo. Vamos a explorar un ejemplo:

```yaml
# Definición de HPA con configuración avanzada de comportamiento
apiVersion: autoscaling/v2  # Versión de la API que define un HPA
kind: HorizontalPodAutoscaler  # Tipo de recurso que estamos definiendo
metadata:
  name: nginx-deployment-hpa  # Nombre de nuestro HPA
spec:
  scaleTargetRef:
    apiVersion: apps/v1  # Versión de la API del recurso objetivo
    kind: Deployment     # Tipo de recurso objetivo
    name: nginx-deployment  # Nombre del recurso objetivo
  minReplicas: 3  # Número mínimo de réplicas
  maxReplicas: 10  # Número máximo de réplicas
  metrics:
  - type: Resource  # Tipo de métrica (recurso del sistema)
    resource:
      name: cpu  # Nombre de la métrica (CPU en este caso)
      target:
        type: Utilization  # Tipo de objetivo (utilización)
        averageUtilization: 50  # Valor objetivo (50% de utilización)
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0  # Período de estabilización para el escalado hacia arriba
      policies:
      - type: Percent  # Tipo de política (porcentaje)
        value: 100  # Valor de la política (100%)
        periodSeconds: 15  # Período de la política (15 segundos)
    scaleDown:
      stabilizationWindowSeconds: 300  # Período de estabilización para el escalado hacia abajo
      policies:
      - type: Percent  # Tipo de política (porcentaje)
        value: 100  # Valor de la política (100%)
        periodSeconds: 15  # Período de la política (15 segundos)
```

En este ejemplo, especificamos un comportamiento de escalado en el que el HPA puede escalar hacia arriba de inmediato, pero esperará durante 5 minutos (300 segundos) después del último escalado hacia arriba antes de considerar un escalado hacia abajo. Esto ayuda a evitar fluctuaciones rápidas en el recuento de réplicas, proporcionando un entorno más estable para nuestros pods.

#### ContainerResource

El tipo de métrica `ContainerResource` en Kubernetes te permite especificar métricas de recursos específicas del contenedor para el escalado. A diferencia de las métricas de recursos comunes que se aplican a todos los contenedores en un Pod, las métricas `ContainerResource` te permiten especificar métricas para un contenedor específico dentro de un Pod. Esto puede ser útil en escenarios en los que tienes múltiples contenedores en un Pod, pero deseas escalar en función del uso de recursos de un contenedor en particular.

Aquí tienes un ejemplo de cómo configurar un Horizontal Pod Autoscaler (HPA) utilizando una métrica `ContainerResource` para escalar un Deployment en función del uso de CPU de un contenedor específico:

```yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: ContainerResource
    containerResource:
      name: cpu
      container: nginx-NOMBRE-COMPLETO-DEL-CONTENEDOR
      target:
        type: Utilization
        averageUtilization: 50
```

En el ejemplo anterior:

- El tipo de métrica se define como `ContainerResource`.
- Dentro del bloque `containerResource`, especificamos el nombre de la métrica (`cpu`), el nombre del contenedor (`mi-contenedor`) y el objetivo de utilización (`averageUtilization: 50`).

Esto significa que el HPA ajustará el número de réplicas del Deployment `my-app` para mantener el uso promedio de CPU del contenedor `nginx-NOMBRE-COMPLETO-DEL-CONTENEDOR` en alrededor del 50%.

Este tipo de configuración permite un control más granular sobre el comportamiento del escalado automático, especialmente en entornos donde los Pods contienen múltiples contenedores con perfiles de uso de recursos diferentes.

#### Detalles del Algoritmo de Escalado

**Cálculo del Número de Réplicas**
El núcleo del Horizontal Pod Autoscaler (HPA) es su algoritmo de escalado, que determina el número óptimo de réplicas en función de las métricas proporcionadas. La fórmula básica utilizada por el HPA para calcular el número deseado de réplicas es:

\[ \text{desiredReplicas} = \lceil \text{currentReplicas} \times \left( \frac{\text{currentMetricValue}}{\text{desiredMetricValue}} \right) \rceil \]

**Ejemplos con Valores Específicos:**

1. **Ejemplo de Escalado hacia Arriba:**
   - Réplicas actuales: 2
   - Valor actual de la métrica (CPU): 80%
   - Valor deseado de la métrica (CPU): 50%
   - Cálculo: \(\lceil 2 \times (80\% / 50\%) \rceil = \lceil 3.2 \rceil = 4\) réplicas

2. **Ejemplo de Escalado hacia Abajo:**
   - Réplicas actuales: 5
   - Valor actual de la métrica (CPU): 30%
   - Valor deseado de la métrica (CPU): 50%
   - Cálculo: \(\lceil 5 \times (30\% / 50\%) \rceil = \lceil 3 \rceil = 3\) réplicas

**Consideraciones sobre Métricas y Estado de los Pods:**

- **Métricas de Recursos por Pod y Personalizadas:** El HPA se puede configurar para utilizar métricas estándar (como CPU y memoria) o métricas personalizadas definidas por el usuario, lo que permite una mayor flexibilidad.
- **Tratamiento de Pods sin Métricas o no Listos:** Si un Pod no tiene métricas disponibles o no está listo, puede ser excluido del cálculo promedio, evitando decisiones de escalado basadas en datos incompletos.

#### Configuraciones Avanzadas y Uso Práctico

**Configuración de Métricas Personalizadas y Múltiples Métricas:**
El HPA no se limita a métricas de CPU y memoria; se puede configurar para utilizar una variedad de métricas personalizadas.

**Uso de Métricas Personalizadas: Ejemplos y Consejos:**

- **Ejemplo:** Supongamos que tiene un servicio que debe escalar según el número de solicitudes HTTP por segundo. Puede configurar el HPA para escalar en función de esta métrica personalizada.
- **Consejos:** Al utilizar métricas personalizadas, asegúrese de que las métricas sean un indicador confiable de la carga de trabajo y de que el servicio de métricas esté configurado correctamente y sea accesible para el HPA.

**Escalado Basado en Múltiples Métricas:**

- El HPA se puede configurar para tener en cuenta varias métricas al mismo tiempo, lo que permite un control más refinado del escalado.
- Por ejemplo, puede configurar el HPA para escalar en función tanto del uso de la CPU como de la memoria, o cualquier combinación de métricas estándar y personalizadas.

#### Integración del HPA con Prometheus para Métricas Personalizadas

Para llevar el escalado automático al siguiente nivel, podemos integrar el HPA con Prometheus. Con esta integración, podemos utilizar métricas de Prometheus para informar nuestras decisiones de escalado automático.

La integración generalmente implica configurar un adaptador de métricas personalizadas, como el `k8s-prometheus-adapter`. Una vez configurado, el HPA puede acceder a las métricas de Prometheus y utilizarlas para tomar decisiones de escalado automático. Puede encontrar la documentación completa sobre cómo integrar el HPA con Prometheus [aquí](#enlace-a-la-documentación).

### Tu Tarea

Ahora que has adquirido conocimientos sobre el HPA, es hora de poner en práctica ese conocimiento. Configura un HPA en tu entorno y experimenta con diferentes métricas: CPU, memoria y métricas personalizadas. Documenta tus observaciones y comprende cómo responde el HPA a diferentes cargas y situaciones.

### Fin del Día 11

Y así llegamos al final del Día 11, un viaje lleno de aprendizaje y exploración. Hoy has descubierto el poder del Horizontal Pod Autoscaler y cómo puede ayudar a que tu aplicación funcione eficientemente incluso bajo diferentes condiciones de carga. No solo has aprendido cómo funciona, sino que también has puesto en práctica ejemplos prácticos. Sigue practicando y explorando, ¡y nos vemos en el próximo día de nuestra aventura en Kubernetes! #VAIIII
