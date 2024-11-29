return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
      },
      ansiblels = {},
    },
    setup = {
      gopls = function(_, opts)
        -- workaround for gopls not supporting semanticTokensProvider
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        local on_attach = function(client, _)
          if not client.server_capabilities.semanticTokensProvider then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
              range = true,
            }
          end
        end
        local name = "gopls"
        -- end workaround
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and (not name or client.name == name) then
              return on_attach(client, buffer)
            end
          end,
        })
      end,
    },
  },
  config = function()
    -- TODO: mason has no ensure_installed so find a way to get goimports and
    --       gofumpt installed
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls",
        "lua_ls",
        "ansiblels",
        "bzl"
      }
    })

    local lspconfig = require("lspconfig")
    lspconfig.gopls.setup({})
    lspconfig.lua_ls.setup({})
    lspconfig.ansiblels.setup({})
    lspconfig.bzl.setup({})
  end,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "LspInfo", "LspInstall", "LspUninstall" },
}
