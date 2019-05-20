# Customize PATH
export PATH="${HOME}/.local/bin:${PATH}"

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# fzf-base16 plugin
FZF_BASE16_COLORSCHEME='google-dark'

# tmux plugin
ZSH_TMUX_AUTOSTART='true'

# https://github.com/gpakosz/.tmux/blob/master/README.md#installation
export TERM='xterm-256color'

# Theme to load
ZSH_THEME='tjkirch'

# Plugins
plugins=(
  tmux
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
KUBE_PS1_ENABLED='false'
KUBE_PS1_PREFIX="\n("
PROMPT="\$(kube_ps1)${PROMPT}"

# Set EDITOR
export EDITOR='vim'

# Aliases
alias tree='tree -C -F'
alias vimrc="${EDITOR} ~/.vim_runtime/my_configs.vim"
alias grbb='git rebase --interactive HEAD~$(git rev-list --count origin/master..HEAD)'
alias bat='bat --style=plain --theme TwoDark'
alias curl='curl --fail'

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

# Get a shell on a container running in Kubernetes
kshell() {
  if [[ "${#}" -lt 1 ]]; then
    printf 'Usage: %s POD_NAME [CONTAINER_NAME]\n' "${FUNCNAME[0]:-${funcstack[1]}}" >&2
    return 1
  fi
  kubectl exec -it "${1}" --container="${2:-}" -- /bin/sh
  return "${?}"
}

# Open a file/directory in GitHub
open_gh() {
  hub browse ${2:-} -- "tree/$(git rev-parse --abbrev-ref --symbolic @{u} | sed 's#^[^/]*/##')/$(git rev-parse --show-prefix)${1:-}"
  return "${?}"
}
