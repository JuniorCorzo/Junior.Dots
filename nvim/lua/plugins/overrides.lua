-- This file contains the configuration overrides for specific Neovim plugins.

-- Patch treesitter query to remove invalid "tab" node type that crashes noice.nvim
local function patch_treesitter_query()
  local query_paths = vim.api.nvim_get_runtime_file("queries/vim/highlights.scm", true)
  for _, path in ipairs(query_paths) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      if content:find('"tab"') then
        local patched = content:gsub('\r?\n%s*"tab"%s*\r?\n', '\n')
        local fw = io.open(path, "w")
        if fw then
          fw:write(patched)
          fw:close()
        end
        vim.treesitter.query.set("vim", "highlights", patched)
      end
    end
  end
end

patch_treesitter_query()

return {
  -- Change configuration for trouble.nvim
  {
    -- Plugin: trouble.nvim
    -- URL: https://github.com/folke/trouble.nvim
    -- Description: A pretty list for showing diagnostics, references, telescope results, quickfix and location lists.
    "folke/trouble.nvim",
    -- Options to be merged with the parent specification
    opts = { use_diagnostic_signs = true }, -- Use diagnostic signs for trouble.nvim
  },

  -- Add symbols-outline.nvim plugin
  {
    -- Plugin: symbols-outline.nvim
    -- URL: https://github.com/simrat39/symbols-outline.nvim
    -- Description: A tree like view for symbols in Neovim using the Language Server Protocol.
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline", -- Command to open the symbols outline
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } }, -- Keybinding to open the symbols outline
    config = true, -- Use default configuration
  },

  -- Remove inlay hints from default configuration
  {
    -- Plugin: nvim-lspconfig
    -- URL: https://github.com/neovim/nvim-lspconfig
    -- Description: Quickstart configurations for the Neovim LSP client.
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Load early so angularls attaches to the first buffer
    opts = {
      inlay_hints = { enabled = false }, -- Disable inlay hints
      servers = {
        jdtls = {
          enabled = false,
        },
        nil_ls = {
          -- Configuration for nil (Nix Language Server), already installed via nix
          cmd = { "nil" },
          autostart = true,
          mason = false, -- Explicitly disable mason management for nil_ls
          settings = {
            ["nil"] = {
              formatting = { command = { "nixpkgs-fmt" } },
            },
          },
        },
      },
    },
  },
}
