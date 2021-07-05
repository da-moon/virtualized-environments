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
  && curl -fsSL https://starship.rs/install.sh | sudo bash -s -- --force 
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
  prettier \
  bash-language-server \
  dockerfile-language-server-nodejs \
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
ENV EDITOR="nvim"
ENV VISUAL="nvim"
ENV PIP_USER="nvim"
ENV HOME="/home/${USER}"
RUN \
  rustup default stable ; \
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
  echo 'eval "$(starship init bash)";' ; \
  ) | sudo tee -a /etc/bash.bashrc > /dev/null ; \
  && sudo rustup default stable ;
COPY "./.SpaceVim.d" "${HOME}/.SpaceVim.d"
RUN \
  curl -sLf https://spacevim.org/install.sh | bash \
  && timeout 200 \
    nvim --headless \
    +VimProcInstall \
    +'call dein#install()'  \
    +UpdateRemotePlugins  \
    +qall || true ;
COPY --from=fjolsvin/just:latest /workspace /usr/local/bin
COPY --from=fjolsvin/convco:latest /workspace /usr/local/bin
COPY --from=fjolsvin/clog:latest /workspace /usr/local/bin
WORKDIR /workspace
