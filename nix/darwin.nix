{ pkgs, ... }:

let
  common = import ./common.nix { inherit pkgs; };
in
{
  environment.interactiveShellInit = ''
    # Set DOCKER_HOST and DOCKER_SOCK environment variables
    eval "$(
      /opt/homebrew/bin/podman system connection list --format='{{if .Default}}{{.URI}}{{end -}}' \
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
      coreutils-prefixed
      (linkFarm "docker-compat" [
        {
          name = "bin/docker";
          path = "/opt/homebrew/bin/podman";
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
      netcat-gnu
      pinentry_mac
      unixtools.watch
    ]);

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
  ];

  homebrew.enable = true;
  homebrew.casks = [
    "alacritty"
    "android-file-transfer"
    # https://chromium.googlesource.com/chromium/src/+/main/docs/mac_arm64.md
    {
      name = "chromium";
      args = {
        no_quarantine = true;
      };
    }
    "gimp"
    # https://librewolf.net/docs/faq/#why-is-librewolf-marked-as-broken
    {
      name = "librewolf";
      args = {
        no_quarantine = true;
      };
    }
    "localsend/localsend/localsend"
    "podman-desktop"
    "thunderbird"
    "wireshark-app"
  ];
  homebrew.masApps = {
    Amphetamine = 937984704;
  };

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

  programs.zsh.enable = true;
  # Managed by oh-my-zsh
  programs.zsh.enableBashCompletion = false;
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  security.pam.services.sudo_local.reattach = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.alf.globalstate = 2; # blocks

  system.primaryUser = "maxime";

  # Used by home-manager
  users.users.maxime.home = "/Users/maxime";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
