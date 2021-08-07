# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/shfmt
FROM golang:alpine AS shfmt-builder
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go env -w "GO111MODULE=on" \
  && go env -w "CGO_ENABLED=0" \
  && go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'" \
  && apk add --no-cache --upgrade build-base git \
  && GO111MODULE=on go get -v mvdan.cc/sh/v3/cmd/shfmt \
  && mv "$(go env GOPATH)/bin/shfmt" /workspace/
FROM fjolsvin/upx AS compression-layer
COPY --from=shfmt-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN \
  ( \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null ; \
  apk add --no-cache --upgrade bash bash-completion
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
RUN \
  /workspace/shfmt --version
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENTRYPOINT [ "/workspace/shfmt" ]
CMD ["--help"]
