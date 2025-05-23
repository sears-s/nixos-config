{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  # TODO: move this
  imports = [ specialArgs.inputs.impermanence.nixosModules.impermanence ];
  boot = {
    # If not using tmpfs for snapshots, rollback the BTRFS subvolume
    initrd.postResumeCommands = lib.mkIf (specialArgs.disk.tmpfsSize == "0G") (
      lib.mkAfter ''
        mp=$(mktemp -d)
        mount -o subvol=root ${specialArgs.disk.rootDevice} $mp
        if [[ -e $mp/root ]]; then
          mkdir -p $mp/old_roots
          timestamp=$(date --date="@$(stat -c %Y $mp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv $mp/root "$mp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "$mp/$i"
          done
          btrfs subvolume delete "$1"
        }

        for i in $(find $mp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
        done

        btrfs subvolume create $mp/root
        umount $mp
        rm -rf $mp
      ''
    );

    # Use the systemd-boot EFI boot loader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    # System packages
    systemPackages = with pkgs; [
      vim
      wget
    ];

    # Impermanence - directories/files to persist
    persistence."${specialArgs.persistDir}" = {
      hideMounts = true;
      directories =
        [
          "/var/db/sudo/lectured" # warning message for first-time sudo use
          "/var/lib/dhcpcd" # DHCP leases
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/timers"
          "/var/log"
        ]
        # Bluetooth directory
        ++ lib.optional config.hardware.bluetooth.enable "/var/lib/bluetooth"

        # NetworkManager directories
        ++ lib.optionals config.networking.networkmanager.enable [
          "/etc/NetworkManager/system-connections"
          "/var/lib/NetworkManager"
        ]

        # libvirt directory
        ++ lib.optional config.virtualisation.libvirtd.enable "/var/lib/libvirt"

        # Podman directory
        ++ lib.optional config.virtualisation.containers.enable "/var/lib/containers";

      files =
        [
          "/etc/machine-id" # machine identifier for logs
        ]
        # SSH host keys
        ++ lib.optionals config.services.openssh.enable lib.concatMap (key: [
          key.path
          (key.path + ".pub")
        ]) config.services.openssh.hostKeys;

      users.${specialArgs.username} = {
        files =
          # GUI application files
          lib.optional specialArgs.graphical ".config/remmina/remmina.pref";

        directories =
          [
            # User SSH directory
            {
              directory = ".ssh";
              mode = "0700";
            }
            "notes"
            "perm"
            "proj"
            "tmp"
          ]
          # Fish command history - error if file used
          ++ lib.optional config.programs.fish.enable ".local/share/fish"

          # Podman directory
          ++ lib.optional config.virtualisation.containers.enable ".local/share/containers"

          # GUI application directories
          ++ lib.optionals specialArgs.graphical [
            ".config/BraveSoftware/Brave-Browser"
            ".config/discordcanary"
            ".config/obsidian"
            ".config/spotify"
            ".config/Slack"
            ".mozilla/firefox"
            ".local/share/keyrings"
            ".local/share/remmina"
            ".local/state/wireplumber"
          ];
      };
    };
  };

  # Enable redistributable firmware
  hardware.enableRedistributableFirmware = true;

  # Networking configuration
  networking = {
    # Enable firewall
    firewall.enable = true;

    # Set hostname
    hostName = specialArgs.hostName;

    # DHCP by default
    # Conflicts with networkmanager module
    useDHCP = lib.mkDefault true;
  };

  # Nix specific
  nix = {
    # Weekly garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Should be enabled by settings.experimental-features
    extraOptions = "experimental-features = nix-command flakes";

    # Weekly store optimization
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Enable Flakes
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;

    # Set arch like hardware configuration
    hostPlatform = specialArgs.system;
  };

  # Fish shell needs to be enabled in NixOS and Home Manager
  programs.fish.enable = true;

  services = {
    # Firmware updater
    fwupd.enable = true;

    # Fix geoclue2 provider URL
    # TODO: fixed in new release?
    geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

    # SSH server
    openssh = {
      enable = true;
      settings = {
        AllowUsers = [ "${specialArgs.username}" ];
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  system = {
    # Update weekly from GitHub Flake
    autoUpgrade = {
      enable = false; # TODO: disable until GitHub setup
      allowReboot = true;
      rebootWindow = {
        lower = "02:00";
        upper = "04:00";
      };
      dates = "weekly";
      flake = "github:sears-s/nix-config";
    };

    # System version to base persistent data off of - do not change
    stateVersion = specialArgs.stateVersion;
  };

  # Set the timezone
  # Conflicts with auto timezone
  time.timeZone = lib.mkDefault "US/Central";

  # Users configuration
  users = {
    # Disable creation of new users/groups
    mutableUsers = false;

    users = {
      # Disable root account
      root.hashedPassword = "!";

      # Create user
      ${specialArgs.username} = {
        description = "Sears Schulz";
        extraGroups =
          [ "wheel" ]
          ++ lib.optional config.networking.networkmanager.enable "networkmanager"
          ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd";
        hashedPasswordFile = "${specialArgs.persistDir}/hashedPassword";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ specialArgs.sshPublicKey ];
        shell = pkgs.fish;
      };
    };
  };

  # Enable Podman
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # enables docker alias
      defaultNetwork.settings.dns_enabled = true; # required for podman-compose

      # Weekly prune
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--all"
          "--volumes"
        ];
      };
    };
  };
}
