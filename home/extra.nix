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
    distrobox # containers integrated with host
    glow # terminal Markdown renderer
    grex # generate regex from test cases
    mosh # client for supported SSH servers on poor connections
    pciutils # PCI device utilities
    progress # show progress for coreutil programs like cp, mv
    pv # show progress for pipes
    viu # terminal image viewer (kitty or ghostty)
    speedtest-cli # internet speed test
    usql # universal SQL client
    up # pipe previewer
    wireguard-tools # includes wg-quick
  ];

  programs = {
    # Alternative to top
    # btm command
    bottom.enable = true;

    # Development environment switcher
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Alternative to ls
    # TODO: aliases and options
    eza.enable = true;

    # Fuzzy file finder
    # Ctrl+T = find files and directories
    # Alt+C = find directories
    fzf.enable = true;

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
