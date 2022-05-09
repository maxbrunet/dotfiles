#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CONFIG_DIR}"

readonly MOUNTPOINT="${MOUNTPOINT:-/mnt}"
readonly DEVICE="${DEVICE:-/dev/sdb}"

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
#   --definitions="${CONFIG_DIR}/repart.d" \
#   --dry-run=no \
#   --key-file=keyfile.bin

echo '>>> Partitioning volume...'
parted "${DEVICE}" -- mkpart ESP fat32 1MiB 128MiB
parted "${DEVICE}" -- mkpart primary 128MiB 100%
parted "${DEVICE}" -- set 1 esp on

echo '>>> Creating file systems...'
mkfs.fat -F 32 -n EFI "${DEVICE}1"

cryptsetup luksFormat --type luks1 --hash sha512 --key-file=keyfile.bin "${DEVICE}2"
cryptsetup luksAddKey "${DEVICE}2" --key-file=keyfile.bin
cryptsetup luksOpen "${DEVICE}2" --key-file=keyfile.bin cryptroot

mkfs.ext4 -L nixos /dev/mapper/cryptroot

echo '>>> Mounting volumes...'
mount /dev/mapper/cryptroot "${MOUNTPOINT}"

mkdir -p "${MOUNTPOINT}/boot/efi"
mount "${DEVICE}1" "${MOUNTPOINT}/boot/efi"

echo '>>> Moving LUKS key file to target...'
mkdir -p "${MOUNTPOINT}/boot/initrd"
mv keyfile.bin "${MOUNTPOINT}/boot/initrd/keyfile.bin"

echo '>>> Copying NixOS configuration to target...'
mkdir -p "${MOUNTPOINT}/etc"
cp -a "${CONFIG_DIR}" "${MOUNTPOINT}/etc/nixos"

echo '>>> Configuring and updating NixOS channels...'
nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
nix-channel --update

echo '>>> Generating hardware configuration...'
rm -f "${MOUNTPOINT}/etc/nixos/hardware-configuration.nix"
nixos-generate-config --root "${MOUNTPOINT}"

echo '>>> Installing NixOS...'
# There is an issue with TMPDIR and initrd.secrets
# https://github.com/NixOS/nixpkgs/issues/157989
TMPDIR=/tmp nixos-install --no-root-passwd --root "${MOUNTPOINT}"

# Fails: https://github.com/NixOS/nix/issues/3145
# echo '>>> Configuring NixOS channels on target...'
# nixos-enter --root "${MOUNTPOINT}" -- bash <<EOF
#   set -euo pipefail
#   nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
#   nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
#   nix-channel --update
# EOF

echo '>>> Re-configuring NixOS configuration for user...'
nixos-enter --root "${MOUNTPOINT}" -- bash <<EOF
  set -euo pipefail
  chown -R maxime /etc/nixos
  git --git-dir=/etc/nixos/.git remote set-url origin git@github.com:maxbrunet/naxos-testing.git
EOF

echo '>>> Setting user password...'
nixos-enter --root "${MOUNTPOINT}" -- passwd maxime
