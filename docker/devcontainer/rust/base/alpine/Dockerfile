# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/base-alpine:latest
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG BASE_PACKAGES="\
  gcc=10.3.1_git20210921-r1 \
  openssl-libs-static=3.0.0-r2 \
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
  && apk add --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${packages[@]}" \
  )
# ────────────────────────────────────────────────────────────────────────────────
COPY <<-"EOT" /usr/local/cargo/config
[target.x86_64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
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
# ENV RUSTFLAGS="-C target-cpu=native"
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
RUN \
  find "${HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} \
  && find "${RUSTUP_HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} \
  && find "${CARGO_HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} \
  && [ ! -z "${WORKDIR+x}" ] && [ ! -z "${WORKDIR}" ] && find "${WORKDIR}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} \
  && rm -rf \
    /tmp/*
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
WORKDIR "${WORKDIR}"
ENTRYPOINT [ "/bin/bash" ]