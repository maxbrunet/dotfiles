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
    init = {
      ["ellisonleao/gruvbox.nvim"] = { version = "99e480720f81baa0ad1dddf0cf33fd096fcee176" },
      ["gpanders/editorconfig.nvim"] = { version = "v1.4.0" },
    },
    heirline = function(config)
      config[1] = vim.tbl_deep_extend("force", config[1], {
        -- add mode component
        astronvim.status.component.mode { mode_text = { padding = { left = 1, right = 1 } } },
      })
      return config
    end,
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
      "rls",
      "rnix",
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
    ["server-settings"] = {
      pylsp = {
        settings = {
          pylsp = {
            configurationSources = { "flake8" },
            ["plugins.flake8.enabled"] = true,
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-action"] = "/action.{yml,yaml}",
              ["https://json.schemastore.org/github-workflow"] = "/.github/workflows/*.{yml,yaml}",
              ["https://json.schemastore.org/github-workflow-template-properties"] = "/.github/workflow-templates/*.{yml,yaml}",
              ["https://goreleaser.com/static/schema.json"] = "/.goreleaser.{yml,yaml}",
              ["https://json.schemastore.org/golangci-lint"] = "/.golangci.{yml,yaml}",
              ["https://json.schemastore.org/pre-commit-config"] = "/.pre-commit-config.{yml,yaml}",
              ["https://json.schemastore.org/pre-commit-hooks"] = "/.pre-commit-hooks.{yml,yaml}",
              ["https://json.schemastore.org/semantic-release"] = "/.releaserc.{yml,yaml}",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.{yml,yaml}",
            },
          },
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

    local dap_adapters = {
      "delve",
    }
    local dapconfig_ok, dapconfig = pcall(require, "mason-nvim-dap.automatic_setup")
    if dapconfig_ok then
      vim.tbl_map(dapconfig, dap_adapters)
    end
  end,
}
