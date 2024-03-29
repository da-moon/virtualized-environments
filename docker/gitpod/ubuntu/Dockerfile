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
FROM fjolsvin/ttdl:latest AS ttdl
# hadolint ignore=DL3007
FROM fjolsvin/clog:latest AS clog
# hadolint ignore=DL3007
FROM fjolsvin/git-governance:latest AS git-governance
# ────────────────────────────────────────────────────────────────────────────────
FROM gitpod/workspace-full:build-branch-master
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
RUN \
  add-apt-repository -y ppa:neovim-ppa/unstable > /dev/null 2>&1 \
  && apt-get update -qq > /dev/null 2>&1 \
  && curl -fsSl https://i.jpillora.com/chisel! | bash > /dev/null 2>&1 \
  && curl -fsSL https://starship.rs/install.sh | bash -s -- --force > /dev/null 2>&1 \
  && install-packages \
    tmux \
    dropbear \
    cmake \
    jq \
    ripgrep \
    curl \
    neovim \
    tree \
    fzf \
    xfonts-utils \
    libssl-dev \
    fonts-symbola \
    xsel \
    xauth \
    xclip
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
WORKDIR "${HOME}"
RUN \
  rustup component add clippy rustfmt
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
  curl -sL "https://api.github.com/repos/${REPO}/releases/latest" \
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
RUN \
  rust-analyzer --version \
  && rm -r /tmp/rust-analyzer
# ────────────────────────────────────────────────────────────────────────────────
USER root
ENV EDITOR="nvim"
ENV VISUAL="nvim"
ENV PATH="${PATH}:/usr/local/bin"
ENV PYTHONUSERBASE="/workspace/.pip-modules"
WORKDIR "/etc/profile.d"
RUN \
  [ -d "${HOME}/.bashrc.d" ] && while read i; do ln -sf "$i" "/etc/profile.d/$(basename $i).sh"; done < <(find ${HOME}/.bashrc.d -type f ) || true ; \
  curl \
  -fsSl https://raw.githubusercontent.com/3hhh/fzfuncs/master/bashrc_fzf \
  -o /etc/profile.d/bashrc_fzf.sh \
  && ( \
  echo "export EDITOR=\"${EDITOR}\"" ; \
  echo "export VISUAL=\"${VISUAL}\"" ; \
  echo 'export DOCKER_BUILDKIT="0"' ; \
  echo 'export BUILDKIT_PROGRESS="auto"' ; \
  echo 'export COMPOSE_DOCKER_CLI_BUILD="0"' ; \
  echo 'export GEM_HOME=/workspace/.rvm' ; \
  echo 'export GEM_PATH=$GEM_HOME:$GEM_PATH' ; \
  echo 'export GOROOT="${HOME}/go" ;' ; \
  echo 'export GOPATH="/workspace/go-packages" ;' ; \
  echo "export PYTHONUSERBASE='${PYTHONUSERBASE}' ;" ; \
  echo 'export PATH="${PATH}:/usr/local/bin"' ; \
  echo '[ -d ${GEM_HOME} ] && export PATH="${GEM_HOME}/bin:$PATH" ;' ; \
  echo '[ -d ${GOROOT} ] && export PATH="${GO_ROOT}/bin:$PATH" ;' ; \
  echo '[ -d ${GOPATH} ] && export PATH="${GOPATH}/bin:$PATH" ;' ; \
  echo '[ -d ${HOME}/.local/bin ] && export PATH="${HOME}/.local/bin:${PATH}"' ; \
  echo '[ -d ${HOME}/.cargo/bin ] && export PATH="${HOME}/.cargo/bin:${PATH}";';  \
  echo '[ -d ${PYTHONUSERBASE} ] && export PATH="${PYTHONUSERBASE}/bin:$PATH" ;' ; \
  echo '[ -d ${HOME}/.pyenv/bin ] && export PATH="${HOME}/.pyenv/bin:${PATH}";' ; \
  echo '[ -d ${HOME}/.pyenv/shims ] && export PATH="${HOME}/.pyenv/shims:${PATH}" ;' ; \
  echo '[ -d ${HOME}/bin ] && export PATH="${HOME}/bin":${PATH}' ; \
  echo 'npm --version >/dev/null 2>&1 && export PATH="$(npm -g bin):${PATH}" ;' ; \
  echo 'yarn --version >/dev/null 2>&1 && export PATH="$(yarn global bin):${PATH}" ;' ; \
  echo 'gp --help >/dev/null 2>&1 && (eval $(gp env | sed -e "s/\(=[[:blank:]]*\)\(.*\)/\1\"\2\" ;/" -e "s/^/export /g") ; source <(gp completion) ;)' ; \
  echo 'starship --version >/dev/null 2>&1 && eval "$(starship init bash)" ;' ; \
  echo 'just --version >/dev/null 2>&1 && eval "$(just --completions bash)" ;' ; \
  echo 'rustup --version >/dev/null 2>&1 && eval "$(rustup completions bash rustup)" && eval "$(rustup completions bash cargo)";' ; \
  echo 'curl --version >/dev/null 2>&1 && source <(curl -sSL git.io/forgit) ;' ; \
  ) | tee 00-env.sh > /dev/null \
  && ( \
  echo "alias apt='sudo apt'" ; \
  echo "alias g='git'" ; \
  echo 'exa --version >/dev/null 2>&1 && alias la="exa -A";alias ll="exa -alhF";alias ls="exa";' ; \
  echo 'bat --version >/dev/null 2>&1 && alias cat="bat -pp";' ; \
  echo 'just --version >/dev/null 2>&1 && alias j="just";' ; \
  echo "alias nvim='nvim --headless -c \"call dein#recache_runtimepath()\" -c \"qall\" && nvim'" ; \
  ) | tee 01-alias.sh > /dev/null \
  && ( \
  echo '(rg -h >/dev/null 2>&1 && bat -h >/dev/null 2>&1 && sk -h >/dev/null 2>&1 ) && function fp { rg --files $1 | sk --preview="bat {} --color=always --style=grid,numbers" ; }' ; \
  echo '(rg -h >/dev/null 2>&1 && sk -h >/dev/null 2>&1 ) && function fs { sk -i -c "rg {} --color=always $1" --ansi ; }' ; \
  ) | tee 02-func.sh > /dev/null \
  && [ -r /etc/bash.bashrc ] && (\
    echo 'while read i; do source "$i"; done < <(find /etc/profile.d/ -name "*.sh") ;' ; \
  ) | tee -a /etc/bash.bashrc
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
WORKDIR "${HOME}"
RUN \
  [ -r "${HOME}/.bashrc.d/60-python" ] \
  && sed -i -e 's/pyenv/${HOME}\/.pyenv\/bin\/pyenv/g'  "${HOME}/.bashrc.d/60-python" \
  && sed -i \
    -e '/\$HOME\/\.bashrc\.d/d' \
    -e '/PIP/d' \
    -e '/PYTHONUSERBASE/d' \
    -e '/gp completion/d' \
    -e '/\.cargo\/env/d' \
    -e '/rvm/d' \
    -e '/GEM/d' \
    "${HOME}/.bashrc" \
  && ( \
  echo "[ -r '\${HOME}/.bashrc' ] && sed -i \\" ; \
  echo "-e '/\\\$HOME\/\.bashrc\.d/d' \\" ; \
  echo "-e '/cargo/d' \\" ; \
  echo "-e '/PIP/d' \\" ; \
  echo "-e '/PYTHONUSERBASE/d' \\" ; \
  echo "-e '/gp completion/d' \\" ; \
  echo "-e '/rvm/d' \\" ; \
  echo "-e '/GEM/d' \\" ; \
  echo "'\${HOME}/.bashrc' \\" ; \
  echo '&& . ${HOME}/.bashrc' ; \
  ) | tee "${HOME}/.profile" > /dev/null ;
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/workspace"
RUN \
  find "${HOME}" \
  -not -group "$(id -g gitpod)" \
  -not -user "$(id -u gitpod)" \
  -print \
  | xargs -I {} -P $(nproc) --no-run-if-empty \
  chown --no-dereference "$(id -u gitpod):$(id -g gitpod)" {} \
  &&  chown "$(id -u gitpod):$(id -g gitpod)" "/workspace" -R
