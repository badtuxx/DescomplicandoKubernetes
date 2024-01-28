# Simplificando Kubernetes

## DÍA 9
&nbsp;

### ¿Qué veremos hoy?

"Si estás aquí, es probable que ya tengas una idea de lo que hace Kubernetes. Pero, ¿cómo exponer tus servicios de manera eficiente y segura al mundo exterior? Aquí es donde entra en juego nuestro protagonista del día: el Ingress. En esta sección, desvelaremos qué es el Ingress, para qué sirve y cómo se diferencia de otras formas de exponer aplicaciones en Kubernetes.

&nbsp;

### Contenido del Día 9

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [DÍA 9](#día-9)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
    - [Contenido del Día 9](#contenido-del-día-9)
- [¿Qué es Ingress?](#qué-es-ingress)
- [Componentes de Ingress](#componentes-de-ingress)
  - [Componentes Clave](#componentes-clave)
    - [Ingress Controller](#ingress-controller)
    - [Ingress Resources](#ingress-resources)
    - [Anotaciones y Personalizaciones](#anotaciones-y-personalizaciones)
    - [Instalación del Nginx Ingress Controller](#instalación-del-nginx-ingress-controller)
      - [Instalación del Ingress Controller Nginx en Kind](#instalación-del-ingress-controller-nginx-en-kind)
        - [Creación del Clúster con Configuraciones Especiales](#creación-del-clúster-con-configuraciones-especiales)
        - [Instalación de un Ingress Controller](#instalación-de-un-ingress-controller)
    - [Instalación de Giropops-Senhas en el Cluster](#instalación-de-giropops-senhas-en-el-cluster)
    - [Creación de un Recurso de Ingress](#creación-de-un-recurso-de-ingress)
- [TBD (Por determinar)](#tbd-por-determinar)

&nbsp;

# ¿Qué es Ingress?

Ingress es un recurso de Kubernetes que gestiona el acceso externo a los servicios dentro de un clúster. Funciona como una capa de enrutamiento HTTP/HTTPS, permitiendo la definición de reglas para dirigir el tráfico externo a diferentes servicios backend. Ingress se implementa a través de un controlador de Ingress, que puede ser alimentado por varias soluciones, como NGINX, Traefik o Istio, por mencionar algunas.

Técnicamente, Ingress actúa como una abstracción de reglas de enrutamiento de alto nivel que son interpretadas y aplicadas por el controlador de Ingress. Permite características avanzadas como el equilibrio de carga, SSL/TLS, redirección, reescritura de URL, entre otras.

Principales Componentes y Funcionalidades:
Controlador de Ingress: Es la implementación real que satisface un recurso Ingress. Puede implementarse mediante varias soluciones de proxy inverso, como NGINX o HAProxy.

**Reglas de Enrutamiento:** Definidas en un objeto YAML, estas reglas determinan cómo deben dirigirse las solicitudes externas a los servicios internos.

**Backend Predeterminado:** Un servicio de respaldo al que se dirigen las solicitudes si no se cumple ninguna regla de enrutamiento.

**Balanceo de Carga:** Distribución automática del tráfico entre múltiples pods de un servicio.

**Terminación SSL/TLS:** Ingress permite la configuración de certificados SSL/TLS para la terminación de la encriptación en el punto de entrada del clúster.

**Adjuntos de Recursos:** Posibilidad de adjuntar recursos adicionales como ConfigMaps o Secrets, que pueden utilizarse para configurar comportamientos adicionales como la autenticación básica, listas de control de acceso, etc."

# Componentes de Ingress

Ahora que ya sabemos qué es Ingress y por qué utilizarlo, es hora de sumergirnos en los componentes que lo componen. Como buen "portero" de nuestro clúster Kubernetes, Ingress no trabaja solo; está compuesto por varias "piezas" que orquestan el tráfico. ¡Vamos a explorarlas!

## Componentes Clave

### Ingress Controller

El Ingress Controller es el motor detrás del objeto Ingress. Es responsable de aplicar las reglas de enrutamiento definidas en el recurso Ingress. Ejemplos populares incluyen el Ingress Controller de Nginx, Traefik y HAProxy Ingress.

### Ingress Resources

Los Ingress Resources son las configuraciones que defines para indicar al Ingress Controller cómo debe ser enrutado el tráfico. Estas se definen en archivos YAML y se aplican en el clúster.

### Anotaciones y Personalizaciones

Las anotaciones permiten personalizar el comportamiento predeterminado de tu Ingress. Por ejemplo, puedes forzar la redirección de HTTP a HTTPS o agregar políticas de seguridad, como protección contra ataques DDoS.

### Instalación del Nginx Ingress Controller

Vamos a instalar el Nginx Ingress Controller. Es importante tener en cuenta la versión del Ingress Controller que estás instalando, ya que las versiones más recientes o más antiguas pueden no ser compatibles con la versión de Kubernetes que estás utilizando. Para este tutorial, utilizaremos la versión 1.8.2.
En tu terminal, ejecuta los siguientes comandos:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

Verifica si el Ingress Controller se ha instalado correctamente:

```bash
kubectl get pods -n ingress-nginx
```

Puedes utilizar la opción `wait` de `kubectl`, de esta manera, cuando los pods estén listos, liberará la terminal, así:

```bash
kubectl get pods -n ingress-nginx --wait
```

```markdown
```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

En el comando anterior, estamos esperando que los pods del Ingress Controller estén listos, con la etiqueta `app.kubernetes.io/component=controller`, en el namespace `ingress-nginx`, y en caso de que no estén listos en 90 segundos, el comando fallará.

#### Instalación del Ingress Controller Nginx en Kind

Kind es una herramienta muy útil para realizar pruebas y desarrollo con Kubernetes. En esta sección actualizada, proporcionamos detalles específicos para asegurarnos de que Ingress funcione como se espera en un clúster Kind.

##### Creación del Clúster con Configuraciones Especiales

Al crear un clúster KinD, podemos especificar varias configuraciones que incluyen asignaciones de puertos y etiquetas para los nodos.

1. Cree un archivo llamado `kind-config.yaml` con el siguiente contenido:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
```

2. Luego, cree el clúster utilizando este archivo de configuración:

```bash
kind create cluster --config kind-config.yaml
```

##### Instalación de un Ingress Controller

Continuaremos utilizando el Ingress Controller de Nginx como ejemplo, ya que es ampliamente adoptado y bien documentado.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

Puede utilizar la opción `wait` de `kubectl`, de modo que cuando los pods estén listos, liberará la terminal, como se muestra a continuación:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

En el comando anterior, estamos esperando que los pods del Ingress Controller estén listos, con la etiqueta `app.kubernetes.io/component=controller`, en el espacio de nombres `ingress-nginx`, y si no están listos en 90 segundos, el comando fallará.

### Instalación de Giropops-Senhas en el Cluster

Para la instalación de Giropops-Senhas, utilizaremos los siguientes archivos:

Archivo: app-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: giropops-senhas # No se traduce giropops-senhas
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
        env:
        - name: REDIS_HOST
          value: redis-service
        ports:
        - containerPort: 5000
        imagePullPolicy: Always
```

Archivo: app-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: giropops-senhas
  labels:
    app: giropops-senhas
spec:
  selector:
    app: giropops-senhas
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
      name: tcp-app
  type: ClusterIP
```

Archivo: redis-deployment.yaml

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

Archivo: redis-service.yaml

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

Con los archivos mencionados anteriormente, estamos creando un Deployment y un Service para `Giropops-Senhas`, y un Deployment y un Service para Redis.

Para aplicarlos, simplemente ejecute los siguientes comandos:

```bash
kubectl apply -f app-deployment.yaml
kubectl apply -f app-service.yaml
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml
```

Para verificar si los pods están en funcionamiento, ejecute el siguiente comando:

```bash
kubectl get pods
```

Para asegurarse de que los servicios estén en funcionamiento, ejecute el siguiente comando:

```bash
kubectl get services
```

Si está utilizando Kind, puede acceder a la aplicación Giropops-Senhas localmente mediante el siguiente comando:

```bash
kubectl port-forward service/giropops-senhas 5000:5000
```

Esto es válido si está utilizando Kind. Si no lo está haciendo, necesitará obtener la dirección IP de su Ingress, lo que se explicará más adelante.

Para probar la aplicación, simplemente abra su navegador web y acceda a la siguiente dirección: http://localhost:5000

### Creación de un Recurso de Ingress

Ahora, vamos a crear un recurso de Ingress para nuestro servicio `giropops-senhas`, que fue creado anteriormente. Cree un archivo llamado `ingress-1.yaml` con el siguiente contenido:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /giropops-senhas
        pathType: Prefix
        backend:
          service: 
            name: giropops-senhas
            port:
              number: 5000
```

Después de crear el archivo, aplíquelo con el siguiente comando:

```bash
kubectl apply -f ingress-1.yaml
```

Ahora vamos verificar si nuestro Ingress se ha creado correctamente:

```bash
kubectl get ingress
```

Para obtener más detalles, puede utilizar el comando `describe`:

```bash
kubectl describe ingress giropops-senhas
```

Tanto en la salida del comando `get` como en la salida del comando `describe`, debería ver la dirección IP de su Ingress en el campo `Address`.

Puede obtener esta dirección IP con el siguiente comando:

```bash
kubectl get ingress giropops-senhas -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Si está utilizando un clúster gestionado por un proveedor de servicios en la nube, como GKE, puede utilizar el siguiente comando:

```bash
kubectl get ingress giropops-senhas -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Esto se debe a que cuando tienes un clúster EKS, AKS, GCP, etc., el Ingress Controller creará un equilibrador de carga para ti, y la dirección IP del equilibrador de carga será la dirección IP de tu Ingress, así de simple.

Para probarlo, puedes usar el comando curl con la dirección IP, el nombre de host o el equilibrador de carga de tu Ingress:

```bash
curl DIRECCIÓN_DEL_INGRESS/giropops-senhas
```

# TBD (Por determinar)