#!/bin/sh
# Shared utility functions for Dot Phials
# Pure helper functions with no side effects

# Logging functions
log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

log_warn() {
    echo "[WARN] $*" >&2
}

# Path resolution
get_repo_root() {
    # Returns the absolute path to the repository root
    cd "$(dirname "$0")/../.." && pwd
}
