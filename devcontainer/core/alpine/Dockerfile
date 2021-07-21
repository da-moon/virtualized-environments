# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/workspace' --rm -it fjolsvin/base-alpine
# ────────────────────────────────────────────────────────────────────────────────

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
&& ! getent group "${USER}" > /dev/null && groupadd sudo \
&& useradd \
  --user-group \
  --no-log-init \
  --create-home \
  --home-dir "/${HOME}" \
  --gid "${UID}" \
  --uid "${UID}" \
  --groups sudo \
  --shell "/bin/bash" \
  --password \
  $(perl \
    -e 'print crypt($ARGV[0], "password")' \
      "${USER}_${UID}" 2>/dev/null) \
"${USER}" \
&& usermod -aG wheel,root ;
# ─── INSTALLING CORE PACKAGES ───────────────────────────────────────────────────
USER root
ARG CORE_PACKAGES="\
  pacman-contrib \
  expac \
  base-devel \
  git \
  wget \
  curl \
  chisel \
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
for i in {1..5}; do \
  makepkg -sic --noconfirm && break || sleep 15 \
done ;
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
IFS=' ' read -a PACKAGES <<< "$PYTHON_PACKAGES" ; \
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
  curl -sLf https://spacevim.org/install.sh | bash \
  && timeout 40 \
  nvim --headless \
  +VimProcInstall \
  +'call dein#install()'  \
  +UpdateRemotePlugins  \
  +qall || true ;
# ─── RUST TOOLCHAIN SETUP ───────────────────────────────────────────────────────
USER root
RUN \
  pacman -Rcns --noconfirm rust || true ;
ENV RUSTUP_HOME="/usr/local/rustup"
ENV CARGO_HOME="/usr/local/cargo"
ENV PATH="/usr/local/cargo/bin:$PATH"
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
cargo install --all-features -j"$(nproc)" "${PACKAGES[@]}" \
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
  echo '[ $(command -v fzf) ] && source /etc/bashrc_fzf ;' ; \
  ) | sudo tee -a /etc/bash.bashrc > /dev/null ;
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
ENV TERM xterm
ARG WORKDIR="/workspace"
ENV WORKDIR $WORKDIR
VOLUME $WORKDIR
WORKDIR $WORKDIR
USER "$USER"

# FROM alpine:edge
# USER root
# ARG BASE_PACKAGES="\
#   libc6-compat \
#   alpine-sdk \
#   autoconf  \
#   automake  \
#   binutils \
#   build-base  \
#   ca-certificates  \
#   cmake  \
#   coreutils  \
#   curl  \
#   doxygen \
#   gettext-tiny-dev  \
#   git  \
#   gtest-dev \
#   less  \
#   libtool  \
#   lua  \
#   make \
#   nodejs \
#   npm \
#   openssl  \
#   perl \
#   pkgconf  \
#   python3-dev  \
#   py3-pip  \
#   tmux  \
#   unzip  \
#   xclip  \
#   yarn \
#   zlib-dev \
#   "

# RUN \
#   ( \
#   echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
#   ) | tee /etc/apk/repositories > /dev/null ; \
#   apk upgrade --no-cache -U -a \
#   && apk add --update --no-cache ${BASE_PACKAGES} \
#   || ( \
#   sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
#   && apk add --update --no-cache ${BASE_PACKAGES} \
#   )

# WORKDIR "/usr/src/neovim"
# RUN \
#   git clone https://github.com/neovim/neovim.git "/usr/src/neovim" \
#   && make -j`nproc` CMAKE_BUILD_TYPE=RelWithDebInfo  \
#   CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local"  \
#   && make -j`nproc` install  \
#   && rm -r /usr/src/neovim
# WORKDIR "/usr/src/ctags"
# RUN  \
#   git clone https://github.com/universal-ctags/ctags.git "/usr/src/ctags" \
#   && ./autogen.sh  \
#   && ./configure  \
#   && make -j`nproc` \
#   && make -j`nproc` install  \
#   && rm -rf /usr/src/ctags
# ARG IMAGE_SPECIFIC_PACKAGES="\
#   aria2 \
#   bash \
#   bash-completion \
#   bat \
#   bzip2 \
#   docker \
#   docker-compose \
#   exa \
#   fd \
#   findutils \
#   fontconfig \
#   fzf \
#   fzf-bash-completion \
#   gawk \
#   git-secret \
#   glow \
#   gnupg \
#   grep \
#   htop \
#   jq \
#   just \
#   just-bash-completion \
#   libcap \
#   libffi-dev \
#   mkfontscale \
#   musl-dev \
#   ncurses \
#   ncurses-dev \
#   ncurses-static \
#   nerd-fonts \
#   openssl-dev \
#   ripgrep \
#   ripgrep-bash-completion \
#   rng-tools-extra \
#   shadow \
#   starship \
#   sudo \
#   tokei \
#   tree \
#   util-linux \
#   wget \
#   "

