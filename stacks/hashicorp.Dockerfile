FROM golang:alpine as builder
USER root
ENV TERM xterm 
RUN go env -w GO111MODULE=on && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache git upx binutils bash && \
    strip --version && \
    upx --version
SHELL ["bash", "-c"]
WORKDIR "/go/src/github.com/hashicorp"
RUN go env -w GO111MODULE=on && \
  git clone \
  --depth 1 \
  --branch "master" \
  "https://github.com/hashicorp/vault.git" \
  "/go/src/github.com/hashicorp/vault" && \
  cd "/go/src/github.com/hashicorp/vault" && \
  go build -o "/go/bin/vault" && \
  strip "/go/bin/vault" && \
  upx "/go/bin/vault"
RUN go env -w GO111MODULE=on && \
  git clone \
  --depth 1 \
  --branch "master" \
  "https://github.com/hashicorp/consul.git" \
  "/go/src/github.com/hashicorp/consul" && \
  cd "/go/src/github.com/hashicorp/consul" && \
  go build -o "/go/bin/consul" && \
  strip "/go/bin/consul" && \
  upx "/go/bin/consul"
RUN go env -w GO111MODULE=on && \
  git clone \
  --depth 1 \
  --branch "master" \
  "https://github.com/hashicorp/consul-template.git" \
  "/go/src/github.com/hashicorp/consul-template" && \
  cd "/go/src/github.com/hashicorp/consul-template" && \
  go build -o "/go/bin/consul-template" && \
  strip "/go/bin/consul-template" && \
  upx "/go/bin/consul-template"
RUN go env -w GO111MODULE=off && \
  git clone \
    --depth 1 \
    --branch "master" \
    "https://github.com/hashicorp/consul-replicate.git" && \
  cd "/go/src/github.com/hashicorp/consul-replicate" && \
  go build -o "/go/bin/consul-replicate" && \
    strip "/go/bin/consul-replicate" && \
    upx "/go/bin/consul-replicate"
RUN go env -w GO111MODULE=on && \
  git clone \
  --depth 1 \
  --branch "master" \
  "https://github.com/hashicorp/terraform.git" \
  "/go/src/github.com/hashicorp/terraform" && \
  cd "/go/src/github.com/hashicorp/terraform" && \
  go build -o "/go/bin/terraform" && \
  strip "/go/bin/terraform" && \
  upx "/go/bin/terraform"
FROM alpine
COPY --from=builder /go/bin/vault /usr/local/bin/vault
COPY --from=builder /go/bin/consul /usr/local/bin/consul
COPY --from=builder /go/bin/consul-template /usr/local/bin/consul-template
COPY --from=builder /go/bin/consul-replicate /usr/local/bin/consul-replicate
COPY --from=builder /go/bin/terraform /usr/local/bin/terraform
ARG USER=code
ENV USER $USER
USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade --no-cache && \
    apk add --no-cache curl coreutils findutils wget jq git ncurses bash sudo shadow
SHELL ["bash", "-c"]
# make a user for "${USER}"
WORKDIR /home/"${USER}"
RUN getent group "${USER}" > /dev/null || addgroup "${USER}" > /dev/null 2>&1 || true
RUN getent passwd "${USER}" > /dev/null || adduser \
  -G wheel \
  -h "/home/${USER}" \
  -s /bin/bash \
  -u 10000 \
  -D \
  "${USER}" "${USER}" && \
  echo "${USER}":"${USER}" | chpasswd > /dev/null 2>&1 && \
  sed -i -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' \
      /etc/sudoers && \
  chown "${USER}":"${USER}" /home/"${USER}" -R && \
  usermod -aG wheel "${USER}"


USER "${USER}"
ENV HOME /home/"${USER}"
WORKDIR "${HOME}"
# [NOTE] => confirming successful installation
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '";} >> .bashrc && \
    vault --version && \
    terraform --version && \
    consul --version && \
    consul-template --version && \
    consul-replicate --version
