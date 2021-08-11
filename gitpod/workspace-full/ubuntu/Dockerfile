# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
FROM gitpod/workspace-full:build-branch-master
USER root
SHELL ["/bin/bash","-c"]
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
  xsel \
  xclip \
  pandoc \
  librsvg2-bin \
  pdftk \
  poppler-utils \
  texmaker \
  texlive-xetex \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-latex-extra \
  ttf-mscorefonts-installer \
  lmodern \
  "
RUN install-packages ${APT_PACKAGES}
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
ENV PIP_USER="false"
RUN \
  IFS=' ' read -a PYTHON_PACKAGES <<< "$PYTHON_PACKAGES" ; \
  python3 -m pip install --no-cache-dir "${PYTHON_PACKAGES[@]}" \
  && python -m pip install --no-cache-dir "neovim"
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
RUN \
  curl -sLf https://spacevim.org/install.sh | bash \
  && find "${HOME}" \
  -not -group "$(id -g gitpod)" \
  -not -user "$(id -u gitpod)" \
  -print \
  | xargs -I {} -P `nproc` --no-run-if-empty \
  chown --no-dereference "$(id -u gitpod):$(id -g gitpod)" {} ;
ENV EDITOR="nvim"
ENV VISUAL="nvim"
ENV PIP_USER="false"
RUN \
  sudo curl -fsSl https://raw.githubusercontent.com/3hhh/fzfuncs/master/bashrc_fzf -o /etc/bashrc_fzf \
  && sudo sed -i \
  -e '/^\s*#/d' \
  -e '/gitpod/d' \
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
  echo "[ -d ${HOME}/.cargo/bin ] && export PATH=\"\${PATH}:${HOME}/.cargo/bin\";"; \
  echo "[ -d ${HOME}/.pyenv/bin ] && export PATH=\"\${PATH}:${HOME}/.pyenv/bin\";"; \
  echo "[ -d ${HOME}/.pyenv/shims ] && export PATH=\"\${PATH}:${HOME}/.pyenv/shims\";"; \
  echo "[ -d ${HOME}/go ] && export GOROOT=\"${HOME}/go\";"; \
  echo "[ -d ${HOME}/go ] && export GOPATH=\"${HOME}/go-packages\";"; \
  echo "[ -d ${HOME}/go ] && export PATH=\"\${PATH}:\${GOROOT}/bin:\${GOPATH}/bin\";"; \
  echo '[ $(command -v gp) ] && eval $(gp env | sed -e "s/\(=[[:blank:]]*\)\(.*\)/\1\"\2\" ;/" -e "s/^/export /g")' ; \
  echo '[ $(command -v starship) ] && eval "$(starship init bash)";' ; \
  echo '[ $(command -v just) ] && eval "$(just --completions bash)"; alias j="just";' ; \
  echo '[ $(command -v rustup) ] && eval "$(rustup completions bash rustup)"; eval "$(rustup completions bash cargo)";' ; \
  echo '[ $(command -v fzf) ] && source /etc/bashrc_fzf ;' ; \
  echo 'command -- curl --version >/dev/null 2>&1 && source <(curl -sSL git.io/forgit) ;' ; \
  ) | sudo tee -a /etc/bash.bashrc > /dev/null ;
  
USER gitpod
RUN \
  sed -i \
  -e '/^\s*#/d' \
  -e '/PIP_USER/d' \
  -e '/cargo/d' \
  -e '/^\s*$/d' \
  "${HOME}/.profile" \
  && ( \
  echo "export EDITOR=\"${EDITOR}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \
  echo "export PIP_USER=\"${PIP_USER}\"" ; \
  ) | tee -a "${HOME}/.profile" > /dev/null ;
# ─── SPACEVIM INSTALLATION ──────────────────────────────────────────────────────
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
  -c "call dein#direct_install('iamcco/markdown-preview.nvim', {'on_ft': ['markdown', 'pandoc.markdown', 'rmd'],'build': 'yarn --cwd app --frozen-lockfile install' })" \
  -c "call dein#direct_install('lymslive/vimloo', { 'merged': '0' })" \
  -c "call dein#direct_install('lymslive/vnote', { 'depends': 'vimloo' })" \
  -c "call dein#direct_install('neoclide/coc.nvim', { 'merged': 0, 'rev': 'master', 'build': 'yarn install --frozen-lockfile' })" \
  -c "qall"
RUN \
  mv \
    "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim.bak" \
    "$HOME/.SpaceVim/autoload/SpaceVim/plugins.vim"
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
RUN \
  IFS=' ' read -a coc_extensions <<< "$(nvim --headless -c "call PrintCocExtensions()"  -c "qall" 2>&1)" ; \
  [ "${#coc_extensions[@]}" -ne 0  ] \
  && (for ext in "${coc_extensions[@]}"; do nvim --headless -c "CocInstall ${ext}" -c "qall"  ; done) \
  || true

COPY --from=fjolsvin/delta:latest /workspace /usr/local/bin
COPY --from=fjolsvin/delta:latest /opt/delta /tmp/delta
ENV PATH="$PATH:$HOME/.git-fuzzy/bin/"
RUN \
  cat /tmp/delta >> "$HOME/.gitconfig" \
  && sudo rm /tmp/delta \
  && git clone https://github.com/bigH/git-fuzzy "$HOME/.git-fuzzy" \
  && chmod +x $HOME/.git-fuzzy/bin/*
COPY --from=fjolsvin/just:latest /workspace /usr/local/bin
COPY --from=fjolsvin/convco:latest /workspace /usr/local/bin
COPY --from=fjolsvin/clog:latest /workspace /usr/local/bin
COPY --from=fjolsvin/fd:latest /workspace /usr/local/bin
COPY --from=fjolsvin/bat:latest /workspace /usr/local/bin
COPY --from=fjolsvin/tokei:latest /workspace /usr/local/bin
COPY --from=fjolsvin/jsonfmt:latest /workspace /usr/local/bin
COPY --from=fjolsvin/tojson:latest /workspace /usr/local/bin
COPY --from=fjolsvin/sad:latest /workspace /usr/local/bin
COPY --from=fjolsvin/releez:latest /workspace /usr/local/bin
COPY --from=fjolsvin/skim:latest /workspace /usr/local/bin
COPY --from=fjolsvin/ripgrep:latest /workspace /usr/local/bin
COPY --from=fjolsvin/shfmt:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/exa:latest /workspace /usr/local/bin
# COPY --from=fjolsvin/scoob:latest /workspace /usr/local/bin
WORKDIR /workspace
