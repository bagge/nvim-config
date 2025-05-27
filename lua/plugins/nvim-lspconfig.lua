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
    require("mason").setup()
    -- Don't use mason-lspconfig to ensure specific servers are installed
    -- see https://vi.stackexchange.com/questions/46856/neovim-duplicate-lsp-clients-attached-to-the-buffer
    --  require("mason-lspconfig").setup({
    --    ensure_installed = {
    --      "gopls",
    --      "lua_ls",
    --      "ansiblels",
    --      "bzl",
    --      "bashls",
    --      "efm"
    --    }
    --  })

    local lspconfig = require("lspconfig")
    lspconfig.gopls.setup({})
    lspconfig.lua_ls.setup({
      settings = {
          Lua = {
              diagnostics = {
                  globals = { "vim" }
              }
          }
      }
    })
    lspconfig.ansiblels.setup({})
    lspconfig.bzl.setup({})
    lspconfig.bashls.setup({})
    -- TODO: Set up keybindings for vim.lsp.buf.format() and vim.diagnostic.setqflist()
    lspconfig.efm.setup({
      init_options = { documentFormatting = true },
      filetypes = { "go", "lua", "sh", "zsh", "bash" },
      settings = {
        rootMarkers = { ".git/" },
        languages = {
          go = {
            { formatCommand = "gofmt -s", formatStdin = true },
            { formatCommand = "goimports", formatStdin = true },
            { formatCommand = "gofumpt", formatStdin = true },
          },
          lua = {
            { formatCommand = "stylua --config-path -", formatStdin = true },
          },
          sh = {
            { formatCommand = "shfmt -i 2 -ci -bn -sr", formatStdin = true },
            {
              lintCommand = 'shellcheck -f gcc -x',
              lintSource = 'shellcheck',
              lintFormats= {'%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m' }
            }
          },
        },
      },
    })
    -- Set up diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "LspInfo", "LspInstall", "LspUninstall" },
}
