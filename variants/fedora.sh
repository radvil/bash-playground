#!/usr/bin/env bash

log() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

set -euo pipefail

log "Installing Fedora config under $DOTFILES"
