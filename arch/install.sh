#!/bin/sh
set -eu

BASE="$HOME/development/dotphials/arch"

"$BASE/system/install.sh"
"$BASE/config/link.sh"
"$BASE/lightdm-greeter/install.sh"

echo "Arch greeter setup complete."