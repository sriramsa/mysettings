-- ============================================================================
--  init.lua  —  modern Neovim config (2026 rewrite of the 2015 .vimrc)
--  - sriramsh
--
--  This replaces the old Vundle/YouCompleteMe/syntastic/cscope setup with:
--    lazy.nvim   plugin manager      (was: Vundle)
--    native LSP  + mason             (was: YouCompleteMe / jedi / python-mode / tern)
--    treesitter  syntax/highlight    (was: vim-cpp-enhanced-highlight + lang syntaxes)
--    telescope   fuzzy find / grep   (was: ctrlp + cscope text search)
--    conform     formatting          (was: clang-format.py / vim-clang-format)
--    nvim-tree   file explorer       (was: NERDTree)
--    aerial      symbol outline      (was: tagbar)
--
--  Muscle memory preserved: leader=",", ,g / ,s / ,c for nav, F4/F8 toggles,
--  C-f / C-b for files, Space-w / Space-q, etc. See the keymap section.
--
--  First-run install: see nvim/README.md in this repo.
-- ============================================================================

-- Leader MUST be set before lazy.nvim loads (so plugin mappings pick it up)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- ----------------------------------------------------------------------------
--  Options  (the old `set xxx` block)
-- ----------------------------------------------------------------------------
local opt = vim.opt

opt.number = true                 -- line numbers (set number)
opt.relativenumber = false
opt.mouse = "a"                   -- mouse in all modes (set mouse=a)
opt.history = 1000
opt.autoread = true               -- reload files changed outside vim
opt.scrolloff = 3                 -- keep 3 lines around cursor (so=3)
opt.lazyredraw = false            -- (old set lazyredraw; harmful w/ modern plugins, off)
opt.errorbells = false
opt.visualbell = false
opt.timeoutlen = 500              -- (tm=500)
opt.encoding = "utf-8"

-- Indentation: 4-space, expand tabs, smart (expandtab/smarttab/sw=sts=ts=4)
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.autoindent = true
opt.smartindent = true
opt.wrap = true
opt.linebreak = true              -- (set lbr) wrap at word boundaries

-- Searching (ignorecase + smartcase + hlsearch + incsearch)
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Colors: 24-bit truecolor. NOTE: inside tmux you need truecolor passthrough,
-- otherwise colors look washed out. See nvim/README.md.
opt.termguicolors = true
opt.background = "dark"
-- opt.colorcolumn = "100"        -- old config debated 92/100/110; uncomment to taste

opt.laststatus = 3                -- global statusline (modern; was laststatus=2)
opt.signcolumn = "yes"            -- stable gutter for LSP/git signs
opt.updatetime = 250
opt.splitright = true
opt.splitbelow = true
opt.wildignore:append({ "*.o", "*.class", "*.git", "*.svn" })

-- Project-local config files (.nvim.lua), the modern safe replacement for
-- the old `set exrc` + `set secure`.
opt.exrc = true

