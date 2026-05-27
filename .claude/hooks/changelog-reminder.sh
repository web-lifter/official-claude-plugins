#!/usr/bin/env bash
# PostToolUse hook for Write|Edit.
#
# Two regimes:
#
# 1. Parent-repo plugins: when <category>/<plugin>/.claude-plugin/plugin.json
#    or .claude-plugin/marketplace.json is dirty, require the root CHANGELOG.md
#    to also be dirty.
#
# 2. anthril-os submodule plugins: when a plugin.json under anthril-os/<group>/
#    <plugin>/ (or anthril-os/<plugin>/ for top-level plugins like venture-os)
#    or anthril-os/.claude-plugin/marketplace.json is dirty inside the
#    submodule, require the per-plugin CHANGELOG.md (e.g.
#    anthril-os/engineering-os/eng-ai/CHANGELOG.md) to also be dirty.
#
# Rationale: Claude Code's plugin marketplace caches do not auto-refresh, so
# users discover new versions via CHANGELOG.md. Drift between manifests and
# the changelog produces silent "no update available" reports downstream.
#
# Implemented without jq so it runs on bare Git Bash on Windows.

set -euo pipefail

INPUT=$(cat)

# Extract .tool_input.file_path. Tolerant regex: matches the first file_path
# string field in the JSON.
FILE_PATH=$(printf '%s' "$INPUT" \
  | tr -d '\r' \
  | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -n 1 \
  | sed -E 's/.*"file_path"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')

if [ -z "${FILE_PATH:-}" ]; then
  exit 0
fi

# Normalise Windows backslashes so the suffix match works in Git Bash.
NORMALISED=$(printf '%s' "$FILE_PATH" | tr '\\' '/')

case "$NORMALISED" in
  */plugin.json|*/.claude-plugin/marketplace.json|*marketplace.json) ;;
  *) exit 0 ;;
esac

# Resolve the repo root from the edited file's directory. If the file does
# not exist yet (rare PostToolUse case) fall back to its parent dir.
TARGET_DIR=$(dirname "$NORMALISED")
if [ ! -d "$TARGET_DIR" ]; then
  TARGET_DIR=$(dirname "$TARGET_DIR")
fi

# `git rev-parse --show-toplevel` inside a submodule returns the submodule
# root, which is what we want for anthril-os edits.
REPO_ROOT=$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null) || exit 0

# Detect anthril-os submodule edits by checking if REPO_ROOT ends in
# /anthril-os (the submodule has its own .git, so rev-parse returns the
# submodule root for files inside it).
case "$REPO_ROOT" in
  */anthril-os)
    SUBMODULE_REGIME=1
    PARENT_ROOT=$(git -C "$(dirname "$REPO_ROOT")" rev-parse --show-toplevel 2>/dev/null || echo "")
    HOOK_REPO="$PARENT_ROOT"
    ;;
  *)
    SUBMODULE_REGIME=0
    HOOK_REPO="$REPO_ROOT"
    ;;
esac

# Only act when this hook script lives in *this* repo's .claude/. Prevents
# the hook from firing if a copy of it ends up under another repo via a
# user-level settings.json.
if [ -z "$HOOK_REPO" ] || [ ! -f "$HOOK_REPO/.claude/hooks/changelog-reminder.sh" ]; then
  exit 0
fi

cd "$REPO_ROOT"

