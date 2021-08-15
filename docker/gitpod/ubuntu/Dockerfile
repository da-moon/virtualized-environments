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
# ────────────────────────────────────────────────────────────────────────────────
FROM gitpod/workspace-full:build-branch-master
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
RUN \
  yes | add-apt-repository ppa:neovim-ppa/unstable  > /dev/null 2>&1 \
  && apt-get update -qq \
  && curl https://i.jpillora.com/chisel! | bash  > /dev/null 2>&1 \
  && curl -fsSL https://starship.rs/install.sh | bash -s -- --force > /dev/null 2>&1
ARG APT_PACKAGES="\
  tmux \
  dropbear \
  cmake \
  jq \
  curl \
  neovim \
  fzf \
  xfonts-utils \
  libssl-dev \
  fonts-symbola \
  pandoc \
  librsvg2-bin \
  ncdu \
  pdftk \
  poppler-utils \
  ripgrep \
  texmaker \
  texlive-xetex \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-latex-extra \
  ttf-mscorefonts-installer \
  lmodern \
  xsel \
  xclip \
  "
RUN install-packages ${APT_PACKAGES}
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
RUN \
  curl -fsSl https://bootstrap.pypa.io/get-pip.py | python3 \
  && python2 --version > /dev/null 2>&1 \
  && curl \
    -fsSl https://bootstrap.pypa.io/pip/$(python2 --version 2>&1 | gawk 'BEGIN{FS=OFS="."}{gsub("[^[:digit:].]*","");print $1,$2}')/get-pip.py | python2 \
  || true ;
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
ENV PATH="${PATH}:${HOME}/.local/bin"
WORKDIR "${HOME}"
RUN \
  curl -fsSl https://bootstrap.pypa.io/get-pip.py | python3 \
  && python2 --version > /dev/null 2>&1 \
  && curl \
    -fsSl https://bootstrap.pypa.io/pip/$(python2 --version 2>&1 | gawk 'BEGIN{FS=OFS="."}{gsub("[^[:digit:].]*","");print $1,$2}')/get-pip.py | python2 \
  || true ;
ARG PYTHON_PACKAGES="\
  pre-commit \
  neovim \
  notedown \
  pylint \
  yapf \
  autoflake \
  isort \
  coverage \
  "
RUN \
  IFS=' ' read -a PYTHON_PACKAGES <<< "$PYTHON_PACKAGES" ; \
  pyenv --version > /dev/null 2>&1 && ( \
    $(pyenv which python) -m  pip install --user --no-cache-dir "${PYTHON_PACKAGES[@]}" \
    && pyenv rehash ; \
  ) || python3 -m  pip install --user --no-cache-dir "${PYTHON_PACKAGES[@]}" \
  && python2 -m pip install --user --no-cache-dir "neovim"
# ────────────────────────────────────────────────────────────────────────────────
WORKDIR "/tmp"
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
WORKDIR "${HOME}"
RUN \
  curl -sLf https://spacevim.org/install.sh | bash \
  && find "${HOME}" \
  -not -group "$(id -g gitpod)" \
  -not -user "$(id -u gitpod)" \
  -print \
  | xargs -I {} -P `nproc` --no-run-if-empty \
  chown --no-dereference "$(id -u gitpod):$(id -g gitpod)" {} ;
# ─── SPACEVIM INSTALLATION ──────────────────────────────────────────────────────
USER gitpod
WORKDIR "${HOME}"
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
  "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim" \
  && mkdir -p "$HOME/.local/share/nvim/shada" \
  && nvim --headless \
  -c "call dein#direct_install('deoplete-plugins/deoplete-go', { 'build': 'make' })" \
  -c "call dein#direct_install('Shougo/vimproc.vim', { 'build': 'make' })" \
  -c "call dein#direct_install('iamcco/markdown-preview.nvim', {'on_ft': ['markdown', 'pandoc.markdown', 'rmd'],'build': 'yarn --cwd app --frozen-lockfile install' })" \
  -c "call dein#direct_install('lymslive/vimloo', { 'merged': '0' })" \
  -c "call dein#direct_install('lymslive/vnote', { 'depends': 'vimloo' })" \
  -c "call dein#direct_install('neoclide/coc.nvim', { 'merged': 0, 'rev': 'master', 'build': 'yarn install --frozen-lockfile' })" \
  -c "qall"
RUN \
  mv \
  "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim.bak" \
  "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim"
