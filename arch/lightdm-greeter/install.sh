#!/bin/sh
set -eu

THEME_NAME="JamGrey"

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DOTPHIALS_ROOT="$(cd "$REPO_ROOT/../.." && pwd)"  # .../dotphials

THEME_SRC="$REPO_ROOT/theme"
THEME_DST="/usr/share/themes/$THEME_NAME"

ASSETS_SRC="$DOTPHIALS_ROOT/assets"
BG_DST_DIR="/usr/share/backgrounds"

BG_FILE="$BG_DST_DIR/login_3.1.png"
AVATAR_FILE="$BG_DST_DIR/avatar.png"

CONF="/etc/lightdm/lightdm-gtk-greeter.conf"

# sanity checks
[ -d "$THEME_SRC" ] || { echo "Missing theme directory: $THEME_SRC"; exit 1; }
[ -f "$THEME_SRC/index.theme" ] || { echo "index.theme not found in $THEME_SRC"; exit 1; }

[ -f "$ASSETS_SRC/login_3.1.png" ] || { echo "Missing asset: $ASSETS_SRC/login_3.1.png"; exit 1; }
[ -f "$ASSETS_SRC/avatar.png" ] || { echo "Missing asset: $ASSETS_SRC/avatar.png"; exit 1; }

echo "Installing LightDM greeter theme: $THEME_NAME"
sudo rm -rf "$THEME_DST"
sudo cp -a "$THEME_SRC" "$THEME_DST"
echo "Installed theme to $THEME_DST"

echo "Installing greeter assets"
sudo install -d "$BG_DST_DIR"
sudo install -m 0644 "$ASSETS_SRC/login_3.1.png" "$BG_FILE"
sudo install -m 0644 "$ASSETS_SRC/avatar.png"     "$AVATAR_FILE"
echo "Installed assets to $BG_DST_DIR"

echo "Writing $CONF"
sudo install -Dm644 /dev/stdin "$CONF" <<EOF
[greeter]
theme-name = $THEME_NAME
font-name = JetBrains Mono 10
cursor-theme-name = Bibata-Modern-Ice
indicators =
background = $BG_FILE
default-user-image = $AVATAR_FILE
EOF

echo "Done."
echo "Tip: restart LightDM to test: sudo systemctl restart lightdm"