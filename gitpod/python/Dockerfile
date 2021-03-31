# syntax = docker/dockerfile:1.0-experimental
# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --build-arg USER=gitpod --build-arg PYTHON_VERSION=3.9.2 --tag fjolsvin/gitpod-python:latest   .
# ────────────────────────────────────────────────────────────────────────────────

FROM fjolsvin/gitpod-base:latest
ARG PYTHON_VERSION=3.9.2
ENV PYTHON_VERSION $PYTHON_VERSION
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND=noninteractive
# ────────────────────────────────────────────────────────────────────────────────
#
# ────────────────────────────────────────────────────────────── I ──────────
#   :::::: P Y E N V   S E T U P : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────
#
USER "root"
ENV PYTHON_BUILD_PACKAGES="\
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
  sudo install-packages ${PYTHON_BUILD_PACKAGES}
ENV PYTHON_PATH=/usr/local/bin/
ENV PYENV_ROOT="/usr/local/lib/pyenv"
ENV PATH="${PATH}:/usr/local/lib/python${PYTHON_VERSION}/bin"
ENV PATH="${PATH}:/usr/local/lib/pyenv/versions/${PYTHON_VERSION}/bin:${PATH}"
ENV CONFIGURE_OPTS="--enable-shared" 
ENV CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-shared" 
ENV CONFIGURE_OPTS="${CONFIGURE_OPTS} --enable-loadable-sqlite-extensions"
ENV CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-system-expat" 
ENV CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-system-ffi" 
ENV CONFIGURE_OPTS="${CONFIGURE_OPTS} --without-ensurepip" 
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
ENV IMAGE_SPECIFIC_PACKAGES="\
  upx \
  "
RUN set -ex && \
  sudo install-packages ${IMAGE_SPECIFIC_PACKAGES}
#
# ──────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P A C K A G E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  sudo python3 -m pip install --no-cache-dir --upgrade pip
ENV PIP_PACKAGES="\
  setuptools \
  wheel \
  virtualenv \
  pipenv \
  pylint \
  rope \
  flake8 \
  mypy \
  autopep8 \
  pep8 \
  pylama \
  pydocstyle \
  bandit \
  notebook \
  twine\
  "
RUN set -ex && \
  sudo  python3 -m pip install --no-cache-dir --upgrade ${PIP_PACKAGES}
#
# ──────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P O E T R Y : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────
#
USER "$USER"
ENV POETRY_HOME="${HOME}/.poetry"
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV PATH="${PATH}:${POETRY_HOME}/bin"
RUN set -ex && \
  mkdir -p "${HOME}/.local/bin" && \
  mkdir -p "${POETRY_HOME}/bin" && \ 
  echo 'echo >&2 "*** sourced 60-python ***"' | tee -a "$HOME/.bashrc.d/60-python" && \
  echo '[ -r ${POETRY_HOME}/env ] && . ${HOME}/.poetry/env' | tee -a "$HOME/.bashrc.d/60-python" && \
  curl -fsSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
  poetry --version

# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   R U S T   T O O L C H A I N : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV PATH="$PATH:${HOME}/.cargo/bin"
RUN set -ex && \
  echo '[ -r ${HOME}/.cargo/env ] && . ${HOME}/.cargo/env' | tee -a  "$HOME/.bashrc.d/70-rust" > /dev/null && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
  -y \
  --default-toolchain nightly \
  --profile default && \
  cargo --version
#
# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   C A R G O   P A C K A G E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  cargo install -j`nproc` pyoxidizer && \
  strip ${HOME}/.cargo/bin/pyoxidizer && \
  upx ${HOME}/.cargo/bin/pyoxidizer && \
  pyoxidizer --version
RUN set -ex && \
  sudo rm -rf /tmp/*
ENV PIP_USER=false