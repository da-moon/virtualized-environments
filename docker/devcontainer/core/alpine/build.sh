#!/usr/bin/env bash
#-*-mode:sh;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
set -euxo pipefail
if [ -z ${IMAGE_NAME+x} ] || [ -z ${IMAGE_NAME+x} ]; then
  IMAGE_NAME="fjolsvin/base-alpine"
fi
# ────────────────────────────────────────────────────────────────────────────────
WD="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ESC_WD="$(echo "$WD" | sed 's/\//\\\//g')"
DOCKER_FILE="$(dirname "${BASH_SOURCE[0]}")/Dockerfile"
DOCKER_FILE=$(echo "${DOCKER_FILE}" | sed -e "s/$ESC_WD\///g")
CACHE_NAME="${IMAGE_NAME}:cache"
export DOCKER_BUILDKIT=1
BUILD="docker"
if [[ $(docker buildx version 2>/dev/null) ]]; then
  builder="$(echo "$IMAGE_NAME" | cut -d/ -f2)"
  docker buildx use "${builder}" || docker buildx create --use --name "${builder}"
  # ────────────────────────────────────────────────────────────────────────────────
  BUILD+=" buildx build"
  BUILD+=" --platform linux/amd64,linux/arm64"
  BUILD+=" --cache-to type=registry,mode=max,ref=${CACHE_NAME}"
  BUILD+=" --push"
else
  BUILD+=" build"
  # BUILD+=" --pull"
fi
BUILD+=" --file $DOCKER_FILE"
BUILD+=" --tag ${IMAGE_NAME}:latest"
BUILD+=" --cache-from type=registry,ref=${CACHE_NAME}"
# BUILD+=" --progress=plain"
BUILD+=" --progress=auto"
BUILD+=" --build-arg USER=devel"
BUILD+=" --build-arg UID=1000"
# ────────────────────────────────────────────────────────────────────────────────
$BUILD $WD
# ────────────────────────────────────────────────────────────────────────────────
# if [[ $(docker buildx version 2>/dev/null) ]]; then
# docker buildx use default
# else
# PUSH="docker push"
# PUSH+=" ${IMAGE_NAME}:latest"
# $PUSH
# fi
