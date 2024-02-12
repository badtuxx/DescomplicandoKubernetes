# Simplificando Kubernetes

## Día 13: Simplificando Kyverno y las Policies en Kubernetes

## Contenido del Día 13

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 13: Simplificando Kyverno y las Policies en Kubernetes](#día-13-simplificando-kyverno-y-las-policies-en-kubernetes)
  - [Contenido del Día 13](#contenido-del-día-13)
  - [¿Qué veremos hoy?](#qué-veremos-hoy)
  - [Comienzo del Día 13](#comienzo-del-día-13)
    - [Introducción a Kyverno](#introducción-a-kyverno)
    - [Instalación de Kyverno](#instalación-de-kyverno)
      - [Usando Helm](#usando-helm)
    - [Verificación de la Instalación](#verificación-de-la-instalación)
    - [Creación de nuestra primera política](#creación-de-nuestra-primera-política)
      - [Ejemplo de Política: Agregar Etiqueta al Namespace](#ejemplo-de-política-agregar-etiqueta-al-namespace)
        - [Detalles de la Política: Agregar Etiqueta al Namespace](#detalles-de-la-política-agregar-etiqueta-al-namespace)
        - [Archivo de Política: `add-label-namespace.yaml`](#archivo-de-política-add-label-namespaceyaml)
        - [Uso de la Política: Agregar Etiqueta al Namespace](#uso-de-la-política-agregar-etiqueta-al-namespace)
      - [Ejemplo de Política: Prohibir Usuario Root](#ejemplo-de-política-prohibir-usuario-root)
        - [Detalles de la Política: Prohibir Usuario Root](#detalles-de-la-política-prohibir-usuario-root)
        - [Archivo de la Política: `disallow-root-user.yaml`](#archivo-de-la-política-disallow-root-useryaml)
        - [Implementación y Efecto](#implementación-y-efecto)
      - [Ejemplo de Política: Generar ConfigMap para Namespace](#ejemplo-de-política-generar-configmap-para-namespace)
        - [Detalles de la Política: Generar ConfigMap para Namespace](#detalles-de-la-política-generar-configmap-para-namespace)
        - [Archivo de Política: `generar-configmap-para-namespace.yaml`](#archivo-de-política-generar-configmap-para-namespaceyaml)
        - [Implementación y Utilidad](#implementación-y-utilidad)
      - [Ejemplo de Política: Permitir Solo Repositorios de Confianza](#ejemplo-de-política-permitir-solo-repositorios-de-confianza)
        - [Detalles de la Política: Permitir Solo Repositorios de Confianza](#detalles-de-la-política-permitir-solo-repositorios-de-confianza)
        - [Archivo de Política: `repositorio-permitido.yaml`](#archivo-de-política-repositorio-permitidoyaml)
        - [Implementación e Impacto](#implementación-e-impacto)
        - [Ejemplo de Política: Require Probes](#ejemplo-de-política-require-probes)
        - [Detalles de la Política: Require Probes](#detalles-de-la-política-require-probes)
        - [Archivo de Política: `require-probes.yaml`](#archivo-de-política-require-probesyaml)
        - [Implementación e Impacto: Require Probes](#implementación-e-impacto-require-probes)
      - [Ejemplo de Política: Uso del Exclude](#ejemplo-de-política-uso-del-exclude)
        - [Detalles de la Política: Uso del Exclude](#detalles-de-la-política-uso-del-exclude)
        - [Archivo de Política](#archivo-de-política)
        - [Implementación y Efectos: Uso del Exclude](#implementación-y-efectos-uso-del-exclude)
    - [Conclusión](#conclusión)
      - [Puntos Clave Aprendidos](#puntos-clave-aprendidos)

## ¿Qué veremos hoy?

Hoy, exploraremos las funcionalidades y aplicaciones de Kyverno, una herramienta de gestión de políticas esencial para la seguridad y eficiencia de los clústeres Kubernetes. Con un enfoque detallado y práctico, aprenderás a utilizar Kyverno para automatizar tareas críticas, garantizar el cumplimiento de normativas y reglas establecidas, y mejorar la administración general de tus entornos Kubernetes.

**Principales temas tratados:**

1. **Introducción a Kyverno:** Una visión general de Kyverno, destacando su importancia y las principales funciones de validación, mutación y generación de recursos.

2. **Instalación y configuración:** Un paso a paso para la instalación de Kyverno, incluyendo métodos que utilizan Helm y archivos YAML, y cómo verificar si la instalación se realizó con éxito.

3. **Desarrollo de políticas eficientes:** Aprenderás a crear políticas para diferentes escenarios, desde la garantía de límites de CPU y memoria en los Pods hasta la aplicación automática de etiquetas en espacios de nombres y la restricción de la ejecución de contenedores como root.

4. **Ejemplos prácticos:** Varios ejemplos de políticas que ilustran cómo Kyverno se puede aplicar para resolver problemas reales y mejorar la seguridad y el cumplimiento en los clústeres Kubernetes.

5. **Consejos de uso y mejores prácticas:** Orientaciones sobre cómo aprovechar al máximo Kyverno, incluyendo consejos de seguridad, eficiencia y automatización de procesos.

Al final de este libro electrónico, tendrás una comprensión completa de Kyverno y estarás preparado con el conocimiento y las habilidades necesarias para implementarlo de manera efectiva en tus propios clústeres Kubernetes. Este libro electrónico está diseñado tanto para principiantes como para profesionales experimentados, proporcionando información valiosa y práctica para todos los niveles de experiencia.

---

## Comienzo del Día 13

### Introducción a Kyverno

Kyverno es una herramienta de gestión de políticas para Kubernetes que se enfoca en la automatización de diversas tareas relacionadas con la seguridad y configuración de los clústeres de Kubernetes. Permite definir, administrar y aplicar políticas de manera declarativa para garantizar que los clústeres y sus cargas de trabajo cumplan con las reglas y normativas establecidas.

**Principales funciones de Kyverno:**

1. **Validación de recursos:** Verifica si los recursos de Kubernetes cumplen con las políticas definidas. Por ejemplo, puede asegurarse de que todos los Pods tengan límites de CPU y memoria definidos.

2. **Mutación de recursos:** Modifica automáticamente los recursos de Kubernetes para cumplir con las políticas definidas. Por ejemplo, puede agregar automáticamente etiquetas específicas a todos los nuevos Pods.

3. **Generación de recursos:** Crea recursos adicionales de Kubernetes en función de las políticas definidas. Por ejemplo, puede generar NetworkPolicies para cada nuevo espacio de nombres creado.

---

### Instalación de Kyverno

La instalación de Kyverno en un clúster Kubernetes se puede realizar de varias maneras, incluyendo el uso de un gestor de paquetes como Helm o directamente a través de archivos YAML. Aquí están los pasos básicos para instalar Kyverno:

#### Usando Helm

Helm es un gestor de paquetes para Kubernetes que facilita la instalación y gestión de aplicaciones. Para instalar Kyverno con Helm, siga estos pasos:

1. **Agregar el Repositorio de Kyverno:**

   ```shell
   helm repo add kyverno https://kyverno.github.io/kyverno/
   helm repo update
   ```

2. **Instalar Kyverno:**

   Puede instalar Kyverno en el espacio de nombres `kyverno` utilizando el siguiente comando:

   ```shell
   helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
   ```

### Verificación de la Instalación

Después de la instalación, es importante verificar si Kyverno se ha instalado correctamente y está funcionando según lo esperado.

- **Verificar los Pods:**

  ```shell
  kubectl get pods -n kyverno
  ```

  Este comando debería mostrar los Pods de Kyverno en ejecución en el espacio de nombres especificado.

- **Verificar los CRDs:**

  ```shell
  kubectl get crd | grep kyverno
  ```

  Este comando debería listar los CRDs relacionados con Kyverno, indicando que se han creado correctamente.

Recuerde que siempre es importante consultar la documentación oficial para obtener las instrucciones más actualizadas y detalladas, especialmente si está trabajando con una configuración específica o una versión más reciente de Kyverno o Kubernetes.

---

### Creación de nuestra primera política

Kyverno permite definir, administrar y aplicar políticas de manera declarativa para garantizar que los clústeres y sus cargas de trabajo cumplan con las reglas y normas establecidas.

Las políticas, o "policies" en inglés, de Kyverno se pueden aplicar de dos formas principales: a nivel de clúster (`ClusterPolicy`) o a nivel de un namespace específico (`Policy`).

1. **ClusterPolicy**: Cuando se define una política como `ClusterPolicy`, se aplica a todos los namespaces en el clúster. Esto significa que las reglas definidas en una `ClusterPolicy` se aplican automáticamente a todos los recursos correspondientes en todos los namespaces, a menos que se excluyan específicamente.

2. **Policy**: Si desea aplicar políticas a un namespace específico, debe utilizar el tipo `Policy`. Las políticas definidas como `Policy` se aplican solo dentro del namespace en el que se crean.

Si no especifica ningún namespace en la política o utiliza `ClusterPolicy`, Kyverno asumirá que la política debe aplicarse de forma global, es decir, en todos los namespaces.

---

**Ejemplo de Política de Kyverno:**

1. **Política de Límites de Recursos:** Asegurar que todos los contenedores en un Pod tengan límites de CPU y memoria definidos. Esto puede ser importante para evitar el uso excesivo de recursos en un clúster compartido.

**Archivo `require-resources-limits.yaml`:**

   ```yaml
   apiVersion: kyverno.io/v1
   kind: ClusterPolicy
   metadata:
     name: require-cpu-memory-limits
   spec:
     validationFailureAction: enforce
     rules:
     - name: validate-limits
       match:
         resources:
           kinds:
           - Pod
       validate:
         message: "CPU and memory limits are required"
         pattern:
           spec:
             containers:
             - name: "*"
               resources:
                 limits:
                   memory: "?*"
                   cpu: "?*"
   ```

Después de crear el archivo, ahora solo tienes que implementarlo en tu clúster de Kubernetes.

```bash
kubectl apply -f require-resources-limits.yaml
```

Ahora, intenta implementar un simple Nginx sin definir límites para los recursos.

**Archivo `pod.yaml`:**

```bash
apiVersion: v1
kind: Pod
metadata:
  name: ejemplo-pod
spec:
  containers:
  - name: ejemplo-container
    image: nginx
```

```bash
kubectl apply -f pod.yaml
```

---

**Más ejemplos de políticas**

Continuando con la explicación y ejemplos de políticas de Kyverno para la gestión de clústeres de Kubernetes:

Entiendo, voy a formatear el texto para que esté listo para copiar en Google Docs:

---

#### Ejemplo de Política: Agregar Etiqueta al Namespace

La política `add-label-namespace` está diseñada para automatizar la adición de una etiqueta específica a todos los Namespaces en un clúster de Kubernetes. Este enfoque es fundamental para la organización, monitorización y control de acceso en entornos complejos.

##### Detalles de la Política: Agregar Etiqueta al Namespace

La etiqueta agregada por esta política es `Jeferson: "Lindo_Demais"`. La aplicación de esta etiqueta a todos los Namespaces facilita la identificación y categorización de los mismos, permitiendo una gestión más eficiente y una estandarización en el uso de etiquetas.

##### Archivo de Política: `add-label-namespace.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-label-namespace
spec:
  rules:
  - name: add-label-ns
    match:
      resources:
        kinds:
        - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            Jeferson: "Lindo_Demais"
```

##### Uso de la Política: Agregar Etiqueta al Namespace

Esta política garantiza que cada Namespace en el clúster sea etiquetado automáticamente con `Jeferson: "Lindo_Demais"`. Esto es especialmente útil para garantizar la conformidad y uniformidad en la asignación de etiquetas, facilitando operaciones como la filtración y búsqueda de Namespaces basados en criterios específicos.

---

#### Ejemplo de Política: Prohibir Usuario Root

La política `disallow-root-user` es una regla de seguridad crítica en la gestión de clústeres de Kubernetes. Prohíbe la ejecución de contenedores como usuario root dentro de Pods. Este control ayuda a prevenir posibles vulnerabilidades de seguridad y refuerza las mejores prácticas en el entorno de contenedores.

##### Detalles de la Política: Prohibir Usuario Root

El principal objetivo de esta política es garantizar que ningún Pod en el clúster ejecute contenedores como usuario root. La ejecución de contenedores como root puede exponer el sistema a riesgos de seguridad, incluyendo accesos no autorizados y posibles daños al sistema host.

##### Archivo de la Política: `disallow-root-user.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-root-user
spec:
  validationFailureAction: enforce
  rules:
  - name: check-runAsNonRoot
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Running as root is not allowed. Set runAsNonRoot to true."
      pattern:
        spec:
          containers:
          - securityContext:
              runAsNonRoot: true
```

##### Implementación y Efecto

Al aplicar esta política, se bloqueará la ejecución de todos los Pods que intenten ejecutar contenedores como usuario root. Se mostrará un mensaje de error que indica que no se permite la ejecución como root. Esto asegura una capa adicional de seguridad en el entorno de Kubernetes, evitando prácticas que puedan comprometer la integridad y la seguridad del clúster.

---

#### Ejemplo de Política: Generar ConfigMap para Namespace

La política `generar-configmap-para-namespace` es una estrategia práctica en la gestión de Kubernetes para automatizar la creación de ConfigMaps en Namespaces. Esta política simplifica la configuración y administración de múltiples entornos dentro de un clúster.

##### Detalles de la Política: Generar ConfigMap para Namespace

Esta política está diseñada para crear automáticamente un ConfigMap en cada Namespace recién creado. El ConfigMap generado, denominado `configmap-por-defecto`, incluye un conjunto estándar de claves y valores, lo que facilita la configuración inicial y la estandarización de los Namespaces.

##### Archivo de Política: `generar-configmap-para-namespace.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generar-configmap-para-namespace
spec:
  rules:
    - name: generar-configmap-namespace
      match:
        resources:
          kinds:
            - Namespace
      generate:
        kind: ConfigMap
        name: configmap-por-defecto
        namespace: "{{request.object.metadata.name}}"
        data:
          datos:
            clave1: "valor1"
            clave2: "valor2"
```

##### Implementación y Utilidad

La aplicación de esta política resulta en la creación automática de un ConfigMap por defecto en cada Namespace nuevo, lo que proporciona una forma rápida y eficiente de distribuir configuraciones comunes e información esencial. Esto es particularmente útil en escenarios donde la consistencia y la automatización de las configuraciones son cruciales.

---

#### Ejemplo de Política: Permitir Solo Repositorios de Confianza

La política `asegurar-imagenes-de-repositorio-confiable` es esencial para la seguridad de los clústeres de Kubernetes, garantizando que todos los Pods utilicen imágenes solo de repositorios de confianza. Esta política ayuda a prevenir la ejecución de imágenes no verificadas o potencialmente maliciosas.

##### Detalles de la Política: Permitir Solo Repositorios de Confianza

Esta política impone que todas las imágenes de contenedores utilizadas en los Pods deben provenir de repositorios especificados y de confianza. Esta estrategia es crucial para mantener la integridad y la seguridad del entorno de contenedores, evitando riesgos asociados con imágenes desconocidas o no autorizadas.

##### Archivo de Política: `repositorio-permitido.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: ensure-images-from-trusted-repo
spec:
  validationFailureAction: enforce
  rules:
  - name: trusted-repo-check
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Only images from trusted repositories are allowed"
      pattern:
        spec:
          containers:
          - name: "*"
            image: "trustedrepo.com/*"
```

##### Implementación e Impacto

Con la implementación de esta política, cualquier intento de implementar un Pod con una imagen de un repositorio no confiable será bloqueado. La política garantiza que solo se utilicen imágenes de fuentes aprobadas, fortaleciendo la seguridad del clúster contra vulnerabilidades y ataques externos.

---

##### Ejemplo de Política: Require Probes

La política `require-readinessprobe` desempeña un papel crucial en la gestión del tráfico y garantiza la disponibilidad de los servicios en un clúster de Kubernetes. Exige que todos los Pods tengan una sonda de preparación (readiness probe) configurada, asegurando que el tráfico se dirija a los Pods solo cuando estén listos para procesar solicitudes.

##### Detalles de la Política: Require Probes

Esta política tiene como objetivo mejorar la confiabilidad y eficiencia de los servicios que se ejecutan en el clúster, garantizando que los Pods estén listos para recibir tráfico antes de exponerse a solicitudes externas. La sonda de preparación verifica si el Pod está listo para atender las solicitudes, lo que ayuda a evitar interrupciones y problemas de rendimiento.

##### Archivo de Política: `require-probes.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-readinessprobe
spec:
  validationFailureAction: Enforce
  rules:
    - name: require-readinessProbe
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Readiness probe is required."
        pattern:
          spec:
            containers:
              - readinessProbe:
                  httpGet:
                    path: "/"
                    port: 8080
```

##### Implementación e Impacto: Require Probes

Con la aplicación de esta política, todos los nuevos Pods o Pods actualizados deben incluir una configuración de sonda de preparación, que normalmente implica especificar una ruta y un puerto para la verificación HTTP. Esto asegura que el servicio solo reciba tráfico cuando esté completamente operativo, mejorando la confiabilidad y la experiencia del usuario.

---

#### Ejemplo de Política: Uso del Exclude

La política `require-resources-limits` es un enfoque proactivo para administrar el uso de recursos en un clúster de Kubernetes. Asegura que todos los Pods tengan límites de recursos definidos, como CPU y memoria, pero con una excepción específica para un namespace.

##### Detalles de la Política: Uso del Exclude

Esta política impone que cada Pod en el clúster tenga límites explícitos de CPU y memoria configurados. Esto es fundamental para evitar el uso excesivo de recursos, que puede afectar a otros Pods y la estabilidad general del clúster. Sin embargo, esta política excluye específicamente el namespace `giropops` de esta regla.

##### Archivo de Política

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: requerir-recursos-limites
spec:
  validationFailureAction: Enforce
  rules:
  - name: validar-limites
    match:
      resources:
        kinds:
        - Pod
    exclude:
      resources:
        namespaces:
        - giropops
    validate:
      message: "Debe definir límites de recursos"
      pattern:
        spec:
          containers:
          - name: "*"
            resources:
              limits:
                cpu: "?*"
                memory: "?*"
```

##### Implementación y Efectos: Uso del Exclude

Al aplicar esta política, todos los Pods nuevos o actualizados deben tener límites de recursos claramente definidos, excepto aquellos en el namespace `giropops`. Esto asegura una mejor gestión de recursos y evita situaciones en las que algunos Pods puedan monopolizar recursos en detrimento de otros.

---

### Conclusión

A lo largo de este artículo, hemos explorado las capacidades y funcionalidades de Kyverno, una herramienta innovadora e imprescindible para la gestión de políticas en clústeres de Kubernetes. Hemos comprendido cómo Kyverno simplifica y automatiza tareas críticas relacionadas con la seguridad, el cumplimiento y la configuración, convirtiéndose en un componente indispensable en la administración de entornos Kubernetes.

#### Puntos Clave Aprendidos

1. **Automatización y Cumplimiento:** Hemos visto cómo Kyverno permite definir, gestionar y aplicar políticas de manera declarativa, garantizando que los recursos de Kubernetes estén siempre en cumplimiento con las reglas y normativas establecidas. Este enfoque reduce significativamente el esfuerzo manual, minimiza los errores y asegura una mayor consistencia en todo el entorno.

2. **Validación, Mutación y Generación de Recursos:** Aprendimos sobre las tres funciones principales de Kyverno: validación, mutación y generación de recursos, y cómo cada una de ellas desempeña un papel vital en la gestión efectiva del clúster. Estas funciones proporcionan un control detallado sobre los recursos, desde garantizar límites de CPU y memoria hasta la aplicación automática de etiquetas y la creación dinámica de ConfigMaps.

3. **Flexibilidad de Políticas:** Discutimos la diferencia entre `ClusterPolicy` y `Policy`, destacando cómo Kyverno ofrece flexibilidad para aplicar políticas en todo el clúster o en espacios de nombres específicos. Esto permite una gestión personalizada y adaptada a las necesidades de diferentes partes del clúster.

4. **Instalación y Verificación:** Abordamos las diversas formas de instalar Kyverno, con un enfoque especial en el uso de Helm, un popular gestor de paquetes para Kubernetes. También exploramos cómo verificar la instalación correcta de Kyverno, asegurando que todo funcione según lo esperado.

5. **Prácticas de Seguridad:** El artículo enfatizó la importancia de la seguridad en Kubernetes, demostrada a través de políticas como la prohibición de ejecutar contenedores como usuario root y la exigencia de imágenes provenientes de repositorios de confianza. Estas políticas ayudan a prevenir vulnerabilidades y garantizar la integridad del clúster.

6. **Automatización y Eficiencia:** Por último, aprendimos cómo Kyverno facilita la automatización y la eficiencia operativa. Las políticas de Kyverno reducen la necesidad de intervención manual, aumentan la seguridad y ayudan en el cumplimiento normativo, haciendo que la administración de Kubernetes sea más sencilla y confiable.

En resumen, Kyverno es una herramienta poderosa que transforma la forma en que se gestionan las políticas en Kubernetes. Su enfoque en la automatización, la flexibilidad y la seguridad lo convierte en un componente esencial para cualquier administrador de Kubernetes que desee optimizar la gestión de clústeres, garantizar el cumplimiento y fortalecer la seguridad. Con Kyverno, podemos alcanzar un nivel más alto de eficiencia y confiabilidad en nuestros entornos Kubernetes, preparándonos para enfrentar los desafíos de un ecosistema en constante evolución.
