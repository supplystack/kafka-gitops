FROM alpine:3.16.0 as kafka-gitops

WORKDIR /opt

RUN apk --update --no-cache add curl && \
    curl -L -o /opt/kafka-gitops.zip https://github.com/devshawn/kafka-gitops/releases/download/0.2.15/kafka-gitops.zip && \
    unzip /opt/kafka-gitops.zip && \
    chmod 755 /opt/kafka-gitops

FROM alpine:3.16.0

RUN apk update && apk upgrade && \
    apk add yq openjdk8-jre && \
    rm -rf /var/cache/apk/*

COPY --from=kafka-gitops /opt/kafka-gitops /usr/local/bin/kafka-gitops

LABEL org.opencontainers.image.source https://github.com/supplystack/kafka-gitops
LABEL org.opencontainers.image.description Combines https://github.com/devshawn/kafka-gitops and https://github.com/mikefarah/yq in a single docker image