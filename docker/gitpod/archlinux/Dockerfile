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
FROM archlinux:base
WORKDIR /tmp/
# ─── INITIAL SETUP ──────────────────────────────────────────────────────────────
USER root
RUN \
  pacman-key --init \
  && pacman-key --populate archlinux \
  && pacman -Syyu --noconfirm \
  && pacman -S --noconfirm bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ─── CONFIGURING PACMAN ─────────────────────────────────────────────────────────
USER root
RUN \
sed -i \
  -e "/ParallelDownloads/d" \
  -e  '/\[options\]/a ParallelDownloads = 16' \
/etc/pacman.conf \
&& sed -i \
  -e "/Color/d" \
  -e "/ILoveCandy/d" \
  -e '/\[options\]/a Color' \
  -e '/\[options\]/a ILoveCandy' \
/etc/pacman.conf ;
# ─── FINDING FASTEST SOURCES ────────────────────────────────────────────────────
USER root
RUN \
pacman -S --noconfirm reflector \
&& reflector \
  --verbose \
  -p https \
  --latest 5 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist
# ─── SUDO SETUP ─────────────────────────────────────────────────────────────────
USER root
RUN \
pacman -Sy --noconfirm sudo \
&& ! getent group sudo > /dev/null && groupadd sudo \
&& sed -i \
  -e '/%wheel.*NOPASSWD:\s*ALL/d' \
  -e '/%wheel\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
/etc/sudoers \
&& ( \
echo "%wheel ALL=(ALL) ALL" ; \
echo "%wheel ALL=(ALL) NOPASSWD: ALL" ; \
) | tee -a /etc/sudoers > /dev/null ;
# ─── USER CREATION ──────────────────────────────────────────────────────────────
USER root
ENV USER="gitpod"
ENV UID="33333"
ENV HOME="/home/${USER}"
RUN \
pacman -Sy --noconfirm perl \
&& ! getent group "${USER}" > /dev/null \
&& groupadd --gid "${UID}" "${USER}" > /dev/null > /dev/null \
&& useradd \
  --no-log-init \
  --create-home \
  --home-dir "${HOME}" \
  --gid "${UID}" \
  --uid "${UID}" \
  --groups sudo \
  --shell "/bin/bash" \
  --password \
  $(perl \
    -e 'print crypt($ARGV[0], "password")' \
      "${USER}_${UID}" 2>/dev/null) \
"${USER}"  \
&& usermod -aG wheel,root "${USER}" ;
# ─── INSTALLING CORE PACKAGES ───────────────────────────────────────────────────
USER root
ARG CORE_PACKAGES="\
  pacman-contrib \
  expac \
  base-devel \
  git \
  wget \
  curl \
  dropbear \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$CORE_PACKAGES" ; \
pacman -Sy --noconfirm --needed "${PACKAGES[@]}"
# ─── PARU INSTALL ───────────────────────────────────────────────────────────────
USER "$USER"
RUN \
  git clone https://aur.archlinux.org/paru.git /tmp/paru
WORKDIR /tmp/paru
RUN \
for i in {1..5}; do makepkg -sic --noconfirm && break || sleep 15; done
USER root
RUN \
pacman \
  -Rcns --noconfirm rust > /dev/null 2>&1 || true
# ─── DEVEL PACKAGES ─────────────────────────────────────────────────────────────
USER root
ARG DEVEL_PACKAGES="\
  cmake \
  go \
  perl \
  python \
  python2 \
  nodejs \
  ruby \
  python2-pip \
  python-pip \
  python-poetry \
  yarn \
  ansible \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$DEVEL_PACKAGES" ; \
pacman -Sy --noconfirm --needed "${PACKAGES[@]}"
# ─── COMMON CLI PACKAGES ────────────────────────────────────────────────────────
USER root
ARG COMMON_CLI_PACKAGES="\
  bash-completion \
  sshpass \
  unzip \
  fzf \
  aria2 \
  jq \
  github-cli \
  rsync \
  rclone \
  parallel \
  tmux \
  htop \
  progress \
  unrar \
  dialog \
  psutils \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$COMMON_CLI_PACKAGES" ; \
