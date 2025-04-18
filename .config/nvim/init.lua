local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

local dotfiles_dir_tbl = {
  ["Darwin"] = os.getenv('HOME')  .. "/.config/darwin",
  ["Linux"] = "/etc/nixos",
}
local sysname = vim.loop.os_uname().sysname

local CO_API_KEY = os.getenv("CO_API_KEY")

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "4.32.3",
    import = "astronvim.plugins",
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      options = {
        opt = {
          cmdheight = 1, -- Always display cmd line
          foldcolumn = "0", -- Hide foldcolumn
          guicursor = "", -- Disable Nvim GUI cursor
          mouse = "", -- Disable mouse support
          number = false, -- Hide numberline
          relativenumber = false, -- Hide relative numberline
          signcolumn = "auto", -- Show sign column when used only
          spell = true, -- Enable spell checking
        },
      },
     }
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      formatting = {
        disabled = {
          -- use null-ls' prettier instead
          "cssls",
          "html",
          "jsonls",
          "ts_ls",
          "yaml",
        },
        format_on_save = {
          enabled = true,
          allow_filetypes = {
            "d2",
            "go",
            "jsonnet",
            "rust",
            "terraform",
          },
        },
      },
      servers = {
        "bashls",
        "buf_ls",
        "cssls",
        "dockerls",
        "eslint",
        "golangci_lint_ls",
        "gopls",
        "helm_ls",
        "html",
        "jsonls",
        "jsonnet_ls",
        "lua_ls",
        "marksman",
        "nixd",
        "pylsp",
        "ruff",
        "rust_analyzer",
        "terraformls",
        "tflint",
        "ts_ls",
        "yamlls",
      },
      config = {
        bashls = {
          settings = {
            bashIde = {
              shfmt = {
                -- Google-style
                binaryNextLine = true,
                caseIndent = true,
              },
            },
          },
        },
        golangci_lint_ls = {
          init_options = {
            -- https://github.com/nametake/golangci-lint-langserver/issues/51
            command = {
              "golangci-lint",
              "run",
              "--output.json.path=stdout",
              "--show-stats=false",
              "--issues-exit-code=1",
            },
          },
        },
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                pylsp_mypy = {
                  overrides = {
                    "--python-executable=" .. vim.fn.exepath("python"),
                    "--warn-unreachable",
                    true,
                  },
                  strict = true,
                },
              },
            },
          },
        }
      },
    },
  },
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "gruvbox",
      highlights = {
        -- Fix Gruvbox highlight groups
        -- https://github.com/ellisonleao/gruvbox.nvim/blob/main/lua/gruvbox.lua
        gruvbox = {
          NotifyBackground = { bg = "#282828" }, -- colors.dark0
          -- Hard-code reversed colors
          -- https://github.com/AstroNvim/AstroNvim/issues/1147
          StatusLine = { fg = "#ebdbb2", bg = "#504945" }, -- colors.light1 / colors.dark2
        },
      },
    },
  },
  {
    "AstroNvim/astrocommunity",
    version = "17.1.0",
    { import = "astrocommunity.completion.avante-nvim" },
    { import = "astrocommunity.editing-support.chatgpt-nvim" },
    { import = "astrocommunity.git.gitlinker-nvim" },
    { import = "astrocommunity.pack.helm" },
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.yaml" },
    { import = "astrocommunity.recipes.telescope-lsp-mappings" },
  },
  { "ellisonleao/gruvbox.nvim" },
  { "terrastruct/d2-vim", ft = { "d2" } },
  {
    "m4xshen/smartcolumn.nvim",
    event = { "InsertEnter", "User AstroFile" },
    opts = {
      disabled_filetypes = { "alpha", "neo-tree", "help", "text" },
      scope = "window",
    },
  },
  {
    -- Made a direct dependency, because when avante.nvim is disabled, its hash
    -- disappears from the lock file.
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = CO_API_KEY ~= nil and CO_API_KEY ~= "",
  },
  {
    "yetone/avante.nvim",
    enabled = CO_API_KEY ~= nil and CO_API_KEY ~= "",
    dependencies = {
      { "MeanderingProgrammer/render-markdown.nvim" },
    },
    opts = {
      provider = "cohere",
      auto_suggestions_provider = "cohere",
      cohere = {
        model = "command-a-03-2025",
        max_tokens = 8192,
      }
    },
  },
  {
    "jackMort/ChatGPT.nvim",
    opts = {
      api_host_cmd = "echo http://127.0.0.1:5483",
      api_key_cmd = "echo dummy",
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require("astroui.status")
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
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
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
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local null_ls = require "null-ls"
      -- Include code and source with diagnostics message
      opts.diagnostics_format = "[#{c}] #{m} (#{s})"
      opts.sources = {
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.formatting.d2_fmt,
        null_ls.builtins.formatting.prettier,
      }
      return opts
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "bash",
        "dockerfile",
        "go",
        "gomod",
        "hcl",
        "hjson",
        "json",
        "jsonnet",
        "nix",
        "proto",
        "python",
        "regex",
        "rust",
        "terraform",
        "toml",
        "typescript",
      })
    end,
  },
} --[[@as LazySpec]], {
  lockfile = dotfiles_dir_tbl[sysname] .. "/.config/nvim/lazy-lock.json",
} --[[@as LazyConfig]])
