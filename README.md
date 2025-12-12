# [Build CI/CD Pipeline Using GitHub Actions](https://www.youtube.com/watch?v=NppkHKvnrqc)

Tutorial tomado del canal de youtube **JavaTechie**.

---

## 📘 Introducción

En este tutorial aprenderemos a crear un pipeline de `CI/CD` utilizando `GitHub Actions`, una de las herramientas de
automatización más usadas actualmente para proyectos alojados en `GitHub`.

Antes de entrar en la práctica, es importante entender qué es `GitHub Actions` y por qué elegir esta herramienta
frente a otras alternativas de `CI/CD` existentes.

## ⚙️ ¿Qué es GitHub Actions?

`GitHub Actions` es una `plataforma de automatización integrada en GitHub` que permite construir, probar y desplegar
código directamente desde tu repositorio.

Permite crear `Workflows` (flujos de trabajo) definidos mediante archivos `YAML` dentro del directorio
`.github/workflows/`, los cuales se ejecutan automáticamente en respuesta a eventos como:

- `push`, `pull_request`
- Creación de tags o releases
- Schedules (cron jobs)
- Dispatch manual desde la UI
- Webhooks e integraciones externas

### 🧩 Características principales

- `Automatización completa`: CI/CD, linting, análisis estático, empaquetados, scripts, notificaciones, etc.
- `Ejecución en múltiples entornos`: Linux, Windows, macOS, contenedores y runners auto-hospedados.
- `Gigante marketplace de acciones reutilizables`: miles de acciones listas como `setup-java`,
  `docker/build-push-action`, `actions/checkout`, etc.
- `Integrado al 100% con GitHub`: sin configuraciones complicadas, sin servidores adicionales.
- `Escalabilidad inmediata`: GitHub provee runners bajo demanda.

#### 💡 Nota técnica

> `GitHub Actions` utiliza `runners`, que son máquinas virtuales donde se ejecutan los workflows. `GitHub`
> ofrece runners gratuitos para proyectos públicos y una cantidad de minutos para repos privados según el plan.

### 🎯 ¿Por qué usar GitHub Actions?

Probablemente, nos preguntemos por qué usar GitHub Actions teniendo tantas herramientas de CI/CD en el mercado, como:

- Jenkins
- GitLab CI
- TeamCity
- TravisCI
- Bamboo
- CircleCI

La respuesta se resume en este principio:
> Si tu repositorio está en `GitHub`, `GitHub Actions` elimina dependencias externas.

#### Ventajas clave

- 🚀 `Sin infraestructura adicional`: No necesitas mantener un servidor Jenkins o máquinas dedicadas.
- 🔄 `Configuración mínima`: Todo se versiona junto con el código (Workflows en YAML).
- 🧩 `Integración nativa`: Se conecta automáticamente a PRs, Issues, Releases y ramas.
- 💰 `Menos costo operativo`: GitHub ofrece runners gratuitos y no pagas por servidores externos.
- 📦 `Acciones reutilizables`: Evita escribir scripting complejo para tareas comunes.
- 🔒 `Seguridad integrada`: Secrets vault, permisos de jobs, OIDC para despliegues a la nube, etc.

En proyectos reales, `GitHub Actions` destaca especialmente para:

- Microservicios en Spring Boot que requieren builds rápidos.
- Pipelines containerizados (Docker, Kubernetes).
- Workflows de despliegue hacia AWS, Azure, GCP, Fly.io, Heroku u otros.
- Automatización de pruebas, linting, SonarQube, Snyk, etc.

### 🔧 Flujo de trabajo tradicional con Jenkins

![01.png](assets/01.png)

En el flujo tradicional con Jenkins, el proceso es:

- 🧑‍💻 El desarrollador escribe código.
- 📤 Hace push al repositorio en GitHub.
- 🔔 GitHub envía un `Webhook` a Jenkins.
- 🔄 Jenkins ejecuta las `etapas de CI`:
    - Compilación
    - Pruebas
    - Code coverage
    - Construcción de la imagen Docker

- 📦 Luego ejecuta las `etapas de CD`:
    - Despliegue
    - Push al registry (Docker Hub / ECR / GCR / etc.)

#### 🏗️ Problemas comunes en Jenkins

- Necesitas infraestructura propia (servidores o contenedores).
- Requiere mantenimiento, actualización de plugins, monitoreo.
- Es más complejo de escalar.
- El pipeline queda dependiente del servidor externo.

En entornos corporativos, Jenkins sigue siendo muy usado, pero requiere equipo DevOps que mantenga todo el sistema.

