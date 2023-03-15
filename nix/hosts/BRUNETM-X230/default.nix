{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  disko.devices = import ../../disko.nix { disks = [ "/dev/sda" ]; };

  hardware.firmware = with pkgs; [
    # Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
    # Bluetooth: hci0: BCM: firmware Patch file not found
    broadcom-bt-firmware
  ];

  networking.hostName = "BRUNETM-X230";
}
