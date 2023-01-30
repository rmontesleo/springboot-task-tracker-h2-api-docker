FROM eclipse-temurin:17-jdk-alpine as base
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as test
CMD ["./mvnw", "test"]

FROM base as development
CMD ["./mvnw", "spring-boot:run"]


FROM base as build
RUN ./mvnw package

FROM eclipse-temurin:17-jre-alpine as production
ARG JAR_NAME=task-tracker-docker.jar
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
EXPOSE 8080
COPY --from=build /app/target/${JAR_NAME} /${JAR_NAME}
ENTRYPOINT ["java", "-jar", ${JAR_NAME} ]