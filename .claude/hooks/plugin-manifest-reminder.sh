#!/usr/bin/env bash
# PostToolUse hook for Write|Edit.
#
# When any file inside <category>/<plugin>/ is modified, require BOTH the
# plugin's plugin.json AND the root .claude-plugin/marketplace.json to be
# dirty.
#
# Rationale: Claude Code's plugin marketplace caches do not auto-refresh.
# The marketplace catalogue is the only signal users see when running
# /plugin update. A skill edit without a manifest version bump means the
# new behaviour ships silently and users on cached versions never receive it.
#
# Chains with changelog-reminder.sh + version-bump-reminder.sh.
#
# (The anthril-os repo carries its own copy of this hook; it is a separate
# standalone repo, not a submodule here.)
#
# Implemented without jq so it runs on bare Git Bash on Windows.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(printf '%s' "$INPUT" \
  | tr -d '\r' \
  | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -n 1 \
  | sed -E 's/.*"file_path"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')

if [ -z "${FILE_PATH:-}" ]; then
  exit 0
fi

# Normalise Windows backslashes so path matching works in Git Bash.
NORMALISED=$(printf '%s' "$FILE_PATH" | tr '\\' '/')

# Skip the files we are *asking* the user to update.
case "$NORMALISED" in
  */.claude-plugin/marketplace.json) exit 0 ;;
  */.claude-plugin/plugin.json) exit 0 ;;
esac

TARGET_DIR=$(dirname "$NORMALISED")
if [ ! -d "$TARGET_DIR" ]; then
  TARGET_DIR=$(dirname "$TARGET_DIR")
fi

REPO_ROOT=$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null) || exit 0
HOOK_REPO="$REPO_ROOT"

if [ ! -f "$HOOK_REPO/.claude/hooks/plugin-manifest-reminder.sh" ]; then
  exit 0
fi

cd "$REPO_ROOT"

# Only fire for files inside a known plugin tree.
case "$NORMALISED" in
  */lifestyle/*|*/smb/*|*/marketing/*|*/engineering/*|*/data-science/*|*/economics/*|*/utilities/*|*/ai-utility-plugins/*|*/official-business-plugins/*|*/official-lifestyle-plugins/*) ;;
  *) exit 0 ;;
esac

if [ ! -f "$REPO_ROOT/.claude-plugin/marketplace.json" ]; then
  exit 0
fi

# Walk up to find the nearest enclosing plugin.json (handles arbitrary nesting
# under category groups like ai-utility-plugins/<plugin>/ or
# official-business-plugins/<sub>/<plugin>/).
REL="${NORMALISED#${REPO_ROOT}/}"
PLUGIN_DIR=""
CANDIDATE=$(dirname "$REL")
while [ -n "$CANDIDATE" ] && [ "$CANDIDATE" != "." ] && [ "$CANDIDATE" != "/" ]; do
  if [ -f "$REPO_ROOT/$CANDIDATE/.claude-plugin/plugin.json" ]; then
    PLUGIN_DIR="$CANDIDATE"
    break
  fi
  CANDIDATE=$(dirname "$CANDIDATE")
done

if [ -z "$PLUGIN_DIR" ]; then
  exit 0
fi

PLUGIN_NAME=$(basename "$PLUGIN_DIR")
PLUGIN_MANIFEST="$PLUGIN_DIR/.claude-plugin/plugin.json"

SOURCE_DIRTY=$(git status --porcelain -- "$REL" 2>/dev/null || true)
if [ -z "$SOURCE_DIRTY" ]; then
  exit 0
fi

PLUGIN_DIRTY=$(git status --porcelain -- "$PLUGIN_MANIFEST" 2>/dev/null || true)
MARKETPLACE_DIRTY=$(git status --porcelain -- ".claude-plugin/marketplace.json" 2>/dev/null || true)

MISSING=""
if [ -z "$PLUGIN_DIRTY" ]; then
  MISSING="${PLUGIN_MANIFEST}"
fi
if [ -z "$MARKETPLACE_DIRTY" ]; then
  if [ -n "$MISSING" ]; then
    MISSING="${MISSING} and .claude-plugin/marketplace.json"
  else
    MISSING=".claude-plugin/marketplace.json"
  fi
fi

if [ -z "$MISSING" ]; then
  exit 0
fi

REASON="Plugin source changed (${PLUGIN_NAME}: ${REL}) but ${MISSING} has not been updated. Bump the version in ${PLUGIN_MANIFEST} (semver: patch for fixes, minor for new skills/features, major for breaking changes) AND update the matching entry in .claude-plugin/marketplace.json (version + description if the skill list or scope changed). Both files must stay in sync — marketplace caches do not auto-refresh, so users only see the new version once both manifests advertise it."

printf '{"decision":"block","reason":"%s"}\n' "$REASON"
exit 0
