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
    # Needed to make swaylock work
    pam.services.swaylock = { };

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
