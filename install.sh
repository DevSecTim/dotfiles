#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Files to install: "repo-relative-source:absolute-target"
FILES=(
    "dots/zshrc:$HOME/.zshrc"
    "dots/vimrc:$HOME/.vimrc"
    "dots/tmux.conf:$HOME/.tmux.conf"
    "dots/gitconfig:$HOME/.gitconfig"
    "dots/gitconfig.d/personal:$HOME/.gitconfig.d/personal"
    "dots/gitconfig.d/synechron:$HOME/.gitconfig.d/synechron"
    "dots/ssh/config:$HOME/.ssh/config"
)

backed_up=0
linked=0
skipped=0

for entry in "${FILES[@]}"; do
    src="$DOTFILES_DIR/${entry%%:*}"
    target="${entry##*:}"

    # Already correctly linked
    if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
        echo "skip    $target (already linked)"
        ((skipped++))
        continue
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    # Back up existing file or stale symlink
    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
        echo "backup  $target -> $BACKUP_DIR/$(basename "$target")"
        ((backed_up++))
    fi

    ln -s "$src" "$target"
    echo "link    $target -> $src"
    ((linked++))
done

# SSH directory (required before config symlink is used)
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
mkdir -p "$HOME/.config/ssh_config.d"

# Vim runtime directories
mkdir -p "$HOME/.vim/undo" "$HOME/.vim/backup" "$HOME/.vim/swap"

echo ""
echo "Done: $linked linked, $backed_up backed up, $skipped already current."
[[ $backed_up -gt 0 ]] && echo "Backups saved to $BACKUP_DIR"
