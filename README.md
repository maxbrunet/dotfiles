# NaxOS

My [NixOS](https://nixos.org) configuration.

![Screenshot](screenshot.png)

## Bootstrap

> **Warning**
>
> All data will be erased to install NixOS! These instructions are not indented for any users but myself (@maxbrunet), read scripts carefully!

Download and boot the [NixOS installer](https://nixos.org/download.html#nixos-iso), then:

```shell
sudo -i
wpa_passphrase <ESSID> | tee /etc/wpa_supplicant.conf
wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant.conf
nix-env -iA nixos.git
git clone https://github.com/maxbrunet/naxos.git
cd naxos
./bootstrap.sh
# Change TTY (not tty1) or reboot and login
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update
/etc/nixos/bootstrap-user.sh
```

If running in VirtualBox, ensure:

* EFI is enabled
* 3D acceleration is enabled
* Solid-state Drive is checked for the virtual disk
* The following variables are exported before starting `sway` (e.g. set from `~/.zshenv`):

  ```shell
  export WLR_NO_HARDWARE_CURSORS=1
  export LIBGL_ALWAYS_SOFTWARE=1
  ```

## Set up Xbox app

The Android app can be used for [Xbox Remote Play](https://www.xbox.com/en-US/consoles/remote-play) on Linux.

```shell
sudo waydroid init
sudo systemctl start waydroid-container

# Start a session with:
# waydroid session start

# Only keep Settings and Xbox apps enabled
UNNEEDED_APPS=(
  com.android.calculator2
  com.android.camera2
  com.android.contacts
  com.android.deskclock
  com.android.documentsui
  com.android.gallery3d
  com.android.inputmethod.latin
  org.lineageos.eleven
  org.lineageos.etar
  org.lineageos.jelly
  org.lineageos.recorder
)
for app in "${UNNEEDED_APPS[@]}"; do
  sudo lxc-attach --lxcpath=/var/lib/waydroid/lxc/ --name=waydroid --clear-env -- pm disable "${app}"
  rm -f "${HOME}/.local/share/applications/waydroid.${app}.desktop"
done

# Download APK: https://apkpure.com/xbox/com.microsoft.xboxone.smartglass
waydroid app install /path/to/Xbox.apk
waydroid prop set persist.waydroid.fake_wifi com.microsoft.xboxone.smartglass
```
