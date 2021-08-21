# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/workspace'--rm -it fjolsvin/upx
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG BASE_PACKAGES="\
  coreutils=8.32-r2 \
  findutils=4.8.0-r1 \
  binutils=2.35.2-r2 \
  file=5.40-r1 \
  "
RUN \
  IFS=' ' read -a packages <<< $BASE_PACKAGES ; \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${packages[@]}" \
  )
ARG UPX_DEPS="\
  curl=7.78.0-r0 \
  jq=1.6-r1 \
  xz=5.2.5-r0 \
  "
RUN \
  IFS=' ' read -a packages <<< $UPX_DEPS ; \
  apk add --no-cache --virtual .deps-upx "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache --virtual .deps-upx "${packages[@]}" \
  )
ARG REPO="upx/upx"
ARG LATEST_RELEASE_ENDPOINT="https://api.github.com/repos/${REPO}/releases/latest"
RUN \
  tag_name="$(curl -sL ${LATEST_RELEASE_ENDPOINT} | jq -r '.tag_name')"; \
  architecture="$(apk --print-arch)"; \
  case "$architecture" in \
    x86_64|amd64) \
      architecture="amd64" \
    ;; \
    aarch64) \
      architecture="arm64" \
    ;; \
    *) \
      echo >&2 "[ WARN ] compression utilities are not available: $architecture"; \
      exit 0 \
    ;; \
  esac ; \
  version="$(echo ${tag_name} | sed 's/v//g')"; \
  download_url="https://github.com/upx/upx/releases/download/${tag_name}/upx-${version}-${architecture}_linux.tar.xz"; \
  rm -rf \
    /tmp/{upx.tar,upx.tar.xz} \
    /usr/local/bin/upx \
  && echo "$download_url" > /tmp/dl \
  && curl -fsSLo /tmp/upx.tar.xz "${download_url}" \
  && xz -d -c /tmp/upx.tar.xz \
  | tar \
    -xOf - upx-${version}-${architecture}_linux/upx > /usr/local/bin/upx
COPY <<-"EOT" /usr/local/bin/compress
#!/usr/bin/env bash
set -euo pipefail
apkArch="$(apk --print-arch)";
case "$apkArch" in
  x86_64|aarch64)
     find . \
    -type f \
    -executable \
    -exec sh -c "file -i '{}' |  grep -q 'charset=binary'" \; \
    -print \
    | xargs \
        -P `nproc` \
        --no-run-if-empty \
        bash -c '
      for pkg do
          strip "$pkg" || true ;
          upx "$pkg" || true ;
      done' bash ;
    ;;
  *)
    echo >&2 "[ WARN ] compression utilities are not available: $apkArch";
    exit 1
  ;;
esac;
find . \
  -mindepth 2 \
  -type f \
  -executable \
  -exec sh -c "file -i '{}' | grep -q 'charset=binary'" \; \
  -print \
  | xargs -P `nproc` -I {} --no-run-if-empty \
    mv "{}" ./
find . -mindepth 1 -maxdepth 1 -type d -exec rm -r "{}" \;
EOT
RUN \
  chmod a+x /usr/local/bin/* \
  && upx --version \
  && apk del .deps-upx \
  && rm -rf \
    /var/cache/apk/* \
    /var/tmp/* \
    /tmp/*
WORKDIR "/workspace"
ENTRYPOINT [ "/bin/bash" ]
CMD ["/usr/local/bin/compress"]
