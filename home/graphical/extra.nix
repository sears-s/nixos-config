{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf (specialArgs.graphical && specialArgs.extra) {
  home.packages =
    with pkgs;
    [
      bluebubbles # iMessage client
      foliate # eBook reader
      obsidian # markdown notes
      onlyoffice-desktopeditors # office suite
      qbittorrent # BitTorrent client
      remmina # RDP/VNC client
      slack # official Slack client
      spotify # official Spotify client
      vlc # video player
      zoom-us # official Zoom client
    ]
    ++
      lib.optional (specialArgs.hostName != "mip") # canary.dl2.discordapp.net blocked
        discord-canary; # official Discord client, beta Wayland support

  programs = {
    # Brave browser
    chromium = {
      enable = true;
      package = pkgs.brave;
    };

    # Screen recorder
    obs-studio.enable = true;
  };

  # Set default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = [ "brave-browser.desktop" ];
      in
      {
        "application/pdf" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "application/xhtml+xml" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/chrome" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/unknown" = browser;
      };
  };
}
