#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DIR=$(dirname "$(realpath "$0")")
DOTFILES_ROOT=$(dirname "$DIR")

cd "$DOTFILES_ROOT" || exit 1
git fetch origin main --quiet

LOCAL=$(git rev-parse main)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
  echo -e "${GREEN}✓${NC} $DOTFILES_ROOT is up to date"
else
  echo -e "${YELLOW}⚠${NC} $DOTFILES_ROOT is out of sync with remote"
  echo -e "\n${YELLOW}Run 'git pull origin main' to update${NC}"
fi
