{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "BRUNETM-X1";

  services.fprintd.enable = true;
}
