
# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build fjolsvin/golang-base:latest .
# ────────────────────────────────────────────────────────────────────────────────

FROM golang:alpine AS go
USER root
RUN set -ex && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache git bash upx findutils binutils && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
SHELL ["bash","-c"]
#
# ────────────────────────────────────────────────────── I ──────────
#   :::::: B U I L D E R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────
#
FROM go AS go-builder
# ─── ARGS ───────────────────────────────────────────────────────────────────────
ARG GOPLS_VERSION=v0.6.9
ARG DELVE_VERSION=v1.5.0
ARG GOTESTS_VERSION=v1.5.3
ARG GOMODIFYTAGS_VERSION=v1.13.0
ARG GOPLAY_VERSION=v1.0.0
ARG GO_PACKAGES="\
# ─── BASE DEPENDENCIES ──────────────────────────────────────────────────────────
golang.org/x/tools/gopls@${GOPLS_VERSION} \
github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} \
# ─── EXTRA TOOLS ────────────────────────────────────────────────────────────────
github.com/fatih/gomodifytags@${GOMODIFYTAGS_VERSION} \
github.com/cweill/gotests/...@${GOTESTS_VERSION} \
github.com/haya14busa/goplay/cmd/goplay@${GOPLAY_VERSION} \
github.com/ramya-rao-a/go-outline \
github.com/davidrjenni/reftools/cmd/... \
# ────────────────────────────────────────────────────────────────────────────────
github.com/rakyll/statik \
mvdan.cc/gofumpt \
github.com/uudashr/gopkgs/v2/cmd/gopkgs \
github.com/cuonglm/gocmt \
github.com/palantir/go-compiles \
github.com/mohae/nocomment/cmd/nocomment  \
github.com/eandre/discover/... \
honnef.co/go/tools/... \
github.com/hexdigest/gounit/cmd/gounit \
github.com/vektra/mockery/v2/.../ \
github.com/stretchr/gorc \
"
RUN set -ex && \
  go get -v golang.org/x/tools/cmd/... && \
  IFS=' ' read -a GO_PACKAGES <<< "$GO_PACKAGES" && \
  go get -v "${GO_PACKAGES[@]}" ;
# ─── COMPRESS ───────────────────────────────────────────────────────────────────
RUN set -ex && \
  while read pkg ; do \
  strip "$pkg"; \
  upx "$pkg"; \
  done < <(find $(go env GOPATH)/bin -type f -mindepth 1 -maxdepth 1)
# ────────────────────────────────────────────────────────────────────────────────
FROM go
# [ NOTE ] => base essential packages
ARG BASE_PACKAGES="\
  curl \
  perl \
  wget \
  tree \
  util-linux \
  git \
  ca-certificates \
  upx \
  ncurses \
  ncurses-dev \
  sudo=1.9.5p2-r0 \
  bash \
  bash-completion \
  shadow \
  libcap \
  coreutils \
  findutils \
  binutils \
  gnupg \
  grep \
  gawk \
  build-base \
  make \
  "
RUN set -ex && \
  apk add --no-cache ${BASE_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES})
SHELL ["bash","-c"]
#
# ─── GO RELEASER ────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
# ────────────────────────────────────────────────────────────────────────────────
ARG GOLANGCI_LINT_VERSION=v1.35.2
RUN set -ex && \ 
wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
# ────────────────────────────────────────────────────────────────────────────────
RUN set -ex && \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
RUN set -ex && \
  sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers && \
  echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
COPY --from=go-builder /go/bin /usr/local/bin