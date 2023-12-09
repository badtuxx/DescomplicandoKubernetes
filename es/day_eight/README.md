# Simplificando Kubernetes

## Día 8
&nbsp;

### Contenido del Día 8

- [Simplificando Kubernetes](#simplificando-kubernetes)
  - [Día 8](#día-8)
    - [Contenido del Día 8](#contenido-del-día-8)
    - [¿Qué veremos hoy?](#qué-veremos-hoy)
      - [¿Qué son los Secrets?](#qué-son-los-secrets)
        - [¿Cómo funcionan los Secrets?](#cómo-funcionan-los-secrets)
        - [Tipos de Secrets](#tipos-de-secrets)
        - [Antes de crear un Secret, el Base64](#antes-de-crear-un-secret-el-base64)
        - [Creando nuestro primer Secret](#creando-nuestro-primer-secret)
        - [Usando nuestro primer Secret](#usando-nuestro-primer-secret)
        - [Creando un Secreto para almacenar credenciales de Docker](#creando-un-secreto-para-almacenar-credenciales-de-docker)
        - [Criando um Secret TLS](#criando-um-secret-tls)
      - [ConfigMaps](#configmaps)
      - [Operador de Secretos Externos](#operador-de-secretos-externos)
        - [El Rol Destacado del ESO](#el-rol-destacado-del-eso)
        - [Conceptos Clave del Operador de Secretos Externos](#conceptos-clave-del-operador-de-secretos-externos)
        - [SecretStore](#secretstore)
        - [ExternalSecret](#externalsecret)
        - [ClusterSecretStore](#clustersecretstore)
        - [Control de Acceso y Seguridad](#control-de-acceso-y-seguridad)
      - [Configurando el External Secrets Operator](#configurando-el-external-secrets-operator)
        - [¿Qué es Vault?](#qué-es-vault)
        - [¿Por qué usar Vault?](#por-qué-usar-vault)
        - [Comandos Básicos de Vault](#comandos-básicos-de-vault)
        - [El Vault en el contexto de Kubernetes](#el-vault-en-el-contexto-de-kubernetes)
        - [Instalación y configuración de Vault en Kubernetes](#instalación-y-configuración-de-vault-en-kubernetes)
        - [Requisitos previos](#requisitos-previos)
        - [Instalación y configuración de Vault con Helm](#instalación-y-configuración-de-vault-con-helm)
        - [Adicionando o Repositório do External Secrets Operator ao Helm](#adicionando-o-repositório-do-external-secrets-operator-ao-helm)
        - [Instalando o External Secrets Operator](#instalando-o-external-secrets-operator)
        - [Verificando a Instalação do ESO](#verificando-a-instalação-do-eso)
        - [Criando um Segredo no Kubernetes](#criando-um-segredo-no-kubernetes)
        - [Configurando o ClusterSecretStore](#configurando-o-clustersecretstore)
        - [Criando um ExternalSecret](#criando-um-externalsecret)
  - [Final do Day-8](#final-do-day-8)

&nbsp;

### ¿Qué veremos hoy?

Hoy es el día de hablar sobre dos cosas muy importantes en el mundo de Kubernetes, hoy vamos a hablar sobre `Secrets` y `ConfigMaps`.

Sí, estas dos piezas fundamentales te permitirán ejecutar tu aplicación en Kubernetes de la mejor manera posible, ya que son responsables de almacenar información sensible de tu aplicación, como contraseñas, tokens, claves de acceso, configuraciones, etc.

Después de hoy, comprenderás cómo funciona el almacenamiento de información sensible en Kubernetes y cómo puedes hacer que tu aplicación consuma esta información de la mejor manera posible.

¡Vamos allá!

&nbsp;

#### ¿Qué son los Secrets?

Los Secrets proporcionan una forma segura y flexible de gestionar información sensible, como contraseñas, tokens OAuth, claves SSH y otros datos que no deseas exponer en las configuraciones de tus aplicaciones.

Un Secret es un objeto que contiene un pequeño volumen de información sensible, como una contraseña, un token o una clave. Esta información puede ser consumida por Pods o utilizada por el sistema para realizar acciones en nombre de un Pod.

&nbsp;

##### ¿Cómo funcionan los Secrets?

Los Secrets se almacenan en `Etcd`, el almacén de datos distribuido de Kubernetes. Por defecto, se almacenan sin cifrar, aunque Etcd admite cifrado para proteger los datos almacenados en él. Además, el acceso a los Secrets está restringido a través del Control de Acceso Basado en Roles (`RBAC`), lo que permite controlar qué usuarios y Pods pueden acceder a qué Secrets.

Los Secrets pueden montarse en Pods como archivos en volúmenes o pueden utilizarse para completar variables de entorno para un contenedor dentro de un Pod. Cuando se actualiza un Secret, Kubernetes no actualiza automáticamente los volúmenes montados ni las variables de entorno que se refieren a él.

&nbsp;

##### Tipos de Secrets

Existen varios tipos de Secrets que puedes utilizar, dependiendo de tus necesidades específicas. A continuación, se muestran algunos de los tipos más comunes de Secrets:

- **Opaque Secrets** - son los Secrets más simples y comunes. Almacenan datos arbitrarios, como claves de API, contraseñas y tokens. Los `Opaque Secrets` se codifican en base64 cuando se almacenan en Kubernetes, pero no se cifran. Pueden utilizarse para almacenar datos confidenciales, pero no son lo suficientemente seguros para almacenar información altamente sensible, como contraseñas de bases de datos.

- **kubernetes.io/service-account-token** - se utilizan para almacenar tokens de acceso a cuentas de servicio. Estos tokens se utilizan para autenticar `Pods` con la API de Kubernetes. Se montan automáticamente en `Pods` que utilizan cuentas de servicio.

- **kubernetes.io/dockercfg** y **kubernetes.io/dockerconfigjson** - se utilizan para almacenar credenciales de registro de Docker. Se utilizan para autenticar `Pods` con un registro de Docker. Se montan en `Pods` que utilizan imágenes de contenedor privadas.

- **kubernetes.io/tls**, **kubernetes.io/ssh-auth** y **kubernetes.io/basic-auth** - se utilizan para almacenar certificados TLS, claves SSH y credenciales de autenticación básica, respectivamente. Se utilizan para autenticar `Pods` con otros servicios.

- **bootstrap.kubernetes.io/token** - se utilizan para almacenar tokens de inicio de clúster. Se utilizan para autenticar nodos con el plano de control de Kubernetes.

Hay algunos tipos más de Secrets, pero estos son los más comunes. Puedes encontrar una lista completa de tipos de Secrets en la documentación de Kubernetes.

Cada tipo de Secret tiene un formato diferente. Por ejemplo, los `Opaque Secrets` se almacenan como un mapa de cadenas, mientras que los `Secrets TLS` se almacenan como un mapa de cadenas con claves adicionales para almacenar certificados y claves, por lo que es importante saber qué tipo de Secret estás utilizando para almacenar los datos correctamente.

##### Antes de crear un Secret, el Base64

Antes de empezar a crear nuestros Secrets, necesitamos entender qué es `Base64`, ya que es un tema que a menudo genera muchas preguntas y que siempre está presente cuando hablamos de Secrets.

Primero, ¿es Base64 cifrado? No, Base64 no es cifrado, es un esquema de codificación binaria para texto que tiene como objetivo garantizar que los datos binarios puedan ser enviados por canales diseñados para tratar solo con texto. Esta codificación ayuda a asegurar que los datos permanezcan intactos sin modificación durante el transporte.

`Base64` se utiliza comúnmente en varias aplicaciones, incluido el correo electrónico a través de MIME, el almacenamiento de contraseñas complejas y mucho más.

La codificación `Base64` convierte los datos binarios en una cadena de texto ASCII. Esta cadena contiene solo caracteres que se consideran seguros para su uso en URL, lo que hace que la codificación Base64 sea útil para codificar datos que se envían a través de Internet.

Sin embargo, la codificación Base64 no es una forma de cifrado y no debe usarse como tal. En particular, no proporciona confidencialidad. Cualquier persona que tenga acceso a la cadena codificada puede decodificarla fácilmente y recuperar los datos originales. Es importante entender esto para no almacenar información sensible en un formato codificado en Base64, ya que no es seguro.

Ahora que ya sabes qué es `Base64`, veamos cómo podemos codificar y decodificar una cadena utilizando `Base64`.

Para codificar una cadena en `Base64`, puedes usar el comando `base64` en Linux. Por ejemplo, para codificar la cadena `giropops` en `Base64`, puedes ejecutar el siguiente comando:

```bash
echo -n 'giropops' | base64
```

El comando anterior devolverá la cadena `Z2lyb3BvcHM=`.

Para decodificar una cadena en Base64, puedes usar el comando `base64` nuevamente, pero esta vez con la opción `-d`. Por ejemplo, para decodificar la cadena `Z2lyb3BvcHM=` en Base64, puedes ejecutar el siguiente comando:

```bash
echo -n 'Z2lyb3BvcHM=' | base64 -d
```

El comando anterior devolverá la cadena `giropops`, ¡tan simple como volar!

Estoy utilizando el parámetro `-n` en el comando `echo` para que no agregue una nueva línea al final de la cadena, ya que esto podría causar problemas al codificar y decodificar la cadena.

Ahora que ya estás listo para crear tus Secrets, ¡es hora de empezar a jugar!

##### Creando nuestro primer Secret

Ahora que ya sabes qué son los Secrets, que el `Base64` no es encriptación y cómo codificar y decodificar una cadena usando `Base64`, vamos a crear nuestro primer Secret.

Primero, crearemos un Secret del tipo `Opaque`. Este es el tipo de Secret más común y se usa para almacenar información arbitraria.

Para crear un Secret del tipo `Opaque`, necesitas crear un archivo YAML que defina el Secret. Por ejemplo, puedes crear un archivo llamado `giropops-secret.yaml` con el siguiente contenido:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: giropops-secret
type: Opaque
data: # Inicio de los datos
    username: SmVmZXJzb25fbGluZG8=
    password: Z2lyb3BvcHM=
```

&nbsp;

El archivo anterior define un Secret llamado `giropops-secret` con dos campos de datos llamados `username` y `password`. El campo `password` contiene la cadena `giropops` codificada en `Base64`. Mi pregunta es: ¿cuál es el valor del campo `username`?

Si lo descubres, te reto a que hagas un tweet o una publicación en otra red social con el valor del campo `username` y las etiquetas #desafioDay8 y #DescomplicandoKubernetes. Si lo haces, te daré un premio, pero no te diré cuál es, ¡es un secreto! :D

Otra información importante que proporcionamos para este Secret fue su tipo, que es `Opaque`. Puedes ver que el tipo de Secret se define en el campo `type` del archivo YAML.

Ahora que has creado el archivo YAML, puedes crear el Secret usando el comando `kubectl create` o `kubectl apply`. Por ejemplo, para crear el Secret usando el comando `kubectl create`, ejecuta el siguiente comando:

```bash
kubectl create -f giropops-secret.yaml

secret/giropops-secret created
```

&nbsp;

¡Listo, nuestro primer Secret ha sido creado! Ahora puedes ver el Secret usando el comando `kubectl get`:

```bash
kubectl get secret giropops-secret

NAME              TYPE     DATA   AGE
giropops-secret   Opaque   2      10s
```

&nbsp;

La salida muestra el nombre del Secret, su tipo, la cantidad de datos que almacena y cuánto tiempo ha pasado desde su creación.

Si deseas ver los datos almacenados en el Secret, puedes usar el comando `kubectl get` con la opción `-o yaml`:

```bash
kubectl get secret giropops-secret -o yaml

apiVersion: v1
data:
  password: Z2lyb3BvcHM=
  username: SmVmZXJzb25fbGluZG8=
kind: Secret
metadata:
  creationTimestamp: "2023-05-21T10:38:39Z"
  name: giropops-secret
  namespace: default
  resourceVersion: "466"
  uid: ac816e95-8896-4ad4-9e64-4ee8258a8cda
type: Opaque
```

&nbsp;

¡Así de simple! Una vez más, los datos almacenados en el Secret no están encriptados y cualquier persona con acceso al Secret puede decodificarlos fácilmente, por lo que es fundamental controlar el acceso a los Secrets y no almacenar información sensible en ellos.

También puedes ver los detalles del Secret usando el comando `kubectl describe`:

```bash
kubectl describe secret giropops-secret

Name:         giropops-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  8 bytes
username:  15 bytes
```

&nbsp;

La salida del comando `kubectl describe` es similar al contenido del archivo YAML que creaste para definir el Secret, pero con información adicional, como el namespace del Secret, las etiquetas y las anotaciones, que también puedes definir en el archivo YAML.

Si deseas crear este mismo Secret utilizando el comando `kubectl create secret`, puedes ejecutar el siguiente comando:

```bash
kubectl create secret generic giropops-secret --from-literal=username=<SECRETO> --from-literal=password=giropops
```

&nbsp;

Fácil, aquí estamos utilizando el parámetro `--from-literal` para definir los datos del Secret. Otras opciones son `--from-file` y `--from-env-file`, que puedes utilizar para definir los datos del Secret a partir de un archivo o variables de entorno.

Si comparas las cadenas de los campos `username` y `password` del Secret creado utilizando el comando `kubectl create secret` con las cadenas de los campos `username` y `password` del Secret creado utilizando el archivo YAML, notarás que son identicas. Esto se debe porque el comando `kubectl create secret` automáticamente codifica los datos en Base64.

&nbsp;

##### Usando nuestro primer Secret

Ahora que ya hemos creado nuestro primer Secret, es hora de aprender cómo usarlo en un Pod.

En este primer ejemplo, solo mostraré cómo usar el Secret en un Pod, pero aún sin ninguna "función" especial, solo para demostrar cómo usar el Secret.

Para utilizar el Secret en un Pod, debes definir el campo `spec.containers[].env[].valueFrom.secretKeyRef` en el archivo YAML del Pod. Estoy presentando este campo en este formato para que puedas empezar a familiarizarte con él, ya que lo utilizarás bastante para buscar información más específica en la línea de comandos, por ejemplo, usando el comando `kubectl get`.

Volviendo al tema principal, necesitamos crear nuestro Pod, ¡así que vamos allá! Crea un archivo llamado `giropops-pod.yaml` con el siguiente contenido:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: giropops-pod
spec:
  containers:
  - name: giropops-container
    image: nginx
    env: # Inicio de la definición de las variables de entorno
    - name: USERNAME # Nombre de la variable de entorno que se utilizará en el Pod
      valueFrom: # Inicio de la definición de dónde se buscará el valor de la variable de entorno
        secretKeyRef: # Inicio de la definición de que el valor de la variable de entorno se buscará en un Secreto, a través de una clave
          name: giropops-secret # Nombre del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod
          key: username # Nombre de la clave del campo del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod
    - name: PASSWORD # Nombre de la variable de entorno que se utilizará en el Pod
      valueFrom: # Inicio de la definición de dónde se buscará el valor de la variable de entorno
        secretKeyRef: # Inicio de la definición de que el valor de la variable de entorno se buscará en un Secreto, a través de una clave
          name: giropops-secret # Nombre del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod
          key: password # Nombre de la clave del campo del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod
```

&nbsp;

He añadido comentarios en las líneas que son nuevas para ti, para que puedas entender lo que hace cada línea.

Pero ahora proporcionaré una explicación más detallada sobre el campo `spec.containers[].env[].valueFrom.secretKeyRef`:

- `spec.containers[].env[].valueFrom.secretKeyRef.name`: el nombre del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod.

- `spec.containers[].env[].valueFrom.secretKeyRef.key`: la clave del campo del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod.

Con esto, tendremos un Pod que tendrá un contenedor llamado `giropops-container` con dos variables de entorno, `USERNAME` y `PASSWORD`, que tendrán los valores definidos en el Secret `giropops-secret`.

Ahora crearemos el Pod utilizando el comando kubectl apply:

```bash
kubectl apply -f giropops-pod.yaml

pod/giropops-pod created
```

&nbsp;

Luego verificaremos si el Pod ha sido creado y si los Secretos se han inyectado en el Pod:

```bash
kubectl get pods

NAME           READY   STATUS    RESTARTS   AGE
giropops-pod   1/1     Running   0          2m
```

&nbsp;

Para verificar si los Secretos se han inyectado en el Pod, puedes utilizar el comando `kubectl exec` para ejecutar el comando `env` dentro del contenedor del Pod:

```bash
kubectl exec giropops-pod -- env

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=giropops-pod
NGINX_VERSION=1.23.4
NJS_VERSION=0.7.11
PKG_RELEASE=1~bullseye
PASSWORD=giropops
USERNAME=CENSURADO
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
HOME=/root
```

&nbsp;

Mira allí nuestros Secretos como variables de entorno dentro del contenedor del Pod.

¡Listo! ¡Tarea ejecutada con éxito! \o/

Ahora creo que podemos avanzar hacia los próximos tipos de Secrets.

##### Creando un Secreto para almacenar credenciales de Docker

Docker Hub es un servicio de registro de imágenes Docker que te permite almacenar y compartir imágenes Docker de forma pública o privada. En 2022, Docker Hub comenzó a limitar la cantidad de descargas de imágenes Docker públicas a 100 descargas cada 6 horas para usuarios no autenticados, y para usuarios autenticados, el límite es de 200 descargas cada 6 horas.

Pero el punto aquí es que puedes usar Docker Hub para almacenar imágenes Docker de forma privada, y para hacerlo necesitas una cuenta en Docker Hub. Para acceder a tu cuenta en Docker Hub, necesitas un nombre de usuario y una contraseña. ¿Entiendes hacia dónde voy? :D

Para que Kubernetes pueda acceder a Docker Hub, necesitas crear un Secreto que almacene el nombre de usuario y la contraseña de tu cuenta en Docker Hub, y luego debes configurar Kubernetes para que utilice este Secreto.

Cuando ejecutas `docker login` y la autenticación se realiza con éxito, Docker crea un archivo llamado `config.json` en el directorio `~/.docker/` de tu usuario. Este archivo contiene el nombre de usuario y la contraseña de tu cuenta en Docker Hub, y es este archivo el que debes utilizar para crear tu Secreto.

El primer paso es tomar el contenido de tu archivo `config.json` y codificarlo en base64, para lo cual puedes usar el comando `base64`:

```bash
base64 ~/.docker/config.json

QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```

&nbsp;

¡Entonces, adelante! Crea un archivo llamado dockerhub-secret.yaml con el siguiente contenido:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-hub-secret # nombre del Secreto
type: kubernetes.io/dockerconfigjson # tipo de Secreto, en este caso, es un Secreto que almacena credenciales de Docker
data:
  .dockerconfigjson: |  # reemplace este valor con el contenido de su archivo config.json codificado en base64
    QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```
&nbsp;

Lo que tenemos de nuevo aquí es en el campo `type`, que define el tipo del Secret, y en este caso es un Secret que almacena credenciales de Docker. Y en el campo data, tenemos el campo `dockerconfigjson`, que es el nombre del campo del Secret que almacena el contenido del archivo `config.json` codificado en `base64`.

Ahora crearemos el Secret utilizando el comando `kubectl apply`:

```bash
kubectl apply -f dockerhub-secret.yaml

secret/docker-hub-secret created
```

&nbsp;

Para listar el Secret que acabamos de crear, puedes utilizar el comando `kubectl get`:

```bash
kubectl get secrets

NAME                TYPE                             DATA   AGE
docker-hub-secret   kubernetes.io/dockerconfigjson   1      1s
```

&nbsp;

¡Secret creado, ahora podemos probar el acceso a Docker Hub!

Ahora Kubernetes tiene acceso a Docker Hub, y puedes utilizar Kubernetes para hacer la descarga de imágenes Docker privadas desde Docker Hub.

Una cosa importante, cada vez que necesites crear un Pod que deba utilizar una imagen Docker privada de Docker Hub, debes configurar el Pod para que utilice el Secret que almacena las credenciales de Docker Hub, y para ello, debes utilizar el campo `spec.imagePullSecrets` en el archivo YAML del Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mi-pod
spec:
  containers:
  - name: mi-container
    image: mi-imagen-privada
  imagePullSecrets: # campo que define el Secret que almacena las credenciales de Docker Hub
  - name: docker-hub-secret # nombre del Secret
```

&nbsp;

Observa el uso del campo `spec.imagePullSecrets` en el archivo YAML del Pod y el campo `name` que define el nombre del Secreto que almacena las credenciales de Docker Hub. Esto es todo lo que necesitas hacer para que Kubernetes pueda acceder a Docker Hub.

##### Criando um Secret TLS

El Secreto `kubernetes.io/tls` se utiliza para almacenar certificados TLS y claves privadas. Se utilizan para proporcionar seguridad en la comunicación entre servicios en Kubernetes. Por ejemplo, puedes utilizar un Secreto TLS para configurar HTTPS en tu servicio web.

Para crear un Secreto TLS, necesitas tener un certificado TLS y una clave privada, y debes codificar el certificado y la clave privada en base64 antes de crear el Secreto.

Crearemos un Secreto TLS para nuestro servicio web, pero primero debes tener un certificado TLS y una clave privada.

Para crear un certificado TLS y una clave privada, puedes utilizar el comando `openssl`:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt
```

&nbsp;

En el comando anterior, estamos creando un certificado TLS y una clave privada, y el certificado y la clave privada se almacenarán en los archivos `certificado.crt` y `chave-privada.key`, respectivamente. Puedes cambiar los nombres de los archivos por cualquier nombre que desees. Estamos utilizando el comando `openssl` para crear un certificado TLS autofirmado, para lo cual debes responder algunas preguntas, como el país, el estado, la ciudad, etc. Puedes responder cualquier cosa, no hay problema. Este certificado TLS autofirmado es solo para fines de prueba y no debe utilizarse en producción. Estamos utilizando el parámetro `-nodes` para que la clave privada no esté cifrada con una contraseña, y el parámetro `-days` para establecer la vigencia del certificado TLS, que en este caso es de 365 días. El parámetro `-newkey` se utiliza para establecer el algoritmo de cifrado de la clave privada, que en este caso es `rsa:2048`, que es un algoritmo de cifrado asimétrico que utiliza claves de 2048 bits.

No entraré en detalles sobre lo que es un certificado TLS y una clave privada, pero en resumen, un certificado TLS (Transport Layer Security) se utiliza para autenticar y establecer una conexión segura entre dos partes, como un cliente y un servidor. Contiene información sobre la entidad para la que se emitió y la entidad que lo emitió, así como la clave pública de la entidad para la que se emitió.

Por otro lado, la clave privada se utiliza para descifrar la información que se ha cifrado con la clave pública. Debe mantenerse en secreto y nunca compartirla, ya que cualquier persona con acceso a la clave privada puede descifrar la comunicación segura. Juntos, el certificado TLS y la clave privada forman un par de claves que permite la autenticación y la comunicación segura entre las partes.

¿Entendido? Espero que sí, porque no entraré en más detalles sobre esto. ¡jajaja!

Ahora volvamos a enfocarnos en la creación del Secreto TLS.

Con el certificado TLS y la clave privada creados, crearemos nuestro Secreto, solo para variar un poco. Crearemos el Secreto utilizando el comando `kubectl apply`:

```bash
kubectl create secret tls meu-servicio-web-tls-secret --cert=certificado.crt --key=chave-privada.key

secret/mi-servicio-web-tls-secret created
```

&nbsp;

Vamos a comprobar si el Secret ha sido creado:

```bash
kubectl get secrets
NAME                         TYPE                             DATA   AGE
mi-servicio-web-tls-secret   kubernetes.io/tls                2      4s
```

&nbsp;

Sí, el Secret está ahí y es del tipo `kubernetes.io/tls`.

Si deseas ver el contenido del Secret, puedes utilizar el comando `kubectl get secret` con el parámetro `-o yaml`:

```bash
kubectl get secret mi-servicio-web-tls-secret -o yaml
```

&nbsp;

Ahora puedes utilizar este Secreto para ejecutar Nginx con HTTPS, y para ello necesitas utilizar el campo `spec.tls` en el archivo YAML del Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
        - containerPort: 443
      volumeMounts:
        - name: nginx-config-volume
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: nginx-tls
          mountPath: /etc/nginx/tls
    volumes:
    - name: nginx-config-volume
      configMap:
        name: nginx-config
    - name: nginx-tls
      secret:
        secretName: mi-servicio-web-tls-secret
        items:
          - key: certificado.crt
            path: certificado.crt
          - key: clave-privada.key
            path: clave-privada.key
```

&nbsp;

Aquí tenemos mucha información nueva, así que vamos por partes.

Lo primero de lo que debemos hablar es sobre `spec.containers`, en particular sobre los volúmenes, que es el campo `spec.containers.volumeMounts`.

El campo `spec.containers.volumeMounts` se utiliza para montar un volumen en un directorio dentro del contenedor. En nuestro caso, estamos montando dos volúmenes, uno para el archivo de configuración de Nginx y otro para el certificado TLS y la clave privada.

Utilizamos el campo `spec.volumes` para definir los volúmenes que se utilizarán en el Pod, y estamos definiendo dos volúmenes, `nginx-config-volume` y `nginx-tls`.

El volumen `nginx-config-volume` es un volumen de tipo `configMap` y se utiliza para montar el archivo de configuración de Nginx, que está almacenado en el ConfigMap `nginx-config`. El próximo tema trata sobre ConfigMaps, así que no te preocupes por eso por ahora.

El volumen `nginx-tls` es un volumen de tipo `secret` y se utiliza para montar el Secret `mi-servicio-web-tls-secret`, que contiene el certificado TLS y la clave privada que se utilizarán para configurar HTTPS en Nginx.

Y como estamos configurando un Nginx para utilizar nuestro Secret, debemos indicar dónde queremos que se monten los archivos del Secret. Para ello, utilizamos el campo `spec.containers.volumeMounts.path` para especificar el directorio en el que queremos que se monten los archivos del Secret, en este caso, el directorio `/etc/nginx/tls`.

Mencioné que el volumen `nginx-config-volume` es un volumen de tipo `configMap`, lo que es una excelente introducción para el próximo tema, que trata sobre ConfigMaps. :D

Por lo tanto, continuaremos con nuestro ejemplo de cómo utilizar Nginx con HTTPS en el próximo tema sobre ConfigMaps. ¡Vamos allá! \o/

#### ConfigMaps

Los ConfigMaps se utilizan para almacenar datos de configuración, como variables de entorno, archivos de configuración, etc. Son muy útiles para almacenar datos de configuración que pueden ser utilizados por varios Pods.

Los ConfigMaps son una forma eficiente de desacoplar los parámetros de configuración de las imágenes de contenedor. Esto permite tener la misma imagen de contenedor en diferentes entornos, como desarrollo, prueba y producción, con diferentes configuraciones.

Aquí hay algunos puntos importantes sobre el uso de ConfigMaps en Kubernetes:

- Actualizaciones: Los ConfigMaps no se actualizan automáticamente en los Pods que los utilizan. Si actualizas un ConfigMap, los Pods existentes no recibirán la nueva configuración. Para que un Pod reciba la nueva configuración, debes recrear el Pod.

- Múltiples ConfigMaps: Es posible usar múltiples ConfigMaps para un solo Pod. Esto es útil cuando tienes diferentes aspectos de la configuración que deseas mantener separados.

- Variables de entorno: Además de montar el ConfigMap en un volumen, también es posible utilizar el ConfigMap para definir variables de entorno para los contenedores en el Pod.

- Inmutabilidad: A partir de la versión 1.19 de Kubernetes, es posible hacer que los ConfigMaps (y Secrets) sean inmutables, lo que puede mejorar el rendimiento de tu clúster si tienes muchos ConfigMaps o Secrets.

Como en el ejemplo del capítulo anterior, donde creamos un Pod con Nginx y utilizamos un ConfigMap para almacenar el archivo de configuración de Nginx, el `ConfigMap` se utiliza para almacenar el archivo de configuración de Nginx en lugar de almacenar el archivo de configuración dentro del Pod, lo que resulta en un Pod más limpio y fácil de mantener. Y, por supuesto, siempre es bueno utilizar las cosas para lo que fueron diseñadas, y el ConfigMap fue diseñado para almacenar datos de configuración.

Sigamos con nuestro ejemplo de cómo utilizar Nginx con HTTPS, pero esta vez utilizando un ConfigMap para almacenar el archivo de configuración de Nginx.

Creemos el archivo de configuración de Nginx llamado `nginx.conf`, que será utilizado por el ConfigMap:

```bash
events { } # Configuración de eventos

http { # Configuración del protocolo HTTP, que es el protocolo que utilizará Nginx
  server { # Configuración del servidor
    listen 80; # Puerto en el que Nginx escuchará
    listen 443 ssl; # Puerto en el que Nginx escuchará para HTTPS y se pasa el parámetro ssl para habilitar HTTPS

    ssl_certificate /etc/nginx/tls/certificado.crt; # Ruta del certificado TLS
    ssl_certificate_key /etc/nginx/tls/clave-privada.key; # Ruta de la clave privada

    location / { # Configuración de la ruta /
      return 200 '¡Bienvenido a Nginx!\n'; # Retorna el código 200 y el mensaje ¡Bienvenido a Nginx!
      add_header Content-Type text/plain; # Agrega el encabezado Content-Type con el valor text/plain
    } 
  }
}
```

&nbsp;

Dejé el contenido del archivo anterior con comentarios para facilitar la comprensión.

Lo que hace el archivo anterior es:

- Configurar Nginx para escuchar en los puertos 80 y 443, donde el puerto 443 se utiliza para HTTPS.
- Configurar Nginx para utilizar el certificado TLS y la clave privada que se encuentran en el directorio `/etc/nginx/tls`.
- Configurar la ruta `/` para devolver el código de estado 200 y el mensaje `¡Bienvenido a Nginx!` con el encabezado `Content-Type` con el valor `text/plain`.

Ahora crearemos el ConfigMap `nginx-config` con el archivo de configuración de Nginx:

```bash
kubectl create configmap nginx-config --from-file=nginx.conf
```

&nbsp;

¡Es bastante simple, ¿verdad? :)

Lo que estamos haciendo es crear un ConfigMap llamado `nginx-config` con el contenido del archivo `nginx.conf`.
Podemos hacer lo mismo a través de un manifiesto, como se muestra en el siguiente ejemplo:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events { }

    http {
      server {
        listen 80;
        listen 443 ssl;

        ssl_certificate /etc/nginx/tls/certificado.crt;
        ssl_certificate_key /etc/nginx/tls/clave-privada.key;

        location / {
          return 200 'Bienvenido a Nginx!\n';
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

El archivo se parece mucho a los manifiestos de `Secret`, pero con algunas diferencias:

- El campo `kind` es `ConfigMap` en lugar de `Secret`.
- El campo `data` se utiliza para definir el contenido del ConfigMap, y el campo `data` es un mapa de clave-valor, donde la clave es el nombre del archivo y el valor es el contenido del archivo. Utilizamos el carácter `|` para definir el valor del campo `data` como un bloque de texto, de esta manera podemos definir el contenido del archivo `nginx.conf` sin necesidad de utilizar el carácter `\n` para separar las líneas del archivo.

Ahora solo tienes que aplicar el manifiesto anterior:

```bash
kubectl apply -f nginx-config.yaml
```

&nbsp;

Para ver el contenido del ConfigMap que creamos, simplemente ejecuta el comando:

```bash
kubectl get configmap nginx-config -o yaml
```

&nbsp;

También puedes usar el comando `kubectl describe configmap nginx-config` para ver el contenido del ConfigMap, pero el comando `kubectl get configmap nginx-config -o yaml` es mucho más completo.

Ahora que ya tenemos nuestro `ConfigMap` creado, vamos a aplicar el manifiesto que creamos en el capítulo anterior. Lo copiaré aquí para facilitar:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    - containerPort: 443
    volumeMounts:
    - name: nginx-config-volume # Nombre del volumen que utilizaremos para montar el archivo de configuración de Nginx
      mountPath: /etc/nginx/nginx.conf # Ruta donde se montará el archivo de configuración de Nginx
      subPath: nginx.conf # Nombre del archivo de configuración de Nginx
    - name: nginx-tls # Nombre del volumen que utilizaremos para montar el certificado TLS y la clave privada
      mountPath: /etc/nginx/tls # Ruta donde se montará el certificado TLS y la clave privada
  volumes: # Lista de volúmenes que utilizaremos en el Pod
  - name: nginx-config-volume # Nombre del volumen que utilizaremos para montar el archivo de configuración de Nginx
    configMap: # Tipo de volumen que utilizaremos
      name: nginx-config # Nombre del ConfigMap que utilizaremos
  - name: nginx-tls # Nombre del volumen que utilizaremos para montar el certificado TLS y la clave privada
    secret: # Tipo de volumen que utilizaremos
      secretName: mi-servicio-web-tls-secret # Nombre del Secret que utilizaremos
      items: # Lista de archivos que montaremos, ya que dentro del secret hay dos archivos, el certificado TLS y la clave privada
        - key: tls.crt # Nombre del archivo que montaremos, nombre que está en el campo `data` del Secret
          path: certificado.crt # Nombre del archivo que se montará, nombre que se utilizará en el campo `ssl_certificate` del archivo de configuración de Nginx
        - key: tls.key # Nombre del archivo que montaremos, nombre que está en el campo `data` del Secret
          path: clave-privada.key # Nombre del archivo que se montará, nombre que se utilizará en el campo `ssl_certificate_key` del archivo de configuración de Nginx
```

Ahora solo tienes que aplicar el manifiesto anterior:

```bash
kubectl apply -f nginx.yaml
```

&nbsp;

Listando los Pods:

```bash
kubectl get pods
```

&nbsp;

Ahora necesitamos crear un Service para exponer el Pod que creamos:

```bash
kubectl expose pod nginx
```

&nbsp;

Listando los Services:

```bash
kubectl get services
```

&nbsp;

Vamos a hacer el `port-forward` para probar si nuestro Nginx está funcionando:

```bash
kubectl port-forward service/nginx 4443:443
```

&nbsp;

El comando anterior realizará el `port-forward` del puerto 443 del Service `nginx` al puerto 4443 de tu computadora, ¡el `port-forward` nos está salvando nuevamente! :)

Utilizaremos `curl` para comprobar si nuestro Nginx está funcionando:"

```bash
curl -k https://localhost:4443

Bienvenido a Nginx!
```

&nbsp;

¡Funciona maravillosamente!
Recuerda que este es un ejemplo muy simple; el objetivo aquí es mostrar cómo usar ConfigMap y Secret para montar archivos dentro de un Pod. El certificado TLS y la clave privada que usamos aquí son auto-firmados y no se recomiendan para su uso en producción, ni son aceptados por los navegadores, pero son adecuados para pruebas.

Creo que ya has comprendido cómo funciona ConfigMap, y recuerda que puedes usar ConfigMap no solo para montar archivos, sino también para definir variables de entorno, lo cual es muy útil cuando necesitas pasar una configuración a un contenedor a través de una variable de entorno.

Si deseas hacer que un ConfigMap sea inmutable, puedes utilizar el campo `immutable` en el manifiesto del ConfigMap, como se muestra en el siguiente ejemplo:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  immutable: true # convierte el ConfigMap en inmutable
data:
  nginx.conf: |
    events { }

    http {
      server {
        listen 80;
        listen 443 ssl;

        ssl_certificate /etc/nginx/tls/certificado.crt;
        ssl_certificate_key /etc/nginx/tls/clave-privada.key;

        location / {
          return 200 'Bienvenido a Nginx!\n';
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

Con esto, no será posible cambiar el ConfigMap, y si intentas modificarlo, Kubernetes devolverá un error.

Si deseas colocar el ConfigMap en un espacio de nombres específico, puedes utilizar el campo `namespace` en el manifiesto del ConfigMap, como se muestra en el siguiente ejemplo:"

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: mi-namespace # coloca el ConfigMap en el espacio de nombres mi-namespace
data:
  nginx.conf: |
    events { }

    http {
      server {
        listen 80;
        listen 443 ssl;

        ssl_certificate /etc/nginx/tls/certificado.crt;
        ssl_certificate_key /etc/nginx/tls/clave-privada.key;

        location / {
          return 200 'Bienvenido a Nginx!\n';
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

En resumen, creo que hemos cubierto bastante sobre ConfigMap. ¿Estás listo para pasar al próximo tema? ¡Vamos adelante! \o/

&nbsp;

#### Operador de Secretos Externos

El Operador de Secretos Externos (External Secrets Operator, ESO) es un maestro de los secretos en Kubernetes, capaz de trabajar en perfecta armonía con una amplia variedad de sistemas de gestión de secretos externos. Esto incluye, pero no se limita a, gigantes como AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault e IBM Cloud Secrets Manager.

El papel del ESO es buscar información en estas API externas y llevarla al entorno de Kubernetes, convirtiéndola en Secretos de Kubernetes listos para usar.

##### El Rol Destacado del ESO

La gran misión del ESO es sincronizar secretos desde las API externas al entorno de Kubernetes. Para lograrlo, utiliza tres recursos personalizados de la API: ExternalSecret, SecretStore y ClusterSecretStore. Estos recursos crean un puente entre Kubernetes y las API externas, permitiendo que los secretos se gestionen y utilicen de manera amigable y eficiente.

Para simplificar, nuestro ESO es el encargado de llevar los Secretos de Kubernetes a un nuevo nivel, permitiéndote utilizar herramientas especializadas en la gestión de secretos, como Hashicorp Vault, por ejemplo, que ya conoces.

##### Conceptos Clave del Operador de Secretos Externos

Vamos a explorar algunos conceptos fundamentales para nuestro trabajo con el Operador de Secretos Externos (ESO).

##### SecretStore

SecretStore es un recurso que separa las preocupaciones de autenticación/acceso de los secretos y configuraciones necesarios para las cargas de trabajo. Este recurso está basado en espacios de nombres (namespaces).

Imagina SecretStore como un administrador de secretos que conoce la forma de acceder a los datos. Contiene referencias a secretos que almacenan las credenciales para acceder a la API externa.

Aquí tienes un ejemplo simplificado de cómo se define SecretStore:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: secretstore-sample
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-secret
            key: secret-access-key
```

##### ExternalSecret

Un ExternalSecret declara qué datos buscar y tiene una referencia al SecretStore, que sabe cómo acceder a esos datos. El controlador utiliza este ExternalSecret como un plan para crear secretos.

Imagina un ExternalSecret como una solicitud al administrador de secretos (SecretStore) para recuperar un secreto específico. La configuración del ExternalSecret define qué buscar, dónde buscarlo y cómo formatear el secreto.

Aquí tienes un ejemplo simplificado de cómo se define un ExternalSecret:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: example
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: secretstore-sample
    kind: SecretStore
  target:
    name: secret-to-be-created
    creationPolicy: Owner
  data:
  - secretKey: secret-key-to-be-managed
    remoteRef:
      key: provider-key
      version: provider-key-version
      property: provider-key-property
  dataFrom:
  - extract:
      key: remote-key-in-the-provider
```

##### ClusterSecretStore

El ClusterSecretStore es un SecretStore global que puede ser referenciado desde todos los namespaces. Puedes usarlo como una puerta de enlace central para tu proveedor de secretos. Es similar a un SecretStore, pero con alcance en todo el clúster en lugar de estar limitado a un solo namespace.

##### Control de Acceso y Seguridad

ESO es un operador potente con un alto nivel de acceso. Crea, lee y actualiza secretos en todos los namespaces y tiene acceso a secretos almacenados en algunas APIs externas. Por lo tanto, es crucial garantizar que ESO tenga solo los privilegios mínimos necesarios y que SecretStore/ClusterSecretStore estén diseñados con cuidado.

Además, considera el uso de un sistema de control de admisión de Kubernetes (como OPA o Kyverno) para un control de acceso más refinado.

Ahora que tenemos una comprensión sólida de los conceptos clave, continuemos con la instalación de ESO en Kubernetes.

#### Configurando el External Secrets Operator

Echemos un vistazo a cómo instalar y configurar el External Secrets Operator en Kubernetes.
En este ejemplo, utilizaremos ESO para que Kubernetes pueda acceder a los secretos en un clúster Vault.

Antes de comenzar, comprendamos qué es Vault, en caso de que aún no lo conozcas.

##### ¿Qué es Vault?

HashiCorp Vault es una herramienta para administrar secretos de manera segura. Le permite almacenar y controlar el acceso a tokens, contraseñas, certificados, claves de cifrado y otra información confidencial. En nuestro contexto, Vault se convierte en una poderosa solución para abordar los problemas inherentes a la forma en que Kubernetes maneja los Secrets.

##### ¿Por qué usar Vault?

Con Vault, puedes centralizar la gestión de secretos, reduciendo la superficie de ataque y minimizando el riesgo de fugas de datos. Vault también ofrece un control detallado de las políticas de acceso, lo que permite determinar quién puede acceder a qué, cuándo y dónde.

##### Comandos Básicos de Vault

Vault puede ser un poco complejo para los principiantes, pero si ya has trabajado con él, los comandos básicos son relativamente sencillos.

**Instalando el Hashicorp Vault**

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vault
```

**Iniciando el Vault en Modo Dev**

```bash
vault server -dev
```

El comando inicia Vault en modo de desarrollo, lo cual es útil para propósitos de aprendizaje y experimentación.

**Configurando el Entorno**

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
```

Esto configura la variable de entorno `VAULT_ADDR`, apuntando hacia la dirección del servidor de Vault.

**Escribiendo los Secrets**

```bash
vault kv put secret/my-secret password=my-password
```

Este comando escribe un secreto llamado "my-secret" con la contraseña "my-password".

**Leyendo Secrets**

```bash
vault kv get secret/my-secret
```

Este comando lee el secreto llamado "my-secret".

##### El Vault en el contexto de Kubernetes

Ahora que ha repasado los conceptos básicos de Vault, el siguiente paso es comprender cómo puede trabajar en conjunto con Kubernetes y ESO para mejorar la gestión de secretos.

##### Instalación y configuración de Vault en Kubernetes

Ahora profundizaremos en la parte práctica. Configuraremos Vault en Kubernetes paso a paso utilizando Helm. Al final de este proceso, tendremos Vault instalado, configurado y listo para su uso.

##### Requisitos previos

Antes de comenzar, asegúrese de tener lo siguiente:

1. Una instancia de Kubernetes en funcionamiento.
2. Helm instalado en su máquina local o en su clúster.

##### Instalación y configuración de Vault con Helm

Aquí están los pasos para instalar y configurar Vault utilizando Helm:

**1. Agregue el repositorio HashiCorp a Helm.**

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

#################
Este comando adiciona o repositório Helm da HashiCorp à nossa configuração do Helm.

**2. Instale o Vault usando Helm**

```bash
helm install vault hashicorp/vault
```

Este comando instala o Vault no cluster Kubernetes.

**3. Inicie uma shell interativa dentro do pod do Vault**

```bash
kubectl exec -ti vault-0 -- sh
```

Este comando inicia uma shell interativa dentro do pod do Vault, permitindo que interajamos diretamente com o Vault.

**4. Inicialize e desbloqueie o Vault**

Nesse ponto é importante você guardar as chaves que são criadas no momento que você inicializa o seu cluster Vault, pois elas serão necessárias para desbloquear o Vault. Guarde essa informação em um local seguro, pois sem essas chaves você não conseguirá desbloquear o Vault.

```bash
vault operator init
vault operator unseal
vault login
```

Estes comandos inicializam o Vault, removem o selo e fazem login.

**5. Crie uma política no Vault**

```bash
vault policy write external-secret-operator-policy -<<EOF
path "data/postgres" { 
capabilities = ["read"]
}
EOF
```

Este comando cria uma política chamada "external-secret-operator-policy" que concede permissões de leitura no caminho "data/postgres".

**6. Crie um token com a política que você acabou de definir**

```bash
vault token create -policy="external-secret-operator-policy"
```

Este comando cria um token vinculado à política "external-secret-operator-policy".

**7. Habilite o armazenamento de segredos e adicione alguns segredos para teste**

```bash
vault secrets enable -path=data kv
vault kv put data/postgres POSTGRES_USER=admin POSTGRES_PASSWORD=123456
```

Estes comandos habilitam o armazenamento de segredos e adicionam um segredo de exemplo ao caminho "data/postgres".

E é isso! Agora você tem o Vault instalado e configurado no seu cluster Kubernetes.



##### Adicionando o Repositório do External Secrets Operator ao Helm

Antes de instalar o ESO, precisamos adicionar o repositório External Secrets ao Helm. Faça isso com os seguintes comandos:

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
```

##### Instalando o External Secrets Operator

Após a adição do repositório, você pode instalar o ESO com o comando abaixo:

```bash
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true
```

##### Verificando a Instalação do ESO

Para verificar se o ESO foi instalado corretamente, você pode executar o seguinte comando:

```bash
kubectl get all -n external-secrets
```

##### Criando um Segredo no Kubernetes

Agora, precisamos criar um segredo no Kubernetes que contém o token do Vault. Faça isso com o seguinte comando:

```bash
kubectl create secret generic vault-token --from-literal=token=SEU_TOKEN_DO_VAULT
```

Lembre-se de substituir `SEU_TOKEN_DO_VAULT` pelo token real que você obteve do Vault.

Para verificar se o segredo foi criado corretamente, você pode executar o seguinte comando:

```bash
kubectl get secrets
```

##### Configurando o ClusterSecretStore

O próximo passo é configurar o ClusterSecretStore, que é o recurso que fornecerá um gateway central para seu provedor de segredos. Para fazer isso, você precisa criar um arquivo chamado `cluster-store.yaml` com o seguinte conteúdo:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore #Kubernetes resource type
metadata:
  name: vault-backend #resource name
spec:
  provider:
    vault: #specifies vault as the provider
      server: "http://10.43.238.17:8200" #the address of your vault instance
      path: "data" #path for accessing the secrets
      version: "v1" #Vault API version
      auth:
        tokenSecretRef:
          name: "vault-token" #Use a secret called vault-token
          key: "token" #Use this key to access the vault token
```

Para aplicar essa configuração ao Kubernetes, use o seguinte comando:

```bash
kubectl apply -f cluster-store.yaml
```

##### Criando um ExternalSecret

Finalmente, precisamos criar um ExternalSecret que especifica quais dados buscar do provedor de segredos. Para fazer isso, crie um arquivo chamado `ex-secrets.yaml` com o seguinte conteúdo:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: external-secret
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: postgres-secret
    creationPolicy: Owner
  data:
    - secretKey: POSTGRES_USER
      remoteRef:
        key: data/postgres
        property: POSTGRES_USER
    - secretKey: POSTGRES_PASSWORD
      remoteRef:
        key: data/postgres
        property: POSTGRES_PASSWORD
```

Para aplicar essa configuração ao Kubernetes, use o seguinte comando:

```bash
kubectl apply -f ex-secrets.yaml
```

Para verificar a criação do ExternalSecret, você pode executar o seguinte comando:

```bash
kubectl get externalsecret
```

E aí está! Você instalou e configurou com sucesso o External Secrets Operator no Kubernetes. Lembre-se, este é apenas um exemplo de como usar o ESO para integrar o Vault com o Kubernetes, mas os mesmos princípios se aplicam a outros provedores de segredos.

Ótimo! Para verificar se a sincronização funcionou corretamente e para utilizar o segredo no seu cluster Kubernetes, você pode criar um deployment. Vamos fazer isso criando um arquivo `deployment.yaml` que define um deployment de exemplo. No exemplo abaixo, estaremos criando um deployment de um banco de dados PostgreSQL que faz uso do segredo que criamos anteriormente.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:latest
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
```

Este arquivo define um deployment do PostgreSQL que tem um único réplica. Ele define duas variáveis de ambiente, `POSTGRES_USER` e `POSTGRES_PASSWORD`, que obtêm seus valores do segredo `postgres-secret` que criamos anteriormente usando o External Secrets Operator.

Para criar o deployment, use o seguinte comando:

```bash
kubectl apply -f deployment.yaml
```

Depois de executar este comando, o Kubernetes criará o deployment e iniciará o contêiner do PostgreSQL. Os valores para `POSTGRES_USER` e `POSTGRES_PASSWORD` serão preenchidos com os valores do segredo `postgres-secret`.

Para verificar se o deployment foi criado com sucesso, você pode executar o seguinte comando:

```bash
kubectl get deployments
```

Se tudo funcionou corretamente, você verá o seu deployment `postgres-deployment` listado.

Com isso, você verificou que a sincronização do External Secrets Operator funcionou como esperado e que o segredo está sendo utilizado corretamente pelo seu deployment.




## Final do Day-8

Hoje o dia foi dedicado dois componentes importantes do Kubernetes: Secrets e ConfigMaps.

Secrets no Kubernetes são um recurso que nos permite gerenciar informações sensíveis, como senhas, tokens OAuth, chaves ssh, etc. Devido à sua natureza sensível, o Kubernetes oferece uma série de recursos para gerenciar Secrets de maneira segura. Usamos o recurso base64 para codificar nossas senhas e chaves secretas. Aprendemos como criar, obter e descrever um Secret, bem como como excluir um Secret.

Fomos além e usamos o Secret para armazenar um certificado TLS e uma chave privada, que usamos para configurar o Nginx para usar HTTPS. Usamos o Secret para montar o certificado TLS e a chave privada em um Pod do Nginx, e usamos um arquivo de manifesto para definir o Secret.

Depois disso, exploramos ConfigMaps. ConfigMaps são uma maneira eficiente de separar parâmetros de configuração de imagens de container, permitindo que você tenha a mesma imagem de container rodando em diferentes ambientes como desenvolvimento, teste e produção, mas com configurações diferentes.

Vimos:

- Atualizar um ConfigMap.
- Usar o ConfigMaps.
- Usar o ConfigMap para definir variáveis de ambiente para os containers no Pod.
- Tornar ConfigMaps imutáveis.
- Criamos um arquivo de configuração do Nginx usando um ConfigMap, que usamos para configurar um Pod do Nginx. Também exploramos como montar o ConfigMap em um volume e como usar um arquivo de manifesto para definir o ConfigMap.
- Descomplicamos o uso do External Secret Operator e sua integração com o Vault.

Finalmente, usamos o ConfigMap e o Secret juntos para configurar um Pod do Nginx para usar HTTPS, onde o ConfigMap é usado para armazenar o arquivo de configuração do Nginx e o Secret é usado para armazenar o certificado TLS e a chave privada.

Essa combinação de ConfigMaps e Secrets não só nos permite gerenciar nossas configurações e dados sensíveis de maneira eficiente e segura, mas também nos oferece um alto grau de flexibilidade e controle sobre as nossas aplicações.

E isso é tudo por hoje, chega! :D

Vejo você no próximo dia, até láááá! &nbsp; :wave: &nbsp; :v:

&nbsp;
