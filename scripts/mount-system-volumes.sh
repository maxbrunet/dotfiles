#!/usr/bin/env bash
set -euo pipefail

readonly HOST="${1?must provide HOST}"

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

export NIX_CONFIG='experimental-features = nix-command flakes'

## FIXME: Disko should open the LUKS devices, but _mount is not picked up in the mount script :/
## https://github.com/nix-community/disko/blob/93672b9b1ef2b262e2bc49be0fc190ac31ea9c59/types/default.nix#L240-L241
## https://github.com/nix-community/disko/blob/93672b9b1ef2b262e2bc49be0fc190ac31ea9c59/types/luks.nix#L40-L54
#
# read -rsp "Enter LUKS passphrase: " LUKS_PASSPHRASE
# echo # Add newline after prompt
# readonly LUKS_PASSPHRASE
# echo -n "${LUKS_PASSPHRASE}" >/tmp/cryptroot.key
#
echo '>>> Opening LUKS volume...'
cryptsetup luksOpen /dev/disk/by-partlabel/primary cryptroot

echo '>>> Mounting system volumes...'
DISKO_MOUNT="$(
  nix build --no-link --print-out-paths \
    ".#nixosConfigurations.${HOST}.config.system.build.mountScript"
)"
"${DISKO_MOUNT}"

echo '>>> Done.'
