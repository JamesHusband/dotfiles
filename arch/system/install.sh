#!/bin/sh
set -eu

MANIFEST="$(cd "$(dirname "$0")" && pwd)/manifest.txt"

[ -f "$MANIFEST" ] || { echo "Missing manifest: $MANIFEST"; exit 1; }

echo "Installing system packages from manifest:"
grep -Ev '^\s*#|^\s*$' "$MANIFEST"

sudo pacman -S --needed $(grep -Ev '^\s*#|^\s*$' "$MANIFEST")

echo "System packages installed."