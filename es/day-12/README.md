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
