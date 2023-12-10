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
<<<<<<< HEAD
        - [Creando un Secret para almacenar credenciales Docker](#creando-un-secret-para-almacenar-credenciales-docker)
        - [Creando un Secret TLS](#creando-un-secret-tls)
      - [ConfigMaps](#configmaps)
      - [External Secret Operator](#external-secret-operator)
        - [El Papel Destacado del ESO](#el-papel-destacado-del-eso)
        - [Conceptos Clave del External Secrets Operator](#conceptos-clave-del-external-secrets-operator)
=======
        - [Creando un Secreto para almacenar credenciales de Docker](#creando-un-secreto-para-almacenar-credenciales-de-docker)
        - [Criando um Secret TLS](#criando-um-secret-tls)
      - [ConfigMaps](#configmaps)
      - [Operador de Secretos Externos](#operador-de-secretos-externos)
        - [El Rol Destacado del ESO](#el-rol-destacado-del-eso)
        - [Conceptos Clave del Operador de Secretos Externos](#conceptos-clave-del-operador-de-secretos-externos)
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
        - [SecretStore](#secretstore)
        - [ExternalSecret](#externalsecret)
        - [ClusterSecretStore](#clustersecretstore)
        - [Control de Acceso y Seguridad](#control-de-acceso-y-seguridad)
      - [Configurando el External Secrets Operator](#configurando-el-external-secrets-operator)
        - [¿Qué es Vault?](#qué-es-vault)
<<<<<<< HEAD
        - [¿Por Qué Usar Vault?](#por-qué-usar-vault)
        - [Comandos Básicos de Vault](#comandos-básicos-de-vault)
        - [El Vault en el Contexto de Kubernetes](#el-vault-en-el-contexto-de-kubernetes)
        - [Instalación y Configuración de Vault en Kubernetes](#instalación-y-configuración-de-vault-en-kubernetes)
        - [Requisitos Previos](#requisitos-previos)
        - [Instalando y Configurando Vault con Helm](#instalando-y-configurando-vault-con-helm)
        - [Agregar el Repositorio del Operador de Secretos Externos a Helm](#agregar-el-repositorio-del-operador-de-secretos-externos-a-helm)
        - [Instalando el Operador de Secretos Externos](#instalando-el-operador-de-secretos-externos)
        - [Verificación de la Instalación de ESO](#verificación-de-la-instalación-de-eso)
        - [Creación de un Secreto en Kubernetes](#creación-de-un-secreto-en-kubernetes)
        - [Configuración del ClusterSecretStore](#configuración-del-clustersecretstore)
        - [Creación de un ExternalSecret](#creación-de-un-externalsecret)
  - [Final del Día 8](#final-del-día-8)
=======
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
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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

<<<<<<< HEAD
Ahora que ya tenemos nuestro primer Secret creado, es hora de aprender cómo utilizarlo en un Pod.

En este primer ejemplo, solo mostraré cómo usar el Secret en un Pod, pero todavía sin ninguna "función" especial, solo para demostrar cómo se utiliza el Secret.

Para usar el Secret en un Pod, necesitas definir el campo spec.containers[].env[].valueFrom.secretKeyRef en el archivo YAML del Pod. Estoy presentando el campo en este formato para que puedas empezar a familiarizarte con él, ya que lo utilizarás bastante para buscar alguna información más específica en la línea de comandos, usando el comando kubectl get, por ejemplo.

Volviendo al tema principal, necesitamos crear nuestro Pod, ¡así que vamos allá! Crea un archivo llamado giropops-pod.yaml con el siguiente contenido:
=======
Ahora que ya hemos creado nuestro primer Secret, es hora de aprender cómo usarlo en un Pod.

En este primer ejemplo, solo mostraré cómo usar el Secret en un Pod, pero aún sin ninguna "función" especial, solo para demostrar cómo usar el Secret.

Para utilizar el Secret en un Pod, debes definir el campo `spec.containers[].env[].valueFrom.secretKeyRef` en el archivo YAML del Pod. Estoy presentando este campo en este formato para que puedas empezar a familiarizarte con él, ya que lo utilizarás bastante para buscar información más específica en la línea de comandos, por ejemplo, usando el comando `kubectl get`.

Volviendo al tema principal, necesitamos crear nuestro Pod, ¡así que vamos allá! Crea un archivo llamado `giropops-pod.yaml` con el siguiente contenido:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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
<<<<<<< HEAD
    - name: USERNAME # Nombre de la variable de entorno que se usará en el Pod
      valueFrom: # Inicio de la definición de dónde se buscará el valor de la variable de entorno
        secretKeyRef: # Inicio de la definición de que el valor de la variable de entorno se buscará en un Secret, a través de una clave
          name: giropops-secret # Nombre del Secret que contiene el valor de la variable de entorno que se usará en el Pod
          key: username # Nombre de la clave del campo del Secret que contiene el valor de la variable de entorno que se usará en el Pod
    - name: PASSWORD # Nombre de la variable de entorno que se usará en el Pod
      valueFrom: # Inicio de la definición de dónde se buscará el valor de la variable de entorno
        secretKeyRef: # Inicio de la definición de que el valor de la variable de entorno se buscará en un Secret, a través de una clave
          name: giropops-secret # Nombre del Secret que contiene el valor de la variable de entorno que se usará en el Pod
          key: password # Nombre de la clave del campo del Secret que contiene el valor de la variable de entorno que se usará en el Pod
=======
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
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
```

&nbsp;

He añadido comentarios en las líneas que son nuevas para ti, para que puedas entender lo que hace cada línea.

<<<<<<< HEAD
Pero aquí te traigo una explicación más detallada sobre el campo `spec.containers[].env[].valueFrom.secretKeyRef`:

- `spec.containers[].env[].valueFrom.secretKeyRef.name`: el nombre del Secret que contiene el valor de la variable de entorno que se utilizará en el Pod;

- `spec.containers[].env[].valueFrom.secretKeyRef.key`: la clave del campo del Secret que contiene el valor de la variable de entorno que se utilizará en el Pod;

Con esto tendremos un Pod, que tendrá un contenedor llamado `giropops-container`, que contará con dos variables de entorno, `USERNAME` y `PASSWORD`, que tendrán los valores definidos en el Secret `giropops-secret`.

Ahora vamos a crear el Pod usando el comando kubectl apply:
=======
Pero ahora proporcionaré una explicación más detallada sobre el campo `spec.containers[].env[].valueFrom.secretKeyRef`:

- `spec.containers[].env[].valueFrom.secretKeyRef.name`: el nombre del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod.

- `spec.containers[].env[].valueFrom.secretKeyRef.key`: la clave del campo del Secreto que contiene el valor de la variable de entorno que se utilizará en el Pod.

Con esto, tendremos un Pod que tendrá un contenedor llamado `giropops-container` con dos variables de entorno, `USERNAME` y `PASSWORD`, que tendrán los valores definidos en el Secret `giropops-secret`.

Ahora crearemos el Pod utilizando el comando kubectl apply:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
Copy code
kubectl apply -f giropops-pod.yaml

pod/giropops-pod created
```

&nbsp;

<<<<<<< HEAD
Ahora vamos a verificar si el Pod ha sido creado y si los Secrets han sido inyectados en el Pod:
=======
Luego verificaremos si el Pod ha sido creado y si los Secretos se han inyectado en el Pod:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl get pods

NAME           READY   STATUS    RESTARTS   AGE
giropops-pod   1/1     Running   0          2m
```

&nbsp;

<<<<<<< HEAD
Para verificar si los Secrets han sido inyectados en el Pod, puedes utilizar el comando kubectl exec para ejecutar el comando env dentro del contenedor del Pod:
=======
Para verificar si los Secretos se han inyectado en el Pod, puedes utilizar el comando `kubectl exec` para ejecutar el comando `env` dentro del contenedor del Pod:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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

<<<<<<< HEAD
¡Mira ahí nuestros Secrets como variables de entorno dentro del contenedor del Pod!

¡Listo! ¡Tarea ejecutada con éxito! \o/

Ahora creo que ya podemos pasar a los siguientes tipos de Secrets!

&nbsp;

##### Creando un Secret para almacenar credenciales Docker

Docker Hub es un servicio de registro de imágenes Docker, que permite almacenar y compartir imágenes Docker públicamente o de manera privada. En 2022, Docker Hub comenzó a limitar el número de descargas de imágenes Docker públicas a 100 descargas cada 6 horas para usuarios no autenticados, y para usuarios autenticados, el límite es de 200 descargas cada 6 horas.

Pero el punto aquí es que puedes usar Docker Hub para almacenar imágenes Docker privadas, y para eso necesitas una cuenta en Docker Hub, y para acceder a tu cuenta en Docker Hub, necesitas un nombre de usuario y una contraseña. ¿Entiendes a dónde quiero llegar? :D

Para que Kubernetes pueda acceder a Docker Hub, necesitas crear un Secret que almacene el nombre de usuario y la contraseña de tu cuenta en Docker Hub, y luego necesitas configurar Kubernetes para usar ese Secret.

Cuando ejecutas `docker login` y tu autenticación es exitosa, Docker crea un archivo llamado `config.json` en el directorio `~/.docker/` de tu usuario, y ese archivo contiene el nombre de usuario y la contraseña de tu cuenta en Docker Hub, y es ese archivo el que necesitas usar para crear tu Secret.

El primer paso es obtener el contenido de tu archivo `config.json` y codificarlo en base64, y para eso puedes usar el comando `base64`:
=======
Mira allí nuestros Secretos como variables de entorno dentro del contenedor del Pod.

¡Listo! ¡Tarea ejecutada con éxito! \o/

Ahora creo que podemos avanzar hacia los próximos tipos de Secrets.

##### Creando un Secreto para almacenar credenciales de Docker

Docker Hub es un servicio de registro de imágenes Docker que te permite almacenar y compartir imágenes Docker de forma pública o privada. En 2022, Docker Hub comenzó a limitar la cantidad de descargas de imágenes Docker públicas a 100 descargas cada 6 horas para usuarios no autenticados, y para usuarios autenticados, el límite es de 200 descargas cada 6 horas.

Pero el punto aquí es que puedes usar Docker Hub para almacenar imágenes Docker de forma privada, y para hacerlo necesitas una cuenta en Docker Hub. Para acceder a tu cuenta en Docker Hub, necesitas un nombre de usuario y una contraseña. ¿Entiendes hacia dónde voy? :D

Para que Kubernetes pueda acceder a Docker Hub, necesitas crear un Secreto que almacene el nombre de usuario y la contraseña de tu cuenta en Docker Hub, y luego debes configurar Kubernetes para que utilice este Secreto.

Cuando ejecutas `docker login` y la autenticación se realiza con éxito, Docker crea un archivo llamado `config.json` en el directorio `~/.docker/` de tu usuario. Este archivo contiene el nombre de usuario y la contraseña de tu cuenta en Docker Hub, y es este archivo el que debes utilizar para crear tu Secreto.

El primer paso es tomar el contenido de tu archivo `config.json` y codificarlo en base64, para lo cual puedes usar el comando `base64`:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
base64 ~/.docker/config.json

QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```

&nbsp;

<<<<<<< HEAD
¡Entonces vamos allá! Crea un archivo llamado `dockerhub-secret.yaml`con el siguiente contenido:
=======
¡Entonces, adelante! Crea un archivo llamado dockerhub-secret.yaml con el siguiente contenido:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```yaml
apiVersion: v1
kind: Secret
metadata:
<<<<<<< HEAD
  name: docker-hub-secret # nombre del Secret
type: kubernetes.io/dockerconfigjson # tipo del Secret, en este caso es un Secret que almacena credenciales Docker
data:
  .dockerconfigjson: |  # sustituye este valor por el contenido de tu archivo config.json codificado en base64
=======
  name: docker-hub-secret # nombre del Secreto
type: kubernetes.io/dockerconfigjson # tipo de Secreto, en este caso, es un Secreto que almacena credenciales de Docker
data:
  .dockerconfigjson: |  # reemplace este valor con el contenido de su archivo config.json codificado en base64
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
    QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```
&nbsp;

<<<<<<< HEAD
Lo nuevo aquí es en el campo `type`, que define el tipo del Secret, y en este caso es un Secret que almacena credenciales Docker, y en el campo `data` tenemos el campo `dockerconfigjson`, que es el nombre del campo del Secret que almacena el contenido del archivo `config.json` codificado en base64.

Ahora vamos a crear el Secret usando el comando `kubectl apply`:
=======
Lo que tenemos de nuevo aquí es en el campo `type`, que define el tipo del Secret, y en este caso es un Secret que almacena credenciales de Docker. Y en el campo data, tenemos el campo `dockerconfigjson`, que es el nombre del campo del Secret que almacena el contenido del archivo `config.json` codificado en `base64`.

Ahora crearemos el Secret utilizando el comando `kubectl apply`:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl apply -f dockerhub-secret.yaml

secret/docker-hub-secret created
```

&nbsp;

<<<<<<< HEAD
Para listar el Secret que acabamos de crear, puedes usar el comando `kubectl get`:
=======
Para listar el Secret que acabamos de crear, puedes utilizar el comando `kubectl get`:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl get secrets

NAME                TYPE                             DATA   AGE
docker-hub-secret   kubernetes.io/dockerconfigjson   1      1s
```

&nbsp;

<<<<<<< HEAD
Secret creada, ¡ahora ya podemos probar el acceso al Docker Hub!

Ahora Kubernetes ya tiene acceso al Docker Hub, y puedes usar Kubernetes para hacer pull de imágenes Docker privadas del Docker Hub.

Una cosa importante, siempre que necesites crear un Pod que requiera utilizar una imagen Docker privada del Docker Hub, necesitas configurar el Pod para usar el Secret que almacena las credenciales del Docker Hub, y para eso necesitas usar el campo `spec.imagePullSecrets` en el archivo YAML del Pod.
=======
¡Secret creado, ahora podemos probar el acceso a Docker Hub!

Ahora Kubernetes tiene acceso a Docker Hub, y puedes utilizar Kubernetes para hacer la descarga de imágenes Docker privadas desde Docker Hub.

Una cosa importante, cada vez que necesites crear un Pod que deba utilizar una imagen Docker privada de Docker Hub, debes configurar el Pod para que utilice el Secret que almacena las credenciales de Docker Hub, y para ello, debes utilizar el campo `spec.imagePullSecrets` en el archivo YAML del Pod.
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mi-pod
spec:
  containers:
  - name: mi-container
    image: mi-imagen-privada
<<<<<<< HEAD
  imagePullSecrets: # campo que define el Secret que almacena las credenciales del Docker Hub
=======
  imagePullSecrets: # campo que define el Secret que almacena las credenciales de Docker Hub
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
  - name: docker-hub-secret # nombre del Secret
```

&nbsp;

<<<<<<< HEAD
Observa la utilización del campo `spec.imagePullSecrets` en el archivo YAML del Pod, y el campo `name` que define el nombre del Secret que almacena las credenciales del Docker Hub. Esto es todo lo que necesitas hacer para que Kubernetes pueda acceder al Docker Hub.

&nbsp;
=======
Observa el uso del campo `spec.imagePullSecrets` en el archivo YAML del Pod y el campo `name` que define el nombre del Secreto que almacena las credenciales de Docker Hub. Esto es todo lo que necesitas hacer para que Kubernetes pueda acceder a Docker Hub.
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

##### Creando un Secret TLS

<<<<<<< HEAD
El Secret `kubernetes.io/tls`, se utiliza para almacenar certificados TLS y claves privadas. Se usan para proporcionar seguridad en la comunicación entre los servicios en Kubernetes. Por ejemplo, puedes usar un Secret TLS para configurar HTTPS en tu servicio web.

Para crear un Secret TLS, necesitas tener un certificado TLS y una clave privada, y necesitas codificar el certificado y la clave privada en base64 para luego crear el Secret.

Vamos a crear un Secret TLS para nuestro servicio web, pero para eso, necesitas tener un certificado TLS y una clave privada antes de nada.

Para crear un certificado TLS y una clave privada, puedes usar el comando `openssl`:
=======
El Secreto `kubernetes.io/tls` se utiliza para almacenar certificados TLS y claves privadas. Se utilizan para proporcionar seguridad en la comunicación entre servicios en Kubernetes. Por ejemplo, puedes utilizar un Secreto TLS para configurar HTTPS en tu servicio web.

Para crear un Secreto TLS, necesitas tener un certificado TLS y una clave privada, y debes codificar el certificado y la clave privada en base64 antes de crear el Secreto.

Crearemos un Secreto TLS para nuestro servicio web, pero primero debes tener un certificado TLS y una clave privada.

Para crear un certificado TLS y una clave privada, puedes utilizar el comando `openssl`:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout clave-privada.key -out certificado.crt
```

&nbsp;

<<<<<<< HEAD
En el comando anterior, estamos creando un certificado TLS y una clave privada, y el certificado y la clave privada se almacenarán en los archivos `certificado.crt` y `clave-privada.key`, respectivamente. Puedes sustituir los nombres de los archivos por cualquier nombre que quieras.
Estamos usando el comando `openssl` para crear un certificado TLS auto-firmado, y para ello necesitas responder algunas preguntas, como el país, estado, ciudad, etc. Puedes responder cualquier cosa, no hay problema. Este certificado TLS auto-firmado es solo para fines de prueba, y no debe ser utilizado en producción. Estamos pasando el parámetro `-nodes` para que la clave privada no sea cifrada con una contraseña, y el parámetro `-days` para definir la validez del certificado TLS, que en este caso es de 365 días. El parámetro `-newkey` se utiliza para definir el algoritmo de cifrado de la clave privada, que en este caso es `rsa:2048`, un algoritmo de cifrado asimétrico que utiliza claves de 2048 bits.

No quiero entrar en detalles sobre lo que es un certificado TLS y una clave privada, pero, básicamente, un certificado TLS (Transport Layer Security) se utiliza para autenticar y establecer una conexión segura entre dos partes, como un cliente y un servidor. Contiene información sobre la entidad a la que se emitió y la entidad que lo emitió, así como la clave pública de la entidad a la que se emitió.

La clave privada, por otro lado, se utiliza para descifrar la información que fue cifrada con la clave pública. Debe mantenerse en secreto y nunca compartida, ya que cualquier persona con acceso a la clave privada puede descifrar la comunicación segura. Juntos, el certificado TLS y la clave privada forman un par de claves que permite la autenticación y la comunicación segura entre las partes.

¿Entendido? Espero que sí, porque no voy a entrar en más detalles sobre eso. hahaha

Ahora volvamos al foco en la creación del Secret TLS.

Con el certificado TLS y la clave privada creados, vamos a crear nuestro Secret, solo para cambiar un poco, vamos a crear el Secret usando el comando `kubectl apply`:

```bash
kubectl create secret tls mi-servicio-web-tls-secret --cert=certificado.crt --key=clave-privada.key
=======
En el comando anterior, estamos creando un certificado TLS y una clave privada, y el certificado y la clave privada se almacenarán en los archivos `certificado.crt` y `chave-privada.key`, respectivamente. Puedes cambiar los nombres de los archivos por cualquier nombre que desees. Estamos utilizando el comando `openssl` para crear un certificado TLS autofirmado, para lo cual debes responder algunas preguntas, como el país, el estado, la ciudad, etc. Puedes responder cualquier cosa, no hay problema. Este certificado TLS autofirmado es solo para fines de prueba y no debe utilizarse en producción. Estamos utilizando el parámetro `-nodes` para que la clave privada no esté cifrada con una contraseña, y el parámetro `-days` para establecer la vigencia del certificado TLS, que en este caso es de 365 días. El parámetro `-newkey` se utiliza para establecer el algoritmo de cifrado de la clave privada, que en este caso es `rsa:2048`, que es un algoritmo de cifrado asimétrico que utiliza claves de 2048 bits.

No entraré en detalles sobre lo que es un certificado TLS y una clave privada, pero en resumen, un certificado TLS (Transport Layer Security) se utiliza para autenticar y establecer una conexión segura entre dos partes, como un cliente y un servidor. Contiene información sobre la entidad para la que se emitió y la entidad que lo emitió, así como la clave pública de la entidad para la que se emitió.

Por otro lado, la clave privada se utiliza para descifrar la información que se ha cifrado con la clave pública. Debe mantenerse en secreto y nunca compartirla, ya que cualquier persona con acceso a la clave privada puede descifrar la comunicación segura. Juntos, el certificado TLS y la clave privada forman un par de claves que permite la autenticación y la comunicación segura entre las partes.

¿Entendido? Espero que sí, porque no entraré en más detalles sobre esto. ¡jajaja!

Ahora volvamos a enfocarnos en la creación del Secreto TLS.

Con el certificado TLS y la clave privada creados, crearemos nuestro Secreto, solo para variar un poco. Crearemos el Secreto utilizando el comando `kubectl apply`:

```bash
kubectl create secret tls meu-servicio-web-tls-secret --cert=certificado.crt --key=chave-privada.key
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

secret/mi-servicio-web-tls-secret created
```

&nbsp;

<<<<<<< HEAD
Vamos a ver si el Secret fue creado:
=======
Vamos a comprobar si el Secret ha sido creado:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl get secrets
NAME                         TYPE                             DATA   AGE
mi-servicio-web-tls-secret   kubernetes.io/tls                2      4s
```

&nbsp;

<<<<<<< HEAD
Sí, el Secret está allí y es del tipo `kubernetes.io/tls`.

Si quieres ver el contenido del Secret, puedes usar el comando `kubectl get secret` con el parámetro `-o yaml`:
=======
Sí, el Secret está ahí y es del tipo `kubernetes.io/tls`.

Si deseas ver el contenido del Secret, puedes utilizar el comando `kubectl get secret` con el parámetro `-o yaml`:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl get secret mi-servicio-web-tls-secret -o yaml
```

&nbsp;

<<<<<<< HEAD
Ahora puedes usar ese Secret para tener Nginx funcionando con HTTPS, y para eso necesitas usar el campo `spec.tls` en el archivo YAML del Pod:
=======
Ahora puedes utilizar este Secreto para ejecutar Nginx con HTTPS, y para ello necesitas utilizar el campo `spec.tls` en el archivo YAML del Pod:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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

<<<<<<< HEAD
Aquí tenemos bastante información nueva, así que vamos por partes.

La primera cosa de la que tenemos que hablar es sobre el `spec.containers`, principalmente sobre los volúmenes, que es el campo `spec.containers.volumeMounts`.

El campo `spec.containers.volumeMounts` se utiliza para montar un volumen en un directorio dentro del contenedor. En nuestro caso, estamos montando dos volúmenes, uno para el archivo de configuración de Nginx, y otro para el certificado TLS y la clave privada.

Y usamos el campo `spec.volumes` para definir los volúmenes que serán utilizados por el Pod, y estamos definiendo dos volúmenes, el `nginx-config-volume` y el `nginx-tls`.

El volumen `nginx-config-volume` es un volumen del tipo `configMap`, y se utiliza para montar el archivo de configuración de Nginx, que está almacenado en el ConfigMap `nginx-config`. El próximo tema es sobre ConfigMaps, así que no te preocupes por eso ahora.

El volumen `nginx-tls` es un volumen del tipo `secret`, y se utiliza para montar el Secret `meu-servico-web-tls-secret`, que contiene el certificado TLS y la clave privada que se utilizarán para configurar HTTPS en Nginx.

Y como estamos configurando un Nginx para usar nuestro Secret, necesitamos hablar de dónde queremos que los archivos del Secret se monten, y para eso usamos el campo `spec.containers.volumeMounts.path` para definir el directorio donde queremos que se monten los archivos del Secret, que en este caso es el directorio `/etc/nginx/tls`.

Dije que el volumen `nginx-config-volume`, es un volumen del tipo `configMap`, eso es una gran introducción para iniciar el próximo tema, que es sobre ConfigMaps! :D

Así que, continuemos con nuestro ejemplo de cómo usar Nginx con HTTPS, pero en el próximo tema sobre ConfigMaps. \o/
=======
Aquí tenemos mucha información nueva, así que vamos por partes.

Lo primero de lo que debemos hablar es sobre `spec.containers`, en particular sobre los volúmenes, que es el campo `spec.containers.volumeMounts`.

El campo `spec.containers.volumeMounts` se utiliza para montar un volumen en un directorio dentro del contenedor. En nuestro caso, estamos montando dos volúmenes, uno para el archivo de configuración de Nginx y otro para el certificado TLS y la clave privada.

Utilizamos el campo `spec.volumes` para definir los volúmenes que se utilizarán en el Pod, y estamos definiendo dos volúmenes, `nginx-config-volume` y `nginx-tls`.

El volumen `nginx-config-volume` es un volumen de tipo `configMap` y se utiliza para montar el archivo de configuración de Nginx, que está almacenado en el ConfigMap `nginx-config`. El próximo tema trata sobre ConfigMaps, así que no te preocupes por eso por ahora.

El volumen `nginx-tls` es un volumen de tipo `secret` y se utiliza para montar el Secret `mi-servicio-web-tls-secret`, que contiene el certificado TLS y la clave privada que se utilizarán para configurar HTTPS en Nginx.

Y como estamos configurando un Nginx para utilizar nuestro Secret, debemos indicar dónde queremos que se monten los archivos del Secret. Para ello, utilizamos el campo `spec.containers.volumeMounts.path` para especificar el directorio en el que queremos que se monten los archivos del Secret, en este caso, el directorio `/etc/nginx/tls`.

Mencioné que el volumen `nginx-config-volume` es un volumen de tipo `configMap`, lo que es una excelente introducción para el próximo tema, que trata sobre ConfigMaps. :D

Por lo tanto, continuaremos con nuestro ejemplo de cómo utilizar Nginx con HTTPS en el próximo tema sobre ConfigMaps. ¡Vamos allá! \o/
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

#### ConfigMaps

Los ConfigMaps se utilizan para almacenar datos de configuración, como variables de entorno, archivos de configuración, etc. Son muy útiles para almacenar datos de configuración que pueden ser utilizados por varios Pods.

<<<<<<< HEAD
Los ConfigMaps son una forma eficiente de desacoplar los parámetros de configuración de las imágenes de contenedores. Esto permite que tengas la misma imagen de contenedor en diferentes entornos, como desarrollo, prueba y producción, con diferentes configuraciones.

Aquí hay algunos puntos importantes sobre el uso de ConfigMaps en Kubernetes:

- Actualizaciones: Los ConfigMaps no se actualizan automáticamente en los pods que los utilizan. Si actualizas un ConfigMap, los pods existentes no recibirán la nueva configuración. Para que un pod reciba la nueva configuración, necesitas recrear el pod.

- Múltiples ConfigMaps: Es posible usar múltiples ConfigMaps para un único pod. Esto es útil cuando tienes diferentes aspectos de la configuración que quieres mantener separados.

- Variables de entorno: Además de montar el ConfigMap en un volumen, también es posible usar el ConfigMap para definir variables de entorno para los contenedores en el pod.

- Inmutabilidad: A partir de la versión 1.19 de Kubernetes, es posible hacer ConfigMaps (y Secrets) inmutables, lo que puede mejorar el rendimiento de tu clúster si tienes muchos ConfigMaps o Secrets.

Como en el ejemplo del capítulo anterior, donde creamos un Pod con Nginx y usamos un ConfigMap para almacenar el archivo de configuración de Nginx, el `ConfigMap` se utiliza para almacenar el archivo de configuración de Nginx, en lugar de almacenar el archivo de configuración dentro del Pod, teniendo así un Pod más limpio y más fácil de mantener. Y claro, siempre es bueno usar las cosas para lo que fueron hechas, y el ConfigMap fue hecho para almacenar datos de configuración.

Continuemos con nuestro ejemplo de cómo usar Nginx con HTTPS, pero ahora usando un ConfigMap para almacenar el archivo de configuración de Nginx.

Vamos a crear el archivo de configuración de Nginx llamado `nginx.conf`, que será utilizado por el ConfigMap:

```bash
events { } # configuración de eventos

http { # configuración del protocolo HTTP, que es el protocolo que Nginx va a usar
  server { # configuración del servidor
    listen 80; # puerto que Nginx va a escuchar
    listen 443 ssl; # puerto que Nginx va a escuchar para HTTPS y pasando el parámetro ssl para habilitar HTTPS
    
    ssl_certificate /etc/nginx/tls/certificado.crt; # ruta del certificado TLS
    ssl_certificate_key /etc/nginx/tls/clave-privada.key; # ruta de la clave privada

    location / { # configuración de la ruta /
      return 200 '¡Bienvenido a Nginx!\n'; # devuelve el código 200 y el mensaje ¡Bienvenido a Nginx!
      add_header Content-Type text/plain; # añade el header Content-Type con el valor text/plain
=======
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
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
    } 
  }
}
```

&nbsp;

<<<<<<< HEAD
He dejado el contenido del archivo anterior con comentarios para facilitar la comprensión.

Lo que el archivo anterior está haciendo es:

- Configurando Nginx para escuchar en los puertos 80 y 443, siendo el puerto 443 utilizado para HTTPS.
- Configurando Nginx para usar el certificado TLS y la clave privada que se encuentran en el directorio `/etc/nginx/tls`.
- Configurando la ruta `/` para devolver el código 200 y el mensaje `¡Bienvenido a Nginx!` con el header `Content-Type` con el valor `text/plain`.

Ahora vamos a crear el ConfigMap `nginx-config` con el archivo de configuración de Nginx:
=======
Dejé el contenido del archivo anterior con comentarios para facilitar la comprensión.

Lo que hace el archivo anterior es:

- Configurar Nginx para escuchar en los puertos 80 y 443, donde el puerto 443 se utiliza para HTTPS.
- Configurar Nginx para utilizar el certificado TLS y la clave privada que se encuentran en el directorio `/etc/nginx/tls`.
- Configurar la ruta `/` para devolver el código de estado 200 y el mensaje `¡Bienvenido a Nginx!` con el encabezado `Content-Type` con el valor `text/plain`.

Ahora crearemos el ConfigMap `nginx-config` con el archivo de configuración de Nginx:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl create configmap nginx-config --from-file=nginx.conf
```

&nbsp;

<<<<<<< HEAD
Muy sencillo, ¿verdad? :)

Lo que estamos haciendo es crear un ConfigMap llamado `nginx-config` con el contenido del archivo `nginx.conf`.
Podemos hacer lo mismo a través de un manifiesto, como en el ejemplo a continuación:
=======
¡Es bastante simple, ¿verdad? :)

Lo que estamos haciendo es crear un ConfigMap llamado `nginx-config` con el contenido del archivo `nginx.conf`.
Podemos hacer lo mismo a través de un manifiesto, como se muestra en el siguiente ejemplo:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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
<<<<<<< HEAD
          return 200 '¡Bienvenido a Nginx!\n';
=======
          return 200 'Bienvenido a Nginx!\n';
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

<<<<<<< HEAD
El archivo es muy similar a los manifiestos de `Secret`, pero con algunas diferencias:

- El campo `kind` es `ConfigMap` en lugar de `Secret`.
- El campo `data` se utiliza para definir el contenido del ConfigMap, y el campo `data` es un mapa de clave-valor, donde la clave es el nombre del archivo y el valor es el contenido del archivo. Usamos el carácter `|` para definir el valor del campo `data` como un bloque de texto, y así podemos definir el contenido del archivo `nginx.conf` sin la necesidad de usar el carácter `\n` para romper las líneas del archivo.

Ahora solo queda aplicar el manifiesto anterior:
=======
El archivo se parece mucho a los manifiestos de `Secret`, pero con algunas diferencias:

- El campo `kind` es `ConfigMap` en lugar de `Secret`.
- El campo `data` se utiliza para definir el contenido del ConfigMap, y el campo `data` es un mapa de clave-valor, donde la clave es el nombre del archivo y el valor es el contenido del archivo. Utilizamos el carácter `|` para definir el valor del campo `data` como un bloque de texto, de esta manera podemos definir el contenido del archivo `nginx.conf` sin necesidad de utilizar el carácter `\n` para separar las líneas del archivo.

Ahora solo tienes que aplicar el manifiesto anterior:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl apply -f nginx-config.yaml
```

&nbsp;

<<<<<<< HEAD
Para ver el contenido del ConfigMap que creamos, basta con ejecutar el comando:
=======
Para ver el contenido del ConfigMap que creamos, simplemente ejecuta el comando:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
kubectl get configmap nginx-config -o yaml
```

&nbsp;

También puedes usar el comando `kubectl describe configmap nginx-config` para ver el contenido del ConfigMap, pero el comando `kubectl get configmap nginx-config -o yaml` es mucho más completo.

<<<<<<< HEAD
Ahora que ya tenemos nuestro `ConfigMap` creado, vamos a aplicar el manifiesto que creamos en el capítulo anterior, voy a pegar aquí el manifiesto para facilitar:
=======
Ahora que ya tenemos nuestro `ConfigMap` creado, vamos a aplicar el manifiesto que creamos en el capítulo anterior. Lo copiaré aquí para facilitar:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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
<<<<<<< HEAD
    - name: nginx-config-volume # nombre del volumen que vamos a usar para montar el archivo de configuración de Nginx
      mountPath: /etc/nginx/nginx.conf # ruta donde se montará el archivo de configuración de Nginx
      subPath: nginx.conf # nombre del archivo de configuración de Nginx
    - name: nginx-tls # nombre del volumen que vamos a usar para montar el certificado TLS y la clave privada
      mountPath: /etc/nginx/tls # ruta donde se montarán el certificado TLS y la clave privada
  volumes: # lista de volúmenes que vamos a usar en el Pod
  - name: nginx-config-volume # nombre del volumen que vamos a usar para montar el archivo de configuración de Nginx
    configMap: # tipo del volumen que vamos a usar
      name: nginx-config # nombre del ConfigMap que vamos a usar
  - name: nginx-tls # nombre del volumen que vamos a usar para montar el certificado TLS y la clave privada
    secret: # tipo del volumen que vamos a usar
      secretName: mi-servicio-web-tls-secret # nombre del Secret que vamos a usar
      items: # lista de archivos que vamos a montar, ya que dentro del secret tenemos dos archivos, el certificado TLS y la clave privada
        - key: tls.crt # nombre del archivo que vamos a montar, nombre que está en el campo `data` del Secret
          path: certificado.crt # nombre del archivo que se montará, nombre que se usará en el campo `ssl_certificate` del archivo de configuración de Nginx
        - key: tls.key # nombre del archivo que vamos a montar, nombre que está en el campo `data` del Secret
          path: clave-privada.key # nombre del archivo que se montará, nombre que se usará en el campo `ssl_certificate_key` del archivo de configuración de Nginx
```

&nbsp;

Ahora solo queda aplicar el manifiesto anterior:
=======
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
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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

<<<<<<< HEAD
El comando anterior hará el `port-forward` del puerto 443 del Service `nginx` al puerto 4443 de tu computador, ¡el `port-forward` salvando nuestra vida una vez más! :)

Vamos a usar `curl` para probar si nuestro Nginx está funcionando:
=======
El comando anterior realizará el `port-forward` del puerto 443 del Service `nginx` al puerto 4443 de tu computadora, ¡el `port-forward` nos está salvando nuevamente! :)

Utilizaremos `curl` para comprobar si nuestro Nginx está funcionando:"
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
curl -k https://localhost:4443

<<<<<<< HEAD
¡Bienvenido a Nginx!
=======
Bienvenido a Nginx!
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
```

&nbsp;

<<<<<<< HEAD
¡Funcionando perfectamente!
Recuerda que este es un ejemplo muy simple, el objetivo aquí es mostrar cómo usar el ConfigMap y el Secret para montar archivos dentro de un Pod. El certificado TLS y la clave privada que usamos aquí son auto-firmados, y no se recomiendan para uso en producción y no son aceptados por los navegadores, pero para probar está genial.

Creo que ya es posible entender cómo funciona el ConfigMap, y recuerda que es posible usar el ConfigMap para montar archivos, pero también es posible usar el ConfigMap para definir variables de entorno, y eso es muy útil cuando necesitas pasar una configuración a un contenedor a través de una variable de entorno.

En caso de que quieras hacer un ConfigMap inmutable, puedes usar el campo `immutable` en el manifiesto del ConfigMap, como en el ejemplo a continuación:
=======
¡Funciona maravillosamente!
Recuerda que este es un ejemplo muy simple; el objetivo aquí es mostrar cómo usar ConfigMap y Secret para montar archivos dentro de un Pod. El certificado TLS y la clave privada que usamos aquí son auto-firmados y no se recomiendan para su uso en producción, ni son aceptados por los navegadores, pero son adecuados para pruebas.

Creo que ya has comprendido cómo funciona ConfigMap, y recuerda que puedes usar ConfigMap no solo para montar archivos, sino también para definir variables de entorno, lo cual es muy útil cuando necesitas pasar una configuración a un contenedor a través de una variable de entorno.

Si deseas hacer que un ConfigMap sea inmutable, puedes utilizar el campo `immutable` en el manifiesto del ConfigMap, como se muestra en el siguiente ejemplo:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
<<<<<<< HEAD
  immutable: true # Convierte el ConfigMap en inmutable
=======
  immutable: true # convierte el ConfigMap en inmutable
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
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
<<<<<<< HEAD
          return 200 '¡Bienvenido a Nginx!\n';
=======
          return 200 'Bienvenido a Nginx!\n';
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

<<<<<<< HEAD
Con esto, no será posible alterar el ConfigMap, y si intentas alterar el ConfigMap, Kubernetes devolverá un error.

En caso de que quieras colocar el ConfigMap en un namespace específico, puedes usar el campo `namespace` en el manifiesto del ConfigMap, como en el ejemplo a continuación:
=======
Con esto, no será posible cambiar el ConfigMap, y si intentas modificarlo, Kubernetes devolverá un error.

Si deseas colocar el ConfigMap en un espacio de nombres específico, puedes utilizar el campo `namespace` en el manifiesto del ConfigMap, como se muestra en el siguiente ejemplo:"
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
<<<<<<< HEAD
  namespace: mi-namespace # deja el ConfigMap en el namespace `mi-namespace`
=======
  namespace: mi-namespace # coloca el ConfigMap en el espacio de nombres mi-namespace
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
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
<<<<<<< HEAD
          return 200 '¡Bienvenido a Nginx!\n';
=======
          return 200 'Bienvenido a Nginx!\n';
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

<<<<<<< HEAD
En fin, creo que ya hemos visto bastante sobre ConfigMap, creo que ya podemos pasar al siguiente tema, ¿verdad? \o/

&nbsp;

#### External Secret Operator

External Secrets Operator es un maestro de los secretos de Kubernetes, capaz de trabajar en perfecta armonía con una amplia variedad de sistemas de gestión de secretos externos. Esto incluye, pero no se limita a, gigantes como AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault e IBM Cloud Secrets Manager.

El papel del ESO es buscar información de esas APIs externas y traerla al escenario de Kubernetes, transformándola en Kubernetes Secrets listos para su uso.

##### El Papel Destacado del ESO

La gran misión del ESO es sincronizar secretos de APIs externas con el entorno de Kubernetes. Para ello, utiliza tres recursos de API personalizados: ExternalSecret, SecretStore y ClusterSecretStore. Estos recursos crean un puente entre Kubernetes y las APIs externas, permitiendo que los secretos sean gestionados y utilizados de manera amigable y eficiente.

Para simplificar, nuestro ESO es el encargado de llevar los Secrets de Kubernetes a un nuevo nivel, permitiéndote utilizar herramientas especializadas en la gestión de secretos, como Hashicorp Vault, por ejemplo, y que ya conoces.

##### Conceptos Clave del External Secrets Operator

Vamos a explorar algunos conceptos fundamentales para nuestro trabajo con el External Secrets Operator (ESO).

##### SecretStore

El SecretStore es un recurso que separa las preocupaciones de autenticación/acceso y los secretos y configuraciones necesarios para las cargas de trabajo. Este recurso está basado en namespaces.

Imagina el SecretStore como un gestor de secretos que conoce la forma de acceder a los datos. Contiene referencias a secretos que mantienen las credenciales para acceder a la API externa.

Aquí hay un ejemplo simplificado de cómo se define el SecretStore:
=======
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
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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

<<<<<<< HEAD
Piensa en un ExternalSecret como una solicitud hecha al gestor de secretos (SecretStore) para buscar un secreto específico. La configuración del ExternalSecret define qué buscar, dónde buscar y cómo formatear el secreto.

Aquí hay un ejemplo simplificado de cómo se define el ExternalSecret:
=======
Imagina un ExternalSecret como una solicitud al administrador de secretos (SecretStore) para recuperar un secreto específico. La configuración del ExternalSecret define qué buscar, dónde buscarlo y cómo formatear el secreto.

Aquí tienes un ejemplo simplificado de cómo se define un ExternalSecret:
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

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

<<<<<<< HEAD
El ClusterSecretStore es un SecretStore global, que puede ser referenciado por todos los namespaces. Puedes usarlo para proporcionar una puerta de acceso central a tu proveedor de secretos. Es como un SecretStore, pero con alcance en todo el cluster, en lugar de solo un namespace.

##### Control de Acceso y Seguridad

El ESO es un operador poderoso con acceso elevado. Crea/lee/actualiza secretos en todos los namespaces y tiene acceso a secretos almacenados en algunas APIs externas. Por lo tanto, es vital asegurar que el ESO tenga solo los privilegios mínimos necesarios y que el SecretStore/ClusterSecretStore sea diseñado cuidadosamente.

Además, considera la utilización del sistema de control de admisión de Kubernetes (como OPA o Kyverno) para un control de acceso más refinado.

Ahora que tenemos una buena comprensión de los conceptos clave, vamos a proceder con la instalación del ESO en Kubernetes.

#### Configurando el External Secrets Operator

Vamos a echar un vistazo a cómo instalar y configurar el External Secrets Operator en Kubernetes.
En este ejemplo, vamos a utilizar el ESO para que Kubernetes pueda acceder a los secretos que están en un cluster Vault.

Antes de comenzar, vamos a entender qué es Vault, en caso de que aún no lo conozcas.

##### ¿Qué es Vault?

HashiCorp Vault es una herramienta para gestionar secretos de manera segura. Te permite almacenar y controlar el acceso a tokens, contraseñas, certificados, claves de cifrado y otra información sensible. En nuestro contexto, Vault se convierte en una solución poderosa para superar los problemas inherentes a la manera en que Kubernetes maneja los Secrets.

##### ¿Por Qué Usar Vault?

Con Vault, puedes centralizar la gestión de secretos, reduciendo la superficie de ataque y minimizando el riesgo de fuga de datos. Vault también ofrece control detallado de políticas de acceso, permitiendo determinar quién puede acceder a qué, cuándo y dónde.

##### Comandos Básicos de Vault

Vault puede ser un poco complejo para los principiantes, pero si ya has trabajado con él, los comandos básicos son relativamente simples.
=======
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
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

**Instalando el Hashicorp Vault**

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vault
```

<<<<<<< HEAD
**Iniciando Vault en Modo Dev**
=======
**Iniciando el Vault en Modo Dev**
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
vault server -dev
```

<<<<<<< HEAD
Este comando inicia Vault en modo de desarrollo, que es útil para fines de aprendizaje y experimentación.

**Configurando el Ambiente**
=======
El comando inicia Vault en modo de desarrollo, lo cual es útil para propósitos de aprendizaje y experimentación.

**Configurando el Entorno**
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
```

<<<<<<< HEAD
Esto establece la variable de entorno `VAULT_ADDR`, apuntando hacia la dirección del servidor Vault.

**Escribiendo Secrets**
=======
Esto configura la variable de entorno `VAULT_ADDR`, apuntando hacia la dirección del servidor de Vault.

**Escribiendo los Secrets**
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
vault kv put secret/my-secret password=my-password
```

<<<<<<< HEAD
Este comando escribe un secreto llamado `my-secret` con la contraseña `my-password`.
=======
Este comando escribe un secreto llamado "my-secret" con la contraseña "my-password".
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

**Leyendo Secrets**

```bash
vault kv get secret/my-secret
```

<<<<<<< HEAD
Este comando lee el secreto llamado `my-secret`.

##### El Vault en el Contexto de Kubernetes

Ahora que ha recordado lo básico de Vault, el siguiente paso es comprender cómo puede trabajar en conjunto con Kubernetes y ESO para mejorar la gestión de secretos.

##### Instalación y Configuración de Vault en Kubernetes

Ahora, vamos a sumergirnos en la parte práctica. Configuraremos Vault en Kubernetes, paso a paso, utilizando Helm. Al final de este proceso, tendremos Vault instalado, configurado y listo para usar.

##### Requisitos Previos
=======
Este comando lee el secreto llamado "my-secret".

##### El Vault en el contexto de Kubernetes

Ahora que ha repasado los conceptos básicos de Vault, el siguiente paso es comprender cómo puede trabajar en conjunto con Kubernetes y ESO para mejorar la gestión de secretos.

##### Instalación y configuración de Vault en Kubernetes

Ahora profundizaremos en la parte práctica. Configuraremos Vault en Kubernetes paso a paso utilizando Helm. Al final de este proceso, tendremos Vault instalado, configurado y listo para su uso.

##### Requisitos previos
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

Antes de comenzar, asegúrese de tener lo siguiente:

1. Una instancia de Kubernetes en funcionamiento.
2. Helm instalado en su máquina local o en su clúster.

<<<<<<< HEAD
##### Instalando y Configurando Vault con Helm

Aquí están los pasos para instalar y configurar Vault utilizando Helm:

**1. Agregue el repositorio de HashiCorp a Helm**
=======
##### Instalación y configuración de Vault con Helm

Aquí están los pasos para instalar y configurar Vault utilizando Helm:

**1. Agregue el repositorio HashiCorp a Helm.**
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

<<<<<<< HEAD
Este comando agrega el repositorio Helm de HashiCorp a nuestra configuración de Helm.
=======
#################
Este comando adiciona o repositório Helm da HashiCorp à nossa configuração do Helm.
>>>>>>> 56019ba70c5320a1b7dc63d54c013d46fef8569a

**2. Instale Vault utilizando Helm**

```bash
helm install vault hashicorp/vault
```

Este comando instala Vault en el clúster Kubernetes.

**3. Inicie una shell interactiva dentro del pod de Vault**

```bash
kubectl exec -ti vault-0 -- sh
```

Este comando inicia una shell interactiva dentro del pod de Vault, lo que permite interactuar directamente con Vault.

**4. Inicialice y desbloquee Vault**

En este punto, es importante que guarde las claves que se generan cuando inicializa su clúster de Vault, ya que serán necesarias para desbloquear Vault. Almacene esta información en un lugar seguro, ya que sin estas claves no podrá desbloquear Vault.

```bash
vault operator init
vault operator unseal
vault login
```

Estos comandos inicializan Vault, quitan el sello y realizan el inicio de sesión.

**5. Cree una política en Vault**

```bash
vault policy write external-secret-operator-policy -<<EOF
path "data/postgres" { 
capabilities = ["read"]
}
EOF
```

Este comando crea una política llamada "external-secret-operator-policy" que otorga permisos de lectura en la ruta "data/postgres".

**6. Cree un token con la política que acaba de definir**

```bash
vault token create -policy="external-secret-operator-policy"
```

Este comando crea un token vinculado a la política "external-secret-operator-policy".

**7. Habilite el almacenamiento de secretos y agregue algunos secretos para realizar pruebas**

```bash
vault secrets enable -path=data kv
vault kv put data/postgres POSTGRES_USER=admin POSTGRES_PASSWORD=123456
```

Estos comandos habilitan el almacenamiento de secretos y agregan un secreto de ejemplo a la ruta "data/postgres".

¡Y eso es todo! Ahora tiene Vault instalado y configurado en su clúster Kubernetes.

##### Agregar el Repositorio del Operador de Secretos Externos a Helm

Antes de instalar ESO, necesitamos agregar el repositorio de External Secrets a Helm. Hágalo con los siguientes comandos:

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
```

##### Instalando el Operador de Secretos Externos

Después de agregar el repositorio, puede instalar ESO con el siguiente comando:

```bash
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true
```

##### Verificación de la Instalación de ESO

Para comprobar si ESO se ha instalado correctamente, puede ejecutar el siguiente comando:

```bash
kubectl get all -n external-secrets
```

##### Creación de un Secreto en Kubernetes

Ahora, necesitamos crear un secreto en Kubernetes que contenga el token de Vault. Hágalo con el siguiente comando:

```bash
kubectl create secret generic vault-token --from-literal=token=SU_TOKEN_DE_VAULT
```

Recuerde reemplazar `SU_TOKEN_DE_VAULT` por el token real que obtuvo de Vault.

Para verificar si el secreto se ha creado correctamente, puede ejecutar el siguiente comando:

```bash
kubectl get secrets
```

##### Configuración del ClusterSecretStore

El siguiente paso es configurar el ClusterSecretStore, que es el recurso que proporcionará una pasarela central para su proveedor de secrets. Para hacerlo, debe crear un archivo llamado `cluster-store.yaml` con el siguiente contenido:

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

Para aplicar esta configuración en Kubernetes, utilice el siguiente comando:

```bash
kubectl apply -f cluster-store.yaml
```

##### Creación de un ExternalSecret

Finalmente, necesitamos crear un ExternalSecret que especifica qué datos buscar en el proveedor de secretos. Para hacerlo, cree un archivo llamado `ex-secrets.yaml` con el siguiente contenido:

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

Para aplicar esta configuración en Kubernetes, utilice el siguiente comando:

```bash
kubectl apply -f ex-secrets.yaml
```

Para verificar la creación del ExternalSecret, puede ejecutar el siguiente comando:

```bash
kubectl get externalsecret
```

Eso es todo. Ha instalado y configurado con éxito el Operador de Secretos Externos en Kubernetes. Recuerde, este es solo un ejemplo de cómo usar ESO para integrar Vault con Kubernetes, pero los mismos principios se aplican a otros proveedores de secretos.

Excelente. Para verificar si la sincronización funcionó correctamente y para usar el secreto en su clúster Kubernetes, puede crear un deployment. Haremos esto creando un archivo `deployment.yaml` que define un deployment de ejemplo. En el siguiente ejemplo, crearemos un deployment de una base de datos PostgreSQL que utiliza el secreto que creamos anteriormente.

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

Este archivo define un deployment de PostgreSQL con una única réplica. Establece dos variables de entorno, `POSTGRES_USER` y `POSTGRES_PASSWORD`, que obtienen sus valores del secreto `postgres-secret` que creamos previamente utilizando el Operador de Secretos Externos.

Para crear el deployment, utilice el siguiente comando:

```bash
kubectl apply -f deployment.yaml
```

Después de ejecutar este comando, Kubernetes creará el deployment e iniciará el contenedor de PostgreSQL. Los valores de `POSTGRES_USER` y `POSTGRES_PASSWORD` se llenarán con los valores del secreto `postgres-secret`.

Para verificar si el deployment se creó con éxito, puede ejecutar el siguiente comando:

```bash
kubectl get deployment
```

## Final del Día 8

Hoy dedicamos el día a dos componentes importantes de Kubernetes: Secrets y ConfigMaps.

En Kubernetes, los Secrets son un recurso que nos permite gestionar información sensible, como contraseñas, tokens OAuth, claves SSH, etc. Debido a su naturaleza sensible, Kubernetes ofrece una serie de características para gestionar los Secrets de manera segura. Aprendimos cómo crear, obtener y describir un Secret, así como cómo eliminarlo. Fuimos un paso más allá al usar un Secret para almacenar un certificado TLS y una clave privada, que luego utilizamos para configurar Nginx para usar HTTPS. Montamos el certificado TLS y la clave privada en un Pod de Nginx utilizando un archivo de manifiesto para definir el Secret.

Luego, exploramos ConfigMaps. Los ConfigMaps son una forma eficiente de separar los parámetros de configuración de las imágenes de los contenedores, lo que permite que una misma imagen de contenedor se ejecute en diferentes entornos, como desarrollo, pruebas y producción, con configuraciones diferentes. Aprendimos a actualizar un ConfigMap, cómo usarlo y cómo definir variables de entorno para los contenedores en un Pod utilizando ConfigMaps. También vimos cómo hacer que los ConfigMaps sean inmutables.

Creamos un archivo de configuración de Nginx utilizando un ConfigMap, que luego utilizamos para configurar un Pod de Nginx. Exploramos cómo montar el ConfigMap en un volumen y cómo utilizar un archivo de manifiesto para definir el ConfigMap.

Además, simplificamos el uso del Operador de Secretos Externos y su integración con Vault.

Finalmente, combinamos ConfigMaps y Secrets para configurar un Pod de Nginx para utilizar HTTPS. Utilizamos el ConfigMap para almacenar el archivo de configuración de Nginx y el Secret para almacenar el certificado TLS y la clave privada.

Esta combinación de ConfigMaps y Secrets nos permite gestionar eficientemente nuestras configuraciones y datos sensibles de manera segura, al tiempo que nos brinda un alto grado de flexibilidad y control sobre nuestras aplicaciones.

¡Y eso es todo por hoy! Nos vemos en el próximo día. ¡Hasta entonces! 👋✌️