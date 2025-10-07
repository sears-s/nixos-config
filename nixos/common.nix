{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  # Use the systemd-boot EFI boot loader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable redistributable firmware
  hardware.enableRedistributableFirmware = true;

  # Networking configuration
  networking = {
    # Set hostname
    inherit (specialArgs) hostName;

    # Enable firewall
    firewall.enable = true;

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

    settings = {
      # Enable Flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Set trusted user
      trusted-users = [ specialArgs.username ];
    };
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
    # Encrypted DNS
    dnscrypt-proxy2 = {
      enable = false;
      settings = {
        ignore_system_dns = false; # hopefully fixes captive portals
        require_dnssec = true;
      };
      # Defaults: https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
    };

    # Firmware updater
    fwupd.enable = true;

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
    # System version to base persistent data off of - do not change
    inherit (specialArgs) stateVersion;

    # Update weekly from GitHub Flake
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      rebootWindow = {
        lower = "02:00";
        upper = "04:00";
      };
      dates = "weekly";
      flake = "github:sears-s/nixos-config";
      flags = [ "--impure" ];
    };
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
        extraGroups = [
          "wheel"
        ]
        ++ lib.optional config.networking.networkmanager.enable "networkmanager"
        ++ lib.optionals config.virtualisation.libvirtd.enable [
          "libvirtd"
          # Required by winapps
          "libvirt"
          "kvm"
        ];
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
