#!/usr/bin/env bash
# PostToolUse hook for Write|Edit.
#
# When a plugin.json is dirty BUT its "version" field is unchanged vs HEAD,
# block the turn and tell the agent to bump the version.
#
# This catches edits that satisfy plugin-manifest-reminder.sh (the manifest
# file is dirty) but didn't actually advance the semver — e.g. description
# tweaks, keyword fixes, or accidental no-op rewrites. Without this guard,
# silent same-version manifests ship to the marketplace and users on cached
# versions never receive the change.
#
# Chains AFTER plugin-manifest-reminder.sh (which guarantees plugin.json is
# dirty). Marketplace.json version drift is caught by a second pass through
# this hook when it is edited.
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

NORMALISED=$(printf '%s' "$FILE_PATH" | tr '\\' '/')

# Only fire for plugin.json edits. Marketplace.json is handled separately
# (matching version pin is enforced by scripts/check-versions.mjs).
case "$NORMALISED" in
  */.claude-plugin/plugin.json) ;;
  *) exit 0 ;;
esac

TARGET_DIR=$(dirname "$NORMALISED")
if [ ! -d "$TARGET_DIR" ]; then
  TARGET_DIR=$(dirname "$TARGET_DIR")
fi
REPO_ROOT=$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null) || exit 0
HOOK_REPO="$REPO_ROOT"

if [ ! -f "$HOOK_REPO/.claude/hooks/version-bump-reminder.sh" ]; then
  exit 0
fi

cd "$REPO_ROOT"

REL="${NORMALISED#${REPO_ROOT}/}"

# Is the manifest dirty? If not, nothing to enforce.
DIRTY=$(git status --porcelain -- "$REL" 2>/dev/null || true)
if [ -z "$DIRTY" ]; then
  exit 0
fi

# Extract the "version" field from both HEAD and working tree. Use grep+sed
# so we do not need jq. The version line looks like:
#   "version": "1.2.3",
extract_version() {
  printf '%s' "$1" \
    | tr -d '\r' \
    | grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n 1 \
    | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/'
}

HEAD_CONTENT=$(git show "HEAD:$REL" 2>/dev/null || echo "")
WORKING_CONTENT=$(cat "$REL" 2>/dev/null || echo "")

# If the file is brand new (no HEAD version), this is fine — a new plugin
# starts at whatever version the author sets.
if [ -z "$HEAD_CONTENT" ]; then
  exit 0
fi

HEAD_VERSION=$(extract_version "$HEAD_CONTENT")
WORKING_VERSION=$(extract_version "$WORKING_CONTENT")

if [ -z "$HEAD_VERSION" ] || [ -z "$WORKING_VERSION" ]; then
  # Malformed manifest — let other tooling catch it.
  exit 0
fi

if [ "$HEAD_VERSION" != "$WORKING_VERSION" ]; then
  # Version was bumped — we're good.
  exit 0
fi

# Version unchanged but file is dirty → nudge.
REASON="${REL} was modified but the version field is still ${HEAD_VERSION}. Bump it (semver: PATCH for fixes, MINOR for new skills/features, MAJOR for breaking changes) and update the matching entry in the marketplace catalogue. Plugin marketplace caches key off the version string — same-version manifests ship silently and users never receive the update."

printf '{"decision":"block","reason":"%s"}\n' "$REASON"
exit 0
