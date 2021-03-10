# syntax = docker/dockerfile:1.0-experimental
# eg. build command
# docker build -t fjolsvin/consul-replicate --file consul-replicate.Dockerfile .
FROM golang:alpine AS builder
ENV LANG=en_US.UTF-8
RUN go env -w GO111MODULE=on && \
 go env -w "CGO_ENABLED=0" && \
 go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN apk upgrade -U -a && \
    apk add build-base make git bash ncurses upx \
    ca-certificates python2 wget  \
    autoconf findutils pkgconf libtool g++ automake linux-headers git
WORKDIR "/go/src/k8s.io"
RUN git clone \
      --depth 1 \
      --branch "master" \
      "https://github.com/kubernetes/minikube.git" \
      "/go/src/k8s.io/minikube"
WORKDIR "/go/src/k8s.io/minikube"
RUN make && \
    strip "out/minikube" && \
    upx "out/minikube" && \
    mv out/minikube /go/bin/minikube
FROM alpine
COPY --from=builder /go/bin/minikube /usr/local/bin/minikube
ARG USER=operator
ENV USER $USER
USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk upgrade --no-cache -U -a && \
    apk add --no-cache curl coreutils \
    findutils wget jq git ncurses bash sudo \
    shadow openssl conntrack-tools docker kubeadm
SHELL ["bash", "-c"]

WORKDIR "/home/${USER}"
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
  usermod -aG wheel,docker "${USER}"
RUN wget \
  -qO /usr/local/bin/kubectl \
  "https://storage.googleapis.com/kubernetes-release/release/$(curl -fSsL https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
  sudo chmod +x /usr/local/bin/kubectl
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
USER "${USER}"
ENV HOME /home/"${USER}"
ENV MINIKUBE_WANTUPDATENOTIFICATION="false"
ENV MINIKUBE_WANTREPORTERRORPROMPT="false" 
ENV MINIKUBE_HOME="$HOME" 
ENV CHANGE_MINIKUBE_NONE_USER="true"
WORKDIR "/workspace"

# [NOTE] => confirming successful installation
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '";} >> ~/.bashrc && \
    kubectl version --client=true && \
    minikube version && \
    helm version
RUN echo 'if [ -e /var/run/docker.sock ]; then sudo chown "$(id -u):docker" /var/run/docker.sock; fi' >> "/${HOME}/.bashrc"

# RUN sudo service docker stop || true
# RUN minikube start --vm-driver docker
VOLUME ${HOME}/.minikube
EXPOSE 8443
COPY fixtures/minikube/docker-entrypoint.sh /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/docker-entrypoint.sh
# ENTRYPOINT ["docker-entrypoint.sh"]
# CMD ["minikube"]

