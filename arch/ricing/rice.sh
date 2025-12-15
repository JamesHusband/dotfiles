#!/bin/sh
# Ricing phase: Apply theming and visual customization
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOME_DIR="$HOME"
SCRIPTS_DIR="$REPO_ROOT/scripts"
SHARED_ASSETS="$REPO_ROOT/shared/assets"

# Source shared utilities
. "$SCRIPTS_DIR/lib.sh"

# ============================================================================
# Utility Functions
# ============================================================================

# Symlink user config files (no sudo required)
link_user() {
    src="$1"
    dst="$HOME_DIR/$2"
    
    [ -e "$src" ] || { log_error "Missing source: $src"; exit 1; }
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"
    
    # Remove existing file/symlink if present
    [ -e "$dst" ] && rm -rf "$dst"
    
    # Create symlink
    ln -sfn "$src" "$dst"
    log_info "Linked $dst -> $src"
}

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
    
    # Create parent directory if needed
    sudo mkdir -p "$(dirname "$dst")"
    
    # Remove existing file/symlink/directory if present
    [ -L "$dst" ] && sudo rm "$dst"
    [ -e "$dst" ] && sudo rm -rf "$dst"
    
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
    if [ -f "$SHARED_ASSETS/wallpapers/login.png" ]; then
        copy_system "$SHARED_ASSETS/wallpapers/login.png" "/usr/share/backgrounds/login.png"
    else
        log_warn "Login background not found: $SHARED_ASSETS/wallpapers/login.png"
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
    
    # Symlink configuration file so it stays repo-driven
    if [ -f "$LIGHTDM_GREETER_DIR/lightdm-gtk-greeter.conf" ]; then
        link_system "$LIGHTDM_GREETER_DIR/lightdm-gtk-greeter.conf" "/etc/lightdm/lightdm-gtk-greeter.conf"
    fi
    
    # Symlink the entire theme directory so the greeter reads assets directly
    # from the repo (gtk.css, images, etc.).
    if [ -d "$LIGHTDM_GREETER_DIR/theme" ]; then
        link_system "$LIGHTDM_GREETER_DIR/theme" "/usr/share/themes/JamGrey"
    fi
}

# Ensure LightDM user can traverse into $HOME and read the greeter theme tree
ensure_lightdm_theme_acls() {
    LIGHTDM_USER="lightdm"
    THEME_DIR="$SCRIPT_DIR/lightdm-greeter/theme"

    # setfacl is required for fine-grained access control
    if ! command -v setfacl >/dev/null 2>&1; then
        log_warn "setfacl not found; skipping LightDM theme ACL configuration."
        return 0
    fi

    # Allow LightDM to traverse into the home directory (no listing)
    if [ -d "$HOME_DIR" ]; then
        sudo setfacl -m "u:${LIGHTDM_USER}:--x" "$HOME_DIR" || \
            log_warn "Failed to set ACL on home directory for ${LIGHTDM_USER}"
    fi

    # Allow LightDM to read the theme tree in the repo (gtk.css + assets)
    if [ -d "$THEME_DIR" ]; then
        sudo setfacl -R -m "u:${LIGHTDM_USER}:rX" "$THEME_DIR" || \
            log_warn "Failed to set recursive ACLs on theme directory for ${LIGHTDM_USER}"
        # Default ACLs so new files inherit access
        sudo setfacl -R -m "d:u:${LIGHTDM_USER}:rX" "$THEME_DIR" || \
            log_warn "Failed to set default ACLs on theme directory for ${LIGHTDM_USER}"
    fi
}

# Apply dunst notification daemon configuration
config_dunst() {
    log_info "Setting up dunst configuration..."
    
    DUNST_DIR="$SCRIPT_DIR/dunst"
    [ -d "$DUNST_DIR" ] || return 0
    
    if [ -f "$DUNST_DIR/dunstrc" ]; then
        link_user "$DUNST_DIR/dunstrc" ".config/dunst/dunstrc"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_info "Starting ricing phase..."
    
    # Copy shared assets first (needed by LightDM greeter)
    copy_assets
    
    # Ensure LightDM can read the repo-backed greeter theme, then configure it
    ensure_lightdm_theme_acls
    config_lightdm_greeter
    
    # Configure dunst notification daemon
    config_dunst
    
    # Additional ricing components can be added here:
    # - GTK themes
    # - Icon sets
    # - Other visual customizations
    
    log_info "Ricing phase completed."
}

main
