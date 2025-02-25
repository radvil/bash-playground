#!/usr/bin/env bash

set -euo pipefail

# load shared functions and variables
eval "$(curl -fsSL https://raw.githubusercontent.com/radvil/bash-playground/main/vars.sh)"

usage() {
  echo "Usage: $0 [--variant fedora|bazzite|arch|cachyos|nobara] [--uninstall]"
  exit 1
}

# ASCII Art Banner
echo -e "\e[34m"
cat <<"EOF"
  _____   ____  _______ ______ _      _____ _      ______  _____ 
 |  __ \ / __ \|__   __|  ____| |    |_   _| |    |  ____|/ ____|
 | |  | | |  | |  | |  | |__  | |      | | | |    | |__  | (___  
 | |  | | |  | |  | |  |  __| | |      | | | |    |  __|  \___ \ 
 | |__| | |__| |  | |  | |____| |____ _| |_| |____| |____ ____) |
 |_____/ \____/   |_|  |______|______|_____|______|______|_____/ 
EOF
echo -e "\e[0m"

echo -e "🚀 Installing dotfiles starting... Sit back, relax, and enjoy! 🎉\n"

if command -v bash &>/dev/null; then
  USER_SHELL="bash"
elif command -v fish &>/dev/null; then
  USER_SHELL="fish"
elif command -v zsh &>/dev/null; then
  USER_SHELL="zsh"
else
  error "No supported shell found (bash, fish, or zsh). Please install bash to proceed."
fi

# Ensure the script is run by a non-root user in the wheel group
if [[ "$EUID" -eq 0 ]]; then
  error "This script must not be run as root. Please run it as a normal user with sudo privileges."
fi
if ! groups | grep -q '\bwheel\b'; then
  error "User must be in the wheel group."
fi

# Display usage if no arguments are passed
if [[ $# -eq 0 ]]; then
  usage
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --variant)
    if [[ -z "$2" || ! " ${SUPPORTED_VARIANTS[@]} " =~ " $2 " ]]; then
      error "Invalid value for --variant. Supported values: fedora, bazzite, arch, cachyos, nobara"
    fi
    VARIANT="$2"
    shift 2
    ;;
  --uninstall)
    UNINSTALL=true
    shift
    ;;
  -h | --help)
    usage
    ;;
  *)
    error "Unknown option: $1"
    ;;
  esac
done

# Display the parsed arguments as a table
echo "--------------------------------------------------"
printf "%-15s | %-20s\n" "Variables" "Value"
echo "--------------------------------------------------"
printf "%-15s | %-20s\n" "USER" "$USER"
printf "%-15s | %-20s\n" "USER_SHELL" "$USER_SHELL"
printf "%-15s | %-20s\n" "VARIANT" "$VARIANT"
printf "%-15s | %-20s\n" "DOTFILES_DIR" "$DOTFILES_DIR"
echo "--------------------------------------------------"

if [[ "$UNINSTALL" == true ]]; then
  log "TODO: Uninstalling ${VARIANT} dotfiles, and try to restore the old config of $USER"
  log "Unsetting exported variables..."
  unset DOTFILES_DIR
  unset USER_SHELL
  unset VARIANT
  exit 0
fi

PLASMA_CONFIG_INIT_URL="${SCRIPTS_BASE_URL}/install-plasma-config.sh"
log "Plasma install script » ${PLASMA_CONFIG_INIT_URL}"
sudo sh -c "$(curl -fsSL "${PLASMA_CONFIG_INIT_URL}?nocache=$(date +%s)")" --verbose=true

VARIANT_SCRIPT_URL="${SCRIPTS_BASE_URL}/variants/${VARIANT}.sh"
source_script "$VARIANT_SCRIPT_URL"


