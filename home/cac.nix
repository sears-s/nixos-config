{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.cac {
  # Source: https://nixos.wiki/wiki/Web_eID

  # Configure Firefox to use p11-kit-proxy
  programs.firefox.policies.SecurityDevices.p11-kit-proxy = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";

  # One shot service to add the module for Chromium browsers
  systemd.user.services.chromium-smartcard = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Environment = [
        "PATH=${
          lib.makeBinPath (
            with pkgs;
            [
              coreutils
              nssTools
            ]
          )
        }"
      ];
      ExecStart = pkgs.writeShellScript "chromium-smartcard.sh" ''
        set -e
        nssdb=~/.pki/nssdb
        mkdir -p $nssdb
        modutil -force -dbdir sql:$nssdb -add p11-kit-proxy \
          -libfile ${pkgs.p11-kit}/lib/p11-kit-proxy.so
        echo "Smartcard module added to Chromium NSS database at $nssdb"
      '';
      Type = "oneshot";
    };
    Unit.Description = "Adds smartcard module for Chromium browsers";
  };
}
