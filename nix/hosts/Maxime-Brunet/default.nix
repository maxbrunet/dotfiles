{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    argocd-vault-plugin
  ];

  homebrew.casks = [
    "tailscale"
    "tuple"
  ];
}
