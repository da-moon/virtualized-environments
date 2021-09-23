# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
FROM rust:alpine AS alpine-base
USER root
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    apk upgrade -U -a && \
    apk add curl bash coreutils findutils binutils build-base make git bash ncurses upx  && \
    # [ NOTE ] hacky way to update index
    cargo search hello-world
SHELL ["bash","-c"]
WORKDIR /workspace
FROM alpine-base AS mdbook-downloader
ARG MDBOOK_VERSION=0.4.8
ARG URL="https://github.com/rust-lang-nursery/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
RUN \
    set -ex && \
    curl -fLO "${URL}"
RUN \
    set -ex && \
    tar xf "mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
RUN \
    set -ex && \
    rm -f "mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
FROM alpine-base AS cargo-about-downloader
ARG CARGO_ABOUT_VERSION=0.2.3
ARG URL="https://github.com/EmbarkStudios/cargo-about/releases/download/${CARGO_ABOUT_VERSION}/cargo-about-${CARGO_ABOUT_VERSION}-x86_64-unknown-linux-musl.tar.gz"
RUN \
    set -ex && \
    curl -fLO "${URL}"
RUN \
    set -ex && \
    tar xf "cargo-about-${CARGO_ABOUT_VERSION}-x86_64-unknown-linux-musl.tar.gz"
RUN \
    set -ex && \
    mv \
    "cargo-about-${CARGO_ABOUT_VERSION}-x86_64-unknown-linux-musl/cargo-about" \
    /workspace/
RUN \
    set -ex && \
    rm -rf \
    "cargo-about-${CARGO_ABOUT_VERSION}-x86_64-unknown-linux-musl.tar.gz" "cargo-about-${CARGO_ABOUT_VERSION}-x86_64-unknown-linux-musl"
FROM alpine-base AS cargo-deny-downloader
ARG CARGO_DENY_VERSION=0.8.5
ARG URL="https://github.com/EmbarkStudios/cargo-deny/releases/download/${CARGO_DENY_VERSION}/cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl.tar.gz"
RUN \
    set -ex && \
    curl -fLO "${URL}"
RUN \
    set -ex && \
    tar xf "cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl.tar.gz"
RUN \
    set -ex && \
    mv \
    "cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl/cargo-deny" \
    /workspace/
RUN \
    set -ex && \
    rm -rf \
    "cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl" \
    "cargo-deny-${CARGO_DENY_VERSION}-x86_64-unknown-linux-musl.tar.gz"
FROM alpine-base AS cargo-deb-builder
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    cargo install cargo-deb && \
    strip /usr/local/cargo/bin/cargo-deb || true &&  \
    upx /usr/local/cargo/bin/cargo-deb || true
FROM alpine-base AS cargo-watch-builder
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    cargo install cargo-watch && \
    strip /usr/local/cargo/bin/cargo-watch || true &&  \
    upx /usr/local/cargo/bin/cargo-watch || true
FROM alpine-base AS cargo-cache-builder
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    cargo install cargo-cache && \
    strip /usr/local/cargo/bin/cargo-cache || true &&  \
    upx /usr/local/cargo/bin/cargo-cache || true
FROM alpine-base AS cargo-tree-builder
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    cargo install cargo-tree && \
    strip /usr/local/cargo/bin/cargo-tree || true &&  \
    upx /usr/local/cargo/bin/cargo-tree || true
FROM alpine-base AS mdbook-graphviz-builder
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    cargo install mdbook-graphviz && \
    strip /usr/local/cargo/bin/mdbook-graphviz || true &&  \
    upx /usr/local/cargo/bin/mdbook-graphviz || true
FROM alpine-base AS just-builder
RUN \
    --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/usr/local/cargo/registry \
    set -ex && \
    cargo install just && \
    strip /usr/local/cargo/bin/just || true &&  \
    upx /usr/local/cargo/bin/just || true
FROM debian:buster as debian-base
USER root
ENV DEBIAN_FRONTEND=noninteractive
ARG SCRIPTS_BASE_URL="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash"
RUN \
    set -ex; \
    apt-get update && \
    apt-get install -yq curl
RUN \
    set -ex; \
    [ -r /usr/local/bin/install-packages ] || \
    curl -fssL \
    -o /usr/local/bin/install-packages \
    ${SCRIPTS_BASE_URL}/docker/install-packages && \
    chmod +x /usr/local/bin/install-packages
ARG BASE_PACKAGES="\
    zip \
    unzip \
    perl \
    bash-completion \
    make \
    bash \
    less \
    locales \
    man-db \
    time \
    multitail \
    lsof \
    apt-utils \
    lsb-release \
    wget \
    ca-certificates \
    gnupg2 \
    ssl-cert \
    #
    build-essential \
    cmake \
    curl \
    file \
    git \
    graphviz \
    musl-dev \
    musl-tools \
    libpq-dev \
    libsqlite-dev \
    libssl-dev \
    linux-libc-dev \
    pkgconf \
    sudo \
    xutils-dev \
    "
RUN \
    set -ex; \
    install-packages ${BASE_PACKAGES} && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    ln -s "/usr/bin/g++" "/usr/bin/musl-g++"
SHELL ["bash","-c"]
RUN \
    set -ex && \
    sed -i \
    -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
    -e '/%sudo.*NOPASSWD:ALL/d' \
    /etc/sudoers && \
    echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
