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
    ghidra # reverse engineering
  ];
}
