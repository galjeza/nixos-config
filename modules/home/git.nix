{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Gal Jeza";
      user.email = "gal.jeza55@gmail.com";

      # histogram: LCS-based algo, handles code better than default myers.
      # colorMoved: moved blocks get a distinct colour so you can tell "code moved"
      # from "code changed" at a glance. allow-indentation-change ignores
      # indent-only moves (e.g. a block shifted right after an if-wrap).
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      diff.colorMovedWS = "allow-indentation-change";

      # zdiff3 adds a BASE (ancestor) section to conflict markers so you can see
      # what both sides diverged from — essential for understanding *why* there's
      # a conflict, not just what the two sides say. Requires git >= 2.35.
      # keepBackup = false: don't leave .orig files everywhere after resolving.
      merge.conflictStyle = "zdiff3";
      merge.tool = "meld";
      mergetool.prompt = false;
      mergetool.keepBackup = false;

      # rerere = Reuse Recorded Resolutions. Git memorises how you resolved a
      # conflict and re-applies it automatically if the same conflict appears again
      # (e.g. long-running feature branch repeatedly rebased onto main).
      # autoUpdate: stage the file automatically once rerere resolves it.
      rerere.enabled = true;
      rerere.autoUpdate = true;

      # autoSetupRemote: no need for --set-upstream on the first push of a branch.
      # branch.sort: most recently used branches listed first in `git branch`.
      # column.ui: columnar output for `git branch`, `git tag`, etc.
      push.autoSetupRemote = true;
      branch.sort = "-committerdate";
      column.ui = "auto";
    };
  };
}
