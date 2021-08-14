{
    "dockerComposeFile": [
        "docker-compose.devcontainer.yml"
    ],
    "service": "workspace",
    "shutdownAction": "stopCompose",
    "workspaceFolder": "/workspace",
    "settings": {
        "files.eol": "\n",
        "terminal.integrated.shell.linux": "/bin/bash",
        "editor.formatOnSave": true,
        "editor.tabSize": 2,
        "editor.formatOnType": true,
        "editor.formatOnPaste": true,
        "python.pythonPath": "${containerWorkspaceFolder}/.venv/bin/python3",
        "python.terminal.activateEnvironment": false,
        "python.poetryPath": "${containerEnv:HOME}/.poetry/bin",
        "python.linting.enabled": true,
        "python.linting.flake8Enabled": false,
        "python.linting.mypyEnabled": true,
        "python.linting.pylintEnabled": true,
        "python.testing.pytestEnabled": true,
        "python.formatting.provider": "yapf",
        "python.formatting.yapfArgs": [
            "--style",
            "{based_on_style: pep8, indent_width: 4}"
        ],
        "python.analysis.disabled": [
            "undefined-variable",
            "unresolved-import"
        ]
    },
    "extensions": [
        "ms-python.python",
        "karyfoundation.comment",
        "bungcip.better-toml",
        "mutantdino.resourcemonitor",
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
        "wholroyd.hcl",
        "skellock.just",
        "tomoyukim.vscode-mermaid-editor",
        "gruntfuggly.todo-tree",
        "tabnine.tabnine-vscode"
    ],
    "forwardPorts": [],
    "containerEnv": {
        "PATH": "${containerEnv:PATH}:${containerWorkspaceFolder}/dist/pex",
    },
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
    ],
    "remoteUser": "code",
    "postStartCommand": "sudo chown \"`id -u`:`id -g`\"  ${containerWorkspaceFolder} -R",
    "postAttachCommand": "sudo chown \"`id -u`:`id -g`\"  ${containerWorkspaceFolder} -R && poetry install",
    "portsAttributes": {
        "8200": {
            "label": "vault"
        }
    },
}
