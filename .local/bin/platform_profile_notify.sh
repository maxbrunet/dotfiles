#!/usr/bin/env bash
set -euo pipefail

inotifywait --event=MODIFY --format=%w --monitor /sys/firmware/acpi/platform_profile \
  | while read -r file; do
    profile="$(<"${file}")"
    dunstify \
      --appname='Platform Profile' \
      --replace='991049' \
      --urgency='low' \
      --timeout='2000' \
      --icon='cpu' \
      "${profile}"
  done
