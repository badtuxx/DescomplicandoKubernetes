# Contribución

¡Tu contribución es muy bienvenida!

Sigue los pasos a continuación siempre que desees mejorar el contenido de este repositorio.

* Instala los siguientes paquetes: `git` y un editor de texto de tu preferencia.
* Crea un fork de este repositorio. Consulta este tutorial: <https://help.github.com/en/github/getting-started-with-github/fork-a-repo>
* Clona el repositorio resultante del fork en tu ordenador.
* Agrega la URL del repositorio original con el siguiente comando.

```bash
git remote -v
git remote add upstream https://github.com/badtuxx/DescomplicandoKubernetes
git remote -v
```

* Crea una rama utilizando el siguiente convención:

```bash
git checkout -b NOMBRE_DE_LA_RAMA
```

* Asegúrate de que estás en la rama correcta utilizando el siguiente comando.

```bash
git branch
```

* La rama en uso tendrá un '*' antes del nombre.
* Realiza los cambios necesarios.
* Prueba tus cambios (si es necesario).
* Haz un commit de tus cambios en la rama recién creada, preferiblemente realiza un commit por cada archivo editado/creado.
* Envía tus commits al repositorio remoto con el comando:

```git push --set-upstream origin NOMBRE_DE_LA_RAMA```.

* Crea una solicitud de extracción (Pull Request, PR) hacia la rama `main` del repositorio original. Consulta este [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
* Actualiza el contenido con las sugerencias del revisor (si es necesario).
* Después de que tu PR sea aprobado y se haya realizado el merge, actualiza los cambios en tu repositorio local con los siguientes comandos.

```bash
git checkout main
git pull upstream main
```

* Elimina la rama local después de que se apruebe y se realice el merge de tu PR, utilizando el comando:

```bash
git branch -d NOMBRE_DE_LA_RAMA
```

* Actualiza la rama ``main`` de tu repositorio local.

```bash
git push origin main
```

* Envía la eliminación de la rama local a tu repositorio en GitHub con el comando:

```bash
git push --delete origin NOMBRE_DE_LA_RAMA
```

* Para mantener tu fork sincronizado con el repositorio original, ejecuta los siguientes comandos:

```bash
git pull upstream main
git push origin main
```

Referencia:

* <https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/>

# Consejo

**Puedes utilizar el editor de texto de tu preferencia y con el que te sientas más cómodo.**

Sin embargo, VSCode (<https://code.visualstudio.com>), combinado con los siguientes complementos, facilita el proceso de edición/revisión, permitiendo la previsualización del contenido antes de realizar el commit, analizando la sintaxis de Markdown y generando automáticamente el índice a medida que se crean/modifican los títulos de las secciones.

* Markdown-lint: <https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint>
* Markdown-toc: <https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc>
* Markdown-all-in-one: <https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one>
* YAML: <https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml>
* Helm-intellisense: <https://marketplace.visualstudio.com/items?itemName=Tim-Koehler.helm-intellisense>
* GitLens: <https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens>
* Temas para VSCode:
  * <https://code.visualstudio.com/docs/getstarted/themes>
  * <https://dev.to/thegeoffstevens/50-vs-code-themes-for-2020-45cc>
  * <https://vscodethemes.com/>
