#!/usr/bin/env bash
set -euo pipefail

function set_brightness {
  local value=${1?Value required}
  local level

  level="$(
    brightnessctl --device=intel_backlight --machine-readable set "${value}" \
      | awk -F, '{print substr($4, 0, length($4)-1)}'
  )"

  send_brigthness_notification "${level}"
}

function get_brightness_icon {
  local level="${1?Level required}"

  if [[ "${level}" -le 0 ]]; then
    printf 'notification-display-brightness-off'
  elif [[ "${level}" -lt 34 ]]; then
    printf 'notification-display-brightness-low'
  elif [[ "${level}" -lt 67 ]]; then
    printf 'notification-display-brightness-medium'
  elif [[ "${level}" -lt 100 ]]; then
    printf 'notification-display-brightness-high'
  else
    printf 'notification-display-brightness-full'
  fi
}

function send_brigthness_notification {
  local level icon
  level="${1?Level required}"
  icon="$(get_brightness_icon "${level}")"

  dunstify \
    --appname='Display Brightness' \
    --replace='991049' \
    --urgency='low' \
    --timeout='2000' \
    --hints="int:value:${level}" \
    --icon="${icon}" \
    'Brightness'
}

function main {
  local action="${1:-}"

  case "${action}" in
    'up')
      set_brightness 5%+
      ;;
    'down')
      set_brightness 5%-
      ;;
    *)
      printf 'Usage: %s up | down \n' "${BASH_SOURCE[0]}" 1>&2
      return 1
      ;;
  esac
}

main "${@}"
