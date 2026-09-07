-- Configure Node.js before loading plugins
require("config.nodejs").setup({ silent = true })

-- Angular: detect *.html files inside Angular projects as htmlangular
-- Must run BEFORE lazy loads so the first buffer gets the right filetype
vim.filetype.add({
  extension = {},
  pattern = {
    [".*%.html"] = {
      function(path, _bufnr)
        -- Walk up the directory tree looking for angular.json or project.json
        local dir = vim.fn.fnamemodify(path, ":h")
        local limit = 10
        while dir ~= "/" and limit > 0 do
          if
            vim.fn.filereadable(dir .. "/angular.json") == 1
            or vim.fn.filereadable(dir .. "/project.json") == 1
          then
            return "htmlangular"
          end
          dir = vim.fn.fnamemodify(dir, ":h")
          limit = limit - 1
        end
      end,
      priority = 10,
    },
  },
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0
