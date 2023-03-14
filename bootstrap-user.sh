#!/usr/bin/env bash
set -euo pipefail

echo '>>> Installing dotfiles...'
mkdir -p "${HOME}/.config"
ln -s /etc/nixos "${HOME}/.config/nixpkgs"

echo '>>> Building and activating Home Manager configuration...'
home-manager switch
