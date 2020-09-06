<!-- TOC -->

- [Contribuindo](#contribuindo)
- [Dica](#dica)

<!-- TOC -->

# Contribuindo

Sua contribuição é muito bem vinda!

Execute os passos a seguir sempre que desejar melhorar o conteúdo deste repositório.

* Instale os seguintes pacotes: git e um editor de texto de sua preferência.
* Crie um fork neste repositório. Veja este tutorial: https://help.github.com/en/github/getting-started-with-github/fork-a-repo
* Clone o repositório resultante do fork para o seu computador.
* Adicione a URL do repositório de origem com o comando a seguir.

```bash
git remote -v
git remote add upstream https://github.com/badtuxx/DescomplicandoKubernetes
git remote -v
```

* Crie uma branch usando o padrão: `git checkout -b US-YOUR_NAME`. Exemplo: *git checkout -b US-AECIO*
* Certifique-se de que está branch correta, usando o comando a seguir.

```bash
git branch
```

* Estará sendo utilizada a branch que estiver um '*' antes do nome.
* Faça as alterações necessárias.
* Teste suas alterações.
* Commit as suas alterações na branch recém criada, de preferência faça um commit para cada arquivo editado/criado.
* Envie os commits para o repositório remoto com o comando `git push --set-upstream origin US-YOUR_NAME`. Exemplo: *git push --set-upstream origin US-AECIO*
* Crie um Pull Request (PR) para a branch `master` do repositório original. Veja este [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
* Atualize o conteúdo com as sugestões do revisor (se necessário).
* Depois de aprovado e realizado o merge do seu PR, atualize as mudanças no seu repositório local com os comandos a seguir.

```bash
git checkout master
git pull upstream master
```

* Remova a branch local após a aprovação e merge do seu PR, usando o comando `git branch -d BRANCH_NAME`. Exemplo: *git branch -d US-AECIO*
* Atualize a branch ``master`` do seu repositório local.

```bash
git push origin master
```

* Envie a exclusão da branch local para o seu repositório no GitHub com o comando `git push --delete origin BRANCH_NAME`. Exemplo: *git push --delete origin US-AECIO*
* Para manter seu fork em sincronia com o repositório original, execute estes comandos:

```bash
git pull upstream master
git push origin master
```

Referência:
* https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/

# Dica

**Você pode usar o editor de texto de sua preferência e que se sinta mais confortável de usar.**

Mas o VSCode (https://code.visualstudio.com), combinado com os plugins a seguir, auxilia o processo de edição/revisão, principalmente permitindo a pré-visualização do conteúdo antes do commit, analisando a sintaxe do Markdown e gerando o sumário automático, à medida que os títulos das seções vão sendo criados/alterados.

* Markdown-lint: https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
* Markdown-toc: https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc
* Markdown-all-in-one: https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one
* YAML: https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
* Helm-intellisense: https://marketplace.visualstudio.com/items?itemName=Tim-Koehler.helm-intellisense