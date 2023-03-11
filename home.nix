{ config, pkgs, ... }:

let
  sources = import ./nix/sources.nix;
in
{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  home.file = {
    ".local/bin/brightness.sh" = {
      source = ./.local/bin/brightness.sh;
    };
    ".local/bin/volume.sh" = {
      source = ./.local/bin/volume.sh;
    };
    ".tmux.conf" = {
      source = "${sources.oh-my-tmux}/.tmux.conf";
    };
    ".tmux.conf.local" = {
      source = ./.tmux.conf.local;
    };
    ".zshrc" = {
      source = ./.zshrc;
    };
  };

  xdg.dataFile = {
    "asdf/plugins/kubectl" = {
      source = sources.asdf-kubectl;
    };
    "asdf/plugins/kustomize" = {
      source = sources.asdf-kustomize;
    };
    "base16/alacritty" = {
      source = sources.base16-alacritty;
    };
    "base16/fzf" = {
      source = sources.base16-fzf;
    };
    "base16/shell" = {
      source = sources.base16-shell;
    };
    "oh-my-zsh" = {
      source = sources.oh-my-zsh;
    };
    "oh-my-zsh-custom" = {
      source = ./.local/share/oh-my-zsh-custom;
    };
  };

  xdg.configFile = {
    alacritty = {
      source = ./.config/alacritty;
    };
    astronvim = {
      onChange = "nvim --headless -c 'if exists(\":LuaCacheClear\") | :LuaCacheClear' +quitall";
      source = ./.config/astronvim;
    };
    dunst = {
      source = ./.config/dunst;
    };
    "gtk-3.0/settings.ini" = {
      source = ./.config/gtk-3.0/settings.ini;
    };
    "gtk-4.0/settings.ini" = {
      source = ./.config/gtk-4.0/settings.ini;
    };
    nvim = {
      onChange = "nvim --headless -c 'if exists(\":LuaCacheClear\") | :LuaCacheClear' +quitall";
      source = sources.astronvim;
    };
    "sway" = {
      source = ./.config/sway;
    };
    "waybar" = {
      source = ./.config/waybar;
    };
    "wofi" = {
      source = ./.config/wofi;
    };
    "xfce4/helpers.rc" = {
      source = ./.config/xfce4/helpers.rc;
    };
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
