# syntax = docker/dockerfile:1.0-experimental

# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --build-arg USER=operator --build-arg UID=1000 --tag fjolsvin/vscode-python-alpine:latest .
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/python-base-alpine:latest
ENV TERM=xterm
USER root
# [ NOTE ] => base essential packages
ARG BASE_PACKAGES="\
  curl \
  perl \
  wget \
  util-linux \
  git \
  ca-certificates \
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
  bzip2 \
  build-base \
  make \
  "
ARG IMAGE_SPECIFIC_PACKAGES="\
  tree \
  bat  \
  ripgrep \
  ripgrep-bash-completion \
  tokei \
  exa \
  just \
  starship \
"
RUN set -ex && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES})
# ────────────────────────────────────────────────────────────────────────────────
RUN set -ex && \
  wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && \
  chmod +x /tmp/vsls-reqs && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs && \
  bash /tmp/vsls-reqs && \
  rm /tmp/vsls-reqs
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C R E A T I N G   U S E R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#
ARG USER=code
ENV USER $USER
ARG UID="1000"
ENV UID $UID
SHELL ["bash","-c"]
RUN set -ex && \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
RUN set -ex && \
  useradd \
  --no-log-init \
  --create-home \
  --home-dir "/home/${USER}" \ 
  --uid "${UID}" \
  --groups sudo \
  --shell "/bin/bash" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}"
RUN sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers && \
  echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  usermod -aG wheel,root,sudo "${USER}"
USER ${USER}
SHELL ["bash","-c"]
ENV HOME="/home/${USER}"
RUN set -ex && \
  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null && \
  echo 'alias apk="sudo apk"' | tee -a ~/.bashrc > /dev/null
ENV POETRY_HOME="${HOME}/.poetry"
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV PATH="${PATH}:${POETRY_HOME}/bin"
RUN set -ex && \
  mkdir -p "${HOME}/.local/bin" && \
  echo 'PATH="${PATH}:${HOME}/.local/bin"' | tee -a ~/.bashrc > /dev/null && \
  mkdir -p "${POETRY_HOME}/bin" && \ 
  echo '[ -r ${POETRY_HOME}/env ] && . ${HOME}/.poetry/env' | tee -a ~/.bashrc > /dev/null && \
  curl -fsSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
  poetry --version
RUN set -ex && \
  python3 -m pip install pex dephell[full] 
RUN set -ex && \
  sudo rm -rf \
     /tmp/*
