{ config, pkgs, ... }:

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
      source =
        # https://github.com/NixOS/nixpkgs/issues/80109
        let
          oh-my-tmux = pkgs.fetchFromGitHub {
            owner = "gpakosz";
            repo = ".tmux";
            rev = "b69ae7c1a4243afd02c5883a500c61218f6bbf3b";
            sha256 = "sha256-+lYEm72t/03q05RXbcMEHSCtXrXpDkRk9MDPnVLfvJE=";
            stripRoot = false;
          };
        in
        "${oh-my-tmux}/.tmux-${oh-my-tmux.rev}/.tmux.conf";
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
      source = pkgs.fetchFromGitHub {
        owner = "Banno";
        repo = "asdf-kubectl";
        rev = "11ac5c3b0f403f7ead0b4a65bfbb04381ac8139e";
        sha256 = "sha256-7Gf7SnRwtmW13F1cf9M57hQ+fRMUHP2YC4/nuNabP4M=";
      };
    };
    "asdf/plugins/kustomize" = {
      source = pkgs.fetchFromGitHub {
        owner = "Banno";
        repo = "asdf-kustomize";
        rev = "2efaa38011e7ea05c90cfe2ef5ec81d232adfa11";
        sha256 = "sha256-WGLL5hUmFRfp7NDbankrmY5if9dRq/cNJEXBB3DwBA4=";
      };
    };
    "base16/alacritty" = {
      source = pkgs.fetchFromGitHub {
        owner = "aarowill";
        repo = "base16-alacritty";
        rev = "914727e48ebf3eab1574e23ca0db0ecd0e5fe9d0";
        sha256 = "sha256-oDsuiKx8gt+Ov7hZ9PibIQtE81IRSLO+n5N99WeiK34=";
      };
    };
    "base16/fzf" = {
      source = pkgs.fetchFromGitHub {
        owner = "nicodebo";
        repo = "base16-fzf";
        rev = "a7316e7fdb3ec77c5c2cc013a0db4a63ef04a05e";
        sha256 = "sha256-/F613kmyL6xakwjp5+xybFcglIV4oLKdykAsQwNBF8s=";
      };
    };
    "base16/shell" = {
      source = pkgs.fetchFromGitHub {
        owner = "chriskempson";
        repo = "base16-shell";
        rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
        sha256 = "sha256-OMhC6paqEOQUnxyb33u0kfKpy8plLSRgp8X8T8w0Q/o=";
      };
    };
    "oh-my-zsh" = {
      source = pkgs.fetchFromGitHub {
        owner = "ohmyzsh";
        repo = "ohmyzsh";
        rev = "4c82a2eedf0c43d47601ffa8b0303ed1326fab8f";
        sha256 = "sha256-evFMOZUVpF8Qv3os+hx8Z7nC216sZclxO1g9ZaO//QU=";
      };
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
      # onChange = "nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'";
      source = ./.config/astronvim;
    };
    dunst = {
      source = ./.config/dunst;
    };
    "gtk-3.0/settings.ini" = {
      source = ./.config/gtk-3.0/settings.ini;
    };
    nvim = {
      # onChange = "nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'";
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev = "v1.6.1";
        sha256 = "sha256-Sf2iwXl9N54G1SFSDkwLkOLCh6CH0SFrB4ggfBhLETQ=";
      };
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
  home.stateVersion = "22.05";
}