if [ "$SUBMODULE_REGIME" = "1" ]; then
  # ---- anthril-os submodule regime ----
  # Dirty manifests inside the submodule.
  MANIFEST_DIRTY=$(git diff --name-only HEAD -- \
    ':(glob)engineering-os/**/plugin.json' \
    ':(glob)venture-os/**/plugin.json' \
    ':(glob)internal-utilities/**/plugin.json' \
    '.claude-plugin/marketplace.json' 2>/dev/null || true)
  if [ -z "$MANIFEST_DIRTY" ]; then
    exit 0
  fi

  # For every dirty plugin.json, derive the plugin dir (parent of
  # .claude-plugin/) and check whether <plugin-dir>/CHANGELOG.md is dirty too.
  MISSING_CHANGELOGS=""
  while IFS= read -r manifest; do
    [ -z "$manifest" ] && continue
    case "$manifest" in
      .claude-plugin/marketplace.json)
        # Submodule-level marketplace edit — we have no single plugin to
        # point at; treat as satisfied if ANY anthril-os CHANGELOG.md is
        # dirty. Defer this check until per-plugin loop below.
        continue
        ;;
    esac
    PLUGIN_DIR=$(dirname "$(dirname "$manifest")")
    CHANGELOG_PATH="$PLUGIN_DIR/CHANGELOG.md"
    if [ ! -f "$CHANGELOG_PATH" ]; then
      # No CHANGELOG exists yet — flag it so Claude creates one.
      MISSING_CHANGELOGS="$MISSING_CHANGELOGS $CHANGELOG_PATH(missing)"
      continue
    fi
    CL_DIRTY=$(git diff --name-only HEAD -- "$CHANGELOG_PATH" 2>/dev/null || true)
    if [ -z "$CL_DIRTY" ]; then
      MISSING_CHANGELOGS="$MISSING_CHANGELOGS $CHANGELOG_PATH"
    fi
  done <<EOF
$MANIFEST_DIRTY
EOF

  if [ -z "$MISSING_CHANGELOGS" ]; then
    exit 0
  fi

  MISSING_LIST=$(printf '%s' "$MISSING_CHANGELOGS" | sed 's/^ //; s/ /,/g')
  MANIFEST_LIST=$(printf '%s' "$MANIFEST_DIRTY" | tr '\n' ',' | sed 's/,$//')

  REASON="anthril-os plugin manifest(s) changed (${MANIFEST_LIST}) but the per-plugin CHANGELOG.md has not been updated: ${MISSING_LIST}. Add a new versioned section to each affected CHANGELOG.md (Added / Changed / Fixed) before continuing. Submodule marketplace caches do not auto-refresh."

  printf '{"decision":"block","reason":"%s"}\n' "$REASON"
  exit 0
fi

# ---- Parent repo regime ----
if [ ! -f "$REPO_ROOT/CHANGELOG.md" ]; then
  exit 0
fi

MANIFEST_DIRTY=$(git diff --name-only HEAD -- \
  ':(glob)lifestyle/**/plugin.json' \
  ':(glob)smb/**/plugin.json' \
  ':(glob)marketing/**/plugin.json' \
  ':(glob)engineering/**/plugin.json' \
  ':(glob)data-science/**/plugin.json' \
  ':(glob)economics/**/plugin.json' \
  ':(glob)utilities/**/plugin.json' \
  ':(glob)ai-utility-plugins/**/plugin.json' \
  ':(glob)official-business-plugins/**/plugin.json' \
  ':(glob)official-lifestyle-plugins/**/plugin.json' \
  '.claude-plugin/marketplace.json' 2>/dev/null || true)
if [ -z "$MANIFEST_DIRTY" ]; then
  exit 0
fi

CHANGELOG_DIRTY=$(git diff --name-only HEAD -- CHANGELOG.md 2>/dev/null || true)
if [ -n "$CHANGELOG_DIRTY" ]; then
  exit 0
fi

MANIFEST_LIST=$(printf '%s' "$MANIFEST_DIRTY" | tr '\n' ',' | sed 's/,$//')

REASON="Plugin manifest changed (${MANIFEST_LIST}) but CHANGELOG.md has not been updated. Claude Code marketplace caches do not auto-refresh — users sanity-check CHANGELOG.md before running /plugin update. Add a new versioned section to CHANGELOG.md describing this change (Added / Changed / Fixed) before continuing. The README's '## Updating' section explains why this matters."

printf '{"decision":"block","reason":"%s"}\n' "$REASON"
exit 0
