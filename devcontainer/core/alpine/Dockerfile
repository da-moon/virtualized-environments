# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── IMAGE DEPENDENCY ALIASES ───────────────────────────────────────────────────
# hadolint ignore=DL3007
FROM fjolsvin/jen:latest AS jen
# hadolint ignore=DL3007
FROM fjolsvin/tojson:latest AS tojson
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
FROM fjolsvin/ripgrep:latest AS ripgrep
# hadolint ignore=DL3007
FROM fjolsvin/starship:latest AS starship
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
# ────────────────────────────────────────────────────────────────────────────────
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ENV TERM xterm
RUN apk add --update --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG BASE_PACKAGES="\
  alpine-sdk=1.0-r1 \
  autoconf=2.71-r0 \
  automake=1.16.4-r0 \
  binutils=2.35.2-r2 \
  build-base=0.5-r2 \
  ca-certificates=20191127-r5 \
  cmake=3.21.1-r0 \
  coreutils=8.32-r2 \
  curl=7.78.0-r0 \
  doxygen=1.9.1-r1 \
  gettext-tiny-dev=0.3.2-r0 \
  git=2.32.0-r2 \
  gtest-dev=1.11.0-r0 \
  less=590-r0 \
  libtool=2.4.6-r7 \
  lua5.4=5.4.3-r0 \
  make=4.3-r0 \
  nodejs=14.17.4-r0 \
  npm=7.20.5-r0 \
  openssl=1.1.1k-r1 \
  perl=5.34.0-r0 \
  pkgconf=1.8.0-r0 \
  python3-dev=3.9.6-r0 \
  py3-pip=20.3.4-r1 \
  py3-setuptools=52.0.0-r4 \
  py3-pyzmq=19.0.2-r1 \
  tmux=3.2a-r0 \
  unzip=6.0-r9 \
  xclip=0.13-r1 \
  yarn=1.22.11-r0 \
  zlib-dev=1.2.11-r3 \
  "
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2=1.35.0-r2 \
  bash-completion=2.11-r4 \
  bzip2=1.0.8-r1 \
  docker=20.10.8-r0 \
  docker-compose=1.29.2-r0 \
  findutils=4.8.0-r1 \
  fontconfig=2.13.1-r4 \
  fzf=0.27.2-r1 \
  fzf-bash-completion=0.27.2-r1 \
  gawk=5.1.0-r0 \
  git-secret=0.3.2-r0 \
  glow=1.3.0-r0 \
  gnupg=2.2.29-r0 \
  grep=3.6-r0 \
  htop=3.0.5-r2 \
  jq=1.6-r1 \
  libcap=2.52-r0 \
  libffi-dev=3.3-r2 \
  mkfontscale=1.2.1-r1 \
  musl-dev=1.2.2-r5 \
  ncurses=6.2_p20210731-r0 \
  ncurses-dev=6.2_p20210731-r0 \
  ncurses-static=6.2_p20210731-r0 \
  nerd-fonts=2.1.0-r6 \
  openssl-dev=1.1.1k-r1 \
  rng-tools-extra=6.12-r0 \
  shadow=4.8.1-r0 \
  sudo=1.9.7_p2-r0 \
  tree=1.8.0-r0 \
  util-linux=2.37.1-r0 \
  wget=1.21.1-r1 \
  "
RUN \
  IFS=' ' read -a BASE_PACKAGES <<< $BASE_PACKAGES ; \
  IFS=' ' read -a IMAGE_SPECIFIC_PACKAGES <<< $IMAGE_SPECIFIC_PACKAGES ; \
  packages=("${BASE_PACKAGES[@]}" "${IMAGE_SPECIFIC_PACKAGES[@]}") ; \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --update --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache "${packages[@]}" \
  )
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
RUN \
  sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers \
  && echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers \
  && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# ────────────────────────────────────────────────────────────────────────────────
ARG USER=devel
ENV USER "${USER}"
ARG UID="1000"
ENV UID $UID
ARG GID=$UID
ENV GID $GID
ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
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
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ARG PYTHON_PACKAGES="\
  notedown \
  pre-commit \
  neovim \
  pylint \
  yapf \
  autoflake \
  isort \
  coverage \
  "
RUN \
  IFS=' ' read -a PYTHON_PACKAGES <<< "$PYTHON_PACKAGES" ; \
  sudo apk add  ; \
  python3 -m pip install --user --no-cache-dir "${PYTHON_PACKAGES[@]}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG NODEJS_PACKAGES="\
  neovim \
  remark \
  remark-cli \
  remark-stringify \
  remark-frontmatter \
  wcwidth \
  prettier \
  bash-language-server \
  dockerfile-language-server-nodejs \
  standard-readme-spec \
  "
# [ NOTE ] neovim could not detect 'neovim' NodeJS package
# installed through Yarn.
RUN \
  IFS=' ' read -a NODEJS_PACKAGES <<< "$NODEJS_PACKAGES" ; \
  npm install -g "${NODEJS_PACKAGES[@]}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/usr/src/ctags"
RUN  \
  git clone https://github.com/universal-ctags/ctags.git "/usr/src/ctags" \
  && ./autogen.sh  \
  && ./configure  \
  && make -j"$(nproc)" \
  && make -j"$(nproc)" install  \
  && rm -rf /usr/src/ctags
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/usr/src/neovim"
RUN \
  git clone https://github.com/neovim/neovim.git "/usr/src/neovim" \
  && make -j"$(nproc)" CMAKE_BUILD_TYPE=RelWithDebInfo  \
  CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local"  \
  && make -j"$(nproc)" install  \
  && rm -r /usr/src/neovim
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN \
  find "${HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} ;
