-- Angular Language Server para Neovim 0.12+ (usa vim.lsp.config, NO lspconfig)
-- ngserver instalado via bun: ~/.bun/bin/ngserver

local bun_global = vim.fn.expand("~/.bun/install/global/node_modules")

-- Rutas de probe: TypeScript y Angular Language Service
-- 1. node_modules del proyecto (calculado dinámicamente en on_attach via root_dir)
-- 2. bun global como fallback
local ts_probe_global = bun_global
local ng_probe_global = bun_global .. "/@angular/language-server/node_modules"

vim.lsp.config("angularls", {
  cmd = function(dispatchers, config)
    local root_dir = (config and config.root_dir) or vim.fn.getcwd()

    -- Preferir node_modules del proyecto para TypeScript local
    local project_node = root_dir .. "/node_modules"
    local ts_probe, ng_probe

    if vim.uv.fs_stat(project_node) then
      ts_probe = project_node .. "," .. ts_probe_global
      ng_probe = project_node .. "/@angular/language-server/node_modules," .. ng_probe_global
    else
      ts_probe = ts_probe_global
      ng_probe = ng_probe_global
    end

    -- Leer versión de @angular/core del package.json del proyecto
    local angular_version = ""
    local pkg = root_dir .. "/package.json"
    if vim.uv.fs_stat(pkg) then
      local ok, content = pcall(vim.fn.readblob, pkg)
      if ok and content then
        local json = vim.json.decode(content) or {}
        local deps = vim.tbl_extend("force", json.dependencies or {}, json.devDependencies or {})
        local v = deps["@angular/core"] or ""
        angular_version = v:match("%d+%.%d+%.%d+") or ""
      end
    end

    local cmd = {
      "ngserver",
      "--stdio",
      "--tsProbeLocations",
      ts_probe,
      "--ngProbeLocations",
      ng_probe,
      "--angularCoreVersion",
      angular_version,
    }

    return vim.lsp.rpc.start(cmd, dispatchers)
  end,

  filetypes = { "typescript", "htmlangular" },

  root_markers = { "angular.json" },

  -- Inlay hints para TypeScript en Angular
  settings = {
    angular = {
      inlayHints = {
        parameterNames = true,
        parameterTypes = true,
        returnTypes = true,
      },
    },
  },
})

vim.lsp.enable("angularls")

-- Plugin spec vacío: la config ya se aplicó arriba con vim.lsp.config
return {}
