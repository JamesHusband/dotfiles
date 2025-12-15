<div align="center">
  <img src=".github/readme.webp" alt="Dot Phials">
</div>

# Dot Phials

Dot Phials is a personal, reproducible system and dotfiles repository designed to transform a fresh operating system installation into a fully configured environment. The repository serves as the single source of truth for system configuration, ensuring consistency and repeatability across multiple machines and operating systems.

# Key features:

- **Multi-OS Support**: Currently supports Arch Linux and macOS
- **Idempotent Operations**: All installation and configuration scripts are safe to run multiple times, converging the system to the desired state
- **Symlink-Based Configuration**: User-level configuration files are symlinked from the repository, eliminating configuration drift
- **Phase-Based Installation**: Clear separation of concerns across installation phases (packages, configuration, ricing)
- **Shared and OS-Specific Logic**: Common configurations and packages are declared once in shared manifests, while OS-specific implementations handle platform differences
- **Zero External Dependencies**: Pure shell scripts with no reliance on third-party configuration management tools or Python dependencies


## Getting Started

### Prerequisites

**Arch Linux:**
- A fresh or existing Arch Linux installation
- `sudo` privileges
- `yay` AUR helper (will be installed if missing)

**macOS:**
- A fresh or existing macOS installation
- `sudo` privileges
- Homebrew (will be installed if missing)
- Xcode Command Line Tools (will be installed if missing)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/JamesHusband/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the installation script for your operating system:**
   
   **Arch Linux:**
   ```bash
   ./arch/install.sh
   ```
   
   **macOS:**
   ```bash
   ./darwin/install.sh
   ```

3. **Follow the prompts:**
   The installation script will:
   - Install packages from shared and OS-specific manifests
   - Symlink configuration files to appropriate locations
   - Apply visual customizations and theming
   - Configure system services (where applicable)

### Post-Installation

After the initial installation completes:

- Review any configuration files that were symlinked to your home directory
- Customize settings as needed by editing files in the repository
- Re-run the installation script at any time to apply changes or restore configuration

### Updating Configuration

To update your system configuration:

1. Edit the relevant files in the repository
2. Re-run the installation script for your OS
3. The script will update symlinks and apply changes idempotently

## Installation Phases

Each OS installation follows a consistent phase-based approach:

1. **Package Installation**: Installs packages from shared and OS-specific manifests using the native package manager
2. **Configuration**: Symlinks user and system configuration files from the repository to their target locations
3. **Ricing**: Applies visual customizations, themes, and aesthetic configurations

## Core Principles

### Repository as Source of Truth

The Git repository is the single source of truth. All configuration changes should be made in the repository, and the installation scripts apply these changes to the system. Manual edits outside the repository are discouraged and will be overwritten on the next installation run.

### Idempotency

All scripts are designed to be idempotent. Running the installation script multiple times will converge the system to the desired state without causing errors or unexpected behavior. This allows safe re-execution for updates and troubleshooting.

### Symlinks Over Copies

User-level configuration files are symlinked from the repository rather than copied. This ensures that:
- Configuration changes in the repository are immediately reflected in the system
- No configuration drift occurs between the repository and the deployed system
- The repository remains the authoritative source

### System Files as Build Outputs

System-level directories (such as `/etc`, `/usr/share`) are treated as build outputs. Files in these locations are written by scripts sourcing from the repository, maintaining the separation between source (repository) and artifact (system).

### Explicit Over Clever

The repository favors explicit, readable code over clever abstractions. Scripts are straightforward and maintainable, with clear separation of concerns and minimal hidden behavior.

## Package Manifests

### Shared Packages

The `shared/packages/shared.packages.txt` file declares packages that should be installed on all supported operating systems. Each line specifies a package name, and the OS-specific installation scripts map these to the appropriate package manager syntax.

### OS-Specific Packages

Each OS maintains its own `package-manifest.txt` file that:
- Lists OS-specific packages not available on other platforms
- Maps shared package names to OS-specific package manager names where necessary
- Groups packages by source (e.g., pacman vs AUR on Arch, Homebrew vs Mac App Store on macOS)

## Configuration Management

### Shared Configuration

Configuration files in `shared/config/` are cross-platform and work identically on all operating systems. These include:
- Git configuration (`.gitconfig`)
- Shell configuration (`.zshrc`, `.bashrc`, etc.)
- Terminal configuration (Alacritty)

### OS-Specific Configuration

OS-specific configuration files in `<os>/config/` handle platform-specific settings:

### Symlinking Strategy

- **User files**: Symlinked to `~/.config/`, `~/`, etc.
- **System files**: Symlinked to `/etc/`, `/usr/local/bin/`, etc. (with appropriate permissions and ACLs where needed)

## Ricing and Theming

The ricing phase applies visual customizations and themes:

## License

This repository contains personal configuration files. Use at your own discretion.
