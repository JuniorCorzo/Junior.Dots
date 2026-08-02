return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              env = {
                CGO_ENABLED = "1",
              },
              analyses = {
                cgo = true,
                unusedparams = true,
                shadow = true,
              },
              staticcheck = true,
              gofumpt = true,
              usePlaceholders = true,
              completeUnimported = true,
            },
          },
        },
      },
    },
  },
}
