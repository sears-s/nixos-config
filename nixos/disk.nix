{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  imports = [ specialArgs.inputs.disko.nixosModules.disko ];
  disko.devices = {
    disk.main = {
      inherit (specialArgs.disk) device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # Boot partition for MBR/BIOS compatibility
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          # ESP partition for UEFI
          esp = {
            name = "esp";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          # System partition
          system = {
            size = "100%";
            content =
              let
                # Common mount options
                btrfsMountOptions = [
                  "compress-force=zstd:2"
                  "noatime"
                ];

                # Encrypted partition
                luks = {
                  name = "luks";
                  type = "luks";
                  settings = {
                    allowDiscards = true; # allow SSD TRIM
                    bypassWorkqueues = true; # increase SSD performance
                  };
                  extraFormatArgs = [
                    "--type luks2"
                    "-c aes-xts-plain64" # cipher
                    "-s 512" # cipher key size
                    "-h sha512" # hash
                    "--pbkdf argon2id" # key derivation function
                    "-i 3000" # milliseconds for key derivation
                  ];
                  content = {
                    # Unencrypted partition
                    type = "btrfs";
                    extraArgs = [
                      "-f" # Override existing parittion
                      "--csum xxhash" # Slightly faster and more secure checksum algorithm than default CRC32
                    ];
                    postCreateHook = lib.mkIf (specialArgs.disk.tmpfsSize == "0G") ''
                      mp=$(mktemp -d)
                      mount -o subvol=root ${specialArgs.disk.rootDevice} $mp
                      trap 'umount $mp; rm -rf $mp' EXIT
                      btrfs subvolume snapshot -r $mp/root $mp/root-blank
                    '';
                    subvolumes = {
                      root = lib.mkIf (specialArgs.disk.tmpfsSize == "0G") {
                        mountpoint = "/";
                        mountOptions = btrfsMountOptions;
                      };
                      nix = {
                        mountpoint = "/nix";
                        mountOptions = btrfsMountOptions;
                      };
                      persist = {
                        mountpoint = specialArgs.persistDir;
                        mountOptions = btrfsMountOptions;
                      };
                      swap = {
                        mountpoint = "/.swap";
                        swap.swapfile.size = specialArgs.disk.swapSize;
                      };
                    };
                  };
                };
              in
              if specialArgs.disk.encrypt then luks else luks.content;
          };
        };
      };
    };
    # RAM partition for files that will not persist
    nodev."/" = lib.mkIf (specialArgs.disk.tmpfsSize != "0G") {
      fsType = "tmpfs";
      mountOptions = [
        "size=${specialArgs.disk.tmpfsSize}"
        "mode=755"
      ];
    };
  };

  # Mount persist subvolume early enough
  fileSystems."${specialArgs.persistDir}".neededForBoot = true;
}
