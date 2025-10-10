{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.graphical {
  # Enable hardware accelerated graphics drivers
  hardware.graphics.enable = true;

  security = {
    pam.services = {
      # Needed to make swaylock work
      swaylock = { };

      # Automatically unlock gnome-keyring on login
      greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };

    # Enable polkit
    polkit.enable = true;
  };

  # Enable greeter if not VM
  services.greetd = lib.mkIf (!specialArgs.vm) {
    enable = true;
    settings.default_session = {
      command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd sway";
      user = "greeter";
    };
  };

  # Fix greetd log spam
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
