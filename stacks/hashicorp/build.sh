#!/usr/bin/env bash
set -xeuo pipefail
IMAGE_NAME="fjolsvin/hashicorp"
CACHE_NAME="fjolsvin/cache:hashicorp"
# --------------------------------------------------------------------------------
WD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
builder="$(echo "$IMAGE_NAME" | cut -d/ -f2)"
# --------------------------------------------------------------------------------
docker buildx use "${builder}" || docker buildx create --use --name "${builder}"
BUILD="docker buildx build"
BUILD+=" -f alpine.Dockerfile"
BUILD+=" --platform linux/amd64,linux/arm64"
BUILD+=" --cache-from type=registry,ref=${CACHE_NAME}"
BUILD+=" --cache-to type=registry,mode=max,ref=${CACHE_NAME}"
BUILD+=" --tag ${IMAGE_NAME}:latest"
BUILD+=" --progress=plain"
BUILD+=" --push"
$BUILD $WD
docker buildx use default