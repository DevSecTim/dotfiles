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
    "dots/ssh-config:$HOME/.ssh/config"
    "dots/claude-settings.json:$HOME/.claude/settings.json"
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

# Oh My Zsh custom plugins
# Format: "org/repo" — cloned into ${ZSH_CUSTOM}/plugins/<repo>
ZSH_CUSTOM_PLUGINS=(
    "ArielTM/zsh-claude-code-shell"
)

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    for plugin_ref in "${ZSH_CUSTOM_PLUGINS[@]}"; do
        plugin_name="${plugin_ref##*/}"
        plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
        if [[ -d "$plugin_dir" ]]; then
            echo "skip    omz plugin $plugin_name (already installed)"
        else
            echo "clone   omz plugin $plugin_name"
            git clone --depth=1 "https://github.com/$plugin_ref" "$plugin_dir"
        fi
    done
fi

# Vim runtime directories
mkdir -p "$HOME/.vim/undo" "$HOME/.vim/backup" "$HOME/.vim/swap"

# Enforce ssh permissions
if [[ -d "$HOME/.ssh" ]]; then
    chmod 700 "$HOME/.ssh"
    [[ -L "$HOME/.ssh/config" ]] && chmod 600 "$HOME/.ssh/config"
fi

echo ""
echo "Done: $linked linked, $backed_up backed up, $skipped already current."
[[ $backed_up -gt 0 ]] && echo "Backups saved to $BACKUP_DIR"
