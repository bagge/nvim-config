return {
  {
    "williamboman/mason.nvim",
    lazy = true,
    opts = {
      ensure_installed = {
        "goimports",
        "gofumpt"
      }
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    opts = {
      ensure_installed = {
        "gopls",
        "lua_ls"
      }
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  }
}

