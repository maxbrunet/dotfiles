{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  disko.devices = import ../../disko.nix { disks = [ "/dev/nvme0n1" ]; };

  networking.hostName = "BRUNETM-X1";

  services.fprintd.enable = true;
}
