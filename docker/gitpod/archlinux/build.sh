#!/usr/bin/env bash
#-*-mode:sh;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
set -xeuo pipefail
WD="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ESC_WD="$(echo "$WD" | sed 's/\//\\\//g')"
FROM_ROOT="$(readlink -f $(dirname "${BASH_SOURCE[0]}") | sed -e "s/$ESC_WD\///g")"
DOCKER_FILE="${FROM_ROOT}/Dockerfile"
if [ -z ${IMAGE_NAME+x} ] || [ -z ${IMAGE_NAME} ]; then
  IMAGE_NAME="fjolsvin/$(echo ${FROM_ROOT} | sed -e 's/docker\///g' -e 's/\//-/g')"
fi
CACHE_NAME="${IMAGE_NAME}:cache"
echo "$IMAGE_NAME"
echo "${DOCKER_FILE}"
if [ -z "${DOCKER_BUILDKIT+x}" ] || [ -z "${DOCKER_BUILDKIT}" ]; then
  export DOCKER_BUILDKIT=1
fi
pushd "$WD" >/dev/null 2>&1
BUILD="docker"
if [ ! -z "${DOCKER_BUILDKIT+x}" ] && [ "${DOCKER_BUILDKIT}" == "0" ]; then
  BUILD+=" build"
else
  if [[ $(docker buildx version 2>/dev/null) ]]; then
    builder="$(echo "$IMAGE_NAME" | cut -d/ -f2)"
    BUILD+=" buildx build"
    BUILD+=" --platform linux/amd64"
    BUILD+=" --cache-to type=registry,mode=max,ref=${CACHE_NAME}"
    BUILD+=" --push"
    docker buildx use "${builder}" || docker buildx create --use --name "${builder}"
  else
    BUILD+=" build"
    BUILD+=" --pull"
  fi
  BUILD+=" --cache-from type=registry,ref=${CACHE_NAME}"
fi
BUILD+=" --file ${DOCKER_FILE}"
BUILD+=" --tag ${IMAGE_NAME}:latest"
$BUILD $WD
if [[ $(docker buildx version 2>/dev/null) ]]; then
  docker buildx use default
else
  PUSH="docker push"
  PUSH+=" ${IMAGE_NAME}:latest"
  $PUSH
fi
popd >/dev/null 2>&1
