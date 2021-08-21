# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/base-alpine:latest
# ────────────────────────────────────────────────────────────────────────────────
USER root
# build-base=0.5-r2 \
# ca-certificates=20191127-r5 \
# cmake=3.21.1-r0 \
# coreutils=8.32-r2 \
# curl=7.78.0-r0 \
# findutils=4.8.0-r1 \
# gcc=10.3.1_git20210625-r0 \
# git=2.32.0-r2 \
# make=4.3-r0 \
# musl-dev=1.2.2-r5 \
# ncurses-static=6.2_p20210731-r0 \
# openssl-dev=1.1.1k-r1 \
# openssl-libs-static=1.1.1k-r1 \
# perl=5.34.0-r0 \
ARG BASE_PACKAGES="\
  gcc=10.3.1_git20210625-r0 \
  openssl-libs-static=1.1.1k-r1 \
  "
RUN \
  IFS=' ' read -a packages <<< $BASE_PACKAGES ; \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --update --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache "${packages[@]}" \
  )
# ────────────────────────────────────────────────────────────────────────────────
COPY <<-"EOT" /usr/local/cargo/config
[target.x86_64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.armv7-unknown-linux-musleabihf]
  linker = "arm-linux-gnueabihf-gcc"
EOT
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG RUST_VERSION="1.54.0"
ARG RUSTUP_URL="https://sh.rustup.rs"
ENV RUSTUP_HOME="/usr/local/rustup"
ENV CARGO_HOME="/usr/local/cargo"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ENV RUST_VERSION "${RUST_VERSION}"
RUN \
  case "$(apk --print-arch)" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  curl --proto '=https' --tlsv1.2 -fSsl "${RUSTUP_URL}" | bash -s -- -y \
  --no-modify-path \
  --profile default \
  --default-toolchain "${RUST_VERSION}" \
  --default-host "$(apk --print-arch)-unknown-linux-musl" \
  && chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}" \
  && chown "$(id -u ${USER}):$(id -g ${USER})" "${RUSTUP_HOME}" -R \
  && chown "$(id -u ${USER}):$(id -g ${USER})" "${CARGO_HOME}" -R
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ENV RUSTFLAGS="-C target-cpu=native"
ENV OPENSSL_STATIC=yes
ENV OPENSSL_LIB_DIR="/usr/lib"
ENV OPENSSL_INCLUDE_DIR="/usr/include"
RUN \
  rustup --version \
  && cargo --version \
  && rustc --version \
  && rustup toolchain install "nightly-$(apk --print-arch)-unknown-linux-musl" \
  && rustup default "stable-$(apk --print-arch)-unknown-linux-musl" \
  && rustup component add rust-src rustfmt rls clippy
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
# cargo-make : fails to build on aarch64
ARG CARGO_PACKAGES="\
  cargo-watch \
  "
RUN \
  rustup default stable ; \
  IFS=' ' read -a packages <<< "${CARGO_PACKAGES}" ; \
  cargo install --locked --all-features --root /usr/local "${packages[@]}"
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ARG WORKDIR="/workspace"
ENV WORKDIR "${WORKDIR}"
WORKDIR "${WORKDIR}"
ENTRYPOINT [ "/bin/bash" ]
