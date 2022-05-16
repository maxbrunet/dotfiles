{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/lenovo/thinkpad/x230>
      ./hardware-configuration.nix
    ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback.out
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.initrd = {
    luks.devices."cryptroot" = {
      allowDiscards = true;
      fallbackToPassword = true;
      keyFile = "/keyfile.bin";
    };
    secrets = {
      "/keyfile.bin" = "/boot/initrd/keyfile.bin";
    };
  };
  boot.plymouth.enable = true;
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "25%";

  environment.defaultPackages = lib.mkForce [ ];

  environment.loginShellInit = ''
    eval "$(gnome-keyring-daemon --start)"
    export SSH_AUTH_SOCK
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';

  environment.pathsToLink = [
    "/libexec"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_OPTIONS = "terminate:ctrl_alt_bksp";
    XKB_DEFAULT_VARIANT = "altgr-intl";
  };

  environment.shells = [ pkgs.zsh ];

  environment.systemPackages = with pkgs; [
    android-tools
    atom
    bat
    bind.dnsutils
    brightnessctl
    cargo
    (chromium.override {
      commandLineArgs = "--enable-features=WebRTCPipeWireCapturer";
    })
    delta
    docker-buildx
    docker-compose_2
    dos2unix
    droidcam
    emote
    evince
    firefox-wayland
    fzf
    fpp
    gcc
    gimp
    gnome.gnome-calculator
    gnome.simple-scan
    go
    gopls
    gotools
    golangci-lint
    hadolint
    htop
    hub
    imagemagick
    jq
    jsonnet
    jsonnet-bundler
    kube3d
    kubectx
    (linkFarm "kubectl-ctx" [
      { name = "bin/kubectl-ctx"; path = "${kubectx}/bin/kubectx"; }
      { name = "bin/kubectl-ns"; path = "${kubectx}/bin/kubens"; }
    ])
    lazygit
    libreoffice
    libsecret
    lsof
    mate.engrampa
    unstable.neovim
    ncdu
    nixpkgs-fmt
    nmap
    nodejs
    pavucontrol
    perl
    playerctl
    polkit_gnome
    powertop
    psmisc
    # Until pulseaudio v15 moves to stable
    unstable.pulseaudio
    pwgen
    python3
    python3Packages.black
    python3Packages.flake8
    python3Packages.isort
    python3Packages.pipx
    python3Packages.poetry
    python3Packages.pre-commit
    python3Packages.python-lsp-server
    python3Packages.virtualenv
    python3Packages.virtualenvwrapper
    ripgrep
    rnix-lsp
    scrcpy
    shellcheck
    shfmt
    slack
    stern
    system-config-printer
    tanka
    tcptraceroute
    terraform-ls
    tflint
    tfswitch
    thunderbird-wayland
    tmux
    traceroute
    tree
    urlview
    v4l-utils
    vlc
    wget
    xdg-utils
    xdg-user-dirs
    xfce.exo
    (xfce.thunar.override {
      thunarPlugins = with pkgs; [
        xfce.thunar-volman
        xfce.thunar-archive-plugin
        xfce.thunar-media-tags-plugin
      ];
    })
    xfce.xfconf
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [
        "Noto Color Emoji"
        "Font Awesome 5 Free"
        "Font Awesome 5 Brands"
        "SauceCodePro Nerd Font"
      ];
      monospace = [
        "Source Code Pro"
        "emoji"
      ];
      sansSerif = [
        "Noto Sans"
        "emoji"
      ];
      serif = [
        "Noto Serif"
        "emoji"
      ];
    };
  };
  fonts.enableDefaultFonts = false;
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    font-awesome
    # Use NerdFontsSymbolsOnly once available in release
    # https://github.com/ryanoasis/nerd-fonts/issues/479
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    source-code-pro
  ];

  hardware.bluetooth.enable = true;
  # Until Bluez 5.64 moves to stable
  # https://github.com/bluez/bluez/issues/286
  hardware.bluetooth.package = pkgs.unstable.bluez;
  hardware.bluetooth.powerOnBoot = false;

  hardware.firmware = with pkgs; [
    # Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
    # Bluetooth: hci0: BCM: firmware Patch file not found
    broadcom-bt-firmware
  ];

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.unstable.hplip ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  location.provider = "manual";
  location.latitude = 49.7565619;
  location.longitude = -123.3152747;

  networking.firewall.allowedUDPPortRanges = [
    # Allow UPnP/SSDP traffic for Chromecast
    # https://github.com/NixOS/nixpkgs/issues/49630#issuecomment-622498732
    { from = 32768; to = 60999; }
  ];
  networking.hostName = "BRUNETM-X230";
  networking.wireless.iwd.enable = true;

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  programs.git.enable = true;

  programs.gnupg.agent.enable = true;

  programs.noisetorch.enable = true;

  programs.seahorse.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      arc-icon-theme
      arc-theme
      alacritty
      # Fake terminal so desktop applications with Terminal=true work
      # https://gitlab.gnome.org/GNOME/glib/-/issues/338
      # https://gitlab.gnome.org/GNOME/glib/-/blob/2.72.1/gio/gdesktopappinfo.c#L2653-2698
      (linkFarm "fake-xterm" [
        { name = "bin/xterm"; path = "${alacritty}/bin/alacritty"; }
      ])
      dunst
      glib
      imv
      libappindicator
      libsForQt5.breeze-gtk
      sway-contrib.grimshot
      swayidle
      swaylock
      (waybar.override { withMediaPlayer = true; })
      wdisplays
      wl-clipboard
      wofi
    ];
  };

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.zsh.enable = true;

  services.avahi.enable = true;

  services.blueman.enable = true;

  services.connman.enable = true;
  services.connman.wifi.backend = "iwd";

  services.gnome.gnome-keyring.enable = true;

  services.gvfs.enable = true;

  services.printing.enable = true;
  # Until hplip fixes move to stable
  # https://github.com/NixOS/nixpkgs/issues/114051
  # https://bugs.launchpad.net/hplip/+bug/1946173
  services.printing.drivers = [ pkgs.unstable.hplip ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    media-session.config.bluez-monitor = {
      rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
              # SBC-XQ is not expected to work on all headset + adapter combinations.
              "bluez5.sbc-xq-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
        }
      ];
    };
  };

  services.redshift = {
    enable = true;
    executable = "/bin/gammastep";
    package = pkgs.gammastep;
  };

  services.tumbler.enable = true;

  services.upower.enable = true;

  sound.enable = true;

  time.timeZone = "America/Vancouver";

  users.users.maxime = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "input"
      "lp"
      "scanner"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
