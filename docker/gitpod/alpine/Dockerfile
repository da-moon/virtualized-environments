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
FROM fjolsvin/clog:latest AS clog
# hadolint ignore=DL3007
FROM fjolsvin/fd:latest AS fd
# hadolint ignore=DL3007
FROM fjolsvin/bat:latest AS bat
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
# ─── MAIN LAYER ─────────────────────────────────────────────────────────────────
FROM alpine:edge
USER root
RUN \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null \
  && apk add --update --no-cache \
  sudo bash util-linux coreutils findutils util-linux shadow \
  grep gawk perl curl
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ─── CREATING USER ──────────────────────────────────────────────────────────────
USER root
RUN \
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
ARG USER=gitpod
ENV USER "${USER}"
ARG UID="33333"
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
# ─── GLOBAL PROFILE SETUP ───────────────────────────────────────────────────────
USER root
ENV EDITOR="nvim"
ENV PIP_USER="false"
ENV VISUAL="${EDITOR}"
RUN \
curl \
  -fsSl https://raw.githubusercontent.com/3hhh/fzfuncs/master/bashrc_fzf \
  -o /etc/bashrc_fzf \
  && ( \
  echo "export EDITOR=\"${EDITOR}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \
  echo "export PIP_USER=\"${PIP_USER}\"" ; \
  echo 'export PATH="${PATH}:/usr/local/bin"' ; \
  echo "[ -d ${HOME}/go ] && export GOROOT=\"${HOME}/go\";"; \
  echo "[ -d ${HOME}/go ] && export GOPATH=\"${HOME}/go-packages\";"; \
  echo "[ -d ${HOME}/go ] && export PATH=\"\${PATH}:\${GOROOT}/bin:\${GOPATH}/bin\";"; \
  echo '[ $(command -v gp) ] && eval $(gp env | sed -e "s/\(=[[:blank:]]*\)\(.*\)/\1\"\2\" ;/" -e "s/^/export /g")' ; \
  echo '[ $(command -v starship) ] && eval "$(starship init bash)";' ; \
  echo '[ $(command -v just) ] && eval "$(just --completions bash)"; alias j="just";' ; \
  echo '[ $(command -v rustup) ] && eval "$(rustup completions bash rustup)"; eval "$(rustup completions bash cargo)";' ; \
  echo '[ $(command -v fzf) ] && source /etc/bashrc_fzf ;' ; \
  ) | tee "/etc/profile.d/00-${USER}.sh" > /dev/null
# ─── BASE PACKAGES ──────────────────────────────────────────────────────────────

ARG BASE_PACKAGES="\
  dropbear \
  alpine-sdk \
  autoconf  \
  automake  \
  binutils \
  build-base  \
  ca-certificates  \
  cmake  \
  coreutils  \
  wget \
  doxygen \
  gettext-tiny-dev  \
  git  \
  gtest-dev \
  less  \
  libtool  \
  make \
  tree \
  bash-completion \
  musl-dev \
  ncurses \
  ncurses-dev \
  ncurses-static \
  openssl  \
  openssl-dev \
  openssl-libs-static \
  pkgconf  \
  tmux  \
  unzip  \
  xclip  \
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
  ) | tee /etc/apk/repositories > /dev/null \
  && apk add --update --no-cache ${BASE_PACKAGES} \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache ${BASE_PACKAGES} \
  ) \
  && curl https://i.jpillora.com/chisel! | sudo bash -s --

# ─── VSCODE LIVE SHARE ──────────────────────────────────────────────────────────
RUN set -ex && \
  for i in {1..5}; do wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && break || sleep 15; done && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs ; \
  bash /tmp/vsls-reqs || true ; \
  rm /tmp/vsls-reqs

ARG IMAGE_SPECIFIC_PACKAGES="\
  lua  \
  nodejs \
  npm \
  python3-dev  \
  py3-pip  \
  yarn \
  go \
  aria2 \
  bzip2 \
  docker \
  docker-compose \
  fontconfig \
  fzf \
  fzf-bash-completion \
  git-secret \
  glow \
  gnupg \
  htop \
  jq \
  libcap \
  libffi-dev \
  mkfontscale \
  nerd-fonts \
  rng-tools-extra \
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
  ) | tee /etc/apk/repositories > /dev/null \
  && apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
  )
RUN \
  usermod -aG docker "${USER}"
  # ─── GLOBAL PROFILE SETUP ───────────────────────────────────────────────────────

WORKDIR "/usr/src/ctags"
RUN  \
  git clone https://github.com/universal-ctags/ctags.git "/usr/src/ctags" \
  && ./autogen.sh  \
  && ./configure  \
  && make -j`nproc` \
  && make -j`nproc` install  \
  && rm -rf /usr/src/ctags
WORKDIR "/usr/src/neovim"
RUN \
  git clone https://github.com/neovim/neovim.git "/usr/src/neovim" \
  && make -j`nproc` CMAKE_BUILD_TYPE=RelWithDebInfo  \
  CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local"  \
  && make -j`nproc` install  \
  && rm -r /usr/src/neovim

# ─── SPACEVIM ───────────────────────────────────────────────────────────────────
USER root
RUN \
  curl -sLf https://spacevim.org/install.sh | bash
USER "$USER"
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
  -c "call dein#direct_install('Shougo/vimproc.vim', { 'build': 'make' })" \
  -c "call dein#direct_install('iamcco/markdown-preview.nvim', {'on_ft': ['markdown', 'pandoc.markdown', 'rmd'],'build': 'yarn --cwd app --frozen-lockfile install' })" \
  -c "call dein#direct_install('lymslive/vimloo', { 'merged': '0' })" \
  -c "call dein#direct_install('lymslive/vnote', { 'depends': 'vimloo' })" \
  -c "qall"
