# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/wrk
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:latest AS builder
ARG WRK_BUILD_PACKAGES="\
  ca-certificates \
  git \
  alpine-sdk \
  perl \
  openssl-dev \
  openssl-libs-static \
  zlib-dev \
  # zlib-static \
  "
RUN set -ex && \
  # echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
  # echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  # echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache ${WRK_BUILD_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${WRK_BUILD_PACKAGES})

# ─── INSTALLING LUA ─────────────────────────────────────────────────────────────
WORKDIR /tmp
RUN set -ex && \
  curl -R -O "http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" && \
  tar -C /tmp -zxf "/tmp/lua-${LUA_VERSION}.tar.gz" && \
  cd "/tmp/lua-${LUA_VERSION}" && \
  make linux test && \
  sudo make install && \
  lua -v
# ─── INSTALLING LUAROCKS ────────────────────────────────────────────────────────
WORKDIR /tmp
RUN set -ex && \
  wget "https://luarocks.org/releases/luarocks-${LUA_ROCKS_VERSION}.tar.gz" && \
  tar -C /tmp -zxf "/tmp/luarocks-${LUA_ROCKS_VERSION}.tar.gz" && \
  cd "/tmp/luarocks-${LUA_ROCKS_VERSION}" && \
  ./configure --with-lua-include=/usr/local/include && \
  make && \
  sudo make install && \
  luarocks --version
WORKDIR /tmp
# ─── INSTALLING LUAJIT ──────────────────────────────────────────────────────────
RUN set -ex && \
  wget "https://luajit.org/download/LuaJIT-${LUA_JIT_VERSION}.tar.gz" && \
  tar -C /tmp -zxf "/tmp/LuaJIT-${LUA_JIT_VERSION}.tar.gz" && \
  cd "/tmp/LuaJIT-${LUA_JIT_VERSION}" && \
  make && \
  sudo make install && \
  luajit -v
RUN set -ex && \
    git clone https://github.com/giltene/wrk2.git /tmp/wrk2
ENV LDFLAGS="-static-libstdc++"
ENV LDFLAGS="${LDFLAGS} -static-libgcc"
ENV LDFLAGS="${LDFLAGS} --static"
# ENV LDFLAGS="${LDFLAGS} -Wl,-Bstatic,--gc-sections"
ENV CFLAGS="-static-libgcc"
ENV CFLAGS="${CFLAGS} -Os"
ENV CFLAGS="${CFLAGS} -ffunction-sections"
ENV CFLAGS="${CFLAGS} -fdata-sections"
# ENV LDFLAGS -static-libgcc
# ENV CFLAGS -static-libgcc

WORKDIR /tmp/wrk2
RUN set -ex && \
    make -j$(nproc)

# FROM alpine:latest
# RUN apk add openssl && apk --no-cache add ca-certificates
# COPY --from=builder /wrk2/wrk /bin
