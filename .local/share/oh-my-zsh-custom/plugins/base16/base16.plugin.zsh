BASE16_PATH="${HOME}/.local/share/base16"
BASE16_THEME="$(<"${HOME}/.config/tinted-theming/theme_name")"

if [[ "$FZF_DEFAULT_OPTS" != *'--color='* ]]; then
  source "${BASE16_PATH}/fzf/bash/base16-${BASE16_THEME}.config"
fi
source "${BASE16_PATH}/shell/scripts/base16-${BASE16_THEME}.sh"

unset BASE16_PATH BASE16_THEME
