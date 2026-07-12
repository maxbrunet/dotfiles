{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    argocd-vault-plugin
    unstable.cursor-cli
    tuple
  ];

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
