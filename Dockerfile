FROM clojure:lein-alpine

COPY project.clj .

RUN lein deps

EXPOSE 3000

COPY ./ /cat
WORKDIR /cat

ENV DATABASE_URL jdbc:mysql://192.168.2.1:3306/cat_dev?user=cat_user&password=C1t&serverTimezone=UTC

RUN lein uberjar

CMD ["java", "-jar", "target/uberjar/cat.jar"]
