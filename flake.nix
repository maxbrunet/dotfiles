{
  description = "My NixOS configuration: A Mix of Nix and Max";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    disko.url = "github:nix-community/disko/v1.9.0";
    disko.inputs.nixpkgs.follows = "nixos";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixos";

    base16-alacritty = { url = "github:tinted-theming/base16-alacritty"; flake = false; };
    base16-fzf = { url = "github:tinted-theming/base16-fzf"; flake = false; };
    base16-shell = { url = "github:tinted-theming/base16-shell"; flake = false; };
    oh-my-tmux = { url = "github:gpakosz/.tmux"; flake = false; };
    oh-my-zsh = { url = "github:ohmyzsh/ohmyzsh"; flake = false; };
    zsh-completions-src = { url = "github:zsh-users/zsh-completions"; flake = false; };
  };

  outputs =
    { nixos
    , nixos-unstable
    , nixos-hardware
    , nixpkgs-darwin
    , nixpkgs-unstable
    , darwin
    , disko
    , home-manager
    , zsh-completions-src
    , ...
    }@attrs:
    let
      overlayPkgs = final: prev: {
        zsh-completions = (prev.zsh-completions.overrideAttrs {
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
              _yarn
            )
            install -D --target-directory=$out/share/zsh/site-functions "''${functions[@]/#/src/}"
          '';
        });
      };
      overlayNixOSUnstable = final: prev: {
        unstable = nixos-unstable.legacyPackages.${prev.system};
      };
      overlayNixpkgsUnstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      baseModules = [
        {
          nixpkgs.overlays = [ overlayNixOSUnstable overlayPkgs ];
        }
        ./nix/nixos.nix
        disko.nixosModules.disko
        # Disable Disko config as it uses device names, we prefer the robustness of UUIDs.
        { disko = { enableConfig = false; rootMountPoint = "/mnt"; }; }
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
              # Equivalent to https://nixos.org/manual/nixos/stable/options#opt-nixpkgs.flake.setNixPath
              nix.nixPath = nixpkgs-darwin.lib.mkForce [ "nixpkgs=flake:nixpkgs" ];
              # Equivalent to https://nixos.org/manual/nixos/stable/options#opt-nixpkgs.flake.setFlakeRegistry
              nix.registry.nixpkgs.to = { type = "path"; path = nixpkgs-darwin.outPath; };
              nixpkgs.overlays = [ overlayNixpkgsUnstable overlayPkgs ];
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
          ];
        };
      };
    };
}
