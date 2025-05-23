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
  systemd.user.services.chromium-p11-kit-proxy = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Environment = [
        "PATH=${
          lib.makeBinPath (
            with pkgs;
            [
              coreutils
              gnugrep
              nssTools
            ]
          )
        }"
      ];
      ExecStart = pkgs.writeShellScript "chromium-p11-kit-proxy.sh" ''
        set -e
        nssdb=~/.pki/nssdb
        mod=p11-kit-proxy

        # Check if the module already exists
        if [ -d $nssdb ] && modutil -dbdir sql:$nssdb -list | grep -q $mod; then
          echo "$mod module already exists in Chromium NSS database at $nssdb"
        else
          # Add the module
          mkdir -p $nssdb
          modutil -force -dbdir sql:$nssdb -add p11-kit-proxy \
            -libfile ${pkgs.p11-kit}/lib/p11-kit-proxy.so
          echo "$mod module added to Chromium NSS database at $nssdb"
        fi
      '';
      Type = "oneshot";
    };
    Unit.Description = "add p11-kit-proxy module to Chromium browsers for smartcard support";
  };
}
