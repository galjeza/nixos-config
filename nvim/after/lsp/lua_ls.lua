-- lua_ls: Lua language server, tuned for editing this Neovim config.
-- Docs: https://luals.github.io/wiki/settings/
return {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			-- Recognize Neovim's `vim` global and this config's own globals.
			diagnostics = {
				globals = {
					"vim",
					"Config",
					"MiniPick",
					"MiniFiles",
					"MiniDiff",
					"MiniBufremove",
					"MiniNotify",
					"MiniMisc",
					"MiniKeymap",
					"MiniCompletion",
					"MiniIcons",
				},
			},
			-- Make the server aware of Neovim runtime files for completion.
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			-- Don't nag to send telemetry.
			telemetry = { enable = false },
		},
	},
}
