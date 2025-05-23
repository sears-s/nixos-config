{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.vnc.enable {

  services = {
    # Disable monitor management
    kanshi.enable = lib.mkForce false;

    # Disable idle manager
    swayidle.enable = lib.mkForce false;
  };

  # Add service that starts sway
  systemd.user = {
    services."wayvnc" = {
      Install.WantedBy = [ "default.target" ];
      Service = {
        Environment = [
          # Path needed because sway calls sh, uname without absolute path
          # Can also use lib.makeBinPath for each relevant package
          "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/${specialArgs.username}/bin"
          "WLR_BACKENDS=headless"
          "WLR_LIBINPUT_NO_DEVICES=1"
        ];
        ExecStart = [ (lib.getExe pkgs.sway) ];
        Restart = "always";
        RestartSec = "30";
      };
      Unit = {
        Description = "sway with wayvnc (VNC server)";
        After = [ "default.target" ];
        PartOf = [ "default.target" ];
        # Start the pulseaudio TCP server
        Wants = [ "pulseaudio.service" ];
      };
    };

    # User service won't automatically start without this
    startServices = "sd-switch";
  };

  wayland.windowManager.sway.config = {
    # Change the modifier from Super to Alt
    modifier = lib.mkForce "Mod1";

    # Set headless resolution from host config
    output.HEADLESS-1.resolution = specialArgs.vnc.resolution;

    # Start wayvnc on sway startup
    startup = [
      {
        command = "${lib.getExe pkgs.wayvnc} -g -o HEADLESS-1 0.0.0.0 5900 &>> /tmp/wayvnc.log";
      }
    ];
  };
}
