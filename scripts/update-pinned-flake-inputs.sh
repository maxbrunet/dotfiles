#!/usr/bin/env nix
#! nix --extra-experimental-features ``nix-command flakes``
#! nix develop --ignore-env --impure --expr ``
#! nix let
#! nix   flake = builtins.getFlake (toString ./..);
#! nix   pkgs = flake.inputs.nixos.legacyPackages.${builtins.currentSystem};
#! nix in
#! nix pkgs.mkShell {
#! nix   packages = with pkgs; [
#! nix     cacert
#! nix     coreutils
#! nix     flake-edit
#! nix     git
#! nix     jq
#! nix     nix
#! nix   ];
#! nix }
#! nix ``
#! nix --keep-env-var HOME
#! nix --keep-env-var USER
#! nix --command bash
# shellcheck shell=bash
set -euo pipefail

# Prefix overrides for flake inputs whose tag family diverges from the
# default (the ref with its trailing version stripped). Only divergent inputs
# are listed, keyed by input name.
#
# Example: the compound-engineering-plugin repo also ships other packages
# under distinct tag families (`cli-v*`, `marketplace-v*`, bare `v*`, ...);
# keeping the `v` in the prefix ensures only `compound-engineering-v*` tags
# are matched and those other releases can't leak into the resolution.
declare -rA PREFIX_OVERRIDES=(
  ["compound-engineering-plugin"]="compound-engineering-v"
)

# Print the usage message.
usage() {
  cat <<'EOF'
Usage: update-pinned-flake-inputs.sh [--dry-run] [--include-major] [INPUT...]

Update version-tagged flake inputs in flake.nix to the latest minor/patch
release of their current major version, then refresh flake.lock.

  --dry-run       Print proposed changes without modifying anything
  --include-major Also update to newer major versions
  INPUT           Restrict to the given input name(s); by default every
                  direct GitHub input pinned to a tag or ref is updated
EOF
}

# Print the strict SemVer (X.Y.Z) at the end of a tag or ref, or nothing.
# `v6.0.7` -> `6.0.7`, `compound-engineering-v3.24.0` -> `3.24.0`, `v20` -> ``
semver_of() {
  sed -nE 's/.*([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' <<<"$1"
}

# Print the ref with its trailing SemVer stripped, keeping a leading `v`.
# `v6.0.7` -> `v`, `compound-engineering-v3.24.0` -> `compound-engineering-v`
ref_prefix() {
  local ref="$1" version
  version="$(semver_of "${ref}")"
  if [[ -n "${version}" ]]; then
    printf '%s' "${ref%"${version}"}"
  else
    printf '%s' "${ref}"
  fi
}

# Print the tag-family prefix for an input, honoring PREFIX_OVERRIDES.
tag_prefix() {
  local name="$1" ref="$2"
  local prefix
  prefix="$(ref_prefix "${ref}")"
  if [[ -v PREFIX_OVERRIDES["${name}"] ]]; then
    prefix="${PREFIX_OVERRIDES["${name}"]}"
  fi
  printf '%s' "${prefix}"
}

# Print a titled summary section, skipping it when empty.
print_section() {
  local title="$1"
  shift
  (($# > 0)) || return 0
  echo
  echo ">>> ${title}:"
  printf '    %s\n' "$@"
}

# Resolve the latest tag for an input into the overall, same-major and
# newer-major results, written through the $5, $6 and $7 namerefs. `sort -V`
# returns tags in ascending version order, so the last matching entry is the
# maximum. Returns 1 when the repository has no tags, 2 when listing them
# fails.
# shellcheck disable=SC2034 # Values are written through namerefs into the caller's variables.
resolve_latest() {
  local name="$1" owner="$2" repo="$3" ref="$4"
  local -n out_overall="$5" out_same_major="$6" out_has_newer="$7"
  local url prefix current_version current_major tags tag version

  url="https://github.com/${owner}/${repo}.git"
  prefix="$(tag_prefix "${name}" "${ref}")"
  current_version="$(semver_of "${ref}")"
  current_major="${current_version%%.*}"

  out_overall=""
  out_same_major=""
  out_has_newer=false

  tags="$(
    git ls-remote --refs --tags "${url}" \
      | sed 's|.*refs/tags/||' \
      | sort -V
  )" || {
    echo "    failed to list tags for ${url}" >&2
    return 2
  }
  [[ -n "${tags}" ]] || return 1

  while IFS= read -r tag; do
    [[ "${tag}" == "${prefix}"* ]] || continue
    version="$(semver_of "${tag}")"
    [[ -n "${version}" ]] || continue
    out_overall="${tag}"
    if [[ -n "${current_version}" && "${version%%.*}" == "${current_major}" ]]; then
      out_same_major="${tag}"
    fi
    if [[ -n "${current_version}" && "${version%%.*}" -gt "${current_major}" ]]; then
      out_has_newer=true
    fi
  done <<<"${tags}"
}

