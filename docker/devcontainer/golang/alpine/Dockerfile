# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
FROM golang:alpine AS go-builder
USER root
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN apk add --update --no-cache "bash=5.1.4-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG BASE_PACKAGES="\
  build-base=0.5-r2 \
  ca-certificates=20191127-r5 \
  cmake=3.20.3-r0 \
  coreutils=8.32-r2 \
  curl=7.78.0-r0 \
  git=2.32.0-r0 \
  findutils=4.8.0-r1 \
  make=4.3-r0 \
  util-linux=2.37-r0 \
  wget=1.21.1-r1 \
  "
RUN  \
  IFS=' ' read -a BASE_PACKAGES <<< $BASE_PACKAGES ; \
  go env -w "GO111MODULE=on" \
  && go env -w "CGO_ENABLED=0" \
  && go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'" \
  && apk add --update --no-cache "${BASE_PACKAGES[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache "${BASE_PACKAGES[@]}" \
  )
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS go-releaser-downloader
RUN \
  curl \
  -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh \
  | sh -s -- -b /go/bin/
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS golang-ci-lint-downloader
RUN \
  wget \
  -O- \
  -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
  | sh -s -- \
  -b /go/bin/ \
  -d "latest"
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS go-tools-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "golang.org/x/tools/cmd/..."  \
  && [ -r /go/bin/splitdwarf ] && true || exit 1 \
  && [ -r /go/bin/server ] && true || exit 1 \
  && [ -r /go/bin/cookieauth ] && true || exit 1 \
  && [ -r /go/bin/authtest ] && true || exit 1 \
  && [ -r /go/bin/benchcmp ] && true || exit 1 \
  && [ -r /go/bin/bundle ] && true || exit 1 \
  && [ -r /go/bin/callgraph ] && true || exit 1 \
  && [ -r /go/bin/compilebench ] && true || exit 1 \
  && [ -r /go/bin/cover ] && true || exit 1 \
  && [ -r /go/bin/digraph ] && true || exit 1 \
  && [ -r /go/bin/eg ] && true || exit 1 \
  && [ -r /go/bin/fiximports ] && true || exit 1 \
  && [ -r /go/bin/getgo ] && true || exit 1 \
  && [ -r /go/bin/gitauth ] && true || exit 1 \
  && [ -r /go/bin/go-contrib-init ] && true || exit 1 \
  && [ -r /go/bin/godex ] && true || exit 1 \
  && [ -r /go/bin/godoc ] && true || exit 1 \
  && [ -r /go/bin/goimports ] && true || exit 1 \
  && [ -r /go/bin/gomvpkg ] && true || exit 1 \
  && [ -r /go/bin/gorename ] && true || exit 1 \
  && [ -r /go/bin/gotype ] && true || exit 1 \
  && [ -r /go/bin/goyacc ] && true || exit 1 \
  && [ -r /go/bin/guru ] && true || exit 1 \
  && [ -r /go/bin/html2article ] && true || exit 1 \
  && [ -r /go/bin/netrcauth ] && true || exit 1 \
  && [ -r /go/bin/present ] && true || exit 1 \
  && [ -r /go/bin/present2md ] && true || exit 1 \
  && [ -r /go/bin/ssadump ] && true || exit 1 \
  && [ -r /go/bin/stress ] && true || exit 1 \
  && [ -r /go/bin/stringer ] && true || exit 1 \
  && [ -r /go/bin/toolstash ] && true || exit 1
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS go-outline-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/ramya-rao-a/go-outline" \
  && /go/bin/go-outline -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS reftools-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/davidrjenni/reftools/cmd/..." \
  && /go/bin/fillstruct -h \
  && /go/bin/fillswitch -h \
  && /go/bin/fixplurals -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gopkgs-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/uudashr/gopkgs/v2/cmd/gopkgs" \
  && /go/bin/gopkgs -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gocmt-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/cuonglm/gocmt" \
  && /go/bin/gocmt -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS go-compiles-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/palantir/go-compiles" \
  && /go/bin/go-compiles -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS nocomment-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/mohae/nocomment/cmd/nocomment" \
  && /go/bin/nocomment -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS discover-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/eandre/discover/..." \
  && /go/bin/discover -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gounit-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/hexdigest/gounit/cmd/gounit" \
  && /go/bin/gounit help
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS mockery-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/vektra/mockery/v2/..." \
  && /go/bin/mockery --version
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gorc-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/stretchr/gorc" \
  && /go/bin/gorc help
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS motion-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/fatih/motion@latest" \
  && /go/bin/motion -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS errcheck-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/kisielk/errcheck@latest" \
  && [ ! -r /go/bin/errcheck ] && exit 1 || exit 0
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS iferr-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/koron/iferr@master" \
  && /go/bin/iferr -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS golint-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "golang.org/x/lint/golint@master" \
  && /go/bin/golint -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gotags-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/jstemmer/gotags@master" \
  && /go/bin/gotags -v
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS impl-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/josharian/impl@master" \
  && [ ! -r /go/bin/impl ] && exit 1 || exit 0
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gomodifytags-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/fatih/gomodifytags@latest" \
  && /go/bin/gomodifytags -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS asmfmt-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/klauspost/asmfmt/cmd/asmfmt" \
  && [ ! -r /go/bin/asmfmt ] && exit 1 || exit 0
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS revive-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/mgechev/revive" \
  && /go/bin/revive --version
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gofumpt-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "mvdan.cc/gofumpt" \
  && /go/bin/gofumpt --version
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS honnef-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "honnef.co/go/tools/..." \
  && go get -v "honnef.co/go/tools/cmd/..." \
  && [ -r /go/bin/ast-to-pattern ] && true || exit 1 \
  && /go/bin/gogrep -h \
  && /go/bin/gosmith -h \
  && /go/bin/irdump -h \
  && /go/bin/keyify --version \
  && /go/bin/staticcheck --version \
  && /go/bin/structlayout --version \
  && /go/bin/structlayout-optimize --version \
  && /go/bin/structlayout-pretty --version
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gotests-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/cweill/gotests/...@latest" \
  && /go/bin/gotests -h
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS goplay-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/haya14busa/goplay/cmd/goplay@latest" \
  && [ ! -r /go/bin/goplay ] && exit 1 || exit 0
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS delve-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "github.com/go-delve/delve/cmd/dlv@latest" \
  && /go/bin/dlv version
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS gopls-builder
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go get -v "golang.org/x/tools/gopls@latest" \
  && /go/bin/gopls version
