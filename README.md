# Web Lifter Official Claude Plugins

A curated library of Claude Code plugins, organised into three customer-facing roots and packaged as a Claude Code marketplace.

**29 catalogued plugins · 200+ production-ready skills · Australian English throughout · evidence-backed markdown outputs.**

The marketplace catalogue ([`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json)) covers everything under:

- [`ai-utility-plugins/`](ai-utility-plugins/) — 3 plugins
- [`official-business-plugins/`](official-business-plugins/) — 22 plugins
- [`official-lifestyle-plugins/`](official-lifestyle-plugins/) — 4 plugins

Engineering lifecycle tooling lives in the separate [John OS marketplace](https://github.com/johnoconnor0/johns-os); both marketplaces write to the shared `.project/` workspace (see [`OUTPUT-CONVENTIONS.md`](OUTPUT-CONVENTIONS.md)).

Maintained by [Web Lifter](https://github.com/web-lifter).

## Quick Start

### Install as Marketplace

```bash
# Add the marketplace
/plugin marketplace add web-lifter/official-claude-plugins

# Install a plugin (examples)
/plugin install software-development@web-lifter-plugins
/plugin install devops@web-lifter-plugins
/plugin install seo-toolkit@web-lifter-plugins
/plugin install venture-core@web-lifter-plugins
/plugin install brand-manager@web-lifter-plugins
/plugin install personal-finance@web-lifter-plugins
```

A full list of installable plugin names lives in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).

### Test Locally

```bash
# Load the full marketplace for development
claude --plugin-dir .

# Load a single plugin (path is the marketplace `source`)
claude --plugin-dir ./official-business-plugins/engineering/software-development

# List available skills
/skills
```

### Updating

Claude Code does **not** auto-refresh marketplaces — it reads from a local cache (`~/.claude/plugins/marketplaces/<name>/`) re-fetched on demand. To pick up a new release:

```bash
/plugin marketplace update web-lifter-plugins
/plugin update software-development@web-lifter-plugins
```

See [`CHANGELOG.md`](CHANGELOG.md) for what changed in each release.

---

## Repository Structure

```
official-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json           # Catalogue — 29 plugins
├── ai-utility-plugins/            # Cross-cutting AI / Claude Code helpers
│   ├── resource-manager/          # Monitor & reclaim Claude Code resources
│   ├── skill-ops/                 # skill-creator (scaffold new skills)
│   └── plan-review/               # plan-completion-audit + audit-resolver
├── official-business-plugins/
│   ├── data-science/              # data-analysis, experimentation
│   ├── economics/                 # business-economics, strategic-economics
│   ├── engineering/               # database-design, devops, package-manager,
│   │                              # software-development, utilities (repo-ops)
│   ├── general/                   # business-operations
│   ├── marketing/                 # brand-management, ppc-management, seo-toolkit
│   └── startups/                  # 9 Strategyzer/Lean Startup plugins
├── official-lifestyle-plugins/
│   ├── health-wellness/           # 5 wellness skills (AU-context)
│   ├── home-life-logistics/       # Trip + household + life-admin + gifting
│   ├── personal-finance/          # AU budget / debt / FIRE / projections
│   └── personal-productivity/     # Habits, reset, deep-focus, energy mapping
├── internal-utilities/            # NOT in marketplace — internal tooling (gitignored)
│   └── skill-ops/                 # evaluator + autonomous-iteration-loop
├── tests/                         # Python smoke tests for embedded scripts
├── scripts/                       # check-versions, check-validate, virustotal
├── .virustotal/                   # Per-plugin VirusTotal scan sidecars
├── .project/                      # Audit reports, output-map, judge fleet
├── CHANGELOG.md
├── SECURITY.md                    # VirusTotal policy + scan results
├── OUTPUT-CONVENTIONS.md          # `.project/<type>/` output scheme
├── LICENSE                        # MIT
└── README.md                      # this file
```

### Plugin layout

```
<plugin-root>/<plugin>/
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/<skill>/                # SKILL.md + templates/ + examples/ + evals/
├── agents/                        # Plugin-level sub-agents (where applicable)
├── commands/                      # Slash commands (where applicable)
├── hooks/                         # Lifecycle hooks (where applicable)
├── settings.json
└── README.md
```

---

## Plugins by Category

Click a plugin name to open its directory; the README inside each plugin lists every skill, agent, command, and hook it provides.

### AI / Claude Code utilities (`ai-utility-plugins/`)

| Plugin | Source | Summary |
|---|---|---|
| `resource-manager` | [ai-utility-plugins/resource-manager](ai-utility-plugins/resource-manager/) | Monitor and reclaim machine resources used by Claude Desktop, Claude Code, and MCP servers — orphan-killer hook, audit skills, localhost dashboard |
| `skill-ops-claude` | [ai-utility-plugins/skill-ops](ai-utility-plugins/skill-ops/) | `skill-creator` — scaffold new skills with frontmatter, templates, examples, supporting files |
| `plan-review` | [ai-utility-plugins/plan-review](ai-utility-plugins/plan-review/) | `plan-completion-audit` + `audit-resolver` — full-stack plan-vs-implementation audit, then close the loop with `/utilities:audit-resolve` |

### John OS — engineering lifecycle marketplace — *separate repo*

Structured engineering-lifecycle tooling (discovery → requirements → architecture → implementation → release, with review agents and an artifact ledger) lives in the separate [John OS marketplace](https://github.com/johnoconnor0/johns-os) (`/plugin marketplace add johnoconnor0/johns-os`). Its plugins write to `.project/.engineering/` and `.project/business-development/`, sharing the same `.project/` workspace root this marketplace outputs to — see [`OUTPUT-CONVENTIONS.md`](OUTPUT-CONVENTIONS.md) for the namespace contract.

### Data science (`official-business-plugins/data-science/`)

| Plugin | Source | Summary |
|---|---|---|
| `data-analysis` | [official-business-plugins/data-science/data-analysis](official-business-plugins/data-science/data-analysis/) | 5 skills — data profiling, quality auditing, pipeline design, cohort analysis, anomaly detection |
| `experimentation` | [official-business-plugins/data-science/experimentation](official-business-plugins/data-science/experimentation/) | 4 skills — A/B test design, experiment readouts, forecasting, causal-impact analysis |

### Economics (`official-business-plugins/economics/`)

| Plugin | Source | Summary |
|---|---|---|
| `business-economics` | [official-business-plugins/economics/business-economics](official-business-plugins/economics/business-economics/) | 6 skills — unit economics (CAC/LTV), market sizing (TAM/SAM/SOM), pricing, cost structure, break-even, cost-benefit |
| `strategic-economics` | [official-business-plugins/economics/strategic-economics](official-business-plugins/economics/strategic-economics/) | 3 skills — competitive dynamics, elasticity estimation, moat-strength audit |

### Engineering — domain plugins (`official-business-plugins/engineering/`)

| Plugin | Source | Summary |
|---|---|---|
| `database-design` | [official-business-plugins/engineering/database-design](official-business-plugins/engineering/database-design/) | 7 skills for Postgres / Supabase — schema design, RLS, migrations, indexes, ERDs, bootstrap, audit |
| `devops` | [official-business-plugins/engineering/devops](official-business-plugins/engineering/devops/) | 9 skills — needs assessment, CI/CD, IaC, containers, K8s, observability, release, supply chain, SRE. Three modes: static, `--live`, `--apply` |
| `package-manager` | [official-business-plugins/engineering/package-manager](official-business-plugins/engineering/package-manager/) | npm package publishing audit + CLI terminal UX audit |
| `software-development` | [official-business-plugins/engineering/software-development](official-business-plugins/engineering/software-development/) | Codebase profiler, dead-code detection across 9 languages, write-path mapping, multi-agent plan orchestration |
| `programming-utilities` | [official-business-plugins/engineering/programming-utilities](official-business-plugins/engineering/programming-utilities/) | 5 repo-ops helpers — changelog-generator, pr-description-writer, env-var-auditor, doc-link-validator, repo-snapshot |

### General / SMB (`official-business-plugins/general/`)

| Plugin | Source | Summary |
|---|---|---|
| `business-operations` | [official-business-plugins/business-operations](official-business-plugins/business-operations/) | 5 SMB ops skills — revenue channel mapping, KPI frameworks, stakeholder briefs, bottleneck detection, pricing strategy |

### Marketing (`official-business-plugins/marketing/`)

| Plugin | Source | Summary |
|---|---|---|
| `brand-manager` | [official-business-plugins/marketing/brand-management](official-business-plugins/marketing/brand-management/) | 9 brand-creation skills — identity, guidelines, audience, competitors, logo, colour, design tokens, disclaimers, copy |
| `ppc-manager` | [official-business-plugins/marketing/ppc-management](official-business-plugins/marketing/ppc-management/) | 23 skills for end-to-end PPC — Google Ads, Meta Ads, GA4, GTM — with OAuth read/write via bundled Python MCP servers |
| `seo-toolkit` | [official-business-plugins/marketing/seo-toolkit](official-business-plugins/marketing/seo-toolkit/) | 20 skills — keyword research + clustering, SERP & competitor analysis, on-page + technical + CWV + backlinks, content briefs, schema, GSC, local SEO, structured-data entity modelling |

### Startups (`official-business-plugins/startups/`)

Nine Strategyzer / Lean Startup plugins designed to compose with `venture-core`:

| Plugin | Source | Summary |
|---|---|---|
| `venture-core` | [official-business-plugins/startups/venture-core](official-business-plugins/startups/venture-core/) | Chassis — workspace scaffolding, status, phase routing, vision sketch, hypothesis register, pivot log, handoff brief |
| `customer-discovery` | [official-business-plugins/startups/customer-discovery](official-business-plugins/startups/customer-discovery/) | Segments, jobs/pains/gains, early-adopter targeting, interview guide + log, readiness gate before MVP |
| `value-proposition-canvas` | [official-business-plugins/startups/value-proposition-canvas](official-business-plugins/startups/value-proposition-canvas/) | Strategyzer VPC — value map, fit check, six ways to innovate, VPC versioning |
| `business-model-canvas` | [official-business-plugins/startups/business-model-canvas](official-business-plugins/startups/business-model-canvas/) | Strategyzer BMC — initial build, front/back-stage split, hypothesis updates, VPC linkage |
| `competitor-analysis` | [official-business-plugins/startups/competitor-analysis](official-business-plugins/startups/competitor-analysis/) | UVP, competitor discovery, table, SWOT, shadow BMC, synthesis |
| `relationships-channels` | [official-business-plugins/startups/relationships-channels](official-business-plugins/startups/relationships-channels/) | Get/keep/grow, channel selection, funnel model, churn `(1 − r)^n` |
| `prototyping` | [official-business-plugins/startups/prototyping](official-business-plugins/startups/prototyping/) | Ideation → 1–3 finalists, paper prototype, Figma-MCP handoff, feedback collection |
| `mvp-planning` | [official-business-plugins/startups/mvp-planning](official-business-plugins/startups/mvp-planning/) | MVP scope/type/metrics, tech-stack recommender, ADRs, API, Supabase RLS, Cloudflare/Vercel deploy, analytics, build plan, pitch |
| `venture-experimentation` | [official-business-plugins/startups/venture-experimentation](official-business-plugins/startups/venture-experimentation/) | Falsifiability gate, test cards, learning cards, experiment design + prioritisation |

### Lifestyle (`official-lifestyle-plugins/`)

| Plugin | Source | Summary |
|---|---|---|
| `health-wellness` | [official-lifestyle-plugins/health-wellness](official-lifestyle-plugins/health-wellness/) | Meal planning, training programs, sleep, supplements, daily wellness — evidence-rated, AU-context |
| `home-life-logistics` | [official-lifestyle-plugins/home-life-logistics](official-lifestyle-plugins/home-life-logistics/) | Trip planning, household maintenance, life-admin, gifting |
| `personal-finance` | [official-lifestyle-plugins/personal-finance](official-lifestyle-plugins/personal-finance/) | AU budgeting, debt payoff, savings rate, retirement projection, emergency runbooks |
| `personal-productivity` | [official-lifestyle-plugins/personal-productivity](official-lifestyle-plugins/personal-productivity/) | Habits, weekly resets, deep-focus days, energy mapping |

### Internal-only (not in marketplace)

| Plugin | Source | Note |
|---|---|---|
| `skill-ops` | [internal-utilities/skill-ops](internal-utilities/skill-ops/) | Skill / agent / hook / script evaluators + regression harness + autonomous-iteration-loop — internal |

---

## Skill features

Every skill includes:

- **YAML frontmatter** — `name`, `description`, `argument-hint`, `allowed-tools`, `effort`
- **`$ARGUMENTS`** — direct user input
- **Output templates** under `templates/`
- **Example outputs** under `examples/`
- **Eval suite** under `evals/suite.yaml` (≥ 3 activation-positive, ≥ 2 activation-negative, ≥ 2 edge)

Select skills also include `context: fork`, `paths` auto-activation, dense `reference.md`, dynamic context injection, and parallel sub-agents.

## Quality + Evaluation

- **Audit** — `/skill-evaluator <path>` (in `internal-utilities/skill-ops`) produces a scored markdown report + JSON sidecar across 8–10 dimensions.
- **Eval suites** — every skill has `evals/suite.yaml`.
- **Harness** — `/skill-eval-harness <skill>` runs the suite, dispatches LLM-as-judge in a fresh subagent context, and emits a markdown run report.

## Validation

Before submitting changes:

```bash
node scripts/check-versions.mjs    # marketplace ↔ plugin.json version sync
node scripts/check-validate.mjs    # delegates to `claude plugin validate`
```

Both checks must pass green.

## Contributing

1. Fork the repo
2. Add a new skill via `/skill-creator` (in `ai-utility-plugins/skill-ops`)
3. Place it under the right `<plugin-root>/<category>/<plugin>/skills/` directory
4. Generate a baseline eval suite with `/skill-eval-bootstrap <skill>`
5. Test locally with `claude --plugin-dir .`
6. Run `node scripts/check-versions.mjs && node scripts/check-validate.mjs`
7. Submit a PR

See [`.claude/CLAUDE.md`](.claude/CLAUDE.md) for detailed development standards.

## License

MIT
