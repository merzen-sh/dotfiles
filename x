#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> 1. Symlinking mise configuration..."
mkdir -p "$HOME/.config/mise"
ln -sfn "$DOTFILES_DIR/mise.toml" "$HOME/.config/mise/mise.toml"

echo "==> 2. Installing system-level packages..."
sudo pacman -S --needed keyd docker docker-compose flatpak paru noctalia mise

echo "==> 3. Running mise tasks..."
# -C Ensure mise executes tasks relative to the dotfiles root directory
mise run -C "$DOTFILES_DIR" install