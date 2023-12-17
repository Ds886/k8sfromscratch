FROM alpine:3.18
USER 0
ENV USER=root
ENV PACKAGES_INFRA "curl python3 cfssl kubectl"

RUN apk add --no-cache bash openssh sshpass

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" | tee /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | tee -a /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" | tee -a /etc/apk/repositories
RUN apk update && apk upgrade && apk add ${PACKAGES_INFRA}

COPY . /opt

WORKDIR /opt

CMD /opt/kfs-operator.sh
