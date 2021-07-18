#
#:syntax = docker/dockerfile-upstream:master-labs
FROM golang:alpine AS go
USER root
RUN  \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache git bash findutils binutils && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN  \
  apk add --no-cache upx || true
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
  go get -v golang.org/x/tools/cmd/... || true ; \
  IFS=' ' read -a GO_PACKAGES <<< "$GO_PACKAGES" ; \
  for pkg in "${GO_PACKAGES[@]}"; do \
  go get -v "${pkg}" || true ; \
  done
# ────────────────────────────────────────────────────────────────────────────────
RUN set -ex && \
  git clone https://github.com/magefile/mage /tmp/mage
WORKDIR /tmp/mage
RUN set -ex && \
  go run bootstrap.go
# ─── COMPRESS ───────────────────────────────────────────────────────────────────
RUN set -ex && \
  if command -v "upx" >/dev/null ; then \
  find $(go env GOPATH)/bin -type f | xargs -I {} -P `nproc` strip {} || true ; \
  find $(go env GOPATH)/bin -type f | xargs -I {} -P `nproc` upx {} || true ; \
  fi
# ────────────────────────────────────────────────────────────────────────────────
FROM "fjolsvin/base-alpine"
USER root
# [ NOTE ] => base essential packages
ARG BASE_PACKAGES="\
  go \
"
RUN set -ex && \
  apk add --update --no-cache ${BASE_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --update --no-cache ${BASE_PACKAGES})
RUN \
  curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh -s -- -b /usr/local/bin/
ARG GOLANGCI_LINT_VERSION=v1.35.2
RUN \
  wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin/ -d ${GOLANGCI_LINT_VERSION}
COPY --from=go-builder /go/bin /usr/local/bin
