FROM openjdk:8-alpine

COPY target/uberjar/cat.jar /cat/app.jar

EXPOSE 3000

CMD ["java", "-jar", "/cat/app.jar"]
