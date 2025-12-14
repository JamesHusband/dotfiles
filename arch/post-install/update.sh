#!/bin/sh
# Update phase: System updates and convergence
set -eu

echo "Running system updates..."

# Arch-specific update logic
sudo pacman -Syu --noconfirm

echo "System updates complete."
