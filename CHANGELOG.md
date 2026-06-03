# Changelog

All notable changes to the Anthril Official Claude Plugins marketplace will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — `seo-toolkit` 2.1.0: self-contained clustering engine, page-type-aware mapping, architecture plan, unified dashboard (2026-06-03)

`seo-toolkit` 2.0.1 → 2.1.0. The `keyword-clustering-and-mapping` skill is now fully self-contained and substantially smarter:

- **Self-contained engine** — the clustering engine is vendored into `skills/keyword-clustering-and-mapping/scripts/` and run locally via `run_clustering.py` (venv built by `setup_env.py`). No external `keyword-cluster` CLI or network API. Degrades to tf-idf if `sentence-transformers` is unavailable.
- **Page-type & intent-aware mapping** — pages are classified (service/landing/blog/guide/news/tool/nav) and commercial keywords are steered to service/landing pages, never blog/news/tool pages. Fixes the core failure where buyer-intent keywords were mis-mapped to blog posts and news articles.
- **Structured architecture** — `architecture.json` (create/optimise/consolidate/deprioritise per cluster, hub/spoke, slugs) narrated into `proposed-architecture.md`. A new **mode gate** asks: optimise-only / optimise + expand / greenfield.
- **One offline `dashboard.html`** — every chart (Plotly inlined) + reports in a single file that opens with no internet; raw files preserved.
- **`keyword-list-developer` focus gate** — `AskUserQuestion` capturing prioritise/exclude/locale/intent → `focus.json`, applied as a hard negative filter and carried into clustering, so off-service keywords stop entering the list.
- **Fixes** — opportunity matrix now populates (column aliasing + tolerant plotting), negative "unknown" (`-1`) sentinels no longer crash charts, and page-brief slugs are de-duplicated.

**User action:** run `/plugin update`. On first clustering run the skill sets up its venv (semantic deps pull `torch` — a large one-time install).

### Fixed — `seo-toolkit` 2.0.1: `keyword-clustering-and-mapping` docs corrected to the real CLI (2026-06-03)

`seo-toolkit` 2.0.0 → 2.0.1. The `keyword-clustering-and-mapping` skill documented a `keyword-cluster` interface the package does not have, so runs failed or produced empty page-mapping. Verified every claim against the installed package and corrected the skill, its reference, agent, templates, examples, and the two downstream skills that consume its output:

- **`--pages` requires `url,page_name`** (not the previously documented 5-column schema). Documented the `crawl` / `enrich-pages` subcommand that enriches pages with `title`/`meta_description`/`h1`/`headings`/`body_excerpt` — folded into the run's page-matching text to sharpen mapping.
- **Cluster count**: `--clusters` is an integer only (default 8); automatic selection is `--auto-k silhouette` (kmeans/agglomerative). Removed the invalid `--clusters auto` from all skills/examples/templates.
- **Embedding presets** corrected to the real set (`tfidf` default, `mini`, `mpnet`, `e5-*`, `bge-*`); semantic embeddings require `--similarity semantic|hybrid`. Removed the non-existent `MiniLM`/`multilingual-MiniLM`/`OpenAI` options and the bogus OpenAI-key prerequisite.
- **Output filenames + schemas** fixed: `page_map.csv` → `keyword_page_map.csv`, `gap_report.csv` → `content_gap_report.csv` (both per-keyword), plus real `cannibalization_report.csv`/`cluster_summary.csv` columns and the previously undocumented `cluster_quality_report.csv`. `internal-linking-planner` and `keyword-list-developer` updated to match so cross-skill handoffs resolve to files that exist.

**User action:** run `/plugin update` (then sanity-check this entry). No credential or config changes.

### Changed — `seo-toolkit` 2.0.0: credentials simplified to a plaintext file, vault + OAuth removed (2026-06-02)

`seo-toolkit` 1.1.2 → 2.0.0 (**breaking**). The encrypted-vault + passphrase + OAuth + setup-wizard stack proved too hard to use. Replaced with the simplest possible model:

- **One plaintext file**: `~/.claude/plugins/data/seo-toolkit/credentials.json`. Every provider reads from it directly; per-provider env vars (`SERPAPI_KEY`, etc.) still override. No encryption, passphrase, OAuth, or wizard.
- **Removed**: the Fernet vault (`seo_vault.py`), the `seo_vault_passphrase` userConfig option, GSC + GA4 OAuth providers (and the `gsc-performance-report` skill, 20 → 19 skills), the `seo-connect`/`seo-disconnect` commands, `token_validator.py`, and the `cryptography`/`filelock`/`google-auth*` dependencies.
- **Added**: `scripts/lib/credentials.py`, `scripts/seo_status.py`, the `/seo-toolkit:seo-setup` command, and a `credentials.example.json` template.

**User action:** run `/plugin update`, then `/seo-toolkit:seo-setup` to create the credentials file and paste in your keys. Re-enter any keys previously held in the encrypted vault; the old `tokens.enc` is no longer read and can be deleted.

### Fixed — `seo-toolkit` vault passphrase never reached runtime (2026-06-02)

`seo-toolkit` 1.1.1 → 1.1.2. Credentials saved via `/seo-toolkit:seo-connect` were written to the encrypted vault correctly, but every provider reported its key as "missing" at runtime. Two defects combined:

- The runtime clients and `token_validator.py` read the passphrase from `SEO_VAULT_PASSPHRASE` — an environment variable nothing in the skill/command execution path ever set. The only writer was a SessionStart hook whose `export` could not propagate to later tool-call subprocesses.
- The documented `seo_vault_passphrase` setting was never declared as a `userConfig` option, so Claude Code never prompted for it and never exported `CLAUDE_PLUGIN_OPTION_SEO_VAULT_PASSPHRASE`.

Fix:
- Declared `seo_vault_passphrase` as a `sensitive`, `required` `userConfig` option in `plugin.json`.
- Added `resolve_passphrase()` in `seo_vault.py` (reads `CLAUDE_PLUGIN_OPTION_SEO_VAULT_PASSPHRASE`, falls back to `SEO_VAULT_PASSPHRASE`); all provider clients and the validator now use it.
- `token_validator.py` and the `seo_vault.py` CLI accept an optional `--passphrase`; commands pass it explicitly instead of relying on cross-process env propagation.

**User action:** run `/plugin update`, then set the vault passphrase in the seo-toolkit plugin settings dialog (the same passphrase used at `seo-connect` time) and restart the session.

### Fixed — `plan-review` slash commands now use `/plan-review:` namespace (2026-05-24)

The `plan-review` plugin's skill docs, command file, hook welcome banner, and plugin.json description all referenced the legacy `/utilities:` slash namespace (e.g. `/utilities:audit-resolve`, `/utilities:plan-completion-audit`). These were stale from a pre-split layout when both plan-review and engineering-utilities lived under a single `utilities` plugin.

All references rewritten to the correct `/plan-review:` namespace. The plugin manifest (`name: plan-review`) and on-disk layout were already correct — this fix only updates the documentation/UI strings users see.

**User action:** invoke as `/plan-review:plan-completion-audit` and `/plan-review:audit-resolve` going forward.

### Changed — `engineering-utilities` renamed to `programming-utilities` (2026-05-24)

The marketplace plugin previously named `engineering-utilities` (folder `official-business-plugins/engineering/utilities/`) has been renamed to `programming-utilities` (folder `official-business-plugins/engineering/programming-utilities/`).

- `plugin.json` — `name` is now `programming-utilities`; `homepage` points to the new path.
- `.claude-plugin/marketplace.json` — entry renamed; `source` updated to `./official-business-plugins/engineering/programming-utilities`; `homepage` updated.
- README.md, tests/README.md, prior CHANGELOG path references — updated to the new folder.
- Skill contents unchanged: `changelog-generator`, `pr-description-writer`, `env-var-auditor`, `doc-link-validator`, `repo-snapshot`.

