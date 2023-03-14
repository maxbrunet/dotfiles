# My Awesome Dotfiles

My dotfiles collection for a flawless workflow. Starring `zsh`, `nvim`, `tmux`, and [NixOS](https://nixos.org).

![Screenshot](screenshot.png)

## Bootstrapping NixOS

> **Warning**
>
> All data will be erased to install NixOS! These instructions are not indented for any users but myself (**@maxbrunet**), read scripts carefully!

Download and boot the [NixOS installer](https://nixos.org/download.html#nixos-iso), then:

```shell
sudo -i
wpa_passphrase <ESSID> | tee /etc/wpa_supplicant.conf
wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant.conf
nix-env -iA nixos.git
git clone https://github.com/maxbrunet/dotfiles.git
cd dotfiles
./scripts/bootstrap.sh <HOSTNAME>
```

Generate SSH key:

```shell
/etc/nixos/scripts/generate-ssh-key.sh
```

Install Rust toolchain

```shell
rustup toolchain install stable
```

If running in VirtualBox, ensure:

* EFI is enabled
* 3D acceleration is enabled
* Solid-state Drive is checked for the virtual disk
