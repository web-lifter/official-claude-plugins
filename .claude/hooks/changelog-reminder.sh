#!/usr/bin/env bash
# PostToolUse hook for Write|Edit.
#
# When <category>/<plugin>/.claude-plugin/plugin.json or
# .claude-plugin/marketplace.json is dirty, require the root CHANGELOG.md to
# also be dirty.
#
# Rationale: Claude Code's plugin marketplace caches do not auto-refresh, so
# users discover new versions via CHANGELOG.md. Drift between manifests and
# the changelog produces silent "no update available" reports downstream.
#
# (The anthril-os repo carries its own copy of this hook with a per-plugin
# CHANGELOG regime; it is a separate standalone repo, not a submodule here.)
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

REPO_ROOT=$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null) || exit 0
HOOK_REPO="$REPO_ROOT"

# Only act when this hook script lives in *this* repo's .claude/. Prevents
# the hook from firing if a copy of it ends up under another repo via a
# user-level settings.json.
if [ ! -f "$HOOK_REPO/.claude/hooks/changelog-reminder.sh" ]; then
  exit 0
fi

cd "$REPO_ROOT"

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
