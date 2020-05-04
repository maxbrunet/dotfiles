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

Install Go tools

```shell
GO111MODULE=on awk -F'"' '/_/{cmd = sprintf("go get %s", $2); print cmd; system(cmd)}' Gofile.go
ln -s kubectx ~/.local/bin/kubectl-ctx
ln -s kubens ~/.local/bin/kubectl-ns
```