# ────────────────────────────────────────────────────────────────────────────────
FROM go-builder AS mage-builder
RUN \
  git clone https://github.com/magefile/mage /tmp/mage
WORKDIR /tmp/mage
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  go run bootstrap.go \
  && /go/bin/mage --version
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/upx AS compression-layer
WORKDIR /workspace/bin
COPY --from=go-tools-builder /go/bin /workspace/bin
COPY --from=go-outline-builder /go/bin /workspace/bin
COPY --from=reftools-builder /go/bin /workspace/bin
COPY --from=gopkgs-builder /go/bin /workspace/bin
COPY --from=gocmt-builder /go/bin /workspace/bin
COPY --from=go-compiles-builder /go/bin /workspace/bin
COPY --from=nocomment-builder /go/bin /workspace/bin
COPY --from=discover-builder /go/bin /workspace/bin
COPY --from=gounit-builder /go/bin /workspace/bin
COPY --from=mockery-builder /go/bin /workspace/bin
COPY --from=gorc-builder /go/bin /workspace/bin
COPY --from=motion-builder /go/bin /workspace/bin
COPY --from=errcheck-builder /go/bin /workspace/bin
COPY --from=iferr-builder /go/bin /workspace/bin
COPY --from=golint-builder /go/bin /workspace/bin
COPY --from=gotags-builder /go/bin /workspace/bin
COPY --from=impl-builder /go/bin /workspace/bin
COPY --from=gomodifytags-builder /go/bin /workspace/bin
COPY --from=asmfmt-builder /go/bin /workspace/bin
COPY --from=revive-builder /go/bin /workspace/bin
COPY --from=gofumpt-builder /go/bin /workspace/bin
COPY --from=honnef-builder /go/bin /workspace/bin
COPY --from=go-releaser-downloader /go/bin /workspace/bin
COPY --from=golang-ci-lint-downloader /go/bin /workspace/bin
COPY --from=mage-builder /go/bin /workspace/bin
COPY --from=gopls-builder /go/bin /workspace/bin
COPY --from=delve-builder /go/bin /workspace/bin
COPY --from=gomodifytags-builder /go/bin /workspace/bin
COPY --from=gotests-builder /go/bin /workspace/bin
COPY --from=goplay-builder /go/bin /workspace/bin
WORKDIR /workspace
RUN \
  compress ;
# ────────────────────────────────────────────────────────────────────────────────
FROM "fjolsvin/base-alpine"
USER root
ENV PATH /usr/local/go/bin:$PATH
ARG GOLANG_VERSION="1.17"
RUN \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  --mount=type=tmpfs,target=/go/src/ \
  set -ex ; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			export GOARCH='amd64' GOOS='linux'; \
			;; \
		'aarch64') \
			export GOARCH='arm64' GOOS='linux'; \
			;; \
		*) exit 1 ;; \
	esac; \
	apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		gnupg \
		go \
		musl-dev \
		openssl \
  && wget -qO "/tmp/go.tgz" "https://dl.google.com/go/go${GOLANG_VERSION}.src.tar.gz" \
  && tar -C /usr/local -xzf /tmp/go.tgz \
	&& rm /tmp/go.tgz \
	&& ( \
		cd /usr/local/go/src; \
		export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
		./make.bash; \
	) \
  && go install -race std \
  && apk del --no-network .build-deps \
  && go version
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"
RUN \
  mkdir -p \
    "${GOPATH}/src" \
    "${GOPATH}/bin" \
  && chmod -R 777 "${GOPATH}" \
  && chown -R "$(id -u ${USER}):$(id -g ${USER})" "${GOPATH}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN  \
  git clone https://github.com/gokultp/go-tprof.git /tmp/go-tprof \
  && make -C /tmp/go-tprof config || true ; \
  make -C /tmp/go-tprof || true ; \
  rm -rf /tmp/go-tprof
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
RUN \
  go env -w "GOPRIVATE=github.com/da-moon" \
  && go env -w "GO111MODULE=on" \
  && go env -w "CGO_ENABLED=0" \
  && go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
# ────────────────────────────────────────────────────────────────────────────────
COPY --from=compression-layer /workspace /usr/local/bin
# ─── CLEAN UP ───────────────────────────────────────────────────────────────────
USER root
RUN \
  chmod a+x /usr/local/bin/* \
  && yarn cache clean --all \
  && npm -g cache clean --force > /dev/null 2>&1 \
  && rm -rf \
    /tmp/* \
    /usr/src \
		/usr/local/go/pkg/*/cmd \
		/usr/local/go/pkg/bootstrap \
		/usr/local/go/pkg/obj \
		/usr/local/go/pkg/tool/*/api \
		/usr/local/go/pkg/tool/*/go_bootstrap \
		/usr/local/go/src/cmd/dist/dist
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ENTRYPOINT [ "/bin/bash" ]
