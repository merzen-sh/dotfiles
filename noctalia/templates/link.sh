#!/usr/bin/env bash
# Symlink every template folder in templates/ into ../community-templates/
# so Noctalia discovers them. Idempotent: existing links are kept, stale
# files/dirs at the target are replaced.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$here/../community-templates"

mkdir -p "$target_dir"

shopt -s nullglob
for src in "$here"/*/; do
    name="$(basename "$src")"
    [ -f "$src/template.toml" ] || { echo "skip    $name (no template.toml)" >&2; continue; }

    target="$target_dir/$name"
    rel="../templates/$name"

    if [ "$(readlink -- "$target" 2>/dev/null)" = "$rel" ]; then
        echo "ok      $name"
        continue
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf -- "$target"
        echo "replaced $name (stale target)"
    fi

    ln -s -- "$rel" "$target"
    echo "linked  $name -> $rel"
done
