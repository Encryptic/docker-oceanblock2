# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jdk-noble

LABEL version="1.9.0"

ARG PACK_ID=128
ENV PACK_ID=${PACK_ID}
ARG PACK_VERSION=100074
ENV PACK_VERSION=${PACK_VERSION}

RUN apt-get update && apt-get install -y curl unzip jq && \
    adduser --uid 99 --gid 100 --home /data --disabled-password minecraft && \
    curl -JL -o server_install "https://api.feed-the-beast.com/v1/modpacks/public/modpack/${PACK_ID}/${PACK_VERSION}/server/linux" && \
    chmod +x server_install && \
    mkdir -p /modpack && \
    /server_install -auto -no-java -pack ${PACK_ID} -version ${PACK_VERSION} -dir /modpack && \
    rm server_install

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

VOLUME /data
WORKDIR /data
 
EXPOSE 25565/tcp

CMD ["/launch.sh"]
 
