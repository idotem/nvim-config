-- Load NvChad LSP UI (diagnostics, base46 highlights, etc.)
dofile(vim.g.base46_cache .. "lsp")
require("nvchad.lsp").diagnostic_config()

local nvlsp = require "nvchad.configs.lspconfig"

-- Shared base config applied to every server
local base = {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

-- Servers with default (base-only) config
local default_servers = { "html", "cssls", "jdtls" }

for _, name in ipairs(default_servers) do
  vim.lsp.config(name, base)
end

-- TypeScript / JavaScript / Vue Setup
local mason_path = vim.fn.stdpath "data" .. "/mason/packages"
local vue_plugin_path = mason_path .. "/vue-language-server/node_modules/@vue/language-server"

vim.lsp.config(
  "ts_ls",
  vim.tbl_deep_extend("force", base, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vue_plugin_path,
          languages = { "javascript", "typescript", "vue" },
        },
      },
    },
    filetypes = { "javascript", "typescript", "vue" },
  })
)

-- Vue Language Server (Volar)
vim.lsp.config(
  "vue-ls",
  vim.tbl_deep_extend("force", base, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    init_options = {
      vue = {
        hybridMode = true, -- Enables blazing fast Hybrid Mode (powered by ts_ls upstream)
      },
    },
  })
)

-- lua_ls  (was set up by nvchad.configs.lspconfig.defaults())
vim.lsp.config(
  "lua_ls",
  vim.tbl_deep_extend("force", base, {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            vim.fn.expand "$VIMRUNTIME/lua",
            vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
            vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
            vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
            "${3rd}/luv/library",
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  })
)

-- Go
vim.lsp.config(
  "gopls",
  vim.tbl_deep_extend("force", base, {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
      },
    },
  })
)

-- Python
vim.lsp.config(
  "pyright",
  vim.tbl_deep_extend("force", base, {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  })
)

-- Enable all configured servers
vim.lsp.enable {
  "html",
  "cssls",
  "ts_ls",
  "volar",
  "jdtls",
  "lua_ls",
  "gopls",
  "pyright",
}
