#!/usr/bin/env bash
set -xeuo pipefail
IMAGE_NAME="fjolsvin/golang-base-alpine"
# --------------------------------------------------------------------------------
WD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
builder="$(echo "$IMAGE_NAME" | cut -d/ -f2)"
# --------------------------------------------------------------------------------
docker buildx use "${builder}" || docker buildx create --use --name "${builder}"
BUILD="docker buildx build"
BUILD+=" -f alpine.Dockerfile"
BUILD+=" --platform linux/amd64,linux/arm64"
BUILD+=" --build-arg 'GURU_VERSION=master'"
BUILD+=" --build-arg 'GOPLS_VERSION=latest'"
BUILD+=" --build-arg 'DELVE_VERSION=latest'"
BUILD+=" --build-arg 'GOTESTS_VERSION=latest'"
BUILD+=" --build-arg 'GOMODIFYTAGS_VERSION=latest'"
BUILD+=" --build-arg 'GOPLAY_VERSION=latest'"
BUILD+=" --build-arg 'GOLANGCI_LINT_VERSION=latest'"
BUILD+=" --cache-from type=registry,ref=${IMAGE_NAME}:cache"
BUILD+=" --cache-to type=registry,mode=max,ref=${IMAGE_NAME}:cache"
BUILD+=" --tag ${IMAGE_NAME}:latest"
BUILD+=" --progress=plain"
BUILD+=" --push"
$BUILD $WD
docker buildx use default