#!/usr/bin/env bash

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}=== Arch Linux Wayland OBS Setup ===${NC}\n"

# 1. Check system packages for Wayland capture & Flatpak runtime
REQUIRED_PKGS=(
    flatpak
    pipewire
    wireplumber
    xdg-desktop-portal
    libva-utils
)

echo -e "${BOLD}[1/2] Checking system packages...${NC}"
MISSING_PKGS=()

for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! pacman -Qs "^${pkg}$" > /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -ne 0 ]; then
    echo -e "${RED}Missing packages: ${MISSING_PKGS[*]}${NC}"
    echo "Installing missing dependencies..."
    sudo pacman -S --needed "${MISSING_PKGS[@]}"
else
    echo -e "${GREEN}All base system packages are installed.${NC}"
fi

# 2. Ensure Flathub is added and install OBS Studio Flatpak
echo -e "\n${BOLD}[2/2] Installing OBS Studio Flatpak...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

if ! flatpak info com.obsproject.Studio > /dev/null 2>&1; then
    echo "OBS Studio Flatpak not found. Installing from Flathub..."
    flatpak install -y flathub com.obsproject.Studio
else
    echo -e "${GREEN}OBS Studio Flatpak is already installed.${NC}"
fi

echo -e "\n${BLUE}${BOLD}=== Setup Complete! ===${NC}"
