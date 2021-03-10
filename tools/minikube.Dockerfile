# syntax = docker/dockerfile:1.0-experimental
# eg. build command
# docker build -t fjolsvin/consul-replicate --file consul-replicate.Dockerfile .
FROM golang:alpine AS builder
ARG KUBE_VERSION=1.7.5
ARG MINIKUBE_VERSION=0.23.0
ENV KUBERNETES_VERSION="${KUBE_VERSION}" 
ENV LANG=en_US.UTF-8
RUN apk add --no-cache git
RUN go env -w GO111MODULE=off && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add build-base make git bash ncurses upx \
    ca-certificates python2 wget  \
    autoconf findutils pkgconf libtool g++ automake linux-headers git

WORKDIR "/go/src/k8s.io"
RUN git clone \
      --depth 1 \
      --branch "v${MINIKUBE_VERSION}" \
      "https://github.com/kubernetes/minikube.git" \
      "/go/src/k8s.io/minikube"
WORKDIR "/go/src/k8s.io/minikube"
RUN make && \
    strip "out/minikube" && \
    upx "out/minikube" && \
    mv out/minikube /go/bin/minikube
FROM alpine
COPY --from=builder /go/bin/minikube /usr/local/bin/minikube
COPY tools/fixtures/minikube/docker-entrypoint.sh /usr/local/bin/
ARG USER=operator
ENV USER $USER
USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade --no-cache -U -a && \
    apk add --no-cache curl coreutils \
    findutils wget jq git ncurses bash sudo shadow
SHELL ["bash", "-c"]

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
ENV MINIKUBE_WANTUPDATENOTIFICATION="false"
ENV MINIKUBE_WANTREPORTERRORPROMPT="false" 
ENV MINIKUBE_HOME="$HOME" 
ENV CHANGE_MINIKUBE_NONE_USER="true"
WORKDIR "/workspace"
RUN sudo wget \
  -O "/usr/local/bin/kubectl" \
  "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl"  && \
  sudo chmod +x /usr/local/bin/kubectl
RUN sudo chmod +x /usr/local/bin/docker-entrypoint.sh

# [NOTE] => confirming successful installation
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '";} >> ~/.bashrc && \
    kubectl --version
RUN minikube start --vm-driver none --kubernetes-version v${KUBERNETES_VERSION} --memory 1024 --disk-size 4g 
RUN sudo rc-update add docker boot && \
    echo "export DOCKER_HOST='tcp://127.0.0.1:2375'" | sudo tee -a "/etc/profile" > /dev/null
VOLUME ${HOME}/.minikube
EXPOSE 2375 8443
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["minikube"]

