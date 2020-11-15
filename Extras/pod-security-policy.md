**Pod Security Policy** é um recurso cluster-level que controla aspectos de segurança na especificação de um POD. A finalidade do PodSecurityPolicy é definir uma serie de condições de segurança que devem ser seguidas para que um pod possa ser aceito pelo admission controller.

Com ele é possível controlar os seguintes aspectos:
* Execução de contêineres privilegiados.
* Uso de host namespaces.
* Uso de host networking e portas.
* Uso de tipos de volumes.
* Uso de host filesystem.
* Permitir driver FlexVolume.
* Alocar um FSGroup ao volume mapeado no POD.
* Limitar a "read only" o uso de root file system.
* Os IDs de usuário e grupo do contêiner.
* Restringir a escalação de privilégios de root.
* Linux capabilities.
* Utilizar o SELinux nos contêineres.
* Permitir a montagem de Proc para contêiner.
* Perfil do AppArmor utilizado nos contêineres.
* Perfil do seccomp utilizado nos contêineres.
* Perfil do sysctl utilizado nos contêineres.

---


Habilitando o **PodSecurityPolicy**
Ele é tratado como um recurso adicional por isso não vem habilitado por padrão, para ativá-lo é necessário uma configuração no kube-apiserver:
```
kube-apiserver --enable-admission-plugins=PodSecurityPolicy
```

Listando os plugins ativos:
```
kube-apiserver -h | grep enable-admission-plugins
```
Agora com o PodSecurityPolicy ativo vamos criar nossa primeira regra para vermos como ele funciona na pratica.

---
LAB
---
Primeiro vamos criar dois simples pods do nginx para fazermos os testes, um sendo privilegiado e outro não.
```
kubectl run nginx --image=nginx
kubectl run nginx-privi --image=nginx --privileged
```
Ambos criados com sucesso, com o status "Running" e sem apresentar nenhum tipo de erro. Já podemos deleta-los.
```
kubectl delete pod nginx nginx-privi
```

Vamos criar nossa primeira policy:
```
kubectl create -f- <<EOF 
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: primeirapolicy
spec:
  privileged: false  
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: MustRunAsNonRoot 
  fsGroup:
    rule: RunAsAny
  volumes:
  - '*'
EOF
```
Vamos verificar como ficou:
```
kubectl get podsecuritypolicy
```

Nesta regra estamos aplicando as seguintes configurações:

* privileged: false = Não será permitido contêineres privilegiados.
* seLinux: RunAsAny = É permitido usar qualquer perfil do SELINUX.
* runAsUser: MustRunAsNonRoot = Não é permitido contêineres rodarem como root.
* fsGroup: RunAsAny = É permitido usar qualquer FsGroup.
* volumes: * = Pode ser utilizado qualquer tipo de volume.

Agora vamos configurar nosso RBAC para definir em quais service account serão aplicadas esse perfil.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: psp:primeirapolicy:role
rules:
- apiGroups:
  - policy
  resourceNames:
  - primeirapolicy
  resources:
  - podsecuritypolicies
  verbs:
  - use
```
---
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: psp:primeirapolicy:role:binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: psp:primeirapolicy:role
subjects:
  - kind: ServiceAccount
    name: default
    namespace: default
```

---

Agora vamos tentar criar os mesmos pods que criamos anteriormente.
```
kubectl run nginx-privi --image=nginx
```
Vamos executar um describe para ver o motivo do erro:
```
kubectl describe pod nginx
kubectl run nginx-privi --image=nginx --privileged
```

Nossa policy funcionou, não conseguimos rodar contêineres nem como root e nem privilegiado.

---


Então como vimos com as PSPs conseguimos criar um baseline de configurações de segurança que deve ser respeitado em um deploy garantindo que todos sigam o padrão, com isso elevando o nível de segurança no cluster.
