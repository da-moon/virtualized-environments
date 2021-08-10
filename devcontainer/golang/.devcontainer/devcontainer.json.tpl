{
    // "name": "code",
    // "runArgs": [
    //     "--cap-add", "SYS_PTRACE",
    //     "--security-opt","seccomp=unconfined",
    //     "--name","code"
    // ],
    // "build": {
    //     "dockerfile": "../contrib/docker/dev/alpine.Dockerfile"
    // },
    "dockerComposeFile": [
        "docker-compose.devcontainer.yml"
    ],
    "service": "workspace",
    "shutdownAction": "stopCompose",
    "workspaceFolder": "/workspace",
    "settings": {
        "files.eol": "\n",
        "files.exclude": {
            "**/.vagrant": true,
            "**/.git": true,
            "**/tmp": true
        }
        "terminal.integrated.shell.linux": "/bin/bash",
        "go.toolsManagement.checkForUpdates": false,
        "go.gopath": "/go",
        "editor.formatOnSave": true,
        "go.useLanguageServer": true,
        "go.autocompleteUnimportedPackages": true,
        "go.gotoSymbol.includeImports": true,
        "go.gotoSymbol.includeGoroot": true,
        "gopls": {
            "completeUnimported": true,
            "deepCompletion": true,
            "usePlaceholders": false
        },
        "go.lintTool": "golangci-lint",
        "go.lintFlags": [
            "--fast",
            "--enable",
            "staticcheck",
            "--enable",
            "bodyclose",
            "--enable",
            "dogsled",
            "--enable",
            "gochecknoglobals",
            "--enable",
            "gochecknoinits",
            "--enable",
            "gocognit",
            "--enable",
            "goconst",
            "--enable",
            "gocritic",
            "--enable",
            "gocyclo",
            "--enable",
            "golint",
            "--enable",
            "gosec",
            "--enable",
            "interfacer",
            "--enable",
            "maligned",
            "--enable",
            "misspell",
            "--enable",
            "nakedret",
            "--enable",
            "prealloc",
            "--enable",
            "scopelint",
            "--enable",
            "unconvert",
            "--enable",
            "unparam",
            "--enable",
            "whitespace"
        ],
    },
    "extensions": [
        "golang.Go",
        "bungcip.better-toml",
        "mutantdino.resourcemonitor",
        "TabNine.tabnine-vscode",
        "EditorConfig.EditorConfig",
        "kevinkyang.auto-comment-blocks",
        "ms-azuretools.vscode-docker",
    ],
    "forwardPorts": [
        8200,
        8500
    ],
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
    ],
    "postCreateCommand": "go version",
    "remoteUser": "code",
}
