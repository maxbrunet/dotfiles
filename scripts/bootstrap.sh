#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages jq
# shellcheck shell=bash
set -euo pipefail

export NIX_CONFIG='experimental-features = nix-command flakes'

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

readonly HOST="${1?Must provide HOST}"
readonly ROOT_DIR
readonly HOST_DIR="${ROOT_DIR}/nix/hosts/${HOST}"
readonly MOUNTPOINT="${MOUNTPOINT:-/mnt}"
readonly DEVICE="${DEVICE:-/dev/sdb}"

if [[ "${DEVICE}" == '/dev/nvme'* ]]; then
  readonly EFI_PART="${DEVICE}p1"
  readonly ROOT_PART="${DEVICE}p2"
else
  readonly EFI_PART="${DEVICE}1"
  readonly ROOT_PART="${DEVICE}2"
fi

if ! nix flake show --json \
  | jq --arg host "${HOST}" '.nixosConfigurations|has($host) or halt_error' >/dev/null; then
  printf '>>> Error: no configuration for host: %s\n' "${HOST}" >&2
  exit 1
fi

echo '>>> Generating LUKS key file...'
dd bs=4096 count=1 iflag=fullblock \
  if=/dev/random of="keyfile.bin"
chmod 000 keyfile.bin

echo '>>> Creating partition table...'
parted "${DEVICE}" -- mklabel gpt

## Declarative partitioning would be nice to have
## https://github.com/NixOS/nixpkgs/issues/87073
## Encrypt=key-file uses luks2, and Grub does not have fully support for luk2 yet
## so we cannot use systemd-repart yet
## https://github.com/NixOS/nixpkgs/issues/122449
# systemd-repart "${DEVICE}" \
#   --definitions="${ROOT_DIR}/repart.d" \
#   --dry-run=no \
#   --key-file=keyfile.bin

echo '>>> Partitioning volume...'
parted "${DEVICE}" -- mkpart ESP fat32 1MiB 128MiB
parted "${DEVICE}" -- mkpart primary 128MiB 100%
parted "${DEVICE}" -- set 1 esp on

echo '>>> Creating file systems...'
mkfs.fat -F 32 -n EFI "${EFI_PART}"

cryptsetup luksFormat --type luks1 --hash sha512 --key-file=keyfile.bin "${ROOT_PART}"
cryptsetup luksAddKey "${ROOT_PART}" --key-file=keyfile.bin
cryptsetup luksOpen "${ROOT_PART}" --key-file=keyfile.bin cryptroot

mkfs.ext4 -L nixos /dev/mapper/cryptroot

echo '>>> Mounting volumes...'
mount /dev/mapper/cryptroot "${MOUNTPOINT}"

mkdir -p "${MOUNTPOINT}/boot/efi"
mount "${EFI_PART}" "${MOUNTPOINT}/boot/efi"

echo '>>> Moving LUKS key file to target...'
mkdir -p "${MOUNTPOINT}/boot/initrd"
mv keyfile.bin "${MOUNTPOINT}/boot/initrd/keyfile.bin"

echo '>>> Copying NixOS configuration to target...'
mkdir -p "${MOUNTPOINT}/etc"
cp -a "${ROOT_DIR}" "${MOUNTPOINT}/etc/nixos"

echo '>>> Generating hardware configuration...'
rm -f "${MOUNTPOINT}/${HOST_DIR}/hardware-configuration.nix"
nixos-generate-config --root "${MOUNTPOINT}" --dir "${HOST_DIR}"
rm -f "${MOUNTPOINT}/${HOST_DIR}/configuration.nix"

echo '>>> Installing NixOS...'
nixos-install --verbose --no-root-passwd --root "${MOUNTPOINT}" --flake ".#${HOST}"

echo '>>> Re-configuring NixOS configuration for user...'
nixos-enter --root "${MOUNTPOINT}" -- bash -e <<EOF
  chown -R maxime:users /etc/nixos
  git --git-dir=/etc/nixos/.git remote set-url origin git@github.com:maxbrunet/naxos.git
EOF

echo '>>> Setting user password...'
nixos-enter --root "${MOUNTPOINT}" -- passwd maxime
