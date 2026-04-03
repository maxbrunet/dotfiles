{
  pkgs,
}:

let
  inherit (pkgs) lib vimUtils vimPlugins;

  sources = import ./sources.nix {
    inherit (pkgs) fetchFromGitHub;
  };

  disabledPlugins = [
    "mason-lspconfig.nvim"
    "mason-null-ls.nvim"
    "mason-tool-installer.nvim"
    "mason.nvim"
  ];

  astronvimDeps = builtins.mapAttrs (
    name: info:
    vimUtils.buildVimPlugin {
      pname = name;
      inherit (info) version src;
      doCheck = false;
    }
  ) (lib.filterAttrs (name: _: !builtins.elem name disabledPlugins) sources);

  userPlugins = {
    # Plugin manager
    "lazy.nvim" = vimPlugins.lazy-nvim;

    # AstroNvim itself
    "AstroNvim" = vimPlugins.AstroNvim;
    "astrocommunity" = vimPlugins.astrocommunity;

    # Override astronvimDeps
    "blink.cmp" = vimPlugins.blink-cmp; # needs pre-built Rust native lib

    # User plugins from nixpkgs
    "agentic.nvim" = vimPlugins.agentic-nvim;
    "d2-vim" = pkgs.unstable.vimPlugins.d2-vim;
    "gitlinker.nvim" = vimPlugins.gitlinker-nvim;
    "gruvbox.nvim" = vimPlugins.gruvbox-nvim;
    "img-clip.nvim" = vimPlugins.img-clip-nvim;
    "render-markdown.nvim" = vimPlugins.render-markdown-nvim;
    "schemastore.nvim" = vimPlugins.SchemaStore-nvim;
    "smartcolumn.nvim" = vimPlugins.smartcolumn-nvim;
  };

  allPlugins = astronvimDeps // userPlugins;
in
pkgs.linkFarm "nvim-plugins" (lib.mapAttrsToList (name: path: { inherit name path; }) allPlugins)
