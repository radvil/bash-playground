# Dotfiles Installation Script

## Overview
This repository contains an installation script to set up your KDE Plasma dotfiles in a clean and automated way. The script is designed to work with the latest KDE Plasma environment and supports Wayland as the display manager.

## Supported Distributions
Currently, the script supports the following distributions:
- Fedora
- Bazzite
- Arch
- CachyOS

## Prerequisites
Before running the script, ensure that:
- You are **not running as root**.
- Your user is part of the `sudoers` group.
- You have `git` and `curl` installed.

## Installation
To install and configure dotfiles, run the following command:

```bash
bash <(curl -s https://raw.githubusercontent.com/radvil/bash-playground/install.sh) --variant <distro>
```

Replace `<distro>` with one of the supported distributions (e.g., `fedora`, `bazzite`, `arch`, `cachyos`).

## Usage
### Running the Script
If you have cloned the repository manually, you can execute the script with:

```bash
./install.sh --variant <distro>
```

### Help Menu
To display usage instructions, run:

```bash
./install.sh --help
```

## Directory Structure
```
project-root/
│── install.sh       # Main installation script
│── variants/        # Directory containing distribution-specific scripts
│   ├── fedora.sh
│   ├── bazzite.sh
│   ├── arch.sh
│   ├── cachyos.sh
│── README.md        # This documentation file
```

## Environment Variables
The script exports the following variable for use in other scripts:

- `DOTFILES` → Points to the installation directory (`$HOME/.dotfiles`).

## Contributing
If you'd like to contribute, feel free to open a pull request or suggest improvements!

## License
This project is licensed under the MIT License.

