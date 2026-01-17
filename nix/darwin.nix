{
  config,
  lib,
  pkgs,
  ...
}:

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
      unstable.caffeine
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
    # https://github.com/NixOS/nixpkgs/issues/411189
    "gimp"
    # https://github.com/NixOS/nixpkgs/issues/247855
    "ungoogled-chromium"
  ];
  # idempotent because taps are managed declaratively via nix-homebrew
  homebrew.onActivation.upgrade = true;

  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.blockAllIncoming = true;
  networking.dns = [ "127.0.0.1" ]; # dnscrypt-proxy
  # Discovered with `networksetup -listallnetworkservices`
  networking.knownNetworkServices = [
    "Wi-Fi"
    "Thunderbolt Bridge"
  ];

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

  services.dnscrypt-proxy.enable = true;
  services.dnscrypt-proxy.settings =
    lib.recursiveUpdate
      # Upstream defaults
      (lib.importTOML "${config.services.dnscrypt-proxy.package}/etc/dnscrypt-proxy/dnscrypt-proxy.toml")
      {
        log_file = "/dev/stderr";
        use_syslog = false;
        sources = {
          public-resolvers = {
            cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          };
          relays = {
            cache_file = "/var/lib/dnscrypt-proxy/relays.md";
          };
        };
      };
  # https://github.com/nix-darwin/nix-darwin/issues/1408
  launchd.daemons.dnscrypt-proxy.serviceConfig.UserName = lib.mkForce null;

  system.defaults.CustomUserPreferences = {
    "com.apple.HIToolbox" = {
      AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.US";
      AppleEnabledInputSources = [
        {
          "Bundle ID" = "com.apple.CharacterPaletteIM";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          "Bundle ID" = "com.apple.PressAndHold";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 0;
          "KeyboardLayout Name" = "U.S.";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 15000;
          "KeyboardLayout Name" = "USInternational-PC";
        }
      ];
    };
    NSGlobalDomain = {
      AppleLanguages = [
        "en-US"
        "en-CA"
        "en"
        "es-UY"
        "es-AR"
        "es"
        "fr-FR"
        "fr-CA"
        "fr"
      ];
      AppleLocale = "en_US@rg=dkzzzz"; # Denmark region
    };
  };

  system.primaryUser = "maxime";

  # Used by home-manager
  users.users.maxime.home = "/Users/maxime";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
