#!/usr/bin/env bash

set -euo pipefail

# ASCII Art Banner
echo -e "\e[34m"
cat << "EOF"
  _____   ____  _______ ______ _      _____ _      ______  _____ 
 |  __ \ / __ \|__   __|  ____| |    |_   _| |    |  ____|/ ____|
 | |  | | |  | |  | |  | |__  | |      | | | |    | |__  | (___  
 | |  | | |  | |  | |  |  __| | |      | | | |    |  __|  \___ \ 
 | |__| | |__| |  | |  | |____| |____ _| |_| |____| |____ ____) |
 |_____/ \____/   |_|  |______|______|_____|______|______|_____/ 
EOF
echo -e "\e[0m"

echo -e "🚀 Installing dotfiles starting... Sit back, relax, and enjoy! 🎉\n"

# Default values
VARIANT=""
REPO_URL="https://github.com/radvil/bash-playground"  # Change this later
INSTALL_DIR="$HOME/.playground"

export DOTFILES="$INSTALL_DIR"

SUPPORTED_VARIANTS=("fedora" "bazzite" "nobara" "arch" "cachyos")

usage() {
    echo "Usage: $0 [--variant fedora|bazzite|nobara|arch|cachyos]"
    exit 1
}

log() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
    exit 1
}

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
                error "Invalid value for --variant. Supported values: fedora, bazzite, nobara, arch, cachyos"
            fi
            VARIANT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Display the parsed arguments as a table
printf "\n%-15s | %-10s\n" "Argument" "Value"
echo "------------------------------"
printf "%-15s | %-10s\n" "Variant" "$VARIANT"

# Execute the corresponding variant script if it exists
VARIANT_SCRIPT="$DOTFILES/variants/${VARIANT}.sh"
if [[ -f "$VARIANT_SCRIPT" ]]; then
    log "Executing variant script: $VARIANT_SCRIPT"
    chmod +x ${VARIANT_SCRIPT}.sh && bash "$VARIANT_SCRIPT"
else
    error "Variant script not found: $VARIANT_SCRIPT"
fi