-- ----------------------------------------------------------------------------
--  Bootstrap lazy.nvim (auto-clones itself on first launch)
-- ----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ----------------------------------------------------------------------------
--  Plugins
-- ----------------------------------------------------------------------------
require("lazy").setup({

  -- Colorscheme: monokai, to match your old molokai / putty-monokai taste
  {
    "tanvirtin/monokai.nvim",
    priority = 1000,
    config = function()
      require("monokai").setup({})
      vim.cmd.colorscheme("monokai")
    end,
  },

  -- Statusline (replaces vim-airline)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "auto", globalstatus = true } },
  },

  -- File explorer (replaces NERDTree) — toggle with F4
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = { width = 35 },
      filters = { custom = { "^.git$", "%.o$", "%.pyc$" } },
    },
  },

  -- Symbol outline (replaces tagbar) — toggle with F8
  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  },

  -- Fuzzy finder (replaces ctrlp + cscope text search + MRU)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local t = require("telescope")
      t.setup({ defaults = { layout_strategy = "flex" } })
      pcall(t.load_extension, "fzf")
    end,
  },

  -- Treesitter: syntax + highlight (replaces all the old per-language syntax plugins)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "go", "python", "javascript", "typescript",
          "lua", "vim", "vimdoc", "bash", "json", "yaml", "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP + Mason (replaces YCM, jedi-vim, python-mode, tern, syntastic, cscope)
  { "williamboman/mason.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig", "mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",        -- C / C++  (was: YCM + clang)
        "gopls",         -- Go       (was: vim-go)
        "pyright",       -- Python   (was: jedi / python-mode)
        "ruff",          -- Python lint/format (was: pep8 / pylint)
        "ts_ls",         -- JS / TS  (was: tern_for_vim)
        "lua_ls",        -- Lua (for editing this config)
      },
    },
  },

  -- Completion (replaces YCM completion + supertab + ultisnips)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(a) require("luasnip").lsp_expand(a.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- Formatting (replaces clang-format.py / vim-clang-format)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        go = { "goimports", "gofmt" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        lua = { "stylua" },
      },
      -- clang-format: Google base, C++ style, 92-col — matches your old settings
      formatters = {
        clang_format = {
          prepend_args = { "--style={BasedOnStyle: Google, ColumnLimit: 92}" },
        },
      },
      -- format on save; toggle with :FormatToggle (see commands below)
      format_on_save = function()
        if vim.g.disable_autoformat then return end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },

  -- Git: signs in gutter (replaces gitgutter) + fugitive (kept — still the best)
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gblame" } },

  -- tpope keepers (these aged perfectly)
  { "tpope/vim-surround" },         -- cs"' etc.
  { "tpope/vim-repeat" },
  { "numToStr/Comment.nvim", opts = {} },   -- gcc / gc (replaces vim-commentary)

  -- Motion (replaces EasyMotion) — trigger with ,w then a label
  {
    "folke/flash.nvim",
    opts = {},
    keys = {
      { ",w", function() require("flash").jump() end, desc = "Flash jump" },
    },
  },

  -- Autopairs (replaces auto-pairs)
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- tmux integration: C-h/j/k/l moves across vim splits AND tmux panes
  -- (this is the modern successor to your old vim-tmux-navigator + .tmux.conf glue)
  { "christoomey/vim-tmux-navigator", lazy = false },

  -- Discoverability: shows pending keybindings in a popup
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

}, {
  ui = { border = "rounded" },
  checker = { enabled = false },
})

-- ----------------------------------------------------------------------------
--  Keymaps  (old muscle memory, repointed at modern equivalents)
-- ----------------------------------------------------------------------------
local map = vim.keymap.set

-- Reload config (was <leader>V :source $MYVIMRC)
map("n", "<leader>V", "<cmd>source $MYVIMRC<CR>", { desc = "Reload config" })

-- Clear search highlight (was ,n :nohls)
map("n", "<leader>n", "<cmd>nohlsearch<CR>", { desc = "Clear search hl" })

-- Sudo-write (was the w!! cmap)
map("c", "w!!", "w !sudo tee > /dev/null %", {})

-- Space leader saves/quits (Space-w / Space-q from old config)
map("n", "<Space>w", "<cmd>w<CR>", { desc = "Write" })
map("n", "<Space>q", "<cmd>q<CR>", { desc = "Quit" })

-- Window movement: C-h/j/k/l is handled by vim-tmux-navigator (also crosses tmux).
-- Shift-Tab cycles windows (was :map <S-Tab> w)
map("n", "<S-Tab>", "<C-w>w", { desc = "Next window" })

-- Files & search (replaces ctrlp / MRU / cscope text)
local tb = function(fn) return function() require("telescope.builtin")[fn]() end end
map("n", "<C-f>",   tb("find_files"), { desc = "Find files" })       -- was CtrlP
map("n", "<C-b>",   tb("oldfiles"),   { desc = "Recent files" })      -- was CtrlPMRU
map("n", "<Space>b",tb("oldfiles"),   { desc = "Recent files" })
map("n", "<leader>t", tb("live_grep"),{ desc = "Grep project" })      -- was cscope 't' text
map("n", "<leader>fb", tb("buffers"), { desc = "Buffers" })

