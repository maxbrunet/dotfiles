#!/usr/bin/env bash
set -euo pipefail

echo '>>> Generating passphrase...'
SSH_PASSPHRASE="$(pwgen -cnysB1 16)"
echo '>>> Generating SSH keys...'
ssh-keygen -b 4096 -N "${SSH_PASSPHRASE}" -f "${HOME}/.ssh/id_rsa"
echo '>>> Storing passphrase in GNOME keyring...'
secret-tool store --label="Unlock password for: ${USER}@${HOSTNAME}" unique "ssh-store:${HOME}/.ssh/id_rsa" <<< "${SSH_PASSPHRASE}"
echo '>>> Done.'
