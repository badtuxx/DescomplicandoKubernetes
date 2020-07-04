# Descomplicando o Kubernetes

O conteúdo desse material é dividido em 06 partes. (day-1 até o day-6)

O material é dividido em 06 partes justamente para facilitar o aprendizado. A ídeia é o aluno focar o aprendizado por etapas, e por esse motivo recomendamos que ele mude para a próxima parte somente quando estiver totalmente confortável com o conteúdo atual.

Nesse material você terá contato com conteúdo do iniciante ao avançado sobre Kubernetes, e agora que ele se tornou aberto, com a ajuda de todos vamos construir o maior e mais completo material sobre Kubernetes do mundo.

Contamos com sua ajuda para tornar esse material ainda mais completo, colabore!

<!-- TOC -->

- [Descomplicando o Kubernetes](#descomplicando-o-kubernetes)
- [Sobre](#sobre)

<!-- TOC -->

# Sobre

O conteúdo deste repositório inicialmente era privado e pertencia a [LinuxTips](https://www.linuxtips.io), onde somente os alunos do curso [Descomplicando o Kubernetes](https://www.linuxtips.io/product-page/descomplicando-o-kubernetes) tinham acesso.

Devido a pandemia do [Coronavirus (COVID-19)](https://coronavirus.jhu.edu/map.html) e inspirado na iniciativa do [Guia Foca GNU/Linux](https://guiafoca.org), de [Gleydson Mazioli da Silva](https:///twitter.com/gleydsonmazioli), [Jeferson Fernando](https://twitter.com/badtux_) liberou o acesso público a este repositório como forma de ajudar no combate a pandemia incentivando as pessoas a ficarem em casa adquirindo o conhecimento e se aprimorando na profissão para poderem contribuir no local de trabalho ou mesmo se prepararem para novas oportunidades.

Futuramente o conteúdo deste repositório se tornará um livro, com o nome de todas as pessoas que contribuiram para o projeto. O valor que será arrecado com a venda do livro, será totalmente destinado para alguma organização que ajude as quebradas e pessoas com problemas financeiros e/ou problemas com acesso a informação, como por exemplo, a [Bienal da Quebrada](https://twitter.com/bienalquebrada).

Veja os vídeos sobre Kubernetes e até outros temas legais no canal LinuxTips.

* https://www.youtube.com/user/linuxtipscanal/videos
* https://www.youtube.com/user/linuxtipscanal/playlists

Para contribuir com melhorias no conteúdo, siga as instruções deste [tutorial](CONTRIBUTING.md).

<!-- TOC -->
- [Descomplicando Kubernetes Day 1](#descomplicando-kubernetes-day-1)
  - [Sumário](#sumário)
- [O quê preciso saber antes de começar?](#o-quê-preciso-saber-antes-de-começar)
  - [Qual distro Linux devo usar?](#qual-distro-linux-devo-usar)
  - [Alguns sites que devemos visitar](#alguns-sites-que-devemos-visitar)
  - [E o k8s?](#e-o-k8s)
  - [Arquitetura do k8s](#arquitetura-do-k8s)
  - [Portas que devemos nos preocupar](#portas-que-devemos-nos-preocupar)
  - [Tá, mas qual tipo de aplicação eu devo rodar sobre o k8s?](#tá-mas-qual-tipo-de-aplicação-eu-devo-rodar-sobre-o-k8s)
  - [Conceitos-chave do k8s](#conceitos-chave-do-k8s)
- [Aviso sobre os comandos](#aviso-sobre-os-comandos)
- [Minikube](#minikube)
  - [Requisitos básicos](#requisitos-básicos)
  - [Instalação do Minikube no Linux](#instalação-do-minikube-no-linux)
  - [Instalação do Minikube no MacOS](#instalação-do-minikube-no-macos)
  - [kubectl: alias e autocomplete](#kubectl-alias-e-autocomplete)
  - [Instalação do Minikube no Microsoft Windows](#instalação-do-minikube-no-microsoft-windows)
  - [Iniciando, parando e excluindo o Minikube](#iniciando-parando-e-excluindo-o-minikube)
  - [Certo, e como eu sei que está tudo funcionando como deveria?](#certo-e-como-eu-sei-que-está-tudo-funcionando-como-deveria)
  - [Descobrindo o endereço do Minikube](#descobrindo-o-endereço-do-minikube)
  - [Acessando a máquina do Minikube via SSH](#acessando-a-máquina-do-minikube-via-ssh)
  - [Dashboard](#dashboard)
  - [Logs](#logs)
- [Microk8s](#microk8s)
  - [Requisitos básicos](#requisitos-básicos-1)
  - [Instalaçao do MicroK8s no GNU/Linux](#instalaçao-do-microk8s-no-gnulinux)
    - [Versões que suportam Snap](#versões-que-suportam-snap)
  - [Instalação no Windows](#instalação-no-windows)
    - [Instalando o Chocolatey](#instalando-o-chocolatey)
      - [Instalando o Multipass](#instalando-o-multipass)
    - [Utilizando Microk8s com Multipass](#utilizando-microk8s-com-multipass)
  - [Instalando o Microk8s no Mac](#instalando-o-microk8s-no-mac)
    - [Instalando o Brew](#instalando-o-brew)
    - [Instalando o Microk8s via Brew](#instalando-o-microk8s-via-brew)
- [Kind](#kind)
  - [Instalação no Linux](#instalação-no-linux)
  - [Instalaçao no MacOS](#instalaçao-no-macos)
  - [Instalação no Windows](#instalação-no-windows-1)
    - [Instalação no Windows via Chocolatey](#instalação-no-windows-via-chocolatey)
  - [Criando um cluster com o Kind](#criando-um-cluster-com-o-kind)
    - [Criando um cluster com múltiplos nós locais com o Kind](#criando-um-cluster-com-múltiplos-nós-locais-com-o-kind)
- [k3s](#k3s)
- [Instalação em cluster com três nós](#instalação-em-cluster-com-três-nós)
  - [Requisitos básicos](#requisitos-básicos-2)
  - [Configuração de módulos de kernel](#configuração-de-módulos-de-kernel)
  - [Atualização da distribuição](#atualização-da-distribuição)
  - [Instalação do Docker e do Kubernetes](#instalação-do-docker-e-do-kubernetes)
  - [Inicialização do cluster](#inicialização-do-cluster)
  - [Configuração do arquivo de contextos do kubectl](#configuração-do-arquivo-de-contextos-do-kubectl)
  - [Inserindo os nós workers no cluster](#inserindo-os-nós-workers-no-cluster)
    - [Múltiplas Interfaces](#múltiplas-interfaces)
  - [Instalação do pod network](#instalação-do-pod-network)
  - [Verificando a instalação](#verificando-a-instalação)
- [Primeiros passos no k8s](#primeiros-passos-no-k8s)
  - [Exibindo informações detalhadas sobre os nós](#exibindo-informações-detalhadas-sobre-os-nós)
  - [Exibindo novamente token para entrar no cluster](#exibindo-novamente-token-para-entrar-no-cluster)
  - [Ativando o autocomplete](#ativando-o-autocomplete)
  - [Verificando os namespaces e pods](#verificando-os-namespaces-e-pods)
  - [Executando nosso primeiro pod no k8s](#executando-nosso-primeiro-pod-no-k8s)
  - [Verificar os últimos eventos do cluster](#verificar-os-últimos-eventos-do-cluster)
  - [Efetuar o dump de um objeto em formato YAML](#efetuar-o-dump-de-um-objeto-em-formato-yaml)
  - [Socorro, são muitas opções!](#socorro-são-muitas-opções)
  - [Expondo o pod](#expondo-o-pod)
  - [Limpando tudo e indo para casa](#limpando-tudo-e-indo-para-casa)

<!-- TOC -->