pacman -Sy --noconfirm --needed "${PACKAGES[@]}"
# ─── FONT PACKAGES ──────────────────────────────────────────────────────────────
USER root
ARG FONT_PACKAGES="\
  noto-fonts \
  ttf-ubuntu-font-family \
  ttf-dejavu \
  ttf-freefont \
  ttf-liberation \
  ttf-droid \
  ttf-inconsolata \
  ttf-roboto \
  terminus-font \
  ttf-font-awesome \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$FONT_PACKAGES" ; \
pacman -Sy --noconfirm --needed "${PACKAGES[@]}"
# ─── AUR PACKAGES ───────────────────────────────────────────────────────────────
USER "$USER"
ARG AUR_PACKAGES="\
  chisel \
  glow \
  rcm \
  xorg-font-utils \
  git-completion \
  yarn-completion-git \
  fzf-extras \
  "
RUN \
paru \
  --needed \
  --removemake \
  --cleanafter \
  --noconfirm \
  -Sy \
"${PACKAGES[@]}"
# ─── DOCKER SETUP ───────────────────────────────────────────────────────────────
USER root
RUN \
pacman \
  -Sy \
  --noconfirm \
  --needed docker docker-compose \
&& usermod -aG docker "$USER" ;
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
ENV PIP_USER="false"
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
# ─── SPACEVIM ───────────────────────────────────────────────────────────────────
USER root
RUN \
  curl -sLf https://spacevim.org/install.sh | bash \
  && timeout 40 \
  nvim --headless \
  +VimProcInstall \
  +'call dein#install()'  \
  +UpdateRemotePlugins  \
  +qall || true ;
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
# ─── RUST TOOLCHAIN SETUP ───────────────────────────────────────────────────────
USER root
RUN \
  pacman -Rcns --noconfirm rust > /dev/null 2>&1 || true ;
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
  --profile default \
&& chown "$(id -u $USER):$(id -g $USER)" "${RUSTUP_HOME}" -R \
&& chown "$(id -u $USER):$(id -g $USER)" "${CARGO_HOME}" -R
USER "$USER"
RUN \
rustup --version \
&& cargo --version \
&& rustc --version
RUN \
rustup toolchain install "nightly-$(uname -m)-unknown-linux-gnu" \
&& rustup default "stable-$(uname -m)-unknown-linux-gnu" \
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
cargo install --all-features -j"$(nproc)" "${PACKAGES[@]}"
ARG RUST_NIGHTLY_PACKAGES="\
  ripgrep \
  "
RUN \
IFS=' ' read -a PACKAGES <<< "$RUST_NIGHTLY_PACKAGES" ; \
rustup default "nightly-$(uname -m)-unknown-linux-gnu" ; \
cargo install --all-features -j"$(nproc)" "${PACKAGES[@]}" ; \
rustup default "stable-$(uname -m)-unknown-linux-gnu" ;
# ─── GLOBAL PROFILE SETUP ───────────────────────────────────────────────────────
USER root
ENV EDITOR="nvim"
ENV VISUAL="${EDITOR}"
RUN \
curl \
  -fsSl https://raw.githubusercontent.com/3hhh/fzfuncs/master/bashrc_fzf \
  -o /etc/bashrc_fzf \
&& sed -i \
  -e '/^\s*#/d' \
  -e '/PIP_USER/d' \
  -e '/nvim/d' \
  -e '/local/d' \
  -e '/starship/d' \
  -e '/rustup/d' \
  -e '/^\s*$/d' \
  /etc/bash.bashrc \
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
  ) | tee -a /etc/bash.bashrc > /dev/null \
  && find "${HOME}" \
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
