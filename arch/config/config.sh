#!/bin/sh
# Config phase: Config orchestration
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SHARED_SCRIPTS="$REPO_ROOT/shared/scripts"
HOME_DIR="$HOME"

# Source shared utilities
. "$SHARED_SCRIPTS/lib.sh"
. "$SHARED_SCRIPTS/config-helpers.sh"

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

# Symlink system config files (requires sudo)
link_system() {
    src="$1"
    dst="$2"
    
    [ -e "$src" ] || { log_error "Missing source: $src"; exit 1; }
    
    # Backup existing file if it exists and is not a symlink
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        log_info "Backing up existing: $dst"
        sudo mv "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create parent directory if needed
    sudo mkdir -p "$(dirname "$dst")"
    
    # Remove existing symlink if present
    [ -L "$dst" ] && sudo rm "$dst"
    
    # Create symlink
    sudo ln -sfn "$src" "$dst"
    log_info "Linked $dst -> $src"
}

# ============================================================================
# Configuration Functions
# ============================================================================

# Apply X11 configurations
config_x11() {
    log_info "Applying X11 configurations..."
    
    if [ -f "$SCRIPT_DIR/x11/.xprofile" ]; then
        link_user "$SCRIPT_DIR/x11/.xprofile" ".xprofile"
    fi
}

# Apply Xmodmap configuration
config_xmodmap() {
    log_info "Applying Xmodmap configuration..."
    
    if [ -f "$SCRIPT_DIR/xmodmap/.Xmodmap" ]; then
        link_user "$SCRIPT_DIR/xmodmap/.Xmodmap" ".Xmodmap"
    fi
}

# Apply LightDM configurations
config_lightdm() {
    log_info "Applying LightDM configurations..."
    
    LIGHTDM_DIR="$SCRIPT_DIR/lightdm"
    [ -d "$LIGHTDM_DIR" ] || return 0
    
    # Symlink main configuration file
    if [ -f "$LIGHTDM_DIR/lightdm.conf" ]; then
        link_system "$LIGHTDM_DIR/lightdm.conf" "/etc/lightdm/lightdm.conf"
    fi
    
    # Symlink helper scripts to /usr/local/bin
    if [ -d "$LIGHTDM_DIR/scripts" ]; then
        for script in "$LIGHTDM_DIR/scripts"/*; do
            [ -f "$script" ] && [ -x "$script" ] || continue
            script_name="$(basename "$script")"
            link_system "$script" "/usr/local/bin/$script_name"
            sudo chmod +x "/usr/local/bin/$script_name"
        done
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_info "Starting configuration phase..."
    
    # Apply shared configs first (git, shell)
    apply_shared_configs "$REPO_ROOT" "$HOME_DIR"
    
    # Apply OS-specific configs
    log_info "Applying Arch-specific configurations..."
    config_x11
    config_xmodmap
    config_lightdm
    
    log_info "Configuration phase completed."
}

main
