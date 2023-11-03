{
  description = "My NixOS configuration: A Mix of Nix and Max";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-devpod.url = "github:maxbrunet/nixpkgs/feat/devpod";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    disko.url = "github:nix-community/disko/v1.0.0";
    disko.inputs.nixpkgs.follows = "nixos";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixos";

    asdf-kubectl = { url = "github:asdf-community/asdf-kubectl"; flake = false; };
    asdf-kustomize = { url = "github:Banno/asdf-kustomize"; flake = false; };
    astronvim = { url = "github:AstroNvim/AstroNvim/v3.37.9"; flake = false; };
    base16-alacritty = { url = "github:aarowill/base16-alacritty"; flake = false; };
    base16-fzf = { url = "github:tinted-theming/base16-fzf"; flake = false; };
    base16-shell = { url = "github:tinted-theming/base16-shell"; flake = false; };
    oh-my-tmux = { url = "github:gpakosz/.tmux"; flake = false; };
    oh-my-zsh = { url = "github:ohmyzsh/ohmyzsh"; flake = false; };
  };

  outputs =
    { self
    , nixos
    , nixos-unstable
    , nixos-hardware
    , nixpkgs-darwin
    , nixpkgs-unstable
    , nixpkgs-devpod
    , darwin
    , disko
    , home-manager
    , ...
    }@attrs:
    let
      overlayNixOSUnstable = final: prev: {
        unstable = nixos-unstable.legacyPackages.${prev.system};
      };
      overlayNixpkgsUnstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      overlayNixpkgsDevpod = final: prev: {
        devpod = nixpkgs-devpod.legacyPackages.${prev.system};
      };
      baseModules = [
        { nixpkgs.overlays = [ overlayNixOSUnstable overlayNixpkgsDevpod ]; }
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
            { nixpkgs.overlays = [ overlayNixpkgsUnstable overlayNixpkgsDevpod ]; }
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