### 🔄 Flujo de trabajo con GitHub Actions

![02.png](assets/02.png)

#### ¿Qué cambia?

- No necesitas infraestructura: GitHub provee los servidores.
- Los workflows se ejecutan `dentro de GitHub`, en runners automáticos.
- El pipeline CI/CD vive en el mismo repositorio donde está tu código.

#### 🧠 Ventajas reales en proyectos modernos

- `Menor complejidad operativa`: no configuras nada fuera de GitHub.
- `Velocidad`: los runners son rápidos y se crean bajo demanda.
- `Consistencia`: cada ejecución inicia desde un entorno limpio.
- `Integración perfecta con PRs`: revisiones automáticas, checks, deploy previews, etc.

#### Ejemplo real en empresas

Supongamos un microservicio Spring Boot que debe:

- Construirse con Maven
- Ejecutar tests
- Construir un Docker image
- Publicarlo a AWS ECR
- Desplegarlo en ECS o Kubernetes

Con `GitHub Actions`, todo este pipeline puede escribirse como un archivo YAML de ~50–80 líneas.
En `Jenkins`, tendrías que configurar un servidor, plugins, agentes, credenciales, pipelines, etc.

`GitHub Actions` reduce radicalmente el tiempo entre `push` → `build` → `deploy`.

## 🚀 Nuestro flujo de trabajo CI/CD (Visión general del tutorial)

En esta lección definiremos el `flujo completo que construiremos en el tutorial`, desde la creación del proyecto
hasta el despliegue automatizado utilizando `GitHub Actions`.

El objetivo es implementar un pipeline CI/CD que:

- Compile y pruebe nuestro proyecto de Spring Boot.
- Construya una imagen Docker.
- Publique dicha imagen en Docker Hub.

Todo esto será ejecutado automáticamente cada vez que realicemos cambios en el código.

### 🛠️ ¿Qué construiremos?

1. `Crearemos un proyecto Spring Boot`. Desarrollaremos un microservicio base (REST API simple) usando `Spring Boot`.
2. `Subiremos el proyecto a GitHub`. El repositorio alojará no solo el código fuente, sino también los workflows YAML
   que definen el pipeline.
3. `Configuraremos un workflow de GitHub Actions`. Desde la pestaña `Actions` crearemos un pipeline que se ejecutará en
   cada `push` o `pull_request`.
4. `Definiremos las etapas del pipeline`. GitHub Actions se encargará de automatizar:
    - 🧪 **1. Build & Test**
        - Descargar dependencias
        - Ejecutar pruebas unitarias
        - Generar artefactos del proyecto
    - 🐳 **2. Build Docker Image**
        - Construir una imagen Docker basada en nuestra aplicación
        - Etiquetarla usando el nombre del proyecto y/o el commit ID
    - 📤 **3. Push Image to Docker Hub**
        - Autenticarse contra Docker Hub usando GitHub Secrets
        - Subir la imagen generada al registry

### 🔄 Resultado final: pipeline CI/CD automatizado

Una vez configurado, `GitHub Actions` ejecutará este flujo de trabajo automáticamente cada vez que actualices tu
repositorio.

![03.png](assets/03.png)

Con esto, obtendremos un pipeline completo que acompaña al código desde el desarrollo hasta la entrega.

## 🧱 1° paso: Creando el proyecto Spring Boot

