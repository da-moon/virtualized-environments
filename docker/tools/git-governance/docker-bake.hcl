#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "LOCAL" {default=false}
variable "ARM64" {default=true}
variable "AMD64" {default=true}
variable "TAG" {default=""}
group "default" {
    targets = [
        "tools-git-governance",
    ]
}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "tools-git-governance" --driver docker-container

# LOCAL=true docker buildx bake --builder tools-git-governance tools-git-governance
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder tools-git-governance tools-git-governance
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder tools-git-governance tools-git-governance
target "tools-git-governance" {
    context="."
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/git-governance:latest",
        notequal("",TAG) ? "fjolsvin/git-governance:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/git-governance:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/git-governance:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}