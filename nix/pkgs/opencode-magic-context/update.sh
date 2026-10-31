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

cd "$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"

WRAPPER="$(mktemp "${TMPDIR:-/tmp}/nix-update-wrapper.XXXXXX")"
trap 'rm -f "${WRAPPER}"' EXIT

cat >"${WRAPPER}" <<EOF
{
  system ? builtins.currentSystem,
  ...
}:
let
  flake = builtins.getFlake (toString ${PWD}/../../..);
  pkgs = flake.inputs.nixos-unstable.legacyPackages.\${system};
in
{
  opencode-magic-context = pkgs.callPackage ${PWD}/package.nix { };
}
EOF

package_src() {
  nix build \
    --extra-experimental-features 'nix-command flakes' \
    --impure \
    --no-link \
    --print-out-paths \
    --expr "(import \"${WRAPPER}\" { }).opencode-magic-context.src"
}

update_args=(--file "${WRAPPER}" --version-regex '^v(\d+\.\d+\.\d+)$')
old_lock="$(sha256sum <"$(package_src)/bun.lock")"

# Update the version and source hash first, without rebuilding node_modules.
nix-update "${update_args[@]}" opencode-magic-context

new_lock="$(sha256sum <"$(package_src)/bun.lock")"

# Only rebuild node_modules when bun.lock changed.
if [[ "${old_lock}" != "${new_lock}" ]]; then
  update_args+=(--subpackage node_modules)
  nix-update "${update_args[@]}" opencode-magic-context
else
  echo "bun.lock unchanged; skipping node_modules update."
fi
