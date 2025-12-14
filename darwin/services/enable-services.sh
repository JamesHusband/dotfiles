#!/bin/sh
# Services phase: Enable system services
set -eu

SERVICES_FILE="$(cd "$(dirname "$0")" && pwd)/services.toml"

if [ ! -f "$SERVICES_FILE" ]; then
    echo "No services.toml found, skipping service enablement."
    exit 0
fi

echo "Enabling system services..."

# Read services.toml and enable launchd services
# Add service enablement logic here

echo "Services enabled."

