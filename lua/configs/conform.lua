local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    python = { "isort", "black" },
    go = { "goimports", "gofumpt" },
    java = { "google-java-format" },
    vue = { "prettier" },
  },

  formatters = {
    prettier = {
      require_cwd = true,
    },
  },

  -- Default options for conform.format()
  default_format_opts = {
    lsp_format = "never",
  },
}

return options