# ────────────────────────────────────────────────────────────────────────────────
COPY "./.SpaceVim.d/" "${HOME}/.SpaceVim.d"
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
WORKDIR "${HOME}"
RUN \
  nvim --headless \
  -c "call dein#install()" \
  -c "call dein#install()" \
  -c "call dein#update()" \
  -c "call dein#remote_plugins()" \
  -c "qall" \
  && nvim --headless \
  -c "UpdateRemotePlugins" \
  -c "qall" ; \
  if go version > /dev/null 2>&1 ; then \
    nvim --headless \
    -c "GoInstallBinaries" \
    -c "GoUpdateBinaries" \
    -c "qall" ; \
  fi

# ─── INSTALL COC EXTENSIONS ─────────────────────────────────────────────────────
USER gitpod
WORKDIR "${HOME}"
RUN \
  IFS=' ' read -a coc_extensions <<< "$(nvim --headless -c "call PrintCocExtensions()"  -c "qall" 2>&1)" ; \
  [ "${#coc_extensions[@]}" -ne 0  ] \
  && (for ext in "${coc_extensions[@]}"; do nvim --headless -c "CocInstall ${ext}" -c "qall"  ; done) \
  || true
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/tmp/rust-analyzer"
RUN \
  rust-analyzer --version > /dev/null 2>&1 && exit 0 || true; \
  REPO="rust-analyzer/rust-analyzer" ; \
  architecture="$(uname -m)"; \
  toolchain="gnu"; \
  case "$architecture" in \
    x86_64 | amd64) \
      architecture="x86_64" ; \
      grep -qF 'alpine' /etc/os-release && toolchain="musl" \
      ;; \
    aarch64) \
      true \
      ;; \
    *) \
      exit 0 \
      ;; \
  esac ; \
  && curl -sL "https://api.github.com/repos/${REPO}/releases/latest" \
  | jq -r "\
  .assets[]|select(\
  .browser_download_url \
  | (\
  contains(\"${architecture}\") \
  and contains(\"${toolchain}\") \
  and contains(\"linux\") \
  and contains(\"gz\") \
  and (contains(\"sha256\") | not))).browser_download_url" \
  | xargs -r -I {} curl -fsSLo /tmp/rust-analyzer/rust-analyzer.gz {} \
  && gzip -d rust-analyzer.gz \
  && chmod +x rust-analyzer \
  && mv ./rust-analyzer /usr/local/bin/rust-analyzer
WORKDIR /workspace
  rust-analyzer --version \
  && rm -r /tmp/rust-analyzer
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
ARG CARGO_PACKAGES="\
  cargo-make \
  "
RUN \
  IFS=' ' read -a packages <<< "${CARGO_PACKAGES}" ; \
  cargo install --locked --all-features --root /usr/local "${packages[@]}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
