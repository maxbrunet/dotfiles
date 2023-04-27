return {
  colorscheme = "gruvbox",

  options = {
    opt = {
      cmdheight = 1, -- Always display cmd line
      guicursor = "", -- Disable Nvim GUI cursor
      mouse = "", -- Disable mouse support
      number = false, -- Hide numberline
      relativenumber = false, -- Hide relative numberline 
      signcolumn = "auto", -- Show sign column when used only
      spell = true, -- Enable spell checking
    },
  },

  highlights = {
    -- Fix Gruvbox highlight groups
    -- https://github.com/ellisonleao/gruvbox.nvim/blob/main/lua/gruvbox/palette.lua
    gruvbox = {
      -- Hard-code reversed colors 
      -- https://github.com/AstroNvim/AstroNvim/issues/1147
      StatusLine = { fg = "#ebdbb2", bg = "#504945" }, -- colors.light1 / colors.dark2
    },
  },

  plugins = {
    { "ellisonleao/gruvbox.nvim", version = "99e480720f81baa0ad1dddf0cf33fd096fcee176" },
    { "gpanders/editorconfig.nvim", version = "v1.4.0" },
    { 
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require("astronvim.utils.status")
        opts.statusline = vim.tbl_deep_extend("force", opts.statusline, {
          -- add mode component
          status.component.mode { mode_text = { padding = { left = 1, right = 1 } } },
        })
        return opts
      end
    },
    {
      "jay-babu/mason-nvim-dap.nvim",
      config = function()
        local dap = require('dap')
        local adapters = require('mason-nvim-dap.mappings.adapters')
        local configurations = require('mason-nvim-dap.mappings.configurations')

        dap.adapters.delve = adapters.delve
        dap.configurations.go = configurations.delve
      end,
    },
    { 
      "nvim-neo-tree/neo-tree.nvim", 
      opts = {
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
          },
        },
      }
    },
    { 
      "jose-elias-alvarez/null-ls.nvim",
      opts = function(_, opts)
        local null_ls = require "null-ls"
        -- Include code and source with diagnostics message
        opts.diagnostics_format = "[#{c}] #{m} (#{s})"
        opts.sources = {
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.golangci_lint,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.gofumpt.with({
            extra_args = { "-extra" },
          }),
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.shfmt.with({
            extra_args = { "-i", "2", "-ci", "-bn"},
          }),
        }
        return opts
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = {
          "bash",
          "go",
          "gomod",
          "hcl",
          "jsonnet",
          "nix",
          "python",
          "regex",
          "rust",
          "terraform",
          "typescript",
        },
      },
    },
  },

  lsp = {
    servers = {
      "bashls",
      "cssls",
      "eslint",
      "gopls",
      "html",
      "jsonls",
      "jsonnet_ls",
      "pylsp",
      "rnix",
      "rust_analyzer",
      "terraformls",
      "tsserver",
      "yamlls",
    },
    formatting = {
      disabled = {
        -- use null-ls' gofumpt/goimports instead 
        -- https://github.com/golang/tools/pull/410
        "gopls", 
        -- use null-ls' prettier instead
        "tsserver", 
      },
      format_on_save = {
        enabled = true,
        allow_filetypes = {
          "go",
          "jsonnet",
          "rust",
          "terraform",
        },
      },
    },
  },

  polish = function()
    vim.filetype.add({
      extension = {
        -- Map .libsonnet files to jsonnet filetype
        -- https://github.com/neovim/neovim/pull/20753
        libsonnet = "jsonnet",
      }
    })

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Highlight lines over 80 characters long",
      callback = function()
        if vim.bo.filetype == "alpha" then
          return
        end
        vim.cmd([[
          highlight ColorColumn ctermbg=DarkRed guibg=DarkRed
          call matchadd('ColorColumn', '\%81v', 100)
        ]])
      end,
    })
  end,
}
