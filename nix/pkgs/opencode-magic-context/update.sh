#!/usr/bin/env nix
#! nix --extra-experimental-features ``nix-command flakes``
#! nix develop --ignore-env --impure --expr ``
#! nix let
#! nix   flake = builtins.getFlake (toString ../../..);
#! nix   pkgs = flake.inputs.nixpkgs-unstable.legacyPackages.${builtins.currentSystem};
#! nix in
#! nix pkgs.mkShell {
#! nix   packages = with pkgs; [
#! nix     cacert
#! nix     git
#! nix     nix
#! nix     nix-update
#! nix   ];
#! nix }
#! nix ``
#! nix --keep-env-var HOME
#! nix --keep-env-var USER
#! nix --keep-env-var GITHUB_TOKEN
#! nix --keep-env-var GH_TOKEN
#! nix --command bash
# shellcheck shell=bash
set -euo pipefail

cd "$(readlink -e "$(dirname "${BASH_SOURCE[0]}")/../../..")"

exec nix-update \
  --flake \
  --version-regex '^v(\d+\.\d+\.\d+)$' \
  --subpackage node_modules \
  opencode-magic-context
