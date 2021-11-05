#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

variable "LOCAL" {default=false}
variable "ARM64" {default=true}
variable "AMD64" {default=true}
variable "TAG" {default=""}
group "default" {
    targets = [
        "devcontainer-core-alpine",
    ]
}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "devcontainer-core-alpine" --driver docker-container

# LOCAL=true docker buildx bake --builder devcontainer-core-alpine
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder devcontainer-core-alpine
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder devcontainer-core-alpine
target "devcontainer-core-alpine" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/devcontainer-core-alpine:latest",
        notequal("",TAG) ? "fjolsvin/devcontainer-core-alpine:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = [equal(LOCAL,true) ? "type=registry,ref=fjolsvin/devcontainer-core-alpine:cache":""]
    cache-to   = [equal(LOCAL,true) ? "type=registry,mode=max,ref=fjolsvin/devcontainer-core-alpine:cache" : ""]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
