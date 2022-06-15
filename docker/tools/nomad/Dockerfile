# syntax = docker/dockerfile:labs
# vim: filetype=dockerfile softtabstop=2 tabstop=2 shiftwidth=2 fileencoding=utf-8 expandtab
# ─── BUILD STAGE ────────────────────────────────────────────────────────────────
FROM golang:alpine AS build-stage
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN \
--mount=type=cache,sharing=shared,mode=0777,target="/var/cache/apk" \
apk add \
  "build-base" \
  "bash" \
  "linux-headers" \
  "g++" \
  "gcc" \
  "git" \
  "yarn" \
  "npm" \
  "make" \
  "upx" \
  "binutils" \
  "musl-dev" \
#  ╭──────────────────────────────────────────────────────────╮
#  │          preparing nobody user for final layer           │
#  ╰──────────────────────────────────────────────────────────╯
&& echo "nobody:x:65534:65534:Nobody:/:" > "/etc_passwd"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
#  ╭──────────────────────────────────────────────────────────╮
#  │              cloning latest stable release               │
#  ╰──────────────────────────────────────────────────────────╯
ARG BRANCH="main"
RUN \
git clone \
  --depth 1 \
  --branch "${BRANCH}" \
  "https://github.com/hashicorp/nomad.git" "/workspace" \
#  ────────────────────────────────────────────────────────────
&& git -C "/workspace" fetch --all --tags \
#  ╭──────────────────────────────────────────────────────────╮
#  │               checkout the latest release                │
#  ╰──────────────────────────────────────────────────────────╯
&& git -C "/workspace" checkout "$(git -C "/workspace" describe --tags $(git -C "/workspace" rev-list --tags --max-count=1))"
#  ╭──────────────────────────────────────────────────────────╮
#  │                       build binary                       │
#  ╰──────────────────────────────────────────────────────────╯
WORKDIR "/workspace"
ARG BUILD_TAGS="nonvidia release ui"
# hadolint ignore=SC2239
RUN \
--mount=type=cache,target="/workspace/node_modules" \
--mount=type=cache,target="/root/.cache/node" \
--mount=type=cache,target="/root/.cache/node-build" \
--mount=type=cache,target="/root/.cache/go-build" \
--mount=type=cache,target="/go/pkg/mod" \
--mount=type=tmpfs,target="/go/src/" \
make -j"$(nproc)" bootstrap ember-dist \
&& make static-assets \
&& CGO_ENABLED=1 \
go build \
  -x \
  -o "bin/nomad" \
  -tags "${BUILD_TAGS}" \
  -ldflags " \
    -X 'github.com/hashicorp/nomad/version.GitCommit=$(git rev-parse HEAD)' \
    -linkmode 'external' \
    -extldflags '-static' \
  " . ; \
#  ╭──────────────────────────────────────────────────────────╮
#  │        ensuring binary has been statically linked        │
#  ╰──────────────────────────────────────────────────────────╯
if [[ ! -z $(readelf -d "/workspace/bin/nomad" | grep "NEED") ]]; then \
  if ldd "/workspace/bin/nomad" > /dev/null 2>&1; then \
    echo >&2 "*** '/workspace/bin/nomad" ; \
    exit 1 ; \
  fi \
fi ;
#  ╭──────────────────────────────────────────────────────────╮
#  │                       compressing                        │
#  ╰──────────────────────────────────────────────────────────╯
# hadolint ignore=SC2239
RUN \
strip "bin/nomad" \
&& upx "bin/nomad"
#  ╭──────────────────────────────────────────────────────────╮
#  │                       final layer                        │
#  ╰──────────────────────────────────────────────────────────╯
FROM "scratch"
COPY --from=build-stage "/etc/ssl/certs/ca-certificates.crt" "/etc/ssl/certs/"
COPY --from=build-stage "/etc_passwd" "/etc/passwd"
COPY --chmod=0755 --chown=65534:0 --from=build-stage "/workspace/bin/nomad" /entrypoint
#  ────────────────────────────────────────────────────────────
USER nobody
ENTRYPOINT ["/entrypoint"]
CMD [ "version" ]