Para comenzar con nuestro pipeline CI/CD, primero necesitamos un proyecto base sobre el cual trabajará GitHub Actions.
Crearemos un proyecto de Spring Boot usando
[Spring Initializr](https://start.spring.io/#!type=maven-project&language=java&platformVersion=3.5.8&packaging=jar&configurationFileFormat=yaml&jvmVersion=21&groupId=dev.magadiflo&artifactId=github-cicd-actions&name=github-cicd-actions&description=Demo%20project%20for%20Spring%20Boot&packageName=dev.magadiflo.app&dependencies=web,lombok),
con las dependencias mínimas necesarias para construir una API sencilla.

## 📦 Dependencias utilizadas

El proyecto usará una configuración ligera pero suficiente para la demostración del pipeline:

- `spring-boot-starter-web`. Para crear un servicio REST.
- `lombok`. Simplifica código boilerplate como getters, setters, constructores, etc.
- `spring-boot-starter-test`. Para ejecutar pruebas unitarias que se usarán en la etapa de CI.

````xml
<!--Spring Boot 3.5.8-->
<!--Java 21-->
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
````

## 🌐 Creando un endpoint sencillo

En esta lección construiremos una pequeña API REST con Spring Boot. Este endpoint será la base sobre la cual
ejecutaremos nuestro pipeline CI/CD con GitHub Actions (compilación, pruebas, construcción de imagen Docker,
despliegue, etc.).

La idea es mantener el servicio simple, pero funcional, como suele hacerse en pipelines de demostración o pruebas de
integración.

### ⚙️ Configuración de la aplicación

Agregamos una configuración mínima en el archivo `application.yml` para definir:

- Puerto de ejecución (8080)
- Manejo de mensajes de error
- Nombre lógico de la aplicación (útil para logs, observabilidad, etc.)

````yml
server:
  port: 8080
  error:
    include-message: always

spring:
  application:
    name: github-cicd-actions
````

### 🧪 Creando un endpoint REST básico

Ahora definimos un controlador sencillo que responderá con un saludo y algunos metadatos útiles:

- Mensaje de bienvenida
- Timestamp
- Versión del servicio

````java

@RestController
@RequestMapping(path = "/api/v1/greetings")
public class HelloController {
    @GetMapping
    public ResponseEntity<Map<String, Object>> hello() {
        var response = new HashMap<String, Object>();
        response.put("message", "Hola desde Spring Boot + GitHub Actions!");
        response.put("timestamp", LocalDateTime.now());
        response.put("version", "1.0.0");
        return ResponseEntity.ok(response);
    }
}
````

### 📌 Resultado esperado

````bash
$ curl -v http://localhost:8080/api/v1/greetings | jq
>
< HTTP/1.1 200
< Content-Type: application/json
< Transfer-Encoding: chunked
< Date: Thu, 11 Dec 2025 15:38:06 GMT
<
{
  "message": "Hola desde Spring Boot + GitHub Actions!",
  "version": "1.0.0",
  "timestamp": "2025-12-11T10:38:06.8277636"
}
````

## 📤 2° paso: Enviando el código fuente al repositorio de GitHub

Una vez creado nuestro proyecto Spring Boot, el siguiente paso es subir el código al repositorio remoto donde
construiremos nuestro pipeline CI/CD. En este caso, utilizaremos GitHub.

### Crear el repositorio en GitHub

Creamos un repositorio llamado `github-cicd-actions`, donde almacenaremos todo el proyecto junto con los workflows de
GitHub Actions.

![04.png](assets/04.png)

### Verificar el historial de commits local

Desde la consola, nos ubicamos en la raíz del proyecto para revisar el historial de cambios registrados hasta el
momento:

````bash
D:\programming\spring\02.youtube\25.java_techie\github-cicd-actions (main)
$ git lg
* 7999462 (HEAD -> main) Creando un endpoint sencillo
* 43da16b Creando el proyecto Spring Boot
* b572268 Nuestro flujo de trabajo CI/CD (Visión general del tutorial)
* 443597c Inicio
````

### Asociar el repositorio local con el repositorio remoto

Agregamos la URL del repositorio recién creado como origen (remote):

````bash
D:\programming\spring\02.youtube\25.java_techie\github-cicd-actions (main)
$ git remote add origin https://github.com/magadiflo/github-cicd-actions.git
````

Este comando crea un vínculo entre tu proyecto local y el repositorio de GitHub.

### Subir el proyecto al repositorio remoto (push)

Una vez configurado el remote, hacemos push del proyecto completo hacia GitHub:

````bash
D:\programming\spring\02.youtube\25.java_techie\github-cicd-actions (main)
$ git push -u origin main
Enumerating objects: 51, done.
Counting objects: 100% (51/51), done.
Delta compression using up to 8 threads
Compressing objects: 100% (36/36), done.
Writing objects: 100% (51/51), 266.13 KiB | 12.67 MiB/s, done.
Total 51 (delta 9), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (9/9), done.
To https://github.com/magadiflo/github-cicd-actions.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'. 
````

### Verificación en GitHub

Finalmente, refrescamos el repositorio en GitHub y confirmamos que todos los archivos del proyecto se hayan cargado
correctamente.

![05.png](assets/05.png)

## ⚙️ 3° paso: Creando el Workflow de GitHub Actions

En este paso configuraremos nuestro primer workflow CI/CD dentro del repositorio de GitHub.
Este workflow será responsable de:

- Compilar el proyecto
- Ejecutar las pruebas
- Publicar el gráfico de dependencias

Este pipeline será la base sobre la cual luego añadiremos las etapas de Docker y despliegue continuo.

### 🧭 Navegando a GitHub Actions

Dentro del repositorio, abrimos la pestaña `Actions`. `GitHub` nos sugiere plantillas predefinidas llamadas `workflows`,
y entre ellas hay dos especialmente relevantes para proyectos Maven:

- `Java With Maven` — Plantilla estándar de CI
    - Esta plantilla está centrada en validar la calidad del código:
        - ✔ Compila el proyecto
        - ✔ Ejecuta todos los tests
        - ✔ Verifica que la rama está en buen estado
    - Es la plantilla base para pipelines que validan pull requests.

- `Publish Java Package With Maven` — Publicación de artefactos
    - Incluye todo lo anterior, pero además permite:
        - Publicar un `.jar` o `.war`
        - Subirlo a un registry como Maven Central, GitHub Packages u otro
    - Esta plantilla se usa cuando tu proyecto es una librería que otros consumirán.

### 🔒 Habilitar Dependency Graph

Antes de crear nuestro workflow, debemos activar una opción importante:

📍 `Settings` → `Security` → `Advanced Security` → `Dependency Graph`

Si no habilitamos esta opción, GitHub marcará un error durante el pull request porque el workflow actualizará el gráfico
de dependencias.

![06.png](assets/06.png)

## 📝 3.1 Build & Test: Creando el Workflow de CI con Java With Maven

Seleccionamos la plantilla `Java with Maven` y hacemos clic en `Configure`:

![07.png](assets/07.png)

GitHub generará automáticamente un archivo llamado `maven.yml`. Nosotros lo ajustamos para adaptarlo a:

- Nombre personalizado
- Uso de Java 21
- Mejor claridad en los pasos
- Publicación del dependency graph

Aquí está el archivo final:

````yml
name: Project CI/CD Flow

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:

    runs-on: ubuntu-latest

    # Añadido: Permiso para que GITHUB_TOKEN pueda subir el gráfico de dependencias
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven
      - name: Build with Maven
        run: mvn -B clean install

      # Optional: Uploads the full dependency graph to GitHub to improve the quality of Dependabot alerts this repository can receive
      # Este paso se ejecutará correctamente por la configuración permissions.contents=write y la habilitación del 
      # Dependency graph en el Advanced Security de el repositorio de GitHub
      - name: Update dependency graph
        uses: advanced-security/maven-dependency-submission-action@571e99aab1055c2e71a1e2309b9691de18d6b7d6
````

- 🏷️ `name: Project CI/CD Flow`. Nombre visible del workflow en GitHub Actions.
- Sección `on`. Define los eventos que disparan el workflow.
    - El pipeline se ejecutará en:
        - Cada *push* hacia `main`
        - Cada *pull request* que proponga cambios en `main`
    - Esto es típico para validar código antes de integrarlo a la rama principal.
- `jobs`: Todos los trabajos del pipeline, en este caso solo tenemos un job: `build`.
- `runs-on: ubuntu-latest`. GitHub ejecutará este pipeline en un runner de Ubuntu alojado en GitHub.
- `permissions.contents=write`. Es necesario para que GitHub pueda actualizar el gráfico de dependencias. Sin esto el
  workflow fallará.
- `steps`. Cada paso del job ejecuta una acción específica dentro del runner.
    - `uses: actions/checkout@v4`. Clona el código fuente del mismo repositorio donde se está ejecutando el workflow.
      Esto permite que los siguientes pasos (compilación, pruebas, análisis, construcción de Docker, etc.) puedan
      trabajar con el código del proyecto.
        - Por ejemplo, si el workflow está corriendo en `magadiflo/github-cicd-actions`, entonces `actions/checkout@v4`
          va a clonar ese repositorio `magadiflo/github-cicd-actions` dentro del runner de GitHub Actions.
- Configurar JDK 21.
    - Usa la distribución Temurin (LTS recomendada)
    - Activa la caché de Maven → acelera futuros builds
- Compilar y ejecutar pruebas
    - `-B` → modo batch (sin salida interactiva, ideal para CI)
- Actualizar dependency graph
    - Este paso envía la lista de dependencias a GitHub.
    - Sirve para:
        - Alertas de seguridad
        - Dependabot
        - Auditorías

Presionamos en `Commit changes...`

![08.png](assets/08.png)

Seleccionamos `Crate a new branch for this commit and start a pull request` para crear este archivo en otra rama.

![09.png](assets/09.png)

### 🔄 Crear el Pull Request

Una vez terminado el YAML, hacemos clic en:

- ✔ Commit changes
- ✔ Create a new branch and start a pull request

![10.png](assets/10.png)

Luego fusionamos los cambios en la rama `main`:

![11.png](assets/11.png)

Finalmente, vemos el archivo `maven.yml` dentro de: `.github/workflows/maven.yml`.

![12.png](assets/12.png)

### 🔻 Actualizar el repositorio local

Traemos la última versión desde GitHub:

````bash
D:\programming\spring\02.youtube\25.java_techie\github-cicd-actions (main -> origin)
$ git pull origin main
remote: Enumerating objects: 7, done.
remote: Counting objects: 100% (7/7), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 6 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (6/6), 2.67 KiB | 182.00 KiB/s, done.
From https://github.com/magadiflo/github-cicd-actions
 * branch            main       -> FETCH_HEAD
   47eadce..0cc30b6  main       -> origin/main
Updating 47eadce..0cc30b6
Fast-forward
 .github/workflows/maven.yml | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)
 create mode 100644 .github/workflows/maven.yml
