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
        [ -f "$SHARED_CONFIG/shell/zsh/.p10k.zsh" ] && \
            link_user "$SHARED_CONFIG/shell/zsh/.p10k.zsh" ".p10k.zsh"
        
        # Symlink oh-my-zsh directory if it exists
        if [ -d "$SHARED_CONFIG/shell/zsh/.oh-my-zsh" ]; then
            ohmyzsh_dst="$HOME_DIR/.oh-my-zsh"
            
            # Backup existing directory if it exists and is not a symlink
            if [ -e "$ohmyzsh_dst" ] && [ ! -L "$ohmyzsh_dst" ]; then
                log_info "Backing up existing: $ohmyzsh_dst"
                mv "$ohmyzsh_dst" "${ohmyzsh_dst}.bak.$(date +%Y%m%d_%H%M%S)"
            fi
            
            # Create parent directory if needed
            mkdir -p "$(dirname "$ohmyzsh_dst")"
            
            # Remove existing symlink if present
            [ -L "$ohmyzsh_dst" ] && rm "$ohmyzsh_dst"
            
            # Create symlink
            ln -sfn "$SHARED_CONFIG/shell/zsh/.oh-my-zsh" "$ohmyzsh_dst"
            log_info "Linked $ohmyzsh_dst -> $SHARED_CONFIG/shell/zsh/.oh-my-zsh"
        fi
    fi
    
    # Bash
    if [ -d "$SHARED_CONFIG/shell/bash" ]; then
        [ -f "$SHARED_CONFIG/shell/bash/.bash_profile" ] && \
            link_user "$SHARED_CONFIG/shell/bash/.bash_profile" ".bash_profile"
        [ -f "$SHARED_CONFIG/shell/bash/.bashrc" ] && \
            link_user "$SHARED_CONFIG/shell/bash/.bashrc" ".bashrc"
    fi
}

