#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

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
        "builder-rust-alpine",
        "devcontainer-core-alpine",
        "devcontainer-golang-alpine",
        "devcontainer-rust-alpine",
        "gitpod-ubuntu",
        "tools-bat",
        "tools-cellar",
        "tools-clog",
        "tools-convco",
        "tools-curl",
        "tools-delta",
        "tools-exa",
        "tools-fd",
        "tools-git-governance",
        "tools-hyperfine",
        "tools-jen",
        "tools-jsonfmt",
        "tools-just",
        "tools-petname",
        "tools-releez",
        "tools-ripgrep",
        "tools-sad",
        "tools-scoob",
        "tools-sd",
        "tools-shfmt",
        "tools-skim",
        "tools-sops",
        "tools-starship",
        "tools-tojson",
        "tools-tokei",
        "tools-ttdl",
        "tools-upx",
        "tools-yq",
    ]
}
# local=true docker buildx bake --builder virtualized-environments rust-alpine
# local=true arm64=false amd64=true docker buildx bake --builder virtualized-environments rust-alpine
# local=true arm64=true amd64=false docker buildx bake --builder virtualized-environments rust-alpine
target "builder-rust-alpine" {
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
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# local=true docker buildx bake --builder virtualized-environments devcontainer-core-alpine
# local=true arm64=false amd64=true docker buildx bake --builder virtualized-environments devcontainer-core-alpine
# local=true arm64=true amd64=false docker buildx bake --builder virtualized-environments devcontainer-core-alpine
target "devcontainer-core-alpine" {
    context="./devcontainer/core/alpine"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/base-alpine:latest",
        notequal("",TAG) ? "fjolsvin/base-alpine:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/base-alpine:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/base-alpine:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# local=true docker buildx bake --builder virtualized-environments devcontainer-golang-alpine
# local=true arm64=false amd64=true docker buildx bake --builder virtualized-environments devcontainer-golang-alpine
# local=true arm64=true amd64=false docker buildx bake --builder virtualized-environments devcontainer-golang-alpine
target "devcontainer-golang-alpine" {
    context="./devcontainer/golang/alpine"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/golang-alpine-sandbox:latest",
        notequal("",TAG) ? "fjolsvin/golang-alpine-sandbox:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/golang-alpine-sandbox:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/golang-alpine-sandbox:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# local=true docker buildx bake --builder virtualized-environments devcontainer-rust-alpine
# local=true arm64=false amd64=true docker buildx bake --builder virtualized-environments devcontainer-rust-alpine
# local=true arm64=true amd64=false docker buildx bake --builder virtualized-environments devcontainer-rust-alpine
target "devcontainer-rust-alpine" {
    context="./devcontainer/rust/base/alpine"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/rust-base-alpine:latest",
        notequal("",TAG) ? "fjolsvin/rust-base-alpine:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/rust-base-alpine:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/rust-base-alpine:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
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
    cache-to   = [equal(LOCAL,false) ? "type=registry,mode=max,ref=fjolsvin/gitpod-ubuntu:cache" : ""]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-bat
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-bat
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-bat
target "tools-bat" {
    context="./tools/bat"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/bat:latest",
        notequal("",TAG) ? "fjolsvin/bat:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/bat:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/bat:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-cellar
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-cellar
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-cellar
target "tools-cellar" {
    context="./tools/cellar"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/cellar:latest",
        notequal("",TAG) ? "fjolsvin/cellar:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/cellar:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/cellar:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-clog
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-clog
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-clog
target "tools-clog" {
    context="./tools/clog"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/clog:latest",
        notequal("",TAG) ? "fjolsvin/clog:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/clog:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/clog:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-convco
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-convco
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-convco
target "tools-convco" {
    context="./tools/convco"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/convco:latest",
        notequal("",TAG) ? "fjolsvin/convco:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/convco:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/convco:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-curl
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-curl
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-curl
target "tools-curl" {
    context="./tools/curl"
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
# LOCAL=true docker buildx bake --builder virtualized-environments tools-delta
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-delta
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-delta
target "tools-delta" {
    context="./tools/delta"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/delta:latest",
        notequal("",TAG) ? "fjolsvin/delta:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/delta:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/delta:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-exa
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-exa
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-exa
target "tools-exa" {
    context="./tools/exa"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/exa:latest",
        notequal("",TAG) ? "fjolsvin/exa:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/exa:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/exa:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-fd
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-fd
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-fd
target "tools-fd" {
    context="./tools/fd"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/fd:latest",
        notequal("",TAG) ? "fjolsvin/fd:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/fd:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/fd:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-git-governance
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-git-governance
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-git-governance
target "tools-git-governance" {
    context="./tools/git-governance"
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
# LOCAL=true docker buildx bake --builder virtualized-environments tools-hyperfine
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-hyperfine
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-hyperfine
target "tools-hyperfine" {
    context="./tools/hyperfine"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/hyperfine:latest",
        notequal("",TAG) ? "fjolsvin/hyperfine:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/hyperfine:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/hyperfine:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-jen
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-jen
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-jen
target "tools-jen" {
    context="./tools/jen"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/jen:latest",
        notequal("",TAG) ? "fjolsvin/jen:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/jen:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/jen:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-jsonfmt
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-jsonfmt
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-jsonfmt
target "tools-jsonfmt" {
    context="./tools/jsonfmt"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/jsonfmt:latest",
        notequal("",TAG) ? "fjolsvin/jsonfmt:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/jsonfmt:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/jsonfmt:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-just
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-just
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-just
target "tools-just" {
    context="./tools/just"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/just:latest",
        notequal("",TAG) ? "fjolsvin/just:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/just:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/just:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-petname
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-petname
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-petname
target "tools-petname" {
    context="./tools/petname"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/petname:latest",
        notequal("",TAG) ? "fjolsvin/petname:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/petname:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/petname:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-releez
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-releez
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-releez
target "tools-releez" {
    context="./tools/releez"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/releez:latest",
        notequal("",TAG) ? "fjolsvin/releez:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/releez:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/releez:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-ripgrep
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-ripgrep
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-ripgrep
target "tools-ripgrep" {
    context="./tools/ripgrep"
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
# LOCAL=true docker buildx bake --builder virtualized-environments tools-sad
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-sad
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-sad
target "tools-sad" {
    context="./tools/sad"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/sad:latest",
        notequal("",TAG) ? "fjolsvin/sad:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/sad:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/sad:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-scoob
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-scoob
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-scoob
target "tools-scoob" {
    context="./tools/scoob"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/scoob:latest",
        notequal("",TAG) ? "fjolsvin/scoob:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/scoob:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/scoob:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-sd
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-sd
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-sd
target "tools-sd" {
    context="./tools/sd"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/sd:latest",
        notequal("",TAG) ? "fjolsvin/sd:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/sd:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/sd:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-shfmt
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-shfmt
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-shfmt
target "tools-shfmt" {
    context="./tools/shfmt"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/shfmt:latest",
        notequal("",TAG) ? "fjolsvin/shfmt:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/shfmt:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/shfmt:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-skim
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-skim
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-skim
target "tools-skim" {
    context="./tools/skim"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/skim:latest",
        notequal("",TAG) ? "fjolsvin/skim:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/skim:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/skim:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-sops
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-sops
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-sops
target "tools-sops" {
    context="./tools/sops"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/sops:latest",
        notequal("",TAG) ? "fjolsvin/sops:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/sops:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/sops:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-starship
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-starship
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-starship
target "tools-starship" {
    context="./tools/starship"
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
# LOCAL=true docker buildx bake --builder virtualized-environments tools-tojson
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-tojson
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-tojson
target "tools-tojson" {
    context="./tools/tojson"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/tojson:latest",
        notequal("",TAG) ? "fjolsvin/tojson:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/tojson:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/tojson:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-tokei
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-tokei
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-tokei
target "tools-tokei" {
    context="./tools/tokei"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/tokei:latest",
        notequal("",TAG) ? "fjolsvin/tokei:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/tokei:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/tokei:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-ttdl
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-ttdl
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-ttdl
target "tools-ttdl" {
    context="./tools/ttdl"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/ttdl:latest",
        notequal("",TAG) ? "fjolsvin/ttdl:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/ttdl:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/ttdl:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-upx
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-upx
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-upx
target "tools-upx" {
    context="./tools/upx"
    dockerfile = "Dockerfile"
    tags = [
        "fjolsvin/upx:latest",
        notequal("",TAG) ? "fjolsvin/upx:${TAG}": "",
    ]
    platforms = [
        equal(AMD64,true) ?"linux/amd64":"",
        equal(ARM64,true) ?"linux/arm64":"",
    ]
    cache-from = ["type=registry,ref=fjolsvin/upx:cache"]
    cache-to   = ["type=registry,mode=max,ref=fjolsvin/upx:cache"]
    output     = [equal(LOCAL,true) ? "type=docker" : "type=registry"]
}
# LOCAL=true docker buildx bake --builder virtualized-environments tools-yq
# LOCAL=true ARM64=false AMD64=true docker buildx bake --builder virtualized-environments tools-yq
# LOCAL=true ARM64=true AMD64=false docker buildx bake --builder virtualized-environments tools-yq
target "tools-yq" {
    context="./tools/yq"
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
