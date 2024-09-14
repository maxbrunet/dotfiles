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

local COHERE_API_KEY = os.getenv("COHERE_API_KEY")

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "4.26.1",
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
          "tsserver",
          "yaml",
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
      servers = {
        "bashls",
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
        "ts_ls",
        "yamlls",
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
          -- Hard-code reversed colors
          -- https://github.com/AstroNvim/AstroNvim/issues/1147
          StatusLine = { fg = "#ebdbb2", bg = "#504945" }, -- colors.light1 / colors.dark2
        },
      },
    },
  },
  {
    "AstroNvim/astrocommunity",
    version = "13.2.0",
    { import = "astrocommunity.editing-support.chatgpt-nvim" },
    { import = "astrocommunity.recipes.telescope-lsp-mappings" },
  },
  { "ellisonleao/gruvbox.nvim" },
  { "terrastruct/d2-vim", ft = { "d2" } },
  { "towolf/vim-helm" },
  {
    "m4xshen/smartcolumn.nvim",
    event = { "InsertEnter", "User AstroFile" },
    opts = {
      disabled_filetypes = { "alpha", "neo-tree", "help", "text" },
      scope = "window",
    },
  },
  {
    "jackMort/ChatGPT.nvim",
    opts = {
      api_host_cmd = "echo http://127.0.0.1:4000",
      api_key_cmd = "echo dummy",
    },
  },
  {
    "huggingface/llm.nvim",
    enabled = COHERE_API_KEY ~= nil and COHERE_API_KEY ~= "",
    opts = {
      api_token = COHERE_API_KEY,
      model = "command-r-plus",
      backend = "cohere",
      url = "https://api.cohere.com",
      request_body = {
        preamble = "You are a software engineer. Complete the code. Do not repeat the given code. Do not format with markdown. Do not explain.",
        temperature = 0.2,
        p = 0.95,
      },
      lsp = {
        bin_path = "/run/current-system/sw/bin/llm-ls",
      },
      context_window = 4096,
    }
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
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci", "-bn" },
        }),
      }
      return opts
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
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
      })
    end,
  },
} --[[@as LazySpec]], {
  lockfile = dotfiles_dir_tbl[sysname] .. "/.config/nvim/lazy-lock.json",
} --[[@as LazyConfig]])
