{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  # If lib.mkIf is used, imports isn't recognized
  imports = lib.optionals specialArgs.secureBoot [
    specialArgs.inputs.lanzaboote.nixosModules.lanzaboote
    (
      let
        pkiDir = "/var/lib/sbctl";
      in
      {
        boot = {
          lanzaboote = {
            enable = true;
            pkiBundle = pkiDir;
          };
          loader.systemd-boot.enable = lib.mkForce false;
        };
        environment.persistence."${specialArgs.persistDir}".directories = [ pkiDir ];
      }
    )
  ];
}
