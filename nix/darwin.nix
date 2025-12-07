{ lib, pkgs, ... }:

let
  common = import ./common.nix { inherit pkgs; };
in
{
  environment.interactiveShellInit = ''
    # Set DOCKER_HOST and DOCKER_SOCK environment variables
    eval "$(
      ${pkgs.podman}/bin/podman system connection list --format='{{if .Default}}{{.URI}}{{end -}}' \
        | ruby -r uri -e '
          uri = URI.parse(ARGF.read)

          # "localhost" is automatically added to known_hosts, but not "127.0.0.1"
          if uri.host == "127.0.0.1"
            uri.host = "localhost"
          end

          sock = uri.path
          uri.path = ""

          puts <<~EOT
            export DOCKER_HOST="#{uri}"
            export DOCKER_SOCK="#{sock}"
          EOT
        '
    )"
  '';

  environment.pathsToLink = [
    "/share/fzf-tab"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  environment.shells = [ "/run/current-system/sw/bin/zsh" ];

  environment.systemPackages =
    common.packages
    ++ (with pkgs; [
      alacritty
      coreutils-prefixed
      (linkFarm "docker-compat" [
        {
          name = "bin/docker";
          path = "${podman}/bin/podman";
        }
      ])
      findutils
      gawk
      git
      gnugrep
      gnumake
      gnupg
      gnused
      gnutar
      librewolf
      localsend
      netcat-gnu
      pinentry_mac
      podman
      podman-desktop
      thunderbird
      unixtools.watch
      wireshark
    ]);

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
  ];

  homebrew.enable = true;
  homebrew.casks = [
    "gimp"
    "ungoogled-chromium"
  ];
  homebrew.masApps = {
    Amphetamine = 937984704;
  };

  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.blockAllIncoming = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.gc.automatic = true;
  nix.gc.interval = {
    Weekday = 0;
  };
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;
  nix.settings.sandbox = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "tuple"
    ];

  programs.zsh.enable = true;
  # Managed by oh-my-zsh
  programs.zsh.enableBashCompletion = false;
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  security.pam.services.sudo_local.reattach = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "maxime";

  # Used by home-manager
  users.users.maxime.home = "/Users/maxime";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
