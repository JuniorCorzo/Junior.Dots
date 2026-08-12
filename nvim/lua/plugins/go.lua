local home = vim.fn.expand("~")
local nix_profile = home .. "/.nix-profile"
local hm_profile = home .. "/.local/state/nix/profiles/home-manager/home-path"

local pkg_config_path = nix_profile .. "/lib/pkgconfig:" .. hm_profile .. "/lib/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig"
local cflags = "-I" .. nix_profile .. "/include -I" .. hm_profile .. "/include"
local ldflags = "-L" .. nix_profile .. "/lib -L" .. hm_profile .. "/lib"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          cmd_env = {
            CGO_ENABLED = "1",
            PKG_CONFIG_PATH = pkg_config_path,
            CGO_CFLAGS = cflags,
            CGO_LDFLAGS = ldflags,
          },
          settings = {
            gopls = {
              env = {
                CGO_ENABLED = "1",
                PKG_CONFIG_PATH = pkg_config_path,
                CGO_CFLAGS = cflags,
                CGO_LDFLAGS = ldflags,
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
