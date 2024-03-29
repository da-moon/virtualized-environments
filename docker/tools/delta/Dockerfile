# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/delta
FROM fjolsvin/rust-builder-alpine AS delta-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  [ "$(apk --print-arch)" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  build --stable "git-delta"
FROM fjolsvin/upx AS compression-layer
COPY --chmod=0755 --from=delta-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --chmod=0755 --from=compression-layer "/workspace" "/workspace"
RUN /workspace/delta --version
WORKDIR /userspace
VOLUME /userspace
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
