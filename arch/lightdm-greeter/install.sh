#!/bin/sh
set -eu

THEME_NAME="JamGrey"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_ROOT/theme"
DST="/usr/share/themes/$THEME_NAME"
CONF="/etc/lightdm/lightdm-gtk-greeter.conf"

# sanity checks
[ -d "$SRC" ] || { echo "Missing theme directory: $SRC"; exit 1; }
[ -f "$SRC/index.theme" ] || { echo "index.theme not found"; exit 1; }

echo "Installing LightDM greeter theme: $THEME_NAME"

sudo rm -rf "$DST"
sudo cp -a "$SRC" "$DST"

echo "Installed to $DST"

echo "Configuring LightDM GTK greeter"

if [ ! -f "$CONF" ]; then
  sudo install -Dm644 /dev/stdin "$CONF" <<EOF
[greeter]
theme-name=$THEME_NAME
EOF
else
  if grep -q '^[[]greeter[]]' "$CONF"; then
    # replace or add theme-name under [greeter]
    sudo awk -v theme="$THEME_NAME" '
      BEGIN { in_greeter=0; done=0 }
      /^\[greeter\]/ { print; in_greeter=1; next }
      /^\[/ && in_greeter && !done {
        print "theme-name=" theme
        in_greeter=0; done=1
      }
      in_greeter && /^#?theme-name=/ {
        print "theme-name=" theme
        in_greeter=0; done=1; next
      }
      { print }
      END {
        if (!done) print "theme-name=" theme
      }
    ' "$CONF" | sudo tee "$CONF" > /dev/null
  else
    sudo tee -a "$CONF" > /dev/null <<EOF

[greeter]
theme-name=$THEME_NAME
EOF
  fi
fi

echo "LightDM greeter set to theme '$THEME_NAME'"