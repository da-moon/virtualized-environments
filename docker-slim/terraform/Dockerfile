# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

# docker-slim --debug --log-level debug --verbose build --http-probe=false --dockerfile Dockerfile --tag-fat hashicorp/terraform .
FROM golang:alpine
RUN go env -w GO111MODULE=on && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add build-base make git bash ncurses upx
WORKDIR "/go/src/github.com/hashicorp"
RUN git clone \
        --depth 1 \
        --branch "master" \
        "https://github.com/hashicorp/terraform.git" \
        "/go/src/github.com/hashicorp/terraform"
WORKDIR "/go/src/github.com/hashicorp/terraform"
RUN TERM=xterm go build -o "/go/bin/terraform" && \
    strip "/go/bin/terraform" && \
    upx "/go/bin/terraform"
ENTRYPOINT ["/go/bin/terraform"]
