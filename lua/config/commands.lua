vim.api.nvim_create_user_command("B", function()
  require("fzf-lua").buffers()
end, { desc = "Fzf buffers" })

vim.api.nvim_create_user_command("F", function()
  require("fzf-lua").files()
end, { desc = "Fzf files" })