# Print the tag to update to for an input, or nothing when already current.
# shellcheck disable=SC2034 # The target is written through the nameref.
resolve_target() {
  local include_major="$1" overall="$2" same_major="$3" ref="$4"
  local -n out_target="$5"
  out_target=""
  if [[ "${include_major}" == true ]]; then
    out_target="${overall}"
  elif [[ -n "${same_major}" ]]; then
    out_target="${same_major}"
  elif [[ -z "$(semver_of "${ref}")" && -n "${overall}" ]]; then
    echo "    current ref is not a version, updating to latest: ${overall}"
    out_target="${overall}"
  fi
}

# Rewrite an input's flake.nix URL with flake-edit, or print what would
# change in dry-run. Returns non-zero when flake-edit fails.
apply_update() {
  local name="$1" owner="$2" repo="$3" ref="$4" target="$5" dry_run="$6"
  if [[ "${dry_run}" == true ]]; then
    echo "    would update ${ref} -> ${target}"
    return 0
  fi
  if ! flake-edit --no-lock change "${name}" "github:${owner}/${repo}/${target}" >/dev/null; then
    return 1
  fi
  echo "    updated ${ref} -> ${target}"
}

# Fill the associative array nameref (input name -> github URL) with the
# direct GitHub inputs pinned to a ref, as reported by `flake-edit list`.
# Returns non-zero when discovery fails.
# shellcheck disable=SC2034 # The array is filled through the nameref.
discover_inputs() {
  local -n out_urls="$1"
  local name url listing
  listing="$(
    flake-edit list --format json \
      | jq -r '
        to_entries[]
        | .value.url as $u
        | (($u | fromjson?) // $u) as $url
        | select($url | test("^github:[^/]+/[^/]+/.+$"))
        | "\(.key)\t\($url)"
      '
  )" || {
    echo '>>> failed to read flake inputs' >&2
    return 1
  }
  [[ -n "${listing}" ]] || return 0
  while IFS=$'\t' read -r name url; do
    out_urls["${name}"]="${url}"
  done <<<"${listing}"
}

main() {
  local -a inputs=()
  local dry_run=false include_major=false

  while (($#)); do
    case "$1" in
      --dry-run) dry_run=true ;;
      --include-major) include_major=true ;;
      -h | --help)
        usage
        return 0
        ;;
      --*)
        echo ">>> Unknown option: $1" >&2
        usage >&2
        return 1
        ;;
      *) inputs+=("$1") ;;
    esac
    shift
  done

  local root_dir
  root_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  cd "${root_dir}"

  local -A urls=()
  local -a names=()
  discover_inputs urls
  if ((${#inputs[@]} > 0)); then
    names=("${inputs[@]}")
  else
    mapfile -t names < <(printf '%s\n' "${!urls[@]}" | sort)
  fi

  local -a updates=() updated_names=() majors=() currents=()
  local name url rest owner repo ref overall same_major has_newer target status

  for name in "${names[@]}"; do
    url="${urls["${name}"]:-}"
    if [[ -z "${url}" ]]; then
      echo ">>> ${name}: not a GitHub input pinned to a ref, skipping"
      continue
    fi
    url="${url#github:}"
    owner="${url%%/*}"
    rest="${url#*/}"
    repo="${rest%%/*}"
    ref="${rest#*/}"

    echo ">>> ${name} (${owner}/${repo} @ ${ref})"
    status=0
    resolve_latest "${name}" "${owner}" "${repo}" "${ref}" overall same_major has_newer || status=$?
    if ((status == 1)); then
      echo '    no tags found'
      continue
    fi
    if ((status == 2)); then
      return 1
    fi

    resolve_target "${include_major}" "${overall}" "${same_major}" "${ref}" target
    if [[ -n "${target}" && "${target}" != "${ref}" ]]; then
      if ! apply_update "${name}" "${owner}" "${repo}" "${ref}" "${target}" "${dry_run}"; then
        return 1
      fi
      updates+=("${name}: ${ref} -> ${target}")
      updated_names+=("${name}")
    else
      currents+=("${name} @ ${ref}")
    fi

    if [[ "${has_newer}" == true && "${include_major}" != true && "${target}" != "${overall}" ]]; then
      majors+=("${name}: ${ref} -> ${overall} (major)")
    fi
  done

  if ((${#updates[@]} > 0)); then
    if [[ "${dry_run}" == true ]]; then
      print_section 'Would update' "${updates[@]}"
      echo '>>> Would refresh flake.lock via: nix flake update <input>...'
    else
      echo
      echo '>>> Refreshing flake.lock...'
      nix flake update "${updated_names[@]}"
      print_section 'Updated' "${updates[@]}"
    fi
  fi

  print_section 'Major updates available (skipped)' "${majors[@]}"
  print_section 'Already current' "${currents[@]}"
}

main "${@}"
