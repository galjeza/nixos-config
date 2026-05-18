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

**`modules/system/common.nix`** — System-level config shared by all hosts: locale, timezone (`Europe/Ljubljana`), user account, Docker, Sway, polkit, XDG portals, automatic GC/store optimisation.

**`hosts/<name>/configuration.nix`** — Per-host overrides (bootloader, hostname). Each imports `hardware-configuration.nix` and `../../modules/system/common.nix`.

**`modules/home/`** — Home-manager modules, all imported by `default.nix`:
- `default.nix` — User packages, foot terminal (Rose Pine colors), mako notifications, wallpaper symlink
- `sway.nix` — Full Sway WM config (keybindings, colors, bar, outputs)
- `neovim.nix` — Enables neovim-nightly; symlinks `nvim/` into `~/.config/nvim`
- `zsh.nix` — Shell config, aliases, zoxide, PATH setup
- `git.nix` — Git identity
- `zellij.nix` — Zellij terminal multiplexer with Rose Pine theme

**`nvim/`** — Neovim config (Lua). Uses `vim.pack` (built-in plugin manager, NixOS Neovim nightly). Loaded in order: `init.lua` → `plugin/10_options.lua` → `20_keymaps.lua` → `30_mini.lua` → `40_plugins.lua`. Powered by `mini.nvim`.

## Key Conventions

- **Theme**: Rose Pine throughout (foot, mako, sway, zellij, neovim). Hex palette: bg `#191724`, fg `#e0def4`, accent `#31748f`, love `#eb6f92`, gold `#f6c177`, iris `#c4a7e7`.
- **`nixpkgs` channel**: `nixos-unstable` (rolling). `home-manager` follows the same nixpkgs to avoid duplicate copies.
- **`stateVersion`**: `"25.11"` — do not change without reading the NixOS docs on state version migration.
- **Neovim config** lives in `nvim/` (repo root) and is symlinked to `~/.config/nvim` via `xdg.configFile` in `neovim.nix`. Edit files here; changes take effect after `rebuild` or after re-sourcing home-manager.
