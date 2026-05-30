{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs) stdenv;
  nvimPlugins = pkgs.callPackage ./pkgs/nvim-plugins { };
  nvimTreesitterParsers = pkgs.callPackage ./pkgs/nvim-treesitter-parsers { };
  opencodeDeps = pkgs.callPackage ./pkgs/opencode-deps { };
in
{
  home.file = {
    ".local/bin/brightness.sh" = lib.mkIf stdenv.isLinux {
      source = ../.local/bin/brightness.sh;
    };
    ".local/bin/volume.sh" = lib.mkIf stdenv.isLinux {
      source = ../.local/bin/volume.sh;
    };
    ".zshrc" = {
      source = ../.zshrc;
    };
    ".librewolf/librewolf.overrides.cfg" = {
      source = ../.librewolf/librewolf.overrides.cfg;
    };
  };

  # Disable installing packages in user profile.
  # Packages are managed at the system level by NixOS and nix-darwin.
  home.packages = lib.mkForce [ ];

  programs.agent-skills = {
    enable = true;
    sources = {
      cc-skills-golang = {
        input = "cc-skills-golang";
        subdir = "skills";
        filter.maxDepth = 1;
      };
      compound-engineering = {
        input = "compound-engineering-plugin";
        subdir = "skills";
        filter.maxDepth = 1;
      };
      gh = {
        path = "${pkgs.gh.src}/skills";
        filter.maxDepth = 1;
        filter.nameRegex = "^gh$";
      };
      google = {
        input = "google-skills";
        subdir = "skills";
        filter.maxDepth = 2;
        filter.nameRegex =
          "cloud/("
          + (builtins.concatStringsSep "|" [
            "cloud-logging-query-generation"
            "cloud-monitoring-chart-generation"
            "cloud-monitoring-list-time-series-request"
            "cloud-monitoring-metric-selection"
            "cloud-sql-basics"
            "gcloud"
            "gke-basics"
            "gke-cost-analysis"
            "gke-networking"
            "gke-observability"
            "gke-reliability"
            "gke-workload-troubleshooting"
            "google-cloud-networking-observability"
          ])
          + ")";
        idPrefix = "google";
      };
    };
    skills.enableAll = true;
    targets.cursor.enable = stdenv.isDarwin;
    targets.opencode.enable = true;
  };

  programs.chromium.enable = true;
  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
    "hipekcciheckooncpjeljhnekcoolahp" # Tabliss
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
  ];

  xdg.dataFile = {
    "base16/alacritty" = {
      source = inputs.base16-alacritty;
    };
    "base16/fzf" = {
      source = inputs.base16-fzf;
    };
    "base16/shell" = {
      source = inputs.base16-shell;
    };
    "nvim/plugins" = {
      source = nvimPlugins;
    };
    "nvim/site/parser" = {
      # nvim-treesitter detects installed parsers from stdpath("data")/site/parser.
      source = "${nvimTreesitterParsers}/parser";
    };
    "oh-my-zsh" = {
      source = inputs.oh-my-zsh;
    };
    "oh-my-zsh-custom" = {
      source = ../.local/share/oh-my-zsh-custom;
    };
  };

  xdg.configFile = {
    "alacritty/alacritty.toml" = {
      source = ../.config/alacritty/alacritty.toml;
    };
    "alacritty/system.toml" = {
      source = ../.config/alacritty/system.toml + "/${lib.toLower stdenv.hostPlatform.uname.system}.toml";
    };
    "azure/config" = {
      source = ../.config/azure/config;
    };
    dunst = lib.mkIf stdenv.isLinux {
      source = ../.config/dunst;
    };
    "gtk-3.0/settings.ini" = lib.mkIf stdenv.isLinux {
      source = ../.config/gtk-3.0/settings.ini;
    };
    "gtk-4.0/settings.ini" = lib.mkIf stdenv.isLinux {
      source = ../.config/gtk-4.0/settings.ini;
    };
    "npm" = {
      source = ../.config/npm;
    };
    nvim = {
      source = ../.config/nvim;
    };
    "opencode/AGENTS.md" = {
      source = ../.config/opencode/AGENTS.md;
    };
    "opencode/opencode.jsonc" = {
      source = ../.config/opencode/opencode.jsonc;
    };
    "opencode/tui.jsonc" = {
      source = ../.config/opencode/tui.jsonc;
    };
    # It does not seem we can disable this, so we package it to avoid surprises
    # https://github.com/anomalyco/opencode/blob/e5cc278dec9294a627a7b05f47ce6a564408c1a2/packages/opencode/src/config/config.ts#L439-L446
    "opencode/node_modules" = {
      source = "${opencodeDeps}/node_modules";
    };
    "opencode/package.json" = {
      source = ../.config/opencode/package.json;
    };
    "opencode/package-lock.json" = {
      source = ../.config/opencode/package-lock.json;
    };
    pypoetry = {
      source = ../.config/pypoetry;
    };
    "sway" = lib.mkIf stdenv.isLinux {
      source = ../.config/sway;
    };
    "tinted-theming/theme_name" = {
      text = "google-dark";
    };
    "uv" = lib.mkIf stdenv.isLinux {
      source = ../.config/uv;
    };
    "waybar" = lib.mkIf stdenv.isLinux {
      source = ../.config/waybar;
    };
    "wofi" = lib.mkIf stdenv.isLinux {
      source = ../.config/wofi;
    };
    "xdg-terminals.list" = lib.mkIf stdenv.isLinux {
      source = ../.config/xdg-terminals.list;
    };
    "xfce4/helpers.rc" = lib.mkIf stdenv.isLinux {
      source = ../.config/xfce4/helpers.rc;
    };
    "zellij" = {
      source = ../.config/zellij;
    };
  };

  services.podman = lib.mkIf stdenv.isDarwin {
    enable = true;
    machines = {
      podman-machine-default = {
        autoStart = true;
        cpus = 4;
        # regctl manifest digest quay.io/podman/machine-os:$(nix eval nixpkgs#podman.version --apply 'v: builtins.elemAt (builtins.match "([0-9]+\.[0-9]+).*" v) 0' --raw)
        image = "docker://quay.io/podman/machine-os@sha256:136b778b34b2ed851d1cb6a42b41038fe3cee5d4538f9d48939e2e14d38abfea";
        memory = 4096;
        # https://github.com/nix-community/home-manager/pull/9368
        volumes = [
          "/Users:/Users"
          "/private:/private"
          "/var/folders:/var/folders"
        ];
      };
    };
    useDefaultMachine = false;
  };

  systemd.user.services = {
    # https://www.kernel.org/doc/html/latest/userspace-api/sysfs-platform_profile.html
    platform-profile-notify =
      let
        script = pkgs.writeShellApplication {
          name = "platform-profile-notify";
          runtimeInputs = with pkgs; [
            dunst
            inotify-tools
          ];
          text = ''
            inotifywait --event=MODIFY --format=%w --monitor /sys/firmware/acpi/platform_profile \
              | while read -r file; do
                profile="$(<"$file")"
                dunstify \
                  --app-name='Platform Profile' \
                  --replace-id='991049' \
                  --urgency='low' \
                  --timeout='2000' \
                  --icon='cpu' \
                  "$profile"
              done
          '';
        };
      in
      {
        Unit = {
          Description = "Notify on platform profile change";
          ConditionPathExists = "/sys/firmware/acpi/platform_profile";
          Requires = [ "dunst.service" ];
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${script}/bin/platform-profile-notify";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
  };

  targets.darwin.defaults = lib.mkIf stdenv.isDarwin {
    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      autohide = true;
      mineffect = "scale";
      mru-spaces = false;
      persistent-apps = [
        {
          tile-data = {
            file-data = {
              _CFURLString = "file:///Applications/Nix%20Apps/LibreWolf.app/";
              _CFURLStringType = 15;
            };
          };
          tile-type = "file-tile";
        }
        {
          tile-data = {
            file-data = {
              _CFURLString = "file:///Applications/Nix%20Apps/Alacritty.app/";
              _CFURLStringType = 15;
            };
          };
          tile-type = "file-tile";
        }
      ];
      persistent-others = [ ];
      show-recents = false;
      tilesize = 48;
      wvous-bl-corner = 5; # Start Screen Saver
      wvous-br-corner = 5; # Start Screen Saver
    };
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
      AppleFnUsageType = 2; # Show Emoji & Symbols
    };
    "com.apple.screensaver" = {
      askForPassword = true;
      askForPasswordDelay = 5; # seconds
    };
    "com.apple.symbolichotkeys" = {
      # What does each part in com.apple.symbolichotkeys.plist mean?
      # https://apple.stackexchange.com/a/474905
      AppleSymbolicHotKeys = {
        # "<ACTION>" = {
        #   enabled = <IS_ENABLED>;
        #   value = {
        #     parameters = [
        #       <ASCII>
        #       <KEY_CODE>
        #       <MODIFIERS>
        #     ];
        #     type = "standard";
        #   };
        # };

        # Ensure Mission Control's Control–Arrow keys shortcuts do not conflict
        # with AstroNvim split resize mappings

        # Mission Control
        "32" = {
          enabled = true;
          value = {
            parameters = [
              65535
              126 # ↑
              9437184 # ⌘ Command
            ];
            type = "standard";
          };
        };

        # Application Windows
        "33" = {
          enabled = true;
          value = {
            parameters = [
              65535
              125 # ↓
              9437184 # ⌘ Command
            ];
            type = "standard";
          };
        };

        # Move left a space
        "79" = {
          enabled = true;
          value = {
            parameters = [
              65535
              123 # ←
              9437184 # ⌘ Command
            ];
            type = "standard";
          };
        };

        # Move right a space
        "81" = {
          enabled = true;
          value = {
            parameters = [
              65535
              124 # →
              9437184 # ⌘ Command
            ];
            type = "standard";
          };
        };
      };
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
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
      "com.apple.swipescrolldirection" = false;
      "com.apple.trackpad.scaling" = 2.0;
      ApplePressAndHoldEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
    };
    "com.apple.assistant.support" = {
      "Search Queries Data Sharing Status" = 2;
    };
  };

  xdg.userDirs = lib.mkIf stdenv.isLinux {
    enable = true;
    createDirectories = true;
    # Until bumping `home.stateVersion` to "26.05" or greater is confirmed safe.
    setSessionVariables = false;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
