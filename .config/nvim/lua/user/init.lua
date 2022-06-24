local colors = require("gruvbox.colors")

local config = {
  colorscheme = "gruvbox",

  options = {
    opt = {
      guicursor = "", -- Disable Nvim GUI cursor
      mouse = "", -- Disable mouse support
      number = false, -- Hide numberline
      relativenumber = false, -- Hide relative numberline 
      signcolumn = "auto", -- Show sign column when used only
      spell = true, -- Enable spell checking
    },
  },

  plugins = {
    init = {
      { "editorconfig/editorconfig-vim", version = "v1.1.1" },
      { "ellisonleao/gruvbox.nvim", as = "gruvbox" },
      { "google/vim-jsonnet" },
    },
    feline = {
      -- Fix theme with gruvbox colors
      theme = {
        fg = colors.light0,
        bg = colors.dark1,
      },
    },
    ["neo-tree"] = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
    },
    ["null-ls"] = function(config)
      local null_ls = require "null-ls"
      -- Include code and source with diagnostics message
      config.diagnostics_format = "[#{c}] #{m} (#{s})"
      config.sources = {
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.golangci_lint,
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.gofumpt.with({
          extra_args = { "-extra" },
        }),
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci", "-bn"},
        }),
        null_ls.builtins.formatting.terraform_fmt,
      }
      return config
    end,
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

  lsp = {
    servers = {
      "pylsp",
      "rnix",
      "rls",
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
