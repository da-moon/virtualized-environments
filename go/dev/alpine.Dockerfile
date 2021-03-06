FROM golang:alpine AS go-pkg-builder
ARG STATIC_CHECK="2020.1.6"
ENV STATIC_CHECK $STATIC_CHECK
RUN apk add --no-cache git
# Setting Go Env
RUN go env -w GO111MODULE=on && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
RUN GO111MODULE=on go get -u -v mvdan.cc/gofumpt 
RUN GO111MODULE=on go get -u -v golang.org/x/tools/gopls 
RUN GO111MODULE=off go get -u -v github.com/github-release/github-release 
RUN GO111MODULE=off go get -u -v github.com/mdempsky/gocode 
RUN GO111MODULE=off go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs 
RUN GO111MODULE=off go get -u -v github.com/ramya-rao-a/go-outline 
RUN GO111MODULE=off go get -u -v github.com/acroca/go-symbols 
RUN GO111MODULE=off go get -u -v golang.org/x/tools/cmd/guru 
RUN GO111MODULE=off go get -u -v golang.org/x/tools/cmd/gorename 
RUN GO111MODULE=off go get -u -v github.com/fatih/gomodifytags 
RUN GO111MODULE=off go get -u -v github.com/haya14busa/goplay/cmd/goplay 
RUN GO111MODULE=off go get -u -v github.com/josharian/impl 
RUN GO111MODULE=off go get -u -v github.com/tylerb/gotype-live 
RUN GO111MODULE=off go get -u -v github.com/rogpeppe/godef 
RUN GO111MODULE=off go get -u -v github.com/zmb3/gogetdoc 
RUN GO111MODULE=off go get -u -v golang.org/x/tools/cmd/goimports 
RUN GO111MODULE=off go get -u -v github.com/sqs/goreturns 
RUN GO111MODULE=off go get -u -v winterdrache.de/goformat/goformat 
RUN GO111MODULE=off go get -u -v golang.org/x/lint/golint 
RUN GO111MODULE=off go get -u -v github.com/cweill/gotests/... 
RUN GO111MODULE=off go get -u -v github.com/alecthomas/gometalinter 
RUN GO111MODULE=off go get -u -v honnef.co/go/tools/... 
RUN GO111MODULE=off go get -u -v github.com/mgechev/revive 
RUN GO111MODULE=off go get -u -v github.com/sourcegraph/go-langserver 
RUN GO111MODULE=off go get -u -v github.com/go-delve/delve/cmd/dlv 
RUN GO111MODULE=off go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct 
RUN GO111MODULE=off go get -u -v github.com/godoctor/godoctor 
RUN GO111MODULE=off go get -u -v github.com/cuonglm/gocmt 
RUN GO111MODULE=off go get -u -v github.com/palantir/go-compiles 
RUN GO111MODULE=off go get -u -v github.com/mohae/nocomment/cmd/nocomment 
RUN GO111MODULE=off go get -u -v github.com/eandre/discover/...  
RUN GO111MODULE=off go get -u -v honnef.co/go/tools/cmd/staticcheck && \
    cd $GOPATH/src/honnef.co/go/tools/cmd/staticcheck && \
    git checkout "$STATIC_CHECK" && \
    go get && \
    go install && \
    go get -u -v -d github.com/stamblerre/gocode && \
    go build -o $GOPATH/bin/gocode-gomod github.com/stamblerre/gocode
FROM golang:alpine
ARG USER=code
ENV USER $USER
ENV HOME=/home/${USER}
ENV LANG=en_US.UTF-8
COPY --from=go-pkg-builder /go/bin/ /usr/local/bin/
# Setting Go Env
RUN go env -w GO111MODULE=on && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
WORKDIR ${HOME}
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk add --no-cache --upgrade \
  ca-certificates curl wget aria2 \
  git build-base make openssl-dev musl-dev libffi-dev \
  ncurses ncurses-dev \
  bash bash-completion \
  sudo shadow libcap \ 
  coreutils findutils binutils grep \
  jq yq yq-bash-completion \
  htop bzip2 upx \
  python3-dev py3-pip py3-setuptools \
  yarn nodejs \
  docker lxd \
  bat glow \
  ripgrep ripgrep-bash-completion \
  tokei exa starship
SHELL ["bash","-c"]
RUN printenv
RUN getent group sudo > /dev/null || sudo addgroup sudo
RUN getent group "${USER}" > /dev/null || sudo addgroup "${USER}"
RUN getent passwd "${USER}" > /dev/null || sudo adduser \
    -G sudo \
    -h "/home/${USER}" \
    -s /bin/bash \
    -u 10000 \
    -D \
    "${USER}" "${USER}" && \
    echo "${USER}:${USER}" | chpasswd && \
    sed -i \
      -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
      -e '/%sudo.*NOPASSWD:ALL/d' \
    /etc/sudoers && \
    echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    chown "${USER}:${USER}" /home/${USER} -R
USER ${USER}
ENV PATH=$PATH:~/.local/bin
# checking binaries copied from other stages
RUN go version && \
  echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
# [ NOTE ] => https://forums.docker.com/t/mounting-using-var-run-docker-sock-in-a-container-not-running-as-root/34390
RUN echo 'if [ -e /var/run/docker.sock ]; then sudo chown "$(id -u):$(id -g)" /var/run/docker.sock; fi' >> "/home/${USER}/.bashrc"
