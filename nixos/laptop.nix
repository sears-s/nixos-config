{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.laptop {
  # Add NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Enable NetworkManager and WiFi
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  services = {
    # Automatic timezone
    # TODO: geoclue can't see WiFi
    # automatic-timezoned.enable = true;

    # Needed for casting
    avahi.enable = true;

    # Bluetooth manager
    blueman.enable = config.hardware.bluetooth.enable;

    # Thunderbolt daemon
    hardware.bolt.enable = true;

    # Enable sound
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Enable power management
    # TODO: replace with tuneD when available for Nix
    tlp.enable = true;

    # Automatically mount removable media to /run/media
    udisks2.enable = true;
  };

  # Disable reboots after automatic updates
  system.autoUpgrade.allowReboot = lib.mkForce false;

  # Keep SSH installed but disable the service
  systemd.services.sshd = {
    wantedBy = lib.mkForce [ ];
    stopIfChanged = lib.mkForce true;
  };
}
