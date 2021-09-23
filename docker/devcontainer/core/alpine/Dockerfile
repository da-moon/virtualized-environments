# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── IMAGE DEPENDENCY ALIASES ───────────────────────────────────────────────────
# hadolint ignore=DL3007
FROM fjolsvin/cellar:latest AS cellar
# hadolint ignore=DL3007
FROM fjolsvin/yq:latest AS yq
# hadolint ignore=DL3007
FROM fjolsvin/jsonfmt:latest AS jsonfmt
# hadolint ignore=DL3007
FROM fjolsvin/just:latest AS just
# hadolint ignore=DL3007
FROM fjolsvin/convco:latest AS convco
# hadolint ignore=DL3007
FROM fjolsvin/fd:latest AS fd
# hadolint ignore=DL3007
FROM fjolsvin/sd:latest AS sd
# hadolint ignore=DL3007
FROM fjolsvin/bat:latest AS bat
# hadolint ignore=DL3007
FROM fjolsvin/exa:latest AS exa
# hadolint ignore=DL3007
FROM fjolsvin/shfmt:latest AS shfmt
# hadolint ignore=DL3007
FROM fjolsvin/tokei:latest AS tokei
# hadolint ignore=DL3007
FROM fjolsvin/sad:latest AS sad
# hadolint ignore=DL3007
FROM fjolsvin/releez:latest AS releez
# hadolint ignore=DL3007
FROM fjolsvin/skim:latest AS skim
# hadolint ignore=DL3007
FROM fjolsvin/delta:latest AS delta
# hadolint ignore=DL3007
FROM fjolsvin/clog:latest AS clog
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ENV TERM xterm
RUN \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --no-cache "bash=5.1.8-r0" "ca-certificates=20191127-r6"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG NEOVIM_BUILD_DEPENDENCIES="\
  automake=1.16.4-r1 \
  autoconf=2.71-r0 \
  build-base=0.5-r2 \
  cmake=3.21.3-r0  \
  coreutils=8.32-r2 \
  curl=7.79.1-r0 \
  git=2.33.0-r2 \
  gettext-tiny-dev=0.3.2-r1 \
  libtool=2.4.6-r7 \
  pkgconf=1.8.0-r0 \
  unzip=6.0-r9 \
  "
RUN \
  IFS=' ' read -a packages <<< $NEOVIM_BUILD_DEPENDENCIES ; \
  apk add --virtual .neovim-build-deps --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --virtual .neovim-build-deps --no-cache "${packages[@]}" \
  ); 
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN \
  git clone https://github.com/neovim/neovim.git "/usr/src/neovim";
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/usr/src/neovim"
RUN \
  make -j"$(nproc)" CMAKE_BUILD_TYPE=RelWithDebInfo  \
  CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_JEMALLOC=FALSE"  \
  && make -j"$(nproc)" install
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
RUN \
  rm -r /usr/src/neovim \
  && apk del .neovim-build-deps || true
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG CTAGS_BUILD_DEPENDENCIES="\
  automake=1.16.4-r1 \
  autoconf=2.71-r0 \
  build-base=0.5-r2 \
  git=2.33.0-r2 \
  pkgconf=1.8.0-r0 \
  "
RUN \
  IFS=' ' read -a packages <<< $NEOVIM_BUILD_DEPENDENCIES ; \
  apk add --virtual .ctags-build-deps --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --virtual .ctags-build-deps --no-cache "${packages[@]}" \
  ) ;


# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/usr/src/ctags"
RUN  \
  git clone https://github.com/universal-ctags/ctags.git "/usr/src/ctags" \
  && ./autogen.sh  \
  && ./configure  \
  && make -j"$(nproc)" \
  && make -j"$(nproc)" install  \
  && rm -rf /usr/src/ctags \
  && apk del .ctags-build-deps || true
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG BASE_PACKAGES="\
  alpine-sdk=1.0-r1 \
  bash-completion=2.11-r4 \
  binutils=2.35.2-r2 \
  build-base=0.5-r2 \
  cmake=3.21.3-r0  \
  coreutils=8.32-r2 \
  curl=7.79.1-r0 \
  doxygen=1.9.1-r1 \
  findutils=4.8.0-r1 \
  fontconfig=2.13.1-r4 \
  gawk=5.1.0-r0 \
  git=2.33.0-r2 \
  grep=3.7-r0 \
  jq=1.6-r1 \
  less=590-r0 \
  make=4.3-r0 \
  mkfontscale=1.2.1-r1 \
  ncurses=6.2_p20210109-r0 \
  ncurses-dev=6.2_p20210109-r0 \
  ncurses-static=6.2_p20210109-r0 \
  openssl=3.0.0-r2 \
  openssl-dev=3.0.0-r2 \
  perl=5.34.0-r1 \
  shadow=4.8.1-r0 \
  starship=0.57.0-r1 \
  sudo=1.9.8_p2-r0 \
  tmux=3.2a-r0 \
  tree=1.8.0-r0 \
  tzdata=2021a-r0 \
  util-linux=2.37.2-r1 \
  wget=1.21.1-r1 \
  unzip=6.0-r9 \
  xclip=0.13-r1 \
  zlib-dev=1.2.11-r3 \
  "
RUN \
  IFS=' ' read -a packages <<< $BASE_PACKAGES ; \
  apk add --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${packages[@]}") \
  && cat '/usr/share/zoneinfo/Canada/Eastern' > /etc/localtime \
  && echo '[ -r /etc/profile ] && . /etc/profile' > "/root/.bashrc"

# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG USER=devel
ENV USER "${USER}"
ARG UID="1000"
ENV UID $UID
ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
RUN \
  useradd \
  --no-log-init \
  --create-home \
  --user-group \
  --home-dir "/home/${USER}" \
  --uid "${UID}" \
  --shell "/bin/bash" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}"