RUN \
  mv \
  "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim.bak" \
  "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim" \
  && git clone https://github.com/da-moon/SpaceVim.d.git "${HOME}/.SpaceVim.d" \
  && nvim --headless \
    -c "call dein#install()" \
    -c "call dein#update()" \
    -c "call dein#remote_plugins()" \
    -c "call dein#recache_runtimepath()" \
    -c "UpdateRemotePlugins" \
    -c "qall" ; \
  [ -d "${HOME}/.SpaceVim/bundle/vimproc.vim" ] && make -C ~/.SpaceVim/bundle/vimproc.vim ;
USER root
# ─── PYTHON PACKAGES ────────────────────────────────────────────────────────────
USER root
ARG PYTHON_PACKAGES="\
  pre-commit \
  pylint \
  yapf \
  autoflake \
  isort \
  coverage \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$PYTHON_PACKAGES" ; \
python3 -m pip install --no-cache-dir "${PACKAGES[@]}"
# ─── NODE PACKAGES ──────────────────────────────────────────────────────────────
USER root
ARG NODEJS_PACKAGES="\
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
RUN \
IFS=' ' read -a PACKAGES <<< "$NODEJS_PACKAGES" ; \
yarn global add --prefix /usr/local "${PACKAGES[@]}"
# ─── RUST TOOLCHAIN SETUP ───────────────────────────────────────────────────────
USER root
ENV RUSTUP_HOME="/usr/local/rustup"
ENV CARGO_HOME="/usr/local/cargo"
ENV PATH="${CARGO_HOME}/bin:$PATH"
RUN \
curl \
--proto '=https' \
--tlsv1.2 \
-sSf https://sh.rustup.rs \
| sh -s -- \
  -y \
  --no-modify-path \
  --default-toolchain stable \
  --profile default
COPY <<-"EOT" /usr/local/cargo/config
[target.x86_64-unknown-linux-musl]
rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
rustflags = ["-C", "target-feature=+crt-static"]
[target.armv7-unknown-linux-musleabihf]
linker = "arm-linux-gnueabihf-gcc"
EOT
RUN \
chown "$(id -u $USER):$(id -g $USER)" "${RUSTUP_HOME}" -R \
&& chown "$(id -u $USER):$(id -g $USER)" "${CARGO_HOME}" -R
USER "$USER"
ENV OPENSSL_STATIC=yes
ENV OPENSSL_LIB_DIR="/usr/lib"
ENV OPENSSL_INCLUDE_DIR="/usr/include"
RUN \
rustup --version \
&& cargo --version \
&& rustc --version
RUN \
rustup toolchain install "nightly-$(apk --print-arch)-unknown-linux-musl" \
&& rustup default "stable-$(apk --print-arch)-unknown-linux-musl" \
&& rustup component add rust-src rustfmt rls clippy
# ─── RUST CLI UTILITIES ─────────────────────────────────────────────────────────
USER "$USER"
ARG RUST_STABLE_PACKAGE="\
  cargo-update \
  starship \
  exa \
  sd \
  hyperfine \
  procs \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$RUST_STABLE_PACKAGE" ; \
cargo install \
--all-features \
-j"$(nproc)" \
--target "$(apk --print-arch)-unknown-linux-musl" "${PACKAGES[@]}"
ARG RUST_NIGHTLY_PACKAGES="\
  ripgrep \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$RUST_NIGHTLY_PACKAGES" ; \
RUSTFLAGS="-C target-cpu=native" \
rustup run nightly cargo install \
  --features simd-accel \
  -j"$(nproc)" \
  --target "$(apk --print-arch)-unknown-linux-musl" "${PACKAGES[@]}" ;


# ─── FIX PERMISSION ─────────────────────────────────────────────────────────────
USER root
RUN \
   find "${HOME}" \
  -not -group "$(id -g $USER)" \
  -not -user "$(id -u $USER)" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u $USER):$(id -g $USER)" {} ;
# ─── PREBUILD BINARIES ──────────────────────────────────────────────────────────
COPY --from=jen /workspace /usr/local/bin
COPY --from=tojson /workspace /usr/local/bin
COPY --from=jsonfmt /workspace /usr/local/bin
COPY --from=just /workspace /usr/local/bin
COPY --from=convco /workspace /usr/local/bin
COPY --from=clog /workspace /usr/local/bin
COPY --from=fd /workspace /usr/local/bin
COPY --from=bat /workspace /usr/local/bin
COPY --from=tokei /workspace /usr/local/bin
COPY --from=sad /workspace /usr/local/bin
COPY --from=releez /workspace /usr/local/bin
COPY --from=skim /workspace /usr/local/bin
COPY --from=delta /workspace /usr/local/bin
COPY --from=delta /opt/delta /tmp/delta
USER "$USER"
RUN \
cat /tmp/delta >> "$HOME/.gitconfig"
# ─── CLEAN UP ───────────────────────────────────────────────────────────────────
USER root
RUN \
rm -rf \
  /tmp/*
# ─── WORKDIR ────────────────────────────────────────────────────────────────────
USER "$USER"
ENV TERM xterm
ARG WORKDIR="/workspace"
ENV WORKDIR $WORKDIR
VOLUME $WORKDIR
WORKDIR $WORKDIR
ENTRYPOINT [ "/bin/bash"]
