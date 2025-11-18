{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # nix.conf
  nixConfig = {
    # Add more binary caches
    extra-substituters = [
      "https://lanzaboote.cachix.org"
      "https://nix-community.cachix.org"
      "https://winapps.cachix.org"
    ];
    extra-trusted-public-keys = [
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="
    ];
  };

  outputs =
    { self, ... }@inputs:
    let
      # Saving this if custom lib needed
      # lib = nixpkgs.lib.extend (final: prev: { custom = import ./lib.nix prev; });
      inherit (inputs.nixpkgs) lib;

      # Function to run on all systems
      forAllSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Function to make a host for nixosConfigurations
      mkHost =
        { hostName, ... }@settings:
        let
          # Recursively merge default settings with host-specific settings (take precedence)
          specialArgs = lib.recursiveUpdate {
            # Include hostname and inputs
            inherit hostName inputs;

            # Set root device based on disk encryption and NVME has different naming
            disk.rootDevice =
              if settings.disk.encrypt then
                "/dev/mapper/luks"
              else if builtins.match ".*[0-9]$" settings.disk.device != null then
                "${settings.disk.device}p3"
              else
                "${settings.disk.device}3";

            # Default settings
            cac = false;
            disk = {
              device = "/dev/vda";
              encrypt = false;
              swapSize = "4G";
              tmpfsSize = "2G";
            };
            editor = "nvim";
            extra = true;
            fontMono = "ComicShannsMono";
            graphical = false;
            hypervisor = false;
            laptop = false;
            persistDir = "/persist";
            vm = false;
            vnc = {
              enable = false;
              clientIp = "127.0.0.1";
              resolution = "1920x1080";
            };
            secureBoot = false;
            security = false;
            sshPrivateKeyName = "id_sears";
            sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7hoEjOMGwikB/6otPk2CDrBenABNgIjlWXQDqhmn9E Sears Schulz";
            stateVersion = "24.11";
            system = "x86_64-linux";
            username = "sears";
          } settings;
        in
        lib.nixosSystem {
          # Include specialArgs and system
          inherit specialArgs;
          inherit (specialArgs) system;

          # Import the NixOS modules
          modules =
            let
              ifExists = path: lib.optional (builtins.pathExists path) path;
            in
            lib.filesystem.listFilesRecursive ./nixos
            ++ ifExists ./hosts/${hostName}-nixos.nix
            ++

              # Import the Home Manager modules
              [
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    extraSpecialArgs = specialArgs;
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.${specialArgs.username} = {
                      imports = lib.filesystem.listFilesRecursive ./home ++ ifExists ./hosts/${hostName}-home.nix;
                    };
                  };
                }
              ];
        };
    in
    {
      # Pre-commit hooks
      checks = forAllSystems (system: {
        pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Check for secrets
            detect-private-keys.enable = true;
            ripsecrets.enable = true;
            trufflehog.enable = true;

            # Misc
            check-added-large-files.enable = true;
            check-case-conflicts.enable = true;
            check-executables-have-shebangs.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            mixed-line-endings.enable = true;
            trim-trailing-whitespace.enable = true;

            # Format and lint Nix files
            nixfmt-rfc-style.enable = true;
            statix.enable = true;

            # Scan Nix files for dead code
            deadnix = {
              enable = true;
              # Allow the same variables at top of each file
              settings.noLambdaPatternNames = true;
            };

            # Format Markdown and YAML files
            prettier = {
              enable = true;
              excludes = [ "flake.lock" ];
            };

            # Lint Markdown files
            markdownlint.enable = true;

            # Lint YAML files
            check-yaml.enable = true;
            yamllint = {
              enable = true;
              settings.configData = "{extends: relaxed}";
            };

            # Format and lint shell scripts
            shfmt = {
              enable = true;
              # Spaces instead of tabs
              args = [
                "-i"
                "2"
              ];
            };
            shellcheck.enable = true;

            # Lint GitHub actions
            actionlint.enable = true;

            # Check for typos
            typos = {
              enable = true;
              settings.ignored-words = [ "noice" ];
            };
          };
        };
      });

      # devShell to run pre-commit checks
      devShells = forAllSystems (system: {
        default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });

      # Create the NixOS hosts
      nixosConfigurations = {
        karen = mkHost {
          hostName = "karen";
          disk = {
            device = "/dev/vda";
            swapSize = "8G";
            tmpfsSize = "2G";
          };
          graphical = true;
          vm = true;
          vnc = {
            enable = true;
            clientIp = "10.69.10.10";
            resolution = "1550x1250";
          };
          security = true;
        };
        sandy = mkHost {
          hostName = "sandy";
          cac = true;
          disk = {
            device = "/dev/nvme0n1";
            encrypt = true;
            swapSize = "8G";
            tmpfsSize = "4G";
          };
          graphical = true;
          hypervisor = true;
          laptop = true;
          secureBoot = true;
          security = true;
        };
        test = mkHost {
          hostName = "test";
          disk = {
            device = "/dev/vda";
            swapSize = "8G";
            tmpfsSize = "2G";
          };
          graphical = true;
          vm = true;
          vnc = {
            enable = true;
            clientIp = "192.168.122.1";
            resolution = "1920x1080";
          };
        };
      };
    };
}
