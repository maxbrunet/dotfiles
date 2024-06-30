#!/usr/bin/env bash
set -euo pipefail

readonly SSH_PRIVATE_KEY="${HOME}/.ssh/id_ed25519"

if [[ -f "${SSH_PRIVATE_KEY}" ]]; then
  printf '>>> Error: SSH key "%s" already exists.\n' "${SSH_PRIVATE_KEY}"
  exit 1
fi

if secret-tool lookup unique "ssh-store:${SSH_PRIVATE_KEY}" >/dev/null; then
  printf '>>> Error: A secret for "unique ssh-store:%s" already exists.\n' "${SSH_PRIVATE_KEY}"
  exit 1
fi

echo '>>> Generating passphrase...'
SSH_PASSPHRASE="$(pwgen -cnysB1 16)"
echo '>>> Generating SSH keys...'
ssh-keygen -t ed25519 -a 100 -N "${SSH_PASSPHRASE}" -f "${SSH_PRIVATE_KEY}"
echo '>>> Storing passphrase in GNOME keyring...'
secret-tool store --label="Unlock password for: ${USER}@${HOSTNAME}" unique "ssh-store:${SSH_PRIVATE_KEY}" <<<"${SSH_PASSPHRASE}"
echo '>>> Done.'
