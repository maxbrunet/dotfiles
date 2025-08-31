{
  description = "My NixOS configuration: A Mix of Nix and Max";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    disko.url = "github:nix-community/disko/v1.11.0";
    disko.inputs.nixpkgs.follows = "nixos";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixos";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.brew-src.follows = "brew-src";

    base16-alacritty = {
      url = "github:tinted-theming/base16-alacritty";
      flake = false;
    };
    base16-fzf = {
      url = "github:tinted-theming/base16-fzf";
      flake = false;
    };
    base16-shell = {
      url = "github:tinted-theming/base16-shell";
      flake = false;
    };
    brew-src = {
      url = "github:Homebrew/brew/4.6.7";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-localsend = {
      url = "github:localsend/homebrew-localsend";
      flake = false;
    };
    oh-my-tmux = {
      url = "github:gpakosz/.tmux";
      flake = false;
    };
    oh-my-zsh = {
      url = "github:ohmyzsh/ohmyzsh";
      flake = false;
    };
    zsh-completions-src = {
      url = "github:zsh-users/zsh-completions";
      flake = false;
    };
  };

  outputs =
    {
      nixos,
      nixos-unstable,
      nixos-hardware,
      nixpkgs-unstable,
      darwin,
      disko,
      home-manager,
      nix-homebrew,
      brew-src,
      homebrew-cask,
      homebrew-core,
      homebrew-localsend,
      zsh-completions-src,
      ...
    }@attrs:
    let
      overlayPkgs = final: prev: {
        zsh-completions = (
          prev.zsh-completions.overrideAttrs {
            version = "HEAD";
            src = zsh-completions-src;
            installPhase = ''
              functions=(
                _direnv
                _golang
                _grpcurl
                _node
                _pre-commit
                _ts-node
                _tsc
              )
              install -D --target-directory=$out/share/zsh/site-functions "''${functions[@]/#/src/}"
            '';
          }
        );
      };
      overlayNixOSUnstable = final: prev: {
        unstable = nixos-unstable.legacyPackages.${prev.system};
      };
      overlayNixpkgsUnstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      baseModules = [
        {
          nixpkgs.overlays = [
            overlayNixOSUnstable
            overlayPkgs
          ];
        }
        ./nix/nixos.nix
        disko.nixosModules.disko
        # Disable Disko config as it uses device names, we prefer the robustness of UUIDs.
        {
          disko = {
            enableConfig = false;
            rootMountPoint = "/mnt";
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = false;
          home-manager.users.maxime = import ./nix/home.nix;
          home-manager.extraSpecialArgs = attrs;
        }
      ];
    in
    {
      nixosConfigurations = {
        BRUNETM-X1 = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
            ./nix/hosts/BRUNETM-X1
          ];
        };
        BRUNETM-X230 = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.lenovo-thinkpad-x230
            ./nix/hosts/BRUNETM-X230
          ];
        };
        virtualbox = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            ./nix/hosts/virtualbox
          ];
        };
      };
      darwinConfigurations = {
        Maxime-Brunet = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            {
              nixpkgs.overlays = [
                overlayNixpkgsUnstable
                overlayPkgs
              ];
            }
            ./nix/darwin.nix
            ./nix/hosts/Maxime-Brunet
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.users.maxime = import ./nix/home.nix;
              home-manager.extraSpecialArgs = attrs;
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = "maxime";
                mutableTaps = false;
                taps = {
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-core" = homebrew-core;
                  "localsend/localsend" = homebrew-localsend;
                };
              };

              system.activationScripts = {
                # https://github.com/zhaofengli/nix-homebrew/pull/79
                setup-homebrew-extra.text = ''
                  HOMEBREW_PREFIX=/opt/homebrew

                  # Link brew docs
                  sudo /bin/ln -shf "${brew-src}/docs" "$HOMEBREW_PREFIX/share/doc/homebrew"
                  # Link brew manpages
                  sudo /bin/ln -shf "${brew-src}/manpages/README.md" "$HOMEBREW_PREFIX/share/man/man1/README.md"
                  sudo /bin/ln -shf "${brew-src}/manpages/brew.1" "$HOMEBREW_PREFIX/share/man/man1/brew.1"

                  # Link brew shell completions
                  sudo /bin/ln -shf "${brew-src}/completions/bash/brew" "$HOMEBREW_PREFIX/etc/bash_completion.d/brew"
                  sudo /bin/ln -shf "${brew-src}/completions/fish/brew.fish" "$HOMEBREW_PREFIX/share/fish/vendor_completions.d/brew.fish"
                  sudo /bin/ln -shf "${brew-src}/completions/zsh/_brew" "$HOMEBREW_PREFIX/share/zsh/site-functions/_brew"
                '';
              };
            }
          ];
        };
      };
    };
}
