-- copilot: GitHub Copilot, spoken to as a plain language server.
-- Docs: https://www.npmjs.com/package/@github/copilot-language-server
--
-- The binary comes from nix (`copilot-language-server` in
-- 'modules/home/default.nix'); the `cmd`, the device-flow `:LspCopilotSignIn` /
-- `:LspCopilotSignOut` commands and the `init_options` handshake come from
-- 'nvim-lspconfig'. This file only layers settings on top — do not define
-- `on_attach` here, it would replace (not extend) the one that creates those
-- two commands.
--
-- Suggestions are rendered by Neovim's built-in inline completion; the wiring
-- and mappings are documented in 'plugin/40_plugins.lua'.
return {
	settings = {
		telemetry = {
			-- 'nvim-lspconfig' defaults this to "all"; opt out instead.
			telemetryLevel = "off",
		},
	},
}
