#!/usr/bin/env bash

set -euo pipefail

log() {
  echo -e "\e[32m[INFO]\e[0m $1"
}

error() {
  echo -e "\e[31m[ERROR]\e[0m $1" >&2
  exit 1
}

# PLASMA_CONFIGS_BASE_URL="$(pwd)/kde-configs"
PLASMA_CONFIGS_BASE_URL="${SCRIPTS_BASE_URL}/kde-configs"
GLOBAL_XDG="/etc/xdg"
PLASMA_CONFIGS=(
  "kdeglobals"
  "kcminputrc"
  "kglobalshortcutsrc"
  "kwinrc"
  "plasmarc"
  "kstyle.theme"
)

link_config() {
  local file="$1"
  local src="$PLASMA_CONFIGS_BASE_URL/$file"
  local dest="$GLOBAL_XDG/$file"

  # Ensure the source file exists
  if [[ ! -f "$src" ]]; then
    log "❌ Skipping $file: source file not found."
    return
  fi

  # Backup existing config if it exists
  if [[ -f "$dest" ]]; then
    local backup="${dest}.dotfile.bak"
    log "🔄 Backing up existing $file to $backup"
    mv "$dest" "$backup"
  fi

  # Create a symlink
  log "🔗 Linking $src → $dest"
  ln -s "$src" "$dest"
}

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  error "❌ This script must be run as root!" >&2
fi

log "🚀 Installing KDE Plasma configurations..."

for config in "${PLASMA_CONFIGS[@]}"; do
  link_config "$config"
done

log "✅ Installation complete!"
