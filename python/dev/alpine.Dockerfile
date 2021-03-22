# syntax = docker/dockerfile:1.0-experimental

# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --build-arg USER=operator --build-arg UID=1000 --tag fjolsvin/vscode-python:latest .
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/python-base:latest
ENV TERM=xterm
USER root
# [ NOTE ] => base essential packages
ENV BASE_PACKAGES="\
  curl \
  perl \
  wget \
  util-linux \
  git \
  ca-certificates \
  ncurses \
  bash \
  bash-completion \
  sudo \
  shadow \
  libcap \
  coreutils \
  findutils \
  binutils \
  gnupg \
  grep \
  gawk \
  "

# ────────────────────────────────────────────────────────────────────────────────
ENV IMAGE_SPECIFIC_PACKAGES="\
  aria2  rng-tools-extra \
  build-base make openssl-dev libffi-dev upx \
  ncurses ncurses-dev \
  jq yq yj yq-bash-completion \
  htop bzip2 \
  yarn nodejs \
  bat glow \
  ripgrep ripgrep-bash-completion \
  imagemagick-static libx11-static libxrandr-dev \
  tokei exa starship nerd-fonts nushell just neofetch hyperfine asciinema \
  docker docker-compose \
  "
RUN set -ex && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES}) 
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
RUN  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
# ──────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P O E T R Y : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV POETRY_HOME="${HOME}/.poetry"
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV PATH="${PATH}:${POETRY_HOME}/bin"
RUN mkdir -p "${HOME}/.local/bin" && \
  echo 'PATH="${PATH}:${HOME}/.local/bin"' | tee -a ~/.bashrc > /dev/null && \
  echo 'alias apk="sudo apk"' | tee -a ~/.bashrc > /dev/null && \
  mkdir -p "${POETRY_HOME}/bin" && \ 
  echo '[ -r ${POETRY_HOME}/env ] && . ${HOME}/.poetry/env' | tee -a ~/.bashrc > /dev/null && \
  curl -fsSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
  poetry --version

# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   R U S T   T O O L C H A I N : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV PATH="$PATH:${HOME}/.cargo/bin"
RUN echo '[ -r ${HOME}/.cargo/env ] && . ${HOME}/.cargo/env' | tee -a ~/.bashrc > /dev/null && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
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
