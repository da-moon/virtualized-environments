# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/yq
FROM golang:alpine AS yq-builder
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
ARG REPO="github.com/mikefarah/yq"
ARG BRANCH="master"
WORKDIR "/go/src/${REPO}"
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go env -w "GO111MODULE=on" \
  && go env -w "CGO_ENABLED=0" \
  && go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'" \
  && apk add --no-cache --upgrade build-base git \
  && git clone \
  --depth 1 \
  --branch "${BRANCH}" \
  "https://${REPO}.git" \
  "/go/src/${REPO}" \
  && git fetch --all --tags \
  && git checkout \
    "$(git describe --tags `git rev-list --tags --max-count=1`)" \
  && mkdir -p /workspace \
  && go build -o "/workspace/yq" "./"
FROM fjolsvin/upx AS compression-layer
COPY --from=yq-builder "/workspace" "/workspace"
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
  /workspace/yq --version
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENTRYPOINT [ "/workspace/yq" ]
CMD ["--help"]
