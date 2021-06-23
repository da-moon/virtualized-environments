# syntax = docker/dockerfile-upstream:master-labs
FROM alpine:edge
COPY <<-"EOT" /usr/local/bin/compress
#!/usr/bin/env bash
set -euxo pipefail
# [ NOTE ] => turn a space delinated string into an array
IFS=' ' read -a DIRS <<< $@ ;
apkArch="$(apk --print-arch)";
# [ NOTE ] installing dependancies
case "$apkArch" in
  x86_64) 
      find . -type f -print0 \
      | xargs \
        -0 \
        -P `nproc` \
        --no-run-if-empty \
        bash -c '
      for pkg do
          strip "$pkg" || true ;
          upx "$pkg" || true ;
      done' bash
    ;;
  *) 
    echo >&2 "[ WARN ] compression utilities are not available: $apkArch";
    # [ NOTE ] graceful exit so that aarch64 builds don't break
    exit 0
  ;;
esac;
EOT
WORKDIR "/workspace"
RUN \
  set -ex \
  && apk upgrade -U -a \
  && apk add --no-cache bash \
  && chmod +x /usr/local/bin/* ;
SHELL ["bash","-c"]
RUN \
  set -ex ; \
  apkArch="$(apk --print-arch)"; \
  case "$apkArch" in \
    x86_64) \
      apk add --no-cache binutils findutils upx \
    ;; \
    *) \
      echo >&2 "[ WARN ] compression utilities are not available: $apkArch"; \
      exit 0 \
    ;; \
  esac
ENTRYPOINT [ "bash" ]
