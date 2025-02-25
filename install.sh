#!/usr/bin/env bash

set -euo pipefail

usage() {
	echo "Usage: $0 [--variant fedora|bazzite|arch|cachyos|nobara] [--uninstall]"
	exit 1
}

log() {
	echo -e "\e[32m[INFO]\e[0m $1"
}

error() {
	echo -e "\e[31m[ERROR]\e[0m $1" >&2
	exit 1
}

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
USER_SHELL="$SHELL"

if command -v bash &> /dev/null; then
	USER_SHELL="bash"
elif command -v fish &> /dev/null; then
	USER_SHELL="fish"
elif command -v zsh &> /dev/null; then
	USER_SHELL="zsh"
else
	error "No supported shell found (bash, fish, or zsh). Please install bash to proceed."
fi

VARIANT=""
REPO_URL="https://github.com/radvil/bash-playground.git"  # Change this later
INSTALL_DIR="$HOME/.dotfiles"
SUPPORTED_VARIANTS=("fedora" "bazzite" "arch" "cachyos" "nobara")
UNINSTALL=false

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
		-h|--help)
			usage
			;;
		*)
			error "Unknown option: $1"
			;;
	esac
done

# export all variables for other scripts
export VARIANT
export USER_SHELL
export DOTFILES="$INSTALL_DIR"

# Display the parsed arguments as a table
printf "\n%-15s | %-20s\n" "Argument" "Value"
echo "--------------------------------------------------"
printf "%-15s | %-20s\n" "$VARIANT" "$VARIANT"
printf "%-15s | %-20s\n" "$DOTFILES" "$DOTFILES"
printf "%-15s | %-20s\n" "$USER" "$USER"
printf "%-15s | %-20s\n" "$USER_SHELL" "$USER_SHELL"

if [[ "$UNINSTALL" == true ]]; then
	log "TODO: Uninstalling ${VARIANT} dotfiles, and try to restore the old config of $USER"
	log "Unsetting exported variables..."
	unset DOTFILES
	unset USER_SHELL
	unset VARIANT
	exit 0
fi

# Execute the corresponding variant script using curl
VARIANT_SCRIPT_URL="https://raw.githubusercontent.com/radvil/bash-playground/main/variants/${VARIANT}.sh"

log "Downloading and executing variant script: $VARIANT_SCRIPT_URL"

case "$USER_SHELL" in
	bash)
		bash -c "$(curl -s $VARIANT_SCRIPT_URL)"
		;;
	fish)
		fish -c "curl -s $VARIANT_SCRIPT_URL | source"
		;;
	zsh)
		zsh -c "$(curl -s $VARIANT_SCRIPT_URL)"
		;;
	*)
		error "No supported shell found (bash, fish, or zsh). Please install bash to proceed."
		;;
esac

