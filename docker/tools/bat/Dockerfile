# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/bat
FROM fjolsvin/rust-builder-alpine AS bat-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  [ "$(apk --print-arch)" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  build --git "https://github.com/sharkdp/bat.git"
FROM fjolsvin/upx AS compression-layer
COPY --from=bat-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --update --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --from=compression-layer "/workspace" "/workspace"
RUN /workspace/bat --version
WORKDIR /userspace
VOLUME /userspace
ENTRYPOINT [ "/workspace/bat" ]
CMD ["--help"]