# ─── SPACEVIM INSTALLATION ──────────────────────────────────────────────────────
USER "${USER}"
RUN \
  rm -rf \
    ~/.SpaceVim \
    ~/.vim* \
    ~/.config/*vim* \
    ~/.cache/*vim* \
    ~/.cache/neosnippet \
    ~/.local/share/*vim* \
&& curl -sLf https://spacevim.org/install.sh | bash \
&& sed \
    -i.bak 's/call dein#add/"call dein#add/g' \
    "${HOME}/.SpaceVim/autoload/SpaceVim/plugins.vim" \
&& mkdir -p "${HOME}/.local/share/nvim/shada" \
&& nvim --headless \
    -c "call dein#direct_install('deoplete-plugins/deoplete-go', { 'build': 'make' })" \
    -c "call dein#direct_install('iamcco/markdown-preview.nvim', {'on_ft': ['markdown', 'pandoc.markdown', 'rmd'],'build': 'yarn --cwd app --frozen-lockfile install' })" \
    -c "call dein#direct_install('lymslive/vimloo', { 'merged': '0' })" \
    -c "call dein#direct_install('lymslive/vnote', { 'depends': 'vimloo' })" \
    -c "call dein#direct_install('neoclide/coc.nvim', { 'merged': 0, 'rev': 'master', 'build': 'yarn install --frozen-lockfile' })" \
    -c "qall"
RUN \
  mv \
    "${HOME}/.SpaceVim/autoload/SpaceVim/plugins.vim.bak" \
    "${HOME}/.SpaceVim/autoload/SpaceVim/plugins.vim"
COPY "./.SpaceVim.d/" "${HOME}/.SpaceVim.d"
RUN \
  nvim --headless \
    -c "call dein#install()" \
    -c "call dein#install()" \
    -c "call dein#update()" \
    -c "call dein#remote_plugins()" \
    -c "qall" \
&& nvim --headless \
    -c "UpdateRemotePlugins" \
    -c "qall"
# ─── INSTALL COC EXTENSIONS ─────────────────────────────────────────────────────
USER "${USER}"
RUN \
  IFS=' ' read -a coc_extensions <<< "$(nvim --headless -c "call PrintCocExtensions()"  -c "qall" 2>&1)" ; \
  [ "${#coc_extensions[@]}" -ne 0  ] \
  && (for ext in "${coc_extensions[@]}"; do nvim --headless -c "CocInstall ${ext}" -c "qall"  ; done) \
  || true
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
COPY --from=delta /opt/delta /tmp/delta
ENV PATH="${PATH}:${HOME}/.git-fuzzy/bin/"
RUN \
  echo '[ -r /etc/profile ] && . /etc/profile' > "${HOME}/.bashrc" \
  && git clone https://github.com/bigH/git-fuzzy "${HOME}/.git-fuzzy" \
  && chmod a+x ${HOME}/.git-fuzzy/bin/* \
  && cat /tmp/delta >> "${HOME}/.gitconfig"
# ────────────────────────────────────────────────────────────────────────────────
USER root
ENV EDITOR="nvim"
ENV VISUAL="nvim"
RUN \
  echo '[ -r /etc/profile ] && . /etc/profile' > "/root/.bashrc" \
  && mkdir -p /etc/profile.d/ \
  && curl \
    -fsSl https://raw.githubusercontent.com/3hhh/fzfuncs/master/bashrc_fzf \
    -o /etc/profile.d/bashrc_fzf.sh \
  && ( \
  echo "alias apk='sudo apk'" ; \
  echo "export EDITOR=\"${EDITOR}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \

  echo 'command -- starship --version >/dev/null 2>&1 && eval "$(starship init bash)";' ; \
  echo 'command -- just --version >/dev/null 2>&1 && eval "$(just --completions bash)"; alias j="just";' ; \
  echo 'command -- rustup --version >/dev/null 2>&1 && eval "$(rustup completions bash rustup)"; eval "$(rustup completions bash cargo)";' ; \
  ) | tee /etc/profile.d/alpine.sh > /dev/null ;
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
COPY --from=jen /workspace /usr/local/bin
COPY --from=tojson /workspace /usr/local/bin
COPY --from=jsonfmt /workspace /usr/local/bin
COPY --from=just /workspace /usr/local/bin
COPY --from=convco /workspace /usr/local/bin
COPY --from=fd /workspace /usr/local/bin
COPY --from=sd /workspace /usr/local/bin
COPY --from=bat /workspace /usr/local/bin
COPY --from=exa /workspace /usr/local/bin
COPY --from=starship /workspace /usr/local/bin
COPY --from=ripgrep /workspace /usr/local/bin
COPY --from=shfmt /workspace /usr/local/bin
COPY --from=tokei /workspace /usr/local/bin
COPY --from=sad /workspace /usr/local/bin
COPY --from=releez /workspace /usr/local/bin
COPY --from=skim /workspace /usr/local/bin
COPY --from=delta /workspace /usr/local/bin
# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ARG WORKDIR="/workspace"
ENV WORKDIR "${WORKDIR}"
WORKDIR "${WORKDIR}"
VOLUME "${WORKDIR}"
ENTRYPOINT [ "/bin/bash" ]
