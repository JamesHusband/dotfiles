#!/bin/sh
# Entry point: Full system bootstrap for macOS
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting macOS system bootstrap..."

# Run phases in order
"$SCRIPT_DIR/post-install/update.sh"
"$SCRIPT_DIR/post-install/post-install.sh"
"$SCRIPT_DIR/packages/install-packages.sh"
"$SCRIPT_DIR/services/enable-services.sh"
"$SCRIPT_DIR/config/config.sh"
"$SCRIPT_DIR/ricing/rice.sh"

echo "macOS system bootstrap complete."

