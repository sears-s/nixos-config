{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
{
  home = {
    # Programs not available as a home-manager program
    packages = with pkgs; [
      dig # DNS troubleshooting
      file # get file type by header
      jq # JSON parsing
      p7zip # extract 7Z
      tcpdump # packet capture
      unzip # extract ZIP
    ];
    # Set state version
    inherit (specialArgs) stateVersion;
  };

  programs = {
    # fish
    fish = {
      enable = true;
      preferAbbrs = true;
      shellAbbrs = {
        gacp = lib.mkIf config.programs.git.enable {
          expansion = "git add -A && git commit -m '%' && git push";
          setCursor = true;
        };
        grep = lib.mkIf config.programs.ripgrep.enable "rg";
        impls = "sudo find / -mount -type f -printf '%h/%f\\n' | grep -iv cache | less";
        # TODO: remove --impure when builins.readFile removed from geoclue
        nixr = "sudo nixos-rebuild switch --flake /home/${specialArgs.username}/proj/nixos-config/ --accept-flake-config --impure";
        top = lib.mkIf config.programs.bottom.enable "bottom";
      };
    };

    # git
    git = {
      enable = true;
      delta.enable = true; # better syntax highlighting
      extraConfig = {
        commit.gpgsign = true;
        core.editor = specialArgs.editor;
        credential.helper = "libsecret";
        gpg.format = "ssh";
        http."https://code.levelup.cce.af.mil".sslVerify = false;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        user = {
          email = "36250748+sears-s@users.noreply.github.com";
          name = "Sears Schulz";
          signingkey = "~/.ssh/${specialArgs.sshPrivateKeyName}.pub";
        };
      };
      package = pkgs.gitFull;
    };

    # home-manager
    home-manager.enable = true;

    # neovim without nixvim if minimal system
    neovim = lib.mkIf (!specialArgs.extra) {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
