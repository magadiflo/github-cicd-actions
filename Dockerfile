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
