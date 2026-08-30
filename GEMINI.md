# Neovim Configuration Context & Guidelines

This repository contains personal Neovim configuration built on top of **NvChad (v2.5)** with **`lazy.nvim`** as the plugin manager.

---

## 📁 Repository Structure & Architecture

```text
~/.config/nvim/
├── init.lua                   # Main entry point: bootstrap lazy, load options, plugins, mappings, treesitter
├── lua/
│   ├── chadrc.lua             # NvChad UI & base46 configuration (theme, transparency, overrides)
│   ├── options.lua            # Custom vim options (layered over nvchad.options)
│   ├── mappings.lua           # Custom key mappings (layered over nvchad.mappings)
│   ├── plugins/
│   │   └── init.lua           # Lazy plugin specs (mason, dap, lsp, treesitter, etc.)
│   ├── configs/
│   │   ├── lazy.lua           # lazy.nvim performance & UI settings
│   │   ├── lspconfig.lua      # LSP server configurations & setup via vim.lsp.config / vim.lsp.enable
│   │   ├── conform.lua        # Formatter definitions per filetype (conform.nvim)
│   │   └── jb_theme.lua       # Auto-theme switcher (switches to jb.nvim on Java files)
│   └── custom/
│       └── configs/
│           └── null-ls.lua    # Extra Go formatters & buffer options
├── lazy-lock.json             # Pinned plugin versions
└── GEMINI.md                  # Agent context and workspace guide
```

---

## ⚙️ Core Configuration & Defaults

- **Leader Key**: `<Space>` (`vim.g.mapleader = " "`)
- **UI & Themes**:
  - Base theme: `monekai` with transparency enabled in `lua/chadrc.lua`.
  - Dynamic switching: `lua/configs/jb_theme.lua` automatically applies `jb.nvim` (JetBrains theme) when editing Java files, preserving NvChad statusline and UI components, then reverts back to Base46 for other filetypes.
- **Editor Options** (`init.lua` / `lua/options.lua`):
  - `relativenumber = true`
  - `scrolloff = 10`, `sidescrolloff = 10`, `sidescroll = 1`
  - `wrap = false` (line wrapping permanently disabled)

---

## 🛠️ Language Stacks & Tooling

| Language | LSP Server | Formatters / Linters | Debugger / Tooling |
| :--- | :--- | :--- | :--- |
| **Go** | `gopls` | `goimports`, `gofumpt`, `null-ls` (goimports_reviser, golines) | `nvim-dap-go`, `gopher.nvim` |
| **Java** | `jdtls` (via `nvim-java`) | `google-java-format` | `nvim-java` (Lombok & Spring Boot support) |
| **TypeScript / JS** | `ts_ls` (+ `@vue/typescript-plugin`) | `prettier` | Mason-managed |
| **Vue** | `vue-ls` (Volar Hybrid Mode) | `prettier` | `@vue/language-server` |
| **Python** | `pyright` | `isort`, `black` | Mason-managed |
| **Lua** | `lua_ls` | `stylua` | Neovim runtime & NvChad types |
| **HTML / CSS** | `html`, `cssls` | `prettier` | Mason-managed |

---

## ⌨️ Custom Keybindings (`lua/mappings.lua`)

- **General**:
  - `;` $\rightarrow$ `:` (Enter command mode directly)
  - `jk` $\rightarrow$ `<Esc>` (Fast escape from insert mode)
  - `<C-a>` $\rightarrow$ `vim.lsp.buf.code_action` (LSP Code Actions)
- **Navigation (tmux)**:
  - `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` $\rightarrow$ Seamless navigation across Neovim and Tmux panes
- **Debugging (DAP)**:
  - `<leader>db` $\rightarrow$ Toggle breakpoint
  - `<leader>dus` $\rightarrow$ Open debugging scopes sidebar
  - `<leader>dgt` $\rightarrow$ Debug Go test (via `dap-go`)
  - `<leader>dgl` $\rightarrow$ Debug last Go test (via `dap-go`)
- **Go Helper (`gopher.nvim`)**:
  - `<leader>gsj` $\rightarrow$ Add JSON struct tags
  - `<leader>gsy` $\rightarrow$ Add YAML struct tags
- **Git**:
  - `<leader>gg` / `<leader>lg` $\rightarrow$ Open LazyGit
  - `<leader>cg` $\rightarrow$ Gitsigns preview hunk

---

## 📋 Guidelines for Future Agent Edits

1. **Adding Plugins**:
   - Register plugin specs in `lua/plugins/init.lua`.
   - Separate complex configurations into `lua/configs/<plugin_name>.lua` and load via `opts = require "configs.<plugin_name>"` or `config = function() ... end`.
2. **Adding or Updating LSP Servers**:
   - Update `ensure_installed` in `lua/plugins/init.lua` under `williamboman/mason.nvim`.
   - Add/extend server configuration in `lua/configs/lspconfig.lua` using `vim.lsp.config(...)` extending `base` (`on_attach`, `on_init`, `capabilities`).
   - Add the server name to `vim.lsp.enable { ... }` in `lua/configs/lspconfig.lua`.
3. **Formatters**:
   - Register new formatters in `lua/configs/conform.lua` under `formatters_by_ft`.
4. **Preserve NvChad Synergy**:
   - Do not remove `require "nvchad.*"` imports or break Base46 cache integration (`vim.g.base46_cache`).
   - Ensure theme switches and UI hooks remain compatible with NvChad's statusline and tabline.
