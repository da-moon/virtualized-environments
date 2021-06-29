FROM gitpod/workspace-full
USER root
RUN \
  yes | add-apt-repository ppa:neovim-ppa/unstable
ARG APT_PACKAGES="\
  cmake \
  xfonts-utils \
  neovim \
"
RUN \
  curl \
  -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose \
  && yes | add-apt-repository ppa:neovim-ppa/unstable \
  && apt-get update \
  && apt-get -y full-upgrade \
  && install-packages ${APT_PACKAGES}
ARG PYTHON_PACKAGES="\
  pre-commit \
  pylint \
  yapf \
  autoflake \
  isort \
  coverage \ 
"
ARG NODEJS_PACKAGES="\
  @commitlint/cli \
  @commitlint/config-conventional \
  remark \
  remark-cli \
  remark-stringify \
  remark-frontmatter \
  wcwidth \
  bash-language-server \
  prettier \
"
# spacevim python and nodejs packages
RUN \
  python3 -m pip install --no-cache-dir ${PYTHON_PACKAGES} \
  && yarn global add --prefix /usr/local ${NODEJS_PACKAGES}
RUN \
  curl -sLf https://spacevim.org/install.sh | bash
WORKDIR /workspace
RUN \
  find \
    /workspace \
    -not -group `id -g` \
    -not -user `id -u` \
    -print0 | sudo xargs \
    --no-run-if-empty  \
    -0 \
    -P 0 \
    chown --no-dereference "`id -u gitpod`:`id -g` gitpod" \
  && find \
    "${HOME}" \
    -not -group `id -g` \
    -not -user `id -u` \
    -print0 | sudo xargs \
    --no-run-if-empty  \
    -0 \
    -P 0 \
    chown --no-dereference "`id -u gitpod`:`id -g gitpod`"

USER gitpod
RUN curl -sLf https://spacevim.org/install.sh | bash
RUN cargo install -j `nproc` convco && sudo ln -s ~/.cargo/bin/convco /usr/local/bin/convco
RUN cargo install -j `nproc` clog-cli && sudo ln -s ~/.cargo/bin/clog /usr/local/bin/clog
ENV EDITOR nvim
ENV GP_OPEN_EDITOR="${EDITOR}"
ENTRYPOINT [ "/bin/bash" ]
