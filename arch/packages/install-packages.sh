#!/bin/sh
# Packages phase: Install packages from manifests
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SHARED_SCRIPTS="$REPO_ROOT/shared/scripts"
SHARED_APPS="$REPO_ROOT/shared/manifest/apps.common.yml"
OS_MANIFEST="$SCRIPT_DIR/package-manifest.toml"
CUSTOM_PACKAGES_DIR="$SCRIPT_DIR/custom"

# Source shared utilities
. "$SHARED_SCRIPTS/lib.sh"

# Temporary files for package lists
PACMAN_PACKAGES="/tmp/dotphials_pacman_packages.txt"
AUR_PACKAGES="/tmp/dotphials_aur_packages.txt"

# Cleanup function
cleanup() {
    rm -f "$PACMAN_PACKAGES" "$AUR_PACKAGES"
}
trap cleanup EXIT

log_info "Installing packages from manifests..."

# Check for required Python dependencies
check_python_deps() {
    if ! python3 -c "import yaml" 2>/dev/null; then
        log_error "PyYAML is not installed."
        log_info "Installing python-yaml via pacman..."
        if sudo pacman -S --needed --noconfirm python-yaml 2>/dev/null; then
            log_info "PyYAML installed successfully."
        else
            log_error "Failed to install python-yaml. Please install manually:"
            log_error "  sudo pacman -S python-yaml"
            log_error "  or: pip install pyyaml"
            exit 1
        fi
    fi
    
    # Check for TOML support (tomllib in Python 3.11+, or tomli)
    if ! python3 -c "import tomllib" 2>/dev/null && ! python3 -c "import tomli" 2>/dev/null; then
        log_warn "TOML support not found. Installing python-tomli..."
        if sudo pacman -S --needed --noconfirm python-tomli 2>/dev/null || pip3 install --user tomli 2>/dev/null; then
            log_info "TOML support installed."
        else
            log_warn "Could not install TOML support. TOML parsing may fail."
        fi
    fi
}

check_python_deps

# Step 1: Parse shared apps.common.yml and extract Arch packages
log_info "Reading shared application manifest..."
if [ -f "$SHARED_APPS" ]; then
    log_info "Found shared apps manifest: $SHARED_APPS"
    
    # Use Python to parse YAML and extract Arch packages
    SHARED_APPS_FILE="$SHARED_APPS" PACMAN_FILE="$PACMAN_PACKAGES" AUR_FILE="$AUR_PACKAGES" python3 << 'PYTHON_EOF'
import sys
import os

try:
    import yaml
except ImportError:
    print("Error: PyYAML not installed. This should have been caught earlier.", file=sys.stderr)
    sys.exit(1)

try:
    with open(os.environ['SHARED_APPS_FILE'], 'r') as f:
        data = yaml.safe_load(f)
    
    pacman_packages = []
    aur_packages = []
    
    if 'apps' in data:
        for app in data['apps']:
            if 'arch' in app:
                source = app['arch'].get('source', '')
                package = app['arch'].get('package', '')
                if source == 'pacman' and package:
                    pacman_packages.append(package)
                elif source == 'aur' and package:
                    aur_packages.append(package)
    
    # Write to temporary files
    with open(os.environ['PACMAN_FILE'], 'w') as f:
        f.write('\n'.join(pacman_packages))
    
    with open(os.environ['AUR_FILE'], 'w') as f:
        f.write('\n'.join(aur_packages))
    
except Exception as e:
    print(f"Error parsing YAML: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
    
    if [ -s "$PACMAN_PACKAGES" ]; then
        log_info "Found $(wc -l < "$PACMAN_PACKAGES") pacman packages from shared manifest"
    fi
    if [ -s "$AUR_PACKAGES" ]; then
        log_info "Found $(wc -l < "$AUR_PACKAGES") AUR packages from shared manifest"
    fi
else
    log_warn "Shared apps manifest not found: $SHARED_APPS"
    touch "$PACMAN_PACKAGES" "$AUR_PACKAGES"
fi

# Step 2: Parse OS-specific package-manifest.toml
log_info "Reading OS-specific package manifest..."
if [ -f "$OS_MANIFEST" ]; then
    log_info "Found OS manifest: $OS_MANIFEST"
    
    # Use Python to parse TOML and extract packages
    OS_MANIFEST_FILE="$OS_MANIFEST" PACMAN_FILE="$PACMAN_PACKAGES" AUR_FILE="$AUR_PACKAGES" python3 << 'PYTHON_EOF'
import sys
import os

try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print("Error: tomllib (Python 3.11+) or tomli not available.", file=sys.stderr)
        print("Install with: pip install tomli", file=sys.stderr)
        sys.exit(1)

try:
    with open(os.environ['OS_MANIFEST_FILE'], 'rb') as f:
        data = tomllib.load(f)
    
    pacman_packages = []
    aur_packages = []
    
    if 'packages' in data:
        if 'pacman' in data['packages']:
            pacman_packages = data['packages']['pacman'].get('packages', [])
        if 'aur' in data['packages']:
            aur_packages = data['packages']['aur'].get('packages', [])
    
    # Append to existing files
    with open(os.environ['PACMAN_FILE'], 'a') as f:
        if pacman_packages:
            f.write('\n' + '\n'.join(pacman_packages) + '\n')
    
    with open(os.environ['AUR_FILE'], 'a') as f:
        if aur_packages:
            f.write('\n' + '\n'.join(aur_packages) + '\n')
    
except Exception as e:
    print(f"Error parsing TOML: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
else
    log_warn "OS manifest not found: $OS_MANIFEST"
fi

# Step 3: Install packages grouped by source
# Install pacman packages
if [ -s "$PACMAN_PACKAGES" ]; then
    log_info "Installing pacman packages..."
    # Remove duplicates and empty lines, then install
    packages=$(sort -u "$PACMAN_PACKAGES" | grep -v '^$' | tr '\n' ' ')
    if [ -n "$packages" ]; then
        sudo pacman -S --needed --noconfirm $packages || log_error "Failed to install some pacman packages"
    fi
fi

# Install AUR packages
if [ -s "$AUR_PACKAGES" ]; then
    log_info "Installing AUR packages..."
    # Check if yay is available
    if command -v yay >/dev/null 2>&1; then
        packages=$(sort -u "$AUR_PACKAGES" | grep -v '^$' | tr '\n' ' ')
        if [ -n "$packages" ]; then
            yay -S --needed --noconfirm $packages || log_error "Failed to install some AUR packages"
        fi
    else
        log_warn "yay not found. Skipping AUR packages. Install yay to enable AUR support."
    fi
fi

# Step 4: Build and install custom packages
if [ -d "$CUSTOM_PACKAGES_DIR" ]; then
    log_info "Building and installing custom packages..."
    for pkg_dir in "$CUSTOM_PACKAGES_DIR"/*; do
        [ -d "$pkg_dir" ] || continue
        [ -f "$pkg_dir/PKGBUILD" ] || continue
        
        pkg_name=$(basename "$pkg_dir")
        log_info "Building custom package: $pkg_name"
        
        # Build package
        (cd "$pkg_dir" && makepkg -si --noconfirm) || log_error "Failed to build $pkg_name"
    done
fi

log_info "Packages installed."
