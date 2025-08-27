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
        inherit (config.lib.nixvim) mkRaw;
        enable = true;
        # colorscheme = "TODO";
        clipboard.register = "unnamedplus";
        defaultEditor = true;

        # Aliases
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        keymaps = [
          # Snacks.picker
          {
            options.desc = "Smart Find Files";
            action = mkRaw "function() Snacks.picker.smart() end";
            key = "<leader><space>";
          }
          {
            options.desc = "Buffers";
            action = mkRaw "function() Snacks.picker.buffers() end";
            key = "<leader>,";
          }
          {
            options.desc = "Grep";
            action = mkRaw "function() Snacks.picker.grep() end";
            key = "<leader>/";
          }
          {
            options.desc = "Command History";
            action = mkRaw "function() Snacks.picker.command_history() end";
            key = "<leader>:";
          }
          {
            options.desc = "Notification History";
            action = mkRaw "function() Snacks.picker.notifications() end";
            key = "<leader>n";
          }
          {
            options.desc = "Todo Comments";
            action = mkRaw "function() Snacks.picker.todo_comments() end";
            key = "<leader>st";
          }
          {
            options.desc = "Undo History";
            action = mkRaw "function() Snacks.picker.undo() end";
            key = "<leader>su";
          }

          # todo-comments
          {
            options.desc = "Next todo comment";
            action = mkRaw "function() require('todo-comments').jump_next() end";
            key = "]t";
          }
          {
            options.desc = "Previous todo comment";
            action = mkRaw "function() require('todo-comments').jump_prev() end";
            key = "[t";
          }

          # trouble
          {
            options.desc = "Diagnostics (Trouble)";
            action = "<cmd>Trouble diagnostics toggle<cr>";
            key = "<leader>xx";
          }
          {
            options.desc = "Buffer Diagnostics (Trouble)";
            action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
            key = "<leader>xX";
          }
          {
            options.desc = "Location List (Trouble)";
            action = "<cmd>Trouble loclist toggle<cr>";
            key = "<leader>xL";
          }
          {
            options.desc = "Quickfix List (Trouble)";
            action = "<cmd>Trouble qflist toggle<cr>";
            key = "<leader>xQ";
          }
          {
            options.desc = "Symbols (Trouble)";
            action = "<cmd>Trouble symbols toggle focus=false<cr>";
            key = "<leader>cs";
          }
          {
            options.desc = "LSP Definitions / References / ... (Trouble)";
            action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
            key = "<leader>cl";
          }

          # GrugFar
          {
            options.desc = "Search and replace";
            action = "<cmd>GrugFar<cr>";
            key = "<leader>sr";
          }

          # LazyGit
          {
            options.desc = "Open LazyGit";
            action = mkRaw "function() Snacks.lazygit() end";
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
        };
        plugins = {

          # Conform for formatting
          conform-nvim = {
            enable = true;
            settings = {
              formatters_by_ft = {
                markdown = [ "prettierd" ];
                nix = [ "nixfmt" ];
                python = [ "ruff" ];
              };
              formatters = {
                nixfmt.command = lib.getExe pkgs.nixfmt-rfc-style;
                prettierd.command = lib.getExe pkgs.prettierd;
                ruff.command = lib.getExe pkgs.ruff;
              };
              format_on_save.lsp_format = "fallback";
            };
          };

          # Show lines changed since Git
          gitsigns.enable = true;

          # Find and replace in multiple files using rg
          grug-far.enable = true;

          # Hints to improve motions
          hardtime.enable = true;

          mini = {
            enable = true;

            # Use mini.icons for nvim-web-devicons
            mockDevIcons = true;

            modules = {
              # More text objects
              ai = { };

              # Sensible defaults for Neovim
              basics = {
                options = {
                  basic = true;
                  extra_ui = true;
                  win_borders = "single";
                };
                mappings = {
                  basic = true;
                  windows = true;
                  move_with_alt = true;
                };
                autocommands = {
                  basic = true;
                  relnum_in_visual_mode = false;
                };
              };

              # Provide icons for other plugins
              icons = { };

              # Automatically add and remove character pairs
              pairs = { };

              # Enhanced status line
              statusline = { };

              # s for operations on surrounding characters
              surround.mappings = {
                add = "gsa";
                delete = "gsd";
                find = "gsf";
                find_left = "gsF";
                highlight = "gsh";
                replace = "gsr";
                update_n_lines = "gsn";
              };

              # Show buffers at top
              tabline = { };
            };
          };

          # UI for messages, cmdline, and popupmenu
          noice.enable = true;

          # TODO: move outside of plugins once servers.powershell_es available
          lsp = {
            enable = true;

            servers = {
              # LSP for Python
              basedpyright.enable = true;

              # LSP and formatter for PowerShell
              powershell_es = {
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
          };

          snacks = {
            enable = true;
            settings = {
              # Show indent guides and scopes
              indent.enabled = true;

              # UI for LazyGit
              lazygit.enabled = true;

              # UI for notifications
              notifier.enabled = true;

              # Fuzzy finder
              picker.enabled = true;
            };
          };

          # Handle todo comments
          todo-comments.enable = true;

          # UI for diagnostics, references, quickfix, and location list
          trouble.enable = true;

          # Hints for keymaps
          which-key.enable = true;
        };
      };
    }
  ];
}
