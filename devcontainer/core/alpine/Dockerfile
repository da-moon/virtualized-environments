# syntax = docker/dockerfile-upstream:master-labs
FROM alpine:edge
USER root
ARG BASE_PACKAGES="\
  alpine-sdk \
  autoconf  \
  automake  \
  binutils \
  build-base  \
  ca-certificates  \
  cmake  \
  coreutils  \
  curl  \
  doxygen \
  gettext-tiny-dev  \
  git  \
  gtest-dev \
  less  \
  libtool  \
  lua  \
  make \
  nodejs \
  npm \
  openssl  \
  perl \
  pkgconf  \
  python3-dev  \
  py3-pip  \
  tmux  \
  unzip  \
  xclip  \
  yarn \
  zlib-dev \
  "

RUN \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null ; \
  apk upgrade --no-cache -U -a \
  && apk add --update --no-cache ${BASE_PACKAGES} \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache ${BASE_PACKAGES} \
  )

WORKDIR "/usr/src/neovim"
RUN \ 
  git clone https://github.com/neovim/neovim.git "/usr/src/neovim" \
  && make -j`nproc` CMAKE_BUILD_TYPE=RelWithDebInfo  \
  CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local"  \
  && make -j`nproc` install  \
  && rm -r /usr/src/neovim
WORKDIR "/usr/src/ctags"
RUN  \
  git clone https://github.com/universal-ctags/ctags.git "/usr/src/ctags" \
  && ./autogen.sh  \
  && ./configure  \
  && make -j`nproc` \
  && make -j`nproc` install  \
  && rm -rf /usr/src/ctags
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2 \
  bash \
  bash-completion \
  bat \
  bzip2 \
  docker \
  docker-compose \
  exa \
  fd \
  findutils \
  fontconfig \
  fzf \
  fzf-bash-completion \
  gawk \
  git-secret \
  glow \
  gnupg \
  grep \
  htop \
  jq \
  just \
  just-bash-completion \
  libcap \
  libffi-dev \
  mkfontscale \
  musl-dev \
  ncurses \
  ncurses-dev \
  ncurses-static \
  nerd-fonts \
  openssl-dev \
  ripgrep \
  ripgrep-bash-completion \
  rng-tools-extra \
  shadow \
  starship \
  sudo \
  tokei \
  tree \
  util-linux \
  wget \
  "

RUN \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null ; \
  apk upgrade --no-cache -U -a \
  && apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
  )
SHELL ["bash","-c"]
RUN \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
RUN \
  sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers \
  && echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers \
  && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
ARG PYTHON_PACKAGES="\
  pynvim \
  pre-commit \
  pylint \
  yapf \
  autoflake \
  isort \
  coverage \ 
  "
RUN \
  sudo python3 -m pip install --no-cache-dir ${PYTHON_PACKAGES}
ARG NODEJS_PACKAGES="\
  remark \
  remark-cli \
  remark-stringify \
  remark-frontmatter \
  wcwidth \
  bash-language-server \
  prettier \
  "
RUN \
  yarn global add --prefix /usr/local ${NODEJS_PACKAGES}
RUN \
  curl -sLf https://spacevim.org/install.sh | bash
#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C R E A T I N G   U S E R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#
ARG USER=devel
ENV USER $USER
ARG UID="1000"
ENV UID $UID
ARG GID=$UID
ENV GID $GID
SHELL ["bash","-c"]
RUN \
  useradd \
  --no-log-init \
  --create-home \
  --home-dir "/home/${USER}" \ 
  --uid "${UID}" \
  --gid "${GID}" \
  --groups sudo \
  --shell "/bin/bash" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}" \
  && usermod -aG wheel,root,sudo,docker "${USER}"
USER ${USER}
SHELL ["bash","-c"]
ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
ENV PIP_USER="false"
RUN \
  echo 'alias apk="sudo apk"' | tee -a ~/.bashrc > /dev/null \
  && echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
ENV EDITOR="nvim"
ENV VISUAL="nvim"
RUN \
  curl -sLf https://spacevim.org/install.sh | bash
COPY .SpaceVim.d "${HOME}/"
RUN \
  timeout 200 \
  nvim --headless \
  +VimProcInstall \
  +'call dein#install()'  \
  +UpdateRemotePlugins  \
  +qall || true ;
USER root
RUN \
  chmod +x /usr/local/bin/* \
  && yarn cache clean --all \
  && rm -rf \
  /tmp/* \
  /usr/src
USER ${USER}
ENV TERM xterm
ARG WORKDIR="/workspace"
ENV WORKDIR $WORKDIR
WORKDIR $WORKDIR
COPY --from=fjolsvin/convco:latest /workspace /usr/local/bin
COPY --from=fjolsvin/clog:latest /workspace /usr/local/bin
COPY --from=fjolsvin/delta:latest /workspace /usr/local/bin
COPY --from=fjolsvin/delta:latest /opt/delta /tmp/delta
ENV PATH="$PATH:$HOME/.git-fuzzy/bin/"
RUN \
  cat /tmp/delta >> "$HOME/.gitconfig" \
  && sudo rm /tmp/delta \
  && git clone https://github.com/bigH/git-fuzzy "$HOME/.git-fuzzy" \
  && chmod +x $HOME/.git-fuzzy/bin/*
ENTRYPOINT [ "/bin/bash" ]
