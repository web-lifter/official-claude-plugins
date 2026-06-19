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
## Latest scan — 2026-06-08

| Plugin | Detections | Last scan | Report |
|---|---:|---|---|
| brand-manager | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/29ee2b1ab71094657ce5408954db5f5739ea706dec635fad68567034990efbfa) |
| business-economics | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/21ce69c781bfdff5a951fb1d9a978c46bea738d4f7880d2b3b476e5ea15147cf) |
| data-analysis | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/cb29b6fe5071e8c14663f6e5798031df07a8084c5c857a87e218ff106b690ed9) |
| database-design | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/00e061fd7ef10305bc94885cefff21bfe655e951647d89a432bf48745a4fe7d5) |
| devops | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/a5f7dd5bc718b616dce2728101d8565bc3dcfebe4d1a7bc45503a7ebeb886db8) |
| experimentation | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/af56e87aaf783030f7aa0e339f62ff17d6d5b6dd383af070efe3935745a6143e) |
| health-wellness | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/f18aa963d5f22c0ae472e2db8104de41e8f8bf6fcc0da94e76f04ce87f508d05) |
| home-life-logistics | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/d429f02ae20ac24046f4ee200f3305eff21d3a563768517f116202ba08a6a591) |
| personal-productivity | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/b67e3c38d55d457c1a543b522d3a01ba40f48ddda1ec076752afdb0112c486fe) |
| plan-review | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/278551a9f671ad350503a293605c21dcb938f204f701c195842b45c0863ae944) |
| ppc-manager | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/b691857d5252dd0e21776642e174516caccf271cdba0897e8c466810aacdbaf5) |
| programming-utilities | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/c9de3979623cee9d155900fb3c9e2b2e05194af460a4363149f716f39de7dfa0) |
| seo-toolkit | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/eb44ed472e3c4468ea26ad3fd07616b8cf01b32072c81953d729949346cd1e05) |
| software-development | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/3dbf17cb6167c526887c002bec7be2b744df1ee3cab21834b76277e1ad115de6) |
| strategic-economics | 0 / 75 | 2026-06-08 | [report](https://www.virustotal.com/gui/file/9304b2f529afb8a35429dd3967b2bfe4c739ff63424b287cf3c2f1c98b77b960) |
<!-- vt-summary:end -->
