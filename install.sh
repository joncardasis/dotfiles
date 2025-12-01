#!/bin/zsh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR=$(dirname "$(realpath "$0")")
USER_BIN_DIR=$HOME/.local/bin

symlink_file() {
  local src=$1
  local dest=$2

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$dest")"

  # Check for existing non-symlink files at destination
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo -e "${RED}Error: ${dest} exists as a non-symlink file"
    echo -e "Please remove the file or directory and try again${NC}"
    exit 1
  fi

  # Create symlink
  ln -sf "$src" "$dest"
}

link_bin_files() {
  for file in "$DOTFILES_DIR/bin"/*; do
    if [ -f "$file" ]; then
      symlink_file "$file" "$USER_BIN_DIR/$(basename "${file%.*}")"
    fi
  done
}

# Link bin programs
link_bin_files

# Add user local bin PATH if not already present
if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
  echo "export PATH=\"$USER_BIN_DIR:\$PATH\"" >> "$HOME/.zshrc"
fi

echo -e "${GREEN}✓ Dotfiles installed successfully${NC}"

source "$HOME/.zshrc"