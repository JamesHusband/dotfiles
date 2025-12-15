#!/bin/sh
# Config phase: Config orchestration
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
HOME_DIR="$HOME"

# Source shared utilities
. "$SCRIPTS_DIR/lib.sh"
. "$SCRIPTS_DIR/config-helpers.sh"

# ============================================================================
# Utility Functions
# ============================================================================

# Symlink user config files (no sudo required)
link_user() {
    src="$1"
    dst="$HOME_DIR/$2"
    
    [ -e "$src" ] || { log_error "Missing source: $src"; exit 1; }
    
    # Backup existing file if it exists and is not a symlink
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        log_info "Backing up existing: $dst"
        mv "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"
    
    # Remove existing symlink if present
    [ -L "$dst" ] && rm "$dst"
    
    # Create symlink
    ln -sfn "$src" "$dst"
    log_info "Linked $dst -> $src"
}

# ============================================================================
# Configuration Functions
# ============================================================================

# Apply macOS defaults (system preferences)
config_defaults() {
    log_info "Applying macOS defaults..."
    
    DEFAULTS_DIR="$SCRIPT_DIR/defaults"
    [ -d "$DEFAULTS_DIR" ] || return 0
    
    # Apply each defaults file
    for defaults_file in "$DEFAULTS_DIR"/*.sh; do
        [ -f "$defaults_file" ] || continue
        [ -x "$defaults_file" ] || chmod +x "$defaults_file"
        
        log_info "Applying defaults from: $(basename "$defaults_file")"
        "$defaults_file" || log_warn "Failed to apply defaults from: $(basename "$defaults_file")"
    done
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_info "Starting configuration phase..."
    
    # Apply shared configs first (git, shell, terminal)
    apply_shared_configs "$REPO_ROOT" "$HOME_DIR"
    
    # Apply OS-specific configs
    log_info "Applying macOS-specific configurations..."
    config_defaults
    
    log_info "Configuration phase completed."
}

main

