#!/usr/bin/env bash
set -euo pipefail

# https://github.com/NixOS/nixpkgs/issues/22652#issuecomment-890512607
echo '>>> Configuring default icon theme...'
mkdir -p ~/.local/share/icons
ln -s /run/current-system/sw/share/icons/breeze_cursors ~/.local/share/icons/default

echo '>>> Creating XDG user directories...'
xdg-user-dirs-update

echo '>>> Installing dotfiles...'
git clone --recursive https://github.com/maxbrunet/dotfiles.git ~/.dotfiles
git --git-dir="${HOME}/.config/dotfiles/.git" remote set-url origin git@github.com:maxbrunet/dotfiles.git
cd "${HOME}/config/dotfiles"

echo '>>> Installing Ansible...'
pipx install ansible-core

echo '>>> Running Ansible playbook...'
ansible-playbook ansidot/ansidot.yml --inventory localhost, --connection local --extra-vars @apps.yml

echo '>>> Generating SSH keys...'
SSH_PASSPHRASE="$(pwgen -cnysB1 16)"
ssh-keygen -b 4096 -N "${SSH_PASSPHRASE}" -f "${HOME}/.ssh/id_rsa"
secret-tool store --label="Unlock password for: ${USER}@${HOSTNAME}" unique "ssh-store:${HOME}/.ssh/id_rsa" <<< "${SSH_PASSPHRASE}"
