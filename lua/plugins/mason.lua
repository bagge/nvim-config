local function supports_mason_vale_ls()
  if vim.uv.os_uname().sysname ~= "Linux" then
    return true
  end

  local output = vim.fn.system({ "getconf", "GNU_LIBC_VERSION" })
  if vim.v.shell_error ~= 0 then
    return false
  end

  local major, minor = output:match("glibc%s+(%d+)%.(%d+)")
  major, minor = tonumber(major), tonumber(minor)
  return major ~= nil and minor ~= nil and (major > 2 or (major == 2 and minor >= 39))
end

local ensure_installed = {
  "lua-language-server",
  "gopls",
  "pyright",
  "bash-language-server",
  "yaml-language-server",
  "ansible-language-server",
  "efm",
  "starpls",
  "marksman",
  "vale",
  "stylua",
  "shfmt",
  "shellcheck",
  "black",
  "isort",
  "prettier",
  "prettierd",
  "mmdc",
}

if supports_mason_vale_ls() then
  table.insert(ensure_installed, "vale-ls")
end

return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = {
      PATH = "prepend",
    },
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    opts = {
      ensure_installed = ensure_installed,
      auto_update = false,
      run_on_start = false,
    },
  },
}
