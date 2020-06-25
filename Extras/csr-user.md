## Criando um usuario no Kubernetes 

Primeiro para criar um usuario no Kuberntes vamos precissar gerar um CSR para o usuario, nosso usuario será o linuxtips e faz parte do time de sysadm

```
openssl req -new -newkey rsa:4096 -nodes -keyout linuxtips.key -out linuxtips.csr -subj "/CN=linuxtips/O=sysadm"
```

Agora vamos fazer o CSR no cluster

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

Vamos ver o csr gerado:
```
kubectl get csr
```

O mesmo está com o status Pending, vamos aprova-lo

```
kubectl certificate approve linuxtips-csr
```

Agora vamos pegar o certificado assinado do csr que fizemos:

```
kubectl get csr linuxtips-csr -o jsonpath='{.status.certificate}' | base64 --decode > linuxtips.crt
```

Vamos pegar o CA do nosso config atual.

```
kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > ca.crt
```

Feito isso vamos montar nosso kubeconfig para o novo usario:
```
kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=ca.crt --kubeconfig=linuxtips-config --embed-certs
```

```
kubectl config set-credentials linuxtips --client-certificate=linuxtips.crt --client-key=linuxtips.key --embed-certs --kubeconfig=linuxtips-config
```

```
kubectl config set-context linuxtips --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}')  --user=linuxtips --kubeconfig=linuxtips-config
```

```
kubectl config use-context linuxtips --kubeconfig=linuxtips-config
```

```
kubectl version --kubeconfig=bob-k8s-config
```