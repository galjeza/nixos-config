{ ... }:
{
  programs.lazygit = {
    enable = true;

    settings = {
      os = {
        # `e` on a file opens it in the *parent* nvim as a tab, instead of
        # starting a nested nvim inside lazygit's floating terminal.
        #
        # lazygit.nvim only wires up remote editing when `nvr` is on PATH
        # (`g:lazygit_use_neovim_remote = executable('nvr') ? 1 : 0`), and it
        # isn't. This preset needs no extra package: it uses $NVIM, the socket
        # nvim exports inside any :terminal. When $NVIM is unset — lazygit
        # launched straight from ghostty or a zellij pane — it falls back to a
        # plain `nvim`, so both entry points behave sensibly. Invoked from the
        # staging panel it also jumps to the right line.
        editPreset = "nvim-remote";
      };

      # The version is pinned by the flake, so a self-update prompt is noise
      # you can't act on — `rebuild-update` is what actually moves it.
      update.method = "never";

      # No "press enter to return" step after every subprocess (editor, shell
      # command, interactive rebase). Trade-off: subprocess output scrolls away
      # instead of waiting for you — flip back to true if you miss seeing it.
      promptToReturnFromSubprocess = false;

      # No introductory popups on open.
      disableStartupPopups = true;

      gui = {
        # The command log eats a fixed slice of the bottom panel and mostly
        # repeats what you just did. Hidden; `@` (extrasMenu) still opens it
        # on demand when you actually want to see the git commands.
        showCommandLog = false;

        # Removes the "Donate" and "Ask Question" links from the bottom line,
        # keeping the keybinding hints and version. They are clickable
        # hyperlinks, so lazygit only renders them when the mouse is on:
        # informationStr() gates both behind `if gui.g.Mouse`, and gui.go sets
        # `g.Mouse = userConfig.Gui.MouseEvents`. There is no dedicated setting
        # for them. Cost: no click-to-focus, no border dragging, and no scroll
        # wheel in the diff panes.
        mouseEvents = false;

        border = "single";
        #get rid of icons
        nerdFontsVersion = "";

        # Fraction of the terminal width given to the whole left column
        # (default 0.3333). The side panels are lists of short strings — branch
        # names, file paths, commit subjects — while the main panel holds the
        # diff, which is where the long lines actually are. difftastic's
        # side-by-side output in particular wants the width: it never switches
        # away from two columns, so a narrow main panel is paid for in wrapped
        # lines (continuation rows marked with a leading `.`) instead.
        #
        # Upstream's own advice for narrow screens is 0.2. Long branch names
        # truncate at this width; `_` (or `+`) cycles the focused panel through
        # half- and full-screen when you need to read one in full.
        sidePanelWidth = 0.2;

        shrinkSidePanelsToContent = false;

        # Accordion: the focused side panel grows, the others shrink to their
        # title line. The weight below is lazygit's default and means "twice
        # the height of an unfocused panel"; raise it if you want focus to be
        # more emphatic.
        expandFocusedSidePanel = true;
        expandedSidePanelWeight = 2;

        # Side panels top-to-bottom; each inner list shares one panel as tabs.
        # This matches upstream's default set minus 'tags'. 'files', 'branches'
        # and 'commits' cannot be hidden — everything else is optional.
        #
        # 'status' shows the repo/branch line plus the dashboard (version,
        # config path, links). `gui.statusPanelView = "allBranchesLog"` swaps
        # that dashboard for a log of all branches, if the static text is not
        # earning its row.
        sidePanels = [
          [ "status" ]
          [
            "files"
            "worktrees"
            "submodules"
          ]
          [
            "branches"
            "remotes"
          ]
          [
            "commits"
            "reflog"
          ]
          [ "stash" ]
        ];
      };

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
