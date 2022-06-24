: ${BASE16_THEME?}
: ${BASE16_PATH:=${HOME}/.local/share/base16}

source "${BASE16_PATH}/fzf/bash/base16-${BASE16_THEME}.config"
source "${BASE16_PATH}/shell/scripts/base16-${BASE16_THEME}.sh"
