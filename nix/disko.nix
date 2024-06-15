{ disks ? [ "/dev/sdb" ], ... }:

let
  device = builtins.elemAt disks 0;
  deviceName = builtins.baseNameOf device;
in
{
  disk = {
    ${deviceName} = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "ESP";
            type = "EF00";
            size = "128M";
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [ "-F" "32" "-n" "EFI" ];
              mountpoint = "/boot/efi";
              mountOptions = [ "umask=077" ];
            };
          };
          primary = {
            label = "primary";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
                keyFile = "/tmp/cryptroot.key";
              };
              extraFormatArgs = [ "--type" "luks1" "--hash" "sha512" ];
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [ "-L" "nixos" ];
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
