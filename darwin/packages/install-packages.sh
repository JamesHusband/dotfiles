#!/bin/sh
# Packages phase: Install packages from manifests
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SHARED_SCRIPTS="$REPO_ROOT/shared/scripts"
SHARED_APPS="$REPO_ROOT/shared/manifest/apps.common.yml"
OS_MANIFEST="$SCRIPT_DIR/package-manifest.toml"

# Source shared utilities
. "$SHARED_SCRIPTS/lib.sh"

# Temporary files for package lists
BREW_PACKAGES="/tmp/dotphials_brew_packages.txt"
MAS_PACKAGES="/tmp/dotphials_mas_packages.txt"

# Cleanup function
cleanup() {
    rm -f "$BREW_PACKAGES" "$MAS_PACKAGES"
}
trap cleanup EXIT

log_info "Installing packages from manifests..."

# Check for required Python dependencies
check_python_deps() {
    if ! python3 -c "import yaml" 2>/dev/null; then
        log_error "PyYAML is not installed."
        log_info "Installing pyyaml via pip3..."
        if pip3 install --user pyyaml 2>/dev/null || pip3 install pyyaml 2>/dev/null; then
            log_info "PyYAML installed successfully."
        else
            log_error "Failed to install pyyaml. Please install manually:"
            log_error "  pip3 install pyyaml"
            log_error "  or: brew install python-yaml"
            exit 1
        fi
    fi
    
    # Check for TOML support (tomllib in Python 3.11+, or tomli)
    if ! python3 -c "import tomllib" 2>/dev/null && ! python3 -c "import tomli" 2>/dev/null; then
        log_warn "TOML support not found. Installing tomli..."
        if pip3 install --user tomli 2>/dev/null || pip3 install tomli 2>/dev/null; then
            log_info "TOML support installed."
        else
            log_warn "Could not install TOML support. TOML parsing may fail."
        fi
    fi
}

check_python_deps

# Step 1: Parse shared apps.common.yml and extract Darwin packages
log_info "Reading shared application manifest..."
if [ -f "$SHARED_APPS" ]; then
    log_info "Found shared apps manifest: $SHARED_APPS"
    
    # Use Python to parse YAML and extract Darwin packages
    SHARED_APPS_FILE="$SHARED_APPS" BREW_FILE="$BREW_PACKAGES" MAS_FILE="$MAS_PACKAGES" python3 << 'PYTHON_EOF'
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
    
    brew_packages = []
    mas_packages = []
    
    if 'apps' in data:
        for app in data['apps']:
            if 'darwin' in app:
                source = app['darwin'].get('source', '')
                package = app['darwin'].get('package', '')
                if source == 'brew' and package:
                    brew_packages.append(package)
                elif source == 'mas' and package:
                    mas_packages.append(package)
    
    # Write to temporary files
    with open(os.environ['BREW_FILE'], 'w') as f:
        f.write('\n'.join(brew_packages))
    
    with open(os.environ['MAS_FILE'], 'w') as f:
        f.write('\n'.join(mas_packages))
    
except Exception as e:
    print(f"Error parsing YAML: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
    
    if [ -s "$BREW_PACKAGES" ]; then
        log_info "Found $(wc -l < "$BREW_PACKAGES") brew packages from shared manifest"
    fi
    if [ -s "$MAS_PACKAGES" ]; then
        log_info "Found $(wc -l < "$MAS_PACKAGES") mas packages from shared manifest"
    fi
else
    log_warn "Shared apps manifest not found: $SHARED_APPS"
    touch "$BREW_PACKAGES" "$MAS_PACKAGES"
fi

# Step 2: Parse OS-specific package-manifest.toml
log_info "Reading OS-specific package manifest..."
if [ -f "$OS_MANIFEST" ]; then
    log_info "Found OS manifest: $OS_MANIFEST"
    
    # Use Python to parse TOML and extract packages
    OS_MANIFEST_FILE="$OS_MANIFEST" BREW_FILE="$BREW_PACKAGES" MAS_FILE="$MAS_PACKAGES" python3 << 'PYTHON_EOF'
import sys
import os

try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print("Error: tomllib (Python 3.11+) or tomli not available.", file=sys.stderr)
        print("Install with: pip3 install tomli", file=sys.stderr)
        sys.exit(1)

try:
    with open(os.environ['OS_MANIFEST_FILE'], 'rb') as f:
        data = tomllib.load(f)
    
    brew_packages = []
    mas_packages = []
    
    if 'packages' in data:
        if 'brew' in data['packages']:
            brew_packages = data['packages']['brew'].get('packages', [])
        if 'mas' in data['packages']:
            mas_packages = data['packages']['mas'].get('packages', [])
    
    # Append to existing files
    with open(os.environ['BREW_FILE'], 'a') as f:
        if brew_packages:
            f.write('\n' + '\n'.join(brew_packages) + '\n')
    
    with open(os.environ['MAS_FILE'], 'a') as f:
        if mas_packages:
            f.write('\n' + '\n'.join(mas_packages) + '\n')
    
except Exception as e:
    print(f"Error parsing TOML: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
else
    log_warn "OS manifest not found: $OS_MANIFEST"
fi

# Step 3: Install packages grouped by source
# Install brew packages
if [ -s "$BREW_PACKAGES" ]; then
    log_info "Installing brew packages..."
    packages=$(sort -u "$BREW_PACKAGES" | grep -v '^$' | tr '\n' ' ')
    if [ -n "$packages" ]; then
        brew install $packages || log_error "Failed to install some brew packages"
    fi
fi

# Install mas packages
if [ -s "$MAS_PACKAGES" ]; then
    log_info "Installing mas packages..."
    # Check if mas is available
    if command -v mas >/dev/null 2>&1; then
        packages=$(sort -u "$MAS_PACKAGES" | grep -v '^$' | tr '\n' ' ')
        if [ -n "$packages" ]; then
            mas install $packages || log_error "Failed to install some mas packages"
        fi
    else
        log_warn "mas not found. Skipping Mac App Store packages. Install mas to enable MAS support."
    fi
fi

log_info "Packages installed."
