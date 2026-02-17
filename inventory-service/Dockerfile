FROM eclipse-temurin:21-jdk-jammy
COPY target/*.jar app.jar
# Não precisamos fixar o EXPOSE aqui se vamos passar a porta via Terraform
ENTRYPOINT ["java", "-Dserver.port=${SERVER_PORT}", "-jar", "app.jar"]