#!/usr/bin/env bash
set -euo pipefail

readonly HOST="${1?must provide HOST}"

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

export NIX_CONFIG='experimental-features = nix-command flakes'

read -rsp "Enter LUKS passphrase: " LUKS_PASSPHRASE
echo # Add newline after prompt
readonly LUKS_PASSPHRASE
echo -n "${LUKS_PASSPHRASE}" >/tmp/cryptroot.key

echo '>>> Mounting system volumes...'
DISKO_MOUNT="$(
  nix build --no-link --print-out-paths \
    ".#nixosConfigurations.${HOST}.config.system.build.disko-mount"
)"
"${DISKO_MOUNT}"

echo '>>> Done.'
