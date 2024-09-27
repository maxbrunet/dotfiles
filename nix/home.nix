{ config
, lib
, pkgs
, base16-alacritty
, base16-fzf
, base16-shell
, oh-my-tmux
, oh-my-zsh
, ...
}:

let
  inherit (pkgs) stdenv;
  inherit (pkgs.python3Packages) litellm;
  litellmProxy = litellm.overridePythonAttrs (prev: {
    dependencies = prev.dependencies
      ++ litellm.optional-dependencies.proxy;
  });
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
    "Library/Application Support/mods/mods.yml" = lib.mkIf stdenv.isDarwin {
      source = ../.config/mods/mods.yml;
    };
  };

  launchd.agents = {
    LiteLLM = {
      config = {
        ProgramArguments = [
          "${litellmProxy}/bin/litellm"
          "--config"
          "${config.xdg.configHome}/litellm/config.yaml"
          "--host"
          "127.0.0.1"
          "--port"
          "5483"
          "--telemetry"
          "False"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/LiteLLM/launchd-stderr.log";
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/LiteLLM/launchd-stdout.log";
      };
      enable = true;
    };
  };

  programs.chromium.enable = true;
  programs.chromium.package = pkgs.writeTextDir "dummy-chromium/chromium" "";
  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
    "hipekcciheckooncpjeljhnekcoolahp" # Tabliss
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
  ];

  xdg.dataFile = {
    "base16/alacritty" = {
      source = base16-alacritty;
    };
    "base16/fzf" = {
      source = base16-fzf;
    };
    "base16/shell" = {
      source = base16-shell;
    };
    "oh-my-zsh" = {
      source = oh-my-zsh;
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
    dunst = lib.mkIf stdenv.isLinux {
      source = ../.config/dunst;
    };
    "gtk-3.0/settings.ini" = lib.mkIf stdenv.isLinux {
      source = ../.config/gtk-3.0/settings.ini;
    };
    "gtk-4.0/settings.ini" = lib.mkIf stdenv.isLinux {
      source = ../.config/gtk-4.0/settings.ini;
    };
    "mods/mods.yml" = lib.mkIf stdenv.isLinux {
      source = ../.config/mods/mods.yml;
    };
    "npm" = {
      source = ../.config/npm;
    };
    nvim = {
      onChange = "PATH=$PATH:${pkgs.git}/bin ${pkgs.neovim}/bin/nvim --headless +quitall";
      source = ../.config/nvim;
    };
    pypoetry = {
      source = ../.config/pypoetry;
    };
    "sway" = lib.mkIf stdenv.isLinux {
      source = ../.config/sway;
    };
    "tinted-theming/theme_name" = { text = "google-dark"; };
    "tmux/tmux.conf" = {
      source = "${oh-my-tmux}/.tmux.conf";
    };
    "tmux/tmux.conf.local" = {
      source = ../.config/tmux/tmux.conf.local;
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
  };

  systemd.user.services = {
    litellm = {
      Unit = {
        Description = "Use any LLM as a drop in replacement for gpt-3.5-turbo.";
        ConditionPathExists = "${config.xdg.configHome}/litellm/config.yaml";
      };
      Install = { WantedBy = [ "default.target" ]; };
      Service = {
        ExecStart = "${litellmProxy}/bin/litellm --config ${config.xdg.configHome}/litellm/config.yaml --host 127.0.0.1 --port 5483 --telemetry False";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    # https://www.kernel.org/doc/html/latest/userspace-api/sysfs-platform_profile.html
    platform-profile-notify =
      let
        script = pkgs.writeShellApplication {
          name = "platform-profile-notify";
          runtimeInputs = with pkgs; [ dunst inotify-tools ];
          text = ''
            inotifywait --event=MODIFY --format=%w --monitor /sys/firmware/acpi/platform_profile \
              | while read -r file; do
                profile="$(<"$file")"
                dunstify \
                  --appname='Platform Profile' \
                  --replace='991049' \
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
        Install = { WantedBy = [ "graphical-session.target" ]; };
        Service = {
          ExecStart = "${script}/bin/platform-profile-notify";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
  };

  xdg.userDirs = lib.mkIf stdenv.isLinux {
    enable = true;
    createDirectories = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
