# Customize PATH
export PATH="${HOME}/.local/bin:${PATH}"

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# fzf-base16 plugin
FZF_BASE16_COLORSCHEME='google-dark'

# Go environment
# run `go env` for more
export GOBIN="${HOME}/.local/bin"
export GOPATH="${HOME}/.local/lib/go"

# tmux plugin
ZSH_TMUX_AUTOSTART='true'

# https://github.com/gpakosz/.tmux/blob/master/README.md#installation
export TERM='xterm-256color'

# Theme to load
ZSH_THEME='tjkirch'

# Plugins
plugins=(
  tmux
  aws
  colored-man-pages
  common-aliases
  docker
  fzf
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
  fzf-base16
  kubectx
  zsh-autosuggestions
)

# Conditionally load some plugins
(( $+commands[pyenv] )) && plugins+=(pyenv)
(( $+commands[virtualenvwrapper_lazy.sh] )) && plugins+=(virtualenvwrapper)
(( $+commands[zypper] )) && plugins+=(suse)

# Load zsh-syntax-highlighting after all custom widgets have been created
plugins+=(zsh-syntax-highlighting)

source "${ZSH}/oh-my-zsh.sh"

# kube-ps1 plugin
KUBE_PS1_ENABLED='false' # Disable kube-ps1 by default
KUBE_PS1_PREFIX="\n("
# Adapted PROMPT for kube_ps1 from ${ZSH}/themes/tjkirch.zsh-theme
PROMPT='%(?, ,%{$fg[red]%}FAIL: $?%{$reset_color%}
)$(kube_ps1)
%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}: %{$fg_bold[blue]%}%~%{$reset_color%}$(git_prompt_info)
$(prompt_char) '

# Automatically enable kube-ps1 when certain commands are executed
function _enable_kube-ps1 {
  case "${2%% *}" in
        kubectl \
      | kops \
      | kubens \
      | kubectx \
      | kustomize \
      | minikube \
    )
      kubeon
      ;;
  esac
}

if ! (( $preexec_functions[(I)_enable_kube-ps1] )); then
  preexec_functions+=(_enable_kube-ps1)
fi

# Set EDITOR
export EDITOR='vim'

# Aliases
alias tree='tree -C -F'
alias vimrc="${EDITOR} ~/.vim_runtime/my_configs.vim"
alias grbb='git rebase --interactive HEAD~$(git rev-list --count origin/master..HEAD)'
alias bat='bat --style=plain --theme TwoDark'
alias curl='curl --fail'
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
