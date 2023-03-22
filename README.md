# My Awesome Dotfiles

My dotfiles collection for a flawless workflow. Starring `zsh`, `nvim`, `tmux`, and [NixOS](https://nixos.org).

![Screenshot](screenshot.png)

## Bootstrapping NixOS

> **Warning**
>
> All data will be erased to install NixOS! These instructions are not indented for any users but myself (**@maxbrunet**), read scripts carefully!

1. Download and boot the [NixOS installer](https://nixos.org/download.html#nixos-iso)
2. If using WiFi, connect to it:

    ```shell
    wpa_passphrase <ESSID> | sudo tee /etc/wpa_supplicant.conf
    sudo wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant.conf
    ```

3. Run bootstrap script:

    ```shell
    sudo -i
    nix-env -iA nixos.git
    git clone https://github.com/maxbrunet/dotfiles.git
    cd dotfiles
    ./scripts/bootstrap.sh <HOSTNAME>
    reboot
    ```

4. Generate SSH key:

    ```shell
    /etc/nixos/scripts/generate-ssh-key.sh
    ```

5. Install Rust toolchain:

    ```shell
    rustup toolchain install stable
    ```

> **Note**
>
> If running in VirtualBox, ensure:
> 
> * EFI is enabled
> * 3D acceleration is enabled
> * Solid-state Drive is checked for the virtual disk
