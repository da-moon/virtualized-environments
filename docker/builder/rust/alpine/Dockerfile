# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
# ─── USAGE ──────────────────────────────────────────────────────────────────────
# docker run --mount type=bind,source="$PWD",target='/workspace' --rm -it fjolsvin/rust-builder-alpine
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --update --no-cache "bash=5.1.8-r0"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG BASE_PACKAGES="\
  build-base=0.5-r2 \
  ca-certificates=20191127-r5 \
  cmake=3.21.1-r0 \
  coreutils=8.32-r2 \
  curl=7.78.0-r0 \
  findutils=4.8.0-r1 \
  gcc=10.3.1_git20210625-r0 \
  git=2.32.0-r2 \
  make=4.3-r0 \
  musl-dev=1.2.2-r5 \
  ncurses-static=6.2_p20210807-r0 \
  openssl-dev=1.1.1k-r1 \
  openssl-libs-static=1.1.1k-r1 \
  perl=5.34.0-r0 \
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
  && apk add --update --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --update --no-cache "${packages[@]}" \
  )
# ────────────────────────────────────────────────────────────────────────────────
ARG RUST_VERSION="1.54.0"
ARG RUSTUP_URL="https://sh.rustup.rs"
ENV RUSTUP_HOME="/usr/local/rustup"
ENV CARGO_HOME="/usr/local/cargo"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ENV RUST_VERSION "${RUST_VERSION}"
# && rustup toolchain install "nightly-$(apk --print-arch)-unknown-linux-musl" \
# && rustup default "stable-$(apk --print-arch)-unknown-linux-musl" \
# && rustup component add rust-src rustfmt rls clippy \
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  case "$(apk --print-arch)" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  curl --proto '=https' --tlsv1.2 -fSsl "${RUSTUP_URL}" | bash -s -- -y \
  --no-modify-path \
  --profile minimal \
  --default-toolchain "${RUST_VERSION}" \
  --default-host "$(apk --print-arch)-unknown-linux-musl" \
  && chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}" \
  && rustup --version \
  && cargo --version \
  && rustc --version \
  && cargo search hello-world
# ────────────────────────────────────────────────────────────────────────────────
COPY <<-"EOT" /usr/local/bin/build
#!/usr/bin/env bash
#-*-mode:bash;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=sh tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
set -eu
function help() {
  echo
  echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
  echo
  echo
  echo -e "[Synopsis]:\tstatically builds rust binaries"
  echo "Flags:"
  echo
  echo -e "  --git\t\tbuild from git against stable toolchain"
  echo -e "  --git-nightly\t\tbuild from git against nightly toolchain"
  echo -e "  --stable\t\tbuilds crate against stable toolchain"
  echo -e "  --nightly\t\tbuilds crate against nightly toolchain"
  echo
  echo
}
function main() {
  if [ $# = 0 ]; then
    echo >&2 "*** No crates specified"
    exit 1
  fi
  local git=()
  local git_nightly=()
  local stable=()
  local nightly=()
  while [[ $# -gt 0 ]]; do
    local key="$1"
    case "$key" in
      --git)
        shift
        git+=("${1}")
        ;;
      --git-nightly)
        shift
        git_nightly+=("${1}")
        ;;
      --stable)
        shift
        stable+=("${1}")
        ;;
      --nightly)
        shift
        nightly+=("${1}")
        ;;
      *)
        help
        exit
        ;;
    esac
    shift
  done
  apkArch="$(apk --print-arch)"
  case "$apkArch" in
    x86_64 | aarch64)
      true
      ;;
    *)
      echo >&2 "[ WARN ] unsupported architecture: $apkArch"
      exit 1
      ;;
  esac
  failed=()
  build="cargo"
  build+=" install"
  if [ -z ${FEATURES+x} ]  ; then
    build+=" --all-features"
  fi
  if [ ! -z ${FEATURES+x} ] && [ -z ${FEATURES} ]; then
    build+=' --no-default-features'
  fi
  if [ ! -z ${FEATURES+x} ] &&  [ ! -z ${FEATURES} ]; then
    build+=" --features ${FEATURES}"
  fi
  build+=" --locked"
  build+=" --jobs $(nproc)"
  build+=" --root /workspace"
  build+=" --target ${apkArch}-unknown-linux-musl"
  if [ ${#git[@]} -ne 0 ]; then
    for crate in "${git[@]}"; do
      tag="$(echo "${crate}" | awk 'BEGIN{FS=OFS="=";}{print $2}')"
      crate="$(echo "${crate}" | awk 'BEGIN{FS=OFS="=";}{print $1}')"
      cmd="rustup run --install stable ${build} --git ${crate}"
      [ -n "${tag}" ] && cmd="${cmd} --tag ${tag}" ;
      $cmd ||
        (
          failed+=("${crate}")
          true
        )
    done
  fi
  if [ ${#git_nightly[@]} -ne 0 ]; then
    for crate in "${git_nightly[@]}"; do
      tag="$(echo "${crate}" | awk 'BEGIN{FS=OFS="=";}{print $2}')"
      crate="$(echo "${crate}" | awk 'BEGIN{FS=OFS="=";}{print $1}')"
      cmd="rustup run --install nightly ${build} --git ${crate}"
      [ -n "${tag}" ] && cmd="${cmd} --tag ${tag}" ;
      $cmd ||
        (
          failed+=("${crate}")
          true
        )
    done
  fi
  if [ ${#stable[@]} -ne 0 ]; then
    for crate in "${stable[@]}"; do
      rustup run --install stable ${build} ${crate} ||
        (
          failed+=("${crate}")
          true
        )
    done
  fi
  if [ ${#nightly[@]} -ne 0 ]; then
    for crate in "${nightly[@]}"; do
      rustup run --install nightly ${build} ${crate} ||
        (
          failed+=("${crate}")
          true
        )
    done
  fi
  if [ ${#failed[@]} -ne 0 ]; then
    echo >&2 "*** failed packages : ${failed[@]}"
    exit 1
  fi
  executables=($(find /workspace/bin \
    -type f \
    -executable \
    -exec sh -c "file -i '{}' | grep -q 'charset=binary'" \; \
    -print))
  [ ${#executables[@]} -eq 0 ] \
  && (
    echo '*** could not detect any binaries'
    exit 1 ) \
  || true ;
  for exe in "${executables[@]}"; do
    if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then
      if ldd ${exe} > /dev/null 2>&1; then
        echo >&2 "*** '${exe}' was not linked statically";
        exit 1;
      fi
    else
      true
    fi
    mv "$exe" "/workspace/$(basename $exe)"
  done
  rm -rf "/workspace/bin"
  exit
}
if [ -z "${BASH_SOURCE+x}" ]; then
  main "${@}"
  exit $?
else
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
    exit $?
  fi
fi
EOT
# ────────────────────────────────────────────────────────────────────────────────
COPY <<-"EOT" /usr/local/cargo/config
[target.x86_64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.armv7-unknown-linux-musleabihf]
  linker = "arm-linux-gnueabihf-gcc"
EOT
# ────────────────────────────────────────────────────────────────────────────────
RUN \
  chmod +x /usr/local/bin/* ;
ENV RUSTFLAGS="-C target-cpu=native"
ENV OPENSSL_STATIC=yes
ENV OPENSSL_LIB_DIR="/usr/lib"
ENV OPENSSL_INCLUDE_DIR="/usr/include"
WORKDIR "/workspace"
ENTRYPOINT [ "bash","/usr/local/bin/build"]
