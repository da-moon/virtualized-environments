# !/usr/bin/env -S just --justfile
# vi: ft=just tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

set positional-arguments := true
set dotenv-load := true
set shell := ["/bin/bash", "-o", "pipefail", "-c"]

default:
    @just --choose

# ─── DEPENDENCIES ───────────────────────────────────────────────────────────────

alias b := bootstrap

bootstrap: dependencies build-targets-gen vscode-tasks kary-comments format pre-commit
    @echo bootstrap completed

# ────────────────────────────────────────────────────────────────────────────────

alias d := dependencies

dependencies:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -- sudo pip3 -h > /dev/null 2>&1 ; then
      if ! command -- pre-commit -h > /dev/null 2>&1 ; then
        sudo pip3 install pre-commit
      fi
    fi
    if command -- cargo -h > /dev/null 2>&1 ; then
      if ! command -- convco -h > /dev/null 2>&1 ; then
        cargo install convco
      fi
      if ! command -- jsonfmt -h > /dev/null 2>&1 ; then
        cargo install jsonfmt
      fi
    fi
    if [ ! -d "$HOME/.SpaceVim" ] ; then
      curl -sLf https://spacevim.org/install.sh | bash
    fi
    if command -- sudo $(which node) $(which yarn) --help > /dev/null 2>&1 ; then
      NODE_PACKAGES="\
      remark \
      remark-cli \
      remark-stringify \
      remark-frontmatter \
      wcwidth \
      prettier \
      bash-language-server \
      dockerfile-language-server-nodejs \
      standard-readme-spec \
      "
      IFS=' ' read -a NODE_PACKAGES <<< "$NODE_PACKAGES" ;
      installed=()
      if command -- jq -h > /dev/null 2>&1 && [ -r $(sudo $(which node) $(which yarn) global dir)/package.json ] ; then
        while IFS='' read -r line; do
          installed+=("$line");
        done < <(cat  $(sudo $(which node) $(which yarn) global dir)/package.json  | jq -r '.dependencies|keys[]')
      fi
      intersection=($(comm -12 <(for X in "${NODE_PACKAGES[@]}"; do echo "${X}"; done|sort)  <(for X in "${installed[@]}"; do echo "${X}"; done|sort)))
      to_install=($(echo ${intersection[*]} ${NODE_PACKAGES[*]} | sed 's/ /\n/g' | sort -n | uniq -u | paste -sd " " - ))
      if [ ${#to_install[@]} -ne 0  ];then
        sudo $(which node) $(which yarn) global add --prefix /usr/local ${to_install[@]}
      fi
    fi

# ────────────────────────────────────────────────────────────────────────────────

alias kc := kary-comments

kary-comments:
    #!/usr/bin/env bash
    set -euo pipefail
    sed -i.bak \
    -e "/case 'yaml':.*/a case 'terraform':" \
    -e "/case 'yaml':.*/a case 'dockerfile':" \
    -e "/case 'yaml':.*/a case 'just':" \
    -e "/case 'yaml':.*/a case 'hcl':" \
    ~/.vscode*/extensions/karyfoundation.comment*/dictionary.js || true

# ────────────────────────────────────────────────────────────────────────────────

alias vt := vscode-tasks

vscode-tasks:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -- jq -h > /dev/null 2>&1 ; then
      IFS=' ' read -a TASKS <<< "$(just --summary --color never -f "{{ justfile() }}" 2>/dev/null)"
      if [ ${#TASKS[@]} -ne 0  ];then
        json=$(jq -n --arg version "2.0.0" '{"version":$version,"tasks":[]}')
        for task in "${TASKS[@]}";do
          taskjson=$(jq -n --arg task "${task}" --arg command "just ${task}" '[{"type": "shell","label": $task,  "command": $command }]')
          json=$(echo "${json}" | jq ".tasks += ${taskjson}")
        done
        echo "${json}" | jq -r '.' > "{{ justfile_directory() }}/.vscode/tasks.json"
      fi
    fi

# ─── FORMAT ─────────────────────────────────────────────────────────────────────

alias f := format
alias fmt := format

format: format-json format-just
    @echo format completed

# ────────────────────────────────────────────────────────────────────────────────

alias fj := format-json
alias json-fmt := format-json

format-json:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -- jsonfmt -h > /dev/null 2>&1 ; then
      while read file;do
        echo "*** formatting $file"
        jsonfmt "$file" || true
      done < <(find -type f -not -path '*/\.git/*' -name '*.json')
    fi

# ────────────────────────────────────────────────────────────────────────────────
format-just:
    #!/usr/bin/env bash
    set -euo pipefail
    just --unstable --fmt 2>/dev/null

# ─── GIT ────────────────────────────────────────────────────────────────────────
# Variables

MASTER_BRANCH_NAME := 'master'
MAJOR_VERSION := `[[ $(git tag -l) -ne '' ]] && convco version --major 2>/dev/null || echo '0.0.1'`
MINOR_VERSION := `[[ $(git tag -l) -ne '' ]] && convco version --minor 2>/dev/null || echo '0.0.1'`
PATCH_VERSION := `[[ $(git tag -l) -ne '' ]] && convco version --patch 2>/dev/null || echo '0.0.1'`

# ────────────────────────────────────────────────────────────────────────────────

alias pc := pre-commit

pre-commit: format-just
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "{{ justfile_directory() }}" > /dev/null 2>&1
    export PIP_USER=false
    git add ".pre-commit-config.yaml"
    pre-commit install > /dev/null 2>&1
    pre-commit install-hooks
    pre-commit
    popd > /dev/null 2>&1

# ────────────────────────────────────────────────────────────────────────────────

alias c := commit

commit: pre-commit
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "{{ justfile_directory() }}" > /dev/null 2>&1
    if command -- convco -h > /dev/null 2>&1 ; then
      convco commit
    else
      git commit
    fi
    popd > /dev/null 2>&1

# ────────────────────────────────────────────────────────────────────────────────

alias mar := major-release

major-release: format-just
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "{{ justfile_directory() }}" > /dev/null 2>&1
    git checkout "{{ MASTER_BRANCH_NAME }}"
    git pull
    git tag -a "v{{ MAJOR_VERSION }}" -m 'major release {{ MAJOR_VERSION }}'
    git push origin --tags
    if command -- convco -h > /dev/null 2>&1 ; then
      convco changelog > CHANGELOG.md
      git add CHANGELOG.md
      if command -- pre-commit -h > /dev/null 2>&1 ; then
        pre-commit || true
        git add CHANGELOG.md
      fi
      git commit -m 'docs(changelog): updated changelog for v{{ MAJOR_VERSION }}'
      git push
    fi
    popd > /dev/null 2>&1

# ────────────────────────────────────────────────────────────────────────────────

alias mir := minor-release

minor-release: format-just
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "{{ justfile_directory() }}" > /dev/null 2>&1
    git checkout "{{ MASTER_BRANCH_NAME }}"
    git pull
    git tag -a "v{{ MINOR_VERSION }}" -m 'minor release {{ MINOR_VERSION }}'
    git push origin --tags
    if command -- convco -h > /dev/null 2>&1 ; then
      convco changelog > CHANGELOG.md
      git add CHANGELOG.md
      if command -- pre-commit -h > /dev/null 2>&1 ; then
        pre-commit || true
        git add CHANGELOG.md
      fi
      git commit -m 'docs(changelog): updated changelog for v{{ MINOR_VERSION }}'
      git push
    fi
    popd > /dev/null 2>&1

# ────────────────────────────────────────────────────────────────────────────────

alias pr := patch-release

patch-release: format-just
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "{{ justfile_directory() }}" > /dev/null 2>&1
    git checkout "{{ MASTER_BRANCH_NAME }}"
    git pull
    git tag -a "v{{ PATCH_VERSION }}" -m 'patch release {{ PATCH_VERSION }}'
    git push origin --tags
    if command -- convco -h > /dev/null 2>&1 ; then
      convco changelog > CHANGELOG.md
      git add CHANGELOG.md
      if command -- pre-commit -h > /dev/null 2>&1 ; then
        pre-commit || true
        git add CHANGELOG.md
      fi
      git commit -m 'docs(changelog): updated changelog for v{{ MINOR_VERSION }}'
      git push
    fi
    popd > /dev/null 2>&1

# ────────────────────────────────────────────────────────────────────────────────

alias dc := docker-clean

docker-clean:
    #!/usr/bin/env bash
    set -euo pipefail
    docker ps -aq | xargs -r docker rm -f
    docker system prune -f -a --volumes

# ─── VAGRANT RELATED TARGETS ────────────────────────────────────────────────────

alias vug := vagrant-up-gcloud

vagrant-up-gcloud:
    #!/usr/bin/env bash
    set -euo pipefail
    export NAME="$(basename "{{ justfile_directory() }}")" ;
    plugins=(
      "vagrant-share"
      "vagrant-google"
      "vagrant-rsync-back"
    );
    available_plugins=($(vagrant plugin list | awk '{print $1}'))
    intersection=($(comm -12 <(for X in "${plugins[@]}"; do echo "${X}"; done|sort)  <(for X in "${available_plugins[@]}"; do echo "${X}"; done|sort)))
    to_install=($(echo ${intersection[*]} ${plugins[*]} | sed 's/ /\n/g' | sort -n | uniq -u | paste -sd " " - ))
    if [ ${#to_install[@]} -ne 0  ];then
      vagrant plugin install ${to_install[@]}
    fi
    if [ -z ${GOOGLE_PROJECT_ID+x} ] || [ -z ${GOOGLE_PROJECT_ID} ]; then
      export GOOGLE_PROJECT_ID="$(gcloud config get-value core/project)" ;
    fi
    GCLOUD_IAM_ACCOUNT="${NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com"
    if ! gcloud iam service-accounts describe "${GCLOUD_IAM_ACCOUNT}" > /dev/null 2>&1; then
      gcloud iam service-accounts create "${NAME}" ;
      gcloud projects add-iam-policy-binding "${GOOGLE_PROJECT_ID}" \
        --member="serviceAccount:${GCLOUD_IAM_ACCOUNT}" \
        --role="roles/owner" ;
    fi
      if [ -z ${GOOGLE_APPLICATION_CREDENTIALS+x} ] || [ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
      export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/${NAME}_gcloud.json" ;
    fi
    if [ -r "${GOOGLE_APPLICATION_CREDENTIALS}" ];then
      rm ${GOOGLE_APPLICATION_CREDENTIALS}
    fi
    gcloud iam service-accounts keys list \
      --iam-account="${GCLOUD_IAM_ACCOUNT}" \
      --format="value(KEY_ID)" | xargs -I {} \
      gcloud iam service-accounts keys delete \
      --iam-account="${GCLOUD_IAM_ACCOUNT}" {} >/dev/null 2>&1 || true ;
    gcloud iam service-accounts keys \
      create ${GOOGLE_APPLICATION_CREDENTIALS} \
      --iam-account="${GCLOUD_IAM_ACCOUNT}" ;
    rm -f "$HOME/.ssh/${NAME}"* ;
    ssh-keygen -q -N "" -t rsa -b 2048 -f "$HOME/.ssh/${NAME}" || true ;
    vagrant up --provider=google

# ────────────────────────────────────────────────────────────────────────────────

alias vdg := vagrant-down-gcloud

vagrant-down-gcloud:
    #!/usr/bin/env bash
    set -euo pipefail ;
    vagrant destroy -f || true ;
    export NAME="$(basename "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")" ;
    if [ -z ${GOOGLE_PROJECT_ID+x} ] || [ -z ${GOOGLE_PROJECT_ID} ]; then
    export GOOGLE_PROJECT_ID="$(gcloud config get-value core/project)" ;
    fi
    if [ -z ${GOOGLE_APPLICATION_CREDENTIALS+x} ] || [ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/${NAME}_gcloud.json" ;
    fi
    GCLOUD_IAM_ACCOUNT="${NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com"
    gcloud iam service-accounts delete --quiet "${GCLOUD_IAM_ACCOUNT}" > /dev/null 2>&1  || true ;
    rm -f "${GOOGLE_APPLICATION_CREDENTIALS}" ;
    rm -f "$HOME/.ssh/${NAME}" ;
    rm -f "$HOME/.ssh/${NAME}.pub" ;
    gcloud compute instances delete --quiet "${NAME}" > /dev/null 2>&1 || true ;
    sudo rm -rf .vagrant ;

# ─── GITPOD ─────────────────────────────────────────────────────────────────────
docker-socket-chown:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo chown "$(id -u gitpod):$(cut -d: -f3 < <(getent group docker))" /var/run/docker.sock

alias fo := fix-ownership

fix-ownership: docker-socket-chown
    #!/usr/bin/env bash
    set -euo pipefail
    sudo find "${HOME}/" "/workspace" -not -group `id -g` -not -user `id -u` -print0 | xargs -P 0 -0 --no-run-if-empty sudo chown --no-dereference "`id -u`:`id -g`" || true ;
    # sudo find "/workspace" -not -group `id -g` -not -user `id -u` -print | xargs -I {}  -P `nproc` --no-run-if-empty sudo chown --no-dereference "`id -u`:`id -g`" {} || true ;

docker-login-env:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "*** ensuring current user belongs to docker group" ;
    sudo usermod -aG docker "$(whoami)"
    echo "*** ensuring required environment variables are present" ;
    while [ -z "$DOCKER_USERNAME" ] ; do \
    printf "\n❗ The DOCKER_USERNAME environment variable is required. Please enter its value.\n" ;
    read -s -p "DOCKER_USERNAME: " DOCKER_USERNAME ; \
    done ; gp env DOCKER_USERNAME=$DOCKER_USERNAME && printf "\nThanks\n" || true ;
    while [ -z "$DOCKER_PASSWORD" ] ; do \
    printf "\n❗ The DOCKER_PASSWORD environment variable is required. Please enter its value.\n" ;
    read -s -p "DOCKER_PASSWORD: " DOCKER_PASSWORD ; \
    done ; gp env DOCKER_PASSWORD=$DOCKER_PASSWORD && printf "\nThanks\n" || true ;

alias dl := docker-login

docker-login: fix-ownership docker-login-env
    #!/usr/bin/env bash
    set -euo pipefail
    echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin ;
    just fix-ownership

ssh-pub-key-env:
    #!/usr/bin/env bash
    set -euo pipefail
    while [ -z "$SSH_PUB_KEY" ] ; do \
    printf "\n❗ The SSH_PUB_KEY environment variable is required. Please enter its value.\n" ;
    read -s -p "SSH_PUB_KEY: " SSH_PUB_KEY ; \
    done ; gp env SSH_PUB_KEY=$SSH_PUB_KEY && printf "\nThanks\n" || true ;

ssh-pub-key: fix-ownership ssh-pub-key-env
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p ${HOME}/.ssh ;
    echo "${SSH_PUB_KEY}" | tee ${HOME}/.ssh/authorized_keys > /dev/null ;
    chmod 700 ${HOME}/.ssh ;
    chmod 600 ${HOME}/.ssh/authorized_keys ;
    just fix-ownership
    exit 0

chisel: fix-ownership
    #!/usr/bin/env bash
    set -euo pipefail
    [ -f ${HOME}/chisel.pid ] && echo "*** killing chisel server" && kill -9 "$(cat ${HOME}/chisel.pid)" && rm -rf ${HOME}/chisel.pid ;
    pushd ${HOME}/ ;
    echo "*** starting chisel server" ;
    bash -c "chisel server --socks5 --pid > ${HOME}/chisel.log 2>&1 &" ;
    echo "*** chisel was started successfully" ;
    popd ;
    just fix-ownership
    exit 0

dropbear: fix-ownership
    #!/usr/bin/env bash
    set -euo pipefail
    [ ! -f ${HOME}/dropbear.hostkey ] && echo "*** generating dropbear host key" && dropbearkey -t rsa -f ${HOME}/dropbear.hostkey ;
    [ -f ${HOME}/dropbear.pid ] && echo "*** killing dropbear server" && kill -9 "$(cat ${HOME}/dropbear.pid)" && rm -rf ${HOME}/dropbear.pid ;
    echo "*** starting dropbear server" ;
    bash -c "dropbear -r ${HOME}/dropbear.hostkey -F -E -s -p 2222 -P ${HOME}/dropbear.pid > ${HOME}/dropbear.log 2>&1 &" ;
    echo "*** dropbear server was started successfully" ;
    just fix-ownership
    exit 0

alias ssh := ssh-config

ssh-config: ssh-pub-key
    #!/usr/bin/env bash
    set -euo pipefail
    cat << EOF
    Host $(gp url | sed -e 's/https:\/\///g' -e 's/[.].*$//g')
      HostName localhost
      User gitpod
      Port 2222
      ProxyCommand chisel client $(gp url 8080) stdio:%h:%p
      RemoteCommand cd /workspace && exec bash --login
      RequestTTY yes
      IdentityFile ~/.ssh/id_rsa
      IdentitiesOnly yes
      StrictHostKeyChecking no
      CheckHostIP no
      MACs hmac-sha2-256
      UserKnownHostsFile /dev/null
    EOF

alias gf := git-fetch

git-fetch:
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "{{ justfile_directory() }}" > /dev/null 2>&1
    git fetch -p ;
    for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
      git branch -D "$branch";
    done
    popd > /dev/null 2>&1

snapshot: format-just git-fetch
    #!/usr/bin/env bash
    set -euo pipefail
    sync
    snapshot_dir="{{ justfile_directory() }}/tmp/snapshots"
    mkdir -p "${snapshot_dir}"
    time="$(date +'%Y-%m-%d-%H-%M')"
    path="${snapshot_dir}/${time}.tar.gz"
    tmp="$(mktemp -d)"
    tar -C {{ justfile_directory() }} -cpzf "$tmp/${time}.tar.gz" .
    mv "$tmp/${time}.tar.gz" "$path"
    rm -r "$tmp"
    echo >&2 "*** snapshot created at ${path}"

# ─── BUILDERS ───────────────────────────────────────────────────────────────────

RUST_BUILDER_IMAGE := "fjolsvin/rust-builder-alpine"

docker-qemu:
    #!/usr/bin/env bash
    set -euo pipefail
    docker run \
      --rm \
      --privileged \
      multiarch/qemu-user-static --reset -p yes

alias rb-amd := rust-builder-amd64

@rust-builder-amd64:
    #!/usr/bin/env bash
    set -euo pipefail
    mount_path="{{ justfile_directory() }}/tmp/$(basename $0)" ;
    docker pull "{{ RUST_BUILDER_IMAGE }}"
    mkdir -p "$mount_path"
    sudo rm -rf "$mount_path"
    mkdir -p  "$mount_path"
    docker run -v "$mount_path:/workspace" \
      --entrypoint '' \
      --rm -it "{{ RUST_BUILDER_IMAGE }}" /bin/bash
    sudo chown "`id -u`:`id -g`" "$mount_path" -R

# ────────────────────────────────────────────────────────────────────────────────

alias rb-arm := rust-builder-arm64

@rust-builder-arm64: docker-qemu
    #!/usr/bin/env bash
    set -euo pipefail
    arch="arm64"
    mount_path="{{ justfile_directory() }}/tmp/$(basename $0)" ;
    hash=$(docker manifest inspect "{{ RUST_BUILDER_IMAGE }}" \
    | jq -r ".manifests \
    | .[]
    | select(.platform.architecture == \"${arch}\")
    | .digest")
    docker run \
    -v {{ justfile_directory() }}/tmp/qemu-aarch64-static:/usr/bin/qemu-aarch64-static \
    --entrypoint "" --rm -it  "{{ RUST_BUILDER_IMAGE }}@${hash}" /bin/bash
    sudo chown "`id -u`:`id -g`" "$mount_path" -R

# ────────────────────────────────────────────────────────────────────────────────
build-and-push-changes *dir:
    #!/usr/bin/env bash
    set -eu pipefail
    if [ -z '{{ dir }}' ]; then
      docker_files=($(git ls-files --others --exclude-standard | /bin/grep -E '.*Dockerfile.*' | sort -u || true))
      docker_files+=($(git diff --name-only HEAD | /bin/grep -E '.*Dockerfile.*' | sort -u || true))
    else
      docker_files=($(git ls-files --others --exclude-standard | /bin/grep '{{ dir }}' | /bin/grep -E '.*Dockerfile.*' | sort -u || true))
      docker_files+=($(git diff --name-only HEAD | /bin/grep '{{ dir }}' | /bin/grep -E '.*Dockerfile.*' | sort -u || true))
    fi
    mkdir -p "{{ justfile_directory() }}/tmp"
    [ -r "{{ justfile_directory() }}/tmp/failed" ] && rm "{{ justfile_directory() }}/tmp/failed"
    for docker_file in "${docker_files[@]}" ; do
      script="$(dirname $docker_file)/build.sh" ;
      if [ -r "${script}" ]; then
        bash "${script}" || echo "${script}" >> "{{ justfile_directory() }}/tmp/failed"
      fi
    done

# ─── IMAGE BUILD TARGETS ────────────────────────────────────────────────────────
# [ WARN ] do NOT add any tagets after this.
# since the sed command in this target removes all
# lines that comes after 'build:'

alias btg := build-targets-gen

build-targets-gen:
    #!/usr/bin/env bash
    set -euo pipefail
    scripts=()
    targets=()
    while read script;do
      scripts+=("${script}")
      target="build-$(dirname ${script} | sed -e 's/\.\///g' -e 's/\//-/g')"
      targets+=("${target}")
    done < <(find . -name build.sh)
    sed -i '/^build:/,$d' "{{ justfile() }}"
    echo "" >> "{{ justfile() }}"
    echo "build: ${targets[@]}" | tee -a "{{ justfile() }}" > /dev/null
    for script in "${scripts[@]}"; do
      target="build-$(dirname ${script} | sed -e 's/\.\///g' -e 's/\//-/g')"
      (
        echo "$target: " ;
        echo '  #!/usr/bin/env bash'
        echo '  set -euo pipefail ;'
        echo "  bash ${script}"
      ) | tee -a "{{ justfile() }}" > /dev/null
    done
    just format-just

build: build-builder-rust-alpine build-devcontainer-core-alpine build-devcontainer-golang-base-alpine build-devcontainer-golang-vscode-alpine build-devcontainer-rust-base-alpine build-devcontainer-rust-base-debian build-devcontainer-rust-vscode-debian build-gitpod-workspace-full-alpine build-gitpod-workspace-full-archlinux build-gitpod-workspace-full-ubuntu build-stacks-hashicorp build-tools-bat build-tools-cellar build-tools-clog build-tools-convco build-tools-delta build-tools-exa build-tools-fd build-tools-hyperfine build-tools-jen build-tools-jsonfmt build-tools-just build-tools-petname build-tools-releez build-tools-ripgrep build-tools-sad build-tools-scoob build-tools-sd build-tools-shfmt build-tools-skim build-tools-sops build-tools-starship build-tools-tojson build-tools-tokei build-tools-ttdl build-tools-upx build-tools-yq

build-builder-rust-alpine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./builder/rust/alpine/build.sh

build-devcontainer-core-alpine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./devcontainer/core/alpine/build.sh

build-devcontainer-golang-base-alpine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./devcontainer/golang/base/alpine/build.sh

build-devcontainer-golang-vscode-alpine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./devcontainer/golang/vscode/alpine/build.sh

build-devcontainer-rust-base-alpine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./devcontainer/rust/base/alpine/build.sh

build-devcontainer-rust-base-debian:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./devcontainer/rust/base/debian/build.sh

build-devcontainer-rust-vscode-debian:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./devcontainer/rust/vscode/debian/build.sh

build-gitpod-workspace-full-alpine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./gitpod/workspace-full/alpine/build.sh

build-gitpod-workspace-full-archlinux:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./gitpod/workspace-full/archlinux/build.sh

build-gitpod-workspace-full-ubuntu:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./gitpod/workspace-full/ubuntu/build.sh

build-stacks-hashicorp:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./stacks/hashicorp/build.sh

build-tools-bat:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/bat/build.sh

build-tools-cellar:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/cellar/build.sh

build-tools-clog:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/clog/build.sh

build-tools-convco:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/convco/build.sh

build-tools-delta:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/delta/build.sh

build-tools-exa:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/exa/build.sh

build-tools-fd:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/fd/build.sh

build-tools-hyperfine:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/hyperfine/build.sh

build-tools-jen:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/jen/build.sh

build-tools-jsonfmt:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/jsonfmt/build.sh

build-tools-just:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/just/build.sh

build-tools-petname:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/petname/build.sh

build-tools-releez:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/releez/build.sh

build-tools-ripgrep:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/ripgrep/build.sh

build-tools-sad:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/sad/build.sh

build-tools-scoob:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/scoob/build.sh

build-tools-sd:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/sd/build.sh

build-tools-shfmt:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/shfmt/build.sh

build-tools-skim:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/skim/build.sh

build-tools-sops:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/sops/build.sh

build-tools-starship:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/starship/build.sh

build-tools-tojson:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/tojson/build.sh

build-tools-tokei:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/tokei/build.sh

build-tools-ttdl:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/ttdl/build.sh

build-tools-upx:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/upx/build.sh

build-tools-yq:
    #!/usr/bin/env bash
    set -euo pipefail ;
    bash ./tools/yq/build.sh