````

### 🧭 Verificar historial de commits

````bash
D:\programming\spring\02.youtube\25.java_techie\github-cicd-actions (main -> origin)
$ git lg
*   0cc30b6 (HEAD -> main, origin/main, origin/HEAD) Merge pull request #3 from magadiflo/magadiflo-patch-1
|\
| * 3b73a2c (origin/magadiflo-patch-1) Modify CI/CD workflow for JDK 21 and permissions
|/
* 47eadce 2° paso: Enviando el código fuente al repositorio de GitHub
* 7999462 Creando un endpoint sencillo
* 43da16b Creando el proyecto Spring Boot
* b572268 Nuestro flujo de trabajo CI/CD (Visión general del tutorial)
* 443597c Inicio 
````

Revisamos nuestros archivos en nuestro proyecto y vemos: `.github` > `workflows` > `maven.yml`, vemos que se ha
descargado correctamente.

## Verificando ejecución del WorkFlow

Antes de continuar con las etapas siguientes de CI/CD, validamos que el workflow que creamos —responsable del paso
Build & Test— se esté ejecutando correctamente en GitHub Actions.

### 🧾 Historial de commits

Después de completar la configuración del workflow en la lección anterior, realizamos un commit y lo subimos al
repositorio remoto. Nuestro historial actual queda así:

