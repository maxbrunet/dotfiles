local plugins = vim.fn.stdpath("data") .. "/plugins"
if vim.fn.isdirectory(plugins) == 0 then
  vim.api.nvim_echo({ { "plugins not found at " .. plugins .. "\n", "ErrorMsg" } }, true, {})
  vim.cmd.quit()
end

vim.opt.rtp:prepend(plugins .. "/lazy.nvim")

local CO_API_KEY = os.getenv("CO_API_KEY")

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
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
            "nix",
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
    { import = "astrocommunity.completion.avante-nvim" },
    { import = "astrocommunity.git.gitlinker-nvim" },
    { import = "astrocommunity.pack.helm" },
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.yaml" },
    { import = "astrocommunity.recipes.picker-lsp-mappings" },
  },
  { "ellisonleao/gruvbox.nvim" },
  { "terrastruct/d2-vim", ft = { "d2" } },
  {
    "m4xshen/smartcolumn.nvim",
    event = { "InsertEnter", "User AstroFile" },
    opts = {
      disabled_filetypes = { "snacks_dashboard", "neo-tree", "help", "text" },
      scope = "window",
    },
  },
  {
    "yetone/avante.nvim",
    enabled = CO_API_KEY ~= nil and CO_API_KEY ~= "",
    dependencies = {
      { "MeanderingProgrammer/render-markdown.nvim" },
      { "Kaiser-Yang/blink-cmp-avante" },
    },
    opts = {
      provider = "opencode",
      acp_providers = {
        ["opencode"] = {
          command = "opencode",
          args = { "acp" },
          env = {
            CO_API_KEY = CO_API_KEY,
            TAVILY_API_KEY = os.getenv("TAVILY_API_KEY"),
          },
        },
      },
      providers = {
        cohere = {
          __inherited_from = "openai",
          api_key_name = "CO_API_KEY",
          endpoint = "https://api.cohere.ai/compatibility/v1",
          model = "command-a-reasoning-08-2025",
          context_window = 256000,
          tokenizer_id = "https://storage.googleapis.com/cohere-public/tokenizers/command-a-reasoning-08-2025.json",
          extra_request_body = {
            max_tokens = 8192,
          },
        },
      },
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
  { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
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
    init = function()
      -- Nix-built treesitter grammars
      vim.opt.rtp:prepend(plugins .. "/nvim-treesitter-grammars")
    end,
    opts = function(_, opts)
      opts.ensure_installed = {}
      opts.auto_install = false
    end,
  },
} --[[@as LazySpec]], {
  dev = {
    -- Use the plugins installed by home-manager
    path = plugins,
    -- They should all come from there
    patterns = { "." },
    -- No fallback to Git if non-existent
    fallback = false,
  },
  checker = { enabled = false },
  install = { missing = false },
  -- Disable lockfile
  lockfile = "/dev/null",
  readme = { enabled = false },
} --[[@as LazyConfig]])
