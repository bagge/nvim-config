NVIM ?= nvim
STYLUA ?= stylua
CHECK_HEALTH ?= lazy vim.lsp vim.treesitter

.PHONY: check check-lua check-startup check-health check-lualine-hydra check-note-tasks check-format

check: check-lua check-startup check-health check-lualine-hydra check-note-tasks check-format

check-lua:
	$(NVIM) --headless -u NONE -i NONE -c "luafile scripts/check_lua_syntax.lua" -c qa

check-startup:
	$(NVIM) --headless -i NONE -c "lua print('config loaded')" -c qa

check-health:
	$(NVIM) --headless -i NONE -c "checkhealth $(CHECK_HEALTH)" -c qa

check-lualine-hydra:
	$(NVIM) --headless -i NONE -c "luafile scripts/check_lualine_hydra.lua" -c qa

check-note-tasks:
	$(NVIM) --headless -i NONE -c "luafile scripts/check_note_tasks.lua" -c qa

check-format:
	@if command -v "$(STYLUA)" >/dev/null 2>&1; then \
		"$(STYLUA)" --check .; \
	elif [ -x "$$HOME/.local/share/nvim/mason/bin/stylua" ]; then \
		"$$HOME/.local/share/nvim/mason/bin/stylua" --check .; \
	else \
		echo "stylua not found; skipping format check"; \
	fi
