#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
    printf 'Usage: %s\n' "$0" >&2
    exit 2
fi

command -v brew >/dev/null 2>&1 || { printf 'Homebrew is not available in PATH.\n' >&2; exit 1; }
exec brew bundle dump --file=- --no-vscode --no-go --no-cargo --no-uv --no-npm --no-krew --no-flatpak --no-winget --no-restart
