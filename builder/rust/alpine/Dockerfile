# syntax = docker/dockerfile-upstream:master-labs
FROM rust:alpine
USER root
COPY <<-"EOT" /usr/local/bin/build
#!/usr/bin/env bash
set -euxo pipefail
if [ $# = 0 ]; then
  echo >&2 "*** No crates specified"
  exit 1
fi
# [ NOTE ] => turn a space delinated string into an array
IFS=' ' read -a CRATES <<< $@ ;
apkArch="$(apk --print-arch)";
for crate in "${CRATES[@]}"; do 
  echo >&2 "[ INFO ] building: $crate";
  case "$apkArch" in
    x86_64|aarch64)
      cargo install --root "/workspace" -j `nproc` --target "$(apk --print-arch)-unknown-linux-musl" "${crate}" \
      ;;
    *) 
      echo >&2 "[ WARN ] unsupported architecture: $apkArch";
      continue
    ;;
  esac;
  find /workspace/bin \
    -type f \
    -executable \
    -exec sh -c "file -i '{}' | grep -q 'x-executable; charset=binary'" \; \
    -print0 \
    | xargs \
        -0 \
        -P `nproc` \
        --no-run-if-empty \
        mv {} /workspace/ ;
  rm -rf "/workspace/bin" ;
done ;
find /workspace -type f -exec grep -IL /workspace "rm {}" \;
EOT
COPY <<-"EOT" /usr/local/cargo/config
[target.x86_64-unknown-linux-musl]
rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
rustflags = ["-C", "target-feature=+crt-static"]
[target.armv7-unknown-linux-musleabihf]
linker = "arm-linux-gnueabihf-gcc"
EOT

WORKDIR "/workspace"
ARG BASE_PACKAGES="\
  alpine-sdk \
  build-base \
  musl-dev \
  ncurses-static \
  ca-certificates \
  git \
  make \
  cmake \
  openssl-dev \
  openssl-libs-static \
  bash \
  findutils \
  coreutils \
"
ENV OPENSSL_STATIC=yes
ENV OPENSSL_LIB_DIR="/usr/lib"
ENV OPENSSL_INCLUDE_DIR="/usr/include"
RUN \
  chmod +x /usr/local/bin/* ; \
  ( \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null ; \
  apk upgrade --no-cache -U -a \
  && apk add --update --no-cache ${BASE_PACKAGES} \
  || ( \
    sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
    && apk add --update --no-cache ${BASE_PACKAGES} \
  )
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  set -ex \
  # [ NOTE ] hacky way to update index
  && cargo search hello-world
SHELL ["bash","-c"]
ENTRYPOINT [ "bash","/usr/local/bin/build"]
