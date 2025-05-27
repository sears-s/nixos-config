{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  imports = [ specialArgs.inputs.impermanence.nixosModules.impermanence ];

  # Impermanence - directories/files to persist
  environment.persistence."${specialArgs.persistDir}" = {
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

    users.${specialArgs.username}.directories =
      [
        ".cache"
        ".local/share/systemd/timers"
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

      # Winapps directory
      ++ lib.optional (specialArgs.graphical && specialArgs.hypervisor) ".local/share/winapps"

      # GUI application directories
      ++ lib.optionals specialArgs.graphical [
        ".mozilla/firefox"
        ".local/share/applications"
        ".local/share/keyrings"
        ".local/state/wireplumber"
      ]

      # Extra GUI application directories
      ++ lib.optionals (specialArgs.graphical && specialArgs.extra) [
        ".config/BraveSoftware/Brave-Browser"
        ".config/discordcanary"
        ".config/obsidian"
        ".config/remmina"
        ".config/spotify"
        ".config/Slack"
        ".local/share/app.bluebubbles.BlueBubbles"
        ".local/share/remmina"
      ];
  };
}
