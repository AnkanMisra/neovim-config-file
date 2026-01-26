-----------------------------------------------------------
-- LAZY.NVIM BOOTSTRAP
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- BASIC SETTINGS
-----------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 0
vim.opt.updatetime = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Hide statusline for maximum vertical space
vim.opt.laststatus = 0

-- Disable swap files to avoid E325 errors
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Treat issue docs without extensions as markdown
vim.filetype.add({
  pattern = {
    [".*/gateway/issues/.*"] = "markdown",
  },
})

-----------------------------------------------------------
-- LEADER
-----------------------------------------------------------
vim.g.mapleader = " "

-----------------------------------------------------------
-- KEYMAPS
-----------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>h", ":nohlsearch<CR>")
map("n", "<leader>e", ":Ex<CR>")
map("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
  if vim.bo.filetype == "markdown" or vim.bo.filetype == "text" then
    vim.wo.linebreak = vim.wo.wrap
  end
end, { desc = "Toggle word wrap" })
-- Make :ex (or :Ex) quit all instead of netrw
vim.cmd([[cnoreabbrev <expr> ex getcmdtype() == ':' && getcmdline() == 'ex' ? 'qa' : 'ex']])

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "NvimTree" },
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.linebreak = false
  end,
})

-----------------------------------------------------------
-- PLUGINS
-----------------------------------------------------------
require("lazy").setup({

  {
    "nvim-tree/nvim-web-devicons",
    config = true,
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      picker   = { enabled = true },
      explorer = { enabled = true },
      terminal = { enabled = true },
      notifier = { enabled = true },

      dashboard = {
  enabled = true,
  width = 50,

  header = [[
 ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
 ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],

  sections = {
    { section = "header", padding = 2 },
    { section = "keys", gap = 1, padding = 1 },
    { section = "recent_files", limit = 4, padding = 1 },
    { section = "startup", padding = 1 },
  },
},


      statuscolumn = { enabled = true },
      image = {
        enabled = true,
        backend = "kitty",
      },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
    },
  },

  ---------------------------------------------------------
  -- THEME
  ---------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
          cmp = true,
          gitsigns = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  ---------------------------------------------------------
  -- TREESITTER
  ---------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      pcall(function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            -- Core / systems
            "c", "cpp", "cmake", "make",
            "bash", "dockerfile",

            -- Popular app/backend
            "go", "rust",
            "java", "kotlin",
            "python",
            "php", "ruby",
            "c_sharp", "swift",

            -- Web
            "javascript", "typescript", "tsx",
            "html", "css", "scss",
            "vue", "svelte",

            -- Data / config
            "json", "yaml", "toml", "xml",
            "sql", "graphql", "regex",
            "proto", "terraform", "hcl",

            -- Docs / editor
            "markdown", "markdown_inline",
            "gitignore",
            "vim", "vimdoc", "query",
          },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end)
    end,
  },

  ---------------------------------------------------------
  -- LSP INSTALLER
  ---------------------------------------------------------
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
        ensure_installed = {
          -- Core
          "clangd",
          "lua_ls",

          -- Popular
          "pyright",
          "gopls",
          "rust_analyzer",
          "jdtls",
          "ts_ls",

          -- Web/config hehe idk comment
          "eslint",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "dockerls",
          "bashls",
          "taplo",
          "marksman",
          "terraformls",
          "tailwindcss",
        },
      })
    end,
  },

  ---------------------------------------------------------
  -- MARKDOWN PREVIEW
  ---------------------------------------------------------
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    config = true,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_preview_options = {
        markdown = {
          mermaid = true,
        },
        disable_filename = 1,
      }
    end,
  },

  ---------------------------------------------------------
  -- LSP
  ---------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        -- Systems
        clangd = {},

        -- Popular
        pyright = {},
        gopls = {},
        rust_analyzer = {},
        ts_ls = {},
        jdtls = {},

        -- Web/config
        eslint = {},
        html = {},
        cssls = {},
        jsonls = {},
        yamlls = {},
        dockerls = {},
        bashls = {},
        taplo = {},
        marksman = {},
        terraformls = {},
        tailwindcss = {},

        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(server, config)
      end

      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },

  ---------------------------------------------------------
  -- GITHUB COPILOT
  ---------------------------------------------------------
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true, -- suggestions appear while typing
          keymap = {
            accept = "<C-l>", -- accept suggestion
            next = "<M-]>",   -- Alt+] for next
            prev = "<M-[>",   -- Alt+[ for prev (NOT Ctrl+[ which is Escape!)
            dismiss = "<C-e>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  ---------------------------------------------------------
  -- AUTOCOMPLETE
  ---------------------------------------------------------
  {
    "onsails/lspkind.nvim",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        completion = {
          autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(), -- Ctrl+E to close menu
        }),
        sources = {
          { name = "copilot" }, -- AI first
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text", -- shows icon + text
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            require("cmp.config.compare").offset,
            require("cmp.config.compare").exact,
            require("cmp.config.compare").score,

            require("cmp.config.compare").kind,      
            require("cmp.config.compare").sort_text,
            require("cmp.config.compare").length,
            require("cmp.config.compare").order,
          },
        },
      })
    end,
  },

  ---------------------------------------------------------
  -- AUTOPAIRS
  ---------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  ---------------------------------------------------------
  -- GIT
  ---------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    -- Disable Cmd+Shift+V paste in markdown buffers to avoid accidental paste
    vim.keymap.set("n", "<D-S-v>", "<Nop>", { buffer = args.buf })
    -- Preview (browser with mermaid)
    vim.keymap.set("n", "<D-M-p>", "<cmd>MarkdownPreviewToggle<CR>", { buffer = args.buf, desc = "Markdown preview" })
    -- Terminal preview fallback
    vim.keymap.set("n", "<leader>vg", "<cmd>Glow<CR>", { buffer = args.buf, desc = "Glow preview" })
  end,
})

