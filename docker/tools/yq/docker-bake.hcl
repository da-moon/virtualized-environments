#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

variable "LOCAL" {default=false}
variable "ARM64" {default=true}
variable "AMD64" {default=true}
variable "TAG" {default=""}
group "default" {
    targets = [
        "tools-yq",
    ]
}
# docker buildx create --use --name "tools-yq" --driver docker-container
# LOCAL=true docker buildx bake --builder tools-yq tools-yq
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder tools-yq tools-yq
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder tools-yq tools-yq
target "tools-yq" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/yq:latest",
        notequal("",TAG) ? "fjolsvin/yq:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/yq:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/yq:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}