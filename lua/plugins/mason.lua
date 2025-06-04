return {
  "mason-org/mason.nvim",
  opts = {},
  event = { "BufReadPre", "BufNewFile" },
  cmd = {
    "Mason",
    "MasonInstall",
    "MasonUninstall",
    "MasonUninstallAll",
    "MasonLog",
    "MasonUpdate",
  },
}
