# Customize PATH
export PATH="${HOME}/.local/bin:${HOME}/.pyenv/shims:${PATH}"

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Base16 theme
BASE16_THEME='google-dark'

# Go environment
# run `go env` for more
export GOBIN="${HOME}/.local/bin"
export GOPATH="${HOME}/.local/lib/go"

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
export BAT_THEME='TwoDark'

# terraform
export TF_PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugins"

# tmux plugin
ZSH_TMUX_AUTOSTART='true'

# https://github.com/gpakosz/.tmux/blob/master/README.md#installation
export TERM='xterm-256color'

# Theme to load
ZSH_THEME='tjkirch'

# Plugins
plugins=(
  tmux
  asdf
  aws
  colored-man-pages
  common-aliases
  docker
  git
  gitignore
  kube-ps1
  kubectl
  pyenv
  sudo
  vagrant
  zsh_reload
  # custom
  ansidot
  base16
)

# Conditionally load some plugins
(( $+commands[pyenv] )) && plugins+=(pyenv)
(( $+commands[virtualenvwrapper_lazy.sh] )) && plugins+=(virtualenvwrapper)
(( $+commands[zypper] )) && plugins+=(suse)
[[ -f /etc/arch-release ]] && plugins+=(archlinux)

source "${ZSH}/oh-my-zsh.sh"

# fzf
if (( $+commands[zypper] )); then
  source /etc/zsh_completion.d/fzf-key-bindings
elif (( $+commands[brew] )); then
  [[ $- == *i* ]] && source /usr/local/opt/fzf/shell/completion.zsh 2> /dev/null
  source /usr/local/opt/fzf/shell/key-bindings.zsh
elif [[ -f /etc/arch-release ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi

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
  case "${2%% *}" in
        kubectl \
      | k3d \
      | kops \
      | kubens \
      | kubectx \
      | kustomize \
      | tk \
    )
      kubeon
      ;;
  esac
}

if ! (( $preexec_functions[(I)_enable_kube-ps1] )); then
  preexec_functions+=(_enable_kube-ps1)
fi

# Set EDITOR
export EDITOR='nvim'

# Aliases
alias argocd='KUBECTL_EXTERNAL_DIFF="git --no-pager diff --no-index" argocd'
alias tree='tree -C -F'
alias nvimrc="${EDITOR} ~/.vim_runtime/my_configs.vim"
alias grbb='git rebase --interactive HEAD~$(git rev-list --count origin/HEAD..HEAD)'
alias curl='curl --fail'
alias tf='terraform'
alias tffmt='terraform fmt'
alias tfinit='terraform init'
alias tfplan='terraform plan'
alias tfapply='terraform apply'
alias -g J='| bat --language=json'
alias -g Y='| bat --language=yaml'

# OpenSUSE specific aliases
if (( $+commands[zypper] )); then
  alias zinnr='sudo zypper install --no-recommends'
  alias zse='zypper se'
  alias zif='zypper if'
fi

# MacOS specific aliases
if [[ "$(uname -s)" == 'Darwin' ]]; then
  alias mkpasswd='docker run --rm busybox mkpasswd'
  alias sudoedit='sudo -e'
  alias updatedb='sudo /usr/libexec/locate.updatedb'
fi

# Open a file/directory in GitHub
open_gh() {
  hub browse ${2:-} -- "tree/$({git rev-parse --abbrev-ref --symbolic @{u} || git rev-parse --short HEAD} 2>/dev/null | sed 's#^[^/]*/##')/$(git rev-parse --show-prefix)${1:-}"
  return "${?}"
}

# Open a file/directory in Bitbucket Cloud
open_bb() {
  local file="${1:-}"
  local option="${2:-}"
  local remote commit prefix repository url
  remote="$(git config --get remote.origin.url)"
  commit="$(git rev-parse HEAD)"
  prefix="$(git rev-parse --show-prefix)"

  if [[ "${remote}" =~ '^git@bitbucket.org:(.+)\.git$' ]]; then
    # ${match} is the Zsh equivalent of Bash's ${BASH_REMATCH}
    repository="${match[1]}"
  elif [[ "${remote}" =~ '^https://.+@bitbucket.org/(.+)\.git$' ]]; then
    repository="${match[1]}"
  else
    echo 'Aborted: could not find any git remote pointing to a Bitbucket Cloud repository' >&2
    return 1
  fi

  url="https://bitbucket.org/${repository}/src/${commit}/${prefix}${file}"
  # Yes, I do cheap argument parsing, good enough, to hell getopts and co
  if [[ " ${option} " =~ " --copy " || " ${option} " =~ " -c " ]]; then
    # The clipcopy() function is part of oh-my-zsh (see lib/clipboard.zsh)
    clipcopy <<< "${url}"
  elif [[ " ${option} " =~ " --url " || " ${option} " =~ " -u " ]]; then
    printf '%s\n' "${url}"
  else
    # The open_command() function is part of oh-my-zsh (see lib/functions.zsh)
    open_command "${url}"
  fi
}

# zsh-users
# Load zsh-syntax-highlighting after all custom widgets have been created
if (( $+commands[brew] )); then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /etc/arch-release ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
