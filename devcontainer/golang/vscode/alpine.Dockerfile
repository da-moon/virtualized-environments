# syntax = docker/dockerfile-upstream:master-labs
FROM fjolsvin/golang-base-alpine
USER root
# ────────────────────────────────────────────────────────────────────────────────
ARG IMAGE_SPECIFIC_PACKAGES="\
  "
RUN set -ex && \
  apk upgrade --no-cache -U -a \
  && apk add --no-cache ${IMAGE_SPECIFIC_PACKAGES} || \
  (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && \
  apk add --no-cache ${IMAGE_SPECIFIC_PACKAGES})
RUN set -ex && \ 
  git clone https://github.com/gokultp/go-tprof.git /tmp/go-tprof && \
  make -C /tmp/go-tprof config || true ; \
  make -C /tmp/go-tprof || true ; \
  rm -rf /tmp/go-tprof  
# ─── VSCODE LIVE SHARE ──────────────────────────────────────────────────────────
RUN set -ex && \
  for i in {1..5}; do wget -O /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script && break || sleep 15; done && \
  sed -i 's/libssl1.0/libssl1.1/g' /tmp/vsls-reqs ; \
  bash /tmp/vsls-reqs || true ; \
  rm /tmp/vsls-reqs
USER ${USER}
RUN set -ex && \
  go env -w "GOPRIVATE=github.com/da-moon" && \
  go env -w "GO111MODULE=on" && \
  go env -w "CGO_ENABLED=0" && \
  go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'"
WORKDIR "${WORKDIR}"
RUN set -ex && \
  find ${WORKDIR} \
  -not -group `id -g` \
  -not -user `id -u` \
  -print0 \
  | sudo xargs \
  --no-run-if-empty \
  -0  \
  -P 0 \
  chown --no-dereference "`id -u`:`id -g`" \
  && find ${HOME} \
  -not -group `id -g` \
  -not -user `id -u` \
  -print0 \
  | sudo xargs \
  --no-run-if-empty \
  -0  \
  -P 0 \
  chown --no-dereference "`id -u`:`id -g`" \
  && find $(go env GOROOT) \
  -not -group `id -g` \
  -not -user `id -u` \
  -print0 \
  | sudo xargs \
  --no-run-if-empty \
  -0  \
  -P 0 \
  chown --no-dereference "`id -u`:`id -g`" \
  && find $(go env GOPATH) \
  -not -group `id -g` \
  -not -user `id -u` \
  -print0 \
  | sudo xargs \
  --no-run-if-empty \
  -0  \
  -P 0 \
  chown --no-dereference "`id -u`:`id -g`" \
  && mkdir -p ~/.vscode-server \
  && mkdir -p ~/.vscode-server-insiders
VOLUME "${HOME}/.vscode-server"
VOLUME "${HOME}/.vscode-server-insiders"
RUN set -ex && \
  sudo rm -rf \
  /tmp/*
ENTRYPOINT [ "/bin/bash" ]
