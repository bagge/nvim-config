return {
  "Mofiqul/dracula.nvim",
  config = function()
    local colors = require("dracula.palette")
    require("dracula").setup({
      overrides = {
        -- Change the bg of the statusline not have the same bg as buffer
        StatusLineNC = { fg = colors.comment, bg = colors.menu },
        WindowPickerStatusLine = { fg = colors.white, bg = colors.comment },
        WindowPickerStatusLineNC = { fg = colors.white, bg = colors.comment },
      },
    })
  end,
}
