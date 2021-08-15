#!/usr/bin/env bash
#-*-mode:sh;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
set -xeuo pipefail ;
if [ -z ${IMAGE_NAME+x} ] || [  -z ${IMAGE_NAME} ];then
  IMAGE_NAME="fjolsvin/$(basename $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
pushd "$WD" >/dev/null 2>&1
fi
# ────────────────────────────────────────────────────────────────────────────────

WD="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
pushd "$WD" >/dev/null 2>&1
ESC_WD="$(echo "$WD" | sed 's/\//\\\//g')"
DOCKER_FILE="$(dirname "${BASH_SOURCE[0]}")/Dockerfile"
DOCKER_FILE=$(echo "${DOCKER_FILE}" | sed -e "s/$ESC_WD\///g")
CACHE_NAME="${IMAGE_NAME}:cache"
