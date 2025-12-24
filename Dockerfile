FROM eclipse-temurin:17-jdk-alpine

EXPOSE 8085

ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

COPY target/*.jar app.jar

CMD ["java", "-jar", "app.jar"]
