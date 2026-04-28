#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != '--apply' ) ]]; then
    printf 'Usage: %s [--apply]\n' "$0" >&2
    exit 2
fi

command -v brew >/dev/null 2>&1 || { printf 'Homebrew is not available in PATH.\n' >&2; exit 1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
printf 'Previewing packages not declared in %s/Brewfile:\n' "$SCRIPT_DIR"
preview_status=0
preview="$(brew bundle cleanup --file="$SCRIPT_DIR/Brewfile" </dev/null)" || preview_status=$?
printf '%s\n' "$preview"
if [[ $preview_status -ne 0 ]]; then
    if [[ $preview_status -ne 1 || "$preview" != *'Run `brew bundle cleanup --force` to make these changes.'* ]]; then
        exit "$preview_status"
    fi
fi

if [[ $# -eq 0 ]]; then
    printf '\nPreview only. To uninstall, run: %s --apply\n' "$0"
    exit 0
fi

printf '\nUninstall the packages listed above? Type yes to continue: '
if ! IFS= read -r answer || [[ "$answer" != 'yes' ]]; then
    printf '\nCancelled. No packages were uninstalled.\n'
    exit 0
fi

brew bundle cleanup --file="$SCRIPT_DIR/Brewfile" --force
printf '\nVerifying cleanup completed:\n'
verify_status=0
verification="$(brew bundle cleanup --file="$SCRIPT_DIR/Brewfile" </dev/null)" || verify_status=$?
printf '%s\n' "$verification"
if [[ $verify_status -ne 0 ]]; then
    printf 'Cleanup verification failed. Homebrew may have left packages installed; inspect the output above.\n' >&2
    exit "$verify_status"
fi
