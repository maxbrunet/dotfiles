# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# tmux plugin
ZSH_TMUX_AUTOSTART="true"

# https://github.com/gpakosz/.tmux/blob/master/README.md#installation
export TERM=xterm-256color

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="tjkirch"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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
  kubectx
  zsh-autosuggestions
)

# Conditionally load some plugins
(( $+commands[pyenv] )) && plugins+=(pyenv)
(( $+commands[virtualenvwrapper_lazy.sh] )) && plugins+=(virtualenvwrapper)
(( $+commands[zypper] )) && plugins+=(suse)

# Load zsh-syntax-highlighting after all custom widgets have been created
plugins+=(zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# kube-ps1
KUBE_PS1_ENABLED=false
KUBE_PS1_PREFIX="
("
PROMPT="\$(kube_ps1)${PROMPT}"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias tree='tree -C -F'
alias vimrc="$EDITOR ~/.vim_runtime/my_configs.vim"
alias grbb="git rebase --interactive HEAD~\$(git rev-list --count origin/master..HEAD)"
alias bat="bat --style=plain --theme TwoDark"
alias curl="curl --fail"

if (( $+commands[zypper] )); then
  alias zinnr='sudo zypper install --no-recommends'
  alias zse='zypper se'
  alias zif='zypper if'
fi

if [[ "$(uname -s)" == 'Darwin' ]]; then
  alias mkpasswd='docker run --rm busybox mkpasswd'
  alias sudoedit='sudo -e'
  alias updatedb='sudo /usr/libexec/locate.updatedb'
fi

kshell() {
  if [[ "${#}" -lt 1 ]]; then
    printf 'Usage: %s POD_NAME [CONTAINER_NAME]\n' "${FUNCNAME[0]:-${funcstack[1]}}" >&2
    return 1
  fi
  kubectl exec -it "${1}" --container="${2:-}" -- /bin/sh
  return "${?}"
}

open_gh() {
  hub browse ${2:-} -- "tree/$(git rev-parse --abbrev-ref --symbolic @{u} | sed 's#^[^/]*/##')/$(git rev-parse --show-prefix)${1:-}"
  return "${?}"
}

source $HOME/.local/share/fzf/base16-fzf/bash/base16-google-dark.config
