{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    argocd-vault-plugin
  ];

  homebrew.casks = [
    "1password"
    "tailscale"
    "tuple"
  ];
}
