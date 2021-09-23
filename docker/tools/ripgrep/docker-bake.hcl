#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "LOCAL" {default=false}
variable "TAG" {default=""}
group "default" {
    targets = [
        "tools-ripgrep",
    ]
}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "tools-ripgrep" --driver docker-container

# LOCAL=true docker buildx bake --builder tools-ripgrep tools-ripgrep
target "tools-ripgrep" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/ripgrep:latest",
        notequal("",TAG) ? "fjolsvin/ripgrep:${TAG}": "",
    ]
    platforms = ["linux/amd64"]
    cache-from = ["type=registry,ref=fjolsvin/ripgrep:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/ripgrep:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}