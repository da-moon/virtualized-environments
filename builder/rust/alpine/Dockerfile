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
  [ ! -f ${CARGO_HOME}/config ] && ln -s /root/cargo.toml ${CARGO_HOME}/config ;
  echo >&2 "[ INFO ] building: $crate";
  case "$apkArch" in
    x86_64|aarch64)
      cargo install --root "/workspace" -j `nproc` --target "$(apk --print-arch)-unknown-linux-musl" "${crate}" \
      || ( rm -f ${CARGO_HOME}/config && cargo install --root "/workspace" -j `nproc` --target "$(apk --print-arch)-unknown-linux-musl" "${crate}" )
      ;;
    aarch64) 
      cargo install --root "/workspace" -j `nproc` "${crate}" || true
      ;;
    *) 
      echo >&2 "[ WARN ] unsupported architecture: $apkArch";
      continue
    ;;
  esac;
  mv -f /workspace/bin/* "/workspace/";
  rm -rf "/workspace/bin" ;
done ;
find /workspace -type f -exec grep -IL /workspace "rm {}" \;
EOT
COPY <<-"EOT" /root/cargo.toml
[target.x86_64-unknown-linux-musl]
rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
rustflags = ["-C", "target-feature=+crt-static"]
[target.armv7-unknown-linux-musleabihf]
linker = "arm-linux-gnueabihf-gcc"
EOT

WORKDIR "/workspace"
ARG BASE_PACKAGES="\
  musl-dev \
  ncurses-static \
  ca-certificates \
  git \
  make \
  cmake \
  openssl-libs-static \
  bash \
  findutils \
  coreutils \
"
RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories \
  && apk add --no-cache --upgrade apk-tools \
  && apk upgrade --no-cache -U -a \
  && chmod +x /usr/local/bin/* \
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
ENTRYPOINT [ "bash" ]
