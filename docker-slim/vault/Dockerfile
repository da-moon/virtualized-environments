# docker-slim --debug --log-level debug --verbose build --http-probe=false --dockerfile Dockerfile --tag-fat hashicorp/vault .
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
        "https://github.com/hashicorp/vault.git" \
        "/go/src/github.com/hashicorp/vault"
WORKDIR "/go/src/github.com/hashicorp/vault"
RUN TERM=xterm go build -o "/go/bin/vault" && \
    strip "/go/bin/vault" && \
    upx "/go/bin/vault"
ENTRYPOINT ["/go/bin/vault"]