local Snacks = require("snacks")

-- Cmd+P (files)
vim.keymap.set("n", "<D-p>", function()
  Snacks.picker.files({
    hidden = true,
    ignored = false,
  })
end)

-- Cmd+G (grep)
vim.keymap.set("n", "<D-g>", function()
  require("snacks").picker.grep()
end, { desc = "Search text (Snacks)" })

-- Cmd+E (explorer)
vim.keymap.set("n", "<D-e>", function()
  require("snacks").explorer()
end, { desc = "Explorer (Snacks)" })

-- Cmd+T (terminal)
vim.keymap.set("n", "<D-t>", function()
  require("snacks").terminal()
end, { desc = "Terminal (Snacks)" })

-- Leader+GG (lazygit)
vim.keymap.set("n", "<leader>gg", function()
  require("snacks").lazygit()
end, { desc = "Lazygit (Snacks)" })

-- Markdown UX
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    -- Soft wrap for writing
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    -- Quick actions
    vim.keymap.set("n", "<leader>mp", function()
      require("snacks").picker.grep({ search = "^#" })
    end, { buffer = true, desc = "Headings (Snacks)" })

    vim.keymap.set("n", "<leader>mt", function()
      require("snacks").terminal()
    end, { buffer = true, desc = "Terminal (Snacks)" })
  end,
})

-- Hide mode since statusline shows it
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.opt.showmode = false
  end,
})

-- Also set it here to avoid flicker on startup
vim.cmd("set noshowmode")

-- K = hover (standard behavior)
vim.keymap.set("n", "K", vim.lsp.buf.hover)

-- Show diagnostics under cursor (floating)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics" })

-- Navigate diagnostics (handy)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.lsp.buf.clear_references()
  end,
})

vim.diagnostic.config({
  virtual_text = false, -- no inline red text
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
