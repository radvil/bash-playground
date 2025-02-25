#!/usr/bin/env bash

VARIANT=""
USER_SHELL="$SHELL"
DOTFILES_DIR="/usr/share/dotfiles"
# GLOBAL_XDG="/etc/xdg"
GLOBAL_XDG="/home/$USER/.config"
SCRIPTS_BASE_URL="https://raw.githubusercontent.com/radvil/bash-playground/main"
PLASMA_CONFIGS_BASE_URL="${SCRIPTS_BASE_URL}/plasma-configs"
SUPPORTED_VARIANTS=("fedora" "bazzite" "arch" "cachyos" "nobara")
PLASMA_CONFIGS="kdeglobals kcminputrc kglobalshortcutsrc kwinrc plasmarc"
UNINSTALL=false

log() {
  printf "\e[32m[INFO]\e[0m %s\n" "$1"
}

verbose_log() {
  if [ "$VERBOSE" = true ]; then
    printf "\033[36m[DEBUG]\033[0m %s\n" "$1"
  fi
}

error() {
  echo -e "\e[31m[ERROR]\e[0m $1" >&2
  exit 1
}

source_script() {
  script_url="$1"
  log "Downloading and executing » $script_url"
  case "$USER_SHELL" in
  bash)
    bash -c "$(curl -s "$script_url")"
    ;;
  fish)
    fish -c "curl -s $script_url | source"
    ;;
  zsh)
    zsh -c "$(curl -s "$script_url")"
    ;;
  *)
    error "No supported shell found (bash, fish, or zsh). Please install bash to proceed."
    ;;
  esac
}

# Export functions and variables
export -f log verbose_log error source_script

export VARIANT
export UNINSTALL
export USER_SHELL
export GLOBAL_XDG
export PLASMA_CONFIGS
export SCRIPTS_BASE_URL
export SUPPORTED_VARIANTS
export PLASMA_CONFIGS_BASE_URL
export DOTFILES_DIR
