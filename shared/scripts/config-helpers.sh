#!/bin/sh
# Shared configuration helpers for Dot Phials
# Functions for applying shared configs (git, shell) across all OSes

# Apply shared configurations (git, shell, etc.)
# This function should be called from each OS's config.sh script
# Requires: link_user() function to be defined in the calling script
apply_shared_configs() {
    REPO_ROOT="$1"
    HOME_DIR="$2"
    SHARED_CONFIG="$REPO_ROOT/shared/config"
    
    # Detect OS for platform-specific paths
    if [ "$(uname -s)" = "Darwin" ]; then
        PLUGINS_DST="/usr/local/share/zsh/plugins"
    else
        PLUGINS_DST="/usr/share/zsh/plugins"
    fi
    
    log_info "Applying shared configurations..."
    
    # Git configuration
    if [ -f "$SHARED_CONFIG/git/.gitconfig" ]; then
        link_user "$SHARED_CONFIG/git/.gitconfig" ".gitconfig"
    fi
    
    # Shell configurations
    # Zsh
    if [ -d "$SHARED_CONFIG/shell/zsh" ]; then
        [ -f "$SHARED_CONFIG/shell/zsh/.zshrc" ] && \
            link_user "$SHARED_CONFIG/shell/zsh/.zshrc" ".zshrc"
        
        # Copy zsh plugins to system directory
        plugins_src="$SHARED_CONFIG/shell/zsh/plugins"
        if [ -d "$plugins_src" ]; then
            log_info "Copying zsh plugins to system directory: $PLUGINS_DST"
            
            # Backup existing plugins directory if it exists
            if [ -e "$PLUGINS_DST" ] && [ ! -L "$PLUGINS_DST" ]; then
                log_info "Backing up existing: $PLUGINS_DST"
                sudo mv "$PLUGINS_DST" "${PLUGINS_DST}.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || \
                    log_warn "Could not backup existing plugins directory"
            fi
            
            # Remove existing symlink or directory if present
            [ -L "$PLUGINS_DST" ] && sudo rm "$PLUGINS_DST"
            [ -d "$PLUGINS_DST" ] && [ ! -L "$PLUGINS_DST" ] && sudo rm -rf "$PLUGINS_DST"
            
            # Create parent directory if needed
            sudo mkdir -p "$(dirname "$PLUGINS_DST")"
            
            # Copy plugins directory
            if sudo cp -a "$plugins_src" "$PLUGINS_DST"; then
                log_info "Copied zsh plugins to $PLUGINS_DST"
            else
                log_error "Failed to copy zsh plugins to $PLUGINS_DST"
            fi
        fi
    fi
    
    # Bash
    if [ -d "$SHARED_CONFIG/shell/bash" ]; then
        [ -f "$SHARED_CONFIG/shell/bash/.bash_profile" ] && \
            link_user "$SHARED_CONFIG/shell/bash/.bash_profile" ".bash_profile"
        [ -f "$SHARED_CONFIG/shell/bash/.bashrc" ] && \
            link_user "$SHARED_CONFIG/shell/bash/.bashrc" ".bashrc"
    fi
    
    # Terminal configurations
    # Alacritty (Linux/Mac: ~/.config/alacritty/alacritty.toml)
    if [ -f "$SHARED_CONFIG/terminal/alacritty/alacritty.toml" ]; then
        link_user "$SHARED_CONFIG/terminal/alacritty/alacritty.toml" ".config/alacritty/alacritty.toml"
    fi
}

