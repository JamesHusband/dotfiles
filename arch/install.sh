#!/bin/sh
set -eu

# Arch Linux installation entry point
# Orchestrates all installation phases

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$REPO_ROOT/scripts/lib.sh"

log_info "Starting Arch Linux installation..."

# Preflight checks
log_info "Running preflight checks..."
# TODO: Add preflight checks (OS detection, permissions, etc.)

# Phase 1: Packages
log_info "Phase 1: Package installation"
"$SCRIPT_DIR/packages/install-packages.sh"

# Phase 2: Config
log_info "Phase 2: Configuration"
"$SCRIPT_DIR/config/config.sh"

# Phase 3: Ricing
log_info "Phase 3: Ricing and visual customization"
"$SCRIPT_DIR/ricing/rice.sh"

# Postflight
log_success "Arch Linux installation complete!"
