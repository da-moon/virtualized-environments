# syntax = docker/dockerfile-upstream:master-labs
FROM fjolsvin/rust-builder-alpine AS jsonfmt-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  build "jsonfmt"
FROM fjolsvin/upx AS compression-layer
COPY --from=jsonfmt-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
RUN apk upgrade --no-cache -U -a && apk add --no-cache --upgrade gcc
ENTRYPOINT [ "/workspace/jsonfmt" ]