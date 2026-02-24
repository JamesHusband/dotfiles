# Dotfiles Template

> A minimal, stow-based dotfiles template.

## Quick Start

1. Click **"Use this template"** above to create your own dotfiles repo
2. Clone your new repo and customize the configs
3. Deploy with GNU Stow:

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
