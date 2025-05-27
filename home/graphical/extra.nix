{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf (specialArgs.graphical && specialArgs.extra) {
  home.packages = with pkgs; [
    bluebubbles # iMessage client
    discord-canary # official Discord client, beta Wayland support
    foliate # eBook reader
    obsidian # markdown notes
    onlyoffice-desktopeditors # office suite
    qbittorrent # BitTorrent client
    remmina # RDP/VNC client
    slack # official Slack client
    spotify # official Spotify client
    vlc # video player
    zoom-us # official Zoom client
  ];

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

  wayland.windowManager.sway.config = {
    keybindings =
      let
        inherit (config.wayland.windowManager.sway.config) defaultWorkspace;
        mod = config.wayland.windowManager.sway.config.modifier;
        apps = [
          ''class="Brave-browser"''
          ''class="obsidian"''
          ''class="Spotify"''
          ''class="discord"''
          ''class="Slack"''
          ''app_id="bluebubbles"''
        ];
      in
      # mkOptionDefault merges with default configuration
      lib.mkOptionDefault {
        # Move windows to layout for a small screen
        "${mod}+Ctrl+1" = lib.concatImapStringsSep ";" (
          i: app: "[${app}] move workspace number ${toString i}"
        ) apps;

        # Move windows to layout for a large screen
        "${mod}+Ctrl+2" = lib.concatStringsSep ";" (
          # Stage the windows in workspace 10
          (builtins.map (app: "[${app}] move workspace number 10") apps)
          ++ [
            "[${builtins.elemAt apps 0}] move ${defaultWorkspace}"
            "[${builtins.elemAt apps 0}] splitv"
            "[${builtins.elemAt apps 1}] move ${defaultWorkspace}"
            "[${builtins.elemAt apps 2}] move ${defaultWorkspace}"
            "[${builtins.elemAt apps 2}] move right"
            "[${builtins.elemAt apps 2}] splitv"
            "[${builtins.elemAt apps 3}] move ${defaultWorkspace}"
            "[${builtins.elemAt apps 3}] move up"
            "[${builtins.elemAt apps 3}] splith"
            "[${builtins.elemAt apps 4}] move ${defaultWorkspace}"
            "[${builtins.elemAt apps 4}] move up"
            "[${builtins.elemAt apps 4}] move up"
            "[${builtins.elemAt apps 5}] move ${defaultWorkspace}"
            "[${builtins.elemAt apps 5}] move up"
            "[${builtins.elemAt apps 5}] move up"
            "[${builtins.elemAt apps 3}] layout tabbed"
          ]
        );
      };

    # Open apps on startup
    startup = builtins.map (app: { command = lib.getExe app; }) (
      with pkgs;
      [
        brave
        obsidian
        spotify
        discord-canary
        slack
        bluebubbles
      ]
    );
  };
}
