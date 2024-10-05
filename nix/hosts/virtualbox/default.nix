{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  disko.devices = import ../../disko.nix { disks = [ "/dev/sda" ]; };

  networking.hostName = "virtualbox";

  environment.sessionVariables = {
    # https://github.com/swaywm/sway/issues/3814
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  users.users.maxime.extraGroups = [ "vboxsf" ];

  # Requires rebuild of VirtualBox, which is unlikely to be used.
  virtualisation.virtualbox.host.enableExtensionPack = lib.mkForce false;
}
