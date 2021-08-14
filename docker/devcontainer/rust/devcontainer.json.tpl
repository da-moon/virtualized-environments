{

    // "name": "my-app-rs",
    // "runArgs": [
    //     "--cap-add", "SYS_PTRACE",
    //     "--security-opt","seccomp=unconfined",
    //     "--name","my-app-rs"
    // ],
    // "build": {
    //     "dockerfile": "./dev/debian.Dockerfile"
    // },
    "dockerComposeFile": [
        "docker-compose.yml"
    ],
    "service": "vscode-rust",
    "shutdownAction": "stopCompose",
    "workspaceFolder": "/home/rust/src",
    "settings": {
        "files.eol": "\n",
        "terminal.integrated.shell.linux": "/bin/bash",
        "files.watcherExclude": {
            "**/target/**": true
        },
        "rust-analyzer.trace.extension": true,
        "rust-analyzer.cargo.loadOutDirsFromCheck": true,
        "rust-analyzer.updates.channel": "nightly",
        "rust-analyzer.updates.askBeforeDownload": false,
        "editor.formatOnSave": true,
    },
    "extensions": [
        // "rust-lang.rust",
        "matklad.rust-analyzer",
        "bungcip.better-toml",
        "mutantdino.resourcemonitor",
        "TabNine.tabnine-vscode",
        // ---------------
        "redhat.vscode-yaml",
        "streetsidesoftware.code-spell-checker",
        "vscode-snippet.snippet",
        "wayou.vscode-todo-highlight",
        "wmaurer.change-case",
        "yzane.markdown-pdf",
        "yzhang.markdown-all-in-one",
        "aaron-bond.better-comments",
        "bungcip.better-toml",
        "EditorConfig.EditorConfig",
        "emeraldwalk.RunOnSave",
        "kevinkyang.auto-comment-blocks",
        "ms-azuretools.vscode-docker",

    ],
    "forwardPorts": [
    ],
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
    ],
    "remoteUser": "rust",
    "postCreateCommand": "uname -a && rustc --version"
}