# RUN \
#   ( \
#   echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
#   echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
#   ) | tee /etc/apk/repositories > /dev/null ; \
#   apk upgrade --no-cache -U -a \
#   && apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
#   || ( \
#   sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
#   && apk add --update --no-cache ${IMAGE_SPECIFIC_PACKAGES} \
#   )
# SHELL ["bash","-c"]
# RUN \
#   getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
# RUN \
#   sed -i \
#   -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
#   -e '/%sudo.*NOPASSWD:ALL/d' \
#   /etc/sudoers \
#   && echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers \
#   && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# ARG PYTHON_PACKAGES="\
#   pynvim \
#   pre-commit \
#   pylint \
#   yapf \
#   autoflake \
#   isort \
#   coverage \
#   "
# RUN \
#   sudo python3 -m pip install --no-cache-dir ${PYTHON_PACKAGES}
# ARG NODEJS_PACKAGES="\
#   remark \
#   remark-cli \
#   remark-stringify \
#   remark-frontmatter \
#   wcwidth \
#   prettier \
#   bash-language-server \
#   dockerfile-language-server-nodejs \
#   standard-readme-spec \
#   "
# RUN \
#   yarn global add --prefix /usr/local ${NODEJS_PACKAGES}
# RUN \
#   curl -sLf https://spacevim.org/install.sh | bash
# #
# # ────────────────────────────────────────────────────────────────── I ──────────
# #   :::::: C R E A T I N G   U S E R : :  :   :    :     :        :          :
# # ────────────────────────────────────────────────────────────────────────────
# #
# ARG USER=devel
# ENV USER $USER
# ARG UID="1000"
# ENV UID $UID
# SHELL ["bash","-c"]
# RUN \
#   useradd \
#   --user-group \
#   --no-log-init \
#   --create-home \
#   --home-dir "/home/${USER}" \
#   --uid "${UID}" \
#   --groups sudo \
#   --shell "/bin/bash" \
#   --password \
#   $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
#   "${USER}" \
#   && usermod -aG wheel,root,sudo,docker "${USER}"
# USER ${USER}
# SHELL ["bash","-c"]
# ENV SHELL="/bin/bash"
# ENV HOME="/home/${USER}"
# ENV PIP_USER="false"
# RUN \
#   echo 'alias apk="sudo apk"' | tee -a ~/.bashrc > /dev/null \
#   && echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
# ENV EDITOR="nvim"
# ENV VISUAL="nvim"
# RUN \
#   curl -sLf https://spacevim.org/install.sh | bash
# COPY .SpaceVim.d "${HOME}/"
# RUN \
#   timeout 200 \
#   nvim --headless \
#   +VimProcInstall \
#   +'call dein#install()'  \
#   +UpdateRemotePlugins  \
#   +qall || true ;
# USER root
# RUN \
#   chmod +x /usr/local/bin/* \
#   && yarn cache clean --all \
#   && rm -rf \
#   /tmp/* \
#   /usr/src
# USER ${USER}
# ENV TERM xterm
# ARG WORKDIR="/workspace"
# ENV WORKDIR $WORKDIR
# VOLUME $WORKDIR
# WORKDIR $WORKDIR
# COPY --from=fjolsvin/convco:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/clog:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/sad:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/skim:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/releez:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/delta:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/delta:latest /opt/delta /tmp/delta
# ENV PATH="$PATH:$HOME/.git-fuzzy/bin/"
# RUN \
#   cat /tmp/delta >> "$HOME/.gitconfig" \
#   && sudo rm /tmp/delta \
#   && git clone https://github.com/bigH/git-fuzzy "$HOME/.git-fuzzy" \
#   && chmod +x $HOME/.git-fuzzy/bin/*
# ENTRYPOINT [ "/bin/bash" ]
