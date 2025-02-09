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
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
  ];

  homebrew.enable = true;
  homebrew.brews = [
    # Unable to build the darwin-system derivation with the azure-cli package,
    # so using Homebrew's instead
    # sandbox-exec: pattern serialization length 66790 exceeds maximum (65535)
    # https://github.com/NixOS/nix/issues/4119
    "azure-cli"
  ];
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
    "lulu"
    "podman-desktop"
    "thunderbird"
    "wireshark"
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

  # FIXME: Requires pam_reattach to work in tmux
  # https://github.com/LnL7/nix-darwin/pull/662
  security.pam.enableSudoTouchIdAuth = true;

  services.nix-daemon.enable = true;

  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.0;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
  system.defaults.alf.globalstate = 2; # blocks
  system.defaults.dock.autohide = true;
  system.defaults.dock.mineffect = "scale";
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.tilesize = 48;
  system.defaults.dock.wvous-bl-corner = 5; # Start Screen Saver
  system.defaults.dock.wvous-br-corner = 5; # Start Screen Saver
  system.defaults.screensaver.askForPassword = true;
  system.defaults.screensaver.askForPasswordDelay = 5; # seconds
  system.defaults.trackpad.Clicking = true;

  # Used by home-manager
  users.users.maxime.home = "/Users/maxime";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
