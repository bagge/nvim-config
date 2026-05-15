local highlight_group = vim.api.nvim_create_augroup("config_highlights", { clear = true })

local function apply_highlights()
  vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "darkgreen", ctermbg = "darkgreen" })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#222222" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = highlight_group,
  pattern = "*",
  callback = apply_highlights,
})

apply_highlights()
vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
