local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=v10.21.0", lazypath })
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

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "4.7.7",
    import = "astronvim.plugins",
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local get_icon = require("astroui").get_icon
      local chatgpt_mappings = {
        ["<Leader>m"] = { desc = get_icon("ChatGPT", 1, true) .. "ChatGPT" },
        ["<Leader>mc"] = { "<Cmd>ChatGPT<CR>", desc = "ChatGPT" },
        ["<Leader>mC"] = { "<Cmd>ChatGPTActAs<CR>", desc = "ChatGPT Acts As ..." },
        ["<Leader>me"] = { "<Cmd>ChatGPTEditWithInstruction<CR>", desc ="Edit with instruction" },
        ["<Leader>mg"] = { "<Cmd>ChatGPTRun grammar_correction<CR>", desc ="Grammar Correction" },
        ["<Leader>mt"] = { "<Cmd>ChatGPTRun translate<CR>", desc ="Translate" },
        ["<Leader>mk"] = { "<Cmd>ChatGPTRun keywords<CR>", desc ="Keywords" },
        ["<Leader>md"] = { "<Cmd>ChatGPTRun docstring<CR>", desc ="Docstring" },
        ["<Leader>ma"] = { "<Cmd>ChatGPTRun add_tests<CR>", desc ="Add Tests" },
        ["<Leader>mo"] = { "<Cmd>ChatGPTRun optimize_code<CR>", desc ="Optimize Code" },
        ["<Leader>ms"] = { "<Cmd>ChatGPTRun summarize<CR>", desc ="Summarize" },
        ["<Leader>mf"] = { "<Cmd>ChatGPTRun fix_bugs<CR>", desc ="Fix Bugs" },
        ["<Leader>mx"] = { "<Cmd>ChatGPTRun explain_code<CR>", desc ="Explain Code" },
        ["<Leader>mr"] = { "<Cmd>ChatGPTRun roxygen_edit<CR>", desc ="Roxygen Edit" },
        ["<Leader>ml"] = { "<Cmd>ChatGPTRun code_readability_analysis<CR>", desc ="Code Readability Analysis" },
      }

      return vim.tbl_deep_extend("force", opts,
        ---@type AstroCoreOpts
        {
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
          mappings = {
            n = chatgpt_mappings,
            v = chatgpt_mappings,
          },
        }
      )
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
        "eslint",
        "gopls",
        "helm_ls",
        "html",
        "jsonls",
        "jsonnet_ls",
        "lua_ls",
        "nixd",
        "pylsp",
        "ruff_lsp",
        "rust_analyzer",
        "terraformls",
        "tsserver",
        "yamlls",
      },
    },
  },
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    config = {
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
      icons = {
        ChatGPT = "󰭹",
      }
    },
  },
  { "ellisonleao/gruvbox.nvim", version = "2.0.0" },
  { "terrastruct/d2-vim", version = "981c87dccb63df2887cc41b96e84bf550f736c57", ft = { "d2" }},
  { "towolf/vim-helm", version = "9425cf68d2a73d2efbfd05ab3e8b80ffb5a08802" },
  {
    "jackMort/ChatGPT.nvim",
    cmd = {
      "ChatGPT",
      "ChatGPTActAs",
      "ChatGPTEditWithInstructions",
      "ChatGPTRun",
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/trouble.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      api_host_cmd = "echo http://127.0.0.1:4000",
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
        null_ls.builtins.diagnostics.golangci_lint.with({
          extra_args = { "--fast" },
        }),
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
