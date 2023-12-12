FROM alpine:3.18
USER 0
ENV USER=root

RUN apk add --no-cache bash

COPY . /opt

WORKDIR /opt

CMD /bin/bash
