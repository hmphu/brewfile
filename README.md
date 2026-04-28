# Brewfile Package Management

Manage the desired package list in `Brewfile`, then use the Bash scripts to check or apply that list. Edit the file first instead of installing or uninstalling packages directly with `brew`.

## Requirements

- macOS with Homebrew available in `PATH`.
- Bash. Run scripts with `./script.sh` or `bash script.sh`, not `sh script.sh`.
- For `mas` entries: the Mac App Store CLI (`mas`, declared in `Brewfile`) and the appropriate App Store account and app access.

The examples below assume your terminal is in this repository. You can also invoke a script by its full path from another directory; it will still use the `Brewfile` beside the script.

## Commands

| Command | Behavior |
| --- | --- |
| `./check.sh` | Check whether the active Brewfile entries are installed, without requiring upgrades. Does not install or remove packages. |
| `./install.sh` | Install missing Brewfile entries without upgrading existing packages. Does not remove unlisted packages. |
| `./cleanup.sh` | Preview what Homebrew Bundle would remove because it is not declared in Brewfile. Does not uninstall anything. |
| `./cleanup.sh --apply` | Preview cleanup, ask for confirmation, then apply Homebrew Bundle cleanup. |
| `./snapshot.sh` | Print the installed-state snapshot to the terminal without modifying Brewfile. |
| `./trust-taps.sh` | Trust every active tap declared in Brewfile without installing packages or changing the file. |

## Add Packages

Add an active entry to the appropriate section in `Brewfile`. For example:

```ruby
brew "git"
cask "visual-studio-code"
mas "Xcode", id: 497799835
```

For third-party packages, include their tap and qualified package name when needed:

```ruby
tap "ddev/ddev"
brew "ddev/ddev/ddev"
```

Install missing entries, then verify:

```bash
./install.sh
./check.sh
```

Both scripts use `--no-upgrade`. They are not commands for updating all packages to their latest versions.

## Trust Taps

If Homebrew asks you to trust third-party taps, run:

```bash
./trust-taps.sh
./install.sh
```

The script reads active taps using `brew bundle list --tap` and runs `brew trust --tap` for each one. Commented-out taps are ignored, and custom tap URLs remain unchanged. Run it again after adding new taps; `install.sh` does not run it automatically.

**Security:** Tap-wide trust allows Homebrew to load all formulae, casks, and external commands from those taps, including future additions. Only run this for repositories you trust. It updates Homebrew's local trust configuration, not Brewfile; commenting out a tap later does not revoke previously granted trust.

This command requires a Homebrew version that supports `brew trust`. Check availability with `brew trust --help`.

Active taps also declare `trusted: true` in Brewfile. Homebrew Bundle cleanup resets the local trust store to the trust declared in that file, so these declarations preserve tap trust during cleanup. Include `trusted: true` when adding a tap you want to trust persistently.

## Remove Packages

Delete or comment out the relevant entry in `Brewfile`:

```ruby
# cask "spotify"
```

Preview the removal list:

```bash
./cleanup.sh
```

Review the entire list before applying:

```bash
./cleanup.sh --apply
```

Type exactly `yes` at the prompt to continue. Any other response, or end of input, cancels removal.

The script captures the preview with standard input disconnected, preventing Homebrew's own interactive cleanup prompt from performing removals during preview. It accepts Homebrew's expected preview exit status when removals are listed, but stops on other failures. After your confirmation, it runs cleanup with `--force` once.

After applying, the script runs another non-interactive preview and fails if uninstall candidates remain. Homebrew can print an uninstall count even when an underlying uninstall did not remove a package. If the same formula keeps appearing, compare its name with `brew list --formula --full-name`; a renamed formula or changed tap can cause cleanup to target the wrong name. Confirm the installed package is unwanted before uninstalling it by its actual installed name.

**Warning:** Cleanup is not limited to the entry you just edited. It delegates to Homebrew Bundle cleanup for everything outside the manifest, subject to Homebrew's dependency rules. Add any unlisted packages you want to keep before applying cleanup. Do not assume this uninstalls Mac App Store apps; manage their removal through macOS and update their Brewfile entries separately.

## Reconcile Direct Brew Changes

If you have used `brew install` or `brew uninstall` directly, inspect the current installed state:

```bash
./snapshot.sh
```

Compare that output with `Brewfile`:

1. Add installed packages you want to keep that are missing from the file.
2. Delete or comment out entries for packages you intentionally uninstalled.
3. Keep entries for packages you still want, even if they are currently missing; `./install.sh` can install them again.
4. Run `./check.sh` and preview `./cleanup.sh` before applying further changes.

The snapshot is for manual comparison, not automatic merging. It includes Homebrew taps, formulae, casks, and detected Mac App Store apps. It excludes VS Code extensions, Go, Cargo, uv, npm, Krew, Flatpak, and WinGet packages, and omits service restart directives.

Review exported entries before adding them. In particular, do not add a `mas` entry with an invalid App Store ID such as `0`.

**Do not run `./snapshot.sh > Brewfile`.** Shell redirection would overwrite your organized manifest, losing its sections, comments, and commented-out choices.

## Troubleshooting

| Issue | Action |
| --- | --- |
| `Homebrew is not available in PATH.` | Ensure Homebrew is installed and its shell environment is loaded. Confirm with `brew --version`. |
| `Permission denied` when running a script | Use `bash check.sh` or the equivalent script name, or restore executable permissions with the command below. |
| `check.sh` reports missing entries | Run `./install.sh` if they are wanted, or edit Brewfile if they were intentionally removed. |
| Snapshot contains an unexpected package | Decide whether to declare it or remove it; the snapshot does not infer your intent. |

To restore executable permissions:

```bash
chmod +x check.sh install.sh cleanup.sh snapshot.sh trust-taps.sh
```

Use `cleanup.sh` for this workflow rather than `cleanup_casks.py`. The older Python script has a fallback that deletes Caskroom directories after an uninstall failure; the Bash script delegates cleanup to Homebrew instead.
