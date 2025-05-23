{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.graphical {
  # Set default font
  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "${specialArgs.fontMono} Nerd Font Mono" ];
  };

  home.packages =
    with pkgs;
    [
      # TODO: bluebubbles
      foliate # eBook reader
      font-awesome # extra icons
      obsidian # markdown notes
      onlyoffice-desktopeditors # office suite
      # TODO: replace with nerd-fonts.* in 25.05
      (nerdfonts.override { fonts = [ specialArgs.fontMono ]; }) # font with icons
      pavucontrol # audio controller
      qbittorrent # BitTorrent client
      remmina # RDP/VNC client
      slack # official Slack client
      spotify # official Spotify client
      vlc # video player
      wl-clipboard # Wayland clipboard support
      zoom # official Zoom client
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

    firefox = {
      enable = true;
      policies = {
        ExtensionSettings =
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "force_installed";
              };
            };
          in
          builtins.listToAttrs [
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "ublock-origin" "uBlock0@raymondhill.net")
          ]
          // {
            "*".installation_mode = "blocked"; # Prevent other extensions from being installed
          };
      };
    };

    # Terminal emulator
    # TODO: consider ghostty, wezterm
    foot = {
      enable = true;
      settings.main.font = "${specialArgs.fontMono} Nerd Font Mono:size=11";
    };

    # Screen recorder
    obs-studio.enable = true;

    # Launcher
    # TODO: add plugins
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };

    # Idle screen locker
    swaylock = lib.mkIf (!specialArgs.vm) {
      enable = true;
      settings = {
        color = "000000";
        daemonize = true;
        show-failed-attempts = true;
      };
    };

    # Status bar
    waybar = {
      enable = true;
      settings.mainBar =
        let
          interval = 5;
          spacing = 4;
        in
        {
          # TODO: add custom/media with mediaplayer.py
          inherit spacing;
          position = "top";
          modules-left = [
            "systemd-failed-units"
            "temperature"
            "cpu"
            "memory"
            "disk"
            "sway/workspaces"
            "sway/mode"
            "sway/scratchpad"
          ];
          modules-center = [ "clock" ];
          modules-right =
            [
              "tray"
              "keyboard-state"
              "pulseaudio"
              "network"
            ]
            ++ lib.optional (!specialArgs.vm) "idle_inhibitor"
            ++ lib.optionals specialArgs.laptop [
              "backlight"
              "battery"
            ];
          backlight = lib.mkIf specialArgs.laptop {
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
            tooltip = false;
          };
          battery = lib.mkIf specialArgs.laptop {
            inherit interval;
            # Only critical setup in default CSS
            states = {
              critical = 15;
              warning = 30;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% {icon} 󱐋";
            format-plugged = "{capacity}% {icon} ";
            format-alt = "{time} {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            tooltip-format = "{timeTo} | {health}% health";
          };
          clock.format = "{:%R | %m/%d/%y}";
          cpu = {
            inherit interval;
            format = "{usage}% ";
            tooltip = false;
          };
          disk = {
            inherit interval;
            format = "{percentage_used}% 󰗮";
            path = specialArgs.persistDir;
          };
          idle_inhibitor = lib.mkIf (!specialArgs.vm) {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };
          keyboard-state = {
            capslock = true;
            numlock = true;
            format = "{name} {icon}";
            format-icons = {
              locked = "";
              unlocked = "";
            };
          };
          memory = {
            inherit interval;
            format = "{percentage}% ";
            tooltip-format = "{used:0.1f} / {total:0.1f} GiB used ({percentage}%) | swap: {swapUsed:0.1f} / {swapTotal:0.1f} GiB used ({swapPercentage}%)";
          };
          network = {
            inherit interval;
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            format-linked = "{ifname} (no ip) ";
            format-disconnected = "off ";
            format-alt = "{ifname} = {ipaddr}/{cidr} ";
            tooltip-format = "{ifname} = {ipaddr}/{cidr} via {gwaddr}";
            on-click = lib.getExe' pkgs.networkmanager "nmtui";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "󰖁 {icon} {format_source}";
            format-muted = "󰖁 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "󰍭";
            format-icons = {
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = lib.getExe pkgs.pavucontrol;
          };
          "sway/mode".format = "<span style=\"italic\">{}</span>";
          "sway/scratchpad" = {
            format = "{icon} {count}";
            format-icons = [
              ""
              ""
            ];
            show-empty = false;
            tooltip = true;
            tooltip-format = "{app}: {title}";
          };
          systemd-failed-units = {
            inherit interval;
            format = "✗ {nr_failed}";
          };
          temperature = {
            inherit interval;
            critical-threshold = 80;
            format-critical = "{temperatureC}°C {icon}";
            format = "{temperatureC}°C {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
            ];
            tooltip = false;
          };
          tray = { inherit spacing; };
        };
    };
  };

  services = {
    # Secrets manager for git
    gnome-keyring.enable = true;

    # Monitor management
    # kanshi.settings defined in host config
    kanshi.enable = !specialArgs.vm;

    # Tray icon for Bluetooth manager
    blueman-applet.enable = osConfig.hardware.bluetooth.enable;

    # Reduces blue light at night
    gammastep = lib.mkIf (!specialArgs.vm) {
      enable = true;
      # TODO: switch to geoclue2 when working
      # provider = "geoclue2";
      latitude = 29.4;
      longitude = -98.5;
    };

    # Notifications
    mako = {
      enable = true;
      defaultTimeout = 10000; # 10s
      ignoreTimeout = true;
    };

    # Idle manager
    swayidle = lib.mkIf (!specialArgs.vm) (
      let
        lockCmd = lib.getExe pkgs.swaylock;
        unlockCmd = "pkill -SIGUSR1 swaylock";
        timeoutCmd = "${lib.getExe' pkgs.sway "swaymsg"} 'output * dpms off'";
        resumeCmd = "${lib.getExe' pkgs.sway "swaymsg"} 'output * dpms on'";
        suspendCmd = "[ '$(< /sys/class/power_supply/BAT0/status)' = 'Discharging' ] && ${lib.getExe' pkgs.systemd "systemctl"} suspend";
      in
      {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = lockCmd;
          }
          {
            event = "lock";
            command = lockCmd;
          }
          {
            event = "unlock";
            command = unlockCmd;
          }
          {
            event = "after-resume";
            command = resumeCmd;
          }
        ];
        timeouts = [
          # Lock after 10 minutes
          {
            timeout = 600;
            command = lockCmd;
          }
          # Turn displays off after 20 minutes
          {
            timeout = 1200;
            command = timeoutCmd;
            resumeCommand = resumeCmd;
          }
          # Sleep after 30 minutes on battery
          {
            timeout = 1800; # 30m
            command = suspendCmd;
          }
        ];
      }
    );
  };

  # Configure SwayWM
  wayland.windowManager.sway = {
    enable = true;
    config = {
      bars = [ { command = lib.getExe pkgs.waybar; } ];
      defaultWorkspace = "workspace number 1";

      # Enable floating windows for a list of criteria
      # Find other windows: swaymsg -t get_tree
      floating.criteria = [
        # Bluetooth controller
        { app_id = ".blueman-manager-wrapped"; }

        # Audio controller
        { app_id = "org.pulseaudio.pavucontrol"; }

        # Chromium smart card PIN prompt
        { title = "Sign in to Security Device"; }
      ];

      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
          left = config.wayland.windowManager.sway.config.left;
          right = config.wayland.windowManager.sway.config.right;
          up = config.wayland.windowManager.sway.config.up;
          down = config.wayland.windowManager.sway.config.down;
          brightnessCmd = "exec ${lib.getExe pkgs.brightnessctl} -q set 5%";
          volumeCmd = "exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume @DEFAULT_SINK@";
          volumeMicCmd = "exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-source-volume @DEFAULT_SOURCE@";
          volumeStep = "5";
        in
        # mkOptionDefault merges with default configuration
        lib.mkOptionDefault {
          # Close window with shift
          "${mod}+q" = "kill";

          # Move workspaces between displays
          "${mod}+greater" = "move workspace to output right";
          "${mod}+less" = "move workspace to output left";

          # Power control
          "${mod}+Ctrl+l" = "exec ${lib.getExe pkgs.swaylock}";
          "${mod}+Ctrl+p" = "exec ${lib.getExe' pkgs.systemd "systemctl"} poweroff";
          "${mod}+Ctrl+r" = "exec ${lib.getExe' pkgs.systemd "systemctl"} reboot";
          "${mod}+Ctrl+s" = "exec ${lib.getExe' pkgs.systemd "systemctl"} suspend";

          # Brightness control
          XF86MonBrightnessDown = "${brightnessCmd}-";
          XF86MonBrightnessUp = "${brightnessCmd}+";

          # Volume control
          XF86AudioMute = "exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioLowerVolume = "${volumeCmd} -${volumeStep}%";
          XF86AudioRaiseVolume = "${volumeCmd} +${volumeStep}%";
          XF86AudioMicMute = "exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-source-mute @DEFAULT_SOURCE@ toggle";
          "${mod}+XF86AudioMute" =
            "exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-source-mute @DEFAULT_SOURCE@ toggle";
          "${mod}+XF86AudioLowerVolume" = "${volumeMicCmd} -${volumeStep}%";
          "${mod}+XF86AudioRaiseVolume" = "${volumeMicCmd} +${volumeStep}%";
        };
      menu = "${lib.getExe pkgs.rofi} -show drun";
      modifier = "Mod4";

      # Ensure kanshi runs when sway reloaded
      startup = lib.optional config.services.kanshi.enable {
        always = true;
        command = "${lib.getExe' pkgs.systemd "systemctl"} --user restart kanshi.service";
      };

      terminal = lib.getExe pkgs.foot;
    };
  };

  xdg = {
    # Set default apps
    mimeApps = {
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

    # XDG portal
    portal = {
      enable = true;
      # TODO: correctly set config https://mynixos.com/nixpkgs/option/xdg.portal.config
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };
  };
}
