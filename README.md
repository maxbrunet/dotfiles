# My Awesome Dotfiles

My dotfiles collection for a flawless workflow. Starring `zsh`, `nvim` and `tmux`.

![Screenshot](screenshot.png)

## How to setup

```shell
git clone git@github.com:maxbrunet/dotfiles.git ~/.config/nixpkgs
home-manager switch
nvim +PackerSync
```

Install Go tools

```shell
export GO111MODULE='on'
go get -u github.com/bwplotka/bingo
bingo get -l
ln -s kubectx ~/.local/bin/kubectl-ctx
ln -s kubens ~/.local/bin/kubectl-ns
```

Install Rust toolchain

```shell
rustup toolchain install stable --component rls
```
