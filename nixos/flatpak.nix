{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  # If lib.mkIf is used, imports isn't recognized
  imports = lib.optionals (specialArgs.extra && specialArgs.graphical) [
    specialArgs.inputs.nix-flatpak.nixosModules.nix-flatpak
    {
      services.flatpak = {
        enable = true;
        packages = [ "app.openbubbles.OpenBubbles" ];

        # Update flatpaks on system change
        update.onActivation = true;

        # Don't allow other flatpaks
        uninstallUnmanaged = true;
      };

      # Otherwise assertion fails for enabling flatpak
      # Also defined in home config
      xdg.portal = {
        enable = true;
        # TODO: correctly set config https://mynixos.com/nixpkgs/option/xdg.portal.config
        config.common.default = "*";
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };
    }
  ];
}
