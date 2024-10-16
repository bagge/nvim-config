return {
  "nvim-treesitter/nvim-treesitter",
  lazy = true,
  build = ":TSUpdate",
  config = function()
		require("nvim-treesitter.configs").setup {
			highlight = {
				enable = true,
			},
			ensure_installed = {
				"vimdoc",
				"luadoc",
				"vim",
				"lua",
				"markdown"
			}
		}
	end,
}
