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
vim.opt.linebreak = false
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.updatetime = 200
vim.opt.splitright = true
vim.opt.splitbelow = true

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

  ---------------------------------------------------------
  -- THEME
  ---------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight")
    end,
  },

  ---------------------------------------------------------
  -- DASHBOARD
  ---------------------------------------------------------
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        " ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        " ████╗  ██║██║   ██║██║████╗ ████║",
        " ██╔██╗ ██║██║   ██║██║██╔████╔██║",
        " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "",
        " Write Code. Build Things. Do Epic Shit.",
      }

      dashboard.section.buttons.val = {
        dashboard.button("n", "  New file", ":ene <CR>"),
        dashboard.button("f", "󰈞  Find file", ":Telescope find_files<CR>"),
        dashboard.button("g", "󰊄  Live grep", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Config", ":e ~/.config/nvim/init.lua<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end,
  },

  ---------------------------------------------------------
  -- FILE EXPLORER
  ---------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)

        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            local node = api.tree.get_node_under_cursor()
            if node and node.type == "file" then
              api.node.open.preview()
            end
          end,
        })
      end

      require("nvim-tree").setup({
        on_attach = on_attach,
        view = {
          -- Put tree on the left so nvim-tree's `renderer.full_name` popup works
          -- (it only shows for left-side trees).
          side = "left",
          width = 42,
        },
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        renderer = {
          highlight_git = true,
          highlight_opened_files = "name",
          -- Show full filename in a floating popup when it doesn't fit the tree width.
          full_name = true,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = false,
            },
          },
        },
      })

      -- Toggle tree
      vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>")
    end,
  },

  ---------------------------------------------------------
  -- STATUS LINE
  ---------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
      })
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

          -- Web/config
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
        },
      })
    end,
  },

  ---------------------------------------------------------
  -- TELESCOPE
  ---------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ❯ ",
          path_display = { "smart" },
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
            follow = true,
          },
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
  -- AUTOCOMPLETE
  ---------------------------------------------------------
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
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
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

-- VS Code–style file search
vim.keymap.set("n", "<D-p>", function()
  require("telescope.builtin").find_files({
    hidden = true,
    no_ignore = true,
    follow = true,
    cwd = vim.loop.cwd(),
  })
end, { desc = "Find files (Cmd+P)" })

-- Search text in project (Cmd+Shift+F like VS Code)
vim.keymap.set("n", "<D-S-f>", function()
  require("telescope.builtin").live_grep()
end, { desc = "Search text (Cmd+Shift+F)" })

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

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg0 = vim.fn.argv(0)
    if arg0 ~= "" and vim.fn.isdirectory(arg0) == 1 then
      vim.schedule(function()
        local ok = pcall(require, "nvim-tree")
        if ok then
          pcall(vim.cmd, "NvimTreeOpen")
        end
      end)
    end
  end,
})