````bash
D:\programming\spring\02.youtube\25.java_techie\github-cicd-actions (main -> origin)
$ git lg
* 014f953 (HEAD -> main, origin/main, origin/HEAD) 3° paso: Creando el Workflow de GitHub Actions
*   0cc30b6 Merge pull request #3 from magadiflo/magadiflo-patch-1
|\
| * 3b73a2c (origin/magadiflo-patch-1) Modify CI/CD workflow for JDK 21 and permissions
|/
* 47eadce 2° paso: Enviando el código fuente al repositorio de GitHub
* 7999462 Creando un endpoint sencillo
* 43da16b Creando el proyecto Spring Boot
* b572268 Nuestro flujo de trabajo CI/CD (Visión general del tutorial)
* 443597c Inicio 
````

### ⚙️ ¿Por qué el workflow se ejecutó automáticamente?

Esto ocurre gracias al bloque `on:` configurado en el archivo `maven.yml`:

````yml
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
````

🔍 Explicación

- Cada vez que hacemos un `push` a la rama `main`.
- O abrimos un `pull request` hacia la rama `main`.

➡️ `GitHub Actions` dispara automáticamente el `workflow`.

Por eso, una vez que enviamos los últimos cambios, GitHub ejecutó el pipeline sin que tuviéramos que hacer nada más.

### 🚀 Verificando la ejecución en GitHub Actions

Entramos a nuestro repositorio remoto y abrimos la pestaña `Actions`. Allí aparece la lista de ejecuciones recientes del
pipeline.

- Un ícono verde (✔) indica que todo se ejecutó con éxito.
- Un ícono rojo (✖) indicaría errores durante la ejecución.

![13.png](assets/13.png)

### 📂 Detalles de la ejecución

Hacemos clic en la última ejecución y luego seleccionamos el job `build`:

![14.png](assets/14.png)

Dentro de esa sección podemos ver cada uno de los pasos definidos en `maven.yml` ejecutándose en orden:

![15.png](assets/15.png)

### ✅ Descripción general de cada paso del workflow

#### 1. Set up job 🏁

Este paso lo ejecuta GitHub automáticamente. Aquí se prepara el entorno donde correrá el workflow:

- Descarga la versión del runner (ubuntu-latest).
- Verifica la versión del runner.
- Prepara el directorio de trabajo.
- Descarga las acciones que usará tu workflow (checkout, setup-java, etc.).
- Configura el token de autenticación (GITHUB_TOKEN).

