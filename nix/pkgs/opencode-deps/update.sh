#!/usr/bin/env nix
#! nix --extra-experimental-features ``nix-command flakes``
#! nix develop --ignore-env --impure --expr ``
#! nix let
#! nix   flake = builtins.getFlake (toString ../../..);
#! nix   pkgs = flake.inputs."nixos-unstable".legacyPackages.${builtins.currentSystem};
#! nix in
#! nix pkgs.mkShell {
#! nix   env = {
#! nix     OPENCODE_VERSION = pkgs.opencode.version;
#! nix   };
#! nix   packages = with pkgs; [
#! nix     cacert
#! nix     nodejs-slim.npm
#! nix     prefetch-npm-deps
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

PKG_DIR="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
cd "${PKG_DIR}/../../../.config/opencode"

npm pkg set dependencies.@opencode-ai/plugin="${OPENCODE_VERSION}"
npm update --package-lock-only

HASH="$(prefetch-npm-deps package-lock.json)"
sed -i \
  -e "s#version = .*;#version = \"${OPENCODE_VERSION}\";#" \
  -e "s#hash = .*;#hash = \"${HASH}\";#" \
  "${PKG_DIR}/package.nix"
