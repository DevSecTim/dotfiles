#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_BASE="$HOME/.dotfiles_backup"

# Must match FILES in install.sh
FILES=(
    "dots/zshrc:$HOME/.zshrc"
    "dots/vimrc:$HOME/.vimrc"
    "dots/tmux.conf:$HOME/.tmux.conf"
    "dots/gitconfig:$HOME/.gitconfig"
    "dots/ssh-config:$HOME/.ssh/config"
    "dots/claude-settings.json:$HOME/.claude/settings.json"
)

# Find the most recent backup directory
latest_backup=""
if [[ -d "$BACKUP_BASE" ]]; then
    latest_backup="$(ls -1d "$BACKUP_BASE"/*/ 2>/dev/null | sort -r | head -1)"
fi

removed=0
restored=0

for entry in "${FILES[@]}"; do
    src="$DOTFILES_DIR/${entry%%:*}"
    target="${entry##*:}"

    # Only remove symlinks that point into this repo
    if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
        rm "$target"
        echo "unlink  $target"
        ((removed++))

        # Restore from most recent backup if available
        if [[ -n "$latest_backup" && -e "$latest_backup/$(basename "$target")" ]]; then
            mv "$latest_backup/$(basename "$target")" "$target"
            echo "restore $target (from $latest_backup)"
            ((restored++))
        fi
    fi
done

# Clean up empty backup directories
if [[ -d "$BACKUP_BASE" ]]; then
    find "$BACKUP_BASE" -type d -empty -delete 2>/dev/null || true
fi

echo ""
echo "Done: $removed unlinked, $restored restored from backup."
