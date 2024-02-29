BASE16_PATH="${HOME}/.local/share/base16"
BASE16_THEME="$(<"${HOME}/.config/tinted-theming/theme_name")"

source "${BASE16_PATH}/fzf/bash/base16-${BASE16_THEME}.config"
source "${BASE16_PATH}/shell/scripts/base16-${BASE16_THEME}.sh"

unset BASE16_PATH BASE16_THEME
