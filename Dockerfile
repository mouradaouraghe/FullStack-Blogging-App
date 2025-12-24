FROM eclipse-temurin:17-jre-jammy
EXPOSE 8085

ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

COPY target/*-SNAPSHOT.jar app.jar

CMD ["java", "-jar", "app.jar"]
