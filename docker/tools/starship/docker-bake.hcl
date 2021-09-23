#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "LOCAL" {default=false}
variable "TAG" {default=""}
group "default" {
    targets = [
        "tools-starship",
    ]
}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "tools-starship" --driver docker-container

# LOCAL=true docker buildx bake --builder tools-starship tools-starship
target "tools-starship" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/starship:latest",
        notequal("",TAG) ? "fjolsvin/starship:${TAG}": "",
    ]
    platforms = ["linux/amd64"]
    cache-from = ["type=registry,ref=fjolsvin/starship:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/starship:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}