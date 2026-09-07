return {
  -- Explicit JDTLS configuration
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "folke/snacks.nvim",
      "mfussenegger/nvim-dap",
    },
    ft = { "java" },
  },
  -- Spring Boot plugin
  {
    "JavaHello/spring-boot.nvim",
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    ft = { "java" },
    opts = {},
  },
  -- Ensure mason installs the java servers
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-debug-adapter",
        "java-test",
        "vscode-spring-boot-tools",
      })
    end,
  },
}
