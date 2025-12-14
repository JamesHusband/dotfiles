#!/bin/sh
set -eu

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

link() {
  src="$REPO_ROOT/$1"
  dst="$HOME_DIR/$2"

  [ -e "$src" ] || { echo "Missing $src"; exit 1; }

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "Linked $dst -> $src"
}

# dotfiles
link xprofile .xprofile