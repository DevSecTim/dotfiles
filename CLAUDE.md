# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository containing shell configuration (zsh) and vim settings. Files are designed to be symlinked into `$HOME`.

## File Structure

- `.zprofile` — Login shell setup: PATH construction, environment variables, language version managers (pyenv, jenv, luarocks), Homebrew, and OS-specific config (macOS/Linux)
- `.zshrc` — Interactive shell setup: Oh My Zsh, tool completions (kubectl, terraform, aws, stern, argocd), cloud context aliases, and local overrides from `~/.local/zshrc.d/`
- `.vimrc` — Vim configuration (4-space tabs, 80-char column, syntax highlighting, status line)

## Install / Uninstall

- `./install.sh` — Symlinks all dotfiles into `$HOME`. Existing files are backed up to `~/.dotfiles_backup/<timestamp>/`.
- `./uninstall.sh` — Removes symlinks pointing to this repo and restores the most recent backup.

Both scripts skip `.git`, `CLAUDE.md`, `AGENTS.md`, and the scripts themselves.

## Key Patterns

- **Conditional tool setup**: All tool configuration guards on command existence using `(( $+commands[tool] ))` or `[ -d path ]`. Follow this pattern when adding new tools.
- **`_CTX` accumulator**: Cloud CLI context lines are prepended to `_CTX` and displayed via the `ctx` alias. To add a new cloud/context provider, prepend to `_CTX` inside a guard block.
- **Local overrides**: Machine-specific config goes in `~/.local/zshrc.d/` (sourced by `.zshrc`) — not in this repo.
- **Profile sourcing guard**: `.zshrc` sources `.zprofile` with a `PROFILE_SOURCED` flag to prevent double-sourcing.
- **Cross-platform**: `.zprofile` branches on `$OSTYPE` for macOS vs Linux differences (Homebrew paths, Wine config).
