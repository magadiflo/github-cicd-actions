# ETAPA 1: Extraer capas del JAR (builder)
FROM eclipse-temurin:21-jre-alpine AS builder
WORKDIR /app
# Copiamos el JAR que fue construido previamente por GitHub Actions
COPY target/*.jar ./app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# ETAPA 2: Imagen final ligera
FROM eclipse-temurin:21-jre-alpine AS runner
WORKDIR /app
COPY --from=builder /app/dependencies ./
COPY --from=builder /app/spring-boot-loader ./
COPY --from=builder /app/snapshot-dependencies ./
COPY --from=builder /app/application ./

EXPOSE 8080
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
