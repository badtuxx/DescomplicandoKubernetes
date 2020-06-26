## Criando um usuário no Kubernetes 

Para criar um usuário no Kubernetes, vamos precisar gerar um CSR para o usuario. O usuário que vamos utilizar como exemplo é o linuxtips.

Comando para gerar o CSR:

```
openssl req -new -newkey rsa:4096 -nodes -keyout linuxtips.key -out linuxtips.csr -subj "/CN=linuxtips"
```

Agora vamos fazer o request do CSR no cluster:

``` 
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: linuxtips-csr
spec:
  groups:
  - system:authenticated
  request: $(cat linuxtips.csr | base64 | tr -d '\n')
  usages:
  - client auth
``` 

Para ver os CSR:

```
kubectl get csr
```

O mesmo está com o status Pending, vamos aprová-lo

```
kubectl certificate approve linuxtips-csr
```

Agora o certificado foi assinado pela CA do cluster, para pegar o certificado assinado vamos usar o seguinte comando:

```
kubectl get csr linuxtips-csr -o jsonpath='{.status.certificate}' | base64 --decode > linuxtips.crt
```

Será necessário para a configuração do kubeconf a CA do cluster, para obtê-lá vamos extrai-lá do kubeconf atual que estamos utilizando:

```
kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > ca.crt
```

Feito isso vamos montar nosso kubeconfig para o novo usuário:

Vamos pegar as informações de IP cluster:

```
kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=ca.crt --kubeconfig=linuxtips-config --embed-certs
```
Agora setando as confs de user e key:
```
kubectl config set-credentials linuxtips --client-certificate=linuxtips.crt --client-key=linuxtips.key --embed-certs --kubeconfig=linuxtips-config
```

Agora definindo  e setando o context:

```
kubectl config set-context linuxtips --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}')  --user=linuxtips --kubeconfig=linuxtips-config
```

```
kubectl config use-context linuxtips --kubeconfig=linuxtips-config
```
Vamos ver um teste
```
kubectl version --kubeconfig=bob-k8s-config
```

Pronto ! Agora só associar um role com as permissões desejadas para o usuário