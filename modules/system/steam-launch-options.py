"""Give every installed Steam game a default launch option.

Steam has no global launch option, only a per-game one stored in
userdata/<id>/config/localconfig.vdf. Steam rewrites that file on exit, so
this runs from the steam wrapper *before* Steam starts, and bails out if
Steam is already up.

Only fills in games whose launch option is missing or empty; anything set by
hand in the Steam UI is left alone. Tools (Proton, the Steam Linux Runtimes,
the redistributables) are skipped.
"""

import os
import re
import sys
from pathlib import Path

import vdf

STEAM = Path.home() / ".local/share/Steam"
TOOL = re.compile(r"^(Proton|Steam Linux Runtime|Steamworks Common)")


def steam_running():
    try:
        pid = (Path.home() / ".steam/steam.pid").read_text().strip()
        return os.readlink(f"/proc/{pid}/exe").endswith("ubuntu12_32/steam")
    except (OSError, ValueError):
        return False


def installed_games():
    folders = vdf.load(open(STEAM / "steamapps/libraryfolders.vdf"))
    for folder in folders["libraryfolders"].values():
        if not isinstance(folder, dict):
            continue
        for acf in Path(folder["path"], "steamapps").glob("appmanifest_*.acf"):
            state = vdf.load(open(acf))["AppState"]
            if not TOOL.match(state.get("name", "")):
                yield state["appid"], state.get("name", "")


def child(node, key):
    """Case-insensitive lookup; Steam isn't consistent about key case."""
    for k in node:
        if k.lower() == key.lower():
            return node[k]
    node[key] = vdf.VDFDict()
    return node[key]


def escape(text):
    # Steam escapes only these; vdf._escape also does \\? and friends.
    for raw, esc in (("\\", "\\\\"), ('"', '\\"'), ("\n", "\\n"), ("\t", "\\t")):
        text = text.replace(raw, esc)
    return text


def dump(node, depth=0):
    """vdf.dumps, but in Steam's own layout (two tabs between key and value),
    so the file round-trips byte for byte and a diff shows only real edits."""
    tab = "\t" * depth
    out = []
    for key, value in node.items():
        key = escape(key)
        if isinstance(value, dict):
            out.append(f'{tab}"{key}"\n{tab}{{\n{dump(value, depth + 1)}{tab}}}\n')
        else:
            out.append(f'{tab}"{key}"\t\t"{escape(value)}"\n')
    return "".join(out)


def main(launch_options):
    if steam_running():
        return
    games = list(installed_games())
    for cfg in STEAM.glob("userdata/*/config/localconfig.vdf"):
        root = vdf.load(open(cfg), mapper=vdf.VDFDict)
        apps = root["UserLocalConfigStore"]
        for key in ("Software", "Valve", "Steam", "apps"):
            apps = child(apps, key)
        changed = []
        for appid, name in games:
            app = child(apps, appid)
            if not app.get("LaunchOptions"):
                # VDFDict appends on assignment, so drop an empty "" first.
                app.remove_all_for("LaunchOptions")
                app["LaunchOptions"] = launch_options
                changed.append(name)
        if changed:
            tmp = cfg.with_suffix(".vdf.tmp")
            tmp.write_text(dump(root))
            tmp.replace(cfg)
            print(f"{cfg}: set launch options for {', '.join(changed)}")


if __name__ == "__main__":
    main(sys.argv[1])
