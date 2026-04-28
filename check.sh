#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
    printf 'Usage: %s\n' "$0" >&2
    exit 2
fi

command -v brew >/dev/null 2>&1 || { printf 'Homebrew is not available in PATH.\n' >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec brew bundle check --file="$SCRIPT_DIR/Brewfile" --no-upgrade --verbose
