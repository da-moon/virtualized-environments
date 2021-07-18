FROM fjolsvin/rust-base-debian
ENV TERM=xterm
USER root
# ────────────────────────────────────────────────────────────────────────────────
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2 \
  jq \
  htop \
  upx \
  make \
  ncdu \
  rename \
  "
RUN set -ex && \
  install-packages ${IMAGE_SPECIFIC_PACKAGES}
# ─── VSCODE LIVE SHARE ──────────────────────────────────────────────────────────
RUN set -ex && \
  for i in {1..5}; do wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && break || sleep 15; done && \
  bash /tmp/vsls-reqs && \
  rm /tmp/vsls-reqs
#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C R E A T I N G   U S E R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#
ARG USER=code
ENV USER $USER
ARG UID="1000"
ENV UID $UID
SHELL ["bash","-c"]
RUN set -ex && \
  useradd \
  --no-log-init \
  --create-home \
  --home-dir "/home/${USER}" \
  --uid "${UID}" \
  --groups sudo \
  --shell "/bin/bash" \
  --password \
  $(perl -e 'print crypt($ARGV[0], "password")' "${USER}_${UID}" 2>/dev/null) \
  "${USER}"
RUN usermod -aG root,sudo "${USER}"
USER ${USER}
SHELL ["bash","-c"]

ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
ARG INSTALLER_SCRIPTS="\
  https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/starship \
  https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/rust-core-utils \
  "
RUN \
  set -ex && \
  IFS=' ' read -a INSTALLER_SCRIPTS <<< "$INSTALLER_SCRIPTS" && \
  for url in ${INSTALLER_SCRIPTS[@]};do \
  curl -fsSl ${url} | bash ; \
  done;
ARG WORKDIR="/workspace"
ENV WORKDIR $WORKDIR
WORKDIR $WORKDIR
RUN \
  set -ex && \
  find ${RUST_HOME} -not -group `id -g` -not -user `id -u` -print0 | sudo xargs -P 0 -0 --no-run-if-empty chown --no-dereference "`id -u`:`id -g`" && \
  sudo chown "$(id -u):$(id -g)" . -R && \
  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  echo '[ -f $CARGO_HOME/env ] && . $CARGO_HOME/env' | tee -a ~/.bashrc > /dev/null && \
  echo 'if [ -e /var/run/docker.sock ]; then sudo chown "$(id -u):docker" /var/run/docker.sock; fi' | tee -a ~/.bashrc
RUN \
  set -ex && \
  sudo apt-get autoremove -y && \
  sudo apt-get clean -y && \
  sudo rm -rf "/tmp/*"
ENTRYPOINT [ "/bin/bash" ]
