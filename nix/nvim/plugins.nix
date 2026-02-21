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
    "avante.nvim" = pkgs.unstable.vimPlugins.avante-nvim;
    "blink-cmp-avante" = vimPlugins.blink-cmp-avante;
    "d2-vim" = vimPlugins.d2-vim;
    "gitlinker.nvim" = vimPlugins.gitlinker-nvim;
    "gruvbox.nvim" = vimPlugins.gruvbox-nvim;
    "render-markdown.nvim" = vimPlugins.render-markdown-nvim;
    "schemastore.nvim" = vimPlugins.SchemaStore-nvim;
    "smartcolumn.nvim" = vimPlugins.smartcolumn-nvim;
  };

  treesitterGrammars = {
    "nvim-treesitter-grammars" = pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths =
        let
          p = vimPlugins.nvim-treesitter-parsers;
        in
        [
          p.bash
          p.dockerfile
          p.go
          p.gomod
          p.hcl
          p.helm
          p.hjson
          p.json
          p.jsonnet
          p.lua
          p.markdown
          p.markdown_inline
          p.nix
          p.proto
          p.python
          p.query
          p.regex
          p.rust
          p.terraform
          p.toml
          p.typescript
          p.vim
          p.vimdoc
          p.yaml
        ];
    };
  };

  allPlugins = astronvimDeps // userPlugins // treesitterGrammars;
in
pkgs.linkFarm "nvim-plugins" (lib.mapAttrsToList (name: path: { inherit name path; }) allPlugins)
