
FROM golang:alpine AS go
USER root
RUN set -ex && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache git bash upx findutils binutils && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
SHELL ["bash","-c"]
FROM go AS go-builder
ARG GOPLS_VERSION=v0.6.9
ARG DELVE_VERSION=v1.5.0
ARG GOTESTS_VERSION=v1.5.3
ARG GOMODIFYTAGS_VERSION=v1.13.0
ARG GOPLAY_VERSION=v1.0.0
ARG GURU_VERSION=v0.1.2

ARG GO_PACKAGES="\
  golang.org/x/tools/gopls@${GOPLS_VERSION} \
  github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} \
  github.com/fatih/gomodifytags@${GOMODIFYTAGS_VERSION} \
  github.com/cweill/gotests/...@${GOTESTS_VERSION} \
  github.com/haya14busa/goplay/cmd/goplay@${GOPLAY_VERSION} \
  github.com/ramya-rao-a/go-outline \
  github.com/davidrjenni/reftools/cmd/... \
  mvdan.cc/gofumpt \
  github.com/uudashr/gopkgs/v2/cmd/gopkgs \
  github.com/cuonglm/gocmt \
  github.com/palantir/go-compiles \
  github.com/mohae/nocomment/cmd/nocomment  \
  github.com/eandre/discover/... \
  honnef.co/go/tools/... \
  honnef.co/go/tools/cmd/... \
  github.com/hexdigest/gounit/cmd/gounit \
  github.com/vektra/mockery/v2/.../ \
  github.com/stretchr/gorc \
  github.com/fatih/motion@latest \
  github.com/kisielk/errcheck@latest \
  github.com/koron/iferr@master \
  golang.org/x/lint/golint@master \
  github.com/jstemmer/gotags@master \
  github.com/josharian/impl@master \
  github.com/fatih/gomodifytags@latest \
  github.com/klauspost/asmfmt/cmd/asmfmt \
  github.com/mgechev/revive \
  "
RUN set -ex && \
  go get -v golang.org/x/tools/cmd/... && \
  IFS=' ' read -a GO_PACKAGES <<< "$GO_PACKAGES" && \
  go get -v "${GO_PACKAGES[@]}" ;
# ────────────────────────────────────────────────────────────────────────────────
RUN set -ex && \
  git clone https://github.com/magefile/mage /tmp/mage
WORKDIR /tmp/mage
RUN set -ex && \
  go run bootstrap.go
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
RUN set -ex && \
  curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
ARG GOLANGCI_LINT_VERSION=v1.35.2
RUN set -ex && \ 
  wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
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
