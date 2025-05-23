{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.cac {
  # Tell p11-kit to load/proxy opensc-pkcs11.so
  # Source: https://wiki.nixos.org/w/index.php?title=Web_eID
  environment.etc."pkcs11/modules/opensc-pkcs11".text = "module: ${pkgs.opensc}/lib/opensc-pkcs11.so";

  # Install DoD certificates by downloading and parsing bundle
  security.pki.certificateFiles = [
    "${
      pkgs.stdenv.mkDerivation {
        name = "dod-certificates";
        src = pkgs.fetchzip {
          url = "https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip";
          sha256 = "sha256-HhbGyHgwV8bbZutDqhHriso3y84XxumtuED9BHO0XEk=";
        };
        phases = [
          "unpackPhase"
          "buildPhase"
        ];
        buildInputs = [ pkgs.openssl ];
        buildPhase = ''
          mkdir -p $out
          openssl pkcs7 -print_certs -inform der -in *_DoD.der.p7b -out $out/dod-certificates.pem
        '';
      }
    }/dod-certificates.pem"
  ];

  # Smart card daemon
  services.pcscd.enable = true;
}
