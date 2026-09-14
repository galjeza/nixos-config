{ ... }:
{
  programs.lazygit = {
    enable = true;

    settings = {
      git = {
        # Diff renderers are cycled with `|` inside lazygit. The list order is
        # the cycle order, so entry one is what you get by default.
        #
        # difftastic (type extDiff) takes over diff *generation* via git's
        # --ext-diff, rather than restyling git's output: it parses both sides
        # with tree-sitter and compares syntax trees. Reindents, block wraps and
        # renames — the shape of edit agents produce most — collapse to the few
        # lines that actually changed instead of a whole moved block.
        #
        # Scoping it here rather than to git's global diff.external is
        # deliberate: difftastic's output is not a valid patch (`git apply`
        # rejects it) and git applies diff.external even when stdout is not a
        # TTY. Setting it globally would hand unparseable diffs to every agent
        # that shells out to `git diff`. In lazygit it only ever renders for a
        # human.
        diffRenderers = [
          {
            type = "extDiff";
            # {{diffContext}} forwards lazygit's context size, so the `{` / `}`
            # keys still widen/narrow the diff while difftastic is active.
            command = "difft --color=always --context={{diffContext}}";
          }
          {
            # Escape hatch: plain git output, for when difftastic falls back to
            # a line diff anyway (lockfiles, logs, languages it has no parser
            # for) or when a real unified diff is what you actually want to read.
            type = "rawGit";
            name = "default";
          }
        ];
      };
    };
  };
}
