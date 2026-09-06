-- taplo: TOML language server (`Cargo.toml`, `rustfmt.toml`, `.taplo.toml`).
-- Docs: https://taplo.tamasfe.dev/configuration/language-server.html
--
-- Binary comes from nix — see 'modules/home/rust.nix'. Schema validation for
-- well-known files (Cargo.toml included) is fetched from schemastore.org, so
-- it degrades to plain syntax/format support when offline.
return {
	settings = {
		evenBetterToml = {
			schema = {
				enabled = true,
				catalogs = { "https://www.schemastore.org/api/json/catalog.json" },
			},
			formatter = {
				alignEntries = false,
				reorderKeys = false,
			},
		},
	},
}
