#!/bin/bash

SCREENSHOTS_DIR="$HOME/Screenshots"

print_usage() {
  echo -e "\nUsage: screenshots <option>\n"
  echo "Options:"
  echo "  help          Show this help message"
  echo "  configure     Create $SCREENSHOTS_DIR and set as default directory"
  echo "  organize      Organize screenshots directory by year and month"
  echo ""
}

configure_screenshots() {
  # Create directory
  [[ ! -d "$SCREENSHOTS_DIR" ]] && mkdir -p "$SCREENSHOTS_DIR"

  # Set screenshot preferences
  defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
  defaults write com.apple.screencapture showsClicks 1
  killall SystemUIServer

  echo "Screenshots configured for $SCREENSHOTS_DIR"

  # iOS simulator
  if xcrun simctl help &>/dev/null; then
    defaults write com.apple.iphonesimulator ScreenShotSaveLocation -string "$SCREENSHOTS_DIR"
    defaults write com.apple.iphonesimulator ScreenRecordingPath -string "$SCREENSHOTS_DIR"
    defaults write com.apple.iphonesimulator NSUserKeyEquivalents -dict-add "Record Screen" -string "@\$r" # Rebind to ⌘⇧R for react native
    echo "iOS Simulator screenshots configured for $SCREENSHOTS_DIR"
  else
    echo "Xcode CLI not found, skipping iOS Simulator screenshots configuration"
  fi
}

organize_screenshots() {
  [[ ! -d "$SCREENSHOTS_DIR" ]] && echo "Screenshots directory not found" && return 1

  local cutoff=$(date +%Y%m)

  # Move files older than current month into YYYY.MM folders
  for file in "$SCREENSHOTS_DIR"/*; do
    # Skip YYYY.MM directories
    [[ $(basename "$file") =~ ^[0-9]{4}\.[0-9]{2}$ ]] && continue

    local file_date=$(date -r "$file" "+%Y%m")
    [[ "$file_date" -ge "$cutoff" ]] && continue

    local year_month=$(date -r "$file" "+%Y.%m")
    local target="$SCREENSHOTS_DIR/$year_month"

    mkdir -p "$target"
    mv -n "$file" "$target/"
  done

  # Update folder timestamps to match their dates
  for folder in "$SCREENSHOTS_DIR"/????.*; do
    [[ ! -d "$folder" ]] && continue
    local name=$(basename "$folder")
    local year=${name%.*}
    local month=${name#*.}
    local timestamp="${year}${month}010000"  # YYYYMMDDHHmm format

    touch -t "$timestamp" "$folder"  # modification time
    SetFile -d "${month}/01/${year} 00:00:00" -m "${month}/01/${year} 00:00:00" "$folder" 2>/dev/null  # creation & modification time
  done

  echo "${SCREENSHOTS_DIR} organized"
}

case "$1" in
  help)
    print_usage
    exit 0
  ;;
  configure)
    configure_screenshots
    exit 0
  ;;
  organize)
    organize_screenshots
    exit 0
  ;;
  *)
    print_usage
    exit 1
  ;;
esac