#!/usr/bin/env bash
set -euo pipefail

readonly DUNSTIFY_CONFIG=(
  --appname='Audio Volume'
  --replace='991049'
  --urgency='low'
  --timeout='2000'
)

# Disable language localization
export LC_ALL=C

function get_volume {
  pactl get-sink-volume @DEFAULT_SINK@ \
    | awk '/^Volume: / {print substr($5, 0, length($5)-1); exit}'
}

function get_volume_icon {
  local level="${1?Level required}"

  if [[ "${level}" -le 0 ]]; then
    printf 'notification-audio-volume-off'
  elif [[ "${level}" -lt 34 ]]; then
    printf 'notification-audio-volume-low'
  elif [[ "${level}" -lt 67 ]]; then
    printf 'notification-audio-volume-medium'
  else
    printf 'notification-audio-volume-high'
  fi
}

function send_volume_notification {
  local level icon
  level="$(get_volume)"
  icon="$(get_volume_icon "${level}")"

  dunstify "${DUNSTIFY_CONFIG[@]}" \
    --hints="int:value:${level}" \
    --icon="${icon}" \
    'Volume'
}

function send_mute_notification {
  local level muted
  muted="$(pactl get-sink-mute @DEFAULT_SINK@ | awk -F': ' '{print $2}')"

  case "${muted}" in
    'yes')
      dunstify "${DUNSTIFY_CONFIG[@]}" \
        --hints='int:value:0' \
        --icon='notification-audio-volume-muted' \
        'Volume' \
        'Mute'
      ;;
    'no')
      level="$(get_volume)"
      dunstify "${DUNSTIFY_CONFIG[@]}" \
        --hints="int:value:${level}" \
        --icon="$(get_volume_icon "${level}")" \
        'Volume'
      ;;
    *)
      echo 'Error: Unknown mute status' 1>&2
      return 1
      ;;
  esac
}

function main {
  local action="${1:-}"

  case "${action}" in
    'raise')
      pactl set-sink-volume @DEFAULT_SINK@ +5%
      send_volume_notification
      ;;
    'lower')
      pactl set-sink-volume @DEFAULT_SINK@ -5%
      send_volume_notification
      ;;
    'mute')
      pactl set-sink-mute @DEFAULT_SINK@ toggle
      send_mute_notification
      ;;
    *)
      printf 'Usage: %s raise | lower | mute\n' "${BASH_SOURCE[0]}" 1>&2
      return 1
      ;;
  esac
}

main "${@}"
