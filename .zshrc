# Customize PATH
export PATH="${HOME}/.local/share/cargo/bin:${HOME}/.local/bin:${PATH}"

# Path to oh-my-zsh installation.
ZSH="${HOME}/.local/share/oh-my-zsh"
ZSH_CUSTOM="${HOME}/.local/share/oh-my-zsh-custom"

# Base16 theme
BASE16_THEME='google-dark'

# Set default applications
export BROWSER='firefox'
export EDITOR='nvim'

# awscli
export AWS_PAGER=''

# aws-vault
case "$(uname -s)" in
  'Darwin')
    export AWS_VAULT_KEYCHAIN_NAME='login'
    ;;
  'Linux')
    export AWS_VAULT_BACKEND='secret-service'
    ;;
esac
export AWS_SESSION_TOKEN_TTL='8h'
export AWS_ASSUME_ROLE_TTL='1h'

# bat
export BAT_STYLE='plain'
export BAT_THEME='gruvbox-dark'

# fzf
if (( $+commands[fzf-share] )); then
  FZF_BASE="$(fzf-share)"
elif (( $+commands[brew] )); then
  FZF_BASE='/usr/local/opt/fzf'
fi

# tmux plugin
ZSH_TMUX_AUTOSTART='true'

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
)

# Conditionally load some plugins
(( $+commands[virtualenvwrapper_lazy.sh] )) && plugins+=(virtualenvwrapper)

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
    kubectl
    k3d
    kubens
    kubectx
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

# Aliases
alias argocd='KUBECTL_EXTERNAL_DIFF="git --no-pager diff --no-index" argocd'
alias tree='tree -C -F'
alias nvimrc="${EDITOR} ${HOME}/.config/nixpkgs/.config/astronvim/lua/user/init.lua"
alias zshrc="${EDITOR} ${HOME}/.config/nixpkgs/.zshrc"
alias grbb='git rebase --interactive HEAD~$(git rev-list --count origin/HEAD..HEAD)'
alias curl='curl --fail'
alias tf='terraform'
alias tffmt='terraform fmt'
alias tfinit='terraform init'
alias tfplan='terraform plan'
alias tfapply='terraform apply'
alias -g J='| bat --language=json'
alias -g Y='| bat --language=yaml'
alias e="${EDITOR}"

# zsh-users
# Load zsh-syntax-highlighting after all custom widgets have been created
if (( $+commands[nixos-rebuild] )); then
  source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif (( $+commands[brew] )); then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
