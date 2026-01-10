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
  ["Darwin"] = "/etc/nix-darwin",
  ["Linux"] = "/etc/nixos",
}
local sysname = vim.loop.os_uname().sysname

local CO_API_KEY = os.getenv("CO_API_KEY")

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "5.3.14",
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
    version = "19.0.0",
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
    -- Made a direct dependency, because when avante.nvim is disabled, its hash
    -- disappears from the lock file.
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = CO_API_KEY ~= nil and CO_API_KEY ~= "",
  },
  {
    "Kaiser-Yang/blink-cmp-avante",
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
      providers = {
        cohere = {
          model = "command-a-03-2025",
          extra_request_body = {
            max_tokens = 8192,
          },
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    version = "18.3.1",
    enabled = CO_API_KEY ~= nil and CO_API_KEY ~= "",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = function(_, opts)
          if not opts.file_types then opts.file_types = { "markdown" } end
          opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "codecompanion" })
        end,
      },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          local prefix = "<Leader>C"
          maps.n[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
          maps.v[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
          maps.n[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
          maps.v[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
          maps.n[prefix .. "i"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
          maps.v[prefix .. "i"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
          maps.n[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
          maps.v[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
          maps.v[prefix .. "a"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to chat" }

          vim.cmd([[cab cc CodeCompanion]])
        end,
      },
      { "AstroNvim/astroui", opts = { icons = { CodeCompanion = "󰚩" } } },
    },
    opts = {
      adapters = {
        cohere = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "cohere",
            formatted_name = "Cohere",
            env = {
              url = "https://api.cohere.ai/compatibility",
              api_key = CO_API_KEY,
            },
            handlers = {
              -- overwrite setup to remove unsupported stream_options
              setup = function(self)
                if self.opts and self.opts.stream then
                  self.parameters.stream = true
                end
                return true
              end,
            },
            schema = {
              model = {
                default = "command-a-03-2025",
              },
            },
          })
        end,
      },
      display = {
        action_palette = {
          provider = "snacks",
        },
        chat = {
          start_in_insert_mode = true,
        },
      },
      strategies = {
        chat = {
          adapter = "cohere",
        },
        inline = {
          adapter = "cohere",
        },
        cmd = {
          adapter = "cohere",
        }
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
