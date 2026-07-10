"""Bump every plugin under johns-os by one semver PATCH and keep
marketplace.json + each plugin's CHANGELOG.md in sync.

Uses targeted regex on file text (NOT json.dumps) so that whitespace,
unicode escapes, and key order in the existing JSON are preserved.

Run from the repo root:
    python scripts/bump-johns-os-plugins.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path("johns-os")
TODAY = "2026-05-24"

if not ROOT.exists():
    sys.exit("johns-os/ not found — run from repo root")

VERSION_RE = re.compile(r'("version"\s*:\s*")([^"]+)(")')
NAME_RE = re.compile(r'"name"\s*:\s*"([^"]+)"')


def bump_patch(v: str) -> str:
    parts = v.split(".")
    parts[-1] = str(int(parts[-1]) + 1)
    return ".".join(parts)


SPECIFIC_NOTES = {
    "eng-core": (
        "Fixed: SessionStart `seed-workspace.sh` is now opt-in — it no longer "
        "auto-creates `.eng-os/` in unrelated project cwds. The hook only "
        "maintains the standard subdirectory layout when `.eng-os/` already exists."
    ),
    "venture-os": (
        "Fixed: SessionStart `bootstrap-venture-workspace.sh` is now opt-in — "
        "the `cwd-fallback` branch that auto-created `.venture-os/` in any "
        "project has been removed. Workspace creation now requires "
        "`$VENTURE_OS_WORKSPACE`, a registry hit from "
        "`/venture-os:setup-venture-os`, or a pre-existing `.venture-os/` directory."
    ),
}

GENERIC_NOTE = (
    "Coordinated release bump alongside the eng-core and venture-os "
    "SessionStart opt-in fix. No functional changes in this plugin."
)


def main() -> int:
    plugin_jsons = sorted(ROOT.glob("**/.claude-plugin/plugin.json"))
    bumps: dict[str, tuple[str, str, Path]] = {}

    # --- Pass 1: bump each plugin.json ---
    for pj in plugin_jsons:
        text = pj.read_text(encoding="utf-8")
        m_name = NAME_RE.search(text)
        m_ver = VERSION_RE.search(text)
        if not m_name or not m_ver:
            print(f"SKIP (no name/version): {pj}")
            continue
        name = m_name.group(1)
        old = m_ver.group(2)
        new = bump_patch(old)
        new_text = VERSION_RE.sub(
            lambda m: m.group(1) + new + m.group(3), text, count=1
        )
        pj.write_text(new_text, encoding="utf-8")
        bumps[name] = (old, new, pj)

    # --- Pass 2: update marketplace.json ---
    mp_path = ROOT / ".claude-plugin" / "marketplace.json"
    mp_text = mp_path.read_text(encoding="utf-8")
    for name, (old, new, _) in bumps.items():
        # Match: "name": "<name>", "version": "<old>"  (handles wide whitespace)
        pattern = re.compile(
            r'("name"\s*:\s*"' + re.escape(name) + r'"\s*,\s*"version"\s*:\s*")'
            r"[^\"]+(\")",
            re.DOTALL,
        )
        updated = pattern.sub(
            lambda m: m.group(1) + new + m.group(2), mp_text, count=1
        )
        if updated == mp_text:
            print(f"WARN: marketplace entry for '{name}' not updated")
        mp_text = updated
    mp_path.write_text(mp_text, encoding="utf-8")

    # --- Pass 3: update CHANGELOG.md ---
    for name, (old, new, pj) in bumps.items():
        plugin_dir = pj.parent.parent
        cl_path = plugin_dir / "CHANGELOG.md"
        note = SPECIFIC_NOTES.get(name, GENERIC_NOTE)
        section = "### Fixed" if name in SPECIFIC_NOTES else "### Changed"
        entry = f"## [{new}] - {TODAY}\n\n{section}\n\n- {note}\n\n"
        if cl_path.exists():
            existing = cl_path.read_text(encoding="utf-8")
            if existing.startswith("# "):
                head, _, rest = existing.partition("\n")
                cl_path.write_text(
                    f"{head}\n\n{entry}{rest.lstrip()}", encoding="utf-8"
                )
            else:
                cl_path.write_text(
                    f"# Changelog\n\n{entry}{existing}", encoding="utf-8"
                )
        else:
            cl_path.write_text(f"# Changelog\n\n{entry}", encoding="utf-8")

    # --- Report ---
    for name in sorted(bumps):
        old, new, _ = bumps[name]
        print(f"  {name:40s} {old} -> {new}")
    print(f"\nBumped {len(bumps)} plugins")
    return 0


if __name__ == "__main__":
    sys.exit(main())
