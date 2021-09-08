# Dicas CKA/CKAD

 * Estar bem familiarizado com todos objetos dentro do k8s (pod, deploy, replicaSet, jobs, pv, pvc, statefulSet ...)

 * Dominar o kubectl:
    * explain   - ex: ``kubecetl explain deployment --recursive``
    * create    - ex: ``kubectl create nginx --image nginx -o yaml``
    * dry-run   - ex: ``kubectl create nginx --image nginx -o yaml``
    * json-path - ex: ``kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'``

 * Básico no VIM:
    * Copiar
    * Editar
    * Substituir
    * Deletar

 * Dominar um pouco de shell para manipular saídas:
    * ">"
    * ">>"
    * ``awk '{print $}'``
    * ``grep``

 * Gerência de tempo:
    * Não gaste todo seu tempo em uma única questão, se não resolver em 2x tentativas passe para próxima questão e após ver/fazer as outras questões volte nela.

 * Peso das perguntas:
    * Ficar atento com o peso das perguntas pois vão ter perguntar fáceis valendo muito e perguntas extremamente complicadas valendo pouco.

 * Conhecer um pouco do ``SystemD`` e ``Journalctl``:
    * ``systemctl stop|restart|stop|status``
    * ``journalctl -xe``

 * Básico de ETCD para backup e restore:
   * https://github.com/badtuxx/DescomplicandoKubernetes/tree/master/Extras/Manutencao-Cluster-Etcd

 * Experiência em Linux ajuda também nas de troubleshooting:
   * Ver logs
   * Procurar arquivos
   * tmux/screen


 * Fazer alias ajuda a ganhar tempo:
   * ``alias k=kubectl``
   * ``alias kn=kubectl get no``
   * ``alias kp=kubectl get po``

# ETCD

Para a prova do CKA é bem relevante saber como o ETCD funciona.

O assunto do ETCD está relacionado aos 11% do Cluster Maintenance.

Porém, pode ser que você seja obrigado a salvar esse **snapshot** em um diretório específico. Exemplo: ``/tmp/``.

Com isso, o comando ficaria assim:

```
ETCDCTL_API=3 etcdctl \
--cacert /var/lib/minikube/certs/etcd/ca.crt \
--key /var/lib/minikube/certs/etcd/server.key \
--cert /var/lib/minikube/certs/etcd/server.crt \
--endpoints [127.0.0.1:2379]  \
snapshot save /tmp/snapshot.db
```

Para fazer o restore usando o arquivo de backup /tmp/snapshot.db podemos executar os seguintes comandos:

```
ETCDCTL_API=3 etcdctl \
--cacert /var/lib/minikube/certs/etcd/ca.crt \
--key /var/lib/minikube/certs/etcd/server.key \
--cert /var/lib/minikube/certs/etcd/server.crt \
--endpoints 127.0.0.1:2379  \
snapshot restore /tmp/snapshot.db

sudo mv /var/lib/etcd/member /var/lib/etcd/member.old
sudo mv /var/lib/etcd/default.etcd/member /var/lib/etcd/
```

# Referências

A seguir estão alguns links com dicas e questões de estudo para a certificação:

* https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad
* https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad
* https://www.cncf.io/certification/cka/
* https://www.cncf.io/certification/ckad/
* https://blog.nativecloud.dev/what-changes-with-certified-kubernetes-administrator-in-september-2020/
* https://dev.to/aurelievache/tips-about-certified-kubernetes-application-developers-ckad-exam-287g
* https://www.linkedin.com/pulse/kubernetes-certification-cka-ckad-exam-tips-gineesh-madapparambath/?articleId=6662722107232911361
* https://github.com/dgkanatsios/CKAD-exercises
* https://dev.to/liptanbiswas/ckad-practice-questions-4mpn
* https://github.com/twajr/ckad-prep-notes?utm_sq=gi8psj8vrn
* https://medium.com/faun/be-fast-with-kubectl-1-18-ckad-cka-31be00acc443
* https://medium.com/faun/how-to-pass-certified-kubernetes-administrator-cka-exam-on-first-attempt-36c0ceb4c9e
* https://medium.com/@yitaek/getting-kubernetes-certified-the-mostly-free-way-41c8b68c8ed4
