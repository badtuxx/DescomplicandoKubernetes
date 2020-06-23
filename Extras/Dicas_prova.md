## Dicas CKA/CKAD
 * Estar bem familiarizado com todos objetos dentro do k8s (pod, deploy, replicaset, jobs, pv, pvc, statefulset ...)

 * Dominar o kubectl:
    * explain   - ex: kubecetl explain deployment --recursive
    * create    - ex: kubectl crete nginx --image nginx -o yaml 
    * dry-run   - ex: kubectl crete nginx --image nginx -o yaml
    * json-path - ex: kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
 
 * Básico no VIM
    * copiar 
    * editar
    * substituir
    * deletar

 * Dominar um pouco de shell para manipular saídas
    * ">"  
    * ">>" 
    * awk '{print $}'
    * grep 
    
 * Gerencia de tempo
    * Não gaste todo seu tempo em uma única questão, se não resolver em 2x tentativas passe para próxima questão e após ver/fazer as outras questões volte nela.

 * Peso das perguntas
    * Ficar atento com o peso das perguntas pois vão ter perguntar fáceis valendo muito e perguntas extremamente complicadas valendo pouco.

 * Conhecer um pouco do SystemD e Journalctl 
    * systemctl stop,restart,stop,status
    * journalctl -xe

 * Básico de ETCD para backup e restore
   * https://github.com/badtuxx/DescomplicandoKubernetes/tree/master/Extras/Manutencao-Cluster-Etcd

 * Experiencia em Linux ajuda também nas de troubleshooting
   * Ver logs
   * Procurar arquivos
   * tmux/screen
   
    
 * Fazer alias ajuda a ganhar tempo
   * alias k=kubectl
   * alias kn=kubectl get no
   * alias kp=kubectl get po