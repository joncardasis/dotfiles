# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------

alias gitme="git config user.name 'Jon Cardasis' && git config user.email 'joncardasis@gmail.com'"
alias gitwhoami="git config user.name && git config user.email"

# Simple git aliases
alias grebase="git pull --rebase origin main"
alias gco="git checkout"
alias gst="git status"
alias gd="git diff"
alias glo="git log --oneline --decorate"
alias gcmsg="git commit --message"
alias gfa="git fetch --all --tags --jobs=10"
alias gl="git pull"

# gch [n] - list the last n recently checked out branches (default: 10)
gch() {
  local n="${1:-10}"
  git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n "$n" | awk -F' ~ HEAD@{' '{printf(" %12s\t\033[32m%s\033[0m\n", substr($2, 1, length($2) - 1), $1)}'
}

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

# Push current branch to origin
function ggp () {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push origin "${b:=$1}"
  fi
}

# Worktree add
function wta() {
  local branch="$1"
  local dir="${2:-${1//\//-}}"
  git worktree add "$dir" -B "$branch"
}

# -----------------------------------------------------------------------------
# File System
# -----------------------------------------------------------------------------

alias desktop-hide="defaults write com.apple.finder CreateDesktop false; killall Finder"
alias desktop-show="defaults write com.apple.finder CreateDesktop true; killall Finder"
alias tempdir="TEMP_DIR=$(mktemp -d); echo 'Created temp directory at $TEMP_DIR'; cd $TEMP_DIR"

# cdw [project] - cd to ~/Workspace or a particular project in Workspace
function cdw() {
  local target=~/Workspace/$1
  if [[ -d "$target" ]]; then
    builtin cd "$target"
  else
    echo "cdw: project not found: $1" >&2
    return 1
  fi
}

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

# Get app sandbox for booted simulator
function app-sandbox() {
  bundle_ids=($(xcrun simctl listapps booted | grep CFBundleIdentifier | awk '{print $3}' | tr -d '";' | grep -v '^com\.apple'))

  if [ ${#bundle_ids[@]} -eq 0 ]; then
      echo "No apps found in booted simulator"
      exit 1
  fi

  PS3=$'\nEnter selection: '  # Custom prompt instead of "#?"

  echo "Bundle IDs:"
  select bundle_id in "${bundle_ids[@]}" "Quit"; do
    case $bundle_id in
      "Quit")
        exit 0
        ;;
      *)
        if [ -n "$bundle_id" ]; then
          echo "\nApp for $bundle_id:\n"
          xcrun simctl get_app_container booted "$bundle_id" app
          echo "\nData for $bundle_id:\n"
          xcrun simctl get_app_container booted "$bundle_id" data
          break
        else
          echo "Invalid selection"
        fi
        ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# Android
# -----------------------------------------------------------------------------

if command -v emulator &> /dev/null; then
  alias launchavd="emulator -avd \$(emulator -list-avds | head -n 1) > /dev/null 2>&1 &"
fi
