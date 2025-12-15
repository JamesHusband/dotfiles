#!/bin/sh
# Packages phase: Install packages from manifests (pure shell, no external parsers)
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
SHARED_APPS="$REPO_ROOT/shared/packages/shared.packages.txt"
OS_MANIFEST="$SCRIPT_DIR/package-manifest.txt"

# Source shared utilities
. "$SCRIPTS_DIR/lib.sh"

log_info "Installing packages from manifests..."

BREW_PKGS=""
MAS_PKGS=""

# Parse shared apps manifest for Darwin specs
if [ -f "$SHARED_APPS" ]; then
    log_info "Reading shared application manifest: $SHARED_APPS"
    while IFS='|' read -r name arch_spec darwin_spec; do
        name=$(printf '%s' "$name" | xargs || true)
        darwin_spec=$(printf '%s' "$darwin_spec" | xargs || true)

        [ -z "$name" ] && continue
        [ "${name#\#}" != "$name" ] && continue  # skip comment lines
        [ -z "$darwin_spec" ] && continue

        src=${darwin_spec%%:*}
        pkg=${darwin_spec#*:}

        case "$src" in
            brew) BREW_PKGS="$BREW_PKGS $pkg" ;;
            mas)  MAS_PKGS="$MAS_PKGS $pkg" ;;
        esac
    done < "$SHARED_APPS"
else
    log_warn "Shared apps manifest not found: $SHARED_APPS"
fi

# Parse Darwin-specific package manifest
if [ -f "$OS_MANIFEST" ]; then
    log_info "Reading OS-specific package manifest: $OS_MANIFEST"
    while IFS=':' read -r src pkg; do
        src=$(printf '%s' "$src" | xargs || true)
        pkg=$(printf '%s' "$pkg" | xargs || true)

        [ -z "$src" ] && continue
        [ "${src#\#}" != "$src" ] && continue  # skip comment lines
        [ -z "$pkg" ] && continue

        case "$src" in
            brew) BREW_PKGS="$BREW_PKGS $pkg" ;;
            mas)  MAS_PKGS="$MAS_PKGS $pkg" ;;
        esac
    done < "$OS_MANIFEST"
else
    log_warn "OS manifest not found: $OS_MANIFEST"
fi

# Install brew packages
if [ -n "$BREW_PKGS" ]; then
    packages=$(printf '%s\n' $BREW_PKGS | sort -u | grep -v '^$' || true)
    if [ -n "$packages" ]; then
        log_info "Installing brew packages: $packages"
        brew install $packages || log_error "Failed to install some brew packages"
    fi
fi

# Install Mac App Store packages
if [ -n "$MAS_PKGS" ]; then
    if command -v mas >/dev/null 2>&1; then
        packages=$(printf '%s\n' $MAS_PKGS | sort -u | grep -v '^$' || true)
        if [ -n "$packages" ]; then
            log_info "Installing mas packages: $packages"
            mas install $packages || log_error "Failed to install some mas packages"
        fi
    else
        log_warn "mas not found. Skipping Mac App Store packages. Install mas to enable MAS support."
    fi
fi

log_info "Packages installed."
