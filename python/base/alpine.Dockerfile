# syntax = docker/dockerfile:1.0-experimental

# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --build-arg PYTHON_VERSION=3.9.2 --tag fjolsvin/python-base-alpine:latest .
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:latest
ENV TERM=xterm
USER root
# ────────────────────────────────────────────────────────────────────────────────
# PATHS
ARG BASE_PACKAGES="\
  musl \
  libc6-compat \
  linux-headers \
  build-base \
  bash \
  git \
  sudo \
  ca-certificates \
  libssl1.1 \
  libffi-dev \
  tzdata \
  "
# python dev tools
ARG PYTHON_BUILD_PACKAGES="\
  bzip2-dev \
  coreutils \
  dpkg-dev dpkg \
  expat-dev \
  findutils \
  gcc \
  gdbm-dev \
  libc-dev \
  libffi-dev \
  libnsl-dev \
  libtirpc-dev \
  linux-headers \
  make \
  ncurses-dev \
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
  git \
  "
RUN set -ex && \
  apk add --no-cache ${BASE_PACKAGES} ${PYTHON_BUILD_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${PYTHON_BUILD_PACKAGES})
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["bash","-c"]
# ────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: B U I L D I N G   P Y T H O N : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────
#
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