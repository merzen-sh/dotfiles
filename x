#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> 1. Symlinking mise configuration..."
mkdir -p "$HOME/.config/mise"
ln -sfn "$DOTFILES_DIR/mise.toml" "$HOME/.config/mise/mise.toml"

echo "==> 2. Installing system-level packages..."

sudo pacman -Syu --noconfirm

shared_packages="mise ttf-cascadia-mono-nerd cargo --noconfirm"

# Check if running inside WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "==> 3. Installing WSL specific packages..."
    sudo pacman -S --needed $shared_packages
else
    echo "==> 3. Installing Arch specific packages..."
    sudo pacman -S --needed keyd docker docker-compose flatpak paru noctalia $shared_packages
fi

echo "==> 4. Running mise tasks..."
# -C Ensure mise executes tasks relative to the dotfiles root directory
mise run --raw -C "$DOTFILES_DIR" install
