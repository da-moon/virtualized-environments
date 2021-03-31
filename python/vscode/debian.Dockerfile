FROM fjolsvin/python-base-debian:latest
# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file debian.Dockerfile --build-arg USER=code --build-arg UID=1000 fjolsvin/vscode-python-debian:latest .
# ────────────────────────────────────────────────────────────────────────────────
#
# ──────────────────────────────────────────────────────────── I ──────────
#   :::::: U S E R   S E T U P : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────
#
ARG USER=code
ENV USER $USER
ARG UID="1000"
ENV UID $UID
ENV SHELL="/bin/bash"
RUN set -ex && \
  useradd \
  --no-log-init \
  --create-home \
  --home-dir "/home/${USER}" \ 
  --uid "${UID}" \
  --groups sudo \
  --shell "${SHELL}" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}"
RUN sed -i \
  -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
  /etc/sudoers
ENV HOME="/home/$USER"
WORKDIR $HOME
RUN set -ex && \
  { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
USER "${USER}"
ARG WORKSPACE="/workspace"
ENV WORKSPACE $WORKSPACE
WORKDIR "${WORKSPACE}"

ARG IMAGE_SPECIFIC_PACKAGES="\
  jq \
  upx \
  "
RUN set -ex && \
  sudo install-packages ${IMAGE_SPECIFIC_PACKAGES}
#
# ──────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P A C K A G E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  sudo python3 -m pip install --no-cache-dir --upgrade pip
ENV PIP_PACKAGES="\
  setuptools \
  wheel \
  virtualenv \
  pipenv \
  pylint \
  rope \
  flake8 \
  mypy \
  autopep8 \
  pep8 \
  pylama \
  pydocstyle \
  bandit \
  notebook \
  twine\
  "
RUN set -ex && \
  sudo  python3 -m pip install --no-cache-dir --upgrade ${PIP_PACKAGES}
#
# ──────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P Y T H O N   P O E T R Y : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────
#
USER "$USER"
ENV POETRY_HOME="${HOME}/.poetry"
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV PATH="${PATH}:${POETRY_HOME}/bin"
RUN set -ex && \
  mkdir -p "${HOME}/.local/bin" && \
  mkdir -p "${POETRY_HOME}/bin" && \ 
  echo '[ -r ${POETRY_HOME}/env ] && . ${HOME}/.poetry/env' | tee -a "$HOME/.bashrc" && \
  curl -fsSL \
  https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
  poetry --version

# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   R U S T   T O O L C H A I N : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV PATH="$PATH:${HOME}/.cargo/bin"
RUN set -ex && \
  echo '[ -r ${HOME}/.cargo/env ] && . ${HOME}/.cargo/env' | tee -a  "$HOME/.bashrc" > /dev/null && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
  -y \
  --default-toolchain nightly \
  --profile default && \
  cargo --version
#
# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   C A R G O   P A C K A G E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  cargo install -j`nproc` pyoxidizer && \
  strip ${HOME}/.cargo/bin/pyoxidizer && \
  upx ${HOME}/.cargo/bin/pyoxidizer && \
  pyoxidizer --version
RUN set -ex && \
  sudo apt-get autoremove -y  && \
  apt-get clean -y  && \
  rm -rf \
     /var/cache/debconf/* \
     /var/lib/apt/lists/* \
     /tmp/* \
     /var/tmp/*