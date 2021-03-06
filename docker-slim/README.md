# docker

## overview

the docker files in this directory are written to work with [`docker-slim`](https://dockersl.im/) build so that we can get optimally secure and smallest images. Do not user `docker` to build these as the images are far too large when built with docker.

## usage

- build

```bash
docker-slim --debug --log-level trace --verbose build --http-probe=false --dockerfile Dockerfile --tag-fat <tag-name> .
```