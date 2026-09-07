return {
  -- LSP configuration for Oxlint and Oxfmt
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        oxlint = {},
        oxfmt = {},
      },
    },
  },

  -- Conform.nvim integration for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "oxfmt" },
        typescript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        json = { "oxfmt" },
        jsonc = { "oxfmt" },
      },
    },
  },
}
