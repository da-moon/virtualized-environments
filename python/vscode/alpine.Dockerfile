# syntax = docker/dockerfile:1.0-experimental

# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --build-arg USER=operator --build-arg UID=1000 --tag fjolsvin/vscode-python-alpine:latest .
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/python-base-alpine:latest
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
  sudo \
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
  "
RUN set -ex && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES})
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
  --shell "${SHELL}" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}"
RUN sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers && \
  echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN usermod -aG wheel,root,sudo "${USER}"
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
RUN set -ex && \
  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
# ──────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P O E T R Y : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV POETRY_HOME="${HOME}/.poetry"
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV PATH="${PATH}:${POETRY_HOME}/bin"
RUN set -ex && \
  mkdir -p "${HOME}/.local/bin" && \
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
RUN set -ex && \
  echo '[ -r ${HOME}/.cargo/env ] && . ${HOME}/.cargo/env' | tee -a ~/.bashrc > /dev/null && \
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
RUN set -ex && \
  cargo install -j`nproc` pyoxidizer && \
  strip ${HOME}/.cargo/bin/pyoxidizer && \
  upx ${HOME}/.cargo/bin/pyoxidizer && \
  pyoxidizer --version
#
# ──────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   N U   S H E L L : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  nu -c 'config set path $nu.path' && \
  nu -c 'config set env  $nu.env' && \
  nu -c 'config set prompt "starship prompt"' && \
  sudo usermod --shell /usr/bin/nu "${USER}"
RUN set -ex && \
  rm -rf \
     /tmp/*