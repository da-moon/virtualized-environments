
# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build fjolsvin/golang-base:latest .
# ────────────────────────────────────────────────────────────────────────────────

FROM golang:alpine
USER root
RUN set -ex && \
  apk add --no-cache git bash upx && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"

# ─── BASE GO DEVELOPMENT TOOLS NEEDED FOR VS CODE GO EXTENSION ──────────────────
ARG GOPLS_VERSION=v0.6.9
ARG DELVE_VERSION=v1.5.0
ARG BASE_GO_DEV_PACKAGES="\
golang.org/x/tools/gopls@${GOPLS_VERSION} \
github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} \
"

SHELL ["bash" ,"-c"]
RUN set -ex && \
  IFS=' ' read -a BASE_GO_DEV_PACKAGES <<< "$BASE_GO_DEV_PACKAGES" ; \
  for pkg in "${BASE_GO_DEV_PACKAGES[@]}"; do go get $pkg ; done
# ─── EXTRA TOOLS INTEGRATING WITH VS CODE ───────────────────────────────────────
ARG GOTESTS_VERSION=v1.5.3
ARG GOMODIFYTAGS_VERSION=v1.13.0
ARG GOPLAY_VERSION=v1.0.0
ARG VSCODE_GO_DEV_PACKAGES="\
github.com/fatih/gomodifytags@${GOMODIFYTAGS_VERSION} \
github.com/cweill/gotests/...@${GOTESTS_VERSION} \
github.com/haya14busa/goplay/cmd/goplay@${GOPLAY_VERSION} \
github.com/ramya-rao-a/go-outline \
golang.org/x/tools/cmd/guru \
golang.org/x/tools/cmd/gorename \
github.com/davidrjenni/reftools/cmd/fillstruct \
"
RUN set -ex && \
  IFS=' ' read -a VSCODE_GO_DEV_PACKAGES <<< "$VSCODE_GO_DEV_PACKAGES" ; \
  for pkg in "${VSCODE_GO_DEV_PACKAGES[@]}"; do go get -v $pkg ; done

# ─── EXTRA TOOLS ────────────────────────────────────────────────────────────────

ARG EXTRA_GO_DEV_PACKAGES="\
mvdan.cc/gofumpt \
github.com/uudashr/gopkgs/v2/cmd/gopkgs \
github.com/cuonglm/gocmt \
github.com/palantir/go-compiles \
github.com/mohae/nocomment/cmd/nocomment  \
github.com/eandre/discover/... \
honnef.co/go/tools/... \
github.com/hexdigest/gounit/cmd/gounit \
github.com/vektra/mockery/v2/.../ \
"
RUN set -ex && \
  IFS=' ' read -a EXTRA_GO_DEV_PACKAGES <<< "$EXTRA_GO_DEV_PACKAGES" ; \
  for pkg in "${EXTRA_GO_DEV_PACKAGES[@]}"; do go get -v $pkg ; done
# ─── COMPRESS ───────────────────────────────────────────────────────────────────
RUN set -ex && \
 cd $(go env GOPATH)/bin && \
 ls | xargs -I {} upx {}
# ─── CLEAN UP ───────────────────────────────────────────────────────────────────
RUN set -ex && \
  rm -rf \
  $(go env GOPATH)/pkg/* \
  $(go env GOPATH)/src/* \
  /root/.cache/go-build
