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
        ohmyzsh_src="$SHARED_CONFIG/shell/zsh/.oh-my-zsh"
        log_info "Checking for .oh-my-zsh at: $ohmyzsh_src"
        if [ -d "$ohmyzsh_src" ]; then
            log_info "Found .oh-my-zsh directory, creating symlink..."
            ohmyzsh_dst="$HOME_DIR/.oh-my-zsh"
            
            # Backup existing directory if it exists and is not a symlink
            if [ -e "$ohmyzsh_dst" ] && [ ! -L "$ohmyzsh_dst" ]; then
                log_info "Backing up existing: $ohmyzsh_dst"
                backup_name="${ohmyzsh_dst}.bak.$(date +%Y%m%d_%H%M%S)"
                if mv "$ohmyzsh_dst" "$backup_name" 2>/dev/null; then
                    log_info "Backed up to: $backup_name"
                else
                    log_error "Failed to backup existing .oh-my-zsh directory. Please remove it manually."
                    log_warn "Skipping .oh-my-zsh symlink creation due to backup failure."
                    return 0
                fi
            fi
            
            # Create parent directory if needed
            mkdir -p "$(dirname "$ohmyzsh_dst")"
            
            # Remove existing symlink if present
            [ -L "$ohmyzsh_dst" ] && rm "$ohmyzsh_dst"
            
            # Remove existing directory if present (shouldn't happen after backup, but just in case)
            [ -d "$ohmyzsh_dst" ] && [ ! -L "$ohmyzsh_dst" ] && rm -rf "$ohmyzsh_dst"
            
            # Create symlink with absolute path
            ohmyzsh_src_abs="$(cd "$(dirname "$ohmyzsh_src")" && pwd)/$(basename "$ohmyzsh_src")"
            if ln -sfn "$ohmyzsh_src_abs" "$ohmyzsh_dst"; then
                log_info "Linked $ohmyzsh_dst -> $ohmyzsh_src_abs"
            else
                log_error "Failed to create symlink: $ohmyzsh_dst -> $ohmyzsh_src_abs"
                return 0
            fi
            
            # Verify the symlink was created correctly
            if [ -L "$ohmyzsh_dst" ] && [ -d "$ohmyzsh_dst" ]; then
                log_info "Verified .oh-my-zsh symlink is working correctly"
            else
                log_error "Symlink created but verification failed. Check: $ohmyzsh_dst"
                return 0
            fi
        else
            log_warn ".oh-my-zsh directory not found at: $ohmyzsh_src"
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

