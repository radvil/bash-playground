#!/usr/bin/env sh

set -e

VERBOSE=true # Verbose mode ON by default
DRY_RUN=true # Dry-run mode ON by default

log() {
  echo "[INFO] $1"
}

verbose_log() {
  if [ "$VERBOSE" = true ]; then
    echo "[DEBUG] $1"
  fi
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

SCRIPTS_BASE_URL="https://raw.githubusercontent.com/bangpuki/bash-playground/main"
PLASMA_CONFIGS_BASE_URL="${SCRIPTS_BASE_URL}/kde-configs"
GLOBAL_XDG="/etc/xdg"
PLASMA_CONFIGS="kdeglobals kcminputrc kglobalshortcutsrc kwinrc plasmarc kstyle.theme"

backup_and_restore() {
  file="$1"
  dest="$GLOBAL_XDG/$file"
  backup="${dest}.dotfile.bak"

  # Restore backup if exists
  if [ -f "$backup" ]; then
    log "♻️  Restoring backup for $file..."
    verbose_log "Moving $backup → $dest"

    if [ "$DRY_RUN" = false ]; then
      mv "$backup" "$dest"
    fi
  fi
}

download_config() {
  file="$1"
  src="$PLASMA_CONFIGS_BASE_URL/$file"
  dest="$GLOBAL_XDG/$file"

  # Backup existing config
  if [ -f "$dest" ]; then
    backup="${dest}.dotfile.bak"
    log "🔄 Backing up existing $file to $backup"
    verbose_log "Moving $dest → $backup"

    if [ "$DRY_RUN" = false ]; then
      mv "$dest" "$backup"
    fi
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

log "🚀 Restoring previous KDE Plasma configurations..."
for config in $PLASMA_CONFIGS; do
  backup_and_restore "$config"
done

log "🚀 Installing new KDE Plasma configurations..."
for config in $PLASMA_CONFIGS; do
  download_config "$config"
done

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