-- Explorer / outline toggles (were F4 NERDTree / F8 Tagbar)
map("n", "<F4>", "<cmd>NvimTreeToggle<CR>", { desc = "File tree" })
map("n", "<F8>", "<cmd>AerialToggle<CR>",   { desc = "Symbol outline" })

-- ----------------------------------------------------------------------------
--  LSP keymaps  (the old cscope/vim-go nav, now backed by real LSP)
-- ----------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local b = { buffer = ev.buf }
    local function m(lhs, rhs, desc) map("n", lhs, rhs, vim.tbl_extend("force", b, { desc = desc })) end

    -- core navigation (cscope ,g/,s/,c muscle memory)
    m("<leader>g", vim.lsp.buf.definition, "Go to definition")                -- was cscope 'g'
    m("<leader>s", require("telescope.builtin").lsp_references, "References") -- was cscope 's'
    m("<leader>c", require("telescope.builtin").lsp_incoming_calls, "Callers")-- was cscope 'c'
    m("<leader>i", require("telescope.builtin").lsp_implementations, "Implementations")
    m("gd", vim.lsp.buf.definition, "Definition")
    m("gD", vim.lsp.buf.declaration, "Declaration")
    m("K",  vim.lsp.buf.hover, "Hover docs")                                  -- was pymode K / go-doc

    -- refactor / actions
    m("<leader>rn",  vim.lsp.buf.rename, "Rename")                            -- was go-rename / pymode rename
    m("<leader>gre", vim.lsp.buf.rename, "Rename (go muscle memory)")
    m("<leader>ca",  vim.lsp.buf.code_action, "Code action")

    -- diagnostics (replaces syntastic / pymode lint).
    -- vim.diagnostic.jump is 0.11+; fall back to goto_prev/next on 0.10.
    local function diag(dir)
      return function()
        if vim.diagnostic.jump then
          vim.diagnostic.jump({ count = dir, float = true })
        elseif dir < 0 then
          vim.diagnostic.goto_prev()
        else
          vim.diagnostic.goto_next()
        end
      end
    end
    m("[d", diag(-1), "Prev diagnostic")
    m("]d", diag(1),  "Next diagnostic")
  end,
})

-- Manual format: <leader>f, plus <C-\> (your old clang-format binding)
map({ "n", "v" }, "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, { desc = "Format" })
map("n", "<C-\\>", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, { desc = "Format" })

-- Toggle format-on-save
vim.api.nvim_create_user_command("FormatToggle", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  print("format-on-save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
end, {})

-- ----------------------------------------------------------------------------
--  Filetype tweaks
-- ----------------------------------------------------------------------------
-- Go: tabs not spaces (gofmt standard), F5 to run (was vim-go :GoRun)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    map("n", "<F5>", "<cmd>!go run %<CR>", { buffer = true, desc = "go run" })
  end,
})

-- Markdown: treat .md as markdown (was an explicit autocmd)
vim.filetype.add({ extension = { md = "markdown" } })

-- ----------------------------------------------------------------------------
--  Typo abbreviations (a few favorites carried over from the old .vimrc)
-- ----------------------------------------------------------------------------
local typos = {
  acheive = "achieve", alos = "also", aslo = "also", becuase = "because",
  charcter = "character", exmaple = "example", seperate = "separate",
  shoudl = "should", taht = "that", teh = "the", bianry = "binary",
}
for wrong, right in pairs(typos) do
  vim.cmd(string.format("iabbrev %s %s", wrong, right))
  vim.cmd(string.format("iabbrev %s %s", wrong:gsub("^%l", string.upper), right:gsub("^%l", string.upper)))
end
