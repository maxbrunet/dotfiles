{ config, lib, pkgs, ... }:

let
  common = import ./common.nix { inherit pkgs; };
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1; # needed by k3d's svclb-traefik DaemonSet
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.initrd = {
    luks.devices."cryptroot" = {
      allowDiscards = true;
      bypassWorkqueues = true;
      fallbackToPassword = true;
      keyFile = "/keyfile.bin";
    };
    secrets = {
      "/keyfile.bin" = "/boot/initrd/keyfile.bin";
    };
  };
  boot.plymouth.enable = true;
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "25%";

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
    "/share/fzf-tab"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  environment.sessionVariables = rec {
    # https://k3d.io/stable/usage/advanced/podman/#using-rootless-podman
    DOCKER_HOST = "unix://${DOCKER_SOCK}";
    DOCKER_SOCK = "\${XDG_RUNTIME_DIR}/podman/podman.sock";
    GTK_THEME = "Arc-Dark"; # For GTK 4
    NIXOS_OZONE_WL = "1";
    # To ensure ruff is always built from source (e.g. pre-commit)
    # https://github.com/NixOS/nixpkgs/issues/142383#issuecomment-1481800175
    PIP_NO_BINARY = "ruff";
    RTX_HIDE_UPDATE_WARNING = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };

  environment.shells = [ pkgs.zsh ];

  environment.systemPackages =
    common.packages ++
    (with pkgs; [
      appimage-run
      aspellDicts.en
      bind.dnsutils
      brightnessctl
      (chromium.override {
        commandLineArgs = builtins.concatStringsSep " " [
          "--enable-features=WebRTCPipeWireCapturer"
          # Hardware acceleration freezes the (Chromecast) video playback
          # when the window is not focused/is in the background.
          # https://bugs.chromium.org/p/chromium/issues/detail?id=752726
          "--disable-gpu"
        ];
      })
      emote
      evince
      file
      firefox
      gcc
      gimp
      gnome.gnome-calculator
      gnome.simple-scan
      gnumake
      libreoffice
      libsecret
      lsof
      mate.engrampa
      pavucontrol
      playerctl
      polkit_gnome
      powertop
      psmisc
      pulseaudio
      system-config-printer
      thunderbird
      traceroute
      unzip
      vlc
      xdg-utils
      xfce.exo
      xfce.mousepad
      (xfce.thunar.override {
        thunarPlugins = with pkgs; [
          xfce.thunar-volman
          xfce.thunar-archive-plugin
          xfce.thunar-media-tags-plugin
        ];
      })
      xfce.xfconf
      zip
    ]);

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [
        "Noto Color Emoji"
        "Font Awesome 6 Free"
        "Font Awesome 6 Brands"
        "Symbols Nerd Font Mono"
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
  fonts.enableDefaultPackages = false;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    font-awesome
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    source-code-pro
  ];

  gtk.iconCache.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  hardware.bluetooth.powerOnBoot = false;

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplip ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  location.provider = "geoclue2";

  networking.wireless.iwd.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.git.enable = true;

  programs.gnupg.agent.enable = true;

  programs.noisetorch.enable = true;

  programs.seahorse.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; let
      schema = gsettings-desktop-schemas;
      dataDir = "${schema}/share/gsettings-schemas/${schema.name}";
      gsettings-wrapped = writeTextFile {
        name = "gsettings";
        destination = "/bin/gsettings";
        executable = true;
        text = ''
          export XDG_DATA_DIRS=${dataDir}:$XDG_DATA_DIRS

          ${pkgs.glib}/bin/gsettings "$@"
        '';
      };
    in
    [
      arc-theme
      alacritty
      # Fake terminal so desktop applications with Terminal=true work
      # https://gitlab.gnome.org/GNOME/glib/-/issues/338
      # https://gitlab.gnome.org/GNOME/glib/-/blob/2.72.1/gio/gdesktopappinfo.c#L2653-2698
      (linkFarm "fake-xterm" [
        { name = "bin/xterm"; path = "${alacritty}/bin/alacritty"; }
      ])
      dunst
      gammastep
      gsettings-wrapped
      imv
      libappindicator
      libsForQt5.breeze-gtk
      numix-icon-theme
      numix-icon-theme-circle
      sway-contrib.grimshot
      swayidle
      swaylock
      waybar
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

  programs.xwayland.enable = false;

  programs.zsh.enable = true;

  security.rtkit.enable = true;

  services.automatic-timezoned.enable = true;
  # Always running unstable as maintainer
  services.automatic-timezoned.package = pkgs.unstable.automatic-timezoned;

  services.avahi.enable = true;

  services.blueman.enable = true;

  services.connman.enable = true;
  services.connman.extraFlags = [ "--nodnsproxy" ]; # For dnscrypt-proxy
  services.connman.wifi.backend = "iwd";
  # For dnscrypt-proxy: https://wiki.archlinux.org/title/ConnMan#/etc/resolv.conf
  systemd.services.connman.serviceConfig.RuntimeDirectory = "connman";

  services.dnscrypt-proxy2.enable = true;

  services.fwupd.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.gvfs.enable = true;

  services.logind.extraConfig = ''
    RuntimeDirectorySize=20%
  '';

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  services.tumbler.enable = true;

  services.upower.enable = true;

  sound.enable = true;

  # Delegate cpuset to user slice: https://github.com/k3d-io/k3d/issues/1082
  systemd.services."user@".serviceConfig = {
    Delegate = [ "cpuset" ];
  };

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
  virtualisation.podman.defaultNetwork.settings = {
    dns_enabled = true;
  };

  xdg.mime = rec {
    defaultApplications = {
      "application/pdf" = "org.gnome.Evince.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "image/avif" = "imv-folder;imv.desktop";
      "image/bmp" = "imv-folder;imv.desktop";
      "image/gif" = "firefox.desktop";
      "image/heif" = "imv-folder;imv.desktop";
      "image/jpeg" = "imv-folder;imv.desktop";
      "image/jpg" = "imv-folder;imv.desktop";
      "image/pjpeg" = "imv-folder;imv.desktop";
      "image/png" = "imv-folder;imv.desktop";
      "image/svg+xml" = "firefox.desktop";
      "image/tiff" = "imv-folder;imv.desktop";
      "image/x-bmp" = "imv-folder;imv.desktop";
      "image/x-pcx" = "imv-folder;imv.desktop";
      "image/x-png" = "imv-folder;imv.desktop";
      "image/x-portable-anymap" = "imv-folder;imv.desktop";
      "image/x-portable-bitmap" = "imv-folder;imv.desktop";
      "image/x-portable-graymap" = "imv-folder;imv.desktop";
      "image/x-portable-pixmap" = "imv-folder;imv.desktop";
      "image/x-tga" = "imv-folder;imv.desktop";
      "image/x-xbitmap" = "imv-folder;imv.desktop";
      "text/html" = "firefox.desktop";
      "text/plain" = "org.xfce.mousepad.desktop";
      "text/x-readme" = "org.xfce.mousepad.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/mailto" = "thunderbird.desktop";
    };
    addedAssociations = defaultApplications;
  };

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  zramSwap.enable = true;
  # 50% RAM, capped at 4 GiB
  zramSwap.memoryMax = 4294967296;
  zramSwap.memoryPercent = 50;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
