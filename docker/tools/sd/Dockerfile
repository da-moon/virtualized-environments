# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/sd
# ────────────────────────────────────────────────────────────────────────────────
FROM fjolsvin/rust-builder-alpine AS sd-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  build --stable sd
FROM fjolsvin/upx AS compression-layer
COPY --chmod=0755 --from=sd-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --chmod=0755 --from=compression-layer "/workspace" "/workspace"
RUN /workspace/sd --version
WORKDIR /userspace
VOLUME /userspace
ENTRYPOINT [ "/workspace/sd" ]
CMD ["--help"]
