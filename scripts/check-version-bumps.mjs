#!/usr/bin/env node
/**
 * check-version-bumps.mjs
 *
 * Fails when a plugin's tracked files changed in a commit range but the
 * plugin's `version` (in its own `.claude-plugin/plugin.json`) was NOT bumped.
 *
 * Why this exists
 * ---------------
 * Claude Code installs each plugin into a *version-keyed* cache directory
 * (…/plugins/cache/<marketplace>/<plugin>/<version>/) and its update logic is
 * gated purely on the `version` string: if the marketplace's advertised
 * version equals the installed version, the plugin is treated as "up to date"
 * and the files are NEVER re-copied — even when the underlying git commit and
 * file contents changed. The result on end-user machines is the classic
 * "I updated but nothing changed / the marketplace does not update" bug.
 *
 * `check-versions.mjs` only proves marketplace.json and plugin.json agree with
 * *each other*. This script proves the version actually *moved* whenever the
 * plugin's content moved — the missing half of the guarantee.
 *
 * Usage
 * -----
 *   node scripts/check-version-bumps.mjs [<baseRef>] [<headRef>]
 *
 * Defaults:
 *   baseRef  = $BASE_REF || origin/main
 *   headRef  = $HEAD_REF || HEAD
 *
 * In GitHub Actions the workflow passes the PR base/head explicitly.
 *
 * Exit codes:
 *   0 — every changed plugin had its version bumped (or was newly added)
 *   1 — a changed plugin shipped under an unchanged version, or a git error
 */

import { readFile } from "node:fs/promises";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";

const __filename = fileURLToPath(import.meta.url);
const repoRoot = resolve(dirname(__filename), "..");

const red = (s) => `\x1b[31m${s}\x1b[0m`;
const green = (s) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s) => `\x1b[33m${s}\x1b[0m`;
const bold = (s) => `\x1b[1m${s}\x1b[0m`;

const baseRef = process.argv[2] || process.env.BASE_REF || "origin/main";
const headRef = process.argv[3] || process.env.HEAD_REF || "HEAD";

function git(args) {
  return execFileSync("git", args, { cwd: repoRoot, encoding: "utf8" });
}

/** Read a path at a given ref, or null if it does not exist there. */
function gitShowOrNull(ref, relPath) {
  try {
    return git(["show", `${ref}:${relPath}`]);
  } catch {
    return null;
  }
}

// ---- Resolve the merge base so renames/force-pushes don't spuriously fire ----
let diffBase = baseRef;
try {
  diffBase = git(["merge-base", baseRef, headRef]).trim() || baseRef;
} catch {
  // No common ancestor reachable (shallow clone, unrelated histories) — fall
  // back to the raw baseRef and let the diff below surface any git error.
  diffBase = baseRef;
}

// ---- Load the authoritative plugin list from marketplace.json ----------------
const marketplacePath = join(repoRoot, ".claude-plugin", "marketplace.json");
let marketplace;
try {
  marketplace = JSON.parse(await readFile(marketplacePath, "utf8"));
} catch (err) {
  console.error(red(`✗ Failed to read ${marketplacePath}: ${err.message}`));
  process.exit(1);
}

const pluginRoot = marketplace.metadata?.pluginRoot ?? ".";
const relativePlugins = (marketplace.plugins ?? [])
  .filter((p) => typeof p.source === "string")
  .map((p) => ({
    name: p.name,
    // Normalise "./foo/bar" → "foo/bar" with forward slashes for git matching.
    dir: join(pluginRoot, p.source).split("\\").join("/").replace(/^\.\//, ""),
  }));

// ---- Compute the set of changed files in the range ---------------------------
let changedFiles;
try {
  changedFiles = git(["diff", "--name-only", `${diffBase}`, headRef])
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);
} catch (err) {
  console.error(
    red(`✗ git diff ${diffBase}..${headRef} failed: ${err.message.trim()}`),
  );
  console.error(
    yellow(
      "  Hint: CI must check out full history (actions/checkout fetch-depth: 0).",
    ),
  );
  process.exit(1);
}

const failures = [];
const results = [];

for (const { name, dir } of relativePlugins) {
  const prefix = dir.endsWith("/") ? dir : `${dir}/`;
  const touched = changedFiles.some((f) => f === dir || f.startsWith(prefix));
  if (!touched) {
    results.push({ name, status: "unchanged" });
    continue;
  }

  const manifestRel = `${prefix}.claude-plugin/plugin.json`;
  const baseManifestRaw = gitShowOrNull(diffBase, manifestRel);

  // Brand-new plugin (didn't exist at base) — nothing to compare against.
  if (baseManifestRaw === null) {
    results.push({ name, status: "added" });
    continue;
  }

  let baseVersion, headVersion;
  try {
    baseVersion = JSON.parse(baseManifestRaw).version;
  } catch (err) {
    failures.push(`${name}: cannot parse plugin.json at ${diffBase} (${err.message})`);
    continue;
  }
  const headManifestRaw = gitShowOrNull(headRef, manifestRel);
  try {
    headVersion = JSON.parse(headManifestRaw ?? "{}").version;
  } catch (err) {
    failures.push(`${name}: cannot parse plugin.json at ${headRef} (${err.message})`);
    continue;
  }

  if (!headVersion) {
    failures.push(`${name}: plugin.json is missing "version" at ${headRef}`);
    continue;
  }

  if (baseVersion === headVersion) {
    failures.push(
      `${name}: files changed but version stayed at ${headVersion} — bump it ` +
        `(both plugin.json and the marketplace.json entry).`,
    );
  } else {
    results.push({ name, status: "bumped", from: baseVersion, to: headVersion });
  }
}

console.log(bold(`\nVersion-bump check — ${marketplace.name}`));
console.log(`  base ${diffBase.slice(0, 12)}  →  head ${headRef}\n`);

for (const r of results) {
  if (r.status === "bumped") {
    console.log(`  ${green("✓")} ${r.name.padEnd(28)} ${r.from} → ${r.to}`);
  } else if (r.status === "added") {
    console.log(`  ${green("+")} ${r.name.padEnd(28)} (new plugin)`);
  }
}

if (failures.length > 0) {
  console.error(`\n${red(bold(`✗ ${failures.length} plugin(s) changed without a version bump:`))}`);
  for (const f of failures) console.error(`  ${red("✗")} ${f}`);
  console.error(
    yellow(
      "\nClaude Code caches plugins by version. Unchanged version = end users\n" +
        "never receive your changes. Bump the semver and keep marketplace.json in sync.",
    ),
  );
  process.exit(1);
}

const movers = results.filter((r) => r.status === "bumped" || r.status === "added").length;
console.log(green(bold(`\n✓ ${movers} changed plugin(s) carried a version bump; nothing stale.\n`)));
