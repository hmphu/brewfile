#!/usr/bin/env python3
import os
import re
import shutil
import subprocess

BREWFILE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Brewfile")
CASKROOM_PATHS = ["/usr/local/Caskroom", "/opt/homebrew/Caskroom"]


def get_brewfile_casks():
    with open(BREWFILE_PATH) as f:
        casks = set()
        for line in f:
            line = line.strip()
            if line.startswith("cask ") and not line.startswith("#"):
                match = re.match(r'^cask\s+"([^"]+)"', line)
                if match:
                    casks.add(match.group(1).rsplit("/", 1)[-1])
        return casks


def get_installed_casks():
    casks = set()
    for path in CASKROOM_PATHS:
        if os.path.isdir(path):
            casks.update(d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d)))
    return casks


import shutil


def main():
    brewfile_casks = get_brewfile_casks()
    installed_casks = get_installed_casks()
    orphans = sorted(installed_casks - brewfile_casks)

    if not orphans:
        print("No orphaned casks found.")
        return

    print(f"Found {len(orphans)} cask(s) not in Brewfile:")
    for cask in orphans:
        print(f"  - {cask}")

    confirm = input("\nRemove these casks? [y/N]: ").strip().lower()
    if confirm != "y":
        print("Aborted.")
        return

    for cask in orphans:
        print(f"Removing {cask}...")
        result = subprocess.run(["brew", "uninstall", "--cask", cask], capture_output=True)
        if result.returncode != 0:
            for path in CASKROOM_PATHS:
                cask_dir = os.path.join(path, cask)
                if os.path.isdir(cask_dir):
                    shutil.rmtree(cask_dir)
                    print(f"  Removed folder: {cask_dir}")

    print("Done.")


if __name__ == "__main__":
    main()
