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
    export DOCKER_HOST="unix://''${TMPDIR%/}/podman/podman-machine-default-api.sock"
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
      alacritty-graphics
      caffeine
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
      thunderbird
      unixtools.watch
      wireshark
    ]);

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
  ];

  homebrew.enable = true;
  homebrew.brews = [
    "1jehuang/jcode/jcode"
  ];
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

  nix.channel.enable = false;
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

  programs.direnv.enable = true;

  programs.zsh.enable = true;
  # Managed by oh-my-zsh
  programs.zsh.enableBashCompletion = false;
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

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
            cache_file = "${config.users.users._dnscrypt-proxy.home}/public-resolvers.md";
          };
          relays = {
            cache_file = "${config.users.users._dnscrypt-proxy.home}/relays.md";
          };
        };
      };
  # https://github.com/nix-darwin/nix-darwin/issues/1408
  launchd.daemons.dnscrypt-proxy.serviceConfig.UserName = lib.mkForce null;
  # Fix "nix-darwin does not support changing the home directory of existing users.")",
  users.users._dnscrypt-proxy.home = lib.mkForce "/private/var/lib/dnscrypt-proxy";

  system.defaults.CustomSystemPreferences = {
    "com.apple.smartcharging.topoffprotection" = {
      MCLFeatureState = true;
      mclLimitValue = 80;
    };
  };

  system.primaryUser = "maxime";

  # Used by home-manager
  users.users.maxime.home = "/Users/maxime";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