**User action required:** run `/plugin update` after pulling. Anyone previously installed under the `engineering-utilities` plugin name should `/plugin uninstall engineering-utilities` and `/plugin install programming-utilities@anthril`.

### Restructured — repo layout consolidated into named plugin roots (2026-05-23)

Top-level category directories (`smb/`, `marketing/`, `engineering/`, `data-science/`, `economics/`, `utilities/`, `seo/`, `lifestyle/`) have been replaced with named plugin roots:

- `ai-utility-plugins/` — `resource-manager`, `skill-ops` (skill-creator only), `plan-review` (plan-completion-audit + audit-resolver)
- `anthril-os/` — `engineering-os/` (20 role plugins + `software-assurance-audit-program`), `venture-os/`
- `official-business-plugins/` — `data-science/`, `economics/`, `engineering/`, `general/`, `marketing/`, `startups/`
- `official-lifestyle-plugins/` — `health-wellness`, `home-life-logistics`, `personal-finance`, `personal-productivity`
- `internal-utilities/` — `observability`, `skill-ops` (evaluators + autonomous-iteration-loop) — NOT included in marketplace

Companion fixes that landed alongside the restructure:

- **Marketplace** — `.claude-plugin/marketplace.json` regenerated to list the 29 user-facing plugins under the three official roots: `ai-utility-plugins/` (3), `official-business-plugins/` (22 across data-science, economics, engineering, general, marketing, startups), and `official-lifestyle-plugins/` (4). The `anthril-os/` (engineering-os + venture-os) and `internal-utilities/` trees live on disk for direct-path installation but are excluded from the marketplace by design.
- **`homepage` URLs** — every plugin manifest's `homepage` updated to its new on-disk path.
- **`dependencies` field stripped** — the undocumented top-level `dependencies` array has been removed from 11 manifests (9 startups plugins + `experimentation` + `strategic-economics`) per the documented Claude Code plugin schema.
- **Split plugin descriptions rewritten** — the four split plugins (`ai-utility-plugins/skill-ops`, `ai-utility-plugins/plan-review`, `internal-utilities/skill-ops`, `official-business-plugins/engineering/utilities`) now have descriptions matching their actual contents instead of inheriting the legacy unified blurb. `ai-utility-plugins/plan-review` was renamed from internal `name: "ai-utilities"` to `name: "plan-review"`.
- **`.virustotal/*.json`** — all 18 sidecar `path` fields updated to the new locations.
- **Tests** — `tests/scripts/test_smoke.py` and `tests/README.md` script-path references updated; `link-check.py` resolved to `official-business-plugins/engineering/utilities/scripts/` (it did not move with `plan-review`).
- **Root docs** — `SECURITY.md`, `OUTPUT-CONVENTIONS.md`, `.gitignore` comments, and two plugin READMEs (`engineering/devops`, `engineering/software-development`) repaired to use the new paths.
- **README.md** — rewritten to reflect the 51-plugin layout.

Historical CHANGELOG entries below this one still reference the OLD top-level paths — they are preserved as written for historical accuracy.

### Refined — Engineering OS skill bodies via archetype dispatch

All 232 SKILL.md bodies and 232 output templates regenerated through an archetype classifier ([`scripts/eng-os/archetypes.mjs`](scripts/eng-os/archetypes.mjs)). Eleven archetypes — `profile`, `decision`, `review`, `diagnose`, `implementation`, `research`, `runbook`, `postmortem`, `narrative-doc`, `schema`, `plan` (default) — each have a tailored Phase structure and a tailored output-template skeleton. Distribution: plan 176, review 9, schema 8, implementation 8, narrative-doc 8, research 7, runbook 6, diagnose 4, profile 3, decision 2, postmortem 1.

The uniform "Phase 1 Load context / Phase 2 Plan / Phase 3 Produce / Phase 4 Validate / Phase 5 Handoff" pattern has been replaced with archetype-appropriate phases — e.g. postmortem skills now have "Timeline → Impact → Contributing factors → Actions → Publish"; implementation skills have "Read design → Read codebase → Plan edits → Edit → Verify and report"; diagnose skills have "Reproduce → Isolate → Identify root cause → Patch and verify → Follow-up".

### Added — Engineering OS suite v0.1.0 (Waves 1, 2, 3)

The full 20-plugin **Engineering OS** suite has been scaffolded under `anthril-os/engineering-os/`, covering primary engineering work plus specialist and executive domains:

- **Wave 1 (12 plugins, 134 skills, 96 agents):** `eng-core`, `eng-product`, `eng-architecture`, `eng-app`, `eng-platform`, `eng-devops`, `eng-sre`, `eng-database`, `eng-quality`, `eng-security`, `eng-tpm`, `eng-docs`.
- **Wave 2 (6 plugins, 74 skills, 52 agents):** `eng-design`, `eng-data`, `eng-ai`, `eng-it`, `eng-grc`, `eng-customer`.
- **Wave 3 (2 plugins, 24 skills, 16 agents):** `eng-business`, `eng-executive`.

Each plugin ships a manifest, README, CHANGELOG, MIT licence, full skill set with SKILL.md + template + example per skill, full agent set, standard hooks (`seed-workspace.sh` SessionStart + `suggest-related.sh` Stop), and placeholder MCP/LSP/monitor configs. Total: **232 SKILL.md files, 159 agent files, ~1,075 artefacts.**

The suite is data-driven: edit `anthril-os/engineering-os/_suite/spec/suite-spec.json` and re-run `node scripts/eng-os/scaffold-suite.mjs` to regenerate. Hand-tuned content is preserved across regenerations (detected by absence of the `<!-- AUTO-GENERATED -->` marker).

- **Shared workspace contract:** every plugin reads/writes `.eng-os/` (profiles, service catalog, decisions, handoffs, work, reports). Schema and safety modes documented in `anthril-os/engineering-os/CONVENTIONS.md`.
- **Handoff schema validated by `scripts/eng-os/validate-handoff.mjs`.** Worked fixture at `_suite/fixtures/checkout-revamp/` exercises the chain from `eng-product` → `eng-architecture` → `eng-app`.
- **Marketplace updated:** `.claude-plugin/marketplace.json` recreated with 20 entries under `category: engineering`.
- **Validation:** all 20 plugins pass `node scripts/check-validate.mjs` and `node scripts/check-versions.mjs`.

### Added — `software-assurance-audit-program` v1.0.0 (first public-eligible release)

SAAP has reached **v1.0.0** — the cut-line. Schemas, command names, agent names, hook contract, and `.saap/` workspace layout are now stable; breaking changes require a MAJOR bump and a migration script. Final surface:

