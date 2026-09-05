#!/usr/bin/env bash

set -Eeuo pipefail

# =============================================================================
# Configuration
# =============================================================================

readonly DOTFILES_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

readonly MISE_CONFIG_SOURCE="${DOTFILES_DIR}/mise.toml"
readonly MISE_CONFIG_DIR="${HOME}/.config/mise"
readonly MISE_CONFIG_TARGET="${MISE_CONFIG_DIR}/mise.toml"

readonly COMMON_PACKAGES=(
    mise
    ttf-cascadia-mono-nerd
    cargo
)

readonly DESKTOP_PACKAGES=(
    keyd
    docker
    docker-compose
    flatpak
    paru
    noctalia
)

# =============================================================================
# Logging
# =============================================================================

log() {
    printf '[INFO] %s\n' "$1"
}

success() {
    printf '[ OK ] %s\n' "$1"
}

warn() {
    printf '[WARN] %s\n' "$1" >&2
}

error() {
    printf '[ERROR] %s\n' "$1" >&2
}

# =============================================================================
# Error Handling
# =============================================================================

on_error() {
    local exit_code=$?

    error "Bootstrap failed at line ${BASH_LINENO[0]}."

    exit "$exit_code"
}

trap on_error ERR

# =============================================================================
# Environment
# =============================================================================

is_wsl() {
    if [[ -n "${WSL_INTEROP:-}" ]]; then
        return 0
    fi

    if [[ -r /proc/version ]] &&
        grep -qiE 'microsoft|wsl' /proc/version; then
        return 0
    fi

    return 1
}

# =============================================================================
# Requirements
# =============================================================================

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Required command not found: ${command_name}"
        exit 1
    fi
}

# =============================================================================
# Header
# =============================================================================

echo
echo "=== Arch Linux Dotfiles Bootstrap ==="
echo

log "Dotfiles directory: ${DOTFILES_DIR}"

if is_wsl; then
    log "Environment: WSL"
else
    log "Environment: Native Linux"
fi

# =============================================================================
# Basic Checks
# =============================================================================

if [[ ! -f /etc/arch-release ]]; then
    error "This script is intended for Arch Linux."
    exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
    error "Do not run this script as root."
    error "Run it as your normal user."
    exit 1
fi

require_command pacman
require_command sudo
require_command mise

sudo -v

# =============================================================================
# 1. Symlink mise configuration
# =============================================================================

echo
echo "[1/3] Configuring mise..."

if [[ ! -f "$MISE_CONFIG_SOURCE" ]]; then
    error "mise.toml not found:"
    error "  ${MISE_CONFIG_SOURCE}"
    exit 1
fi

mkdir -p "$MISE_CONFIG_DIR"

if [[ -L "$MISE_CONFIG_TARGET" ]]; then
    CURRENT_TARGET="$(readlink "$MISE_CONFIG_TARGET")"

    if [[ "$CURRENT_TARGET" == "$MISE_CONFIG_SOURCE" ]]; then
        success "mise.toml is already linked."
    else
        log "Updating existing mise.toml symlink..."

        ln -sfn \
            "$MISE_CONFIG_SOURCE" \
            "$MISE_CONFIG_TARGET"

        success "mise.toml symlink updated."
    fi

elif [[ -e "$MISE_CONFIG_TARGET" ]]; then
    warn "Existing mise.toml found:"
    warn "  ${MISE_CONFIG_TARGET}"

    BACKUP_PATH="${MISE_CONFIG_TARGET}.backup.$(date +%Y%m%d-%H%M%S)"

    mv \
        "$MISE_CONFIG_TARGET" \
        "$BACKUP_PATH"

    log "Backup created:"
    log "  ${BACKUP_PATH}"

    ln -s \
        "$MISE_CONFIG_SOURCE" \
        "$MISE_CONFIG_TARGET"

    success "mise.toml linked."

else
    ln -s \
        "$MISE_CONFIG_SOURCE" \
        "$MISE_CONFIG_TARGET"

    success "mise.toml linked."
fi

# =============================================================================
# 2. System packages
# =============================================================================

echo
echo "[2/3] Installing system packages..."

log "Refreshing Arch Linux package database..."

sudo pacman \
    -Syu \
    --noconfirm

if is_wsl; then
    log "Installing common packages for WSL..."

    sudo pacman \
        -S \
        --needed \
        --noconfirm \
        "${COMMON_PACKAGES[@]}"

else
    log "Installing common packages..."

    sudo pacman \
        -S \
        --needed \
        --noconfirm \
        "${COMMON_PACKAGES[@]}"

    log "Installing desktop packages..."

    sudo pacman \
        -S \
        --needed \
        --noconfirm \
        "${DESKTOP_PACKAGES[@]}"
fi

success "System packages installed."

# =============================================================================
# 3. mise
# =============================================================================

echo
echo "[3/3] Running mise..."

require_command mise

log "Installing mise tools..."

mise run \
    --raw \
    -C "$DOTFILES_DIR" \
    install

success "mise setup completed."

# =============================================================================
# Complete
# =============================================================================

echo
echo "=== Bootstrap Complete ==="
echo

success "Dotfiles bootstrap finished successfully."

echo
log "Next steps:"
echo "  1. Restart your shell."
echo "  2. Verify mise:"
echo "       mise doctor"
echo "  3. Verify installed tools:"
echo "       mise ls"
echo
