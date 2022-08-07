### Múltiplas Interfaces

Caso algum dos nós que será utilizado tenha mais de uma interface de rede, verifique se ele consegue alcançar o `service` do `Kubernetes` através da rota padrão.

Para verificar, será necessário pegar o IP interno do `service` Kubernetes através do comando ``kubectl get services kubernetes``. Após obter o IP, basta ir no nó que será ingressado no cluster e rodar o comando ``curl -k https://SERVICE`` alterando o `SERVICE` para o IP do `service`. Exemplo: ``curl -k https://10.96.0.1``.

Caso a saída seja algo parecido com o exemplo a seguir, a conexão está acontecendo normalmente.

```json
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}
```

Caso a saída não seja parecido com o exemplo, será necessário adicionar uma rota com o seguinte comando.

```shell
ip route add REDE_DO_SERVICE/16 dev INTERFACE
```

Substitua a `REDE_DO SERVICE` com a rede do `service` (geralmente é um IP finalizando com 0).

Exemplo: Se o IP for `10.96.0.1` a rede é `10.96.0.0`) e a `INTERFACE` com a interface do nó que tem acesso ao `control-plane` do cluster.

Exemplo de comando para adicionar uma rota:

```
sudo ip route add 10.96.0.0/16 dev eth1
```

Adicione a rota nas configurações de rede para que seja criada durante o boot.