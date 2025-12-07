{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    argocd-vault-plugin
    tuple
  ];

  # The default Nix build user group ID was changed from 30000 to 350.
  # It is not recommend trying to change the group ID with macOS user
  # management tools without a complete uninstallation and reinstallation
  # of Nix.
  ids.gids.nixbld = 30000;
}
