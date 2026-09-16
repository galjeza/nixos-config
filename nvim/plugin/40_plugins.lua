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
		"toml",
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
		"taplo",
		"tailwindcss",
		"copilot",
	})

	-- GitHub Copilot is wired up as a plain language server (the `copilot` entry
	-- above) plus Neovim's built-in inline completion — no third-party plugin.
	-- The server binary is installed by nix; see 'modules/home/default.nix', and
	-- 'after/lsp/copilot.lua' for its settings.
	--
	-- First run needs an interactive sign-in: in any buffer execute
	-- `:LspCopilotSignIn` and follow the device-flow prompt (the one-time code is
	-- put on the clipboard). The token is cached under
	-- '~/.config/github-copilot/', so this is once per machine.
	-- `:LspCopilotSignOut` revokes it. Both commands are created by
	-- 'nvim-lspconfig' when the server attaches to a buffer.
	--
	-- Suggestions show up as ghost text while in Insert mode:
	-- - `<Tab>`      - accept. Takes priority over the 'mini.completion' menu,
	--                  which is then navigated with `<C-n>` / `<C-p>`. A step of
	--                  the multistep mapping in 'plugin/30_mini.lua'.
	-- - `<Leader>lc` - toggle the ghost text for the current buffer
	--                  (mapped in 'plugin/20_keymaps.lua').
	--
	-- See also `:h lsp-inline-completion`.
	local enable_inline_completion = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local method = vim.lsp.protocol.Methods.textDocument_inlineCompletion
		if client ~= nil and client:supports_method(method, ev.buf) then
			vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
		end
	end
	Config.new_autocmd("LspAttach", "*", enable_inline_completion, "Enable LSP inline completion")

	-- Buffer-local on/off switch behind `<Leader>lc`, for when the ghost text is
	-- in the way (or when writing something that should stay Copilot-free).
	Config.toggle_inline_completion = function()
		local is_enabled = vim.lsp.inline_completion.is_enabled({ bufnr = 0 })
		vim.lsp.inline_completion.enable(not is_enabled, { bufnr = 0 })
	end
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
			toml = { "taplo" },
			typescript = { "biome", "prettierd", stop_after_first = true },
			typescriptreact = { "biome", "prettierd", stop_after_first = true },
			yaml = { "prettierd" },
		},
	})
end)

-- Diffview: single-tabpage UI for reviewing git diffs, merge conflicts and
-- file history. Depends on 'plenary.nvim', added alongside it below. File icons
-- come from 'mini.icons' (see 'plugin/30_mini.lua', which mocks
-- 'nvim-web-devicons').
--
-- HOW TO USE (all commands work from anywhere inside a git repo):
-- - `:DiffviewOpen` / `<Leader>gd` ......... review current changes vs index.
--   Left window = staged/index version, right window = working tree. Edit
--   either side and `:w` to stage that hunk (:DiffviewRefresh updates the view).
-- - `:DiffviewOpen <rev>` ................... diff one revision, e.g.
--   `:DiffviewOpen HEAD~2`, `:DiffviewOpen origin/main...HEAD`,
--   `:DiffviewOpen d4a7b0d^!` (single commit), `:DiffviewOpen HEAD~4..HEAD~2`.
-- - `:DiffviewClose` / `<Leader>gD` ......... close the view (`:tabclose` too).
-- - `:DiffviewFileHistory %` / `<Leader>gh` . history of the current file.
-- - `:DiffviewFileHistory` / `<Leader>gH` ... history of the whole branch.
--   Visual-select lines then run it to trace those lines' evolution (`-L`).
-- - Merging: opening a view during a merge/rebase lists conflicted files in a
--   3-way diff. Pick a side with `<Leader>co` (ours) / `<Leader>ct` (theirs) /
--   `<Leader>cb` (base) / `<Leader>ca` (all), or `dx` to delete the region.
--   Capital variants (`<Leader>cO`, ...) apply to the whole file.
--
-- NAVIGATING INSIDE A DIFFVIEW (defaults, press `g?` for the full list):
-- - `<Tab>` / `<S-Tab>` - next / previous changed file.
-- - `[F` / `]F` ......... first / last file.
-- - `gf` ................ open the real file (leaves the view).
-- - `[c` / `]c` ......... jump between hunks (built-in diff-mode, `:h diff-mode`).
-- - `do` / `dp` ......... obtain (`:h copy-diffs`) a hunk from the other /
--   put it there. `2do` / `3do` pick ours/theirs in a 3-way merge view.
-- - In the file panel: `-` or `s` stage/unstage entry, `S`/`U` stage/unstage
--   all, `X` restore file to the left side's state, `R` refresh, `L` commit log.
--
-- TIPS:
-- - `:DiffviewOpen -uno` ............ hide untracked files.
-- - `:DiffviewOpen -- :!some/path` .. exclude a path.
-- - `:DiffviewToggleFiles` ........... toggle the file panel.
-- - `:DiffviewFocusFiles` ............ jump focus to the file panel.
-- - Full docs: `:h diffview.nvim` (after install) or USAGE.md upstream.
later(function()
	add({
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/sindrets/diffview.nvim",
	})
	require("diffview").setup({
		-- Dim the filler chars on deleted lines. Most colorschemes paint them a
		-- bright red — big blocks of colour carrying no information that pull your
		-- eye away from the actual change. Links DiffviewDiffDelete -> Comment.
		enhanced_diff_hl = true,
	})

	-- ...but that option is inert on its own in this version. diffview's
	-- `hi_link()` routes through `hi()`, which merges the *existing* highlight
	-- spec with the new one (hl.lua:266-268). `default` is absent from the new
	-- opts, so `default = true` survives from the definition `hl.setup()` already
	-- made — and nvim treats a default highlight as "apply only if not already
	-- set". The re-link silently does nothing. Verified: raw nvim_set_hl applies,
	-- diffview's hi_link does not. So do the link here, and again on ColorScheme
	-- since loading a theme resets the groups.
	local hl_group = vim.api.nvim_create_augroup("diffview_dim_delete", { clear = true })
	local function dim_diff_delete()
		vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { link = "DiffviewDiffDeleteDim" })
	end
	dim_diff_delete()
	vim.api.nvim_create_autocmd("ColorScheme", { group = hl_group, callback = dim_diff_delete })

	-- Auto-refresh on changes made outside this nvim instance.
	--
	-- diffview only updates itself on two triggers: a `:w` from this instance
	-- (its BufWritePost handler), and a change to `.git/index` (the
	-- `watch_index` fs_poll, on by default). A coding agent writing files on
	-- disk, a rebase from a lazygit pane, or a checkout in another zellij pane
	-- hits neither, so the view silently goes stale and needs `R` /
	-- `:DiffviewRefresh`. Upstream: sindrets/diffview.nvim#567.
	--
	-- `refresh_files` is exactly what :DiffviewRefresh emits.
	local group = vim.api.nvim_create_augroup("diffview_auto_refresh", { clear = true })
	local timer

	-- `checktime` reloads buffers whose file changed on disk ('autoread' is on).
	-- Guarded: it throws inside the cmdline window.
	local function check_disk()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd("silent! checktime")
		end
	end

	local function refresh_panel()
		local ok, lib = pcall(require, "diffview.lib")
		-- get_current_view() is tabpage-scoped, so this is nil unless the tab
		-- you're on right now *is* a diffview. Never resurrects a background view.
		if ok and lib.get_current_view() then
			require("diffview").emit("refresh_files")
		end
	end

	-- Only rebuild the file panel when a file genuinely changed on disk, rather
	-- than on a blind interval: `checktime` fires FileChangedShellPost when it
	-- actually reloads something.
	vim.api.nvim_create_autocmd("FileChangedShellPost", {
		group = group,
		callback = refresh_panel,
	})

	-- Coming back to nvim is a natural point to resync, and cheap enough to do
	-- unconditionally — an agent may also have added files that are in no buffer
	-- yet, which checktime alone would miss.
	vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "TermClose" }, {
		group = group,
		callback = function()
			check_disk()
			refresh_panel()
		end,
	})

	-- FocusGained needs the terminal to report focus and the multiplexer to
	-- forward it, which is not guaranteed. Poll as a fallback, but only while a
	-- view is actually open, and only `checktime` — the panel rebuild still goes
	-- through FileChangedShellPost above.
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "DiffviewViewOpened",
		callback = function()
			if timer then
				timer:stop()
			else
				timer = vim.uv.new_timer()
			end
			timer:start(2000, 2000, vim.schedule_wrap(check_disk))
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "DiffviewViewClosed",
		callback = function()
			if timer then
				timer:stop()
				timer:close()
				timer = nil
			end
		end,
	})
