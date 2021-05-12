# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --build-arg USER=code --build-arg UID=1000 --tag fjolsvin/vscode-golang-alpine:latest .
# ────────────────────────────────────────────────────────────────────────────────

FROM fjolsvin/golang-base-alpine
ENV TERM=xterm
USER root
# ────────────────────────────────────────────────────────────────────────────────
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2 \
  rng-tools-extra \
  openssl-dev \
  libffi-dev \
  jq \
  htop \
  bzip2 \
  yarn \
  nodejs \
  ripgrep \
  ripgrep-bash-completion \
  bat \
  tokei \
  exa \
  starship \
  just \
  "
RUN set -ex && \
  apk add --no-cache glow
RUN set -ex && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a
# ────────────────────────────────────────────────────────────────────────────────
RUN set -ex && \
  apk add --no-cache ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${IMAGE_SPECIFIC_PACKAGES})
# ─── GO-TPROF ───────────────────────────────────────────────────────────────────
RUN set -ex && \ 
  git clone https://github.com/gokultp/go-tprof.git /tmp/go-tprof && \
  make -C /tmp/go-tprof config && \
  make -C /tmp/go-tprof && \
  rm -rf /tmp/go-tprof  
# ─── VSCODE LIVE SHARE ──────────────────────────────────────────────────────────
RUN set -ex && \
  for i in {1..5}; do wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && break || sleep 15; done && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs && \
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
RUN usermod -aG wheel,root,sudo "${USER}"
USER ${USER}
SHELL ["bash","-c"]
#
# ──────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   U S E R   E N V I R O N M E N T : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
#
# ──────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   G O   E N V : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────
#

RUN set -ex && \
  go env -w "GOPRIVATE=github.com/da-moon" && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"

#
# ──────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   N U   S H E L L : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────
#
WORKDIR /workspace
RUN set -ex && \
  sudo chown "$(id -u):$(id -g)" . -R && \
  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  sudo chown "`id -u`:`id -g`" $(go env GOROOT) -R && \
  sudo chown "$(id -u):$(id -g)" $(go env GOPATH) -R  && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
RUN set -ex && \
  sudo rm -rf \
  /tmp/*
ENTRYPOINT [ "/bin/bash" ]
