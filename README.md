# Dotfiles Template

> A minimal, stow-based dotfiles template for [OpenBoot](https://openboot.dev)

[![Use this template](https://img.shields.io/badge/Use%20this-template-blue)](https://github.com/openbootdotdev/dotfiles/generate)

## Quick Start

1. Click **"Use this template"** above to create your own dotfiles repo
2. Clone your new repo and customize the configs
3. Deploy with GNU Stow:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles ~/.dotfiles
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

## How It Works

This template uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management:

| Source | Target |
|--------|--------|
| `git/.gitconfig` | `~/.gitconfig` |
| `ssh/.ssh/config` | `~/.ssh/config` |
| `zsh/.zshrc` | `~/.zshrc` |

Each top-level directory is a "stow package" that gets symlinked relative to `$HOME`.

## Integration with OpenBoot

### Option 1: Via Dashboard

1. Go to [openboot.dev/dashboard](https://openboot.dev/dashboard)
2. Create a config and set your dotfiles repo URL
3. Run your custom install command:

```bash
curl -fsSL https://openboot.dev/YOUR_USERNAME/CONFIG_SLUG | bash
```

### Option 2: Manual

```bash
# After running OpenBoot
git clone https://github.com/YOUR_USERNAME/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow -v --target="$HOME" */
```

## Adding More Configs

### Simple Config (e.g., tmux)

```bash
mkdir -p tmux
echo "set -g mouse on" > tmux/.tmux.conf
stow -v --target="$HOME" tmux
# Creates: ~/.tmux.conf
```

### Nested Config (e.g., Neovim)

```bash
mkdir -p nvim/.config/nvim
touch nvim/.config/nvim/init.lua
stow -v --target="$HOME" nvim
# Creates: ~/.config/nvim/init.lua
```

### XDG Config Directory

```bash
mkdir -p alacritty/.config/alacritty
touch alacritty/.config/alacritty/alacritty.toml
stow -v --target="$HOME" alacritty
# Creates: ~/.config/alacritty/alacritty.toml
```

## Common Additions

| Package | Files |
|---------|-------|
| `tmux/` | `.tmux.conf` |
| `nvim/` | `.config/nvim/init.lua` |
| `alacritty/` | `.config/alacritty/alacritty.toml` |
| `starship/` | `.config/starship.toml` |
| `wezterm/` | `.config/wezterm/wezterm.lua` |

## Tips

- **Backup first**: Stow won't overwrite existing files. Move them to `*.backup` first.
- **Dry run**: Use `stow -n -v` to preview changes without applying.
- **Unstow**: Use `stow -D package` to remove symlinks.
- **Restow**: Use `stow -R package` to refresh symlinks after changes.

## Related

- [openboot](https://github.com/openbootdotdev/openboot) - CLI tool
- [openboot.dev](https://github.com/openbootdotdev/openboot.dev) - Website

## License

MIT
