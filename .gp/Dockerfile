# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
FROM gitpod/workspace-full:build-branch-master
USER root
SHELL ["/bin/bash","-c"]
RUN \
  yes | add-apt-repository ppa:neovim-ppa/unstable \
  && apt-get update \
  && curl https://i.jpillora.com/chisel! | bash \
  && curl -fsSL https://starship.rs/install.sh | sudo bash -s -- --force --verbose \
  && echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null \
  && echo 'export EDITOR="nvim"' | tee -a ~/.bashrc > /dev/null \
  && echo 'export VISUAL="nvim"' | tee -a ~/.bashrc > /dev/null

ARG APT_PACKAGES="\
  dropbear \
  cmake \
  xfonts-utils \
  neovim \
  jq \ 
  curl \
  libssl-dev \
  fonts-symbola \
  fzf \
  "
RUN install-packages ${APT_PACKAGES}
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
  python3 -m pip install --no-cache-dir ${PYTHON_PACKAGES}
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
  curl -sLf https://spacevim.org/install.sh | bash \
  && find "${HOME}" \
  -not -group "$(id -g gitpod)" \
  -not -user "$(id -u gitpod)" \
  -print \
  | xargs -I {} -P `nproc` --no-run-if-empty \ 
  chown --no-dereference "$(id -u gitpod):$(id -g gitpod)" {} ;
USER gitpod
WORKDIR /workspace
RUN \
  sed -i \
  -e '1s/^/export PIP_USER="false"\n/' \
  -e '1s/^/export VISUAL="nvim"\n/' \
  -e '1s/^/export EDITOR="nvim"\n/' \
  -e '1s/^/eval "$(starship init bash)"\n/' \
  -e '1s/^/[ -d ~\/go ] \&\& export PATH="${PATH}:${GOROOT}\/bin:${GOPATH}\/bin" \n/' \
  -e '1s/^/[ -d ~\/go ] \&\&  export GOPATH=~\/go-packages ; \n/' \
  -e '1s/^/[ -d ~\/go ] \&\&  export GOROOT=~\/go ; \n/' \
  -e '1s/^/[ -d ~\/.pyenv ] \&\& export PATH="${PATH}:~\/.pyenv\/bin:~\/.pyenv\/shims" \n/' \
  -e '1s/^/export PATH="${PATH}:\/usr\/local\/bin"\n/' \
  ~/.profile

ENV EDITOR="nvim"
ENV VISUAL="nvim"
RUN \
  curl -sLf https://spacevim.org/install.sh | bash \
  && timeout 120 nvim --headless +"call dein#install#_update([], 'update', 0)" +qall \
  && timeout 120 nvim --headless +"call dein#add('Shougo/vimproc.vim', {'build': 'make'})" +qall  \
  && timeout 120 nvim --headless +VimProcInstall +qall \
  && timeout 120 vim "+call dein#install#_update([], 'update', 0)" +qall \
  && timeout 120 vim "+call dein#add('Shougo/vimproc.vim', {'build': 'make'})" +qall  \
  && timeout 120 vim +VimProcInstall +qall
COPY "./.SpaceVim.d" "${HOME}/.SpaceVim.d"
RUN  timeout 120 vim "+call dein#install()" +qall || true
RUN  timeout 120 nvim --headless +'call dein#install()' +qall || true
COPY --from=fjolsvin/just:latest /workspace /usr/local/bin
COPY --from=fjolsvin/convco:latest /workspace /usr/local/bin
COPY --from=fjolsvin/clog:latest /workspace /usr/local/bin
