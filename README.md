# Dotfiles Template

> A minimal, stow-based dotfiles template.

## Quick Start

```bash
git clone https://github.com/JamesHusband/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow -v --target="$HOME" git ssh zsh
```

## Structure

```
dotfiles/
├── git/
│   └── .gitconfig      # Git configuration
├── ssh/
│   └── .ssh/
│       └── config      # SSH configuration  
├── zsh/
│   └── .zshrc          # Zsh configuration
└── README.md
```