end)

-- Cargo.toml helper. Shows the latest/available version of each dependency
-- inline as virtual text, and exposes upgrade/features/docs actions. Registers
-- itself as an in-process LSP server (`lsp.enabled`), so completion and hover
-- flow through 'mini.completion' like any other server instead of needing a
-- separate completion source. Loaded on the first TOML buffer.
-- Buffer-local mappings inside a 'Cargo.toml' (see 'plugin/20_keymaps.lua'
-- for the global `<Leader>l` group these extend):
-- - `<Leader>lu` - upgrade the crate under the cursor
-- - `<Leader>lU` - upgrade every crate in the file
-- - `<Leader>lF` - popup to toggle the crate's features
-- - `<Leader>lD` - open the crate's docs.rs page
local crates_loaded = false
local setup_crates = function(ev)
	if not crates_loaded then
		add({ "https://github.com/saecki/crates.nvim" })
		require("crates").setup({
			lsp = { enabled = true, actions = true, completion = true, hover = true },
			completion = { crates = { enabled = true } },
		})
		crates_loaded = true
	end
	if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":t") ~= "Cargo.toml" then
		return
	end
	local bmap = function(lhs, rhs, desc)
		vim.keymap.set("n", "<Leader>" .. lhs, rhs, { buffer = ev.buf, desc = desc })
	end
	bmap("lu", '<Cmd>lua require("crates").upgrade_crate()<CR>', "Upgrade crate")
	bmap("lU", '<Cmd>lua require("crates").upgrade_all_crates()<CR>', "Upgrade all crates")
	bmap("lF", '<Cmd>lua require("crates").show_features_popup()<CR>', "Features popup")
	bmap("lD", '<Cmd>lua require("crates").open_documentation()<CR>', "Docs.rs page")
end
Config.new_autocmd("FileType", "toml", setup_crates, "Set up 'crates.nvim'")

-- Colorschemes ======
Config.now(function()
	add({
		"https://github.com/vague-theme/vague.nvim",
		"https://github.com/bluz71/vim-moonfly-colors",
		"https://github.com/rebelot/kanagawa.nvim",
		"https://github.com/olivercederborg/poimandres.nvim",
	})

	-- Default on startup; try others live with `:colorscheme <name>`.
	-- Kanagawa ships: `kanagawa-wave`, `kanagawa-dragon`, `kanagawa-lotus` (light).
	vim.cmd("colorscheme moonfly")
end)
