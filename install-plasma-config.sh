#!/usr/bin/env bash

set -e

# load shared functions and variables
eval "$(curl -fsSL https://raw.githubusercontent.com/radvil/bash-playground/main/vars.sh)"

VERBOSE=false
DRY_RUN=false

if [ -z "$DOTFILES_USER" ]; then
  GLOBAL_XDG="/home/$DOTFILES_USER/.config"
  echo "$GLOBAL_XDG"
fi

if [ ! -d "$GLOBAL_XDG.bak" ]; then
  cp -r "$GLOBAL_XDG" "$GLOBAL_XDG.bak"
fi

# Store summary info
SUMMARY_TABLE="| Filename | Old Config | New Config |\n|----------|------------|------------|"

download_and_link_config() {
  file="$1"
  src="$PLASMA_CONFIGS_BASE_URL/$file"
  dest="$GLOBAL_XDG/$file"
  dotfile="$DOTFILES_DIR/$file"
  backup="${dest}.dotfile.bak"
  old_config="None"

  # Ensure dotfiles directory exists
  if [ "$DRY_RUN" = false ]; then mkdir -p "$DOTFILES_DIR"; fi

  # Restore backup if exists
  if [ -f "$backup" ]; then
    log "♻️  Restoring backup for $file..."
    verbose_log "Moving $backup → $dest"
    if [ "$DRY_RUN" = false ]; then mv "$backup" "$dest"; fi
    old_config="$backup"
  elif [ -f "$dest" ]; then
    log "🔄 Backing up existing $file to $backup"
    verbose_log "Moving $dest → $backup"
    if [ "$DRY_RUN" = false ]; then mv "$dest" "$backup"; fi
    old_config="$backup"
  fi

  # Download new config to /usr/share/dotfiles/
  log "🌍 Downloading $file from $src"
  verbose_log "Running: curl -fvSL $src -o $dotfile"
  if [ "$DRY_RUN" = false ]; then
    if [ "$VERBOSE" = true ]; then
      curl -fvSL "$src" -o "$dotfile"
    else
      curl -fsSL "$src" -o "$dotfile"
    fi
  fi

  if [ "$DRY_RUN" = false ] && [ ! -f "$dotfile" ]; then
    error "❌ Failed to download $file"
  fi

  # Symlink from /usr/share/dotfiles to /etc/xdg/
  log "🔗 Linking $dotfile → $dest"
  verbose_log "Running: ln -sf $dotfile $dest"
  if [ "$DRY_RUN" = false ]; then
    if [ -f "$dest" ]; then
      verbose_log "Backing up $dest → $backup before doing the symlink"
      mv "$dest" "$backup"
      old_config="$backup"
    fi
    ln -sf "$dotfile" "$dest"
  fi

  SUMMARY_TABLE="$SUMMARY_TABLE\n| $file | $old_config | $dest |"
}

# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
  error "❌ This script must be run as root!"
fi

log "🚀 Installing new KDE Plasma configurations..."
for config in $PLASMA_CONFIGS; do
  download_and_link_config "$config"
done

# Print summary table
echo -e "\n📌 **Summary of Changes:**"
echo -e "$SUMMARY_TABLE" | column -t -s '|'

log "🔥 Refreshing kwin_wayland"
kwin_wayland --replace & disown

log "✅ Installation complete!"
