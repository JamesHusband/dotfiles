#!/bin/sh
# Ricing phase: Apply theming and visual customization
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
SHARED_ASSETS="$REPO_ROOT/shared/assets"

# Source shared utilities
. "$SCRIPTS_DIR/lib.sh"

# ============================================================================
# Utility Functions
# ============================================================================

# Symlink system files (requires sudo)
link_system() {
    src="$1"
    dst="$2"
    
    [ -e "$src" ] || { log_error "Missing source: $src"; exit 1; }
    
    # Backup existing file/directory if it exists and is not a symlink
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

# Copy system files/directories (requires sudo)
copy_system() {
    src="$1"
    dst="$2"
    
    [ -e "$src" ] || { log_error "Missing source: $src"; exit 1; }
    
    # Backup existing file/directory if it exists and is not a symlink
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        log_info "Backing up existing: $dst"
        sudo mv "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create parent directory if needed
    sudo mkdir -p "$(dirname "$dst")"
    
    # Remove existing symlink or directory if present
    [ -L "$dst" ] && sudo rm "$dst"
    [ -d "$dst" ] && sudo rm -rf "$dst" # Ensure directory is clean for copy
    
    # Copy file/directory
    sudo cp -a "$src" "$dst"
    log_info "Copied $dst <- $src"
}

# ============================================================================
# Ricing Functions
# ============================================================================

# Copy shared assets to system locations
copy_assets() {
    log_info "Copying shared assets to system locations..."
    
    # Ensure /usr/share/backgrounds exists
    sudo mkdir -p "/usr/share/backgrounds"
    
    # Copy login background
    if [ -f "$SHARED_ASSETS/wallpapers/login_3.1.png" ]; then
        copy_system "$SHARED_ASSETS/wallpapers/login_3.1.png" "/usr/share/backgrounds/login_3.1.png"
    else
        log_warn "Login background not found: $SHARED_ASSETS/wallpapers/login_3.1.png"
    fi
    
    # Copy avatar
    if [ -f "$SHARED_ASSETS/avatars/avatar.png" ]; then
        copy_system "$SHARED_ASSETS/avatars/avatar.png" "/usr/share/backgrounds/avatar.png"
    else
        log_warn "Avatar not found: $SHARED_ASSETS/avatars/avatar.png"
    fi
}

# Apply LightDM greeter configuration and theme
config_lightdm_greeter() {
    log_info "Setting up LightDM greeter..."
    
    LIGHTDM_GREETER_DIR="$SCRIPT_DIR/lightdm-greeter"
    [ -d "$LIGHTDM_GREETER_DIR" ] || return 0
    
    # Copy configuration file
    if [ -f "$LIGHTDM_GREETER_DIR/lightdm-gtk-greeter.conf" ]; then
        copy_system "$LIGHTDM_GREETER_DIR/lightdm-gtk-greeter.conf" "/etc/lightdm/lightdm-gtk-greeter.conf"
    fi
    
    # Copy theme directory
    if [ -d "$LIGHTDM_GREETER_DIR/theme" ]; then
        copy_system "$LIGHTDM_GREETER_DIR/theme" "/usr/share/themes/JamGrey"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_info "Starting ricing phase..."
    
    # Copy shared assets first (needed by LightDM greeter)
    copy_assets
    
    # Apply LightDM greeter configuration
    config_lightdm_greeter
    
    # Additional ricing components can be added here:
    # - GTK themes
    # - Icon sets
    # - Other visual customizations
    
    log_info "Ricing phase completed."
}

main
