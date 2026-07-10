# PPC Manager — Web Lifter Plugin

End-to-end PPC management across Google Ads, Meta Ads, GA4, and Google Tag Manager — inside Claude Code. 23 skills, 4 bundled MCP servers, OAuth-authenticated read + write, encrypted credential vault.

## What you get

| Category | Skills |
|---|---|
| **Foundation** | `oauth-setup` |
| **Google Tag Manager** | `gtm-setup`, `gtm-datalayer`, `gtm-tags` |
| **Google Analytics 4** | `ga4-setup`, `ga4-events` |
| **Google Ads** | `google-ads-account-setup`, `google-search-campaign`, `google-pmax-campaign`, `google-ads-copy`, `display-ad-specs` |
| **Meta / Facebook Ads** | `meta-pixel-setup`, `meta-capi-setup`, `meta-events-mapping`, `meta-audience-builder`, `meta-creative-brief`, `meta-ads-copy` |
| **Cross-platform** | `keyword-research`, `campaign-audit`, `utm-builder`, `landing-page-copy`, `youtube-campaign` |

All skills follow the Web Lifter convention: Australian English, markdown-first output, 200–500 line `SKILL.md` files, realistic examples, Apache 2.0 licensed per skill.

## Prerequisites

- **Claude Code** (latest)
- **Python 3.11+** on your PATH (the SessionStart hook builds a local venv in `${CLAUDE_PLUGIN_DATA}/venv`)
- **A Google Cloud Platform project** with OAuth 2.0 Desktop client credentials (`client_secret.json`)
- **A Meta Business developer app** at [developers.facebook.com](https://developers.facebook.com) with the Marketing API product enabled
- **A Google Ads developer token** from [ads.google.com/aw/apicenter](https://ads.google.com/aw/apicenter) (can be applied for later)

`/ppc-manager:oauth-setup` walks you through every prerequisite step by step.

## Installation

### From the Web Lifter marketplace

```bash
# Add the marketplace if you haven't already
/plugin marketplace add johnoconnor0/official-claude-plugins

# Install the plugin
/plugin install ppc-manager@web-lifter-plugins
```

### From a local checkout

```bash
/plugin install /path/to/ppc-manager
```

On first enable, Claude Code prompts you for the 8 `userConfig` fields. The only field strictly required up front is `ppc_vault_passphrase`. Everything else can be left blank and filled in by `/ppc-manager:oauth-setup`.

## First run

```
/ppc-manager:oauth-setup
```

The skill will:

1. Ask which platforms you want to connect (Google, Meta, or both).
2. Walk you through the GCP OAuth client creation if you haven't done it yet.
3. Open your browser for Google consent (one time, one combined scope set for GTM + GA4 + Google Ads).
4. Open your browser for Meta consent and let you pick which ad accounts to store.
5. Validate every token with a read-only API call to each platform.

After that, every other skill in the plugin has transparent read + write access to all four platforms. Tokens refresh automatically.

## How skills chain

```
oauth-setup
   ├─ gtm-setup ─ gtm-datalayer ─ gtm-tags
   ├─ ga4-setup ─ ga4-events
   ├─ google-ads-account-setup ─ google-search-campaign
   │                           └ google-pmax-campaign
   ├─ meta-pixel-setup ─ meta-capi-setup
   │                   ├ meta-events-mapping
   │                   └ meta-audience-builder
   └─ keyword-research ─ utm-builder ─ landing-page-copy
         │
         └─ campaign-audit (cross-platform, uses all four MCP servers)
```

Pure content skills (`google-ads-copy`, `display-ad-specs`, `meta-creative-brief`, `meta-ads-copy`, `landing-page-copy`) have no OAuth dependency and can be run in isolation.

## Credential architecture

Static secrets (Google Ads developer token, Meta app secret) live in the Claude Code keychain via `userConfig.sensitive=true`. Rotating secrets (Google refresh tokens, Meta long-lived tokens) live in an encrypted vault at `${CLAUDE_PLUGIN_DATA}/tokens.enc` — Fernet-encrypted with a key derived via PBKDF2-HMAC-SHA256 (100 000 iterations) from your vault passphrase.

See `docs/credentials.md` for:

- Vault file format
- Where tokens live on disk per OS
- Manually rotating Meta tokens
- Backing up and restoring the vault
- Revoking access

## Bundled MCP servers

| Server | Source | Tools |
|---|---|---|
| `ppc-gtm` | ported from gtm-mcp | ~15 — accounts, containers, workspaces, tags, triggers, variables, versions |
| `ppc-ga4` | ported from google-analytics-mcp | ~12 — admin, reporting, realtime, custom dims/metrics, conversions |
| `ppc-google-ads` | ported from google-ads-plugin | ~25 — campaigns, ad groups, keywords, ads, bidding, audiences, reporting, conversions |
| `ppc-meta` | built from scratch on facebook_business | ~20 — accounts, campaigns, ad sets, ads, creatives, audiences, pixels, CAPI, insights |

All four share a single `scripts/lib/ppc_auth.py` library for credential loading and auto-refresh.

## Security notes

- The vault is encrypted at rest. Your passphrase is the only thing that unlocks it.
- The plugin ships with a `.gitignore` that excludes `tokens.enc`, `.env`, and `client_secret*.json`. Do not commit these.
- Scripts never log raw tokens — `masking_logger.py` filters anything starting with `ya29.`, `1//`, or `EAAB`.
- If a machine is compromised, revoke access in each platform's developer console, delete `tokens.enc`, and re-run `/ppc-manager:oauth-setup`.

## Troubleshooting

See `docs/credentials.md` troubleshooting section. Quick pointers:

- **"Vault not found"** → Run `/ppc-manager:oauth-setup`.
- **"Failed to decrypt vault"** → Wrong passphrase. Disable + enable the plugin to re-prompt.
- **"Google API 403"** → Check `client_secret.json` includes all 5 scopes, and OAuth consent screen lists your email as a test user.
- **"Meta token expired"** → Re-run `/ppc-manager:oauth-setup refresh` for the Meta platform. Meta long-lived tokens expire after ~60 days.
- **"MCP server failed to start"** → Check `${CLAUDE_PLUGIN_DATA}/install.log` for pip failures; ensure Python 3.11+ is on your PATH.

## License

- Plugin-level code: MIT (see `LICENSE`).
- Per-skill `SKILL.md` + assets: Apache 2.0 (see `skills/<name>/LICENSE.txt`).

## Author

Web Lifter — [john@weblifter.com.au](mailto:john@weblifter.com.au) · [github.com/johnoconnor0](https://github.com/johnoconnor0)
