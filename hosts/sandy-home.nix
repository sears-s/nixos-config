{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
{
  # Extra home packages for host
  home.packages = with pkgs; [ gpclient ];

  # Setup monitor profiles
  services.kanshi.settings = [
    {
      output = {
        criteria = "Chimei Innolux Corporation 0x14D4 Unknown";
        alias = "laptop";
        mode = "1920x1080@60Hz";
        scale = 1.25;
        status = "enable";
      };
    }
    {
      output = {
        criteria = "ASUSTek COMPUTER INC XG43UQ 1322131231233";
        alias = "monitor";
        mode = "3840x2160@60Hz";
        scale = 1.5;
        status = "enable";
      };
    }
    {
      output = {
        criteria = "Jiangxi Jinghao Optical Co., Ltd. P2-L P2-20230215";
        alias = "left";
        mode = "1920x1080@60Hz";
        scale = 1.25;
        status = "enable";
      };
    }
    {
      output = {
        criteria = "Jiangxi Jinghao Optical Co., Ltd. P2-R P2-20230215";
        alias = "right";
        mode = "1920x1080@60Hz";
        scale = 1.25;
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
            position = "0,0";
          }
          {
            criteria = "$monitor";
            # Y = 1080 / 1.25
            position = "1536,0";
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
            criteria = "$monitor";
            position = "0,0";
          }
        ];
      };
    }
    {
      profile = {
        name = "triple";
        outputs = [
          {
            criteria = "$left";
            position = "0,0";
          }
          {
            criteria = "$laptop";
            position = "1536,0";
          }
          {
            criteria = "$right";
            position = "3072,0";
          }
        ];
      };
    }
  ];

  # Handle lid for kanshi profiles
  wayland.windowManager.sway.extraConfig =
    let
      bCmd = "bindswitch --locked --reload lid:";
      kCmd = "${lib.getExe' pkgs.kanshi "kanshictl"} switch";
    in
    ''
      ${bCmd}on exec ${kCmd} docked-closed
      ${bCmd}off exec ${kCmd} triple || ${kCmd} docked-open || ${kCmd} undocked
    '';
}
