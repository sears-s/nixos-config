{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf (specialArgs.graphical && specialArgs.security) {

  # Programs not available as a home-manager program
  home.packages = with pkgs; [
    autopsy # disk forensics tool
    burpsuite # web exploitation
    ghidra # reverse engineering
    wireshark # view PCAPs (TODO: how to run capture)
  ];
}
