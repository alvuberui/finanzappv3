# ---------- build ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copiamos todo el proyecto del micro
COPY . .

# Compilamos (sin tests para que sea más rápido)
RUN mvn -DskipTests package

# ---------- runtime ----------
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copiamos el jar generado (da igual el nombre exacto)
COPY --from=build /app/target/*.jar app.jar

# Spring Boot suele escuchar en 8080 dentro del contenedor
EXPOSE 8080

# Importante: que Java respete la RAM limitada por Docker
ENTRYPOINT ["java","-XX:MaxRAMPercentage=75","-jar","app.jar"]
