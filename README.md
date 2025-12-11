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

