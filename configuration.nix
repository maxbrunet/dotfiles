{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/common/pc/laptop/ssd>
      <nixos-hardware/lenovo/thinkpad/x230>
      ./hardware-configuration.nix
    ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback.out
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1; # need by k3d's svclb-traefik DaemonSet
  };
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

  environment.etc = {
    # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';

  environment.pathsToLink = [
    "/libexec"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  environment.sessionVariables = rec {
    # https://k3d.io/stable/usage/advanced/podman/#using-rootless-podman
    DOCKER_HOST = "unix://${DOCKER_SOCK}";
    DOCKER_SOCK = "\${XDG_RUNTIME_DIR}/podman/podman.sock";
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_OPTIONS = "terminate:ctrl_alt_bksp";
    XKB_DEFAULT_VARIANT = "altgr-intl";
  };

  environment.shells = [ pkgs.zsh ];

  environment.systemPackages = with pkgs; [
    android-tools
    appimage-run
    atom
    bat
    bind.dnsutils
    brightnessctl
    (chromium.override {
      commandLineArgs = "--enable-features=WebRTCPipeWireCapturer";
    })
    delta
    dos2unix
    droidcam
    emote
    evince
    file
    firefox-wayland
    fpp
    fzf
    gcc
    gh
    gimp
    gnome.gnome-calculator
    gnome.simple-scan
    gnumake
    go_1_18
    gofumpt
    golangci-lint
    gopls
    goreleaser
    gotools
    hadolint
    htop
    imagemagick
    jq
    jsonnet
    jsonnet-bundler
    # Until v5.4.2 is in stable channel
    # https://github.com/k3d-io/k3d/pull/1045
    unstable.kube3d
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
    ncdu
    neovim
    nixpkgs-fmt
    nmap
    nodejs
    pavucontrol
    perl
    playerctl
    podman-compose
    polkit_gnome
    powertop
    pre-commit
    psmisc
    pulseaudio
    pwgen
    python3
    python3Packages.black
    python3Packages.flake8
    python3Packages.isort
    python3Packages.pipx
    python3Packages.poetry
    python3Packages.python-lsp-server
    python3Packages.virtualenv
    python3Packages.virtualenvwrapper
    regctl
    ripgrep
    rnix-lsp
    rustup
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
    unzip
    urlview
    v4l-utils
    vlc
    wget
    xdg-user-dirs
    xdg-utils
    xfce.exo
    (xfce.thunar.override {
      thunarPlugins = with pkgs; [
        xfce.thunar-volman
        xfce.thunar-archive-plugin
        xfce.thunar-media-tags-plugin
      ];
    })
    xfce.xfconf
    yarn
    yq-go
    zip
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [
        "Noto Color Emoji"
        "Font Awesome 6 Free"
        "Font Awesome 6 Brands"
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
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    font-awesome
    # Use NerdFontsSymbolsOnly once available in release
    # https://github.com/ryanoasis/nerd-fonts/issues/479
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    source-code-pro
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  hardware.bluetooth.powerOnBoot = false;

  hardware.firmware = with pkgs; [
    # Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
    # Bluetooth: hci0: BCM: firmware Patch file not found
    broadcom-bt-firmware
  ];

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplip ];

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;

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
    extraSessionCommands = ''
      eval "$(gnome-keyring-daemon --start)"
      export SSH_AUTH_SOCK
    '';
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
  services.printing.drivers = [ pkgs.hplip ];

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  services.redshift = {
    enable = true;
    executable = "/bin/gammastep";
    package = pkgs.gammastep;
  };

  services.tumbler.enable = true;

  services.upower.enable = true;

  sound.enable = true;

  # Delegate cpu/cpuset: https://github.com/k3d-io/k3d/issues/1082
  systemd.services."user@".serviceConfig = {
    Delegate = [ "cpu" "cpuset" "io" "memory" "pids" ];
  };

  # Until https://github.com/NixOS/nixpkgs/pull/176809 make it to the stable channel
  systemd.user.services.podman = {
    path = [ "/run/wrappers" ]; # https://github.com/NixOS/nixpkgs/issues/138423
    serviceConfig = {
      ExecStart = [ "" "${pkgs.podman}/bin/podman $LOGGING system service" ];
    };
  };
  systemd.user.sockets.podman.wantedBy = [ "sockets.target" ];

  time.timeZone = "America/Vancouver";

  users.users.maxime = {
    isNormalUser = true;
    extraGroups = [
      "input"
      "lp"
      "scanner"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.zsh;
  };

  virtualisation.containers.registries.search = [ "docker.io" ];

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
