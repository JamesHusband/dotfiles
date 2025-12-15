#!/bin/sh
# Entry point: Full system bootstrap for macOS
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting macOS system bootstrap..."

# Run phases in order (post-install and services will be added later)
"$SCRIPT_DIR/packages/install-packages.sh"
"$SCRIPT_DIR/config/config.sh"
"$SCRIPT_DIR/ricing/rice.sh"

echo "macOS system bootstrap complete."

