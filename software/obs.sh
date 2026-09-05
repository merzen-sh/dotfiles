#!/usr/bin/env bash

set -Eeuo pipefail

# =============================================================================
# Configuration
# =============================================================================

readonly OBS_FLATPAK_ID="com.obsproject.Studio"
readonly FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

readonly REQUIRED_PKGS=(
    flatpak
    pipewire
    wireplumber
    xdg-desktop-portal
    libva-utils
)

# =============================================================================
# Colors
# =============================================================================

if [[ -t 1 ]]; then
    readonly BOLD='\033[1m'
    readonly GREEN='\033[0;32m'
    readonly BLUE='\033[0;34m'
    readonly YELLOW='\033[0;33m'
    readonly RED='\033[0;31m'
    readonly NC='\033[0m'
else
    readonly BOLD=''
    readonly GREEN=''
    readonly BLUE=''
    readonly YELLOW=''
    readonly RED=''
    readonly NC=''
fi

# =============================================================================
# Logging
# =============================================================================

log() {
    printf '[INFO] %s\n' "$1"
}

success() {
    printf "${GREEN}[ OK ]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1" >&2
}

error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# =============================================================================
# Error Handling
# =============================================================================

on_error() {
    local exit_code=$?
    error "Setup failed at line ${BASH_LINENO[0]}."
    exit "$exit_code"
}

trap on_error ERR

# =============================================================================
# Require Commands
# =============================================================================

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Required command not found: ${command_name}"
        exit 1
    fi
}

# =============================================================================
# Environment Checks
# =============================================================================

echo
echo -e "${BLUE}${BOLD}=== Arch Linux Wayland OBS Setup ===${NC}"
echo

if [[ ! -f /etc/arch-release ]]; then
    warn "This script is intended for Arch Linux."
    exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
    error "Do not run this script as root."
    error "Run it as your normal user."
    exit 1
fi

require_command pacman
require_command sudo

sudo -v

success "Arch Linux and sudo detected."

# =============================================================================
# Wayland Check
# =============================================================================

if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
    success "Wayland session detected."
else
    warn "Current session is not detected as Wayland."
    warn "Detected: ${XDG_SESSION_TYPE:-unknown}"
fi

# =============================================================================
# 1. System Packages
# =============================================================================

echo
echo -e "${BOLD}[1/4] Checking system packages...${NC}"

MISSING_PKGS=()

for pkg in "${REQUIRED_PKGS[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
        success "$pkg is installed."
    else
        MISSING_PKGS+=("$pkg")
        warn "$pkg is missing."
    fi
done

if (( ${#MISSING_PKGS[@]} > 0 )); then
    echo
    log "Installing missing packages:"
    printf '  %s\n' "${MISSING_PKGS[@]}"

    sudo pacman -S --needed -- "${MISSING_PKGS[@]}"

    echo
    success "System packages installed."
else
    success "All required system packages are installed."
fi

# =============================================================================
# 2. PipeWire / WirePlumber
# =============================================================================

echo
echo -e "${BOLD}[2/4] Checking PipeWire...${NC}"

if systemctl --user is-active --quiet pipewire.service; then
    success "PipeWire is running."
else
    warn "PipeWire is not currently running."

    if systemctl --user cat pipewire.service >/dev/null 2>&1; then
        log "Starting PipeWire..."
        systemctl --user start pipewire.service
    else
        warn "pipewire.service is not available in the user systemd session."
    fi
fi

if systemctl --user is-active --quiet wireplumber.service; then
    success "WirePlumber is running."
else
    warn "WirePlumber is not currently running."

    if systemctl --user cat wireplumber.service >/dev/null 2>&1; then
        log "Starting WirePlumber..."
        systemctl --user start wireplumber.service
    else
        warn "wireplumber.service is not available in the user systemd session."
    fi
fi

# =============================================================================
# 3. Flathub
# =============================================================================

echo
echo -e "${BOLD}[3/4] Configuring Flathub...${NC}"

if ! command -v flatpak >/dev/null 2>&1; then
    error "Flatpak is not available after package installation."
    exit 1
fi

if flatpak remote-list | awk '{print $1}' | grep -qx "flathub"; then
    success "Flathub is already configured."
else
    log "Adding Flathub..."

    flatpak remote-add \
        --if-not-exists \
        flathub \
        "$FLATHUB_URL"

    success "Flathub added."
fi

# =============================================================================
# 4. OBS Studio
# =============================================================================

echo
echo -e "${BOLD}[4/4] Installing OBS Studio...${NC}"

if flatpak info "$OBS_FLATPAK_ID" >/dev/null 2>&1; then
    success "OBS Studio Flatpak is already installed."

    log "Checking for OBS updates..."

    flatpak update \
        -y \
        "$OBS_FLATPAK_ID"

    success "OBS Studio is up to date."
else
    log "OBS Studio Flatpak not found."
    log "Installing from Flathub..."

    flatpak install \
        -y \
        flathub \
        "$OBS_FLATPAK_ID"

    success "OBS Studio installed."
fi

# =============================================================================
# Verification
# =============================================================================

echo
echo -e "${BOLD}=== Verification ===${NC}"

# OBS
if flatpak info "$OBS_FLATPAK_ID" >/dev/null 2>&1; then
    success "OBS Studio: installed."
else
    error "OBS Studio: installation could not be verified."
    exit 1
fi

# PipeWire
if command -v wpctl >/dev/null 2>&1; then
    if wpctl status >/dev/null 2>&1; then
        success "PipeWire audio graph: available."
    else
        warn "wpctl exists but PipeWire is not responding."
    fi
else
    warn "wpctl is not available."
fi

# xdg-desktop-portal
if systemctl --user is-active --quiet xdg-desktop-portal.service; then
    success "xdg-desktop-portal: running."
else
    warn "xdg-desktop-portal is not currently running."
fi

# VA-API
if command -v vainfo >/dev/null 2>&1; then
    if vainfo >/dev/null 2>&1; then
        success "VA-API: available."
    else
        warn "vainfo is installed but VA-API could not be initialized."
    fi
else
    warn "vainfo is not available."
fi

# =============================================================================
# Complete
# =============================================================================

echo
echo -e "${BLUE}${BOLD}=== Setup Complete ===${NC}"
echo

log "OBS Studio:"
echo "    flatpak run ${OBS_FLATPAK_ID}"

echo
log "Useful commands:"
echo "    flatpak update"
echo "    systemctl --user status pipewire"
echo "    systemctl --user status wireplumber"
echo "    systemctl --user status xdg-desktop-portal"

echo
success "Wayland OBS environment is ready."
