# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/tojson
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/rust-builder-alpine AS tojson-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  build --stable tojson
FROM fjolsvin/upx AS compression-layer
COPY --from=tojson-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --from=compression-layer "/workspace" "/workspace"
RUN /workspace/tojson --version
WORKDIR /userspace
VOLUME /userspace
ENTRYPOINT [ "/workspace/tojson" ]
CMD ["--help"]
