{
  pkgs,
}:

let
  p = pkgs.vimPlugins.nvim-treesitter-parsers;
in
pkgs.symlinkJoin {
  name = "nvim-treesitter-parsers";
  paths = [
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
}
