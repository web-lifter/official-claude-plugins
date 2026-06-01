# Security Policy

## Scanning

Every plugin in this marketplace is packaged as a gzipped tarball and submitted to [VirusTotal](https://www.virustotal.com) for multi-engine antivirus scanning. Scans run automatically on:

- **Push to `main`** that touches anything under one of the plugin trees (`official-business-plugins/`, `official-lifestyle-plugins/`, `ai-utility-plugins/`, `anthril-os/`) — changed plugins only via path-scoped triggers
- **Weekly cron** — Monday at 14:00 UTC (full marketplace rescan)
- **Manual dispatch** via the Actions tab

### Strategy

- **One tarball per plugin** — each plugin directory (e.g. `official-business-plugins/<category>/<name>/`) is packaged and scanned as a single artefact.
- **Hash-first dedup** — we compute the SHA-256 locally and query VirusTotal by hash. Only previously-unseen tarballs are uploaded, which keeps us well within the public API's 4 req/min and 500 req/day limits.
- **Rate-limit headroom** — 20 seconds between API calls (4 req/min allowed; we use ~3 req/min worst-case).

### Reports

| Artefact | Location | Audience |
|---|---|---|
| Consolidated marketplace report | [`VIRUSTOTAL.md`](VIRUSTOTAL.md) (repo root) | Humans |
| Raw normalised JSON (per plugin) | `.anthril/virustotal/<name>.json` (gitignored — regenerated each run) | Tooling, CI consumers, shields.io endpoints |
| Marketplace-wide summary table | below this section | Humans |

### Privacy note

Files uploaded via the VirusTotal public API are shared with VT's AV-vendor partners and VT Intelligence subscribers per their [public API terms](https://developers.virustotal.com/reference/privacy-policy). This marketplace is fully public on GitHub, so the effective exposure is identical to what is already published in the repository. Do **not** add anything private, secret, or customer-identifying to any plugin — uploaded content is not recoverable from VT.

## Reporting a Vulnerability

If you discover a security issue in any plugin or in the marketplace tooling, please email **john@anthril.com** rather than opening a public issue. We will acknowledge receipt within 72 hours.

For dependency vulnerabilities surfaced by VirusTotal scans (non-zero detections in the table below), review the linked VT report first — false positives are common for gzipped shell-heavy archives. Confirmed true positives are treated as P0 and the affected plugin is delisted from `marketplace.json` pending remediation.

<!-- vt-summary:start -->
## Latest scan — 2026-06-01

| Plugin | Detections | Last scan | Report |
|---|---:|---|---|
| brand-manager | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/fb1e224350233a09de77f8e9b3fe79e8e67c6854359105c92e4f8ec35d92620e) |
| devops | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/b6aa32b27fabad4800739db1d97878ffee607b3fb0f999c56d525dba799ab718) |
| health-wellness | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/9aa54ee057de315e314499c75c8109ba87407c2612844b303e32e17b4c845aa9) |
| home-life-logistics | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/237e2167e2da04d81429b149425af7e513b93563f8f1844351c8a77462f508fa) |
| package-manager | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/e2027a342e88d31313f56ac03f9b2a74a954aa5288f5c58c9bdb95857842f276) |
| personal-finance | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/86fb249d81489fa5a3c160a0644e816b4b76069716b8dae17a39efc211313a97) |
| personal-productivity | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/b9bf9ad2606f430f80a4dca71ef3b85ed6044e264f44e416d87401b1e0e1ab75) |
| plan-review | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/757f8919f0d980ca4a3f8f8125af8e01510ae68b6c6c4e970510927c1dad8474) |
| programming-utilities | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/5b3e979713ba112c3f10967910b2394eb9c06ba2c90d8a09f7b146cbb0870ea2) |
| seo-toolkit | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/41747a1e64c0bc993536b2694345ccc5ad773d0a729b981bde29ccda81577fe2) |
| skill-ops-claude | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/7ef187337f157855a70417cd4e4c1f194c4dbe1472c669f86d420037567b226c) |
| software-development | 0 / 75 | 2026-06-01 | [report](https://www.virustotal.com/gui/file/0f295d8e888ec81d3d1a028320cbc36574eb20cf9343fe1281fbb5a604d0c837) |
<!-- vt-summary:end -->