RUN \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1 \
  && sed -i \
    -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
    -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers \
  && echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers \
  && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && usermod -aG wheel,root,sudo "${USER}"
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
RUN \
  echo '[ -r /etc/profile ] && . /etc/profile' > "${HOME}/.bashrc"
# ─── VSCODE LIVE SHARE ──────────────────────────────────────────────────────────
USER root
RUN \
  for i in {1..5}; do wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && break || sleep 15; done && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs ; \
  bash /tmp/vsls-reqs || true ; \
  rm /tmp/vsls-reqs
# ────────────────────────────────────────────────────────────────────────────────
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2=1.35.0-r2 \
  bzip2=1.0.8-r1 \
  docker=20.10.8-r1 \
  docker-compose=1.29.2-r1 \
  fzf=0.27.2-r2 \
  fzf-bash-completion=0.27.2-r2 \
  git-secret=0.4.0-r0 \
  glow=1.3.0-r0 \
  gnupg=2.2.29-r5 \
  gtest-dev=1.11.0-r0 \
  htop=3.0.5-r2 \
  libcap=2.58-r0 \
  libffi-dev=3.3-r2 \
  lua5.4=5.4.3-r0 \
  musl-dev=1.2.2-r6 \
  nerd-fonts=2.1.0-r6 \
  rcm=1.3.4-r0 \
  ripgrep=13.0.0-r0 \
  ripgrep-bash-completion=13.0.0-r0 \
  rng-tools-extra=6.12-r0 \
  "
RUN \
  IFS=' ' read -a packages <<< $IMAGE_SPECIFIC_PACKAGES ; \
  apk add --no-cache "${packages[@]}" \
  && usermod -aG docker "${USER}" ;
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG PYTHON_DEPENDENCIES="\
  python3-dev=3.9.7-r2 \
  python2-dev=2.7.18-r2 \
  py3-pip=20.3.4-r1 \
  py3-setuptools=52.0.0-r4 \
  py2-setuptools=44.0.0-r0 \
  py3-pyzmq=19.0.2-r1 \
  "
RUN \
  IFS=' ' read -a packages <<< $PYTHON_DEPENDENCIES ; \
  apk add --no-cache "${packages[@]}" ;
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG NODEJS_DEPENDENCIES="\
  npm=14.17.6-r0 \
  yarn=1.22.11-r0 \
"
RUN \
  IFS=' ' read -a packages <<< $NODEJS_DEPENDENCIES ; \
  apk add --no-cache "${packages[@]}" ;
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN \
  find "${HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {}
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ENV EDITOR="nvim"
ENV VISUAL="nvim"
ENV PATH="${PATH}:/usr/local/bin"
ENV PATH="${PATH}:${HOME}/.local/bin"
RUN \
  git clone "https://github.com/da-moon/.dotfiles.git" "${HOME}/.dotfiles" \
  && rcup -f
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ENV PATH="${PATH}:${HOME}/.local/bin"
RUN \
  git clone "https://github.com/da-moon/SpaceVim.d.git" "${HOME}/.SpaceVim.d" \
  && curl -fSsl "https://raw.githubusercontent.com/da-moon/SpaceVim.d/master/spacevim-installer.sh" | bash
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ENV PATH="${PATH}:${HOME}/.git-fuzzy/bin/"
RUN \
  git clone https://github.com/bigH/git-fuzzy "${HOME}/.git-fuzzy" \
  && chmod a+x ${HOME}/.git-fuzzy/bin/* 
# ─── CLEAN UP ───────────────────────────────────────────────────────────────────
USER root
RUN \
  chmod a+x /usr/local/bin/* \
  && yarn cache clean --all \
  && npm -g cache clean --force > /dev/null 2>&1 \
  && rm -rf \
  /tmp/* \
  /usr/src
# ─── PREBUILD BINARIES ──────────────────────────────────────────────────────────
COPY --chmod=0755 --from=yq /workspace/yq /usr/local/bin/yq
COPY --chmod=0755 --from=jsonfmt /workspace/jsonfmt /usr/local/bin/jsonfmt
COPY --chmod=0755 --from=just /workspace/just /usr/local/bin/just
COPY --chmod=0755 --from=convco /workspace/convco /usr/local/bin/convco
COPY --chmod=0755 --from=fd /workspace/fd /usr/local/bin/fd
COPY --chmod=0755 --from=sd /workspace/sd /usr/local/bin/sd
COPY --chmod=0755 --from=bat /workspace/bat /usr/local/bin/bat
COPY --chmod=0755 --from=exa /workspace/exa /usr/local/bin/exa
COPY --chmod=0755 --from=shfmt /workspace/shfmt /usr/local/bin/shfmt
COPY --chmod=0755 --from=tokei /workspace/tokei /usr/local/bin/tokei
COPY --chmod=0755 --from=sad /workspace/sad /usr/local/bin/sad
COPY --chmod=0755 --from=releez /workspace/releez /usr/local/bin/releez
COPY --chmod=0755 --from=skim /workspace/sk /usr/local/bin/sk
COPY --chmod=0755 --from=delta /workspace/delta /usr/local/bin/delta
COPY --chmod=0755 --from=cellar /workspace/cellar /usr/local/bin/cellar
COPY --chmod=0755 --from=clog /workspace/clog /usr/local/bin/clog
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN \
  find "${HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} \
  && yarn cache clean --all \
  && npm -g cache clean --force > /dev/null 2>&1 \
  && rm -rf \
    /tmp/*
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ARG WORKDIR="/workspace"
ENV WORKDIR "${WORKDIR}"
WORKDIR "${WORKDIR}"
ENTRYPOINT [ "/bin/bash" ]