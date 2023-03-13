{
  description = "My NixOS configuration: A Mix of Nix and Max";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware }:
    let
      overlayUnstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      baseModules = [
        ({ ... }: { nixpkgs.overlays = [ overlayUnstable ]; })
        ./nix/nixos.nix
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
