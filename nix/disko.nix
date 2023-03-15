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
            type = "partition";
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
            type = "partition";
            name = "primary";
            start = "128MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              keyFile = "/tmp/cryptroot.key";
              extraArgs = [ "--type" "luks1" "--hash" "sha512" ];
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
