# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
ARG BUILD_DEPS="\
  g++ \
  make  \
  perl \
  git \
  automake \
  autoconf \
  build-base \
  libtool \
"
# hadolint ignore=DL3018,SC2086
RUN \
  set -xeu ; \
  apk add --no-cache ${BUILD_DEPS}
ARG curl_version="7.78.0"
ADD https://curl.haxx.se/download/curl-${curl_version}.tar.gz /tmp/curl.tar.gz
RUN tar -C /tmp -xvzf /tmp/curl.tar.gz
WORKDIR /tmp/curl-${curl_version}
RUN \
set -xeu ; \
autoreconf -vfi \
&& ./configure \
	--prefix=/workspace \
	--disable-ldap \
	--disable-ipv6 \
	--disable-unix-sockets \
  --disable-shared \
	--without-ssl \
	--without-libidn \
	--without-libidn2 \
	--without-libssh2 \
  --without-nghttp2 \
	--with-pic \
	--enable-static \
&& make -j$(nproc) V=1 LDFLAGS="-static -all-static" \
&& make install \
&& ldd /workspace/bin/curl && exit 1 || true
