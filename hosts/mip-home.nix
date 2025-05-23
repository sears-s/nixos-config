{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
{
  # Setup monitor profiles
  services.kanshi.settings = [
    {
      output = {
        criteria = "BOE 0x08C5 Unknown";
        alias = "laptop";
        mode = "1920x1080@60Hz";
        scale = 1.0;
        status = "enable";
      };
    }
    {
      output = {
        criteria = "Samsung Electric Company LS32A80 HCRWA02257";
        alias = "left";
        mode = "3840x2160@60Hz";
        scale = 1.5;
        status = "enable";
        transform = "90";
      };
    }
    {
      output = {
        criteria = "Samsung Electric Company LS32A80 HCRWA02259";
        alias = "right";
        mode = "3840x2160@60Hz";
        scale = 1.5;
        status = "enable";
      };
    }
    {
      profile = {
        name = "undocked";
        outputs = [
          {
            criteria = "$laptop";
            position = "0,0";
          }
        ];
      };
    }
    {
      profile = {
        name = "docked-open";
        outputs = [
          {
            criteria = "$laptop";
            position = "0,1080";
          }
          {
            criteria = "$left";
            position = "1920,0";
          }
          {
            criteria = "$right";
            # X = 1920 + (2160 / 1.5)
            # Y = ((3840 - 2160) / 2) / 1.5
            position = "3360,560";
          }
        ];
      };
    }
    {
      profile = {
        name = "docked-closed";
        outputs = [
          {
            criteria = "$laptop";
            status = "disable";
          }
          {
            criteria = "$left";
            position = "0,0";
          }
          {
            criteria = "$right";
            # X = 2160 / 1.5
            # Y = ((3840 - 2160) / 2) / 1.5
            position = "1440,560";
          }
        ];
      };
    }
  ];

  wayland.windowManager.sway = {
    # Handle lid for kanshi profiles
    extraConfig =
      let
        bCmd = "bindswitch --locked --reload lid:";
        kCmd = "${lib.getExe' pkgs.kanshi "kanshictl"} switch";
      in
      ''
        ${bCmd}on exec ${kCmd} docked-closed
        ${bCmd}off exec ${kCmd} triple || ${kCmd} docked-open || ${kCmd} undocked
      '';

    # Force sway to work with Nvidia
    extraOptions = [ "--unsupported-gpu" ];
  };
}
