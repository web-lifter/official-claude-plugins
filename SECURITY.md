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
## Latest scan — 2026-05-25

| Plugin | Detections | Last scan | Report |
|---|---:|---|---|
| brand-manager | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/78d27c40b7efe5af6a393d3021150717811c102ebd19ab4d8dd89520489916b8) |
| database-design | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/4a8badf8e8bde2aca007667ed8aa58af5b5d56202eb9f4d5f32e5f9789fe5424) |
| devops | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/26e3c2267a7654f199cf9cc8403ffc17b362c5e39b2dbfcc587fc4ef2bd1c966) |
| health-wellness | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/44bd71cdb565600b0b6dcf1f6ec3d7975e7be043dc205f9071576d1d3e58c9ca) |
| package-manager | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/7566af3ce32f5a71a0bbe8eb0f58817cff8c0c8d7ece1626e45d5a4680bc39f4) |
| personal-productivity | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/f828f6dea935bdab0942defdc45a535b87bca89723bc15b60913d346775d9ab8) |
| plan-review | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/a5da82e8caf97d1681d2149f162c13d10332d2045c09c433ee79833f25a03afc) |
| programming-utilities | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/a6919ee24b038cc8a12a8a89321514a6afbec1c6c16a43e54f89aaa20968d927) |
| skill-ops-claude | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/6cb7d0bbc163b951d07b0fdc32d2e3a1f8c235ffdfda564e9cacf7d9973cb08f) |
| software-development | 0 / 75 | 2026-05-25 | [report](https://www.virustotal.com/gui/file/9d8f6c9917a9b5fc970fa1cfc5b5d4af4a76d762362554fdaa66f9a00ad108db) |
<!-- vt-summary:end -->
