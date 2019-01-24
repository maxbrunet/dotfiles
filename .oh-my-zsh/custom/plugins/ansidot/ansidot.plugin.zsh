dotfiles="${HOME}/.dotfiles"
ansidot="${dotfiles}/ansidot"
python_env="${HOME}/.virtualenvs/.dotfiles/bin" 

alias ansidot="ANSIBLE_PIPELINING=true ${python_env}/ansible-playbook ${ansidot}/ansidot.yml \
--inventory localhost, \
--connection local \
--extra-vars @${dotfiles}/apps.yml"

alias dotapps="${EDITOR:-vim} ${dotfiles}/apps.yml"

dotgit() {
  GIT_WORK_TREE=${dotfiles} GIT_DIR=${GIT_WORK_TREE}/.git git "${@}"
}
compdef '_dispatch git git' dotgit
