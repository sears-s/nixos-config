{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.extra {

  # Programs not available as a home-manager program
  home.packages = with pkgs; [
    devenv # Nix development environments
    dua # alternative to du/ncdu
    distrobox
    glow # terminal Markdown renderer
    pciutils # PCI device utilities
    speedtest-cli # internet speed test
    wireguard-tools # includes wg-quick
  ];

  programs = {
    # Alternative to top
    bottom.enable = true;

    # Development environment switcher
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Alternative to ls
    # TODO: aliases and options
    eza.enable = true;

    # git TUI
    lazygit.enable = true;

    # Alternative to grep
    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--smart-case"
      ];
    };

    # Alternative to man (tldr)
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };
}
