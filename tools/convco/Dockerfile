# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/convco
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/rust-builder-alpine AS clog-builder
# [ NOTE ] => for fixing linked issues with atomics on
# aarch64
# https://github.com/rust-lang/git2-rs/issues/706#issuecomment-836092166
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  [ "$(apk --print-arch)" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  build --stable "convco"
FROM fjolsvin/upx AS compression-layer
COPY --from=clog-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories \
  && apk add --no-cache --upgrade openssl-dev git vim gcc
WORKDIR /userspace
VOLUME /userspace
ENV EDITOR vim
ENV VISUAL vim
COPY --from=compression-layer "/workspace" "/workspace"
ENTRYPOINT [ "/workspace/convco" ]
CMD ["--help"]
