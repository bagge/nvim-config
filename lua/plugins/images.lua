local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local mermaid_puppeteer_config = vim.fs.joinpath(config_root, "resources", "mermaid-puppeteer.json")
local notes_vault = vim.fn.fnamemodify(vim.fn.expand("~/notes"), ":p"):gsub("/+$", "")
local notes_attachment_dir = vim.fs.joinpath(notes_vault, "attachments", "images")
local note_graphics_enabled = true

local function file_exists(path)
  return path ~= nil and (vim.uv or vim.loop).fs_stat(path) ~= nil
end

local function percent_decode(path)
  return path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

local function normalize_markdown_path(path)
  return percent_decode(path:gsub("^<(.+)>$", "%1"))
end

local function is_relative_path(path)
  return not path:match("^/") and not path:match("^~")
end

local function is_base64_image(path)
  return path:sub(1, 10) == "data:image"
end

local function resolve_base64_image(image_path)
  local tmp_path = vim.fn.tempname()
  local base64_part = image_path:gsub("^data:image/[%w%+]+;base64,", "")
  local ok, decoded = pcall(vim.base64.decode, base64_part)
  if not ok then
    return image_path
  end

  local file = io.open(tmp_path, "wb")
  if file ~= nil then
    file:write(decoded)
    file:close()
  end

  return tmp_path
end

local function is_in_notes_vault(document_file_path)
  if document_file_path == nil or document_file_path == "" then
    return false
  end

  local document_path = vim.fn.fnamemodify(document_file_path, ":p")
  return document_path == notes_vault
    or document_path:sub(1, #notes_vault + 1) == notes_vault .. "/"
end

local function resolve_obsidian_image_path(document_file_path, image_path, default_resolver)
  local normalized_path = normalize_markdown_path(image_path)
  if is_base64_image(normalized_path) then
    return resolve_base64_image(normalized_path)
  end

  local default_path = default_resolver(document_file_path, normalized_path)
  if
    file_exists(default_path)
    or not is_relative_path(normalized_path)
    or not is_in_notes_vault(document_file_path)
  then
    return default_path
  end

  local vault_path = vim.fs.joinpath(notes_vault, normalized_path)
  if file_exists(vault_path) then
    return vault_path
  end

  if not normalized_path:find("/", 1, true) then
    local attachment_path = vim.fs.joinpath(notes_attachment_dir, normalized_path)
    if file_exists(attachment_path) then
      return attachment_path
    end
  end

  return default_path
end

local function diagram_renderer_options()
  return {
    mermaid = {
      background = "transparent",
      cli_args = { "--puppeteerConfigFile", mermaid_puppeteer_config },
      theme = "dark",
    },
    plantuml = {
      charset = "utf-8",
      cli_args = { "-Djava.awt.headless=true" },
    },
  }
end

local function is_markdown_buffer(bufnr)
  return vim.bo[bufnr].filetype == "markdown"
end

local function clear_current_diagrams()
  local ok, diagram = pcall(require, "diagram")
  if ok then
    diagram.clear()
  end
end

local function render_current_diagrams()
  if not note_graphics_enabled or not is_markdown_buffer(vim.api.nvim_get_current_buf()) then
    return
  end

  local ok, diagram = pcall(require, "diagram")
  if ok then
    diagram.render()
  end
end

local function refresh_current_markdown_images()
  local ok, group = pcall(vim.api.nvim_create_augroup, "image.nvim:markdown", { clear = false })
  if not ok then
    return
  end

  pcall(vim.api.nvim_exec_autocmds, "BufWinEnter", {
    group = group,
    buffer = vim.api.nvim_get_current_buf(),
    modeline = false,
  })
end

local function enable_note_graphics()
  note_graphics_enabled = true
  require("image").enable()
  refresh_current_markdown_images()
  render_current_diagrams()
  vim.notify("Note graphics enabled", vim.log.levels.INFO)
end

local function disable_note_graphics()
  note_graphics_enabled = false
  clear_current_diagrams()
  require("image").disable()
  vim.notify("Note graphics disabled", vim.log.levels.INFO)
end

local function toggle_note_graphics()
  if note_graphics_enabled then
    disable_note_graphics()
  else
    enable_note_graphics()
  end
end

local function diagram_block_range(bufnr, diagram)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local start_row = diagram.range.start_row
  local end_row = diagram.range.end_row

  for row = start_row, 0, -1 do
    local line = lines[row + 1]
    if line and line:match("^%s*```") then
      start_row = row
      break
    end
  end

  for row = end_row, #lines - 1 do
    local line = lines[row + 1]
    if line and line:match("^%s*```%s*$") then
      end_row = row
      break
    end
  end

  return start_row, end_row
end

local function get_diagram_at_cursor(bufnr, integration)
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1

  for _, diagram in ipairs(integration.query_buffer_diagrams(bufnr)) do
    local start_row, end_row = diagram_block_range(bufnr, diagram)
    if cursor_row >= start_row and cursor_row <= end_row then
      return diagram
    end
  end

  return nil
end

local function get_diagram_renderer(integration, renderer_id)
  for _, renderer in ipairs(integration.renderers) do
    if renderer.id == renderer_id then
      return renderer
    end
  end

  return nil
end

local function open_diagram_preview(file_path, renderer_id)
  if not file_exists(file_path) then
    vim.notify("Diagram file not found: " .. file_path, vim.log.levels.ERROR)
    return
  end

  local image_api = require("image")
  local restore_image_disabled = not image_api.is_enabled()
  if restore_image_disabled then
    image_api.enable()
  end

  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_buf_set_name, buf, renderer_id .. " diagram")

  local image = image_api.hijack_buffer(file_path, win, buf, {
    max_width_window_percentage = 100,
    max_height_window_percentage = 100,
  })
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  if not image then
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "Image display failed.",
      "File: " .. file_path,
    })
    vim.bo[buf].modifiable = false
  end

  local cleaned = false
  local function cleanup()
    if cleaned then
      return
    end

    cleaned = true
    if image then
      pcall(function()
        image:clear()
      end)
    end
    if restore_image_disabled then
      pcall(function()
        image_api.disable()
      end)
    end
  end

  local function close_preview()
    cleanup()
    pcall(vim.cmd, "tabclose")
  end

  vim.keymap.set("n", "q", close_preview, { buffer = buf, desc = "Close diagram preview" })
  vim.keymap.set("n", "<Esc>", close_preview, { buffer = buf, desc = "Close diagram preview" })
  vim.keymap.set("n", "o", function()
    vim.ui.open(file_path)
  end, { buffer = buf, desc = "Open diagram image" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = cleanup,
  })
