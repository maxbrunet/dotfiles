local config = {
  colorscheme = "gruvbox",

  options = {
    opt = {
      guicursor = "", -- Disable Nvim GUI cursor
      mouse = "", -- Disable mouse support
      number = false, -- Hide numberline
      relativenumber = false, -- Hide relative numberline 
      signcolumn = "auto", -- Show sign column when used only
    },
  },

  plugins = {
    init = {
      { "editorconfig/editorconfig-vim", version = "v1.1.1" },
      { "ellisonleao/gruvbox.nvim", as = "gruvbox" },
      { "google/vim-jsonnet" },
    },
    packer = {
      snapshot = "packer.snapshot.json",
      snapshot_path = vim.fn.stdpath "config" .. "/lua/user",
    },
    session_manager = {
      autosave_last_session = true,
    },
    treesitter = {
      ensure_installed = {
        "hcl",
        "gomod",
        "nix",
      },
    },
  },

  ["null-ls"] = function()
    local status_ok, null_ls = pcall(require, "null-ls")
    if not status_ok then
      return
    end

    local formatting = null_ls.builtins.formatting

    local diagnostics = null_ls.builtins.diagnostics

    null_ls.setup {
      -- Include code and source with diagnostics message
      diagnostics_format = "[#{c}] #{m} (#{s})",
      sources = {
        diagnostics.flake8,
        diagnostics.golangci_lint,
        diagnostics.shellcheck,
        formatting.black,
        formatting.gofmt,
        formatting.goimports,
        formatting.isort,
        formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci", "-bn"},
        }),
        formatting.terraform_fmt,
      },
    }
  end,

  lsp = {
    servers = {
      "pylsp",
      "rnix",
      "terraformls",
      "gopls",
    },
  },

  polish = function()
    -- Highlight lines over 80 characters long
    vim.cmd([[
      highlight ColorColumn ctermbg=DarkRed guibg=DarkRed
      call matchadd('ColorColumn', '\%81v', 100)
    ]])
  end,
}

return config
