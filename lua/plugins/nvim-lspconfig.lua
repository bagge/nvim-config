return {
  "neovim/nvim-lspconfig",
--  config = function()
--    local lspconfig = require("lspconfig")
--    local mason_lspconfig = require("mason-lspconfig")
--    local server_names = require("config").lsp_servers
--
--    mason_lspconfig.setup({
--      ensure_installed = server_names,
--      handlers = {
--        function(server_name)
--          if server_name == "lua_ls" then
--            lspconfig["sumneko_lua"].setup(opts)
--          else
--            lspconfig[server_name].setup(opts)
--          end
--        end,
--      },
--    })
--  end,
  config = function()
    local lspconfig = require("lspconfig")
    lspconfig.gopls.setup({})
  end,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "LspInfo", "LspInstall", "LspUninstall" },
}
