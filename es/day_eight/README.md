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
        - [Usando o nosso primeiro Secret](#usando-o-nosso-primeiro-secret)
        - [Criando um Secret para armazenar credenciais Docker](#criando-um-secret-para-armazenar-credenciais-docker)
        - [Criando um Secret TLS](#criando-um-secret-tls)
      - [ConfigMaps](#configmaps)
      - [External Secret Operator](#external-secret-operator)
        - [O Papel de Destaque do ESO](#o-papel-de-destaque-do-eso)
        - [Conceitos-Chave do External Secrets Operator](#conceitos-chave-do-external-secrets-operator)
        - [SecretStore](#secretstore)
        - [ExternalSecret](#externalsecret)
        - [ClusterSecretStore](#clustersecretstore)
        - [Controle de Acesso e Segurança](#controle-de-acesso-e-segurança)
      - [Configurando o External Secrets Operator](#configurando-o-external-secrets-operator)
        - [O que é o Vault?](#o-que-é-o-vault)
        - [Por que Usar o Vault?](#por-que-usar-o-vault)
        - [Comandos Básicos do Vault](#comandos-básicos-do-vault)
        - [O Vault no Contexto do Kubernetes](#o-vault-no-contexto-do-kubernetes)
        - [Instalando e Configurando o Vault no Kubernetes](#instalando-e-configurando-o-vault-no-kubernetes)
        - [Pré-requisitos](#pré-requisitos)
        - [Instalando e Configurando o Vault com Helm](#instalando-e-configurando-o-vault-com-helm)
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

Si comparas las cadenas de los campos `username` y `password` del Secret creado utilizando el comando `kubectl create secret` con las cadenas de los campos `username` y `password` del Secret creado utilizando el archivo YAML, notarás que son iguales. Esto sucede porque el comando `kubectl create secret` codifica automáticamente los datos en Base64.

&nbsp;

########################

########################
##### Usando o nosso primeiro Secret

Agora que já temos o nosso primeiro Secret criado, é hora de saber como usa-lo em um Pod.

Nesse nosso primeiro exemplo, somente irei mostrar como usar o Secret em um Pod, mas ainda sem nenhuma "função" especial, apenas para mostrar como usar o Secret.

Para usar o Secret em um Pod, você precisa definir o campo `spec.containers[].env[].valueFrom.secretKeyRef` no arquivo YAML do Pod. Eu estou trazendo o campo nesse formato, para que você possa começar a se familiarizar com esse formato, pois você irá usa-lo bastante para buscar alguma informação mais especifica na linha de comando, usando o comando `kubectl get`, por exemplo.

Voltando ao assunto principal, precisamos criar o nosso Pod, então vamos lá! Crie um arquivo chamado `giropops-pod.yaml` com o seguinte conteúdo:


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: giropops-pod
spec:
  containers:
  - name: giropops-container
    image: nginx
    env: # Inicio da definição das variáveis de ambiente
    - name: USERNAME # Nome da variável de ambiente que será usada no Pod
      valueFrom: # Inicio da definição de onde o valor da variável de ambiente será buscado
        secretKeyRef: # Inicio da definição de que o valor da variável de ambiente será buscado em um Secret, através de uma chave
          name: giropops-secret # Nome do Secret que contém o valor da variável de ambiente que será usada no Pod
          key: username # Nome da chave do campo do Secret que contém o valor da variável de ambiente que será usada no Pod
    - name: PASSWORD # Nome da variável de ambiente que será usada no Pod
      valueFrom: # Inicio da definição de onde o valor da variável de ambiente será buscado
        secretKeyRef: # Inicio da definição de que o valor da variável de ambiente será buscado em um Secret, através de uma chave
          name: giropops-secret # Nome do Secret que contém o valor da variável de ambiente que será usada no Pod
          key: password # Nome da chave do campo do Secret que contém o valor da variável de ambiente que será usada no Pod
```

&nbsp;

Eu adicionei comentários nas linhas que são novas para você, para que você possa entender o que cada linha faz.

Mas vou trazer aqui uma explicação mais detalhada sobre o campo `spec.containers[].env[].valueFrom.secretKeyRef`:

- `spec.containers[].env[].valueFrom.secretKeyRef.name`: o nome do Secret que contém o valor da variável de ambiente que será usada no Pod;

- `spec.containers[].env[].valueFrom.secretKeyRef.key`: a chave do campo do Secret que contém o valor da variável de ambiente que será usada no Pod;

Com isso teremos um Pod, que terá um container chamado `giropops-container`, que terá duas variáveis de ambiente, `USERNAME` e `PASSWORD`, que terão os valores que estão definidos no Secret `giropops-secret`.

Agora vamos criar o Pod usando o comando `kubectl apply`:

```bash
kubectl apply -f giropops-pod.yaml

pod/giropops-pod created
```

&nbsp;

Agora vamos verificar se o Pod foi criado e se os Secrets foram injetados no Pod:

```bash
kubectl get pods

NAME           READY   STATUS    RESTARTS   AGE
giropops-pod   1/1     Running   0          2m
```

&nbsp;

Para verificar se os Secrets foram injetados no Pod, você pode usar o comando `kubectl exec` para executar o comando `env` dentro do container do Pod:

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

Olha lá os nosso Secrets como variáveis de ambiente dentro do container do Pod!

Pronto! Tarefa executada com sucesso! \o/

Agora eu acho que já podemos partir para os próximos tipos de Secrets!

&nbsp;
##############################
##### Criando um Secret para armazenar credenciais Docker

O Docker Hub é um serviço de registro de imagens Docker, que permite que você armazene e compartilhe imagens Docker publicamente ou privadamente. Em 2022, o Docker Hub começou a limitar o número de downloads de imagens Docker públicas para 100 downloads por 6 horas para usuários não autenticados, e para usuários autenticados, o limite é de 200 downloads por 6 horas.

Mas o ponto aqui é que você pode usar o Docker Hub para armazenar imagens Docker privadas, e para isso você precisa de uma conta no Docker Hub, e para acessar a sua conta no Docker Hub, você precisa de um nome de usuário e uma senha. Entendeu onde eu quero chegar? :D

Para que o Kubernetes possa acessar o Docker Hub, você precisa criar um Secret que armazene o nome de usuário e a senha da sua conta no Docker Hub, e depois você precisa configurar o Kubernetes para usar esse Secret.

Quando você executa `docker login` e tem a sua autenticação bem sucedida, o Docker cria um arquivo chamado `config.json` no diretório `~/.docker/` do seu usuário, e esse arquivo contém o nome de usuário e a senha da sua conta no Docker Hub, e é esse arquivo que você precisa usar para criar o seu Secret.

Primeiro passo é pegar o conteúdo do seu arquivo `config.json` e codificar em base64, e para isso você pode usar o comando `base64`:

```bash
base64 ~/.docker/config.json

QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```

&nbsp;

Então vamos lá! Crie um arquivo chamado `dockerhub-secret.yaml` com o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-hub-secret # nome do Secret
type: kubernetes.io/dockerconfigjson # tipo do Secret, neste caso é um Secret que armazena credenciais Docker
data:
  .dockerconfigjson: |  # substitua este valor pelo conteúdo do seu arquivo config.json codificado em base64
    QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```

&nbsp;

O que temos de novo aqui é no campo `type`, que define o tipo do Secret, e neste caso é um Secret que armazena credenciais Docker, e no campo `data` temos o campo `dockerconfigjson`, que é o nome do campo do Secret que armazena o conteúdo do arquivo `config.json` codificado em base64.

Agora vamos criar o Secret usando o comando `kubectl apply`:

```bash
kubectl apply -f dockerhub-secret.yaml

secret/docker-hub-secret created
```

&nbsp;

Para listar o Secret que acabamos de criar, você pode usar o comando `kubectl get`:

```bash
kubectl get secrets

NAME                TYPE                             DATA   AGE
docker-hub-secret   kubernetes.io/dockerconfigjson   1      1s
```

&nbsp;

Secret criada, agora já podemos testar o acesso ao Docker Hub!

Agora o Kubernetes já tem acesso ao Docker Hub, e você pode usar o Kubernetes para fazer o pull de imagens Docker privadas do Docker Hub.

Um coisa importante, sempre quando você precisar criar um Pod que precise utilizar uma imagem Docker privada do Docker Hub, você precisa configurar o Pod para usar o Secret que armazena as credenciais do Docker Hub, e para isso você precisa usar o campo `spec.imagePullSecrets` no arquivo YAML do Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meu-pod
spec:
  containers:
  - name: meu-container
    image: minha-imagem-privada
  imagePullSecrets: # campo que define o Secret que armazena as credenciais do Docker Hub
  - name: docker-hub-secret # nome do Secret
```

&nbsp;

Perceba a utilização do campo `spec.imagePullSecrets` no arquivo YAML do Pod, e o campo `name` que define o nome do Secret que armazena as credenciais do Docker Hub. É somente isso que você precisa fazer para que o Kubernetes possa acessar o Docker Hub.


&nbsp;

##### Criando um Secret TLS

O Secret `kubernetes.io/tls`, é usado para armazenar certificados TLS e chaves privadas. Eles são usados para fornecer segurança na comunicação entre os serviços no Kubernetes. Por exemplo, você pode usar um Secret TLS para configurar o HTTPS no seu serviço web.

Para criar um Secret TLS, você precisa ter um certificado TLS e uma chave privada, e você precisa codificar o certificado e a chave privada em base64, para então criar o Secret.

Vamos criar um Secret TLS para o nosso serviço web, mas para isso, você precisa ter um certificado TLS e uma chave privada antes de mais nada.

Para criar um certificado TLS e uma chave privada, você pode usar o comando `openssl`:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt
```

&nbsp;


No comando acima, estamos criando um certificado TLS e uma chave privada, e o certificado e a chave privada serão armazenados nos arquivos `certificado.crt` e `chave-privada.key`, respectivamente. Você pode substituir os nomes dos arquivos por qualquer nome que você quiser.
Estamos usando o comando `openssl` para criar um certificado TLS auto-assinado, e para isso você precisa responder algumas perguntas, como o país, estado, cidade, etc. Você pode responder qualquer coisa, não tem problema. Esse certificado TLS auto-assinado é apenas para fins de teste, e não deve ser usado em produção. Estamos passando o parâmetro `-nodes` para que a chave privada não seja criptografada com uma senha, e o parâmetro `-days` para definir a validade do certificado TLS, que neste caso é de 365 dias. Já o parâmetro `-newkey` é usado para definir o algoritmo de criptografia da chave privada, que neste caso é o `rsa:2048`, que é um algoritmo de criptografia assimétrica que usa chaves de 2048 bits.


Eu não quero entrar em detalhes sobre como o que é um certificado TLS e uma chave privada, mas, basicamente, um certificado TLS (Transport Layer Security) é usado para autenticar e estabelecer uma conexão segura entre duas partes, como um cliente e um servidor. Ele contém informações sobre a entidade para a qual foi emitido e a entidade que o emitiu, bem como a chave pública da entidade para a qual foi emitido.

A chave privada, por outro lado, é usada para descriptografar a informação que foi criptografada com a chave pública. Ela deve ser mantida em segredo e nunca compartilhada, pois qualquer pessoa com acesso à chave privada pode decifrar a comunicação segura. Juntos, o certificado TLS e a chave privada formam um par de chaves que permite a autenticação e a comunicação segura entre as partes.

Entendido? Espero que sim, porque eu não vou entrar em mais detalhes sobre isso. hahaha

Agora vamos voltar o foco na criação do Secret TLS.

Com o certificado TLS e a chave privada criados, vamos criar o nosso Secret, é somente para mudar um pouco, vamos criar o Secret usando o comando `kubectl apply`:

```bash
kubectl create secret tls meu-servico-web-tls-secret --cert=certificado.crt --key=chave-privada.key

secret/meu-servico-web-tls-secret created
```

&nbsp;

Vamos ver se o Secret foi criado:

```bash
kubectl get secrets
NAME                         TYPE                             DATA   AGE
meu-servico-web-tls-secret   kubernetes.io/tls                2      4s
```

&nbsp;

Sim, o Secret está lá e é do tipo `kubernetes.io/tls`.

Caso você queira ver o conteúdo do Secret, você pode usar o comando `kubectl get secret` com o parâmetro `-o yaml`:

```bash
kubectl get secret meu-servico-web-tls-secret -o yaml
```

&nbsp;

Agora você pode usar esse Secret para ter o Nginx rodando com HTTPS, e para isso você precisa usar o campo `spec.tls` no arquivo YAML do Pod:

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
        secretName: meu-servico-web-tls-secret
        items:
          - key: certificado.crt
            path: certificado.crt
          - key: chave-privada.key
            path: chave-privada.key
```

&nbsp;

Aqui temos bastante informação nova, então vamos por partes.

Primeira coisa que temos que falar é sobre o `spec.containers`, principalmente sobre os volumes, que é o campo `spec.containers.volumeMounts`. 

O campo `spec.containers.volumeMounts` é usado para montar um volume em um diretório dentro do container. No nosso caso, estamos montando dois volumes, um para o arquivo de configuração do Nginx, e outro para o certificado TLS e a chave privada.

E usamos o campo `spec.volumes` para definir os volumes que serão usados pelo Pod, e estamos definindo dois volumes, o `nginx-config-volume` e o `nginx-tls`.

O volume `nginx-config-volume` é um volume do tipo `configMap`, e ele é usado para montar o arquivo de configuração do Nginx, que está armazenado no ConfigMap `nginx-config`. O próximo tópico é sobre ConfigMaps, então não se preocupe com isso agora.

Já o volume `nginx-tls` é um volume do tipo `secret`, e ele é usado para montar o Secret `meu-servico-web-tls-secret`, que contém o certificado TLS e a chave privada que serão usados para configurar o HTTPS no Nginx.

E como estamos configurando um Nginx para usar o nosso Secret, precisamos falar onde queremos que os arquivos do Secret sejam montados, e para isso usamos o campo `spec.containers.volumeMounts.path` para definir o diretório onde queremos que os arquivos do Secret sejam montados, que neste caso é o diretório `/etc/nginx/tls`.

Falei que o volume `nginx-config-volume`, é um volume do tipo `configMap`, isso é uma ótima deixa para eu iniciar o próximo tópico, que é sobre ConfigMaps! :D

Sendo assim, bora continuar o nosso exemplo de como usar o Nginx com HTTPS, mas no próximo tópico sobre ConfigMaps. \o/


#### ConfigMaps

ConfigMaps são usados para armazenar dados de configuração, como variáveis de ambiente, arquivos de configuração, etc. Eles são muito úteis para armazenar dados de configuração que podem ser usados por vários Pods.

Os ConfigMaps são uma maneira eficiente de desacoplar os parâmetros de configuração das imagens de container. Isso permite que você tenha a mesma imagem de container em diferentes ambientes, como desenvolvimento, teste e produção, com diferentes configurações.

Aqui estão alguns pontos importantes sobre o uso de ConfigMaps no Kubernetes:

- Atualizações: Os ConfigMaps não são atualizados automaticamente nos pods que os utilizam. Se você atualizar um ConfigMap, os pods existentes não receberão a nova configuração. Para que um pod receba a nova configuração, você precisa recriar o pod.

- Múltiplos ConfigMaps: É possível usar múltiplos ConfigMaps para um único pod. Isso é útil quando você tem diferentes aspectos da configuração que quer manter separados.

- Variáveis de ambiente: Além de montar o ConfigMap em um volume, também é possível usar o ConfigMap para definir variáveis de ambiente para os containers no pod.

- Imutabilidade: A partir da versão 1.19 do Kubernetes, é possível tornar ConfigMaps (e Secrets) imutáveis, o que pode melhorar o desempenho de sua cluster se você tiver muitos ConfigMaps ou Secrets.


Como no exemplo do capítulo anterior, onde criamos um Pod com o Nginx, e usamos um ConfigMap para armazenar o arquivo de configuração do Nginx, o `ConfigMap` é usado para armazenar o arquivo de configuração do Nginx, ao invés de armazenar o arquivo de configuração dentro do Pod, tendo assim um Pod mais limpo e mais fácil de manter. E claro, sempre é bom usar as coisas para o que elas foram feitas, e o ConfigMap foi feito para armazenar dados de configuração.

Bora continuar o nosso exemplo de como usar o Nginx com HTTPS, mas agora usando um ConfigMap para armazenar o arquivo de configuração do Nginx.

Vamos criar o arquivo de configuração do Nginx chamado `nginx.conf`, que vai ser usado pelo ConfigMap:

```bash
events { } # configuração de eventos

http { # configuração do protocolo HTTP, que é o protocolo que o Nginx vai usar
  server { # configuração do servidor
    listen 80; # porta que o Nginx vai escutar
    listen 443 ssl; # porta que o Nginx vai escutar para HTTPS e passando o parâmetro ssl para habilitar o HTTPS
    
    ssl_certificate /etc/nginx/tls/certificado.crt; # caminho do certificado TLS
    ssl_certificate_key /etc/nginx/tls/chave-privada.key; # caminho da chave privada

    location / { # configuração da rota /
      return 200 'Bem-vindo ao Nginx!\n'; # retorna o código 200 e a mensagem Bem-vindo ao Nginx!
      add_header Content-Type text/plain; # adiciona o header Content-Type com o valor text/plain
    } 
  }
}
```

&nbsp;

Eu deixei o conteúdo do arquivo acima com comentários, para facilitar o entendimento.

O que o arquivo acima está fazendo é:

- Configurando o Nginx para escutar as portas 80 e 443, sendo que a porta 443 vai ser usada para o HTTPS.
- Configurando o Nginx para usar o certificado TLS e a chave privada que estão no diretório `/etc/nginx/tls`.
- Configurando a rota `/` para retornar o código 200 e a mensagem `Bem-vindo ao Nginx!` com o header `Content-Type` com o valor `text/plain`.


Agora vamos criar o ConfigMap `nginx-config` com o arquivo de configuração do Nginx:

```bash
kubectl create configmap nginx-config --from-file=nginx.conf
```

&nbsp;

Simples demais, não? :)

O que estamos fazendo é criar um ConfigMap chamado `nginx-config` com o conteúdo do arquivo `nginx.conf`.
Podemos fazer a mesma coisa através de um manifesto, como no exemplo abaixo:

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
        ssl_certificate_key /etc/nginx/tls/chave-privada.key;

        location / {
          return 200 'Bem-vindo ao Nginx!\n';
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

O arquivo é bem parecido com os manifestos do `Secret`, mas com algumas diferenças:

- O campo `kind` é `ConfigMap` ao invés de `Secret`.
- O campo `data` é usado para definir o conteúdo do ConfigMap, e o campo `data` é um mapa de chave-valor, onde a chave é o nome do arquivo e o valor é o conteúdo do arquivo. Usamos o caractere `|` para definir o valor do campo `data` como um bloco de texto, e assim podemos definir o conteúdo do arquivo `nginx.conf` sem a necessidade de usar o caractere `\n` para quebrar as linhas do arquivo.

Agora é só aplicar o manifesto acima:

```bash
kubectl apply -f nginx-config.yaml
```

&nbsp;

Para ver o conteúdo do ConfigMap que criamos, bastar executar o comando:

```bash
kubectl get configmap nginx-config -o yaml
```

&nbsp;

Você também pode usar o comando `kubectl describe configmap nginx-config` para ver o conteúdo do ConfigMap, mas o comando `kubectl get configmap nginx-config -o yaml` é bem mais completo.

Agora que já temos o nosso `ConfigMap` criado, vamos aplicar o manifesto que criamos no capítulo anterior, vou colar aqui o manifesto para facilitar:

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
    - name: nginx-config-volume # nome do volume que vamos usar para montar o arquivo de configuração do Nginx
      mountPath: /etc/nginx/nginx.conf # caminho onde o arquivo de configuração do Nginx vai ser montado
      subPath: nginx.conf # nome do arquivo de configuração do Nginx
    - name: nginx-tls # nome do volume que vamos usar para montar o certificado TLS e a chave privada
      mountPath: /etc/nginx/tls # caminho onde o certificado TLS e a chave privada vão ser montados
  volumes: # lista de volumes que vamos usar no Pod
  - name: nginx-config-volume # nome do volume que vamos usar para montar o arquivo de configuração do Nginx
    configMap: # tipo do volume que vamos usar
      name: nginx-config # nome do ConfigMap que vamos usar
  - name: nginx-tls # nome do volume que vamos usar para montar o certificado TLS e a chave privada
    secret: # tipo do volume que vamos usar
      secretName: meu-servico-web-tls-secret # nome do Secret que vamos usar
      items: # lista de arquivos que vamos montar, pois dentro da secret temos dois arquivos, o certificado TLS e a chave privada
        - key: tls.crt # nome do arquivo que vamos montar, nome que está no campo `data` do Secret
          path: certificado.crt # nome do arquivo que vai ser montado, nome que vai ser usado no campo `ssl_certificate` do arquivo de configuração do Nginx
        - key: tls.key # nome do arquivo que vamos montar, nome que está no campo `data` do Secret
          path: chave-privada.key # nome do arquivo que vai ser montado, nome que vai ser usado no campo `ssl_certificate_key` do arquivo de configuração do Nginx
```

&nbsp;

Agora é só aplicar o manifesto acima:

```bash
kubectl apply -f nginx.yaml
```

&nbsp;

Listando os Pods:

```bash
kubectl get pods
```

&nbsp;

Agora precisamos criar um Service para expor o Pod que criamos:

```bash
kubectl expose pod nginx
```

&nbsp;

Listando os Services:

```bash
kubectl get services
```

&nbsp;

Bora fazer o `port-forward` para testar se o nosso Nginx está funcionando:

```bash
kubectl port-forward service/nginx 4443:443
```

&nbsp;

O comando acima vai fazer o `port-forward` da porta 443 do Service `nginx` para a porta 4443 do seu computador, o `port-forward` salvando a nossa vida novamente! :)

Vamos usar o `curl` para testar se o nosso Nginx está funcionando:

```bash
curl -k https://localhost:4443

Bem-vindo ao Nginx!
```

&nbsp;

Funcionando lindamente!
Lembre-se que esse é um exemplo bem simples, o objetivo aqui é mostrar como usar o ConfigMap e o Secret para montar arquivos dentro de um Pod. O certificado TLS e a chave privada que usamos aqui são auto-assinados, e não são recomendados para uso em produção e não são aceitos pelos navegadores, mas para testar está ótimo.

Acho que já deu para entender como funciona o ConfigMap, e lembre-se que é possível usar o ConfigMap para montar arquivos, mas também é possível usar o ConfigMap para definir variáveis de ambiente, e isso é muito útil quando você precisa passar uma configuração para um container através de uma variável de ambiente.

Caso você queira tornar um ConfigMap imutável, você pode usar o campo `immutable` no manifesto do ConfigMap, como no exemplo abaixo:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  immutable: true # torna o ConfigMap imutável
data:
  nginx.conf: |
    events { }

    http {
      server {
        listen 80;
        listen 443 ssl;

        ssl_certificate /etc/nginx/tls/certificado.crt;
        ssl_certificate_key /etc/nginx/tls/chave-privada.key;

        location / {
          return 200 'Bem-vindo ao Nginx!\n';
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;

Com isso, não será possível alterar o ConfigMap, e se você tentar alterar o ConfigMap, o Kubernetes vai retornar um erro.

Caso você queira deixar o ConfigMap em uma namespace específica, você pode usar o campo `namespace` no manifesto do ConfigMap, como no exemplo abaixo:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: minha-namespace # deixa o ConfigMap na namespace `minha-namespace`
data:
  nginx.conf: |
    events { }

    http {
      server {
        listen 80;
        listen 443 ssl;

        ssl_certificate /etc/nginx/tls/certificado.crt;
        ssl_certificate_key /etc/nginx/tls/chave-privada.key;

        location / {
          return 200 'Bem-vindo ao Nginx!\n';
          add_header Content-Type text/plain;
        }
      }
    }
```

&nbsp;


Enfim, acho que já vimos bastante coisa sobre ConfigMap, acho que já podemos ir para o próximo assunto, certo? \o/

&nbsp;



#### External Secret Operator

External Secrets Operator é um maestro dos segredos do Kubernetes, capaz de trabalhar em perfeita harmonia com uma grande variedade de sistemas de gerenciamento de segredos externos. Isso inclui, mas não se limita a, gigantes como AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault e IBM Cloud Secrets Manager.

O papel do ESO é buscar informações dessas APIs externas e trazer para o palco do Kubernetes, transformando-as em Kubernetes Secrets prontos para uso.

##### O Papel de Destaque do ESO

A grande missão do ESO é sincronizar segredos de APIs externas para o ambiente do Kubernetes. Para tanto, ele se utiliza de três recursos de API personalizados: ExternalSecret, SecretStore e ClusterSecretStore. Estes recursos criam uma ponte entre o Kubernetes e as APIs externas, permitindo que os segredos sejam gerenciados e utilizados de maneira amigável e eficiente.

Para deixar simples, o nosso ESO é o cara responsável por levar os Secrets do Kubernetes para um novo patamar, permitindo que você utilize as ferramentas que são especializadas em gerenciar segredos, como o Hashicorp Vault, por exemplo, e que você já conhece.

##### Conceitos-Chave do External Secrets Operator

Vamos explorar alguns conceitos fundamentais para o nosso trabalho com o External Secrets Operator (ESO).

##### SecretStore

O SecretStore é um recurso que separa as preocupações de autenticação/acesso e os segredos e configurações necessários para as cargas de trabalho. Este recurso é baseado em namespaces.

Imagine o SecretStore como um gerente de segredos que conhece a forma como acessar os dados. Ele contém referências a segredos que mantêm as credenciais para acessar a API externa.

Aqui está um exemplo simplificado de como o SecretStore é definido:

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

Um ExternalSecret declara quais dados buscar e tem uma referência ao SecretStore, que sabe como acessar esses dados. O controlador usa esse ExternalSecret como um plano para criar segredos.

Pense em um ExternalSecret como um pedido feito ao gerente de segredos (SecretStore) para buscar um segredo específico. A configuração do ExternalSecret define o que buscar, onde buscar e como formatar o segredo.

Aqui está um exemplo simplificado de como o ExternalSecret é definido:

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

O ClusterSecretStore é um SecretStore global, que pode ser referenciado por todos os namespaces. Você pode usá-lo para fornecer um gateway central para seu provedor de segredos. É como um SecretStore, mas com alcance em todo o cluster, ao invés de apenas um namespace.

##### Controle de Acesso e Segurança

O ESO é um operador poderoso com acesso elevado. Ele cria/lê/atualiza segredos em todos os namespaces e tem acesso a segredos armazenados em algumas APIs externas. Portanto, é vital garantir que o ESO tenha apenas os privilégios mínimos necessários e que o SecretStore/ClusterSecretStore seja projetado com cuidado.

Além disso, considere a utilização do sistema de controle de admissão do Kubernetes (como OPA ou Kyverno) para um controle de acesso mais refinado.

Agora que temos um bom entendimento dos conceitos-chave, vamos prosseguir para a instalação do ESO no Kubernetes.


#### Configurando o External Secrets Operator

Vamos dar uma olhada em como instalar e configurar o External Secrets Operator no Kubernetes.
Nesse exemplo nós iremos utilizar o ESO para que o Kubernetes possa acessar os segregos que estão em um cluster Vault.

Antes de começar, vamos entender o que é o Vault, caso você ainda não conheça.

##### O que é o Vault?

HashiCorp Vault é uma ferramenta para gerenciar segredos de maneira segura. Ele permite que você armazene e controle o acesso a tokens, senhas, certificados, chaves de criptografia e outras informações sensíveis. No nosso contexto, o Vault se torna uma solução poderosa para superar os problemas inerentes à maneira como o Kubernetes lida com os Secrets.

##### Por que Usar o Vault?

Com o Vault, você pode centralizar a gestão de segredos, reduzindo a superfície de ataque e minimizando o risco de vazamento de dados. O Vault também oferece controle detalhado de políticas de acesso, permitindo determinar quem pode acessar o que, quando e onde.

##### Comandos Básicos do Vault

O Vault pode ser um pouco complexo para os novatos, mas se você já trabalhou com ele, os comandos básicos são relativamente simples.

**Instalando o Hashicorp Vault**

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vault
```

**Iniciando o Vault em Modo Dev**

```bash
vault server -dev
```

Este comando inicia o Vault em modo de desenvolvimento, que é útil para fins de aprendizado e experimentação.

**Configurando o Ambiente**

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
```

Isso define a variável de ambiente `VAULT_ADDR`, apontando para o endereço do servidor Vault.

**Escrevendo Secrets**

```bash
vault kv put secret/my-secret password=my-password
```

Este comando escreve um segredo chamado "my-secret" com a senha "my-password".

**Lendo Secrets**

```bash
vault kv get secret/my-secret
```

Este comando lê o segredo chamado "my-secret".

##### O Vault no Contexto do Kubernetes

Agora que você se lembrou do básico do Vault, a próxima etapa é entender como ele pode trabalhar em conjunto com o Kubernetes e o ESO para aprimorar a gestão de segredos.


##### Instalando e Configurando o Vault no Kubernetes

Vamos agora mergulhar na parte prática. Vamos configurar o Vault no Kubernetes, passo a passo, utilizando o Helm. No final deste processo, teremos o Vault instalado, configurado e pronto para o uso.

##### Pré-requisitos

Antes de começar, certifique-se de que você tem o seguinte:

1. Uma instância do Kubernetes em execução.
2. O Helm instalado em sua máquina local ou no seu cluster.

##### Instalando e Configurando o Vault com Helm

Aqui estão os passos para instalar e configurar o Vault usando o Helm:

**1. Adicione o repositório HashiCorp ao Helm**

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

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
