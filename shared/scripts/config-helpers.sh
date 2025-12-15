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

