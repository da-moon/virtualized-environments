# syntax = docker/dockerfile-upstream:master-labs
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/userspace' --rm -it fjolsvin/tokei
FROM fjolsvin/rust-builder-alpine AS tokei-builder
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  build "tokei" ;
FROM fjolsvin/upx AS compression-layer
COPY --from=tokei-builder "/workspace" "/workspace"
RUN \
  compress ;
FROM alpine:edge
RUN \
  ( \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null ; \
  && apk add --no-cache --upgrade bash bash-completion
WORKDIR /userspace
VOLUME /userspace
COPY --from=compression-layer "/workspace" "/workspace"
SHELL [ "/bin/bash", "-c" ]
ENTRYPOINT [ "/workspace/tokei" ]
CMD ["--help"]
