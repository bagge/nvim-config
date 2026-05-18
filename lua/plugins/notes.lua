local function note_slug(title)
  local slug = title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
  slug = slug:gsub("-+", "-"):gsub("^-", ""):gsub("-$", "")

  if slug == "" then
    return tostring(os.date("%Y%m%d%H%M"))
  end

  return slug
end

local heading_backgrounds = {
  "ConfigRenderMarkdownH1Bg",
  "ConfigRenderMarkdownH2Bg",
  "ConfigRenderMarkdownH3Bg",
  "ConfigRenderMarkdownH4Bg",
  "ConfigRenderMarkdownH5Bg",
  "ConfigRenderMarkdownH6Bg",
}

local heading_foregrounds = {
  "ConfigRenderMarkdownH1",
  "ConfigRenderMarkdownH2",
  "ConfigRenderMarkdownH3",
  "ConfigRenderMarkdownH4",
  "ConfigRenderMarkdownH5",
  "ConfigRenderMarkdownH6",
}

local function setup_render_markdown_highlights()
  local colors = require("dracula.palette")

  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH1", {
    fg = colors.fg,
    bold = true,
    underline = true,
  })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH2", {
    fg = colors.fg,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH3", { fg = colors.fg })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH4", { fg = colors.fg })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH5", { fg = colors.fg })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH6", { fg = colors.fg })

  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH1Bg", { bg = colors.menu })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH2Bg", { bg = colors.menu })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH3Bg", { bg = colors.menu })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH4Bg", { bg = colors.menu })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH5Bg", { bg = colors.menu })
  vim.api.nvim_set_hl(0, "ConfigRenderMarkdownH6Bg", { bg = colors.menu })

  for level, group in ipairs(heading_foregrounds) do
    vim.api.nvim_set_hl(0, "@markup.heading." .. level .. ".markdown", { link = group })
  end
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>no", "<cmd>Obsidian quick_switch<cr>", desc = "Open note" },
      { "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
      { "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>nt", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>nd", "<cmd>Obsidian today<cr>", desc = "Daily note" },
      { "<leader>nl", "<cmd>Obsidian links<cr>", desc = "Links in note" },
      { "<leader>nr", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
      { "<leader>nT", "<cmd>Obsidian template<cr>", desc = "Insert note template" },
      { "<leader>nf", "<cmd>Obsidian follow_link<cr>", desc = "Follow note link" },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = "~/notes",
        },
      },
      picker = {
        name = "fzf-lua",
      },
      completion = {
        nvim_cmp = false,
        blink = true,
      },
      ui = {
        enable = false,
      },
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%Y-%m-%d",
        template = "daily.md",
      },
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      attachments = {
        folder = "attachments/images",
      },
      note_id_func = function(title, _path)
        if title ~= nil then
          return note_slug(title)
        end

        return tostring(os.date("%Y%m%d%H%M"))
      end,
      frontmatter = {
        func = function(note)
          local out = {
            id = note.id,
            aliases = note.aliases,
            tags = note.tags,
            created = os.date("%Y-%m-%d"),
          }

          if note.title then
            out.title = note.title
          end

          return out
        end,
        sort = { "id", "title", "aliases", "tags", "created" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      file_types = { "markdown" },
      heading = {
        width = "block",
        backgrounds = heading_backgrounds,
        foregrounds = heading_foregrounds,
      },
      completions = {
        lsp = { enabled = true },
      },
    },
    config = function(_, opts)
      setup_render_markdown_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("config_render_markdown_highlights", { clear = true }),
        callback = setup_render_markdown_highlights,
      })
      require("render-markdown").setup(opts)
    end,
  },
}
