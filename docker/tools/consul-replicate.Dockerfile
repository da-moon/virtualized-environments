# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/consul-replicate
# ────────────────────────────────────────────────────────────────────────────────
FROM golang:alpine AS builder
RUN apk add --no-cache git
RUN go env -w GO111MODULE=off && \
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
        "https://github.com/hashicorp/consul-replicate.git" \
        "/go/src/github.com/hashicorp/consul-replicate"
WORKDIR "/go/src/github.com/hashicorp/consul-replicate"
RUN TERM=xterm \
  GO111MODULE=off \
  go build -o "/go/bin/consul-replicate" && \
    strip "/go/bin/consul-replicate" && \
    upx "/go/bin/consul-replicate"
RUN echo "nobody:x:65534:65534:Nobody:/:" > /etc_passwd
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc_passwd /etc/passwd
COPY --chmod=0755 --chown=65534:0 --from=builder "/go/bin/consul-replicate" /entrypoint
USER nobody
ENTRYPOINT ["/entrypoint"]
