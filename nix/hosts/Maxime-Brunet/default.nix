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

  networking.search = [
    "tail5566.ts.net"
    "codomain.cohere.ai"
  ];

  services.dnscrypt-proxy.settings = {
    forwarding_rules = pkgs.writeText "forwarding-rules.txt" ''
      tail5566.ts.net 100.100.100.100
    '';
  };
}
