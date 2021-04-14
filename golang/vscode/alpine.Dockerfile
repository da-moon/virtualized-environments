# ─── EXAMPLE BUILD COMMAND ──────────────────────────────────────────────────────
# docker build --file alpine.Dockerfile --build-arg USER=code --build-arg UID=1000 --tag fjolsvin/vscode-golang-alpine:latest .
# ────────────────────────────────────────────────────────────────────────────────

FROM golang:alpine
ENV TERM=xterm
USER root
# [ NOTE ] => base essential packages
ARG BASE_PACKAGES="\
  curl \
  perl \
  wget \
  tree \
  util-linux \
  git \
  ca-certificates \
  ncurses \
  sudo \
  bash \
  bash-completion \
  shadow \
  libcap \
  coreutils \
  findutils \
  binutils \
  gnupg \
  grep \
  gawk \
  "

# ────────────────────────────────────────────────────────────────────────────────
ARG IMAGE_SPECIFIC_PACKAGES="\
  aria2 rng-tools-extra \
  build-base make openssl-dev libffi-dev upx \
  ncurses ncurses-dev \
  jq yq yj yq-bash-completion \
  htop bzip2 \
  yarn nodejs \
  docker docker-compose \
  ripgrep ripgrep-bash-completion \
  bat tokei exa starship just neofetch hyperfine asciinema \
  "
RUN set -ex && \
    apk add --no-cache glow
RUN set -ex && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade --no-cache -U -a
RUN set -ex && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${BASE_PACKAGES} ${IMAGE_SPECIFIC_PACKAGES})
SHELL ["bash","-c"]
ARG GOLANGCI_LINT_VERSION=v1.35.2
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
RUN set -ex && \
  wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && \
  chmod +x /tmp/vsls-reqs && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs && \
  bash /tmp/vsls-reqs && \
  rm /tmp/vsls-reqs
RUN set -ex && \
  curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
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
  getent group sudo > /dev/null || addgroup sudo > /dev/null 2>&1
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
RUN sed -i \
  -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
  -e '/%sudo.*NOPASSWD:ALL/d' \
  /etc/sudoers && \
  echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN usermod -aG wheel,root,sudo,docker "${USER}"
USER ${USER}
SHELL ["bash","-c"]
COPY --from=fjolsvin/golang-base:latest /go/bin /go/bin
ENV SHELL="/bin/bash"
#
# ──────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R I N G   U S E R   E N V I R O N M E N T : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────
#
ENV HOME="/home/${USER}"
RUN set -ex && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "GOPRIVATE=github.com/da-moon" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"  && \
  sudo chown "$(id -u):$(id -g)" "${HOME}" -R && \
  sudo chown "$(id -u):$(id -g)" /go -R && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
RUN set -ex && \
  sudo rm -rf \
  /tmp/*
WORKDIR /workspace
RUN set -ex && \
  sudo chown "$(id -u):$(id -g)" . -R
ENTRYPOINT [ "/bin/bash" ]
