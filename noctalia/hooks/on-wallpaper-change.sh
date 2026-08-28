#!/usr/bin/env bash
set -euo pipefail

wall_path="${NOCTALIA_WALLPAPER_PATH:-}"
connector="${NOCTALIA_WALLPAPER_CONNECTOR:-all}"

logger -t noctalia-hook "Wallpaper updated on [$connector] -> $wall_path"
