#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "LOCAL" {default=false}
variable "TAG" {default=""}
group "default" {
    targets = [
        "gitpod-ubuntu",
    ]
}
# docker buildx create --use --name "gitpod-ubuntu" --driver docker-container
# LOCAL=true docker buildx bake --builder gitpod-ubuntu gitpod-ubuntu
target "gitpod-ubuntu" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/gitpod-ubuntu:latest",
        notequal("",TAG) ? "fjolsvin/gitpod-ubuntu:${TAG}": "",
    ]
    platforms  = ["linux/amd64"]
    cache-from = ["type=registry,ref=fjolsvin/gitpod-ubuntu:cache"]
    cache-to   = [equal(LOCAL,false) ? "type=registry,mode=max,ref=fjolsvin/gitpod-ubuntu:cache" : ""]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
