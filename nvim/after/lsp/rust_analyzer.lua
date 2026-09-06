-- rust_analyzer: Rust language server.
-- Docs: https://rust-analyzer.github.io/book/configuration.html
--
-- The binary and the toolchain it drives (`cargo`, `rustc`, `clippy`,
-- `rustfmt`) come from nix — see 'modules/home/rust.nix'. The nixpkgs wrapper
-- already sets RUST_SRC_PATH, so std sources resolve without configuring
-- `rust-analyzer.cargo.sysrootSrc` here.
return {
	settings = {
		["rust-analyzer"] = {
			-- Run clippy instead of plain `cargo check` for on-save diagnostics.
			-- `allTargets` includes tests/benches/examples, so lints fire in test
			-- code too rather than only in the main build.
			check = {
				command = "clippy",
				allTargets = true,
			},
			-- Import style that matches what `rustfmt` would leave alone:
			-- one `use` per module, crate-relative paths.
			imports = {
				granularity = { group = "module" },
				prefix = "self",
			},
			-- Inlay hints are computed here but only drawn once enabled in the
			-- buffer; toggle them with `<Leader>lI` (see 'plugin/20_keymaps.lua').
			inlayHints = {
				bindingModeHints = { enable = false },
				closureReturnTypeHints = { enable = "with_block" },
				lifetimeElisionHints = { enable = "skip_trivial" },
				parameterHints = { enable = true },
				typeHints = { enable = true },
			},
			-- Don't index build output or direnv's cache as project sources.
			files = {
				excludeDirs = { ".direnv", ".git", "target" },
			},
		},
	},
}
