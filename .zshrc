# Customize PATH
export PATH="${HOME}/.local/share/cargo/bin:${HOME}/.local/bin:${PATH}"

# Path to oh-my-zsh installation.
ZSH="${HOME}/.local/share/oh-my-zsh"
ZSH_CUSTOM="${HOME}/.local/share/oh-my-zsh-custom"

# dotfiles
case "${OSTYPE}" in
  darwin*)
    DOTFILES_DIR="${HOME}/.config/darwin"
    ;;
  linux*)
    DOTFILES_DIR="/etc/nixos"
    ;;
esac

# Set default applications
case "${OSTYPE}" in
  darwin*)
    export BROWSER='open -a Librewolf'
    ;;
  linux*)
    export BROWSER='librewolf'
    ;;
esac
export EDITOR='nvim'

# awscli
export AWS_PAGER=''

# aws-vault
case "${OSTYPE}" in
  darwin*)
    export AWS_VAULT_KEYCHAIN_NAME='login'
    ;;
  linux*)
    export AWS_VAULT_BACKEND='secret-service'
    ;;
esac
export AWS_SESSION_TOKEN_TTL='8h'
export AWS_ASSUME_ROLE_TTL='1h'

# bat
export BAT_STYLE='plain'
export BAT_THEME='gruvbox-dark'

# fzf
FZF_BASE="$(fzf-share)"

# fzf-tab
# disable sort when completing git commands
zstyle ':completion:*:git-*:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with ls when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# kubecolor
export KUBECOLOR_PRESET='pre-0.0.21-dark'

# tmux plugin
ZSH_TMUX_AUTOSTART='true'
ZSH_TMUX_CONFIG="${HOME}/.config/tmux/tmux.conf"

# https://github.com/gpakosz/.tmux/blob/master/README.md#installation
export TERM='xterm-256color'

# Theme to load
ZSH_THEME='tjkirch'

# Plugins
plugins=(
  tmux
  xdg-base-dir
  aws
  base16
  colored-man-pages
  common-aliases
  direnv
  fzf
  git
  gitignore
  kube-ps1
  kubectl
  sudo
  terraform
)

# Conditionally load some plugins
if [[ -x /opt/homebrew/bin/brew ]]; then
  plugins+=(brew)
  # Add completion functions for brew packages to fpath
  # https://github.com/ohmyzsh/ohmyzsh/issues/10412#issuecomment-967029981
  typeset -U FPATH fpath # Enforce uniqueness in FPATH
  fpath+=( /opt/homebrew/share/zsh/site-functions )
fi

source "${ZSH}/oh-my-zsh.sh"

# kube-ps1 plugin
KUBE_PS1_ENABLED='off' # Disable kube-ps1 by default
KUBE_PS1_PREFIX="\n("
KUBE_PS1_SEPARATOR=''

# Adapted PROMPT for kube_ps1 from ${ZSH}/themes/tjkirch.zsh-theme
PROMPT='%(?, ,%{$fg[red]%}FAIL: $?%{$reset_color%}
)$(kube_ps1)
%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}: %{$fg_bold[blue]%}%~%{$reset_color%}$(git_prompt_info)
$(prompt_char) '

# Add aws prompt
RPROMPT='$(aws_prompt_info)'"${RPROMPT}"

# Automatically enable kube-ps1 when certain commands are executed
function _enable_kube-ps1 {
  local -ra KUBE_CMDS=(
    k3d
    kubecolor
    kubectl
    kubectx
    kubens
    kustomize
    tk
  )
  if (( $KUBE_CMDS[(I)${2%% *}] )); then
    kubeon
  fi
}

if ! (( $preexec_functions[(I)_enable_kube-ps1] )); then
  preexec_functions+=(_enable_kube-ps1)
fi

# kubecolor
alias kubectl='kubecolor'
compdef kubecolor='kubectl'

# Aliases
alias argocd='KUBECTL_EXTERNAL_DIFF="git --no-pager diff --no-index" argocd'
alias tree='tree -C -F'
alias nvimrc="${EDITOR} ${DOTFILES_DIR}/.config/nvim/init.lua"
alias zshrc="${EDITOR} ${DOTFILES_DIR}/.zshrc"
alias grbb='git rebase --interactive HEAD~$(git rev-list --count origin/HEAD..HEAD)'
alias curl='curl --fail-with-body'
alias tfswitch="tfswitch --bin=\"${HOME}/.local/bin/terraform\""
alias -g J='| bat --language=json'
alias -g Y='| bat --language=yaml'
alias e="${EDITOR}"

source /run/current-system/sw/share/fzf-tab/fzf-tab.zsh
# zsh-users
# Load zsh-syntax-highlighting after all custom widgets have been created
source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Clean up variables
unset \
  DOTFILES_DIR \
  FZF_BASE \
  ZSH \
  ZSH_CUSTOM \
  ZSH_THEME
