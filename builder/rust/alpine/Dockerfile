# syntax = docker/dockerfile-upstream:master-labs
FROM rust:alpine
COPY <<-"EOT" /usr/local/bin/build
#!/usr/bin/env bash
set -euxo pipefail
if [ $# = 0 ]; then
  echo >&2 "*** No crates specified"
  exit 1
fi
# [ NOTE ] => turn a space delinated string into an array
IFS=' ' read -a CRATES <<< $@ ;
apkArch="$(apk --print-arch)";
for crate in "${CRATES[@]}"; do 
  echo >&2 "[ INFO ] building: $crate";
  case "$apkArch" in
    x86_64) 
      cargo install --root "/workspace" -j `nproc` "${crate}"
      ;;
    aarch64) 
      cargo install --root "/workspace" -j `nproc` "${crate}" || true
      ;;
    *) 
      echo >&2 "[ WARN ] unsupported architecture: $apkArch";
      continue
    ;;
  esac;
  mv -f /workspace/bin/* "/workspace/";
  rm -rf "/workspace/bin" ;
done ;
EOT
WORKDIR "/workspace"
RUN \
  set -ex \
  && apk upgrade -U -a \
  && apk add build-base make git bash ncurses \
  && chmod +x /usr/local/bin/*
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  set -ex \
  # [ NOTE ] hacky way to update index
  && cargo search hello-world
SHELL ["bash","-c"]
ENTRYPOINT [ "bash" ]
