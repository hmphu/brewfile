#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
    printf 'Usage: %s\n' "$0" >&2
    exit 2
fi

command -v brew >/dev/null 2>&1 || { printf 'Homebrew is not available in PATH.\n' >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
taps="$(brew bundle list --file="$SCRIPT_DIR/Brewfile" --tap)"

if [[ -z "$taps" ]]; then
    printf 'No active taps found in Brewfile.\n'
    exit 0
fi

while IFS= read -r tap; do
    [[ -n "$tap" ]] || continue
    printf 'Trusting tap: %s\n' "$tap"
    brew trust --tap "$tap"
done <<< "$taps"
