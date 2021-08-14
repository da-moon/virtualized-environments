# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
FROM alpine:latest
ENV TERM=xterm
USER root
ARG BASE_PACKAGES="\
  curl \
  perl \
  wget \
  tree \
  util-linux \
  git \
  ca-certificates \
  upx \
  ncurses \
  ncurses-dev \
  sudo=1.9.5p2-r0 \
  bash \
  bash-completion \
  shadow \
  libcap \
  coreutils \
  findutils \
  binutils \
  gnupg \
  grep \
  gawk \
  build-base \
  make \
  "
# python dev tools
ARG PYTHON_BUILD_PACKAGES="\
  musl \
  libc6-compat \
  linux-headers \
  libssl1.1 \
  libffi-dev \
  tzdata \
  bzip2-dev \
  dpkg-dev dpkg \
  expat-dev \
  gcc \
  gdbm-dev \
  libc-dev \
  libnsl-dev \
  libtirpc-dev \
  libressl-dev \
  pax-utils \
  readline-dev \
  sqlite-dev \
  tcl-dev \
  tk \
  tk-dev \
  util-linux-dev \
  xz-dev \
  zlib-dev \
  "

RUN set -ex && \
  apk add --no-cache ${BASE_PACKAGES} ${PYTHON_BUILD_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${PYTHON_BUILD_PACKAGES})
SHELL ["bash","-c"]
RUN set -ex && \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
RUN set -ex && \
  sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers && \
  echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
ARG PYTHON_VERSION=3.9.2
ENV PYTHON_PATH=/usr/local/bin/
ENV PYENV_ROOT="/usr/local/lib/pyenv"
ENV PATH="${PATH}:/usr/local/lib/python${PYTHON_VERSION}/bin"
ENV PATH="${PATH}:/usr/local/lib/pyenv/versions/${PYTHON_VERSION}/bin:${PATH}"
ARG CONFIGURE_OPTS="--enable-shared"
ARG CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-shared"
ARG CONFIGURE_OPTS="${CONFIGURE_OPTS} --enable-loadable-sqlite-extensions"
ARG CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-system-expat"
ARG CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-system-ffi"
ARG CONFIGURE_OPTS="${CONFIGURE_OPTS} --without-ensurepip"
RUN set -ex && \
  git clone --depth 1 https://github.com/pyenv/pyenv /usr/local/lib/pyenv ;\
  GNU_ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" ;\
  CONFIGURE_OPTS="${CONFIGURE_OPTS} --build=${GNU_ARCH}" ;\
  /usr/local/lib/pyenv/bin/pyenv install ${PYTHON_VERSION};
RUN set -ex && \
  find /usr/local/lib/pyenv \
  -mindepth 1 \
  -name versions \
  -prune \
  -o -exec rm -rf {} \; || true ;\
  find "/usr/local/lib/pyenv/versions/${PYTHON_VERSION}" \
  -depth \
  -name '*.pyo' \
  -o -name '*.pyc' \
  -o -name 'test' \
  -o -name 'tests' \
  -exec rm -rf '{}' + ;\
  ln -s /usr/local/lib/pyenv/versions/${PYTHON_VERSION}/bin/* "${PYTHON_PATH}"
# ────────────────────────────────────────────────────────────────────────────────
RUN set -ex && \
  ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN set -ex && \
  python3 --version
