# Changelog

## [1.1.2] - 2026-06-02

### Fixed
- Credentials stored via `/seo-toolkit:seo-connect` could not be read back at runtime — every provider reported its key as missing. The vault passphrase was read from `SEO_VAULT_PASSPHRASE`, an environment variable nothing in the skill/command runtime ever set, while the documented `seo_vault_passphrase` plugin option was never declared.

### Added
- `seo_vault_passphrase` is now declared as a `userConfig` option, so Claude Code prompts for it at enable time, stores it in the OS keychain, and injects it into every plugin subprocess as `CLAUDE_PLUGIN_OPTION_SEO_VAULT_PASSPHRASE`.
- `resolve_passphrase()` helper in `seo_vault.py` — single source of truth that reads `CLAUDE_PLUGIN_OPTION_SEO_VAULT_PASSPHRASE`, falling back to `SEO_VAULT_PASSPHRASE` for hooks/tests/CI.

### Changed
- All provider clients (SerpAPI, DataForSEO, Ahrefs, Moz, GSC, GA4) and `token_validator.py` now resolve the passphrase via `resolve_passphrase()` instead of reading `SEO_VAULT_PASSPHRASE` directly.
- `token_validator.py` and the `seo_vault.py` CLI accept an optional `--passphrase` argument; commands now pass the passphrase explicitly rather than relying on environment propagation between processes.

## [1.0.0] - 2026-05-20

### Added
- Initial release. 17 skills covering keyword research + list development + clustering/mapping, SERP analysis, competitor + on-page + technical audits, Core Web Vitals, backlinks, content gap analysis, content briefs, internal-link planning, schema generation, GSC performance reporting, local SEO, redirect mapping, broken-link scanning.
- 3 sub-agents: `seo-auditor`, `serp-analyst`, `content-strategist`.
- 3 slash commands: `/seo-toolkit:seo-connect`, `/seo-toolkit:seo-status`, `/seo-toolkit:seo-disconnect`.
- SessionStart hooks (`ensure-venv.sh`, `check-credentials.sh`) + Stop hook (`suggest-related.sh`).
- Encrypted Fernet vault for SerpAPI, DataForSEO, Ahrefs, Moz, PageSpeed Insights, GSC OAuth, GA4 OAuth credentials.
- `keyword-clustering-and-mapping` skill wraps the external [keyword-clustering](https://github.com/johnoconnor0/keyword-clustering) package.
