FROM eclipse-temurin:17-jre-jammy

WORKDIR /usr/src/app
COPY target/*-SNAPSHOT.jar app.jar

EXPOSE 8085

ENTRYPOINT []
CMD ["java", "-jar", "app.jar"]
