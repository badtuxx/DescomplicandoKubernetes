# Simplificando Kubernetes

## Día 12: Dominando Taints y Tolerations

&nbsp;

## Contenido del Día 12

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 12: Dominando Taints y Tolerations](#día-12-dominando-taints-y-tolerations)
  - [Contenido del Día 12](#contenido-del-día-12)
    - [Introducción](#introducción)
    - [¿Qué son Taints y Tolerations?](#qué-son-taints-y-tolerations)
    - [¿Por qué usar Taints y Tolerations?](#por-qué-usar-taints-y-tolerations)
    - [Anatomía de un Taint](#anatomía-de-un-taint)
    - [Anatomía de una Tolerations](#anatomía-de-una-tolerations)
    - [Aplicación de Taints](#aplicación-de-taints)
    - [Configuración de Tolerations](#configuración-de-tolerations)
    - [Escenarios de Uso](#escenarios-de-uso)
      - [Aislamiento de Cargas de Trabajo](#aislamiento-de-cargas-de-trabajo)
      - [Nodos Especializados](#nodos-especializados)
      - [Toleration en un Pod que Requiere GPU:](#toleration-en-un-pod-que-requiere-gpu)
      - [Evacuación y Mantenimiento de Nodos](#evacuación-y-mantenimiento-de-nodos)
      - [Combinando Taints y Tolerations con Reglas de Afinidad](#combinando-taints-y-tolerations-con-reglas-de-afinidad)
    - [Ejemplos Prácticos](#ejemplos-prácticos)
      - [Ejemplo 1: Aislamiento de Cargas de Trabajo](#ejemplo-1-aislamiento-de-cargas-de-trabajo)
      - [Ejemplo 2: Utilización de Hardware Especializado](#ejemplo-2-utilización-de-hardware-especializado)
      - [Ejemplo 3: Mantenimiento de Nodos](#ejemplo-3-mantenimiento-de-nodos)
    - [Conclusión](#conclusión)
    - [Tareas del Día](#tareas-del-día)
  - [DÍA 12+1: Comprendiendo y Dominando los Selectores](#día-121-comprendiendo-y-dominando-los-selectores)
    - [Introducción 12+1](#introducción-121)
    - [¿Qué son los Selectors?](#qué-son-los-selectors)
    - [Tipos de Selectors](#tipos-de-selectors)
      - [Equality-based Selectors](#equality-based-selectors)
      - [Set-based Selectors](#set-based-selectors)
    - [Selectors en acción](#selectors-en-acción)
      - [En Services](#en-services)
      - [En ReplicaSets](#en-replicasets)
      - [En Jobs y CronJobs](#en-jobs-y-cronjobs)
    - [Selectores y Namespaces](#selectores-y-namespaces)
    - [Escenarios de uso](#escenarios-de-uso-1)
      - [Enrutamiento de tráfico](#enrutamiento-de-tráfico)
      - [Escalado horizontal](#escalado-horizontal)
      - [Desastre y recuperación](#desastre-y-recuperación)
    - [Consejos y trampas](#consejos-y-trampas)
    - [Ejemplos prácticos](#ejemplos-prácticos-1)
      - [Ejemplo 1: Selector en un Service](#ejemplo-1-selector-en-un-service)
      - [Ejemplo 2: Selector en un ReplicaSet](#ejemplo-2-selector-en-un-replicaset)
      - [Ejemplo 3: Selectors avanzados](#ejemplo-3-selectors-avanzados)
    - [Conclusión 12+1](#conclusión-121)

### Introducción

¡Hola a todos! En el capítulo de hoy, vamos a sumergirnos profundamente en uno de los conceptos más poderosos y flexibles de Kubernetes: Taints (Marcas) y Tolerations (Tolerancias). Prepárense, porque este capítulo va más allá de lo básico y entra en detalles que no querrán perderse. #VAMOS

### ¿Qué son Taints y Tolerations?

Los Taints son "manchas" o "marcas" aplicadas a los Nodos que los marcan para evitar que ciertos Pods sean programados en ellos. Por otro lado, las Tolerations son configuraciones que se pueden aplicar a los Pods para permitir que sean programados en Nodos con Taints específicos.

### ¿Por qué usar Taints y Tolerations?

En un clúster Kubernetes diverso, no todos los Nodos son iguales. Algunos pueden tener acceso a recursos especiales como GPUs, mientras que otros pueden estar reservados para cargas de trabajo críticas. Los Taints y Tolerations proporcionan un mecanismo para asegurar que los Pods se programen en los Nodos adecuados.

### Anatomía de un Taint

Un Taint está compuesto por una `clave`, un `valor` y un `efecto`. El efecto puede ser:

- `NoSchedule`: Kubernetes no programa el Pod a menos que tenga una Tolerations correspondiente.
- `PreferNoSchedule`: Kubernetes intenta no programar, pero no hay garantía.
- `NoExecute`: Los Pods existentes son eliminados si no tienen una Tolerations correspondiente.

### Anatomía de una Tolerations

Una Tolerations se define mediante los mismos elementos que un Taint: `clave`, `valor` y `efecto`. Además, contiene un `operador`, que puede ser `Equal` o `Exists`.

### Aplicación de Taints

Para aplicar un Taint a un Nodo, puedes utilizar el comando `kubectl taint`. Por ejemplo:

```bash
kubectl taint nodes nodo1 clave=valor:NoSchedule
```

### Configuración de Tolerations

Las Tolerations se configuran en el PodSpec. Aquí tienes un ejemplo:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

### Escenarios de Uso

#### Aislamiento de Cargas de Trabajo

Imagina un escenario en el que tienes Nodos que deben estar dedicados a cargas de trabajo de producción y no deben ejecutar Pods de desarrollo.

Aplicación de Taint:

```bash
kubectl taint nodes prod-node environment=production:NoSchedule
```

Tolerancia en el Pod de producción:

```yaml
tolerations:
- key: "environment"
  operator: "Equal"
  value: "producción"
  effect: "NoSchedule"
```

#### Nodos Especializados

Si tienes Nodos con GPUs y deseas asegurarte de que solo se programen Pods que necesiten GPUs allí.

Aplicación de Taint:

```bash
kubectl taint nodes gpu-node gpu=true:NoSchedule
```

#### Toleration en un Pod que Requiere GPU:

```yaml
tolerations:
- key: "gpu"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
```

#### Evacuación y Mantenimiento de Nodos

Si necesitas realizar mantenimiento en un Nodo y deseas evitar que se programen nuevos Pods en él.

Aplicar Taint:

```bash
kubectl taint nodes node1 maintenance=true:NoExecute
```

#### Combinando Taints y Tolerations con Reglas de Afinidad

Puedes combinar Taints y Tolerations con reglas de afinidad para un control aún más granular.

### Ejemplos Prácticos

#### Ejemplo 1: Aislamiento de Cargas de Trabajo

Creemos un Nodo con un Taint y tratemos de programar un Pod sin la Toleration correspondiente.

```bash
# Aplicar Taint
kubectl taint nodes dev-node environment=development:NoSchedule

# Intentar programar el Pod
kubectl run nginx --image=nginx
```

Observa que el Pod no se programará hasta que se agregue una Toleration correspondiente.

#### Ejemplo 2: Utilización de Hardware Especializado

Creemos un Nodo con una GPU y apliquemos un Taint correspondiente.

```bash
# Aplicar Taint
kubectl taint nodes gpu-node gpu=true:NoSchedule

# Programar Pod con Toleration
kubectl apply -f gpu-pod.yaml
```

Donde `gpu-pod.yaml` contiene la Toleration correspondiente.

#### Ejemplo 3: Mantenimiento de Nodos

Simulemos un mantenimiento aplicando un Taint a un Nodo y observemos cómo se eliminan los Pods.

```bash
# Aplicar Taint
kubectl taint nodes node1 maintenance=true:NoExecute
```

Estos ejemplos prácticos te ayudarán a comprender mejor cómo funcionan los Taints y Tolerations en situaciones del mundo real.

### Conclusión

Taints y Tolerations son herramientas poderosas para un control refinado de la programación de Pods. Con ellas, puedes aislar workloads, aprovechar hardware especializado e incluso gestionar el mantenimiento de manera más eficaz.

### Tareas del Día

1. Aplica un Taint en uno de tus Nodos y trata de programar un Pod sin la Toleration correspondiente.
2. Elimina el Taint y observa el comportamiento.
3. Agrega una Toleration al Pod y repite el proceso.

## DÍA 12+1: Comprendiendo y Dominando los Selectores

### Introducción 12+1

¡Hola a todos! En el capítulo de hoy, profundizaremos en uno de los recursos más versátiles y fundamentales de Kubernetes: los Selectores. ¿Están listos? ¡Entonces #VAMOS!

### ¿Qué son los Selectors?

Los Selectors son formas de seleccionar recursos, como Pods, en función de sus etiquetas. Son el pegamento que une varios componentes de Kubernetes, como Services y RéplicaSets.

### Tipos de Selectors

#### Equality-based Selectors

Estos son los más simples y utilizan operadores como `=`, `==` y `!=`.

Ejemplo:

```bash
kubectl get pods -l environment=production
```

#### Set-based Selectors

Estos son más complejos y utilizan operadores como `in`, `notin` y `exists`.

Ejemplo:

```bash
kubectl get pods -l 'environment in (production, qa)'
```

### Selectors en acción

#### En Services

Los Services utilizan selectores para dirigir el tráfico hacia Pods específicos.

Ejemplo:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
```

#### En ReplicaSets

Los ReplicaSets utilizan selectores para saber qué Pods gestionar.

Ejemplo:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
spec:
  selector:
    matchLabels:
      app: MyApp
```

#### En Jobs y CronJobs

Los Jobs y CronJobs también pueden utilizar selectores para ejecutar tareas en Pods específicos.

### Selectores y Namespaces

Es crucial entender que los selectores no atraviesan namespaces; son efectivos solo dentro del namespace actual a menos que se especifique de otra manera.

### Escenarios de uso

#### Enrutamiento de tráfico

Utilice Selectors en los Services para dirigir el tráfico hacia versiones específicas de una aplicación.

#### Escalado horizontal

Utilice selectores en Horizontal Pod Autoscalers para escalar solo los Pods que cumplan con criterios específicos.

#### Desastre y recuperación

En casos de conmutación por error, puede utilizar selectores para dirigir el tráfico hacia Pods en un clúster secundario.

### Consejos y trampas

- No cambie las etiquetas de los Pods que son objetivos de Services sin actualizar el selector del Service.
- Utilice selectores de manera consistente para evitar confusiones.

### Ejemplos prácticos

#### Ejemplo 1: Selector en un Service

Vamos a crear un Service que seleccione todos los Pods con la etiqueta `frontend`.

```bash
kubectl apply -f frontend-service.yaml
```

#### Ejemplo 2: Selector en un ReplicaSet

Vamos a crear un ReplicaSet que gestione todos los Pods con la etiqueta `backend`.

```bash
kubectl apply -f backend-replicaset.yaml
```

#### Ejemplo 3: Selectors avanzados

Vamos a realizar una consulta compleja para seleccionar Pods basados en múltiples etiquetas.

```bash
kubectl get pods -l 'release-version in (v1, v2),environment!=debug'
```

### Conclusión 12+1

Los selectores son una herramienta poderosa y flexible en Kubernetes, que permite un control preciso sobre cómo interactúan los recursos. Dominar este concepto es fundamental para cualquiera que trabaje con Kubernetes.
