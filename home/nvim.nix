{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
{
  # If lib.mkIf is used, imports isn't recognized
  imports = lib.optionals specialArgs.extra [
    specialArgs.inputs.nixvim.homeManagerModules.nixvim
    {
      programs.nixvim = {
        enable = true;
        # colorscheme = "TODO";
        clipboard.register = "unnamedplus";
        defaultEditor = true;

        # Aliases
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        # Set leader key to space
        globals.mapleader = " ";

        keymaps = [
          {
            action = "<cmd>LazyGit<cr>";
            key = "<leader>lg";
          }
        ];

        opts = {
          # Tab options
          expandtab = true;
          shiftwidth = 2;
          softtabstop = 2;
          tabstop = 2;

          # Highlight the cursor line and column
          cursorcolumn = true;
          cursorline = true;

          # Search options
          ignorecase = true;
          smartcase = true;

          # Flash closing brackets
          matchtime = 1; # 0.1s
          showmatch = true;

          # Line numbers
          number = true;
          relativenumber = true;

          # Enable spell checking
          spell = true;
          spelllang = "en_us";

          # Split below and right
          splitbelow = true;
          splitright = true;

          # Disable the mouse
          mouse = "";

          # Go to start of line when using gg, G, CTRL-D/U/B/F
          startofline = true;

          # Trigger plugins more quickly
          updatetime = 100;

          # Enable saving undo to file
          undofile = true;
        };
        plugins = {

          # Conform for formatting
          conform-nvim = {
            enable = true;
            settings = {
              formatters_by_ft = {
                nix = [ "nixfmt" ];
                python = [ "ruff" ];
              };
              formatters = {
                nixfmt.command = lib.getExe pkgs.nixfmt-rfc-style;
                ruff.command = lib.getExe pkgs.ruff;
              };
              format_on_save.lsp_format = "fallback";
            };
          };

          # Hints to improve motions
          hardtime.enable = true;

          # Floating window for lazygit
          lazygit.enable = true;

          # TODO: move outside of plugins once servers.powershell_es available
          lsp = {
            enable = true;

            # LSP and formatter for PowerShell
            servers.powershell_es = {
              enable = true;
              extraOptions = {
                bundle_path = "${pkgs.powershell-editor-services}/lib/powershell-editor-services";
                shell = lib.getExe pkgs.powershell;
              };
              package = pkgs.powershell-editor-services;

              # More opinionated PowerShell formatting
              settings.powershell.codeFormatting = {
                ignoreOneLineBlock = false;
                preset = "OTBS";
                useConstantStrings = true;
                useCorrectCasing = true;
                trimWhitespaceAroundPipe = true;
                whitespaceBetweenParameters = true;
              };
            };
          };

          # Hints for keymaps
          which-key.enable = true;
        };
      };
    }
  ];
}
