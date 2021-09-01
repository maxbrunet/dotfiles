dotfiles="${HOME}/.dotfiles"
ansidot="${dotfiles}/ansidot"

if (( $+commands[pyenv] )); then
  python_env=(${HOME}/.pyenv/versions/3.*/envs/.dotfiles/bin)
  python_env="${python_env[-1]}"
else
  python_env="${HOME}/.virtualenvs/.dotfiles/bin"
fi

alias ansidot="ANSIBLE_PIPELINING=true ${python_env}/ansible-playbook ${ansidot}/ansidot.yml \
--inventory localhost, \
--connection local \
--extra-vars @${dotfiles}/apps.yml"

alias dotapps="${EDITOR:-nvim} ${dotfiles}/apps.yml"

dotgit() {
  local dotfiles="${HOME}/.dotfiles"
  GIT_WORK_TREE=${dotfiles} GIT_DIR=${dotfiles}/.git git "${@}"
}
compdef '_dispatch git git' dotgit

unset dotfiles ansidot python_env
