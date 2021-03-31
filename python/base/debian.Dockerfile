# syntax = docker/dockerfile:1.0-experimental
# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file debian.Dockerfile --build-arg PYTHON_VERSION=3.9.2 --tag fjolsvin/python-base-debian:latest .
# ────────────────────────────────────────────────────────────────────────────────

FROM debian:buster
USER root
ENV DEBIAN_FRONTEND=noninteractive
#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: B A S E   P A C K A G E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#
ARG SCRIPTS_BASE_URL="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash"
RUN set -ex; \
  apt-get update && \
  apt-get install -yq curl apt-utils man-db
RUN set -ex; \
  [ -r /usr/local/bin/install-packages ] || \
      curl -fssL \
      -o /usr/local/bin/install-packages \
      ${SCRIPTS_BASE_URL}/docker/install-packages && \
      chmod +x /usr/local/bin/install-packages
ARG ESSENTIAL_PACKAGES="\
  git \
  zip \
  unzip \
  openssl \
  bash-completion \
  build-essential \
  make \
  sudo \
  time \
  locales \
  wget \
  ca-certificates \
  gnupg2 \
  ssl-cert \
  "
RUN set -ex; \
  install-packages ${ESSENTIAL_PACKAGES}
 
RUN set -ex; \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales

ARG PYTHON_VERSION=3.9.2
ENV SHELL="/bin/bash"

ARG PYTHON_BUILD_PACKAGES="\
  libreadline-gplv2-dev \
  libncursesw5-dev \
  libssl-dev \
  libsqlite3-dev \
  tk-dev \
  libgdbm-dev \
  libc6-dev \
  libbz2-dev \
  libffi-dev \
  "
RUN set -ex && \
  install-packages ${PYTHON_BUILD_PACKAGES}
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
RUN set -ex ;\
  git clone --depth 1 https://github.com/pyenv/pyenv /usr/local/lib/pyenv ;\
  GNU_ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" ;\
  CONFIGURE_OPTS="${CONFIGURE_OPTS} --build=${GNU_ARCH}" ;\
  /usr/local/lib/pyenv/bin/pyenv install ${PYTHON_VERSION};
RUN set -ex ;\ 
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
RUN set -ex && \
  python --version
ARG BASE_PACKAGES="\
  upx \
  perl \
  less \
  nano \
  software-properties-common \
  vim \
  multitail \
  lsof \
  lsb-release \
  "
RUN set -ex && \
  install-packages ${BASE_PACKAGES}