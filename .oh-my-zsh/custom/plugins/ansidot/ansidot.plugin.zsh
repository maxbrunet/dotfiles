dotfiles="${HOME}/.dotfiles"
ansidot="${dotfiles}/ansidot"

alias ansidot="ANSIBLE_PIPELINING=true ansible-playbook ${ansidot}/ansidot.yml \
--inventory localhost, \
--connection local \
--extra-vars @${dotfiles}/apps.yml"

alias dotapps="${EDITOR:-nvim} ${dotfiles}/apps.yml"

dotgit() {
  local dotfiles="${HOME}/.dotfiles"
  GIT_WORK_TREE=${dotfiles} GIT_DIR=${dotfiles}/.git git "${@}"
}
compdef '_dispatch git git' dotgit

unset dotfiles ansidot
