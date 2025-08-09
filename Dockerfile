# Multi-stage build for Socyads Ballerina backend

FROM ballerina/ballerina:2201.9.0 AS build
WORKDIR /app
COPY . /app
RUN bal build --offline=false

FROM eclipse-temurin:17-jre
WORKDIR /home/ballerina
COPY --from=build /app/target/bin/socyads_backend.jar /home/ballerina/socyads_backend.jar
COPY Config.toml /home/ballerina/Config.toml
EXPOSE 9090
ENV BAL_CONFIG_FILES=/home/ballerina/Config.toml
ENTRYPOINT ["java", "-jar", "/home/ballerina/socyads_backend.jar"]


