# syntax = docker/dockerfile-upstream:master-labs
FROM fjolsvin/rust-builder-alpine AS petname-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  build "petname"
FROM fjolsvin/upx AS compression-layer
COPY --from=petname-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
ENTRYPOINT [ "/workspace/petname" ]