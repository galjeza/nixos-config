# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rebuild Commands

These aliases are defined in `modules/home/zsh.nix` and available in the shell:

```sh
rebuild            # nixos-rebuild switch --flake ~/nixos-config#lenovo-yoga
rebuild-test       # nixos-rebuild test (doesn't make permanent)
rebuild-boot       # nixos-rebuild boot (applies on next boot)
rebuild-update     # nix flake update + rebuild switch
```

To rebuild for a different host target, run directly:
```sh
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-vm
sudo nixos-rebuild switch --flake ~/nixos-config#arch-nixos-vm
```

To format Nix files:
```sh
nixfmt-rfc-style <file>
```

To check a flake for errors without building:
```sh
nix flake check
```

## Architecture

This is a NixOS flake-based configuration managing three hosts (`lenovo-yoga`, `nixos-vm`, `arch-nixos-vm`) with a shared home-manager setup.

**`flake.nix`** — Entry point. Defines all `nixosConfigurations`, wires in `home-manager` and the `neovim-nightly-overlay`. All hosts share one `homeManagerModule` pointing to `modules/home/default.nix` for user `galjeza`.

**`modules/system/common.nix`** — Config that is genuinely shared by **all** hosts: nix settings + GC/store optimise, locale, timezone (`Europe/Ljubljana`), user account, networking, Docker, Sway + X11, PipeWire, nix-ld, polkit, XDG portals. Hardware- and machine-specific config lives in the host files, not here.

**`hosts/<name>/configuration.nix`** — Per-host config: bootloader, hostname, and anything hardware/machine-specific. `lenovo-yoga` additionally carries NVIDIA/PRIME graphics, gaming (Steam + gamemode), the Yoga speaker fixup, lid-switch behaviour, bluetooth, and battery conservation; the VM hosts carry the SPICE guest agent. Each imports `hardware-configuration.nix` and `../../modules/system/common.nix`.

**`modules/home/`** — Home-manager modules, all imported by `default.nix`:
- `default.nix` — User packages, mako notifications (vague palette), wallpaper symlink
- `foot.nix` — Foot terminal (no longer the default terminal — ghostty is); carries `vague`, `moonfly` and solarized palettes, switched via the `footTheme` selector (currently `solarized-light`)
- `ghostty.nix` — Ghostty terminal, the actual default (`terminal` in `sway.nix`); uses the built-in `Vague` theme
- `sway.nix` — Full Sway WM config (keybindings, colors, bar, outputs, gaps) — vague palette
- `neovim.nix` — Enables neovim-nightly; symlinks `nvim/` into `~/.config/nvim`
- `zsh.nix` — Shell config, aliases, zoxide, PATH setup, prompt (vague palette)
- `git.nix` — Git identity + diff/merge/rerere config
- `meld.nix` — Meld graphical diff/merge tool (dconf settings)
- `zellij.nix` — Zellij terminal multiplexer (vague theme; moonfly + solarized also defined)

**`nvim/`** — Neovim config (Lua). Uses `vim.pack` (built-in plugin manager, NixOS Neovim nightly). Loaded in order: `init.lua` → `plugin/10_options.lua` → `20_keymaps.lua` → `30_mini.lua` → `40_plugins.lua`. Powered by `mini.nvim`.

## Key Conventions

- **Theme**: `vague` ([vague-theme/vague.nvim](https://github.com/vague-theme/vague.nvim)) is the active theme across `ghostty`, `zellij`, `sway`, `nvim` and the `zsh` prompt. vague palette: bg `#141415`, surface `#252530`, fg `#cdcdcd`, muted `#606079`, blue `#6e94b2`, gold `#f3be7c`, love `#d8647e`. `moonfly` ([bluz71/vim-moonfly-colors](https://github.com/bluz71/vim-moonfly-colors)) stays defined everywhere as an alternative — bg `#080808`, surface `#323437`, fg `#bdbdbd`, muted `#949494`, blue `#80a0ff`, gold `#e3c78a`, red `#ff5d5d`. Stragglers: `foot` is on `solarized-light`, `mako` still uses the older Rose Pine hex — migrate when convenient.
- **`nixpkgs` channel**: `nixos-unstable` (rolling). `home-manager` follows the same nixpkgs to avoid duplicate copies.
- **`stateVersion`**: `"25.11"` — do not change without reading the NixOS docs on state version migration.
- **Neovim config** lives in `nvim/` (repo root) and is symlinked to `~/.config/nvim` via `xdg.configFile` in `neovim.nix`. Edit files here; changes take effect after `rebuild` or after re-sourcing home-manager.
