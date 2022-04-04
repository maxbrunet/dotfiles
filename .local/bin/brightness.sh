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

function send_brigthness_notification {
  local level="${1?Level required}"

  dunstify \
    --appname='Monitor Brightness' \
    --replace='991049' \
    --urgency='low' \
    --timeout='2000' \
    --hints="int:value:${level}" \
    --icon="weather-clear" \
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