end

local function wait_for_renderer_job(job_id, callback)
  local timer = (vim.uv or vim.loop).new_timer()
  if not timer then
    return
  end

  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      local result = vim.fn.jobwait({ job_id }, 0)
      if result[1] == -1 then
        return
      end

      if timer:is_active() then
        timer:stop()
      end
      if not timer:is_closing() then
        timer:close()
      end

      callback()
    end)
  )
end

local function preview_diagram_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  if not is_markdown_buffer(bufnr) then
    vim.notify("Diagram preview is only configured for Markdown buffers", vim.log.levels.INFO)
    return
  end

  local integration = require("diagram.integrations.markdown")
  local diagram = get_diagram_at_cursor(bufnr, integration)
  if not diagram then
    vim.notify("No diagram found at cursor", vim.log.levels.INFO)
    return
  end

  local renderer = get_diagram_renderer(integration, diagram.renderer_id)
  if not renderer then
    vim.notify("No renderer found for " .. diagram.renderer_id, vim.log.levels.ERROR)
    return
  end

  vim.notify("Loading " .. diagram.renderer_id .. " diagram...", vim.log.levels.INFO)
  local renderer_result =
    renderer.render(diagram.source, diagram_renderer_options()[renderer.id] or {})
  if not renderer_result or not renderer_result.file_path then
    vim.notify("Failed to render " .. diagram.renderer_id .. " diagram", vim.log.levels.ERROR)
    return
  end

  local function open_preview()
    open_diagram_preview(renderer_result.file_path, diagram.renderer_id)
  end

  if renderer_result.job_id then
    wait_for_renderer_job(renderer_result.job_id, open_preview)
  else
    open_preview()
  end
end

local function setup_diagram_autocmds()
  local group = vim.api.nvim_create_augroup("config_note_graphics_diagrams", { clear = true })

  vim.api.nvim_create_autocmd({ "FileType", "InsertLeave", "BufWinEnter", "TextChanged" }, {
    group = group,
    callback = function(args)
      if not note_graphics_enabled or not is_markdown_buffer(args.buf) then
        return
      end

      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == args.buf then
          render_current_diagrams()
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    callback = function(args)
      if is_markdown_buffer(args.buf) and vim.api.nvim_get_current_buf() == args.buf then
        clear_current_diagrams()
      end
    end,
  })
end

return {
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    build = false,
    keys = {
      {
        "<leader>ng",
        toggle_note_graphics,
        mode = "n",
        ft = { "markdown" },
        desc = "Toggle note graphics",
      },
    },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = false,
          only_render_image_at_cursor = false,
          only_render_image_at_cursor_mode = "inline",
          floating_windows = false,
          filetypes = { "markdown" },
          resolve_image_path = resolve_obsidian_image_path,
        },
        html = {
          enabled = false,
        },
        css = {
          enabled = false,
        },
      },
      max_height_window_percentage = 50,
      hijack_file_patterns = {
        "*.png",
        "*.jpg",
        "*.jpeg",
        "*.gif",
        "*.webp",
        "*.avif",
      },
    },
  },
  {
    "3rd/diagram.nvim",
    ft = { "markdown" },
    dependencies = {
      "3rd/image.nvim",
    },
    keys = {
      {
        "<leader>np",
        preview_diagram_at_cursor,
        mode = "n",
        ft = { "markdown" },
        desc = "Preview diagram",
      },
    },
    opts = function()
      return {
        integrations = {
          require("diagram.integrations.markdown"),
        },
        events = {
          render_buffer = {},
          clear_buffer = { "BufLeave" },
        },
        renderer_options = diagram_renderer_options(),
      }
    end,
    config = function(_, opts)
      require("diagram").setup(opts)
      setup_diagram_autocmds()
      vim.schedule(render_current_diagrams)
    end,
  },
}
