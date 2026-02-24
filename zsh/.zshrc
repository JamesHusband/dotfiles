# =============================================================================
# Zsh Configuration
# =============================================================================

# Path to Oh My Zsh installation (if using)
export ZSH="$HOME/.oh-my-zsh"

# Theme (if using Oh My Zsh)
ZSH_THEME="robbyrussell"

# Plugins (if using Oh My Zsh)
plugins=(
    git
    docker
    kubectl
    # zsh-autosuggestions
    # zsh-syntax-highlighting
)

# Load Oh My Zsh (if installed)
[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# =============================================================================
# Environment Variables
# =============================================================================

export EDITOR="vim"
export VISUAL="$EDITOR"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Homebrew (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew (Intel)
if [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# =============================================================================
# Aliases
# =============================================================================

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"

# List files
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

# Safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Git shortcuts
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate -20"

# Docker shortcuts
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias di="docker images"

# Kubernetes shortcuts
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"

# Quick edit
alias zshrc="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc"

# =============================================================================
# Functions
# =============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# =============================================================================
# Path
# =============================================================================

# Add custom paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Node.js (if using nvm)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# =============================================================================
# Local Configuration
# =============================================================================

# Load local config if exists (for machine-specific settings)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
