#!/usr/bin/env bash

set -euo pipefail

eval "$(curl -fsSL https://raw.githubusercontent.com/radvil/bash-playground/main/vars.sh)"

log "Installing Fedora config under $DOTFILES_DIR"