- **25 skills + 28 agents** spanning security, performance, reliability, privacy, compliance readiness (SOC 2 / ISO 27001 / PCI), accessibility, AI/ML, vendor risk, recurring controls.
- **5 event monitors** (CI failures, deployments, security advisories, incidents, scanner findings).
- **13 documented MCP integration categories + 17 LSP servers** — optional, read-only by default, with explicit per-call approval for mutating actions.
- **14 cross-stack adapters** + **7 fixture-tested stacks** (Node/TS, Python, Go, Java/Spring, .NET, infra-only, AI/LLM) — all profiling at 100% accuracy against committed snapshots; zero cross-stack leakage in agent prose.
- **Phase 9 critical fix** — pure-Python detectors replace bash subprocess calls on Windows (Python's `subprocess.run("bash", …)` was resolving to WSL bash and failing on Windows paths).
- **MVP demo** — fully reproducible walk-through committed at `engineering-os/software-assurance-audit-program/.docs/MVP-DEMO.md`, executed against the `node-ts-web` fixture, captures all 8 MVP capabilities with real outputs.
- **Release rhythm doc** — semver contract, per-release checklist, stability guarantees committed at `engineering-os/software-assurance-audit-program/.docs/RELEASE-RHYTHM.md`.

This release supersedes the deprecation announcement in `software-development` v1.5.0 (Next.js/Supabase `application-audit` skill removal). Public marketplace install is now eligible.

### Changed — `software-development` v1.5.0 (BREAKING: `application-audit` removed)

The Next.js + Supabase + Postgres-biased `application-audit` skill and its three companion commands (`/audit-proceed`, `/audit-compile-plan`, `/audit-work`) have been **removed** from `software-development`. The skill's eleven specialist agents have been ported, generalised, and re-shipped under the new cross-stack `software-assurance-audit-program` plugin (see below). The legacy `.anthril/` workspace format is preserved as a read-only import source — `/software-assurance-audit-program:migrate-anthril` normalises it into `.saap/migrations/anthril-imports/<timestamp>/` without modifying the original tree.

`software-development` now ships four skills: `dead-code-audit`, `write-path-mapping`, `plan-orchestrator`, and `codebase-profiler`. The plugin manifest's `agents` list dropped from 23 to 12 entries.

### Added — `software-assurance-audit-program` plugin v0.1.0 (Phases 0–3 internal alpha)

Profile-first, cross-stack assurance audit plugin. Replaces the legacy `application-audit` skill with a workflow that profiles any stack (Node/TS, Python, Go, Rust, Java/JVM, .NET, PHP, Ruby, mobile, serverless, containers/k8s, data platforms, AI/LLM) before routing audit domains, validates every finding against shared schemas, and writes all output under `.saap/`. Phases 0 (docs), 1 (skeleton + manifest), 2 (profile + 14 stack adapters + 5 profiler agents + 7 detectors), and 3 (8 ported/refit domain agents, 6 new skills, finding/evidence/audit-plan schemas, full `.anthril/`-to-`.saap/` migration pipeline) have landed.

Public marketplace install will follow once SAAP cuts 0.1.0 with the full skill set (Phase 7 of the SAAP roadmap). Until then it is internal-alpha.

## [2.13.0] - 2026-05-22

### Fixed — Version bumps so `claude plugin update` delivers v2.12.0 fixes

The v2.12.0 commit fixed critical plugin load failures (duplicate hooks error, spurious dependencies) and added OTel telemetry to all 18 plugins, but no plugin version numbers were bumped. Claude Code's update mechanism compares version strings — same version means "already up to date, skip re-install" — so no installed user would have received the fixes.

All 19 affected plugins have been given a patch-version bump:

| Plugin | Was | Now |
|---|---|---|
| `data-analysis` | 1.0.3 | 1.0.4 |
| `business-economics` | 1.2.0 | 1.2.1 |
| `strategic-economics` | 1.0.1 | 1.0.2 |
| `package-manager` | 1.1.2 | 1.1.3 |
| `utilities` | 2.2.0 | 2.2.1 |
| `skill-ops` | 2.1.0 | 2.1.1 |
| `brand-manager` | 1.0.2 | 1.0.3 |
| `software-development` | 1.4.0 | 1.4.1 |
| `ppc-manager` | 1.0.2 | 1.0.3 |
| `database-design` | 1.3.1 | 1.3.2 |
| `devops` | 1.0.2 | 1.0.3 |
| `resource-manager` | 1.0.1 | 1.0.2 |
| `seo-toolkit` | 1.1.0 | 1.1.1 |
| `business-operations` | 1.0.0 | 1.0.1 |
| `experimentation` | 1.0.1 | 1.0.2 |
| `personal-productivity` | 1.0.1 | 1.0.2 |
| `health-wellness` | 1.0.1 | 1.0.2 |
| `personal-finance` | 1.0.1 | 1.0.2 |
| `home-life-logistics` | 1.0.1 | 1.0.2 |

`node scripts/check-versions.mjs` exits 0 — all 28 plugins in sync.

### Changed — `.gitignore` excludes `.anthril/.docs/`

`.anthril/.docs/` contains fetched copies of external Claude Code documentation pages (8 files, ~580 KB). These are runtime cache — always available fresh from `code.claude.com` — and should not be tracked in git where they go stale and bloat the repo. Added to `.gitignore`.

`tests/` and `scripts/` remain at the repo root. They are conventional developer tooling directories referenced throughout `CLAUDE.md` and the CHANGELOG verification steps; they are not Claude runtime artefacts and should not move into `.anthril/`.

## [2.12.0] - 2026-05-22

### Fixed — Plugin manifest hygiene (spurious `hooks`, `dependencies`, `displayName` fields)

Resolves plugin load failures and dependency errors across 18 plugins caused by undocumented or misused manifest fields.

**Fixed — `"hooks"` field removed from all plugin manifests (18 plugins)**

Claude Code v2.1.143+ auto-loads `hooks/hooks.json` when it exists alongside a plugin. Specifying `"hooks": "./hooks/hooks.json"` explicitly in `plugin.json` caused a "Duplicate hooks file detected" error that aborted the entire plugin load and hid all skills from the `/` menu. The field has been removed from every affected manifest:

`data-analysis`, `experimentation`, `business-economics`, `strategic-economics`, `database-design`, `devops`, `package-manager`, `software-development`, `health-wellness`, `home-life-logistics`, `personal-finance`, `personal-productivity`, `ppc-manager`, `brand-manager`, `business-operations`, `resource-manager`, `skill-ops`, `utilities`

**Fixed — `"dependencies"` field removed from `brand-manager` and `utilities`**

The `dependencies` field enforces hard install requirements — Claude Code will refuse to activate the plugin unless every listed plugin is also installed. Both plugins listed plugins that were routing suggestions in skill docs, not genuine runtime requirements:

- `smb/brand-manager` — removed `["business-operations"]` (no skill file references it)
- `utilities/utilities` — removed `["database-design", "experimentation", "business-economics", "strategic-economics"]` (these are cross-plugin suggestions, not install requirements)

**Updated — `CLAUDE.md` development standards**

Added explicit warning to the Plugin Manifest field-shape rules: "Do NOT add `"hooks": "./hooks/hooks.json"` to `plugin.json`. Claude Code automatically loads `hooks/hooks.json` if it exists — specifying it explicitly causes a 'Duplicate hooks file detected' error." The `hooks` field has been removed from the `plugin.json` example template.

## [2.11.0] - 2026-05-21

### Added — Startups marketplace category and 9 new plugins (70 skills)

Introduces the **startups** category for venture/customer-development workflows. Nine plugins move out of the `startups/` working directory into the marketplace proper.

**New category**

- `startups` added to the marketplace description alongside Lifestyle, SMB, Marketing, Engineering, Data Science, Economics, SEO, and Utilities.

**New plugins (registered under `category: "startups"`)**

| Plugin | Skills | Role |
|---|---|---|
| `venture-core` | 7 | Chassis — workspace init, status, phase routing, vision, hypothesis register, pivot/refine log, handoff doc |
| `customer-discovery` | 7 | Segment definition, customer profile, early adopters, interview guide/log/analyse, four-question readiness gate |
| `value-proposition-canvas` | 4 | Strategyzer VPC — value map, fit check, six ways to innovate, VPC versioning |
| `business-model-canvas` | 5 | Strategyzer BMC — build, front/back split, hypothesis-driven update, VPC linkage, revenue/cost sketch |
| `competitor-analysis` | 6 | UVP, discovery, table, SWOT, shadow BMC, insights |
| `venture-experimentation` | 6 | Falsifiability check, test cards, learning cards, experiment design/prioritise/track. Renamed from `experimentation` to disambiguate from `data-science/experimentation`. |
| `relationships-channels` | 5 | Get/keep/grow, channel select, product-channel fit, funnel model, churn model |
| `prototyping` | 7 | Diverge/converge, paper + digital prototype, Figma-MCP handoff, feedback, prototype-vs-MVP gate |
| `mvp-planning` | 23 | MVP scope/type/metrics + tech-stack/architecture/ADR/API + Supabase schema/RLS/migrations/auth + Vercel/Cloudflare deploy + analytics/funnel/experiment data + feasibility/build/pitch |

**Plugin chassis alignment**

- All 9 `plugin.json` files brought onto the repo convention: `homepage`, `repository`, `license: "MIT"`, `keywords`, explicit `skills` and `agents` paths, full author block.
- Fixed two plugin names that didn't match their directories: `business-model` → `business-model-canvas`, `value-proposition` → `value-proposition-canvas`.
- Renamed `startups/experimentation` → `startups/venture-experimentation` to avoid colliding with the existing `data-science/experimentation` plugin on install.
- Stripped COMP1100/COMP7110 curriculum framing from plugin descriptions; reframed each in production-grade language while preserving the methodological references (Strategyzer BMC/VPC, Lean Startup, JTBD).
- Each plugin gained a `README.md` (skill table + install/invoke examples) and an empty `settings.json` per the standard plugin structure.

**Marketplace entries**

- Nine new entries added to `marketplace.json` under `category: "startups"`, with `source: "./startups/<plugin>"` paths.

**Productionisation pass (in this entry)**

- Curriculum framing stripped from all 70 SKILL.md files — `Grep -rE "COMP1100|COMP7110|Curriculum hook|Week 7 studio" startups/*/skills/*/SKILL.md` now returns zero matches. Per-skill `references.md` files added where the skill enforces a method or guard-rail; consolidated source list at `startups/SOURCES.md` (Osterwalder & Pigneur, Blank, Ries, Maurya, Christensen, Nygard, Reichheld).
- `templates/output-template.md` + `examples/example-output.md` created for every one of the 70 skills (previously 9/70 had both; now 70/70). Every example portrays the canonical ContractIQ venture (B2B SaaS contract redlining for AU mid-market in-house counsel) — see `startups/CONTRACT-IQ-CONTEXT.md`. Cross-skill examples reference each other coherently so a reviewer can walk the venture funnel end-to-end through the worked outputs.
- Blocking guard-rails (`hypothesis-falsifiability-check`, `prototype-vs-mvp-distinguish`, `customer-discovery-status`) retained but each now cites primary research and documents `--force` override behaviour with `log.md` audit trail.
- `evals/suite.yaml` bootstrapped for every skill (70/70). Activation harness pass rate 99.7% (349/350 cases) in fast mode.

**Audit deliverables**

- `startups/AUDIT.md` — consolidated baseline → final report. Average evaluator score moved 62.5/100 → 100/100. Grade-A skills 9/70 → 70/70.
- `startups/AUDIT.json` — machine-readable sidecar with baseline + final evaluator and harness payloads.
- `startups/audits/2026-05-21/` — baseline JSON sidecars and run scripts.
- `startups/audits/2026-05-21-final/` — post-rewrite JSON sidecars and run scripts.
- `startups/STARTUP_FACTORY_PLAN.md` retained at top of `startups/` with a supersession banner pointing at AUDIT.md.

**Remaining backlog** (tracked in AUDIT.md, not blocking marketplace ship)

- Full-mode `/skill-evaluator` qualitative subagent pass on all 70 skills.
- Full-mode `/skill-eval-harness` functional + LLM-as-judge pass on all 70 suites.
- `@anthril/claude-memex` `venture` profile (the chassis dependency for `venture-init`).
- Cross-skill end-to-end workflow harness.
- Connector mock fixtures so harness can exercise connected paths for Supabase/Cloudflare/Figma without a live MCP.

## [2.10.0] - 2026-05-21

### Fixed — Plugin install failures (7 plugins) and SKILL.md YAML parse errors (2 skills)

The 7 plugins that previously failed `claude plugin validate` and would not install now validate cleanly:
`database-design`, `experimentation`, `personal-finance`, `ppc-manager`, `software-development`, `seo-toolkit`, `strategic-economics`.

Root cause was the `agents` field in `plugin.json` containing trailing-slash directory paths (`"./skills/foo/agents/"`). The official plugin manifest schema requires `agents` to be either a single `.md` file path or an array of `.md` file paths — directory paths fail strict validation with `agents: Invalid input` and block the install.

**Changed**

- `agents` field in all 7 affected `plugin.json` files now lists individual `.md` agent files explicitly (full enumeration, no trailing-slash directory shortcuts).
- Removed the `displayName` field from all 19 plugin manifests. `displayName` was added to the Claude Code plugin schema in v2.1.143; on earlier CLI versions the validator flags it as an unrecognized key. The field is non-essential (Claude Code falls back to `name`), and removing it makes the manifests compatible with v2.1.141 and any prior strict-validation tooling.

**Fixed (skills)**

- `engineering/software-development/skills/codebase-profiler/SKILL.md` — moved `ultrathink` out of the YAML frontmatter (where it was a bare key with no value, breaking the YAML parser) and into the body, where it belongs. At runtime the skill had been loading with empty metadata.
- `utilities/skill-ops/skills/skill-eval-harness/SKILL.md` — quoted the `allowed-tools` value so the `*` and `:` characters inside `Bash(jq:*)` / `Bash(node:*)` / `Bash(bash:scripts/*.sh)` no longer trip YAML's anchor/alias parsing.

**Verification**

- `claude plugin validate <plugin>` now exits 0 (or, on CLI < v2.1.143, only emits the `displayName`-removed-from-the-spec-too-recently warning) for every plugin in the marketplace.

## [2.9.0] - 2026-05-21

### Added — audit-resolver

Closes the audit → fix loop. Pairs with the existing `plan-completion-audit` skill: after an audit produces a report, `audit-resolver` reads it, plans the fixes, executes them with safety gates, and produces a durable ledger of what changed.

- **New skill:** `utilities/utilities/skills/audit-resolver/` — 7-phase workflow (discovery → triage → confirmation gate → pre-flight → batched execute → optional re-audit → ledger). Reads any `plan-completion-audit` report under `.anthril/audits/`, parses every finding into a structured ledger, classifies each (AUTO / SUB-SKILL / PLAN-FIRST / HUMAN-INPUT / DEFER), and applies fixes batch-by-batch with verifier checks (`tsc --noEmit`, `npm test`, `python tests/...`, `node scripts/check-versions.mjs` — auto-detected per stack via `scripts/verify-stack.sh`).
- **New command:** `utilities/utilities/commands/audit-resolve.md` — convenient slash invocation `/utilities:audit-resolve [report-path] [flags]`. Thin wrapper that dispatches to the skill.
- **Supporting artefacts:**
  - `templates/output-template.md` — resolution-ledger structure
  - `examples/example-output.md` — dog-food: ledger of running audit-resolver against this repo's own 2.8.1 sweep
  - `reference.md` — finding-category → handling-strategy lookup; verifier matrix per stack; sub-skill dispatch map
  - `scripts/parse-audit-report.sh` — extract findings from markdown report (TSV out)
  - `scripts/verify-stack.sh` — detect stack via file presence; run appropriate verifier
- **Cross-reference added** to `plan-completion-audit` SKILL.md — every audit report now ends with the `/utilities:audit-resolve` next-step hint.

### Flags supported

```
--dry-run                                  # action plan + diff preview, no execution
--severity=critical[,warning,suggestion]   # default: all three
--phase=N[,N,...]                          # restrict to specific audit phases
--reaudit                                  # re-run plan-completion-audit at the end + diff verdicts
--no-confirm                               # skip per-batch confirmation (HUMAN-INPUT still pauses)
--ledger=<path>                            # override ledger location
```

### Safety guardrails (deliberate)

- **Never commits, pushes, resets, or creates branches.** User owns version control.
- **Always verifies after every batch.** Halts on verifier failure — never auto-continues past a broken state.
- **Ledger is the resume state** (append-only markdown); mid-run interruptions can be resumed by re-invoking.
- **Confirmation gates** via `AskUserQuestion` at Phase 3 (plan approval) and per HUMAN-INPUT finding.
- **Deliberately omitted from `allowed-tools`:** `git commit`, `git push`, `git reset`, `rm`. The skill writes its own ledger / subplan files; never modifies VCS or deletes user files.

### Changed

- **`utilities/utilities`** bumped **v2.1.1 → v2.2.0** (minor — new feature, no breaking changes).

### Verification

- `node scripts/check-versions.mjs` exits 0 — all 19 plugins remain in sync.
- `python tests/scripts/test_smoke.py` — 12/12 still pass.
- New scripts (`parse-audit-report.sh`, `verify-stack.sh`) pass `bash -n`.

## [2.8.1] - 2026-05-21

### Changed — post-release cleanup sweep

This patch release rolls up the P1 + P2 + P3 findings from the 2.8.0 skill-evaluator pass (avg 104.7/115). All changes are non-breaking; user-visible skill behaviour is unchanged.

**Patch-bumped:**

- `lifestyle/personal-productivity` v1.0.0 → **v1.0.1**
- `lifestyle/health-wellness` v1.0.0 → **v1.0.1**
- `lifestyle/personal-finance` v1.0.0 → **v1.0.1**
- `lifestyle/home-life-logistics` v1.0.0 → **v1.0.1**
- `data-science/experimentation` v1.0.0 → **v1.0.1**
- `economics/strategic-economics` v1.0.0 → **v1.0.1**
- `economics/business-economics` v1.1.0 → **v1.1.1**
- `engineering/database-design` v1.3.0 → **v1.3.1**
- `utilities/utilities` v2.1.0 → **v2.1.1**

### Fixed

- **P1 — Dangling `reference.md` references** in 3 SKILL.md bodies (`deep-focus-day`, `adulting-checklist`, `forecasting-model-spec`) — the skills had no companion `reference.md` (per plan) but the SKILL.md text still said "see reference.md". Body text now reads cleanly.
- **P2.1 — `AskUserQuestion` tool missing from `allowed-tools`** on every new skill that uses Phase 1 intake via `AskUserQuestion` (38 skills patched). Previously the skills *described* using the tool but didn't *whitelist* it.
- **P2.2 — Plugin-level script paths standardised** to `${CLAUDE_PLUGIN_ROOT}/scripts/X` across 8 affected `allowed-tools` lines (`macro-calc.py`, `retirement-projection.py`, `debt-payoff-calc.py`, `power-calc.py`, `cvp-calc.py`, `schema-introspect.sh`, `git-history-digest.sh`, `link-check.py`). Previously written as `scripts/X` which resolves to skill-local rather than plugin-root.
- **P2.3 — Disclaimer text inlined** into all 10 health/finance output templates + matching examples (5 health-wellness + 5 personal-finance). Previously templates referenced `commands/*-disclaimer.md` which doesn't auto-expand at runtime; users would see a one-line disclaimer instead of the full ASIC / TGA / clinician-referral block.

### Added

- **P3.1 — Second contrasting example** (`example-output-2.md`) for 10 skills:
  - `move-more-plan` — novice + bodyweight + 3 sessions/wk
  - `sleep-tune-up` — apnoea-suspected red-flag referral stop
  - `smart-supplement-stack` — pregnancy + polypharmacy referral path
  - `money-map` — sole-trader irregular income (profit-first)
  - `rainy-day-plan` — sole-trader tradesperson scenario
  - `debt-knockout-plan` — HECS-HELP-only edge case
  - `savings-game-plan` — FIRE-leaning 55% savings rate scenario
  - `competitive-dynamics-analyser` — two-sided marketplace (AU food delivery)
  - `supabase-schema-bootstrap` — minimal SaaS with full RLS bundle inlined
  - `repo-snapshot` — non-anthril repo (typical Next.js + Supabase B2B SaaS)
- **P3.2 — Python smoke-test harness** at `tests/scripts/test_smoke.py` (12 tests, pure stdlib, ~0.6s runtime). Covers all 6 plugin-level Python scripts shipped in 2.8.0.
- **P3.4 — `paths` glob for auto-activation** added to frontmatter of 6 skills (`sunday-reset`, `debt-knockout-plan`, `rainy-day-plan`, `competitive-dynamics-analyser`, `moat-strength-audit`, `thoughtful-gifts-plan`).

### Changed

- **P3.3 — Phase heading depth** promoted from `###` to `##` in 4 SKILL.md files (`sleep-tune-up`, `daily-wellness-stack`, `thoughtful-gifts-plan`, `repo-snapshot`) for convention parity with the rest of the repo.

### Verification

- `node scripts/check-versions.mjs` exits 0 — all 19 plugins in sync.
- `python tests/scripts/test_smoke.py` — 12/12 tests pass (~0.6s).
- All disclaimer blocks now contain the full ASIC / TGA / clinician-referral text inline; no remaining `commands/*-disclaimer.md` reference dependency at runtime.

## [2.8.0] - 2026-05-20

### Added — new plugins

- **`lifestyle/personal-productivity`** (new plugin, new `lifestyle` category) — 4 skills: `habit-stacker`, `sunday-reset`, `deep-focus-day`, `energy-detective`. Plus `commands/lifestyle-onboard.md` interactive wizard, `hooks/scripts/suggest-related.sh`, and reference materials for habit-stacker + energy-detective.
- **`lifestyle/health-wellness`** (new plugin) — 5 skills: `week-of-meals`, `move-more-plan`, `sleep-tune-up`, `smart-supplement-stack`, `daily-wellness-stack`. Plus `commands/health-disclaimer.md`, `scripts/macro-calc.py` (Mifflin-St Jeor TDEE + macro split), reference materials for week-of-meals + move-more-plan + smart-supplement-stack. Includes mandatory disclaimer pattern (general info only, not medical advice).
- **`lifestyle/personal-finance`** (new plugin) — 5 skills: `money-map`, `debt-knockout-plan`, `savings-game-plan`, `future-me-projection`, `rainy-day-plan`. Plus `commands/finance-disclaimer.md`, `agents/projection-analyst.md` (opus / effort high — sequence-of-returns risk, AU super rules), `scripts/retirement-projection.py` + `scripts/debt-payoff-calc.py`, reference materials for money-map + future-me-projection + rainy-day-plan. AU super / FHSS / Centrelink / ASIC context throughout.
- **`lifestyle/home-life-logistics`** (new plugin) — 4 skills: `trip-day-by-day`, `home-tlc-calendar`, `adulting-checklist`, `thoughtful-gifts-plan`. State-by-state AU compliance for home maintenance; AU FY-aligned quarterly admin sweep.
- **`data-science/experimentation`** (new plugin) — 4 skills: `ab-test-designer`, `experiment-readout-builder`, `forecasting-model-spec`, `causal-impact-analyser`. Plus `agents/stats-reviewer.md` (opus / effort max — p-hacking + SRM + 12-pitfall peer review), `scripts/power-calc.py` (two-proportion z-test). Reference materials cover sample-size formulas, randomisation-unit decision tree, and causal-inference method-selection flowchart.
- **`economics/strategic-economics`** (new plugin) — 3 skills: `competitive-dynamics-analyser`, `elasticity-estimator`, `moat-strength-audit`. Plus `agents/red-team-strategist.md` (opus / effort max) for challenging optimistic moat / dynamics conclusions.

### Changed — extended plugins

- **`economics/business-economics`** bumped v1.0.3 → **v1.1.0**. Added 3 skills: `pricing-architecture-designer`, `cost-structure-builder`, `break-even-scenario-modeller`. Added `scripts/cvp-calc.py` (CVP + break-even + sensitivity). Updated `hooks/scripts/suggest-related.sh` to include new skills.
- **`engineering/database-design`** bumped v1.1.1 → **v1.2.0**. Added 5 skills: `erd-generator`, `rls-policy-designer`, `migration-plan-builder`, `index-strategy-planner`, `supabase-schema-bootstrap`. Added `hooks/` (new), `agents/db-reviewer.md`, `commands/db-bootstrap.md`, `scripts/schema-introspect.sh` (Supabase MCP wrapper).
- **`utilities/utilities`** bumped v2.0.0 → **v2.1.0**. Added 5 skills: `changelog-generator`, `pr-description-writer`, `env-var-auditor`, `doc-link-validator`, `repo-snapshot`. Added `scripts/git-history-digest.sh` and `scripts/link-check.py` (stdlib only).

### Conventions

All new skills follow the canonical structure (SKILL.md + LICENSE.txt + templates/output-template.md + examples/example-output.md, with reference.md where dense lookup material applies). Australian English throughout; AUD + metric units in lifestyle skills; AU super / Centrelink / ASIC / TGA context where relevant. Each plugin ships standard Stop hook `suggest-related.sh` and (where applicable) a setup `commands/` directory.

## [2.7.0] - 2026-05-20

### Changed
- **BREAKING — `knowledge-engineering` plugin removed** (v1.0.3). Its four skills were re-homed to the plugins whose scope they actually match:
  - `entity-disambiguation` → **`seo/seo-toolkit`** (skill is fundamentally about Schema.org `sameAs` mappings and search-engine entity graphs).
  - `entity-relationship-mapper` → **`seo/seo-toolkit`** (produces JSON-LD `@graph` with stable `@id` conventions for Google / Bing / ChatGPT / Perplexity consumption).
  - `knowledge-graph-builder` → **`seo/seo-toolkit`** (designs for search engines + AI systems as primary consumers; outputs Schema.org-typed nodes + JSON-LD).
  - `business-data-model-designer` → **`engineering/database-design`** (pure Postgres/Supabase schema design — ERD, migrations, RLS, indexes, triggers; pairs naturally with `postgres-schema-audit`).
- `seo-toolkit` bumped v1.0.0 → **v1.1.0** (20 skills now).
- `database-design` bumped v1.1.1 → **v1.2.0** (2 skills now).
- `.virustotal/knowledge-engineering.json` removed; per-skill VirusTotal entries re-attach to the new plugin envelopes on next scan.
- Total plugin count: 14 → 13. The `data-science` category now contains only `data-analysis`.

### Migration

Users who had `knowledge-engineering` installed should switch to the new plugin homes:

```bash
/plugin uninstall knowledge-engineering@anthril-claude-plugins
/plugin marketplace update anthril-claude-plugins
/plugin install seo-toolkit@anthril-claude-plugins     # for entity / KG / Schema.org skills
/plugin install database-design@anthril-claude-plugins # for business-data-model-designer
```

All four skill names and slash commands are unchanged — only the plugin envelope moved.

## [2.6.0] - 2026-05-20

### Changed
- **BREAKING — plugin rename: `skillops` → `skill-ops`** (v1.3.0 → v2.0.0). Brings the plugin into kebab-case alignment with every other plugin in the marketplace. Directory moved from `utilities/skillops/` to `utilities/skill-ops/`. Marketplace install command becomes `/plugin install skill-ops@anthril-claude-plugins`. All four contained skills (`skill-creator`, `skill-evaluator`, `skill-eval-harness`, `skill-eval-bootstrap`) keep their names and slash commands; only the plugin envelope was renamed.
- **BREAKING — plugin rename: `plan-completion-audit` → `utilities`** (v1.0.3 → v2.0.0). Refactored from a single-skill plugin into a generic utilities plugin that can host future cross-cutting helper skills. Directory moved from `utilities/plan-completion-audit/` to `utilities/utilities/`. The `plan-completion-audit` skill itself is unchanged (still at `skills/plan-completion-audit/`, still invoked as `/plan-completion-audit`). Marketplace install command becomes `/plugin install utilities@anthril-claude-plugins`.
- `.virustotal/skillops.json` → `.virustotal/skill-ops.json`; `.virustotal/plan-completion-audit.json` → `.virustotal/utilities.json`.
- Updated all in-repo references (README, SECURITY summary table, welcome hook narrative, example artefacts in `skill-ops/skills/*/examples/`, resolver script message strings).

### Migration

Users with the old plugin names installed need to re-install under the new names:

```bash
/plugin uninstall skillops@anthril-claude-plugins
/plugin uninstall plan-completion-audit@anthril-claude-plugins
/plugin marketplace update anthril-claude-plugins
/plugin install skill-ops@anthril-claude-plugins
/plugin install utilities@anthril-claude-plugins
```

## [2.5.0] - 2026-05-20

### Added
- **`seo-toolkit`** (new plugin, new `seo` category) — 17 skills for end-to-end SEO: keyword-research, keyword-list-developer, keyword-clustering-and-mapping (wraps the external `keyword-clustering` package), serp-analysis, competitor-seo-audit, on-page-audit, technical-seo-audit, core-web-vitals-report, backlink-audit, content-gap-analysis, content-brief-generator, internal-linking-planner, schema-markup-generator, gsc-performance-report, local-seo-audit, redirect-map-builder, broken-link-scanner. Includes 3 sub-agents (seo-auditor, serp-analyst, content-strategist), 3 slash commands (seo-connect/seo-status/seo-disconnect), encrypted Fernet vault for SerpAPI/DataForSEO/Ahrefs/Moz/PSI/GSC/GA4 credentials, SessionStart + Stop hooks, and supporting Python scripts.
- **`business-operations`** (new plugin, `smb` category) — 5 skills: revenue-channel-mapper, kpi-framework-generator, stakeholder-brief-builder, operational-bottleneck-detector, pricing-strategy-analyser. Pure reasoning skills, no external APIs.

## [2.4.0] - 2026-05-20

### Added
- **First fleet-wide LLM-as-judge run** — every skill in the marketplace evaluated end-to-end against its `evals/suite.yaml`. One Agent per skill (general-purpose, fresh context) performed activation classification (5 cases) plus a functional judge against the skill's example artefact. Aggregate report at `.anthril/audits/2026-05-20/judge/fleet-judge.md` and JSON sidecar `fleet-judge.json`. Per-skill raw verdicts at `.anthril/audits/2026-05-20/judge/results/<skill>.json`.
- `skill-eval-bootstrap/scripts/tune-criteria.mjs` — programmatic criteria tuner; derives skill-specific judge criteria from each SKILL.md's description, Output Format block, and templates/. Run across all 67 suites — 65 changed, 2 had no functional case.
- `skill-eval-harness/templates/activation-prompt-template.md` — canonical activation classifier prompt. Used by Phase 2 in `--mode=full` (default); `check-activation.sh` keyword-overlap proxy stays as `--mode=fast` fallback.
- `skill-eval-harness/scripts/build-judge-prompt.mjs` — renders a per-skill judge prompt bundling activation + functional judge into one Agent task.
- `skill-eval-harness/scripts/aggregate-fleet.mjs` — collates per-skill judge JSONs into the fleet report.

### Changed
- Harness SKILL.md Phase 2 activation step now invokes Agent against the new prompt template by default; `check-activation.sh` documented as the fast-mode fallback.

### Fleet judge results

- **Activation:** 335/335 pass across all skills (100%). The Agent-based classifier confirms the bootstrapped activation cases work as intended.
- **Functional judge:** 29 pass · 36 partial · 0 fail · 2 skipped (no example artefact). The 2 skipped are the skills added in this branch (`skill-eval-harness`, `skill-eval-bootstrap`); neither has an `examples/` directory yet.

### Criterion phrasing fix

Initial judge run produced 2 false-negative fails (`application-audit`, `plan-orchestrator`) — both artefacts use technical vocabulary that exposes neither AusE-distinctive nor US-distinctive spellings, so the judge could not verify the original "Australian English used throughout the narrative (colour, optimise, behaviour, organise)" criterion was met. The criterion was inverted to "No American spellings present in the narrative (color, optimize, behavior, organize, center, defense, license as a verb, analyze) — Australian or neutral forms both pass". Patched across all 65 suites that carry the criterion; `tune-criteria.mjs` updated for future bootstraps. Re-judged the 2 affected skills — both flipped to pass.

## [2.3.0] - 2026-05-20

### Added
- **skillops** plugin v1.3.0 — two new skills implementing the evaluation+iteration framework from [Anthropic best practices — evaluation & iteration](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices#evaluation-and-iteration) and [develop-tests guide](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests):
  - `skill-eval-harness` — run an `evals/suite.yaml` against a skill (activation tests, functional tests, edge cases, regression diff vs prior run). Produces a markdown run report + JSON sidecar in cwd and appends a row to the skill's `evals/iteration-log.md`. LLM-as-judge runs in a fresh subagent context for independence; `--mode=fast` skips it.
  - `skill-eval-bootstrap` — scaffold a starter `evals/suite.yaml` from a skill's description, examples, and emitted error codes. Generates ≥ 7 cases (3 activation-positive, 2 activation-negative, 0–1 functional, 2 edge) and an empty iteration log. Refuses to overwrite an existing suite without `--force`.
- Per-skill `evals/suite.yaml` and `evals/iteration-log.md` for every skill in the marketplace (65 suites generated by `skill-eval-bootstrap`).

## [2.2.0] - 2026-05-20

### Changed
- **Mechanical anti-pattern sweep across all 65 skills.** Stripped unused tool tokens (`Agent`, `WebFetch`, `WebSearch`) from `allowed-tools` frontmatter in 17 skills, applying the principle of least privilege per check C45. Affected plugins bumped to patch releases: `brand-manager` 1.0.2, `devops` 1.0.2, `package-manager` 1.1.2, `data-analysis` 1.0.3, `knowledge-engineering` 1.0.3, `business-economics` 1.0.3, `plan-completion-audit` 1.0.3.
- **plan-completion-audit** v1.0.3 — extracted Phase 10 (Supabase) and Phase 11 (frontend↔backend) dense content into pointers; added a `reference.md` index. SKILL.md dropped from 361 → 317 lines to satisfy the skills-architecture cap (check C44). Existing `references/supabase-audit-guide.md` is now the canonical source for that material.
- Refined `skill-evaluator`'s C45 detector to exempt skills launched via `agent:` / `context: fork` frontmatter, which legitimately need `Agent` in `allowed-tools` even when the body does not reference it by name.

### Added
- `.anthril/audits/2026-05-20/summary.md` — first sweep using the upgraded 10-dimension rubric. Zero anti-pattern findings remain across the marketplace.

## [2.1.0] - 2026-05-20

### Added
- **skillops** plugin v1.2.0 — extended `skill-evaluator` with two new rubric dimensions:
  - **Dimension 9 — Activation & Behavioural Quality** (10 pts): five checkpoints (C36–C40) covering activation-trigger boundedness, self-containment, side-effect discipline, instruction-following clarity, and example realism. Encodes the canonical five evaluation questions (does the skill fire for the right queries, work in isolation, leave other skills alone, get followed accurately, produce useful results).
  - **Dimension 10 — Anti-patterns** (5 pts): five checkpoints (C41–C45) covering option-overload, script error-handling, hook-schema compliance (per code.claude.com/docs/en/hooks), skills-architecture compliance (per platform.claude.com/docs/en/agents-and-tools/agent-skills), and `allowed-tools` minimality.
- `scripts/check-antipatterns.sh` — emits C41–C45 findings as a JSON array; covers AskUserQuestion option counts, `set -e` enforcement, hook absolute-path / missing-matcher / missing-timeout detection, SKILL.md size cap, and unused-tool detection.
- Findings-schema and output-template updated for 10 dimensions; total score raised from 100 → 115 (85 deterministic + 30 qualitative). Grade boundaries scaled: A ≥ 104, B 86–103, C 69–85, D 52–68, F < 52.

## [2.0.0] - 2026-05-20

### Changed
- **BREAKING — repository restructure.** Plugins moved out of `plugins/<name>/` into top-level category directories: `lifestyle/`, `smb/`, `marketing/`, `engineering/`, `data-science/`, `economics/`, `utilities/`. Every `source` path in `.claude-plugin/marketplace.json` was rewritten accordingly, and every `category` field updated to the new 7-bucket taxonomy.
  - `smb/brand-manager`
  - `marketing/ppc-manager`
  - `engineering/{software-development,devops,database-design,package-manager}`
  - `data-science/{data-analysis,knowledge-engineering}`
  - `economics/business-economics`
  - `utilities/{skillops,resource-manager,plan-completion-audit}`
- Plugin manifests, hooks, README references, and audit scripts updated to walk the new layout.

### Added
- `lifestyle/` placeholder category for future personal-productivity plugins.

### Migration
Users with previously installed plugins should run `/plugin marketplace update anthril` followed by `/plugin update` to pick up the new `source` paths.

## [1.6.0] - 2026-04-25

### Added
- **software-development** plugin v1.1.0 — new `plan-orchestrator` skill for Claude Code Plan Mode
  - Multi-agent parallel orchestration across eight specialist investigator agents (backend, frontend, database, infrastructure, testing, security, documentation) plus a coverage-sweeper that verifies every task is covered before plan compilation
  - Plugin-level `Stop` hook that runs the orchestrator's stop-hook after a plan is compiled
  - Plan and tasks JSON Schemas, plus markdown templates for plan output and agent-report output
  - Helper scripts (Python and Bash): `classify-tasks.py`, `compile-plan.py`, `detect-stack.sh`, `parse-bullets.py`, `stop-hook.sh`, `verify-coverage.py`
- `## Updating` section in `README.md` documenting the two-step `/plugin marketplace update` + `/plugin update` flow, since Claude Code does not auto-refresh marketplaces
- `.claude/hooks/changelog-reminder.sh` + `.claude/settings.json` — PostToolUse hook that blocks Claude from finishing edits to a `plugin.json` or `marketplace.json` without a corresponding `CHANGELOG.md` update

### Changed
- `software-development` marketplace description updated to reflect the third skill (now: dead code detection, write path mapping, plan orchestration)

## [1.5.0] - 2026-04-22

### Added
- **skillops** plugin v1.1.0 — renamed from `skill-creator` (signals broader scope beyond scaffolding)
  - `skill-evaluator` skill — audits any Claude Code skill against an eight-dimension rubric (Discovery & Metadata, Scope & Focus, Conciseness, Information Architecture, Content Quality, Tool & Security, Testing & Examples, Standards Compliance) with 35 deterministic heuristic checks plus an optional qualitative sub-agent review; produces a scored markdown report with file:line evidence, prioritised fix list, and JSON sidecar for CI use
- `.github/workflows/virustotal-audit.yml` + `scripts/virustotal-audit.mjs` — weekly VirusTotal scan of each plugin tarball with hash-first dedup and 20s rate-limit headroom for the public-API 4 req/min cap
- `SECURITY.md` — repo security policy + auto-updated VirusTotal summary table
- `plugins/<name>/VIRUSTOTAL.md` — per-plugin VirusTotal report (generated on first workflow run)
- `.virustotal/<name>.json` — machine-readable scan sidecars

### Changed
- `plugins/skill-creator/` → `plugins/skillops/`; slash command `/skill-creator` preserved (the `skill-creator` skill retained its name); marketplace entry and install command updated to `skillops@anthril-claude-plugins`
- Extended `plugins/skillops/hooks/scripts/post-edit-skill.sh` to delegate YAML parse validation to `skill-evaluator/scripts/parse-frontmatter.sh` and suggest `/skill-evaluator` for full audits

## [1.4.0] - 2026-04-21

### Added
- **devops** plugin v1.0.0 — 9 skills for DevOps and SRE posture audit across CI/CD, IaC, containers, Kubernetes, observability, release readiness, supply chain, and reliability
  - `devops-needs-assessment` — plain-language triage for non-experts, scoring nine dimensions on a four-point scale
  - `cicd-pipeline-audit` — GitHub Actions, GitLab CI, CircleCI, Azure Pipelines, Jenkins, Bitbucket; parallel sub-agent per workflow
  - `iac-terraform-audit` — Terraform, OpenTofu, Terragrunt, Pulumi; parallel sub-agent per module
  - `container-audit` — Dockerfiles and docker-compose; parallel sub-agent per Dockerfile
  - `kubernetes-manifest-audit` — CIS Kubernetes Benchmark + NSA/CISA hardening; sub-agent per chart or manifest group
  - `observability-audit` — four-pillar score across logs, metrics, traces, alerts/dashboards
  - `release-readiness-audit` — pre-production go/no-go gate with migration safety, rollback, deploy strategy
  - `devsecops-supply-chain-audit` — per-ecosystem supply-chain posture with SLSA self-assessment
  - `sre-reliability-audit` — SLOs, runbooks, on-call, postmortems, game days
- Three operating modes across all DevOps skills: static-file audit (default), `--live` (uses `gh`, `kubectl`, `terraform`, cloud CLIs, Trivy/Grype, Prometheus/Grafana/Datadog read APIs, PagerDuty/Opsgenie), and `--apply` (opt-in remediation with per-change confirmation and `DESTROY` gate on destructive operations)
- `--runtime` mode for synthetic alerts, canary smoke tests, chaos experiments, and game-day exercises — with a production-name guard requiring `--i-really-mean-prod` on prod-like targets

### Changed
- **package-manager** plugin v1.1.0 — renamed from `npm-package-audit`; added new `cli-ux-audit` skill that reviews terminal UX (help text, command structure, error messages, output formatting, discoverability, accessibility) and produces a scored report with actionable fixes

## [1.3.0] - 2026-04-20

### Added
- **database-design** plugin v1.1.0 — `postgres-schema-audit` skill
  - Dual connection modes: Supabase MCP or direct Postgres (works with RDS, Cloud SQL, Neon, Railway, self-hosted, local)
  - Parallel per-schema sub-agents across ten audit categories (Keys & Relationships, Data Types, Constraints & Defaults, Arrays & JSONB, Indexes, Triggers & RPC, RLS, Naming, Timestamps, Orphans)
  - Produces markdown report, JSON sidecar, Mermaid ER diagram, and a draft `migrations-suggested.sql` file
  - Interactive setup wizard reads credentials via silent input outside the chat; credentials never touch the conversation transcript
  - All queries SELECT-only, wrapped in `BEGIN TRANSACTION READ ONLY; ... ROLLBACK;` — skill never writes to the database
- `scripts/check-versions.mjs` — CI helper that verifies per-plugin `plugin.json` versions match the `marketplace.json` catalogue

## [1.2.0] - 2026-04-12

### Added
- **ppc-manager** plugin v1.0.1 — 22 skills for end-to-end PPC campaign management across Google Ads, Meta Ads, GA4, and GTM
  - OAuth-authenticated read/write across all four platforms via bundled Python MCP servers
  - Campaign build, audit, copywriting, audience building, creative briefs, UTM tracking, and landing page copy
  - GTM data layer, tag, and trigger configuration; GA4 event mapping; Meta Pixel and CAPI setup
- **brand-manager** plugin v1.0.0 — 9 skills for end-to-end brand creation (identity, guidelines, audience, competitors, logo brief, colour palette, design tokens, legal disclaimers, website copy)
- **software-development** plugin v1.0.0 — `dead-code-audit` (9 languages: JS/TS, Python, Go, Rust, Java, PHP, Ruby, C#) and `write-path-mapping` (UI → DB with framework and database introspection)

### Changed
- Rebranded marketplace from previous namespace to `Anthril` across all plugins, manifests, hooks, and documentation
- Removed redundant metadata from `plugin.json` files (version moved to single source of truth per plugin)
- Updated `.mcp.json` and marketplace schema to the current plugin-marketplace specification

## [1.1.0] - 2026-04-08

### Added
- **plan-completion-audit** plugin v1.0.1 — full-stack audit of a project plan versus actual implementation; verifies plan vs code, types, bugs, security, Supabase schema, RLS, frontend-backend alignment
- **npm-package-audit** plugin v1.0.0 (later renamed to `package-manager` in 1.4.0) — audits npm packages for publishing quality, cross-OS compatibility, type declarations, build config, security, and CI/CD
- **skill-creator** plugin v1.0.1 — scaffolds new Claude Code skills with proper frontmatter, directory structure, templates, examples, and supporting files
- Categorised sub-marketplaces under `.claude-plugin/marketplace.json`
- Restructured repository into standalone per-plugin directories under `plugins/<plugin-name>/`

### Changed
- Bumped plugin versions across the board
- Removed SessionStart hooks in favour of per-skill Stop hooks that suggest related skills
- Normalised shebangs across helper scripts (`#!/usr/bin/env bash`, `#!/usr/bin/env python3`)
- Aligned plugin manifests with the current plugin-marketplace schema

### Fixed
- Marketplace install compatibility and skill loading on fresh installs
- Removed conflicting root `settings.json` and `.claude/` directory that blocked marketplace detection
- Plugin-prefix renames for consistency across all plugins

## [1.0.0] - 2026-04-04

### Added
- Initial marketplace release — transformed `ai-cookbook` repo into a fully-featured Claude Code plugin
- Skills collection, sponsors documentation, and GitHub Actions workflow
- `.claude-plugin/plugin.json` manifest per plugin with `skills` and `hooks` component paths
- `.claude-plugin/marketplace.json` catalogue with `repository` and `homepage` fields
- Per-plugin hooks (SessionStart welcome, Stop suggestions, PreToolUse/PostToolUse validation)
- **data-analysis** plugin — anomaly-detection-rule-builder, cohort-analysis-builder, data-dictionary-generator, data-pipeline-architecture, dataset-profiling-quality-audit
- **knowledge-engineering** plugin — business-data-model-designer, entity-disambiguation, entity-relationship-mapper, knowledge-graph-builder
- **business-economics** plugin — market-sizing-tam-estimator, unit-economics-calculator
- Example outputs and output templates for every skill
- Helper scripts (Python and Bash) for skill validation and computation
- MIT license

> **Note:** The previous 1.0.0 entry was dated 2025-05-20; the actual initial-release commit was 2026-04-04. Plan-completion-audit, npm-package-audit, and skill-creator are now correctly listed under 1.1.0 (2026-04-08) when they were introduced.
