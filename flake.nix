{
  description = "My NixOS configuration: A Mix of Nix and Max";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    asdf-kubectl = { url = "github:asdf-community/asdf-kubectl"; flake = false; };
    asdf-kustomize = { url = "github:Banno/asdf-kustomize"; flake = false; };
    astronvim = { url = "github:AstroNvim/AstroNvim/v3.10.1"; flake = false; };
    base16-alacritty = { url = "github:aarowill/base16-alacritty"; flake = false; };
    base16-fzf = { url = "github:tinted-theming/base16-fzf"; flake = false; };
    base16-shell = { url = "github:tinted-theming/base16-shell"; flake = false; };
    oh-my-tmux = { url = "github:gpakosz/.tmux"; flake = false; };
    oh-my-zsh = { url = "github:ohmyzsh/ohmyzsh"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, disko, home-manager, ... }@attrs:
    let
      overlayUnstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      baseModules = [
        { nixpkgs.overlays = [ overlayUnstable ]; }
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
        BRUNETM-X1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
            ./nix/hosts/BRUNETM-X1
          ];
        };
        BRUNETM-X230 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.lenovo-thinkpad-x230
            ./nix/hosts/BRUNETM-X230
          ];
        };
        virtualbox = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            ./nix/hosts/virtualbox
          ];
        };
      };
    };
}
