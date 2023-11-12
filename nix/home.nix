{ config
, lib
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

let
  inherit (pkgs) stdenv;
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
  };

  xdg.dataFile = {
    "rtx/plugins/kubectl" = {
      source = asdf-kubectl;
    };
    "rtx/plugins/kustomize" = {
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
    "alacritty/alacritty.yml" = {
      source = ../.config/alacritty/alacritty.yml;
    };
    "alacritty/system.yml" = {
      source = ../.config/alacritty/system.yml + "/${lib.toLower stdenv.hostPlatform.uname.system}.yml";
    };
    astronvim = {
      onChange = "PATH=$PATH:${pkgs.git}/bin ${pkgs.neovim}/bin/nvim --headless +quitall";
      source = ../.config/astronvim;
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
    nvim = {
      onChange = "PATH=$PATH:${pkgs.git}/bin ${pkgs.neovim}/bin/nvim --headless +quitall";
      source = astronvim;
    };
    pypoetry = {
      source = ../.config/pypoetry;
    };
    "sway" = lib.mkIf stdenv.isLinux {
      source = ../.config/sway;
    };
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
    "xfce4/helpers.rc" = lib.mkIf stdenv.isLinux {
      source = ../.config/xfce4/helpers.rc;
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
  home.stateVersion = "23.05";
}
