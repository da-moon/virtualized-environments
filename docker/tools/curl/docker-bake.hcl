#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "LOCAL" {default=false}
variable "TAG" {default=""}
group "default" {
    targets = [
        "tools-curl",
    ]
}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "tools-curl" --driver docker-container

# LOCAL=true docker buildx bake --builder tools-curl tools-curl
target "tools-curl" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/curl:latest",
        notequal("",TAG) ? "fjolsvin/curl:${TAG}": "",
    ]
    platforms = ["linux/amd64"]
    cache-from = ["type=registry,ref=fjolsvin/curl:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/curl:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}