ENV EDITOR="nvim"
ENV VISUAL="nvim"
ENV PATH="${PATH}:/usr/local/bin"
WORKDIR "/etc/profile.d"
RUN \
  curl \
  -fsSl https://raw.githubusercontent.com/3hhh/fzfuncs/master/bashrc_fzf \
  -o /etc/profile.d/bashrc_fzf.sh \
  && ( \
  echo 'export PATH="${PATH}:/usr/local/bin"' ; \
  echo "export EDITOR=\"${EDITOR}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \
  echo 'export DOCKER_BUILDKIT="0"' ; \
  echo 'export BUILDKIT_PROGRESS="auto"' ; \
  echo 'export COMPOSE_DOCKER_CLI_BUILD="0"' ; \
  echo 'npm --version >/dev/null 2>&1 && export PATH="${PATH}:$(npm -g bin)" ;' ; \
  echo 'yarn --version >/dev/null 2>&1 && export PATH="${PATH}:$(yarn global bin)" ;' ; \
  echo 'gp --help >/dev/null 2>&1 && eval $(gp env | sed -e "s/\(=[[:blank:]]*\)\(.*\)/\1\"\2\" ;/" -e "s/^/export /g")' ; \
  echo 'starship --version >/dev/null 2>&1 && eval "$(starship init bash)" ;' ; \
  echo 'just --version >/dev/null 2>&1 && eval "$(just --completions bash)" ;' ; \
  echo 'rustup --version >/dev/null 2>&1 && eval "$(rustup completions bash rustup)" && eval "$(rustup completions bash cargo)";' ; \
  echo 'curl --version >/dev/null 2>&1 && source <(curl -sSL git.io/forgit) ;' ; \
  echo "[ -d ${HOME}/go ] && export GOROOT=\"${HOME}/go\";"; \
  echo "[ -d ${HOME}/go ] && export GOPATH=\"${HOME}/go-packages\";"; \
  echo "[ -d ${HOME}/go ] && export PATH=\"\${PATH}:\${GOROOT}/bin:\${GOPATH}/bin\";"; \
  echo "[ -d ${HOME}/.cargo/bin ] && export PATH=\"\${PATH}:${HOME}/.cargo/bin\";"; \
  echo "[ -d ${HOME}/.pyenv/bin ] && export PATH=\"\${PATH}:${HOME}/.pyenv/bin\";"; \
  ) | tee 00-env.sh > /dev/null \
  && ( \
  echo "alias apt='sudo apt'" ; \
  echo "alias g='git'" ; \
  echo 'exa --version >/dev/null 2>&1 && alias la="exa -A";alias ll="exa -alhF";alias ls="exa";' ; \
  echo 'bat --version >/dev/null 2>&1 && alias cat="bat -pp";' ; \
  echo 'just --version >/dev/null 2>&1 && alias j="just";' ; \
  echo "alias nvim='nvim --headless -c \"call dein#recache_runtimepath()\" -c \"UpdateRemotePlugins\" -c \"qall\" && nvim'" ; \
  ) | tee 01-alias.sh > /dev/null \
  && ( \
  echo '(rg -h >/dev/null 2>&1 && bat -h >/dev/null 2>&1 && sk -h >/dev/null 2>&1 ) && function fp { rg --files $1 | sk --preview="bat {} --color=always --style=grid,numbers" ; }' ; \
  echo '(rg -h >/dev/null 2>&1 && sk -h >/dev/null 2>&1 ) && function fs { sk -i -c "rg {} --color=always $1" --ansi ; }' ; \
  ) | tee 02-func.sh > /dev/null \
  && [ -r /etc/bash.bashrc ] && echo 'while read i; do source "$i"; done < <(find /etc/profile.d/ -name "*.sh")' >> /etc/bash.bashrc
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
WORKDIR "${HOME}"
RUN \
  sed -i \
  -e '/^\s*#/d' \
  -e '/cargo/d' \
  -e '/^\s*$/d' \
  "${HOME}/.profile" \
  && ( \
  echo "export EDITOR=\"${EDITOR}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \
  ) | tee -a "${HOME}/.profile" > /dev/null ;
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
COPY --from=fjolsvin/delta:latest /workspace /usr/local/bin
COPY --from=fjolsvin/delta:latest /opt/delta /tmp/delta
WORKDIR "${HOME}"
ENV PATH="$PATH:$HOME/.git-fuzzy/bin/"
RUN \
  cat /tmp/delta >> "$HOME/.gitconfig" \
  && sudo rm /tmp/delta \
  && git clone https://github.com/bigH/git-fuzzy "$HOME/.git-fuzzy" \
  && chmod +x $HOME/.git-fuzzy/bin/*
# ────────────────────────────────────────────────────────────────────────────────
COPY --from=yq /workspace/yq /usr/local/bin/yq
COPY --from=jsonfmt /workspace/jsonfmt /usr/local/bin/jsonfmt
COPY --from=just /workspace/just /usr/local/bin/just
COPY --from=convco /workspace/convco /usr/local/bin/convco
COPY --from=fd /workspace/fd /usr/local/bin/fd
COPY --from=sd /workspace/sd /usr/local/bin/sd
COPY --from=bat /workspace/bat /usr/local/bin/bat
COPY --from=exa /workspace/exa /usr/local/bin/exa
COPY --from=shfmt /workspace/shfmt /usr/local/bin/shfmt
COPY --from=tokei /workspace/tokei /usr/local/bin/tokei
COPY --from=sad /workspace/sad /usr/local/bin/sad
COPY --from=releez /workspace/releez /usr/local/bin/releez
COPY --from=skim /workspace/sk /usr/local/bin/sk
COPY --from=delta /workspace/delta /usr/local/bin/delta
COPY --from=cellar /workspace/cellar /usr/local/bin/cellar
# COPY --from=fjolsvin/scoob:latest /workspace /usr/local/bin
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
WORKDIR /workspace
