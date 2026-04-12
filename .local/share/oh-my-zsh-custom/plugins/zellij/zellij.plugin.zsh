eval "$(zellij setup --generate-auto-start zsh)"

if [[ -n "${ZELLIJ:-}" ]]; then
  # Rename tabs to current working directory automatically
  # https://github.com/zellij-org/zellij/issues/2715
  function _zellij_rename_tab {
    local name="${PWD/${HOME}/~}" # Replace HOME directory by ~
    local truncate_length=10

    if [[ "${#name}" -gt $(( truncate_length + 1 )) ]]; then
      if [[ "${#name##*/}" -gt "${truncate_length}" ]]; then
        # Preserve base name only
        name="…/${name##*/}"
      else
        # Truncate beginning of path with ellipsis
        name="…${name: ~${truncate_length}}"
      fi
    fi

    zellij action rename-tab "${name}"
  }

  if ! (( $chpwd_functions[(I)_zellij_rename_tab] )); then
    chpwd_functions+=(_zellij_rename_tab)
  fi

  # Rename new tab
  _zellij_rename_tab
fi
