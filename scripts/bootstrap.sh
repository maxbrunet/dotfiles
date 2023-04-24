#!/usr/bin/env bash
set -euo pipefail

export NIX_CONFIG='experimental-features = nix-command flakes'

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

readonly HOST="${1?must provide HOST}"
readonly ROOT_DIR
readonly HOST_DIR="${ROOT_DIR}/nix/hosts/${HOST}"
readonly MOUNTPOINT='/mnt'

if [[ -f /tmp/cryptroot.key ]]; then
  PASSWORD="$(</tmp/cryptroot.key)"
  readonly PASSWORD
else
  read -rsp "Enter new password: " PASSWORD
  echo # Add newline after prompt
  read -rsp "Confirm new password: " PASSWORD2
  echo # Add newline after prompt
  readonly PASSWORD PASSWORD2

  if [[ "${PASSWORD}" != "${PASSWORD2}" ]]; then
    echo ">>> Error: passwords do not match."
    exit 1
  fi

  echo -n "${PASSWORD}" >/tmp/cryptroot.key
fi

echo '>>> Partitioning and formatting disk...'
DISKO="$(
  nix build --no-link --print-out-paths \
    ".#nixosConfigurations.${HOST}.config.system.build.disko"
)"
"${DISKO}"

echo '>>> Generating LUKS key file...'
dd bs=4096 count=1 iflag=fullblock if=/dev/random of="keyfile.bin"
chmod 000 keyfile.bin
cryptsetup luksAddKey /dev/disk/by-partlabel/primary --key-file=/tmp/cryptroot.key keyfile.bin

echo '>>> Moving LUKS key file to target...'
mkdir -p "${MOUNTPOINT}/boot/initrd"
mv keyfile.bin "${MOUNTPOINT}/boot/initrd/keyfile.bin"

echo '>>> Generating hardware configuration...'
rm -f "${HOST_DIR}/hardware-configuration.nix"
nixos-generate-config --root "${MOUNTPOINT}" --dir "${HOST_DIR}"
rm -f "${HOST_DIR}/configuration.nix"

echo '>>> Copying NixOS configuration to target...'
mkdir -p "${MOUNTPOINT}/etc"
cp -a "${ROOT_DIR}" "${MOUNTPOINT}/etc/nixos"

echo '>>> Installing NixOS...'
nixos-install --verbose --no-root-passwd --root "${MOUNTPOINT}" --flake ".#${HOST}"

nixos-enter --root "${MOUNTPOINT}" -- bash -e <<EOF
  echo '>>> Re-configuring NixOS configuration for user...'
  chown -R maxime:users /etc/nixos
  git --git-dir=/etc/nixos/.git remote set-url origin git@github.com:maxbrunet/dotfiles.git

  echo '>>> Setting user password...'
  chpasswd <<< 'maxime:${PASSWORD}'
EOF

echo '>>> All done! Ready to reboot.'
