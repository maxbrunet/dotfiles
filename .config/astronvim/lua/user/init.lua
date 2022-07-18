-- Importing gruvbox here would create a circular dependency within the config
-- Hopefully moving to Heirline will make this unnecessary
-- https://github.com/AstroNvim/AstroNvim/issues/686
-- local colors = require("gruvbox.colors")

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
      { "ellisonleao/gruvbox.nvim", version = "29c50f1327d9d84436e484aac362d2fa6bca590b", as = "gruvbox" },
      { "google/vim-jsonnet", version = "b7459b36e5465515f7cf81d0bb0e66e42a7c2eb5" },
    },
    feline = {
      theme = {
        -- Fix theme with gruvbox colors
        -- -- https://github.com/ellisonleao/gruvbox.nvim/blob/main/lua/gruvbox/palette.lua
        fg = "#fbf1c7", -- colors.light0
        bg = "#3c3836", -- colors.dark1
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
      snapshot = "packer_snapshot",
      snapshot_path = vim.fn.stdpath("config"),
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
