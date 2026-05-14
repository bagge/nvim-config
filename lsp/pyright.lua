local function set_python_path(path)
  local clients = vim.lsp.get_clients {
    bufnr = vim.api.nvim_get_current_buf(),
    name = 'pyright',
  }
  for _, client in ipairs(clients) do
    client.config.settings = client.config.settings or {}
    client.config.settings.python = vim.tbl_deep_extend('force', client.config.settings.python or {}, { pythonPath = path })
    client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  end
end

return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
        reportIncompatibleMethodOverride = true,
        stubPath = "./typings"
      },
    },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function()
      client:exec_cmd({
        command = 'pyright.organizeimports',
        arguments = { vim.uri_from_bufnr(bufnr) },
      })
    end, {
      desc = 'Organize Imports',
    })
    vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', function(opts)
      set_python_path(opts.args)
    end, {
      desc = 'Reconfigure pyright with the provided python path',
      nargs = 1,
      complete = 'file',
    })
  end,
  on_init = function(client)
    local workspace_folders = client.workspace_folders
    if not workspace_folders or not workspace_folders[1] then
      return
    end

    local path = workspace_folders[1].name
    if vim.fn.filereadable(path .. "/.gitreview") == 1 and vim.fs.basename(path) == "zuul" then
      client.config.settings.python.analysis = {
        diagnosticSeverityOverrides = {
          reportIncompatibleMethodOverride = false,
        },
        stubPath = path .. "/" .. "../zuul-typings",
      }
      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      return true
    end
  end,
}
