#!/usr/bin/env nix
#! nix --extra-experimental-features ``nix-command flakes``
#! nix develop --ignore-env --impure --expr ``
#! nix let
#! nix   flake = builtins.getFlake (toString ./..);
#! nix   pkgs = flake.inputs.nixpkgs-darwin.legacyPackages.${builtins.currentSystem};
#! nix   inherit (pkgs) lib;
#! nix in
#! nix pkgs.mkShell {
#! nix   env = {
#! nix     PODMAN_TAG = lib.versions.majorMinor pkgs.podman.version;
#! nix   };
#! nix   packages = with pkgs; [
#! nix     coreutils
#! nix     gnused
#! nix     regctl
#! nix   ];
#! nix }
#! nix ``
#! nix --keep-env-var HOME
#! nix --keep-env-var USER
#! nix --command bash
# shellcheck shell=bash
set -euo pipefail

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

readonly HOME_NIX="nix/home.nix"
readonly IMAGE_REPO="quay.io/podman/machine-os"

CURRENT_DIGEST="$(sed -nE "s|.*${IMAGE_REPO}@(sha256:[0-9a-f]+)\".*|\1|p; /^sha256:/q" "${HOME_NIX}")"
readonly CURRENT_DIGEST
if [[ -z "${CURRENT_DIGEST}" ]]; then
  printf '>>> Error: no %s digest found in %s.\n' "${IMAGE_REPO}" "${HOME_NIX}" >&2
  exit 1
fi

echo ">>> Resolving ${IMAGE_REPO}:${PODMAN_TAG}..."
DIGEST="$(regctl manifest digest "${IMAGE_REPO}:${PODMAN_TAG}")"
readonly DIGEST

if [[ "${CURRENT_DIGEST}" == "${DIGEST}" ]]; then
  echo ">>> ${HOME_NIX} is already up to date."
  exit 0
fi

sed -i "s|${IMAGE_REPO}@${CURRENT_DIGEST}|${IMAGE_REPO}@${DIGEST}|" "${HOME_NIX}"
echo ">>> Updated ${HOME_NIX}: ${CURRENT_DIGEST} -> ${DIGEST}"
