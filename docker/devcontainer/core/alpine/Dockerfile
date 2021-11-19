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
  && apk add --no-cache "bash=5.1.8-r0" "ca-certificates=20191127-r7"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG BASE_PACKAGES="\
  alpine-sdk~=1.0 \
  bash-completion~=2.11 \
  binutils~=2.35 \
  build-base~=0.5 \
  cmake~=3.21 \
  coreutils~=8.32 \
  ctags~=5 \
  curl~=7.79 \
  doxygen~=1.9 \
  findutils~=4.8 \
  fontconfig~=2.13 \
  gawk~=5.1 \
  git~=2 \
  grep~=3.7 \
  jq~=1.6 \
  less=590-r0 \
  make~=4.3 \
  mkfontscale~=1.2 \
  ncurses~=6.2 \
  ncurses-dev~=6.2 \
  ncurses-static~=6.2 \
  neovim~=0.5 \
  openssl~=1.1 \
  openssl-dev~=1.1 \
  perl~=5.34 \
  shadow~=4.8 \
  starship~=1 \
  sudo~=1.9 \
  tmux~=3.2 \
  tree~=1.8 \
  tzdata~=2021e \
  util-linux~=2.37 \
  wget~=1.21 \
  unzip~=6.0 \
  xclip~=0.13 \
  zlib-dev~=1.2 \
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
USER "root"
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2=1.35.0-r2 \
  bzip2=1.0.8-r1 \
  fzf~=0.27 \
  fzf-bash-completion~=0.27 \
  git-secret~=0.4 \
  glow~=1.3 \
  gnupg~=2.2 \
  gtest-dev~=1.11 \
  htop~=3.0 \
  libcap~=2 \
  libffi-dev~=3 \
  lua5.4=5.4.3-r0 \
  musl-dev~=1.2 \
  nerd-fonts~=2.1 \
  rcm~=1.3 \
  ripgrep~=13.0 \
  ripgrep-bash-completion~=13.0 \
  rng-tools-extra~=6.12 \
  "
RUN \
  IFS=' ' read -a packages <<< $IMAGE_SPECIFIC_PACKAGES ; \
  apk add --no-cache "${packages[@]}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG PYTHON_DEPENDENCIES="\
  python3-dev~=3.9 \
  python2-dev~=2.7 \
  py3-pip~=20 \
  py3-setuptools~=52 \
  py2-setuptools~=44 \
  py3-pyzmq~=19 \
  "
RUN \
  IFS=' ' read -a packages <<< $PYTHON_DEPENDENCIES ; \
  apk add --no-cache "${packages[@]}" ;
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG NODEJS_DEPENDENCIES="\
  npm~=14 \
  yarn~=1 \
"
RUN \
  IFS=' ' read -a packages <<< $NODEJS_DEPENDENCIES ; \
  apk add --no-cache "${packages[@]}" ;
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
# ────────────────────────────────────────────────────────────────────────────────
USER "root"
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
RUN \
  echo "#!/usr/bin/env bash" > "${HOME}/.environment" ; \
  [ -d "${HOME}/.env.d" ] && while read -r i; do \
  sed -e '/^\s*#/d' "$i" | tee -a "${HOME}/.environment" > /dev/null \
  && printf "\n" >> "${HOME}/.environment" ; \
  done < <(find "${HOME}/.env.d/" -name '*.sh')
RUN \
  echo "#!/usr/bin/env bash" > "${HOME}/.bash_functions" ; \
  [ -d "${HOME}/.profile.d" ] && while read -r i; do \
  sed -e '/^\s*#/d' "$i" | tee -a "${HOME}/.bash_functions" > /dev/null \
  && printf "\n" >> "${HOME}/.bash_functions" ; \
  done < <(find "${HOME}/.profile.d/" -name '*.sh') ;
RUN \
  echo "#!/usr/bin/env bash" > "${HOME}/.bash_aliases" ; \
  [ -d "${HOME}/.alias.d" ] && while read -r i; do \
  sed -e '/^\s*#/d' "$i" | tee -a "${HOME}/.bash_aliases" > /dev/null \
  && printf "\n" >> "${HOME}/.bash_aliases" ; \
  done < <(find "${HOME}/.alias.d/" -name '*.sh') ;
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
RUN \
  git clone "https://github.com/da-moon/SpaceVim.d.git" "${HOME}/.SpaceVim.d" \
  && bash "${HOME}/.SpaceVim.d/contrib/scripts/spacevim-installer.sh"
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
