-- Tinymist: official Typst language server.
-- Docs: https://myriad-dreamin.github.io/tinymist/configurations.html
return {
	settings = {
		-- Use the bundled `typstyle` formatter on `:lua vim.lsp.buf.format()`
		-- (conform's `lsp_format = "fallback"` will pick this up on save).
		formatterMode = "typstyle",
		-- Compile on type for live diagnostics (preview plugin handles its own loop).
		exportPdf = "never",
	},
}