`En resumen`: se prepara la máquina virtual donde correrán los demás pasos.

````bash
Current runner version: '2.329.0'
Runner Image Provisioner
Operating System
Runner Image
GITHUB_TOKEN Permissions
Secret source: Actions
Prepare workflow directory
Prepare all required actions
Getting action download info
Download action repository 'actions/checkout@v4' (SHA:34e114876b0b11c390a56381ad16ebd13914f8d5)
Download action repository 'actions/setup-java@v4' (SHA:c1e323688fd81a25caa38c78aa6df2d33d3e20d9)
Download action repository 'advanced-security/maven-dependency-submission-action@571e99aab1055c2e71a1e2309b9691de18d6b7d6' (SHA:571e99aab1055c2e71a1e2309b9691de18d6b7d6)
Complete job name: build
````

#### 2. Run actions/checkout@v4 📥 (Descargar el código del repo)

Este paso `clona tu repositorio actual` dentro del runner. Hace cosas como:

- Obtener la última referencia (`HEAD`).
- Preparar la carpeta del proyecto.
- Descargar el código completo de la rama (`main` en tu caso).
- Este paso es esencial porque `sin el código descargado, no habría nada que compilar ni testear`.

````bash
Run actions/checkout@v4
Syncing repository: magadiflo/github-cicd-actions
Getting Git version info
Temporarily overriding HOME='/home/runner/work/_temp/88b68f98-ae86-4113-bf61-e677be8dab4b' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/github-cicd-actions/github-cicd-actions
Deleting the contents of '/home/runner/work/github-cicd-actions/github-cicd-actions'
Initializing the repository
Disabling automatic garbage collection
Setting up auth
Fetching the repository
Determining the checkout info
/usr/bin/git sparse-checkout disable
/usr/bin/git config --local --unset-all extensions.worktreeConfig
Checking out the ref
/usr/bin/git log -1 --format=%H
014f9539091c9117426d8ffdcf16647d00fe88d6 
````

#### 3. Set up JDK 21 ☕ (Instalar Java)

Aquí la acción `setup-java` instala y configura `Java 21` en el runner. Incluye:

- Descarga del JDK (o restauración desde el cache si ya existe).
- Configuración de la carpeta `.m2` de Maven.
- Creación del archivo `settings.xml` para Maven.

En pocas palabras: `prepara Java para que Maven pueda construir el proyecto`.

````bash
Run actions/setup-java@v4
Installed distributions
Creating settings.xml with server-id: github
Writing to /home/runner/.m2/settings.xml
Cache hit for: setup-java-Linux-x64-maven-dcef6bc970ae2d9517b2000fdbc8d8786a5ef87f013d8686b3d16452a932d5a7
Received 0 of 83746138 (0.0%), 0.0 MBs/sec
Received 79691776 of 83746138 (95.2%), 38.0 MBs/sec
Received 83746138 of 83746138 (100.0%), 38.4 MBs/sec
Cache Size: ~80 MB (83746138 B)
/usr/bin/tar -xf /home/runner/work/_temp/daabdb21-f18c-4e45-a251-28fd3fa59689/cache.tzst -P -C /home/runner/work/github-cicd-actions/github-cicd-actions --use-compress-program unzstd
Cache restored successfully
Cache restored from key: setup-java-Linux-x64-maven-dcef6bc970ae2d9517b2000fdbc8d8786a5ef87f013d8686b3d16452a932d5a7 
````

#### 4. Build with Maven 🔨 (Compilar y ejecutar tests)

Ejecuta el comando: `mvn -B clean install`.

Este paso realiza:

- Limpieza del proyecto (clean).
- Compilación.
- Ejecución de tests automatizados.
- Empaquetado del artefacto (`.jar`).

GitHub muestra:

- Resumen de tests
- Build success/failure

Este paso es el corazón del proceso de `CI (Integración Continua)`.

````bash
Run mvn -B clean install
[INFO] Scanning for projects...
...
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running dev.magadiflo.app.GithubCicdActionsApplicationTests
18:28:28.496 [main] INFO org.springframework.test.context.support.AnnotationConfigContextLoaderUtils -- Could not detect default configuration classes for test class [dev.magadiflo.app.GithubCicdActionsApplicationTests]: GithubCicdActionsApplicationTests does not declare any static, non-private, non-final, nested classes annotated with @Configuration.
18:28:28.598 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper -- Found @SpringBootConfiguration dev.magadiflo.app.GithubCicdActionsApplication for test class dev.magadiflo.app.GithubCicdActionsApplicationTests

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.5.8)

