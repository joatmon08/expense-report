FROM gradle:7.4-jdk11 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle clean build --no-daemon

FROM openjdk:11-jre-slim
EXPOSE 8080
RUN mkdir -p /app/agent
COPY --from=build /home/gradle/src/build/libs/*.jar /app/spring-boot-application.jar
COPY --from=build /home/gradle/src/application.properties /app/application.properties
COPY --from=build /home/gradle/src/agent/opentelemetry-javaagent.jar /app/agent/opentelemetry-javaagent.jar
ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-Dotel.traces.exporter=zipkin", \
    "-Dotel.metrics.exporter=prometheus" \
    "-javaagent:agent/opentelemetry-javaagent.jar", \
    "-Dotel.resource.attributes=service.name=expense" \
    "-jar","/app/spring-boot-application.jar"]