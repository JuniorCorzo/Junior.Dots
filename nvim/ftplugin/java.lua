local jdtls = require("jdtls")
local root_markers = { "settings.gradle", "settings.gradle.kts", "gradlew", "mvnw", "pom.xml", ".git" }
local root_dir = require("jdtls.setup").find_root(root_markers)

if root_dir == "" then
  return
end

-- Hash the root dir to get a stable, unique workspace directory
local project_name = vim.fs.basename(root_dir)
local workspace_dir = vim.fn.expand("~/.cache/nvim/jdtls/workspace/") .. project_name .. "-" .. vim.fn.sha256(root_dir):sub(1, 12)

local bundles = {}

-- Add java-debug-adapter bundles
local java_debug_path = vim.fn.glob(vim.fn.expand("~/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"), true)
if java_debug_path ~= "" then
  table.insert(bundles, java_debug_path)
end

-- Add java-test bundles
local java_test_jars = vim.fn.glob(vim.fn.expand("~/.local/share/nvim/mason/packages/java-test/extension/server/*.jar"), true)
for jar in java_test_jars:gmatch("[^\r\n]+") do
  table.insert(bundles, jar)
end

-- Add Spring Boot bundles
local ok_spring, spring_boot = pcall(require, "spring_boot")
if ok_spring then
  -- Extended JDTLS bundles with Spring Boot jars
  local spring_bundles = spring_boot.java_extensions()
  vim.list_extend(bundles, spring_bundles)
end

local lombok_jar = vim.fn.expand("~/.local/share/nvim/mason/share/jdtls/lombok.jar")

local cmd = {
  vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls"),
  "-data",
  workspace_dir,
  "--jvm-arg=-javaagent:" .. lombok_jar,
}

local config = {
  cmd = cmd,
  root_dir = root_dir,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },
  init_options = {
    bundles = bundles,
  },
  filetypes = { "java" },
  single_file_support = false,
}

-- Attach DAP and test runners when JDTLS initializes
config.on_attach = function(client, bufnr)
  -- Initialize spring boot client commands
  if ok_spring then
    spring_boot.init_lsp_commands(client, bufnr)
  end

  -- DAP setup
  jdtls.setup_dap({ hotcodereplace = "auto" })

  -- Keymaps
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "<leader>co", jdtls.organize_imports, "Organize Imports")
  map("n", "<leader>cxv", jdtls.extract_variable, "Extract Variable")
  map("v", "<leader>cxv", function() jdtls.extract_variable(true) end, "Extract Variable")
  map("n", "<leader>cxc", jdtls.extract_constant, "Extract Constant")
  map("v", "<leader>cxc", function() jdtls.extract_constant(true) end, "Extract Constant")
  map("v", "<leader>cxm", function() jdtls.extract_method(true) end, "Extract Method")
  
  -- Test debugging and run
  map("n", "<leader>tc", jdtls.test_class, "Test Class")
  map("n", "<leader>tm", jdtls.test_nearest_method, "Test Nearest Method")

  -- Spring Boot symbol searches (using Snacks picker)
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks then
    map("n", "<leader>csb", function()
      snacks.picker.lsp_workspace_symbols({ search = "@" })
    end, "Search Spring Beans/Endpoints")
  end
end

jdtls.start_or_attach(config)
