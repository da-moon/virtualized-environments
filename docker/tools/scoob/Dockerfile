# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/scoob
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/rust-builder-alpine AS scoob-builder
ENV OPENSSL_NO_VENDOR="true"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  [ "$(apk --print-arch)" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  [ "$(apk --print-arch)" == "aarch64" ] && unset OPENSSL_NO_VENDOR || true ; \
  build --stable scoob
FROM fjolsvin/upx AS compression-layer
COPY --from=scoob-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --from=compression-layer "/workspace" "/workspace"
RUN /workspace/scoob --version
WORKDIR /userspace
VOLUME /userspace
ENTRYPOINT [ "/workspace/scoob" ]
CMD ["--help"]
