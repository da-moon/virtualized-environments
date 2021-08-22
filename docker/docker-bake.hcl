# [ NOTE ] => clean up buildx builders
# docker buildx ls | awk '$2 ~ /^docker(-container)*$/{print $1}' | xargs -r -I {} docker buildx rm {}
# [ NOTE ] create a builder for this file
# docker buildx create --use --name "virtualized-environments" --driver docker-container
# [ NOTE ] run build without pushing to dockerhub
# LOCAL=true docker buildx bake --builder virtualized-environments
variable "LOCAL" {default=false}
variable "ARM64" {default=true}
variable "AMD64" {default=true}
variable "TAG" {default=""}
group "default" {
    targets = [
        "rust-alpine",
        "gitpod-ubuntu",
    ]
}
# LOCAL=true docker buildx bake --builder virtualized-environments rust-alpine
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments rust-alpine
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments rust-alpine
target "rust-alpine" {
    context="./builder/rust/alpine"
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
    output     = [
        "type=docker",
        equal(LOCAL,false) ? "type=registry": "",
    ]
}
# LOCAL=true docker buildx bake --builder virtualized-environments gitpod-ubuntu
target "gitpod-ubuntu" {
    context="./gitpod/ubuntu"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/gitpod-ubuntu:latest",
        notequal("",TAG) ? "fjolsvin/gitpod-ubuntu:${TAG}": "",
    ]
    platforms  = ["linux/amd64"]
    cache-from = ["type=registry,ref=fjolsvin/gitpod-ubuntu:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/gitpod-ubuntu:cache"]
    output     = [
        "type=docker",
        equal(LOCAL,false) ? "type=registry": "",
    ]
}