# ─── SPACEVIM INSTALLATION ──────────────────────────────────────────────────────
USER gitpod
RUN \
  git clone "https://github.com/da-moon/SpaceVim.d.git" "${HOME}/.SpaceVim.d" \
  && curl -fSsl "https://raw.githubusercontent.com/da-moon/SpaceVim.d/master/spacevim-installer.sh" | bash
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
COPY --chmod=0755 --from=fjolsvin/delta:latest /workspace /usr/local/bin
COPY --chmod=0755 --from=fjolsvin/delta:latest /opt/delta /tmp/delta
WORKDIR "${HOME}"
ENV PATH="$PATH:$HOME/.git-fuzzy/bin/"
RUN \
  cat /tmp/delta >> "$HOME/.gitconfig" \
  && sudo rm /tmp/delta \
  && git clone https://github.com/bigH/git-fuzzy "$HOME/.git-fuzzy" \
  && chmod +x $HOME/.git-fuzzy/bin/*
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
ARG CARGO_PACKAGES="\
  cargo-make \
  "
RUN \
  rustup default stable ; \
  IFS=' ' read -a packages <<< "${CARGO_PACKAGES}" ; \
  cargo install --locked --all-features --root /usr/local "${packages[@]}"
# ────────────────────────────────────────────────────────────────────────────────
USER root
WORKDIR "/root"
ARG APT_PACKAGES="\
  pandoc \
  librsvg2-bin \
  ncdu \
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
# RUN install-packages ${APT_PACKAGES}
RUN \
  find "${HOME}" \
    -not -group "$(id -g gitpod)" \
    -not -user "$(id -u gitpod)" \
    -print \
  | xargs -I {} -P $(nproc) --no-run-if-empty \
  chown --no-dereference "$(id -u gitpod):$(id -g gitpod)" {} ; \
  [ -d /workspace ] && chown "$(id -u gitpod):$(id -g gitpod)" "/workspace" ; \
  yarn cache clean --all \
  && npm -g cache clean --force > /dev/null 2>&1 \
  && rm -rf \
    /tmp/*
# ────────────────────────────────────────────────────────────────────────────────
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
COPY --chmod=0755 --from=ttdl /workspace/ttdl /usr/local/bin/ttdl
COPY --chmod=0755 --from=clog /workspace/clog /usr/local/bin/clog
COPY --chmod=0755 --from=git-governance /workspace/gg /usr/local/bin/gg
# COPY --chmod=0755 --from=fjolsvin/scoob:latest /workspace /usr/local/bin
# ────────────────────────────────────────────────────────────────────────────────
USER gitpod
WORKDIR /workspace
