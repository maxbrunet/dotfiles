#!/usr/bin/env bash
set -euo pipefail

echo '>>> Generating SSH keys...'
SSH_PASSPHRASE="$(pwgen -cnysB1 16)"
ssh-keygen -b 4096 -N "${SSH_PASSPHRASE}" -f "${HOME}/.ssh/id_rsa"
secret-tool store --label="Unlock password for: ${USER}@${HOSTNAME}" unique "ssh-store:${HOME}/.ssh/id_rsa" <<< "${SSH_PASSPHRASE}"
