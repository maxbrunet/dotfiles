#!/usr/bin/env bash
set -euo pipefail

echo '>>> Installing dotfiles...'
mkdir -p "${HOME}/.config"
git clone --recursive https://github.com/maxbrunet/dotfiles.git ~/.config/nixpkgs
git --git-dir="${HOME}/.config/nixpkgs/.git" remote set-url origin git@github.com:maxbrunet/dotfiles.git
cd "${HOME}/.config/nixpkgs"

echo '>>> Building and activating Home Manager configuration...'
home-manager switch

echo '>>> Generating SSH keys...'
SSH_PASSPHRASE="$(pwgen -cnysB1 16)"
ssh-keygen -b 4096 -N "${SSH_PASSPHRASE}" -f "${HOME}/.ssh/id_rsa"
secret-tool store --label="Unlock password for: ${USER}@${HOSTNAME}" unique "ssh-store:${HOME}/.ssh/id_rsa" <<< "${SSH_PASSPHRASE}"
