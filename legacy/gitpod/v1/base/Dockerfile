# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

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
  apt-get install -yq curl
RUN set -ex; \
  [ -r /usr/local/bin/install-packages ] || \
      curl -fssL \
      -o /usr/local/bin/install-packages \
      ${SCRIPTS_BASE_URL}/docker/install-packages && \
      chmod +x /usr/local/bin/install-packages
RUN set -ex; \
  install-packages \
  git \
  zip \
  unzip \
  rsync \
  openssh-server \
  openssl \
  perl \
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
  ssl-cert \
  # X11
  libx11-xcb-dev \
  libasound2 \
  openssh-server \
  xauth
RUN set -ex; \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales
#
# ────────────────────────────────────────────────────────── I ──────────
#   :::::: S S H   S E T U P : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*PasswordAuthentication.*/d" /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" | tee -a /etc/ssh/sshd_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*PermitRootLogin.*/d" /etc/ssh/sshd_config && \
  echo "PermitRootLogin no" | tee -a /etc/ssh/sshd_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*UsePAM.*/d" /etc/ssh/sshd_config && \
  echo "UsePAM no" | tee -a /etc/ssh/sshd_config
RUN [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*PubkeyAuthentication.*/d" /etc/ssh/sshd_config && \
  echo "PubkeyAuthentication yes" | tee -a /etc/ssh/sshd_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*ForwardX11.*/d" /etc/ssh/ssh_config && \
  echo "ForwardX11 yes" | tee -a /etc/ssh/ssh_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*ForwardX11Trusted.*/d" /etc/ssh/ssh_config && \
  echo "ForwardX11Trusted yes" | tee -a /etc/ssh/ssh_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*PasswordAuthentication.*/d" /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" | tee -a /etc/ssh/sshd_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*X11UseLocalhost.*/d" /etc/ssh/sshd_config && \
  echo "X11UseLocalhost no" | tee -a /etc/ssh/sshd_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*X11Forwarding.*/d" /etc/ssh/sshd_config && \
  echo "X11Forwarding yes" | tee -a /etc/ssh/sshd_config
RUN set -ex && \
  [ -r /etc/ssh/sshd_config ] && \
  sed -i "/.*X11DisplayOffset.*/d" /etc/ssh/sshd_config && \
  echo "X11DisplayOffset 10" | tee -a /etc/ssh/sshd_config
#
# ──────────────────────────────────────────────────────────── I ──────────
#   :::::: B B C P   S E T U P : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  install-packages \
    make libssl-dev build-essential zlib1g-dev aria2
RUN set -ex && \
  aria2c \
  --check-certificate=false \
  --dir=/tmp/ \
  http://www.slac.stanford.edu/~abh/bbcp/bbcp.tgz
WORKDIR /tmp
RUN set -ex && \
  tar xvfz bbcp.tgz
WORKDIR /tmp/bbcp/src
RUN set -ex && \
  sed -i.bak 's/\-i/\-m/g' Makefile && \
  make && \
  mv ../bin/*/bbcp /usr/local/bin/ && \
  chmod +x /usr/local/bin/bbcp && \
  bbcp --version
WORKDIR /tmp
RUN set -ex && \
  rm -rf /tmp/bbcp && \
  rm -rf /tmp/bbcp.tgz
#
# ──────────────────────────────────────────────────────────── I ──────────
#   :::::: U S E R   S E T U P : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────
#
ARG USER=gitpod
ENV USER $USER
ARG UID="33333"
ENV UID $UID
ENV SHELL="/bin/bash"
# [ NOTE ] => https://askubuntu.com/a/1269947
RUN set -ex && \
  useradd \
  --no-log-init \
  --create-home \
  --home-dir "/home/${USER}" \
  --uid "${UID}" \
  --groups sudo \
  --shell "${SHELL}" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}"
RUN sed -i \
  -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
  /etc/sudoers
ENV HOME="/home/$USER"
WORKDIR $HOME
RUN set -ex && \
  { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
USER "${USER}"
RUN set -ex && \
  sudo echo "Running 'sudo' for ${USER}: success" && \
  mkdir -p "${HOME}/.bashrc.d" && \
  echo "" | tee -a "${HOME}/.bashrc" && \
  echo 'while read file;do source $file; done < <(find $HOME/.bashrc.d -mindepth 1 -maxdepth 1)' | tee -a "${HOME}/.bashrc" && \
  echo "" | tee -a "${HOME}/.bashrc"
#
# ──────────────────────────────────────────────────────────────────── I ──────────
#   :::::: D O C K E R   I N S T A L L : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────
RUN set -ex; \
    curl -fssL ${SCRIPTS_BASE_URL}/docker/docker-installer | bash --
#
# ──────────────────────────────────────────────────────────────── I ──────────
#   :::::: N G R O K   H E L P E R : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────
#
RUN set -ex; \
  [ -r /usr/local/bin/ngrok-init ] || \
      sudo curl -fssL \
      -o /usr/local/bin/ngrok-init\
      ${SCRIPTS_BASE_URL}/docker/ngrok-init && \
      sudo chmod +x /usr/local/bin/ngrok-init
#
# ──────────────────────────────────────────────────────────── I ──────────
#   :::::: E N T R Y P O I N T : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────
#
# ─── RUNNING SSH ────────────────────────────────────────────────────────────────
CMD ["sudo","/usr/sbin/sshd", "-D", "-e"]
