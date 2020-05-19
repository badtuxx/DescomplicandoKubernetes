# Extra

## Sumário

<!-- TOC -->

- [Extra](#extra)
  - [Sumário](#sum%c3%a1rio)
- [Security Context](#security-context)
- [Utilizando o security Context](#utilizando-o-security-context)
- [Capabilities](#capabilities)

<!-- TOC -->

# Security Context

Security Context são um conjunto de configurações onde definimos privilégios e acessos a um pod. Essas configurações incluem:

* Definir o usuário e grupo do container;
* Se o container será um container privilegiado;
* Linux Capabilities;
* Se o container pode escalar privilégios;
* Utilizar SELinux/APPArmor.

# Utilizando o security Context

Para utilizar essa configuração precisamos incluir o bloco ```securityCotext``` no manifesto do pod.

Primeiro vamos definir um usuário e grupo para nosso container através das flags ```runAsUser``` e ```runAsGroup``` o usuário e grupo devem ser informados por UID exemplo 1000.


```
apiVersion: v1
kind: Pod
metadata:
  name: busy-security-user
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - name: sec-busy
    image: busybox
    command: [ "sh", "-c", "sleep 1h" ]
```

No exemplo acima utilizamos o user/grup ID ``1000`` para o container.

Vamos executar o comando ``` kubectl exec busy-security-user -- id ``` no container e verificar com o comando ```id``` nosso usuário e grupo.

```
kubectl exec busy-security-user -- id
```

Output:
```
uid=1000 gid=1000
```

As configurações de ``securityContext`` definidas no container são aplicadas somente a ele, já se são definidas no bloco ``securityContext`` fora de ```containers``` será aplicada para todos containers no manifesto.

```
apiVersion: v1
kind: Pod
metadata:
  name: busy-security-uid
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - name: sec-busy
    image: busybox
    securityContext:
      runAsUser: 2000
      runAsGroup: 2000
    command: [ "sh", "-c", "sleep 1h" ]
```

```
kubectl exec busy-security-user -- id
```

Output:
```
uid=2000 gid=1000
```

As configurações declaradas em containers sempre serão prioritárias e irão sobrescrever as demais.

# Capabilities

Nos sistemas UNIX existem basicamente duas categorias de processos: processos privilegiados que são executados como o UID 0 (root ou superusuario) e os não privilegiados que possuem o UID diferente de 0.

Os processos privilegiados dão "bypass" em todas as verificações do kernel, já os processos não-privilegiados passam por algumas checagens como UID,GID,ACLS.

Começando no kernel 2.2, o Linux dividiu as formas tradicionais de privilégios associados ao superusuários em unidades diferentes, agora conhecidas como ```capabilities```, que podem ser habilitadas e desabilitadas independentemente umas das outras. Essas capacidades são atribuídas por thread.

Um pouco mais sobre capabilities
http://man7.org/linux/man-pages/man7/capabilities.7.html

Para demonstar, vamos fazer um teste tentando alterar a hora de um container:

```
apiVersion: v1
kind: Pod
metadata:
  name: busy-security-cap
spec:
  containers:
  - name: sec-busy
    image: busybox
    command: [ "sh", "-c", "sleep 1h" ]

```

```
kubectl exec busy-security-cap -- date -s "18:00:00"
```

Output
```
date: can't set date: Operation not permitted
```

Adicionando a capabilitie ``SYS_TIME`` no container:

```
apiVersion: v1
kind: Pod
metadata:
  name: busy-security-cap
spec:
  containers:
  - name: sec-busy
    image: busybox
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
    command: [ "sh", "-c", "sleep 1h" ]
```

```
kubectl exec busy-security-cap -- date -s "18:00:00"
```

Output:
```
Sat May 16 18:00:00 UTC 2020
```