#!/bin/zsh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m'

DOTFILES_DIR=$(dirname "$(realpath "$0")")

symlink_file() {
  local src=$1
  local dest=$2

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$dest")"

  # Check for existing non-symlink files at destination
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo -e "${RED}Error: ${dest} exists as a non-symlink file"
    echo -e "Please remove the file or directory and try again${NC}"
    exit 1
  fi

  # Create symlink
  ln -sf "$src" "$dest"
}

# Append line to .zshrc if not already present
append_to_zshrc() {
  local line=$1
  if ! grep -qF "$line" "$HOME/.zshrc" 2>/dev/null; then
    echo "$line" >> "$HOME/.zshrc"
  fi
}

setup_bin() {
  local user_bin_dir=$HOME/.local/bin

  for file in "$DOTFILES_DIR/bin"/*; do
    [[ -f "$file" ]] && symlink_file "$file" "$user_bin_dir/$(basename "${file%.*}")"
  done

  append_to_zshrc "export PATH=\"$user_bin_dir:\$PATH\""
}

setup_zsh() {
  append_to_zshrc "source $DOTFILES_DIR/zsh/aliases.zsh"
}

setup_bin
echo -e "${DIM}✓ Symlink bin files to $HOME/.local/bin${NC}"
setup_zsh
echo -e "${DIM}✓ Add aliases to $HOME/.zshrc${NC}"
echo -e "\n${GREEN}Dotfiles installed successfully${NC}"
