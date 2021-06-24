# syntax = docker/dockerfile-upstream:master-labs
FROM fjolsvin/rust-builder-alpine AS convco-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
 apk add --no-cache openssl-dev cmake ; \
 build "convco" || true
FROM fjolsvin/rust-builder-alpine AS clog-builder
# ENV CFLAGS="-mno-outline-atomics"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  apk add --no-cache openssl-dev ; \
  build "clog-cli" || true
FROM fjolsvin/upx AS compression-layer
COPY --from=clog-builder "/workspace" "/workspace"
COPY --from=convco-builder "/workspace" "/workspace" 
RUN \
  compress ;
FROM alpine:edge
USER root
RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories \
  && apk add --no-cache --upgrade apk-tools || true \
  && apk upgrade --no-cache -U -a
ARG BASE_PACKAGES="\
  git-secret \
  curl \
  perl \
  wget \
  tree \
  util-linux \
  ca-certificates \
  ncurses \
  ncurses-dev \
  git \ 
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
  build-base \
  make \
"
RUN \
  apk add --update --no-cache ${BASE_PACKAGES} \
  || ( \
    sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
    && apk add --update --no-cache ${BASE_PACKAGES} \
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
ARG SPACEVIM_SPECIFIC_PACKAGES="\
  py3-pip \
  vim \
  neovim \
  fontconfig \
  mkfontscale \
  nerd-fonts \
  py3-pynvim \
  yarn \
  nodejs \
  npm \
"
RUN \
  apk add --update --no-cache ${SPACEVIM_SPECIFIC_PACKAGES} \
  || ( \
    sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
    && apk add --update --no-cache ${SPACEVIM_SPECIFIC_PACKAGES} \
  )
ARG PYTHON_PACKAGES="\
  pre-commit \
  pylint \
  yapf \
  autoflake \
  isort \
  coverage \ 
"
ARG NODEJS_PACKAGES="\
  @commitlint/cli \
  @commitlint/config-conventional \
  remark \
  remark-cli \
  remark-stringify \
  remark-frontmatter \
  wcwidth \
  bash-language-server \
  prettier \
"
# spacevim python and nodejs packages
RUN \
  sudo python3 -m pip install --no-cache-dir ${PYTHON_PACKAGES} \
  && yarn global add --prefix /usr/local ${NODEJS_PACKAGES}
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
  && usermod -aG wheel,root,sudo "${USER}"
USER ${USER}
SHELL ["bash","-c"]
ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
# home profile and workdirectory setup
RUN \
  find ${HOME} \
  -not -group `id -g` \
  -not -user `id -u` \
  -print0 \
  | sudo xargs \
    --no-run-if-empty \
    -0  \
    -P 0 \
    chown --no-dereference "`id -u`:`id -g`" \
  && echo 'alias apk="sudo apk"' | tee -a ~/.bashrc > /dev/null \
  && echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
# user scoped spacevim install
RUN \
  curl -sLf https://spacevim.org/install.sh | bash
ARG IMAGE_SPECIFIC_PACKAGES="\
  glow \
  aria2 \
  rng-tools-extra \
  openssl-dev \
  libffi-dev \
  jq \
  htop \
  bzip2 \
  ripgrep \
  ripgrep-bash-completion \
  bat \
  tokei \
  fd \
  exa \
  starship \
  just \
  fzf \
  fzf-bash-completion \
  just \
  just-bash-completion \
  docker \
  docker-compose \
"
RUN \
  sudo apk add --update --no-cache  ${IMAGE_SPECIFIC_PACKAGES} \
  || ( \
    sudo sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
    && sudo apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
  )
# precommit hook examples
WORKDIR ${HOME}/pre-commit-templates
COPY <<-"EOT" conventional-commits.yml
---
# cat ~/pre-commit-templates/conventional-commits.yml >> /workspace/.pre-commit-config.yml
default_stages: [commit]
repos:
 - repo: https://github.com/dafyddj/commitlint-pre-commit-hook
   hooks:
     - id: commitlint
       name: Check commit message using commitlint
       description: Lint commit message against @commitlint/config-conventional rules
       stages: [commit-msg]
       additional_dependencies: ['@commitlint/config-conventional']
EOT
RUN \
  sudo chown "`id -u`:`id -g`" ${HOME}/pre-commit-templates -R \
  && sudo usermod -aG docker "`whoami`" \
  && sudo python3 -m pip cache purge \
  && sudo yarn cache clean --all \
  && sudo rm -rf \
  /tmp/*
COPY --from=compression-layer "/workspace" /usr/local/bin
ARG WORKDIR="/workspace"
ENV WORKDIR $WORKDIR
WORKDIR $WORKDIR
RUN \
  find ${WORKDIR} \
  -not -group `id -g` \
  -not -user `id -u` \
  -print0 \
  | sudo xargs \
    --no-run-if-empty \
    -0  \
    -P 0 \
    chown --no-dereference "`id -u`:`id -g`" \
  && sudo chmod +x /usr/local/bin/*
ENV TERM xterm
ENV EDITOR nvim
ENTRYPOINT [ "/bin/bash" ]
