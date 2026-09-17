{ pkgs, ... }:
{
  # `gh` itself plus its extensions. Extensions have to live under
  # ~/.local/share/gh/extensions/gh-<name>/gh-<name> — `gh` does not find them on
  # PATH — so a plain `home.packages` entry is not enough; this module links a
  # read-only farm over that directory instead of `gh extension install`ing into
  # it imperatively. Anything already installed there by hand must be removed
  # once (`rm -rf ~/.local/share/gh/extensions`) or activation refuses to clobber
  # it.
  programs.gh = {
    enable = true;
    extensions = [
      pkgs.gh-stack # `gh stack` — stacked pull requests (github/gh-stack)
    ];

    # ~/.config/gh/config.yml becomes a read-only symlink, so anything that used
    # to live in it has to be declared here. (hosts.yml stays unmanaged — that's
    # where `gh auth login` keeps its token.)
    settings.aliases.co = "pr checkout";

    # The module would otherwise write per-host `credential.<url>.helper` entries
    # on top of the global `!gh auth git-credential` that 'git.nix' already sets.
    # One helper is enough; git.nix stays the single place git config is defined.
    gitCredentialHelper.enable = false;
  };
}
