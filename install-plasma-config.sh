#!/usr/bin/env bash

set -e

VERBOSE=true # Verbose mode ON by default
DRY_RUN=true # Dry-run mode ON by default

verbose_log() {
  if [ "$VERBOSE" = true ]; then
    echo "[DEBUG] $1"
  fi
}

SCRIPTS_BASE_URL="https://raw.githubusercontent.com/bangpuki/bash-playground/main"
PLASMA_CONFIGS_BASE_URL="${SCRIPTS_BASE_URL}/kde-configs"
GLOBAL_XDG="/etc/xdg"
PLASMA_CONFIGS="kdeglobals kcminputrc kglobalshortcutsrc kwinrc plasmarc kstyle.theme"

# Store summary info
SUMMARY_TABLE="| Filename | Old Config | New Config |\n|----------|------------|------------|"

download_config() {
  file="$1"
  src="$PLASMA_CONFIGS_BASE_URL/$file"
  dest="$GLOBAL_XDG/$file"
  backup="${dest}.dotfile.bak"
  old_config="None"

  # Restore backup if exists (before downloading new config)
  if [ -f "$backup" ]; then
    log "♻️  Restoring backup for $file..."
    verbose_log "Moving $backup → $dest"

    if [ "$DRY_RUN" = false ]; then
      mv "$backup" "$dest"
    fi
    old_config="$backup"
  elif [ -f "$dest" ]; then
    log "🔄 Backing up existing $file to $backup"
    verbose_log "Moving $dest → $backup"

    if [ "$DRY_RUN" = false ]; then
      mv "$dest" "$backup"
    fi
    old_config="$backup"
  fi

  # Download new config
  log "🌍 Downloading $file from $src"
  verbose_log "Running: curl -fvSL $src -o $dest"

  if [ "$DRY_RUN" = false ]; then
    if [ "$VERBOSE" = true ]; then
      curl -fvSL "$src" -o "$dest"
    else
      curl -fsSL "$src" -o "$dest"
    fi
  fi

  if [ "$DRY_RUN" = false ] && [ ! -f "$dest" ]; then
    error "❌ Failed to download $file"
  fi

  # Append to summary (only once per file)
  SUMMARY_TABLE="$SUMMARY_TABLE\n| $file | $old_config | $dest |"
}

# Parse command-line arguments
for arg in "$@"; do
  case "$arg" in
  --verbose=false)
    VERBOSE=false
    ;;
  --dry-run=false)
    DRY_RUN=false
    ;;
  --help)
    echo "Usage: $0 [--verbose=true|false] [--dry-run=true|false]"
    exit 0
    ;;
  *)
    error "❌ Unknown argument: $arg. Use --help for usage."
    ;;
  esac
done

# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
  error "❌ This script must be run as root!"
fi

log "🚀 Installing new KDE Plasma configurations..."
for config in $PLASMA_CONFIGS; do
  download_config "$config"
done

# Print summary table
echo -e "\n📌 **Summary of Changes:**"
echo -e "$SUMMARY_TABLE" | column -t -s '|'

log "✅ Installation complete!"

# Detect the user's shell and configure accordingly
USER_SHELL="$(basename "$SHELL")"

case "$USER_SHELL" in
bash | zsh)
  log "✅ Restart your session or run: source ~/.bashrc / ~/.zshrc"
  ;;
fish)
  log "🐟 Fish shell detected. Run: source ~/.config/fish/config.fish to apply changes."
  ;;
*)
  log "⚠️ Unknown shell ($USER_SHELL). Restart your session to apply changes."
  ;;
esac
