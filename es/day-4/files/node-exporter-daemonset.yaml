apiVersion: apps/v1 # Versão da API do Kubernetes do objeto
kind: DaemonSet # Tipo do objeto
metadata: # Informações sobre o objeto
  name: node-exporter # Nome do objeto
spec: # Especificação do objeto
  selector: # Seletor do objeto
    matchLabels: # Labels que serão utilizadas para selecionar os Pods
      app: node-exporter # Label que será utilizada para selecionar os Pods
  template: # Template do objeto
    metadata: # Informações sobre o objeto
      labels: # Labels que serão adicionadas aos Pods
        app: node-exporter # Label que será adicionada aos Pods
    spec: # Especificação do objeto, no caso, a especificação do Pod
      hostNetwork: true # Habilita o uso da rede do host, usar com cuidado
      containers: # Lista de contêineres que serão executados no Pod
      - name: node-exporter # Nome do contêiner
        image: prom/node-exporter:latest # Imagem do contêiner
        ports: # Lista de portas que serão expostas no contêiner
        - containerPort: 9100 # Porta que será exposta no contêiner
          hostPort: 9100 # Porta que será exposta no host
        volumeMounts: # Lista de volumes que serão montados no contêiner, pois o node-exporter precisa de acesso ao /proc e /sys
        - name: proc # Nome do volume
          mountPath: /host/proc # Caminho onde o volume será montado no contêiner
          readOnly: true # Habilita o modo de leitura apenas
        - name: sys # Nome do volume 
          mountPath: /host/sys # Caminho onde o volume será montado no contêiner
          readOnly: true # Habilita o modo de leitura apenas
      volumes: # Lista de volumes que serão utilizados no Pod
      - name: proc # Nome do volume
        hostPath: # Tipo de volume 
          path: /proc # Caminho do volume no host
      - name: sys # Nome do volume
        hostPath: # Tipo de volume
          path: /sys # Caminho do volume no host