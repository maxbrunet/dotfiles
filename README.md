# My Awesome Dotfiles

My dotfiles collection for a flawless workflow. Starring `zsh`, `vim` and `tmux`.

![Screenshot](screenshot.png)

## How to setup

```shell
git clone --recurse-submodules git@github.com:maxbrunet/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
mkvirtualenv .dotfiles
pip install ansible
ansible-playbook ansidot/ansidot.yml --inventory localhost, --connection local --extra-vars @apps.yml
```