...
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 2.621 s -- in dev.magadiflo.app.GithubCicdActionsApplicationTests
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  7.311 s
[INFO] Finished at: 2025-12-11T18:28:31Z
[INFO] ------------------------------------------------------------------------
````

#### 5. Update dependency graph 📊 (Enviar snapshot de dependencias a GitHub)

Esta acción genera un “snapshot” del árbol de dependencias de Maven y lo envía a GitHub.

¿Para qué sirve?

- Para mejorar las alertas de seguridad (Dependabot).
- Para que GitHub pueda detectar vulnerabilidades en tus dependencias.
- Para reconstruir el “Dependency Graph” del proyecto.

Este paso `no afecta el build`, solo actualiza la metadata del proyecto.

````bash
Run advanced-security/maven-dependency-submission-action@571e99aab1055c2e71a1e2309b9691de18d6b7d6
depgraph-maven-plugin
Dependency Snapshot
Submitting Snapshot... 
...
Notice: Snapshot successfully created at 2025-12-11T18:28:34.183Z
completed.
````

#### 6. Post Set up JDK 21 🧹 (Limpieza post-ejecución)

GitHub Actions ejecuta tareas de limpieza interna, como:

- Validar si debe guardar el cache del JDK (en este caso no fue necesario).
- Restaurar configuraciones previas.

Nada que tú debas configurar —es automático.

````bash
Post job cleanup.
Cache hit occurred on the primary key setup-java-Linux-x64-maven-dcef6bc970ae2d9517b2000fdbc8d8786a5ef87f013d8686b3d16452a932d5a7, not saving cache.
````

#### 7. Post Run actions/checkout@v4 🧽 (Limpieza del checkout)

GitHub limpia configuraciones globales que se aplicaron al clonar el repositorio. Incluye:

- Restaurar configuraciones de git.
- Eliminar headers temporales de autenticación.
- Depurar entradas agregadas al git config local.

De nuevo: **es mantenimiento interno del runner.**

````bash
Post job cleanup.
/usr/bin/git version
git version 2.52.0
Temporarily overriding HOME='/home/runner/work/_temp/8d53848e-9e8c-4670-b5b1-de0f18655d9a' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/github-cicd-actions/github-cicd-actions
/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
http.https://github.com/.extraheader
/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"
/usr/bin/git config --local --name-only --get-regexp ^includeIf\.gitdir:
/usr/bin/git submodule foreach --recursive git config --local --show-origin --name-only --get-regexp remote.origin.url 
````

#### 8. Complete job ✅ (Fin del workflow)

Último paso del workflow, donde GitHub:

- Cierra procesos en ejecución.
- Libera recursos.
- Marca el job como finalizado.

````bash
Cleaning up orphan processes 
````

## Generando Access Token de DockerHub y configurando secretos en GitHub

Hasta este punto, nuestro `maven.yml` tiene como último paso la construcción y el testeo del jar, es decir,
finaliza con la construcción de `.jar` correctamente testeada.

A partir de ahora, en los siguientes pasos, empezaremos a trabajar con DockerHub, por lo que, para evitar usar nuestra
contraseña de DockerHub, vamos a crear un `Personal Access Token` desde nuestra propia cuenta:
`Docker Hub → Account Settings → Personal Access Token → Generate New Token`.

![16.png](assets/16.png)

Ahora en `GitHub` nos vamos hacia nuestro repositorio
`github-cicd-actions → Settings → Secrets and variables → Actions → New repository secret`.

![17.png](assets/17.png)

Procedemos a crear nuestros dos secretos:

- `DOCKERHUB_USERNAME`: nuestro usuario de DockerHub.
- `DOCKERHUB_TOKEN`: El Personal Access Token generado anteriormente.

![18.png](assets/18.png)

## Creando Dockerfile

En la raíz de nuestro proyecto de Spring Boot creamos el siguiente `Dockerfile`. Como se observa, este Dockerfile
contiene dos etapas. Aquí estamos asumiendo que el `.jar` ya fue construido y eso en realidad es así, dado que GitHub
Actions es quien construye el `.jar` precisamente cuando ejecutamos el comando `mvn -B clean install` en el paso
llamado `Build with Maven` que definimos en el archivo `maven.yml`.

