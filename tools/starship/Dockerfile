# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/starship
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/rust-builder-alpine AS starship-builder
ENV OPENSSL_NO_VENDOR="true"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  if [ "$(apk --print-arch)" == "aarch64" ]; then \
    export CFLAGS="-mno-outline-atomics" ; \
  fi ; \
  export RUSTFLAGS="-C target-cpu=native" ; \
  build "starship"
FROM fjolsvin/upx AS compression-layer
COPY --from=starship-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
ENTRYPOINT [ "/workspace/starship" ]