ENV PATH="/usr/local/musl/bin:${PATH}"
FROM debian-base
ARG OPENSSL_VERSION=1.1.1i
RUN \
    set -ex && \
    ls /usr/include/linux && \
    mkdir -p /usr/local/musl/include && \
    ln -s /usr/include/linux /usr/local/musl/include/linux && \
    ln -s /usr/include/x86_64-linux-gnu/asm /usr/local/musl/include/asm && \
    ln -s /usr/include/asm-generic /usr/local/musl/include/asm-generic && \
    cd /tmp && \
    short_version="$(echo "$OPENSSL_VERSION" | sed s'/[a-z]$//' )" && \
    curl -fLO "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" || \
    curl -fLO "https://www.openssl.org/source/old/$short_version/openssl-${OPENSSL_VERSION}.tar.gz" && \
    tar xvzf "openssl-${OPENSSL_VERSION}.tar.gz" && cd "openssl-${OPENSSL_VERSION}" && \
    env CC=musl-gcc ./Configure no-shared no-zlib -fPIC --prefix=/usr/local/musl -DOPENSSL_NO_SECURE_MEMORY linux-x86_64 && \
    env C_INCLUDE_PATH=/usr/local/musl/include/ make depend && \
    env C_INCLUDE_PATH=/usr/local/musl/include/ make && \
    make install && \
    rm /usr/local/musl/include/linux /usr/local/musl/include/asm /usr/local/musl/include/asm-generic && \
    rm -r /tmp/*
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl/
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1

ARG ZLIB_VERSION=1.2.11
RUN \
    set -ex && \
    cd /tmp && \
    curl -fLO "http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" && \
    tar xzf "zlib-${ZLIB_VERSION}.tar.gz" && cd "zlib-${ZLIB_VERSION}" && \
    CC=musl-gcc ./configure --static --prefix=/usr/local/musl && \
    make && make install && \
    rm -r /tmp/*
ARG POSTGRESQL_VERSION=11.9
RUN \
    set -ex && \
    cd /tmp && \
    curl -fLO "https://ftp.postgresql.org/pub/source/v${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.tar.gz" && \
    tar xzf "postgresql-${POSTGRESQL_VERSION}.tar.gz" && cd "postgresql-${POSTGRESQL_VERSION}" && \
    CC=musl-gcc CPPFLAGS=-I/usr/local/musl/include LDFLAGS=-L/usr/local/musl/lib ./configure --with-openssl --without-readline --prefix=/usr/local/musl && \
    cd src/interfaces/libpq && make all-static-lib && make install-lib-static && \
    cd ../../bin/pg_config && make && make install && \
    rm -r /tmp/*
ENV PQ_LIB_STATIC_X86_64_UNKNOWN_LINUX_MUSL=1
ENV PG_CONFIG_X86_64_UNKNOWN_LINUX_GNU=/usr/bin/pg_config

ENV RUST_HOME="/opt/rust"
ENV RUSTUP_HOME="${RUST_HOME}/rustup"
ENV CARGO_HOME="${RUST_HOME}/cargo"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ARG TOOLCHAIN=nightly
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN --profile default --no-modify-path && \
    rustup target add x86_64-unknown-linux-musl
RUN \
    set -ex && \
    echo -e "\n\
    [build]\n\
    target = 'x86_64-unknown-linux-musl'\n\
    [target.armv7-unknown-linux-musleabihf]\n\
    linker = 'arm-linux-gnueabihf-gcc'\
    " >> ${CARGO_HOME}/config
ENV PKG_CONFIG_ALLOW_CROSS=true
ENV PKG_CONFIG_ALL_STATIC=true
ENV LIBZ_SYS_STATIC=1
ENV TARGET=musl
RUN \
    set -ex && \
    rustup component add rust-src rustfmt rls clippy
# [ NOTE ] => cargo-audit needs openssl
RUN \
    set -ex && \
    cargo install cargo-audit && \
    strip ${CARGO_HOME}/bin/cargo-audit || true &&  \
    upx ${CARGO_HOME}/bin/cargo-audit || true
COPY --chmod=0755 --from=mdbook-downloader "/workspace/mdbook" "${CARGO_HOME}/bin/"
COPY --chmod=0755 --from=cargo-about-downloader "/workspace/cargo-about" "${CARGO_HOME}/bin/"
COPY --chmod=0755 --from=cargo-deny-downloader "/workspace/cargo-deny" "${CARGO_HOME}/bin/"
COPY --chmod=0755 --from=cargo-deb-builder "/usr/local/cargo/bin/cargo-deb" "${CARGO_HOME}/bin/"
COPY --chmod=0755 --from=cargo-watch-builder "/usr/local/cargo/bin/cargo-watch" "${CARGO_HOME}/bin"
COPY --chmod=0755 --from=cargo-cache-builder "/usr/local/cargo/bin/cargo-cache" "${CARGO_HOME}/bin"
COPY --chmod=0755 --from=cargo-tree-builder "/usr/local/cargo/bin/cargo-tree" "${CARGO_HOME}/bin/"
COPY --chmod=0755 --from=just-builder "/usr/local/cargo/bin/just" "${CARGO_HOME}/bin"
COPY --chmod=0755 --from=mdbook-graphviz-builder "/usr/local/cargo/bin/mdbook-graphviz" "${CARGO_HOME}/bin"
RUN \
    set -ex && \
    rm -rf "${CARGO_HOME}/registry/" && \
    # [ NOTE ] Hacky way to quickly chown recursively
    # as chgrp -hR or chown -R are super slow
    # https://github.com/docker/for-linux/issues/388#issuecomment-685410250
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf "/tmp/*"
ENTRYPOINT [ "/bin/bash" ]
