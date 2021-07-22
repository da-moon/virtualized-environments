# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/delta
FROM fjolsvin/rust-builder-alpine AS delta-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  if [ "$(apk --print-arch)" == "aarch64" ]; then \
    export CFLAGS="-mno-outline-atomics" ; \
  fi ; \
  build "git-delta" ;
FROM fjolsvin/upx AS compression-layer
COPY --from=delta-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
RUN \
  ( \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null ; \
  apk add --no-cache --upgrade bash bash-completion
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
SHELL [ "/bin/bash", "-c" ]
COPY <<-"EOT" /opt/delta
[pager]
    diff = delta
    log = delta
    reflog = delta
    show = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    features = side-by-side line-numbers decorations
    whitespace-error-style = 22 reverse

[delta "decorations"]
    commit-decoration-style = bold yellow box ul
    file-style = bold yellow ul
    file-decoration-style = none

EOT
ENTRYPOINT [ "/workspace/delta" ]
CMD ["--help"]
