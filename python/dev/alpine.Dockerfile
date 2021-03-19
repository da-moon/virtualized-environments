# syntax = docker/dockerfile:1.0-experimental

# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --tag fjolsvin/vscode-python:latest --build-arg USER=operator .
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:latest
ENV TERM=xterm
USER root
# ────────────────────────────────────────────────────────────────────────────────
# PATHS
ENV BASE_PACKAGES="\
  musl \
  libc6-compat \
  linux-headers \
  build-base \
  bash \
  git \
  ca-certificates \
  libssl1.1 \
  libffi-dev \
  tzdata \
  "
# python dev tools
ENV PYTHON_BUILD_PACKAGES="\
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
RUN set -ex ;\
  apk add --no-cache ${BASE_PACKAGES} ${PYTHON_BUILD_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${PYTHON_BUILD_PACKAGES})
# ────────────────────────────────────────────────────────────────────────────────
#
# ────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: B U I L D I N G   P Y T H O N : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────
#
ARG PYTHON_VERSION=3.9.2
ENV PYTHON_VERSION $PYTHON_VERSION
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
# ────────────────────────────────────────────────────────────────────────────────
ENV IMAGE_SPECIFIC_PACKAGES="\
  ca-certificates curl perl wget aria2 util-linux gnupg rng-tools-extra \
  git build-base make openssl-dev libffi-dev upx \
  ncurses ncurses-dev \
  bash bash-completion \
  sudo shadow libcap \
  coreutils findutils binutils grep gawk \
  jq yq yj yq-bash-completion \
  htop bzip2 \
  yarn nodejs \
  bat glow \
  ripgrep ripgrep-bash-completion \
  imagemagick-static libx11-static libxrandr-dev \
  tokei exa starship nushell just neofetch hyperfine asciinema \
  docker docker-compose \
  "
RUN set -ex && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${IMAGE_SPECIFIC_PACKAGES}) 
# [ NOTE ] => set timezone info
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C R E A T I N G   U S E R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#
ARG USER=operator
ENV USER $USER
ARG UID="1000"
ENV UID $UID

SHELL ["bash","-c"]
RUN getent group sudo > /dev/null || sudo addgroup sudo
RUN getent passwd "${USER}" > /dev/null && userdel --remove "${USER}" -f || true
RUN useradd --user-group --create-home --shell /bin/bash --uid "$UID" "${USER}"
RUN sed -i \
  -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' \
  -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
  /etc/sudoers
RUN usermod -aG wheel,root,sudo,docker "${USER}"
USER ${USER}
SHELL ["bash","-c"]
#
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: E N S U R I N G   C O M P I L E D   T O O L   A V A I L A B I L I T Y : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN python3 --version
#
# ──────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   U S E R   E N V I R O N M E N T : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV HOME="/home/${USER}"
ENV PATH="${PATH}:${HOME}/.local/bin"
RUN  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null && \
  echo 'PATH="${PATH}:${HOME}/.local/bin"' | tee -a ~/.bashrc > /dev/null && \
  echo 'PATH="${PATH}:${HOME}/.local/bin"' | tee -a ~/.bashrc > /dev/null && \
  echo '[ -r ${HOME}/.cargo/env ] && . ${HOME}/.cargo/env' | tee -a ~/.bashrc > /dev/null && \
  echo '[ -r ${HOME}/.poetry/env ] && . ${HOME}/.poetry/env' | tee -a ~/.bashrc > /dev/null
#
# ──────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P O E T R Y : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV PATH="${PATH}:${HOME}/.poetry/bin"
RUN mkdir -p "${HOME}/.local/bin" && \
  mkdir -p "${HOME}/.poetry/bin" && \ 
  curl -fsSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
  poetry --version
#
# ────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P I P   P A C K A G E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN python3 -m pip install pex dephell[full]
RUN dephell --version && \
  pex --version
#
# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   R U S T   T O O L C H A I N : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV PATH="$PATH:${HOME}/.cargo/bin"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
  -y \
  --default-host x86_64-unknown-linux-musl \
  --default-toolchain nightly \
  --profile default && \
  cargo --version
#
# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   C A R G O   P A C K A G E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN cargo install -j`nproc` pyoxidizer && \
  strip ${HOME}/.cargo/bin/pyoxidizer && \
  upx ${HOME}/.cargo/bin/pyoxidizer && \
  pyoxidizer --version
#
# ──────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   N U   S H E L L : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────
#
RUN nu -c 'config set path $nu.path' && \
  nu -c 'config set env  $nu.env' && \
  nu -c 'config set prompt "starship prompt"' && \
  sudo usermod --shell /usr/bin/nu "${USER}"

