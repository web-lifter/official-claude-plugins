#!/usr/bin/env node
/**
 * check-versions.mjs
 *
 * Enforces that every plugin listed in each folder-level marketplace
 * (`<marketplace>/.claude-plugin/marketplace.json`) declares the same `version`
 * as its own `.claude-plugin/plugin.json`.
 *
 * The repo ships TWO marketplaces — `official-business-plugins/` and
 * `official-lifestyle-plugins/` — each with its own `.claude-plugin/marketplace.json`.
 * This script discovers every such manifest under the repo root and checks all
 * of them. Plugin `source` paths are resolved relative to the marketplace
 * folder that lists them.
 *
 * Why: Claude Code's update logic for relative-path plugins reads `plugin.json`
 * as the source of truth and silently wins over whatever is declared in the
 * marketplace entry. If the two drift, published version bumps can appear to
 * "do nothing" on end-user machines.
 *
 * Usage:
 *   node scripts/check-versions.mjs
 *
 * Exit codes:
 *   0 — all versions in sync
 *   1 — mismatch, missing file, or parse error
 */

import { readFile, readdir } from "node:fs/promises";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

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

const failures = [];
let okCount = 0;

for (const mp of marketplaces) {
  const marketplace = mp.data;
  if (!Array.isArray(marketplace.plugins) || marketplace.plugins.length === 0) {
    failures.push(`${marketplace.name ?? mp.path}: no plugins array or it is empty`);
    continue;
  }

  console.log(bold(`\nVersion sync check — ${marketplace.name}\n`));

  for (const entry of marketplace.plugins) {
    const { name, source, version: marketplaceVersion } = entry;

    if (typeof source !== "string") {
      console.log(`  ${yellow("–")} ${String(name).padEnd(28)} (non-relative source)`);
      continue;
    }
    if (!marketplaceVersion) {
      failures.push(`${name}: marketplace entry is missing "version"`);
      continue;
    }

    const pluginJsonPath = join(mp.dir, source, ".claude-plugin", "plugin.json");
    let pluginManifest;
    try {
      pluginManifest = JSON.parse(await readFile(pluginJsonPath, "utf8"));
    } catch (err) {
      failures.push(`${name}: cannot read ${pluginJsonPath} (${err.message})`);
      continue;
    }

    if (pluginManifest.name !== name) {
      failures.push(
        `${name}: plugin.json "name" is "${pluginManifest.name}", expected "${name}"`,
      );
    }

    const pluginVersion = pluginManifest.version;
    if (!pluginVersion) {
      failures.push(`${name}: plugin.json is missing "version"`);
      continue;
    }

    if (pluginVersion !== marketplaceVersion) {
      failures.push(
        `${name}: marketplace=${marketplaceVersion}, plugin.json=${pluginVersion}`,
      );
    } else {
      console.log(`  ${green("✓")} ${name.padEnd(28)} ${pluginVersion}`);
      okCount += 1;
    }
  }
}

if (failures.length > 0) {
  console.error(`\n${red(bold(`✗ ${failures.length} version issue(s):`))}`);
  for (const f of failures) console.error(`  ${red("✗")} ${f}`);
  console.error(
    "\nFix: ensure the marketplace entry and the plugin.json declare identical version strings.",
  );
  process.exit(1);
}

console.log(
  green(
    bold(
      `\n✓ All ${okCount} plugin versions in sync across ${marketplaces.length} marketplace(s).\n`,
    ),
  ),
);
