#!/usr/bin/env nix-shell
#! nix-shell -i bash -I nixpkgs=flake:nixpkgs-unstable --pure -p cacert nodejs-slim.npm opencode prefetch-npm-deps
# shellcheck shell=bash
set -euo pipefail

PKG_DIR="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
cd "${PKG_DIR}/../../../.config/opencode"

OPENCODE_VERSION="$(opencode --version)"

npm pkg set dependencies.@opencode-ai/plugin="${OPENCODE_VERSION}"
npm update --package-lock-only

HASH="$(prefetch-npm-deps package-lock.json)"
sed -i \
  -e "s#version = .*;#version = \"${OPENCODE_VERSION}\";#" \
  -e "s#hash = .*;#hash = \"${HASH}\";#" \
  "${PKG_DIR}/package.nix"