````dockerfile
# ETAPA 1: Copiamos el JAR ya compilado y extraemos las capas
FROM eclipse-temurin:21-jre-alpine AS builder
WORKDIR /app
# Aquí necesitamos copiar el JAR que se generó en la máquina de GitHub Actions
COPY target/*.jar ./app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# ETAPA 2: Ejecución (Imagen final ligera solo con JRE)
FROM eclipse-temurin:21-jre-alpine AS runner
WORKDIR /app
COPY --from=builder /app/dependencies ./
COPY --from=builder /app/spring-boot-loader ./
COPY --from=builder /app/snapshot-dependencies ./
COPY --from=builder /app/application ./

EXPOSE 8080
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
````

## 3.2 Build Docker Image: Construyendo la Imagen Docker desde GitHub Actions

En nuestro archivo `maven.yml` agregaremos el siguiente `step` al que le llamaremos `Build Docker image`. En este paso
primero obtenemos el tag del último commit, específicamente los primeros 8 caracteres empezando desde el caracter 1.
Luego, ejecutamos el comando para construir la imagen utilizando el valor definido en el secret `DOCKERHUB_USERNAME`.
Luego de construir la imagen, crearemos otra imagen con el tag `latest` para tener tanto la versión con el commit actual
como una versión `latest`.

````yml
jobs:
  build:
    steps:
      #...
      #...
      #...
      # 4. Construir la imagen Docker
      - name: Build Docker image
        run: |
          # 1. Creamos la etiqueta dinámica
          IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-8)

          # 2. Construimos la imagen con la etiqueta SHA
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:${IMAGE_TAG} .

          # 3. Le asignamos la etiqueta 'latest' a la misma imagen construida
          docker tag ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:${IMAGE_TAG} ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:latest
````

## 3.3 Push Image to Docker Hub: Publicando la Imagen en el Registro de Contenedores

En esta lección definimos dos pasos más, el primero para loguearnos a `DockerHub` y el segundo para subir la imagen
construida.

Para loguearnos a `DockerHub` usamos `docker/login-action@v3` y definimos en username y password los secretos
configurados en nuestro repositorio de GitHub para este repositorio `github-cicd-actions`.

Para subir la imagen a `DockerHub` simplemente usamos el comando `docker push` y el nombre de la imagen a subir, en
nuestro caso subimos las dos imágenes construidas, la imagen con el último commit y el latest.

> Importante: No es necesario crear previamente el repositorio para nuestra imagen en DockerHub, ya que el mismo
> DockerHub
> lo hará por nosotros. Docker Hub crea automáticamente el repositorio la primera vez que hagamos:
> `docker push usuario/nombre_imagen:tag`.
>
> Eso significa:
> - Si tu workflow empuja la imagen por primera vez, Docker Hub crea el repo automáticamente.
> - No necesitas configurarlo manualmente.

````yml
jobs:
  build:
    steps:
      #...
      #...
      #...
      #...
      # 5. Iniciar sesión en Docker Hub
      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # 6. Subir la imagen al Docker Hub
      - name: Push Docker image
        run: |
          IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-8)

          # Subimos la imagen con etiqueta SHA
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:${IMAGE_TAG}

          # Subimos la imagen con etiqueta latest
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:latest
````

## Versión final del maven.yml

A continuación se muestra el archivo final del `maven.yml` que contiene todos los pasos a ejecutar para la construcción
del `.jar`, construcción de la imagen docker, login a docker hub y subida de la imagen a docker hub.

````yml
name: Project CI/CD Flow

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:

    runs-on: ubuntu-latest

    # Añadido: Permiso para que GITHUB_TOKEN pueda subir el gráfico de dependencias
    permissions:
      contents: write

    steps:
      # 1. Checkout del repositorio
      - uses: actions/checkout@v4

      # 2. Configurar JDK
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven

      # 3. Build con Maven
      - name: Build with Maven
        run: mvn -B clean install

      # Optional: Uploads the full dependency graph to GitHub to improve the quality of Dependabot alerts this repository can receive
      - name: Update dependency graph
        uses: advanced-security/maven-dependency-submission-action@571e99aab1055c2e71a1e2309b9691de18d6b7d6

      # 4. Construir la imagen Docker
      - name: Build Docker image
        run: |
          # 1. Creamos la etiqueta dinámica
          IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-8)

          # 2. Construimos la imagen con la etiqueta SHA
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:${IMAGE_TAG} .

          # 3. Le asignamos la etiqueta 'latest' a la misma imagen construida
          docker tag ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:${IMAGE_TAG} ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:latest

      # 5. Iniciar sesión en Docker Hub
      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # 6. Subir la imagen al Docker Hub
      - name: Push Docker image
        run: |
          IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-8)

          # Subimos la imagen con etiqueta SHA
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:${IMAGE_TAG}

          # Subimos la imagen con etiqueta latest
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/github-cicd-actions:latest
````
