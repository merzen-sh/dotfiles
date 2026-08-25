#!/usr/bin/env bash

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}=== CachyOS OBS Studio (Flatpak + Wayland) Setup ===${NC}\n"

# 1. Install Flatpak if not present
echo -e "${BOLD}[1/4] Checking Flatpak installation...${NC}"
if ! command -v flatpak &> /dev/null; then
    echo -e "${YELLOW}Flatpak not found. Installing flatpak...${NC}"
    sudo pacman -S --needed --noconfirm flatpak
fi

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. Install OBS Studio via Flatpak
echo -e "\n${BOLD}[2/4] Installing OBS Studio from Flathub...${NC}"
flatpak install --or-update -y flathub com.obsproject.Studio

# 3. Grant Flatpak permissions for PipeWire & Wayland
echo -e "\n${BOLD}[3/4] Configuring Flatpak permissions...${NC}"
flatpak override --user com.obsproject.Studio \
    --socket=wayland \
    --socket=fallback-x11 \
    --device=all \
    --filesystem=host

# 4. Create Launcher Script in ~/.local/bin
echo -e "\n${BOLD}[4/4] Creating launcher script and updating PATH...${NC}"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

LAUNCHER_PATH="$LOCAL_BIN/obs-wayland"
cat << 'EOF' > "$LAUNCHER_PATH"
#!/usr/bin/env bash

export QT_QPA_PLATFORM=wayland
export OBS_VK_CAPTURE=1

exec flatpak run com.obsproject.Studio "$@"
EOF

chmod +x "$LAUNCHER_PATH"

# Ensure ~/.local/bin is in PATH
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if [ -n "$SHELL_CONFIG" ]; then
    if ! grep -qsF "$PATH_LINE" "$SHELL_CONFIG"; then
        echo "" >> "$SHELL_CONFIG"
        echo '# Added by OBS Flatpak setup' >> "$SHELL_CONFIG"
        echo "$PATH_LINE" >> "$SHELL_CONFIG"
    fi
fi

# Create Desktop Shortcut
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat << EOF > "$DESKTOP_DIR/obs-wayland.desktop"
[Desktop Entry]
Type=Application
Name=OBS Studio (Flatpak Wayland)
Comment=OBS Studio via Flatpak for Wayland & NVENC
Exec=$LAUNCHER_PATH %U
Icon=com.obsproject.Studio
Terminal=false
Categories=AudioVideo;Recorder;
StartupWMClass=obs
EOF

chmod +x "$DESKTOP_DIR/obs-wayland.desktop"

echo -e "\n${GREEN}${BOLD}=== Setup Complete! ===${NC}"
echo -e "Run ${BOLD}source ~/.bashrc${NC} (or ${BOLD}source ~/.zshrc${NC}), then type ${BOLD}obs-wayland${NC} to start."
