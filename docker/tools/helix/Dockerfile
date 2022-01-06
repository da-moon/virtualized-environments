# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/helix
FROM fjolsvin/rust-builder-alpine AS helix-builder
ARG BUILD_DIR="/tmp/helix"
RUN \
  git clone \
    --recurse-submodules \
    --shallow-submodules \
    -j"$(nproc)" \
    "https://github.com/helix-editor/helix" "${BUILD_DIR}"
WORKDIR "${BUILD_DIR}"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  rustup run --install stable \
  cargo install \
    --all-features \
    --locked \
    --jobs "$(nproc)" \
    --root "/workspace"  \
    --target "$(apk --print-arch)-unknown-linux-musl" \
    --path "helix-term"
WORKDIR "/workspace"
RUN \
  exe="/workspace/bin/hx" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"

FROM fjolsvin/upx AS compression-layer
COPY --chmod=0755 --from=helix-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash~=5"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --chmod=0755 --from=compression-layer "/workspace" "/workspace"
RUN \
  /workspace/hx --version
ENV COLORTERM="truecolor"
RUN \
  mkdir -p "~/.config/helix/runtime" \
  && wget -qO - https://github.com/helix-editor/helix/archive/refs/heads/master.tar.gz \
  | tar -C "~/.config/helix/runtime" --strip-components=2 -xzf - "helix-master/runtime"
WORKDIR /userspace
VOLUME /userspace
ENTRYPOINT [ "/workspace/hx" ]