#!/usr/bin/env bash

VARIANT=""
USER_SHELL="$SHELL"
INSTALL_DIR="$HOME/.dotfiles"
SCRIPTS_BASE_URL="https://raw.githubusercontent.com/radvil/bash-playground/main"
PLASMA_CONFIGS_BASE_URL="${SCRIPTS_BASE_URL}/kde-configs"
SUPPORTED_VARIANTS=("fedora" "bazzite" "arch" "cachyos" "nobara")
UNINSTALL=false

log() {
  printf "\e[32m[INFO]\e[0m %s" "$1"
}

verbose_log() {
  if [ "$VERBOSE" = true ]; then
    printf "\033[36m[DEBUG]\033[0m %s" "$1"
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
export SCRIPTS_BASE_URL
export SUPPORTED_VARIANTS
export PLASMA_CONFIGS_BASE_URL
export DOTFILES="$INSTALL_DIR"
