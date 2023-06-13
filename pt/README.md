# Descomplicando o Kubernetes

# Descomplicando o Kubernetes

Esse material é parte do treinamento Descomplicando Kubernetes da LINUXtips. Ele foi desenhado para capacitar a pessoa estudante ou a pessoa profissional de TI a trabalhar com o Kubernetes em ambientes criticos.

O Treinamento é composto por material escrito, aulas gravadas em vídeo e aulas ao vivo. Durante o treinamento a pessoa será testada de forma prática, sendo necessário completar desafios reais para dar continuidade no treinamento.

O foco do treinamento é capacitar a pessoa para trabalhar com Kubernetes de maneira eficiente e totalmente preparada para trabalhar em ambientes críticos que utilizam containers.

Fique à vontade para aprender muito sobre Kubernetes utilizando esse livro!

## Conteúdo

<details>
<summary>DAY-1</summary>

- [DAY-1](day-1/README.md#day-1)
  - [O quê preciso saber antes de começar?](day-1/README.md#o-quê-preciso-saber-antes-de-começar)
  - [Inicio da aula do Day-1](day-1/README.md#inicio-da-aula-do-day-1)
    - [Qual a distro GNU/Linux que devo usar?](day-1/README.md#qual-a-distro-gnu/linux-que-devo-usar?)
    - [Alguns sites que devemos visitar](day-1/README.md#alguns-sites-que-devemos-visitar)
    - [O Container Engine](day-1/README.md#o-container-engine)
    - [OCI - Open Container Initiative](day-1/README.md#oci---open-container-initiative)
    - [O Container Runtime](day-1/README.md#o-container-runtime)
    - [O que é o Kubernetes?](day-1/README.md#o-que-é-o-kubernetes?)
      - [Arquitetura do k8s](day-1/README.md#arquitetura-do-k8s)
    - [Instalando e customizando o Kubectl](day-1/README.md#instalando-e-customizando-o-kubectl)
      - [Instalação do Kubectl no GNU/Linux](day-1/README.md#instalação-do-kubectl-no-gnu/linux)
      - [Instalação do Kubectl no MacOS](day-1/README.md#instalação-do-kubectl-no-macos)
      - [Instalação do Kubectl no Windows](day-1/README.md#instalação-do-kubectl-no-windows)
      - [Customizando o kubectl](day-1/README.md#customizando-o-kubectl)
      - [Auto-complete do kubectl](day-1/README.md#auto-complete-do-kubectl)
      - [Criando um alias para o kubectl](day-1/README.md#criando-um-alias-para-o-kubectl)
    - [Criando um cluster Kubernetes](day-1/README.md#criando-um-cluster-kubernetes)
      - [Criando o cluster em sua máquina local](day-1/README.md#criando-o-cluster-em-sua-máquina-local)
        - [Minikube](day-1/README.md#minikube)
          - [Requisitos básicos para o Minikube](day-1/README.md#requisitos-básicos-para-o-minikube)
          - [Instalação do Minikube no GNU/Linux](day-1/README.md#instalação-do-minikube-no-gnu/linux)
          - [Instalação do Minikube no MacOS](day-1/README.md#instalação-do-minikube-no-macos)
          - [Instalação do Minikube no Microsoft Windows](day-1/README.md#instalação-do-minikube-no-microsoft-windows)
          - [Iniciando, parando e excluindo o Minikube](day-1/README.md#iniciando,-parando-e-excluindo-o-minikube)
          - [Ver detalhes sobre o cluster](day-1/README.md#ver-detalhes-sobre-o-cluster)
          - [Descobrindo o endereço do Minikube](day-1/README.md#descobrindo-o-endereço-do-minikube)
          - [Acessando a máquina do Minikube via SSH](day-1/README.md#acessando-a-máquina-do-minikube-via-ssh)
          - [Dashboard do Minikube](day-1/README.md#dashboard-do-minikube)
          - [Logs do Minikube](day-1/README.md#logs-do-minikube)
          - [Remover o cluster](day-1/README.md#remover-o-cluster)
        - [Kind](day-1/README.md#kind)
          - [Instalação no GNU/Linux](day-1/README.md#instalação-no-gnu/linux)
          - [Instalação no MacOS](day-1/README.md#instalação-no-macos)
          - [Instalação no Windows](day-1/README.md#instalação-no-windows)
          - [Instalação no Windows via Chocolatey](day-1/README.md#instalação-no-windows-via-chocolatey)
          - [Criando um cluster com o Kind](day-1/README.md#criando-um-cluster-com-o-kind)
          - [Criando um cluster com múltiplos nós locais com o Kind](day-1/README.md#criando-um-cluster-com-múltiplos-nós-locais-com-o-kind)
    - [Primeiros passos no k8s](day-1/README.md#primeiros-passos-no-k8s)
      - [Verificando os namespaces e pods](day-1/README.md#verificando-os-namespaces-e-pods)
      - [Executando nosso primeiro pod no k8s](day-1/README.md#executando-nosso-primeiro-pod-no-k8s)
      - [Expondo o pod e criando um Service](day-1/README.md#expondo-o-pod-e-criando-um-service)
    - [Limpando tudo e indo para casa](day-1/README.md#limpando-tudo-e-indo-para-casa)

</details>

<details>
<summary>DAY-2</summary>

- [DAY-2](day-2/README.md#day-2)
  - [O que iremos ver hoje?](day-2/README.md#o-que-iremos-ver-hoje)
    - [O que é um Pod?](o-que-e-um-pod?)
    - [Criando um Pod](day-2/README.md#criando-um-pod)
    - [Visualizando detalhes sobre os Pods](day-2/README.md#visualizando-detalhes-sobre-os-pods)
    - [Removendo um Pod](day-2/README.md#removendo-um-pod)
    - [Criando um Pod através de um arquivo YAML](day-2/README.md#criando-um-pod-atraves-de-um-arquivo-yaml)
    - [Visualizando os logs do Pod](day-2/README.md#visualizando-os-logs-do-pod)
    - [Criando um Pod com mais de um container](day-2/README.md#criando-um-pod-com-mais-de-um-container)
  - [Os comandos `attach` e `exec`](day-2/README.md#os-comandos-attach-e-exec)
  - [Criando um container com limites de memória e CPU](day-2/README.md#criando-um-container-com-limites-de-memoria-e-cpu)
  - [Adicionando um volume EmptyDir no Pod](day-2/README.md#adicionando-um-volume-emptydir-no-pod)

</details>

<details>
<summary>DAY-3</summary>

- [DAY-3](day-3/README.md#day-3)
  - [Inicio da aula do Day-3](#inicio-da-aula-do-day-3)
  - [O que iremos ver hoje?](#o-que-iremos-ver-hoje)
  - [O que é um Deployment?](#o-que-é-um-deployment)
    - [Como criar um Deployment?](#como-criar-um-deployment)
      - [O que cada parte do arquivo significa?](#o-que-cada-parte-do-arquivo-significa)
    - [Como aplicar o Deployment?](#como-aplicar-o-deployment)
    - [Como verificar os Pods que o Deployment está gerenciando?](#como-verificar-os-pods-que-o-deployment-está-gerenciando)
    - [Como verificar o ReplicaSet que o Deployment está gerenciando?](#como-verificar-o-replicaset-que-o-deployment-está-gerenciando)
    - [Como verificar os detalhes do Deployment?](#como-verificar-os-detalhes-do-deployment)
    - [Como atualizar o Deployment?](#como-atualizar-o-deployment)
    - [E qual é a estratégia de atualização padrão do Deployment?](#e-qual-é-a-estratégia-de-atualização-padrão-do-deployment)
    - [As estratégias de atualização do Deployment](#as-estratégias-de-atualização-do-deployment)
      - [Estratégia RollingUpdate](#estratégia-rollingupdate)
      - [Estratégia Recreate](#estratégia-recreate)
      - [Fazendo o rollback de uma atualização](#fazendo-o-rollback-de-uma-atualização)
    - [Removendo um Deployment](#removendo-um-deployment)
  - [Conclusão](#conclusão)

</details>

<details>
<summary>DAY-4</summary>

- [DAY-4](day-4/README.md)
- [Inicio da aula do Day-4](day-4/README.md#inicio-da-aula-do-day-4)
- [O que iremos ver hoje?](day-4/README.md#o-que-iremos-ver-hoje)
  - [ReplicaSet](day-4/README.md#replicaset)
    - [O Deployment e o ReplicaSet](day-4/README.md#o-deployment-e-o-replicaset)
    - [Criando um ReplicaSet](day-4/README.md#criando-um-replicaset)
    - [Apagando o ReplicaSet](day-4/README.md#apagando-o-replicaset)
  - [O DaemonSet](day-4/README.md#o-daemonset)
    - [Criando um DaemonSet](day-4/README.md#criando-um-daemonset)
    - [Criando um DaemonSet utilizando o comando kubectl create](day-4/README.md#criando-um-daemonset-utilizando-o-comando-kubectl-create)
    - [Aumentando um node no cluster](day-4/README.md#aumentando-um-node-no-cluster)
    - [Removendo um DaemonSet](day-4/README.md#removendo-um-daemonset)
  - [As Probes do Kubernetes](day-4/README.md#as-probes-do-kubernetes)
    - [O que são as Probes?](day-4/README.md#o-que-sao-as-probes)
    - [Liveness Probe](day-4/README.md#liveness-probe)
    - [Readiness Probe](day-4/README.md#readiness-probe)
    - [Startup Probe](day-4/README.md#startup-probe)
  - [A sua lição de casa](day-4/README.md#a-sua-licao-de-casa)
- [Final do Day-4](day-4/README.md#final-do-day-4)

</details>

<details>
<summary>DAY-5</summary>

- [DAY-5](day-5/README.md#day-5)
- [Conteúdo do Day-5](day-5/README.md#conteúdo-do-day-5)
- [Inicio da aula do Day-5](day-5/README.md#inicio-da-aula-do-day-5)
  - [O que iremos ver hoje?](day-5/README.md#o-que-iremos-ver-hoje)
  - [Instalação de um cluster Kubernetes](day-5/README.md#instalação-de-um-cluster-kubernetes)
    - [O que é um cluster Kubernetes?](day-5/README.md#o-que-é-um-cluster-kubernetes)
    - [Formas de instalar o Kubernetes](day-5/README.md#formas-de-instalar-o-kubernetes)
    - [Criando um cluster Kubernetes com o kubeadm](day-5/README.md#criando-um-cluster-kubernetes-com-o-kubeadm)
      - [Instalando o kubeadm](day-5/README.md#instalando-o-kubeadm)
      - [Desativando o uso do swap no sistema](day-5/README.md#desativando-o-uso-do-swap-no-sistema)
      - [Carregando os módulos do kernel](day-5/README.md#carregando-os-módulos-do-kernel)
      - [Configurando parâmetros do sistema](day-5/README.md#configurando-parâmetros-do-sistema)
      - [Instalando os pacotes do Kubernetes](day-5/README.md#instalando-os-pacotes-do-kubernetes)
      - [Instalando o Docker e o containerd](day-5/README.md#instalando-o-docker-e-o-containerd)
      - [Configurando o containerd](day-5/README.md#configurando-o-containerd)
      - [Habilitando o serviço do kubelet](day-5/README.md#habilitando-o-serviço-do-kubelet)
      - [Configurando as portas](day-5/README.md#configurando-as-portas)
      - [Iniciando o cluster](day-5/README.md#iniciando-o-cluster)
      - [Entendendo o arquivo admin.conf](day-5/README.md#entendendo-o-arquivo-adminconf)
      - [Instalando o Weave Net](day-5/README.md#instalando-o-weave-net)
      - [O que é o CNI?](day-5/README.md#o-que-é-o-cni)
    - [Visualizando detalhes dos nodes](day-5/README.md#visualizando-detalhes-dos-nodes)
  - [A sua lição de casa](day-5/README.md#a-sua-lição-de-casa)
- [Final do Day-5](day-5/README.md#final-do-day-5)

</details>

<details>
<summary>DAY-6</summary>

- [DAY-6](day-6/README.md#day-6)
  - [Conteúdo do Day-6](day-6/README.md#conteúdo-do-day-6)
  - [Inicio da aula do Day-6](day-6/README.md#inicio-da-aula-do-day-6)
    - [O que iremos ver hoje?](day-6/README.md#o-que-iremos-ver-hoje)
      - [O que são volumes?](day-6/README.md#o-que-são-volumes)
        - [EmpytDir](day-6/README.md#empytdir)
        - [Storage Class](day-6/README.md#storage-class)
        - [PV - Persistent Volume](day-6/README.md#pv---persistent-volume)
        - [PVC - Persistent Volume Claim](day-6/README.md#pvc---persistent-volume-claim)
    - [A sua lição de casa](day-6/README.md#a-sua-lição-de-casa)
  - [Final do Day-6](day-6/README.md#final-do-day-6)

</details>

<details>
<summary>DAY-7</summary>

- [DAY-7](day-7/README.md#day-7)
- [Conteúdo do Day-7](day-7/README.md#conteúdo-do-day-7)
  - [O que iremos ver hoje?](day-7/README.md#o-que-iremos-ver-hoje)
    - [O que é um StatefulSet?](day-7/README.md#o-que-é-um-statefulset)
      - [Quando usar StatefulSets?](day-7/README.md#quando-usar-statefulsets)
      - [E como ele funciona?](day-7/README.md#e-como-ele-funciona)
      - [O StatefulSet e os volumes persistentes](day-7/README.md#o-statefulset-e-os-volumes-persistentes)
      - [O StatefulSet e o Headless Service](day-7/README.md#o-statefulset-e-o-headless-service)
      - [Criando um StatefulSet](day-7/README.md#criando-um-statefulset)
      - [Excluindo um StatefulSet](day-7/README.md#excluindo-um-statefulset)
      - [Excluindo um Headless Service](day-7/README.md#excluindo-um-headless-service)
      - [Excluindo um PVC](day-7/README.md#excluindo-um-pvc)
    - [Services](day-7/README.md#services)
      - [Tipos de Services](day-7/README.md#tipos-de-services)
      - [Como os Services funcionam](day-7/README.md#como-os-services-funcionam)
      - [Os Services e os Endpoints](day-7/README.md#os-services-e-os-endpoints)
      - [Criando um Service](day-7/README.md#criando-um-service)
        - [ClusterIP](day-7/README.md#clusterip)
        - [ClusterIP](day-7/README.md#clusterip-1)
        - [LoadBalancer](day-7/README.md#loadbalancer)
        - [ExternalName](day-7/README.md#externalname)
      - [Verificando os Services](day-7/README.md#verificando-os-services)
      - [Verificando os Endpoints](day-7/README.md#verificando-os-endpoints)
      - [Removendo um Service](day-7/README.md#removendo-um-service)
  - [A sua lição de casa](day-7/README.md#a-sua-lição-de-casa)
- [Final do Day-7](day-7/README.md#final-do-day-7)
</details>


<details>
<summary>DAY-8</summary>

- [Descomplicando o Kubernetes](day-8/README.md#descomplicando-o-kubernetes)
  - [DAY-8](day-8/README.md#day-8)
    - [Conteúdo do Day-8](day-8/README.md#conteúdo-do-day-8)
    - [O que iremos ver hoje?](day-8/README.md#o-que-iremos-ver-hoje)
      - [O que são Secrets?](day-8/README.md#o-que-são-secrets)
        - [Como os Secrets funcionam](day-8/README.md#como-os-secrets-funcionam)
        - [Tipos de Secrets](day-8/README.md#tipos-de-secrets)
        - [Antes de criar um Secret, o Base64](day-8/README.md#antes-de-criar-um-secret-o-base64)
        - [Criando nosso primeiro Secret](day-8/README.md#criando-nosso-primeiro-secret)
        - [Usando o nosso primeiro Secret](day-8/README.md#usando-o-nosso-primeiro-secret)
        - [Criando um Secret para armazenar credenciais Docker](day-8/README.md#criando-um-secret-para-armazenar-credenciais-docker)
        - [Criando um Secret TLS](day-8/README.md#criando-um-secret-tls)
      - [ConfigMaps](day-8/README.md#configmaps)
  - [Final do Day-8](day-8/README.md#final-do-day-8)
</details>

<details>
<summary>DAY-9</summary>

</details>

<details>
<summary>DAY-10</summary>

</details>

<details>
<summary>DAY-11</summary>

</details>

&nbsp;

## O treinamento Descomplicando o Kubernetes

Pensamos em fazer um treinamento realmente prático onde a pessoa consiga aprender os conceitos e teoria com excelente didática, utilizando exemplos e desafios práticos para que você consiga executar todo o conhecimento adquirido. Isso é muito importante para que você consiga fixar e explorar ainda mais o conteúdo do treinamento.
E por fim, vamos simular algumas conversas para que fique um pouco mais parecido com o dia-a-dia no ambiente de trabalho.

Durante o treinamento vamos passar por todos os tópicos importantes do Kubernetes, para que no final do treinamento você possua todo conhecimento e também toda a segurança para implementar e administrar o Kubernetes em ambientes críticos e complexos.

Estamos prontos para iniciar a nossa viagem?
&nbsp;

### O conteúdo programático

O conteúdo ainda será ajustado, e no final do treinamento teremos o conteúdo completo.

&nbsp;

### Como adquirir o treinamento?

Para adquirir o treinamento [Descomplicando o Kubernetes](https://www.linuxtips.io/) você deverá ir até a loja da [LINUXtips](https://www.linuxtips.io/).

&nbsp;

## A ideia do formato do treinamento

Ensinar Kubernetes de uma forma mais real, passando todo o conteúdo de forma prática e trazendo uma conexão com o ambiente real de trabalho.

Esse é o primeiro treinamento sobre Kubernetes de forma realmente prática, da vida real. Pois entendemos que prática é o conjunto de entendimento sobre um assunto, seguido de exemplos reais que possam ser reproduzidos e conectando tudo isso com a forma como trabalhamos.

Assim a definição de prática passa a ser um focada em o conhecimento da ferramenta e adicionando a realidade de um profissional no seu dia-a-dia aprendendo uma nova tecnologia, uma nova ferramenta.

Prepare-se para um novo tipo de treinamento, e o melhor, prepare-se para um novo conceito sobre treinamento prático e de aprendizado de tecnologia.
&nbsp;

O conteúdo desse material é dividido em partes chamadas, onde chamamos cada uma de "day" (day_one, day_two, day_three, etc), para facilitar o aprendizado. A ideia é o aluno focar o aprendizado por etapas e por esse motivo recomendamos que ele mude para a próxima parte somente quando estiver totalmente confortável com o conteúdo atual.

Nesse material você terá contato com conteúdos que abordam do nível iniciante ao avançado sobre Kubernetes, e agora que ele se tornou aberto, com a ajuda de todos vamos construir o maior e mais completo material sobre Kubernetes do mundo.

Contamos com sua ajuda para tornar esse material ainda mais completo, colabore! Para contribuir com melhorias no conteúdo, siga as instruções deste [tutorial](CONTRIBUTING.md).

Veja os vídeos sobre Kubernetes, DevOps, Automação e outros assuntos relacionado a tecnologia nos canais da LINUXtips:

* [Canal da LINUXtips no Youtube](https://www.youtube.com/LINUXtips)
* [Canal da LINUXtips na Twitch](https://www.twitch.com/LINUXtips)

Veja os treinamentos disponíveis da LINUXtips:

* [Site Oficial da LINUXtips](https://linuxtips.io/)


Principais links da LINUXtips:

* [Todos os Links da LINUXtips](https://linktr.ee/LINUXtips)


Acesso ao Livro Descomplicando o Kubernetes:  
- [LIVRO - Descomplicando o Kubernetes](SUMMARY.md)