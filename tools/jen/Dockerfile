# syntax = docker/dockerfile-upstream:master-labs
FROM fjolsvin/rust-builder-alpine AS jen-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  build "jen"
FROM fjolsvin/upx AS compression-layer
COPY --from=jen-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
ENTRYPOINT [ "/workspace/jen" ]