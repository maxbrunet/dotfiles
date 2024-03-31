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
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "1MiB";
            end = "128MiB";
            flags = [ "esp" ];
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [ "-F" "32" "-n" "EFI" ];
              mountpoint = "/boot/efi";
            };
          }
          {
            name = "primary";
            start = "128MiB";
            end = "100%";
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
          }
        ];
      };
    };
  };
}
