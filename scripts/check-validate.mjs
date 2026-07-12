#!/usr/bin/env node
/**
 * check-validate.mjs
 *
 * Runs `claude plugin validate <plugin-path>` for every plugin listed in each
 * folder-level marketplace (`<marketplace>/.claude-plugin/marketplace.json`).
 * Delegates YAML/manifest checking to the official Claude Code CLI, so we never
 * drift from the install-time schema.
 *
 * The repo ships TWO marketplaces — `official-business-plugins/` and
 * `official-lifestyle-plugins/`. Every such manifest under the repo root is
 * discovered and all of its plugins validated. Plugin `source` paths are
 * resolved relative to the marketplace folder that lists them.
 *
 * Why: validation catches problems users hit at install time —
 *   - `agents: Invalid input` from directory paths in plugin.json
 *   - `frontmatter: YAML frontmatter failed to parse`
 *   - `root: Unrecognized key` for fields outside the documented schema
 *
 * Usage:
 *   node scripts/check-validate.mjs
 *
 * Exit codes:
 *   0 — every plugin validates clean
 *   1 — any plugin fails validation, or the `claude` CLI is unavailable
 */

import { readFile, readdir } from "node:fs/promises";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const __filename = fileURLToPath(import.meta.url);
const repoRoot = resolve(dirname(__filename), "..");

const red = (s) => `\x1b[31m${s}\x1b[0m`;
const green = (s) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s) => `\x1b[33m${s}\x1b[0m`;
const bold = (s) => `\x1b[1m${s}\x1b[0m`;

/** Discover every `<dir>/.claude-plugin/marketplace.json` under the repo root. */
async function findMarketplaces() {
  const found = [];
  const entries = await readdir(repoRoot, { withFileTypes: true });
  for (const e of entries) {
    if (!e.isDirectory() || e.name.startsWith(".")) continue;
    const path = join(repoRoot, e.name, ".claude-plugin", "marketplace.json");
    try {
      const data = JSON.parse(await readFile(path, "utf8"));
      found.push({ dir: join(repoRoot, e.name), data, path });
    } catch {
      // Not a marketplace root — skip.
    }
  }
  return found.sort((a, b) => (a.data.name ?? "").localeCompare(b.data.name ?? ""));
}

const marketplaces = await findMarketplaces();
if (marketplaces.length === 0) {
  console.error(red("✗ No */.claude-plugin/marketplace.json found under the repo root"));
  process.exit(1);
}

// On Windows, the `claude` launcher is a .cmd / .ps1 shim, so we need shell
// resolution to pick it up via PATHEXT. We pass the full command as one string
// (avoids Node's DEP0190 shell-arg-escape deprecation) and quote embedded paths.
const quote = (s) => `"${String(s).replace(/"/g, '\\"')}"`;

const probe = spawnSync("claude --version", { encoding: "utf8", shell: true });
if (probe.status !== 0) {
  console.error(
    red(`✗ \`claude\` CLI not available on PATH. Install Claude Code or add it to PATH.`),
  );
  process.exit(1);
}
console.log(`Using ${(probe.stdout || "").trim()}`);

const failures = [];
let passCount = 0;

for (const mp of marketplaces) {
  const marketplace = mp.data;
  if (!Array.isArray(marketplace.plugins) || marketplace.plugins.length === 0) {
    failures.push({ name: marketplace.name ?? mp.path, source: "-", output: "no plugins array or it is empty" });
    continue;
  }

  console.log(bold(`\nPlugin validation sweep — ${marketplace.name}\n`));

  for (const entry of marketplace.plugins) {
    const { name, source } = entry;
    if (typeof source !== "string") {
      console.log(`  ${yellow("–")} ${String(name).padEnd(28)} (non-relative source)`);
      continue;
    }

    const pluginDir = join(mp.dir, source);
    const result = spawnSync(`claude plugin validate ${quote(pluginDir)}`, {
      encoding: "utf8",
      shell: true,
    });
    const output = (result.stdout || "") + (result.stderr || "");

    if (result.status === 0) {
      console.log(`  ${green("✓")} ${name.padEnd(28)} validation passed`);
      passCount += 1;
    } else {
      console.log(`  ${red("✗")} ${name.padEnd(28)} validation FAILED`);
      failures.push({ name, source, output: output.trim() });
    }
  }
}

if (failures.length > 0) {
  console.error(`\n${red(bold(`✗ ${failures.length} plugin(s) failed validation:`))}\n`);
  for (const f of failures) {
    console.error(red(`── ${f.name}  (${f.source}) ──`));
    console.error(f.output);
    console.error("");
  }
  console.error(
    "Fix the errors above before publishing — these match the validation Claude Code does at install time.",
  );
  process.exit(1);
}

console.log(
  green(
    bold(
      `\n✓ All ${passCount} plugins validate clean across ${marketplaces.length} marketplace(s).\n`,
    ),
  ),
);
