FROM debian:buster
ARG TOOLCHAIN=nightly
ARG OPENSSL_VERSION=1.1.1i
ARG MDBOOK_VERSION=0.4.5
ARG CARGO_ABOUT_VERSION=0.2.3
ARG CARGO_DENY_VERSION=0.8.5
ARG ZLIB_VERSION=1.2.11
ARG POSTGRESQL_VERSION=11.9
RUN apt-get update && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get install -yq \
  build-essential cmake curl \
  file git graphviz \
  musl-dev musl-tools libpq-dev \
  libsqlite-dev libssl-dev linux-libc-dev \
  pkgconf sudo xutils-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && \
  useradd rust --user-group --create-home --shell /bin/bash --groups sudo && \
  curl -fLO https://github.com/rust-lang-nursery/mdBook/releases/download/v$MDBOOK_VERSION/mdbook-v$MDBOOK_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
  tar xf mdbook-v$MDBOOK_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
  mv mdbook /usr/local/bin/ && \
  rm -f mdbook-v$MDBOOK_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
  curl -fLO https://github.com/EmbarkStudios/cargo-about/releases/download/$CARGO_ABOUT_VERSION/cargo-about-$CARGO_ABOUT_VERSION-x86_64-unknown-linux-musl.tar.gz && \
  tar xf cargo-about-$CARGO_ABOUT_VERSION-x86_64-unknown-linux-musl.tar.gz && \
  mv cargo-about-$CARGO_ABOUT_VERSION-x86_64-unknown-linux-musl/cargo-about /usr/local/bin/ && \
  rm -rf cargo-about-$CARGO_ABOUT_VERSION-x86_64-unknown-linux-musl.tar.gz cargo-about-$CARGO_ABOUT_VERSION-x86_64-unknown-linux-musl && \
  curl -fLO https://github.com/EmbarkStudios/cargo-deny/releases/download/$CARGO_DENY_VERSION/cargo-deny-$CARGO_DENY_VERSION-x86_64-unknown-linux-musl.tar.gz && \
  tar xf cargo-deny-$CARGO_DENY_VERSION-x86_64-unknown-linux-musl.tar.gz && \
  mv cargo-deny-$CARGO_DENY_VERSION-x86_64-unknown-linux-musl/cargo-deny /usr/local/bin/ && \
  rm -rf cargo-deny-$CARGO_DENY_VERSION-x86_64-unknown-linux-musl cargo-deny-$CARGO_DENY_VERSION-x86_64-unknown-linux-musl.tar.gz
RUN ln -s "/usr/bin/g++" "/usr/bin/musl-g++"
RUN echo "Building OpenSSL" && \
  ls /usr/include/linux && \
  mkdir -p /usr/local/musl/include && \
  ln -s /usr/include/linux /usr/local/musl/include/linux && \
  ln -s /usr/include/x86_64-linux-gnu/asm /usr/local/musl/include/asm && \
  ln -s /usr/include/asm-generic /usr/local/musl/include/asm-generic && \
  cd /tmp && \
  short_version="$(echo "$OPENSSL_VERSION" | sed s'/[a-z]$//' )" && \
  curl -fLO "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" || \
  curl -fLO "https://www.openssl.org/source/old/$short_version/openssl-$OPENSSL_VERSION.tar.gz" && \
  tar xvzf "openssl-$OPENSSL_VERSION.tar.gz" && cd "openssl-$OPENSSL_VERSION" && \
  env CC=musl-gcc ./Configure no-shared no-zlib -fPIC --prefix=/usr/local/musl -DOPENSSL_NO_SECURE_MEMORY linux-x86_64 && \
  env C_INCLUDE_PATH=/usr/local/musl/include/ make depend && \
  env C_INCLUDE_PATH=/usr/local/musl/include/ make && \
  make install && \
  rm /usr/local/musl/include/linux /usr/local/musl/include/asm /usr/local/musl/include/asm-generic && \
  rm -r /tmp/*
RUN echo "Building zlib" && \
  cd /tmp && \
  curl -fLO "http://zlib.net/zlib-$ZLIB_VERSION.tar.gz" && \
  tar xzf "zlib-$ZLIB_VERSION.tar.gz" && cd "zlib-$ZLIB_VERSION" && \
  CC=musl-gcc ./configure --static --prefix=/usr/local/musl && \
  make && make install && \
  rm -r /tmp/*
RUN echo "Building libpq" && \
  cd /tmp && \
  curl -fLO "https://ftp.postgresql.org/pub/source/v$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.tar.gz" && \
  tar xzf "postgresql-$POSTGRESQL_VERSION.tar.gz" && cd "postgresql-$POSTGRESQL_VERSION" && \
  CC=musl-gcc CPPFLAGS=-I/usr/local/musl/include LDFLAGS=-L/usr/local/musl/lib ./configure --with-openssl --without-readline --prefix=/usr/local/musl && \
  cd src/interfaces/libpq && make all-static-lib && make install-lib-static && \
  cd ../../bin/pg_config && make && make install && \
  rm -r /tmp/*
ENV RUSTUP_HOME=/opt/rust/rustup \
  PATH=/home/rust/.cargo/bin:/opt/rust/cargo/bin:/usr/local/musl/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN curl https://sh.rustup.rs -sSf | \
  env CARGO_HOME=/opt/rust/cargo \
  sh -s -- -y --default-toolchain $TOOLCHAIN --profile default --no-modify-path && \
  rustup target add x86_64-unknown-linux-musl
RUN echo "\n\
  [build]\n\
  target = 'x86_64-unknown-linux-musl'\n\
  [target.armv7-unknown-linux-musleabihf]\n\
  linker = 'arm-linux-gnueabihf-gcc'\
  " >> /opt/rust/cargo/config
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl/ \
  X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1 \
  PQ_LIB_STATIC_X86_64_UNKNOWN_LINUX_MUSL=1 \
  PG_CONFIG_X86_64_UNKNOWN_LINUX_GNU=/usr/bin/pg_config \
  PKG_CONFIG_ALLOW_CROSS=true \
  PKG_CONFIG_ALL_STATIC=true \
  LIBZ_SYS_STATIC=1 \
  TARGET=musl
RUN sed -i.bak -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
RUN env CARGO_HOME=/opt/rust/cargo rustup component add rust-src rustfmt rls clippy
RUN env CARGO_HOME=/opt/rust/cargo cargo install -j$(nproc) -f cargo-audit cargo-deb cargo-watch cargo-cache cargo-tree && \
  env CARGO_HOME=/opt/rust/cargo cargo install -j$(nproc) -f mdbook-graphviz tojson petname systemfd && \
  rm -rf /opt/rust/cargo/registry/
USER rust
RUN mkdir -p /home/rust/libs /home/rust/src /home/rust/.cargo && \
  ln -s /opt/rust/cargo/config /home/rust/.cargo/config
WORKDIR /home/rust/src
RUN export DEBIAN_FRONTEND=noninteractive; \
  sudo apt-get update && \
  sudo apt-get install -y apt-utils && \
  sudo apt-get install -y findutils coreutils binutils \
  curl aria2 wget bash build-essential git \
  rename make sudo ncdu jq upx && \
  sudo apt-get upgrade -y
RUN export DEBIAN_FRONTEND=noninteractive; \
  sudo apt-get autoremove -y && \
  sudo apt-get clean -y && \
  sudo rm -rf "/tmp/*"
