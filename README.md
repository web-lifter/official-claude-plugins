# Web Lifter Official Claude Plugins

Two curated Claude Code marketplaces in one repository — **business** and **lifestyle**.

**9 plugins · 139 skills · Australian English throughout · evidence-backed markdown outputs.**

| Marketplace | Folder | Plugins | Catalogue |
|---|---|---|---|
| `official-business-plugins` | [`official-business-plugins/`](official-business-plugins/) | 5 | [marketplace.json](official-business-plugins/.claude-plugin/marketplace.json) |
| `official-lifestyle-plugins` | [`official-lifestyle-plugins/`](official-lifestyle-plugins/) | 4 | [marketplace.json](official-lifestyle-plugins/.claude-plugin/marketplace.json) |

Engineering-lifecycle tooling lives in the separate [John OS marketplace](https://github.com/johnoconnor0/johns-os); all marketplaces write to the shared `.project/` workspace (see [`OUTPUT-CONVENTIONS.md`](OUTPUT-CONVENTIONS.md)).

Maintained by [Web Lifter](https://github.com/web-lifter).

## Quick Start

Each marketplace is a folder with its own `.claude-plugin/marketplace.json`, so you add them independently.

```bash
# Clone once, then add whichever marketplaces you want by local path:
git clone https://github.com/web-lifter/official-claude-plugins
/plugin marketplace add ./official-claude-plugins/official-business-plugins
/plugin marketplace add ./official-claude-plugins/official-lifestyle-plugins

# Install plugins — the @suffix is the marketplace name:
/plugin install marketing@official-business-plugins
/plugin install startups@official-business-plugins
/plugin install data-science@official-business-plugins
/plugin install personal-finance@official-lifestyle-plugins
```

> This repo is a **monorepo with no root marketplace** — the two manifests live one level down, so `/plugin marketplace add web-lifter/official-claude-plugins` (repo-root form) does **not** resolve. `/plugin marketplace add` accepts a GitHub repo, a git URL, or a local path, but not a remote subdirectory — so either clone and add by local path (above), or register a marketplace **without cloning** by adding an `extraKnownMarketplaces` entry to your Claude settings with a git `source` and `sparsePaths` scoped to the folder:
>
> ```jsonc
> "extraKnownMarketplaces": {
>   "official-business-plugins": {
>     "source": {
>       "source": "git",
>       "url": "https://github.com/web-lifter/official-claude-plugins.git",
>       "sparsePaths": ["official-business-plugins/.claude-plugin"]
>     }
>   }
> }
> ```

### Test Locally

```bash
# Load a single plugin (path is the marketplace source)
claude --plugin-dir ./official-business-plugins/marketing

# List available skills
/skills
```

### Updating

Claude Code does **not** auto-refresh marketplaces — it reads from a local cache re-fetched on demand. To pick up a new release:

```bash
/plugin marketplace update official-business-plugins
/plugin update marketing@official-business-plugins
```

See [`CHANGELOG.md`](CHANGELOG.md) for what changed in each release.

---

## Repository Structure

```
official-claude-plugins/
├── official-business-plugins/
│   ├── .claude-plugin/marketplace.json   # Business marketplace catalogue (5 plugins)
│   ├── business-operations/              # 5 SMB operations skills
│   ├── data-science/                     # 9 data-science skills
│   ├── economics/                        # 9 economics skills
│   ├── marketing/                        # 28 brand + SEO skills (bundled Python tooling)
│   └── startups/                         # 70 venture-building skills + 9 orchestrator agents
├── official-lifestyle-plugins/
│   ├── .claude-plugin/marketplace.json   # Lifestyle marketplace catalogue (4 plugins)
│   ├── health-wellness/                  # 5 wellness skills (AU-context)
│   ├── home-life-logistics/              # Trip + household + life-admin + gifting
│   ├── personal-finance/                 # AU budget / debt / FIRE / projections
│   └── personal-productivity/            # Habits, reset, deep-focus, energy mapping
├── scripts/                              # check-versions, check-validate, check-version-bumps
├── tests/                                # Python smoke tests for embedded scripts
├── .project/                             # Shared output workspace (audits, plans, reports)
├── CHANGELOG.md
├── SECURITY.md
├── OUTPUT-CONVENTIONS.md                 # `.project/<type>/` output scheme
├── LICENSE                               # MIT
└── README.md                            # this file
```

### Plugin layout

```
<marketplace>/<plugin>/
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/<skill>/                # SKILL.md + templates/ + examples/ + evals/
├── agents/                        # Plugin-level sub-agents (where applicable)
├── commands/                      # Slash commands (where applicable)
├── hooks/                         # Lifecycle hooks (where applicable)
├── settings.json
└── README.md
```

---

## Business marketplace (`official-business-plugins`)

| Plugin | Skills | Summary |
|---|---:|---|
| [`business-operations`](official-business-plugins/business-operations/) | 5 | Revenue channel mapping, KPI frameworks, stakeholder briefs, bottleneck detection, pricing strategy |
| [`data-science`](official-business-plugins/data-science/) | 9 | Dataset profiling & quality audit, data dictionaries, pipeline architecture, cohort analysis, anomaly detection, A/B test design, experiment readouts, forecasting, causal-impact analysis |
| [`economics`](official-business-plugins/economics/) | 9 | Unit economics (CAC/LTV), market sizing (TAM/SAM/SOM), pricing architecture, cost structure, break-even, cost-benefit, competitive dynamics, elasticity, moat-strength audit |
| [`marketing`](official-business-plugins/marketing/) | 28 | End-to-end brand creation (identity, guidelines, audience, logo, colour, design tokens, disclaimers, copy) + end-to-end SEO (keyword research + clustering, SERP & competitor analysis, on-page/technical/CWV audits, backlinks, content briefs, schema + entity modelling, local SEO) |
| [`startups`](official-business-plugins/startups/) | 70 | Full venture workflow — venture chassis, customer discovery, value-proposition & business-model canvases, competitor analysis, relationships & channels, prototyping, MVP planning + engineering bridge, Lean-Startup experimentation. Ships 9 orchestrator agents. |

## Lifestyle marketplace (`official-lifestyle-plugins`)

| Plugin | Skills | Summary |
|---|---:|---|
| [`health-wellness`](official-lifestyle-plugins/health-wellness/) | 5 | Meal planning, training programs, sleep, supplements, daily wellness — evidence-rated, AU-context |
| [`home-life-logistics`](official-lifestyle-plugins/home-life-logistics/) | 4 | Trip planning, household maintenance, life-admin, gifting |
| [`personal-finance`](official-lifestyle-plugins/personal-finance/) | 5 | AU budgeting, debt payoff, savings rate, retirement projection, emergency runbooks |
| [`personal-productivity`](official-lifestyle-plugins/personal-productivity/) | 4 | Habits, weekly resets, deep-focus days, energy mapping |

---

## Skill features

Every skill includes:

- **YAML frontmatter** — `name`, `description`, `argument-hint`, `allowed-tools`, `effort`
- **`$ARGUMENTS`** — direct user input
- **Output templates** under `templates/`
- **Example outputs** under `examples/`
- **Eval suite** under `evals/suite.yaml` (≥ 3 activation-positive, ≥ 2 activation-negative, ≥ 2 edge)

Select skills also include `context: fork`, `paths` auto-activation, dense `reference.md`, and parallel sub-agents.

## Validation

Before submitting changes:

```bash
node scripts/check-versions.mjs    # marketplace ↔ plugin.json version sync (both marketplaces)
node scripts/check-validate.mjs    # delegates to `claude plugin validate` (both marketplaces)
```

Both checks must pass green. See [`.claude/CLAUDE.md`](.claude/CLAUDE.md) for detailed development standards.

## License

MIT
