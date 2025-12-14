#!/bin/sh
set -eu

# Arch Linux installation entry point
# Orchestrates all installation phases

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$REPO_ROOT/shared/scripts/lib.sh"

log_info "Starting Arch Linux installation..."

# Preflight checks
log_info "Running preflight checks..."
# TODO: Add preflight checks (OS detection, permissions, etc.)

# Phase 1: Update
log_info "Phase 1: System updates"
"$SCRIPT_DIR/post-install/update.sh"

# Phase 2: Post-install
log_info "Phase 2: Post-install tasks"
"$SCRIPT_DIR/post-install/post-install.sh"

# Phase 3: Packages
log_info "Phase 3: Package installation"
"$SCRIPT_DIR/packages/install-packages.sh"

# Phase 4: Services
log_info "Phase 4: Service enablement"
"$SCRIPT_DIR/services/enable-services.sh"

# Phase 5: Config
log_info "Phase 5: Configuration"
"$SCRIPT_DIR/config/config.sh"

# Phase 6: Ricing
log_info "Phase 6: Ricing and visual customization"
"$SCRIPT_DIR/ricing/rice.sh"

# Postflight
log_success "Arch Linux installation complete!"
