{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "virtualbox";

  environment.sessionVariables = {
    # https://github.com/swaywm/sway/issues/3814
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  users.users.maxime.extraGroups = [ "vboxsf" ];
}
