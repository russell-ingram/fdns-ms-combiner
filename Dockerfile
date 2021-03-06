# build stage
FROM cdcgov/maven:fdns as builder

COPY . /usr/src/app
RUN mvn clean package

# run stage
FROM openjdk:8-jre-alpine

ARG COMBINER_PORT
ARG COMBINER_FLUENTD_HOST
ARG COMBINER_FLUENTD_PORT
ARG OBJECT_URL
ARG COMBINER_PROXY_HOSTNAME
ARG OAUTH2_ACCESS_TOKEN_URI
ARG OAUTH2_PROTECTED_URIS
ARG OAUTH2_CLIENT_ID
ARG OAUTH2_CLIENT_SECRET
ARG SSL_VERIFYING_DISABLE

ENV COMBINER_PORT ${COMBINER_PORT}
ENV COMBINER_FLUENTD_HOST ${COMBINER_FLUENTD_HOST}
ENV COMBINER_FLUENTD_PORT ${COMBINER_FLUENTD_PORT}
ENV OBJECT_URL ${OBJECT_URL}
ENV COMBINER_PROXY_HOSTNAME ${COMBINER_PROXY_HOSTNAME}
ENV OAUTH2_ACCESS_TOKEN_URI ${OAUTH2_ACCESS_TOKEN_URI}
ENV OAUTH2_PROTECTED_URIS ${OAUTH2_PROTECTED_URIS}
ENV OAUTH2_CLIENT_ID ${OAUTH2_CLIENT_ID}
ENV OAUTH2_CLIENT_SECRET ${OAUTH2_CLIENT_SECRET}
ENV SSL_VERIFYING_DISABLE ${SSL_VERIFYING_DISABLE}

COPY --from=builder /usr/src/app/target/fdns-ms-combiner-*.jar /app.jar

# pull latest
RUN apk update && apk upgrade --no-cache

# don't run as root user
RUN chown 1001:0 /app.jar
RUN chmod g+rwx /app.jar
USER 1001

ENTRYPOINT java -Dserver.tomcat.protocol-header=x-forwarded-proto -Dserver.tomcat.remote-ip-header=x-forwarded-for -jar /app.jar