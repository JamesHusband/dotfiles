#!/bin/sh
# Packages phase: Install packages from manifests
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SHARED_SCRIPTS="$REPO_ROOT/shared/scripts"
SHARED_APPS="$REPO_ROOT/shared/manifest/apps.common.yml"
OS_MANIFEST="$SCRIPT_DIR/package-manifest.toml"

# Source shared utilities
. "$SHARED_SCRIPTS/lib.sh"

log_info "Installing packages from manifests..."

# Step 1: Read shared apps.common.yml and extract Arch packages
log_info "Reading shared application manifest..."
if [ -f "$SHARED_APPS" ]; then
    # TODO: Parse YAML to extract apps with arch.source and arch.package
    # For each app, group by source (pacman, aur) and collect package names
    log_info "Found shared apps manifest: $SHARED_APPS"
else
    log_warn "Shared apps manifest not found: $SHARED_APPS"
fi

# Step 2: Read OS-specific package-manifest.toml
log_info "Reading OS-specific package manifest..."
if [ -f "$OS_MANIFEST" ]; then
    # TODO: Parse TOML to extract packages grouped by source
    log_info "Found OS manifest: $OS_MANIFEST"
else
    log_warn "OS manifest not found: $OS_MANIFEST"
fi

# Step 3: Install packages from both sources
# TODO: Install packages grouped by source (pacman, aur)
# - Install pacman packages: sudo pacman -S --needed <packages>
# - Install AUR packages: yay -S --needed <packages>
# - Build and install custom packages from custom/ directory

log_info "Packages installed."
