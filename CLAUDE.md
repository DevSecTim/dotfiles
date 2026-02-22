# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository. All managed files live under `dots/` and are symlinked into `$HOME` by `install.sh`.

## Managed Files

| Source | Target |
|---|---|
| `dots/zshrc` | `~/.zshrc` |
| `dots/vimrc` | `~/.vimrc` |
| `dots/tmux.conf` | `~/.tmux.conf` |
| `dots/gitconfig` | `~/.gitconfig` |
| `dots/gitconfig.d/personal` | `~/.gitconfig.d/personal` |
| `dots/gitconfig.d/synechron` | `~/.gitconfig.d/synechron` |
| `dots/ssh/config` | `~/.ssh/config` |

`install.sh` also creates `~/.config/ssh_config.d/` and `~/.vim/{undo,backup,swap}/`.

> **Note**: `uninstall.sh` currently only removes the first 4 entries (zshrc, vimrc, tmux.conf, gitconfig) — it does not remove the gitconfig.d or ssh/config symlinks.

## Key Patterns

- **Conditional tool setup**: Guard all tool config on command/path existence using `(( $+commands[tool] ))` or `[[ -d path ]]`. Follow this for every new tool added to `dots/zshrc`.

- **`_CTX` accumulator**: Lines are prepended to `_CTX` and printed by the `ctx` alias. Each cloud/context provider appends inside its own guard block. Order of prepending determines display order (last prepended shows first).

- **`_cached_completion`**: Shell function in `dots/zshrc` that regenerates a tool's completion script only when the binary is newer than the cached file (`~/.cache/zsh/<cmd>.zsh`). Use this for slow `<tool> completion zsh` calls.

- **Local overrides (shell)**: Machine-specific shell config goes in `~/.local/zshrc.d/` (glob-sourced at end of `.zshrc`) — not in this repo.

- **Local overrides (SSH)**: Machine-specific SSH hosts go in `~/.config/ssh_config.d/` (included at top of `dots/ssh/config`) — not in this repo.

- **Git identity routing**: `dots/gitconfig` uses `[IncludeIf "gitdir:~/Workspace/..."]` to select the correct user identity and SSH key (`~/.gitconfig.d/personal` or `~/.gitconfig.d/synechron`) based on repo path. Repos outside `~/Projects/` get no identity — add new contexts by adding an `IncludeIf` block and a corresponding `dots/gitconfig.d/<context>` file.

- **Cross-platform**: `dots/zshrc` branches on `$OSTYPE` for macOS vs Linux (Homebrew paths, Wine config). Homebrew prefix is set as a variable to avoid the slow `brew --prefix` subprocess on every shell start.

- **tmux plugins**: `dots/tmux.conf` declares plugins via tpm but the `run tpm` line is commented out. Uncomment the last line after installing tpm (`~/.tmux/plugins/tpm`).
