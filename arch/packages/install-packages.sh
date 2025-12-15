#!/bin/sh
# Packages phase: Install packages from manifests (pure shell, no external parsers)
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
SHARED_APPS="$REPO_ROOT/shared/packages/apps.common.txt"
OS_MANIFEST="$SCRIPT_DIR/package-manifest.txt"
CUSTOM_PACKAGES_DIR="$SCRIPT_DIR/custom"

# Source shared utilities
. "$SCRIPTS_DIR/lib.sh"

log_info "Installing packages from manifests..."

PACMAN_PKGS=""
AUR_PKGS=""

# Parse shared apps manifest for Arch specs
if [ -f "$SHARED_APPS" ]; then
    log_info "Reading shared application manifest: $SHARED_APPS"
    while IFS='|' read -r name arch_spec darwin_spec; do
        # trim whitespace
        name=$(printf '%s' "$name" | xargs || true)
        arch_spec=$(printf '%s' "$arch_spec" | xargs || true)

        [ -z "$name" ] && continue
        [ "${name#\#}" != "$name" ] && continue  # skip comment lines
        [ -z "$arch_spec" ] && continue

        src=${arch_spec%%:*}
        pkg=${arch_spec#*:}

        case "$src" in
            pacman) PACMAN_PKGS="$PACMAN_PKGS $pkg" ;;
            aur)    AUR_PKGS="$AUR_PKGS $pkg" ;;
        esac
    done < "$SHARED_APPS"
else
    log_warn "Shared apps manifest not found: $SHARED_APPS"
fi

# Parse Arch-specific package manifest
if [ -f "$OS_MANIFEST" ]; then
    log_info "Reading OS-specific package manifest: $OS_MANIFEST"
    while IFS=':' read -r src pkg; do
        src=$(printf '%s' "$src" | xargs || true)
        pkg=$(printf '%s' "$pkg" | xargs || true)

        [ -z "$src" ] && continue
        [ "${src#\#}" != "$src" ] && continue  # skip comment lines
        [ -z "$pkg" ] && continue

        case "$src" in
            pacman) PACMAN_PKGS="$PACMAN_PKGS $pkg" ;;
            aur)    AUR_PKGS="$AUR_PKGS $pkg" ;;
        esac
    done < "$OS_MANIFEST"
else
    log_warn "OS manifest not found: $OS_MANIFEST"
fi

# Install pacman packages
if [ -n "$PACMAN_PKGS" ]; then
    # dedup
    packages=$(printf '%s\n' $PACMAN_PKGS | sort -u | grep -v '^$' || true)
    if [ -n "$packages" ]; then
        log_info "Installing pacman packages: $packages"
        sudo pacman -S --needed --noconfirm $packages || log_error "Failed to install some pacman packages"
    fi
fi

# Install AUR packages
if [ -n "$AUR_PKGS" ]; then
    if command -v yay >/dev/null 2>&1; then
        packages=$(printf '%s\n' $AUR_PKGS | sort -u | grep -v '^$' || true)
        if [ -n "$packages" ]; then
            log_info "Installing AUR packages: $packages"
            yay -S --needed --noconfirm $packages || log_error "Failed to install some AUR packages"
        fi
    else
        log_warn "yay not found. Skipping AUR packages. Install yay to enable AUR support."
    fi
fi

# Build and install custom packages (unchanged)
if [ -d "$CUSTOM_PACKAGES_DIR" ]; then
    log_info "Building and installing custom packages..."
    for pkg_dir in "$CUSTOM_PACKAGES_DIR"/*; do
        [ -d "$pkg_dir" ] || continue
        [ -f "$pkg_dir/PKGBUILD" ] || continue

        pkg_name=$(basename "$pkg_dir")
        log_info "Building custom package: $pkg_name"

        (cd "$pkg_dir" && makepkg -si --noconfirm) || log_error "Failed to build $pkg_name"
    done
fi

log_info "Packages installed."
