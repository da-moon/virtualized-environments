# syntax = docker/dockerfile:1.0-experimental
# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --build-arg USER=gitpod --build-arg UID=33333 --tag fjolsvin/gitpod-base:latest   .
# ────────────────────────────────────────────────────────────────────────────────

FROM debian:buster
USER root
COPY install-packages /usr/bin
ARG DEBIAN_FRONTEND=noninteractive
#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: B A S E   P A C K A G E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#
RUN chmod +x /usr/bin/install-packages && \
  yes | unminimize \
  && install-packages \
  git \
  zip \
  unzip \
  bash-completion \
  build-essential \
  bash-completion \
  make \
  ninja-build \
  bash \
  htop \
  jq \
  less \
  locales \
  man-db \
  nano \
  software-properties-common \
  sudo \
  time \
  vim \
  multitail \
  lsof \
  apt-utils \
  curl \
  lsb-release \
  wget \
  ca-certificates \
  gnupg2 \
  ssl-cert
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
#
# ──────────────────────────────────────────────────────────── I ──────────
#   :::::: U S E R   S E T U P : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────
#
ARG USER=${USER}
ENV USER $USER
ARG UID="33333"
ENV UID $UID
RUN useradd \
  --no-log-init \
  --create-home \
  --home-dir "/home/${USER}" \ 
  --groups sudo \
  --uid "${UID}" \
  --shell /bin/bash \
  --password "${USER}" \
  "${USER}" && \
  sed -i \
  -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
  /etc/sudoers
ENV HOME="/home/$USER"
WORKDIR $HOME
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
USER "${USER}"
RUN sudo echo "Running 'sudo' for ${USER}: success" && \
  mkdir -p "${HOME}/.bashrc.d" && \
  (echo; echo "for i in \$(ls \$HOME/.bashrc.d/*); do source \$i; done"; echo) | tee -a "${HOME}/.bashrc" > /dev/null

#
# ──────────────────────────────────────────────────────────────────── I ──────────
#   :::::: D O C K E R   I N S T A L L : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────
#
RUN curl \
  -fsSL \
  "https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg" | \
    sudo apt-key add - && \
  echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list && \
  yes | unminimize && \
  sudo install-packages docker-ce docker-ce-cli containerd.io
RUN curl \
  -fsSL \
  https://api.github.com/repos/docker/compose/releases/latest | jq -r ".assets[]|select(.browser_download_url | contains(\"$(uname -s)\") and contains(\"$(uname -m)\") and contains(\"x86_64\") and (contains(\"sha256\")|not)).browser_download_url" | \
  xargs -I {} sudo wget --quiet --no-cache -O /usr/local/bin/docker-compose {} && \
  sudo chmod +x /usr/local/bin/docker-compose