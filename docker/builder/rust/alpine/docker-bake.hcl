#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "LOCAL" {default=false}
variable "ARM64" {default=true}
variable "AMD64" {default=true}
variable "TAG" {default=""}
group "default" {
    targets = [
        "builder-rust-alpine",
    ]
}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "builder-rust-alpine" --driver docker-container

# LOCAL=true docker buildx bake --builder builder-rust-alpine rust-alpine
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder builder-rust-alpine rust-alpine
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder builder-rust-alpine rust-alpine
target "builder-rust-alpine" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/rust-builder-alpine:latest",
        notequal("",TAG) ? "fjolsvin/rust-builder-alpine:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/rust-builder-alpine:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/rust-builder-alpine:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}