local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later
Config.now(function()
	-- Define hook to update tree-sitter parsers after plugin is updated
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	})

	-- `nvim-treesitter` ships queries under `runtime/queries`. With `vim.pack`
	-- this subdirectory is not always added automatically, so ensure it is on
	-- runtimepath; otherwise parser starts but highlights can be missing.
	local ts_plugin_files = vim.api.nvim_get_runtime_file("plugin/nvim-treesitter.lua", false)
	for _, plugin_file in ipairs(ts_plugin_files) do
		local runtime_dir = vim.fn.fnamemodify(plugin_file, ":h:h") .. "/runtime"
		if vim.fn.isdirectory(runtime_dir) == 1 and not vim.tbl_contains(vim.opt.rtp:get(), runtime_dir) then
			vim.opt.rtp:append(runtime_dir)
		end
	end

	-- Define languages which will have parsers installed and auto enabled
	-- After changing this, restart Neovim once to install necessary parsers. Wait
	-- for the installation to finish before opening a file for added language(s).
	local languages = {
		"lua",
		"vimdoc",
		"markdown",
		"javascript",
		"typescript",
		"tsx",
		"prisma",
		"rust",
		"typst",
		-- Add here more languages with which you want to use tree-sitter
		-- To see available languages:
		-- - Execute `:=require('nvim-treesitter').get_available()`
		-- - Visit 'SUPPORTED_LANGUAGES.md' file at
		--   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language.
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

now_if_args(function()
	add({ "https://github.com/neovim/nvim-lspconfig" })
	-- Use `:h vim.lsp.enable()` to automatically enable language server based on
	-- the rules provided by 'nvim-lspconfig'.
	-- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
	vim.lsp.enable({
		"lua_ls",
		"nixd",
		"vtsls",
		"prismals",
		"rust_analyzer",
		"tinymist",
		"tailwindcss",
	})
end)

-- Formatting =================================================================
later(function()
	add({ "https://github.com/stevearc/conform.nvim" })
	require("conform").setup({
		default_format_opts = {
			-- Allow formatting from LSP server if no dedicated formatter is available
			lsp_format = "fallback",
		},
		format_on_save = {
			timeout_ms = 5000,
			lsp_format = "fallback",
		},
		formatters = {
			-- Only reach for biome in projects that actually have a biome config;
			-- everywhere else conform falls through to prettierd.
			biome = { require_cwd = true },
		},
		formatters_by_ft = {
			css = { "biome", "prettierd", stop_after_first = true },
			html = { "prettierd" },
			javascript = { "biome", "prettierd", stop_after_first = true },
			javascriptreact = { "biome", "prettierd", stop_after_first = true },
			json = { "biome", "prettierd", stop_after_first = true },
			jsonc = { "biome", "prettierd", stop_after_first = true },
			less = { "prettierd" },
			lua = { "stylua" },
			markdown = { "prettierd" },
			nix = { "nixfmt" },
			rust = { "rustfmt" },
			scss = { "prettierd" },
			typescript = { "biome", "prettierd", stop_after_first = true },
			typescriptreact = { "biome", "prettierd", stop_after_first = true },
			yaml = { "prettierd" },
		},
	})
end)

later(function()
	add({
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/kdheepak/lazygit.nvim",
	})
end)

later(function()
	add({
		"https://github.com/pwntester/octo.nvim",
	})
	require("octo").setup({
		picker = "default",
		enable_builtin = true,
	})
end)

-- Typst live preview. Opens a browser tab with the rendered PDF that updates
-- as you type. Uses the system `tinymist` binary (provided by nix) for both
-- compilation and the websocket server, so no extra binaries are downloaded.
-- Example usage in a `.typ` buffer:
-- - `:TypstPreview`       - start the preview and open it in the browser
-- - `:TypstPreviewToggle` - start/stop
-- - `:TypstPreviewStop`   - stop the server
later(function()
	add({ "https://github.com/chomosuke/typst-preview.nvim" })
	require("typst-preview").setup({
		dependencies_bin = {
			["typst-preview"] = "tinymist",
		},
		invert_colors = "auto",
	})
end)

-- Colorschemes ======
Config.now(function()
	add({
		"https://github.com/vague-theme/vague.nvim",
		"https://github.com/bluz71/vim-moonfly-colors",
		"https://github.com/maxmx03/solarized.nvim",
		"https://github.com/rebelot/kanagawa.nvim",
	})

	-- Default on startup; try others live with `:colorscheme <name>`.
	-- Kanagawa ships: `kanagawa-wave`, `kanagawa-dragon`, `kanagawa-lotus` (light).
	vim.cmd("colorscheme moonfly")
end)
