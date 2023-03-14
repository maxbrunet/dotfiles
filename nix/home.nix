{ config
, pkgs
, astronvim
, asdf-kubectl
, asdf-kustomize
, base16-alacritty
, base16-fzf
, base16-shell
, oh-my-tmux
, oh-my-zsh
, ...
}:

{
  home.username = "maxime";
  home.homeDirectory = "/home/maxime";

  home.file = {
    ".local/bin/brightness.sh" = {
      source = ../.local/bin/brightness.sh;
    };
    ".local/bin/volume.sh" = {
      source = ../.local/bin/volume.sh;
    };
    ".zshrc" = {
      source = ../.zshrc;
    };
  };

  xdg.dataFile = {
    "asdf/plugins/kubectl" = {
      source = asdf-kubectl;
    };
    "asdf/plugins/kustomize" = {
      source = asdf-kustomize;
    };
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
    alacritty = {
      source = ../.config/alacritty;
    };
    astronvim = {
      onChange = "${pkgs.neovim}/bin/nvim --headless +quitall";
      source = ../.config/astronvim;
    };
    dunst = {
      source = ../.config/dunst;
    };
    "gtk-3.0/settings.ini" = {
      source = ../.config/gtk-3.0/settings.ini;
    };
    "gtk-4.0/settings.ini" = {
      source = ../.config/gtk-4.0/settings.ini;
    };
    nvim = {
      onChange = "${pkgs.neovim}/bin/nvim --headless +quitall";
      source = astronvim;
    };
    "sway" = {
      source = ../.config/sway;
    };
    "tmux/tmux.conf" = {
      source = "${oh-my-tmux}/.tmux.conf";
    };
    "tmux/tmux.conf.local" = {
      source = ../.config/tmux/tmux.conf.local;
    };
    "waybar" = {
      source = ../.config/waybar;
    };
    "wofi" = {
      source = ../.config/wofi;
    };
    "xfce4/helpers.rc" = {
      source = ../.config/xfce4/helpers.rc;
    };
  };

  xdg.userDirs = {
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
  home.stateVersion = "22.11";
}
