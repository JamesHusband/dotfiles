#!/bin/sh
# Update phase: System updates and convergence
set -eu

echo "Running system updates..."

# macOS-specific update logic
brew update
brew upgrade

echo "System updates complete."

