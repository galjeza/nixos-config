{ pkgs, ... }:
{
  # Rust toolchain + tooling.
  #
  # This is the plain nixpkgs toolchain rather than rustup: it tracks whatever
  # `nixos-unstable` ships and moves with the flake, so there is no second
  # version manager to keep in sync. `~/.cargo/bin` is already on PATH (see
  # `envExtra` in 'zsh.nix'), so `cargo install`ed binaries still work. If a
  # project ever needs a pinned or nightly toolchain, use a per-project
  # `nix develop` shell (e.g. via `rust-overlay`) instead of layering rustup
  # on top of this.
  #
  # `rust-analyzer` here is the nixpkgs *wrapper*, which exports RUST_SRC_PATH
  # pointing at `rustPlatform.rustLibSrc` — so "go to definition" into `Vec` or
  # `Option` resolves to real std sources with no extra env wiring. It is
  # enabled as the `rust_analyzer` LSP in 'nvim/plugin/40_plugins.lua' and
  # configured in 'nvim/after/lsp/rust_analyzer.lua'.
  home.packages = with pkgs; [
    rustc
    cargo
    clippy # `cargo clippy` — also what rust-analyzer runs on save
    rustfmt # `cargo fmt` — also conform's `rust` formatter
    rust-analyzer

    # Cargo helpers
    cargo-edit # `cargo add` / `cargo rm` / `cargo upgrade`
    cargo-nextest # `cargo nextest run` — faster test runner, better output
    cargo-watch # `cargo watch -x test` — rerun on file change
    bacon # background `cargo check`/clippy TUI

    # `Cargo.toml` language server + formatter (enabled in nvim as `taplo`)
    taplo

    # Most `*-sys` crates shell out to pkg-config to find system libs.
    # The linker (`gcc`) and `openssl` come from 'default.nix'.
    pkg-config
  ];
}
