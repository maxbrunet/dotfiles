# NaxOS

My [NixOS](https://nixos.org) configuration.

## Bootstrap

**⚠️ Warning: All data will be erased to install NixOS! These instructions are not indented for any users but myself (@maxbrunet), read scripts carefully!**

```shell
sudo -i
wpa_passphrase <ESSID> | tee /etc/wpa_supplicant.conf
wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant.conf
nix-env -iA nixos.git
git clone https://github.com/maxbrunet/naxos.git
cd naxos
./bootstrap.sh
reboot
# Login
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update
/etc/nixos/bootstrap-user.sh
```
