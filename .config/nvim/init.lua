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
    init = function()
      -- Expose nvim-treesitter's bundled queries on runtimepath.
      vim.opt.rtp:prepend(plugins .. "/nvim-treesitter/runtime")
    end,
    ---@param _ LazyPlugin
    ---@param opts AstroCoreOpts
    ---@return AstroCoreOpts
    opts = function(_, opts)
      opts = require("astrocore").extend_tbl(opts, {
        options = {
          opt = {
            cmdheight = 1,          -- Always display cmd line
            foldcolumn = "0",       -- Hide foldcolumn
            guicursor = "",         -- Disable Nvim GUI cursor
            mouse = "",             -- Disable mouse support
            number = false,         -- Hide numberline
            relativenumber = false, -- Hide relative numberline
            signcolumn = "auto",    -- Show sign column when used only
            spell = true,           -- Enable spell checking
          },
        },
        treesitter = {
          auto_install = false,
        },
      }) --[[@as AstroCoreOpts]]
      -- Must be assigned directly so AstroNvim's list-extension logic doesn't keep defaults.
      opts.treesitter.ensure_installed = {}
      return opts
    end,
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
        "docker_language_server",
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
        "ruff",
        "rust_analyzer",
        "terraformls",
        "tflint",
        "ts_ls",
        "ty",
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
    { import = "astrocommunity.git.gitlinker-nvim" },
    { import = "astrocommunity.media.img-clip-nvim" },
    { import = "astrocommunity.pack.helm" },
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.yaml" },
    { import = "astrocommunity.recipes.picker-lsp-mappings" },
  },
  {
    "carlos-algms/agentic.nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          opts.autocmds = opts.autocmds or {}
          opts.autocmds.agentic_input = {
            {
              event = "FileType",
              pattern = "AgenticChat",
              callback = function(args)
                vim.treesitter.start(args.buf, "markdown")
              end,
            },
            {
              event = "FileType",
              pattern = "AgenticInput",
              callback = function(args)
                vim.b[args.buf].completion = false
              end,
            },
          }

          local prefix = "<Leader>a"
          local icon = require("astroui").get_icon("Agentic", 1, true)
          local common_mappings = {
            ["<CR>"] = { function() require("agentic").toggle() end, "Toggle chat" },
            ["n"] = { function() require("agentic").new_session() end, "New session" },
            ["r"] = { function() require("agentic").restore_session() end, "Restore session" },
          }
          local mode_mappings = {
            n = vim.tbl_extend("force", common_mappings, {
              ["a"] = { function() require("agentic").add_selection_or_file_to_context() end, "Add file to context" },
              ["d"] = { function() require("agentic").add_current_line_diagnostics() end, "Add current line diagnostic to context" },
              ["D"] = { function() require("agentic").add_buffer_diagnostics() end, "Add all buffer diagnostics to context" },
            }),
            v = vim.tbl_extend("force", common_mappings, {
              ["a"] = { function() require("agentic").add_selection_or_file_to_context() end, "Add selection to context" },
            }),
          }
          for mode, mappings in pairs(mode_mappings) do
            opts.mappings[mode][prefix] = { desc = icon .. "Agentic" }
            for suffix, spec in pairs(mappings) do
              opts.mappings[mode][prefix .. suffix] = { spec[1], desc = spec[2] }
            end
          end
        end,
      },
      { "AstroNvim/astroui", opts = { icons = { Agentic = "" } } },
      { "hakonharnes/img-clip.nvim" },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        cmd = "RenderMarkdown",
        ft = function()
          local plugin = require("lazy.core.config").spec.plugins["render-markdown.nvim"]
          local opts = require("lazy.core.plugin").values(plugin, "opts", false)
          local default = require("render-markdown").default
          opts.file_types = require("astrocore").list_insert_unique(opts.file_types or default.file_types, { "AgenticChat" })
          return opts.file_types
        end,
      },
    },
    opts = {
      provider = vim.loop.os_uname().sysname == "Darwin" and "cursor-acp" or "opencode-acp",
      acp_providers = {
        ["cursor-acp"] = {
          env = {
            HOME = os.getenv("HOME"),
            PATH = os.getenv("PATH"),
            TAVILY_API_KEY = os.getenv("TAVILY_API_KEY"),
          },
        },
        ["opencode-acp"] = {
          env = {
            CO_API_KEY = CO_API_KEY,
            TAVILY_API_KEY = os.getenv("TAVILY_API_KEY"),
          },
        },
      },
    },
  },
  { "ellisonleao/gruvbox.nvim" },
  { "terrastruct/d2-vim",      ft = { "d2" } },
  {
    "m4xshen/smartcolumn.nvim",
    event = { "InsertEnter", "User AstroFile" },
    opts = {
      disabled_filetypes = { "snacks_dashboard", "neo-tree", "help", "text" },
      scope = "window",
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
  { "jay-babu/mason-null-ls.nvim",               enabled = false },
  { "mason-org/mason-lspconfig.nvim",            enabled = false },
  { "mason-org/mason.nvim",                      enabled = false },
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
