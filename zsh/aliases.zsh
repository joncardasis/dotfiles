# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------

alias gitme="git config user.name 'Jon Cardasis' && git config user.email 'joncardasis@gmail.com'"
alias gitwhoami="git config user.name && git config user.email"

# glb = "git last branches" - list recently checked out branches
alias glb="git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[\$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf(\" %12s\t\033[32m%s\033[0m\n\", substr(\$2, 1, length(\$2) - 1), \$1)}'"

# Stash with options: "staged" stashes only staged changes, otherwise stashes unstaged
gstash() {
  if [[ "$1" == "staged" ]]; then
    git stash push --staged "${@:2}"
  else
    git stash push --keep-index "$@"
  fi
}

# Open a pull request for the current branch (base defaults to main)
ghpr() {
  git push origin HEAD || { echo 'Failed to push commits.'; return 1; }

  local github_url=$(git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#https://#' -e 's@com:@com/@' -e 's%\.git$%%' | awk '/github/')
  local branch_name=$(git symbolic-ref HEAD | cut -d"/" -f 3,4)
  open "$github_url/compare/main...$branch_name"
}

# -----------------------------------------------------------------------------
# File System
# -----------------------------------------------------------------------------

# Rename all directories in current folder to UUIDs
shuffle_dirs() {
  echo "This will rename all directories in $PWD to UUIDs. Continue? (y/N)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    for d in */; do
      [ -d "$d" ] && uuid=$(uuidgen) && mv "$d" "$uuid" && touch -m "$uuid"
    done
    echo "Directories renamed"
  fi
}

# Rename all files in current folder to UUIDs
shuffle_files() {
  echo "This will rename all files in $PWD to UUIDs. Continue? (y/N)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    for f in *; do
      [ -f "$f" ] && uuid=$(uuidgen) && mv "$f" "$uuid" && touch -m "$uuid"
    done
    echo "Files renamed"
  fi
}

# -----------------------------------------------------------------------------
# iOS / Xcode
# -----------------------------------------------------------------------------

alias pi="pod install"

# -----------------------------------------------------------------------------
# Android
# -----------------------------------------------------------------------------

if command -v emulator &> /dev/null; then
  alias launchavd="emulator -avd \$(emulator -list-avds | head -n 1) > /dev/null 2>&1 &"
fi
