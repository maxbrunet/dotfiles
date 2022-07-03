{ pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/lenovo/thinkpad/x1/9th-gen>
      ./hardware-configuration.nix
    ];

  networking.hostName = "BRUNETM-X1";

  services.fprintd.enable = true;
}
