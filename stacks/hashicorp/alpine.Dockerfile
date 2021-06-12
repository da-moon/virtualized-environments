FROM golang:alpine as builder
USER root
ENV TERM xterm 
RUN set -ex && \
  apk upgrade -U -a && \
  apk add git bash findutils binutils ripgrep && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN set -ex && \
  apk add --no-cache upx || true

SHELL ["bash","-c"]

# [ NOTE ] the following builds would fail in alpine
# - nomad 
ARG PACKAGES="\
  github.com/hashicorp/consul \
  github.com/hashicorp/vault \
  github.com/hashicorp/terraform \
  github.com/hashicorp/envconsul \
  github.com/hashicorp/consul-template \
  github.com/hashicorp/consul-replicate \
  github.com/hashicorp/serf \
  github.com/hashicorp/levant \
  github.com/hashicorp/waypoint \
  github.com/hashicorp/boundary \
  github.com/hashicorp/packer \
  "
WORKDIR /workspace
RUN set -ex && \
  IFS=' ' read -a PACKAGES <<< "$PACKAGES" && \
  for pkg in ${PACKAGES[@]};do \
  mkdir -p "$(go env GOPATH)/src/$(dirname $pkg)" && \
  git clone \
  --depth 1 \
  "https://$pkg.git" \
  "$(go env GOPATH)/src/$pkg"; \
  pushd "$(go env GOPATH)/src/$pkg" > /dev/null 2>&1 && \
  [ -f "go.mod" ] && export GO111MODULE=on || export GO111MODULE=off ; \
  go get -v -d ./... && \
  popd > /dev/null 2>&1 ;\
  done;

RUN set -ex && \
  IFS=' ' read -a PACKAGES <<< "$PACKAGES" && \
  for pkg in ${PACKAGES[@]};do \
  pushd "$(go env GOPATH)/src/$pkg" > /dev/null 2>&1 && \
  [ -f "go.mod" ] && export GO111MODULE=on || export GO111MODULE=off ; \
  if $(grep -qF 'func main()' *.go) ; then \
  echo "***building $(basename $PWD)***"; \
  go build -o "/workspace/$(basename $PWD)" || true; \
  else \
  if [ -d cmd ];then \
  targets=($(rg  \
  --type 'go' \
  -l 'func main()' \
  --sort-files cmd  2> /dev/null | xargs -0 dirname |  uniq)); \
  for target in "${targets[@]}"; do \
  if [ -f $target ]; then \
  echo "***building $(basename $PWD)***"; \
  go build -o "/workspace/$(basename $PWD)" || true ; \
  else \
  echo "***building $(basename $target)***"; \
  go build -o "/workspace/$(basename $target)" ./$target || true; \
  fi \
  done; \
  fi; \
  fi; \
  done ; \
  popd  > /dev/null 2>&1
RUN set -ex && \
  if command -v "upx" >/dev/null ; then \
  find /workspace -type f | xargs -I {} -P `nproc` strip {} || true ; \
  find /workspace -type f | xargs -I {} -P `nproc` upx {} || true  ; \
  fi
FROM alpine
COPY --from=builder /workspace /workspace
RUN set -ex && \
  mv /workspace/* /usr/local/bin/ && \
  rm -rf /workspace

