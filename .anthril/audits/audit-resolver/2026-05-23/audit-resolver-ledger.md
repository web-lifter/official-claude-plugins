# Audit-resolver ledger — 2026-05-23

## Baseline

| Field | Value |
|---|---|
| Original audit report | `.anthril/audits/plan-completion-audit/AUDIT_REPORT.md` |
| Plan | `engineering-os/software-assurance-audit-program/.docs/SOFTWARE_ASSURANCE_AUDIT_PROGRAM_PLAN.md` + numbered `.docs/00–11` |
| Code under audit | `engineering-os/software-assurance-audit-program/` at SAAP v1.0.0 |
| Baseline git ref | `ad1fb4faf28f18b2de556551062630588013d7d9` (`Add PostHog eval IDs to many eval suites`) |
| Branch | `main` |
| Working-tree state at start | dirty — 1,122 uncommitted files (entire SAAP plugin from this conversation lives outside HEAD) |
| Pre-flight choice | Proceed with inline AUTO fixes (user-approved via AskUserQuestion) |

## Findings inventory (Phase 1 — from the audit)

12 findings — 0 CRITICAL, 8 WARNINGS, 4 SUGGESTIONS. See `AUDIT_REPORT.md` for full descriptions.

## Plan (Phase 2 triage)

| ID | Severity | Strategy | Disposition |
|---|---|---|---|
| F001 (W-01) | medium | HUMAN-INPUT → AUTO | User chose "Update catalog + 2 stale refs"; applied. |
| F002 (W-02) | medium | AUTO | Applied — `_detect_python` deps now surface as `risk_hotspots[]` / `unknowns[]`. |
| F003 (W-03) | low | AUTO | Applied — variable renamed. |
| F004 (W-04) | low | AUTO | Applied — unused local removed. |
| F005 (W-05) | low | AUTO | Applied — variable renamed. |
| F006 (W-06) | low | DEFER | Per original report — `set.add()` dedup acceptable. |
| F007 (W-07) | low | AUTO | Applied — `ruff --fix` removed 6 unused imports + locals. |
| F008 (W-08) | low | DEFER | Per original report — file size acceptable for v1.0.0. |
| F009 (S-01) | suggest | AUTO | Applied — `ruff.toml` added with E701 per-file-ignores. |
| F010 (S-02) | suggest | DEFER | README pointer sufficient. |
| F011 (S-03) | suggest | DEFER | Refactor not justified by current duplication. |
| F012 (S-04) | suggest | CLOSED | Subsumed by F002. |

## Execution log

| ID | Strategy | Files touched | Verifier | Outcome |
|---|---|---|---|---|
| F003 | AUTO | `scripts/build-evidence-pack.py` (line 198 rename) | `py_compile` + `ruff` | **closed** — variable renamed `ap` → `artefact_path`. |
| F004 | AUTO | `scripts/profile-codebase.py` (line 129 delete) | `py_compile` + `ruff` | **closed** — `has_ci = bool(...)` line removed. |
| F005 | AUTO | `scripts/validate-findings.py` (lines 156–160 rename) | `py_compile` + `ruff` | **closed** — inner loop `e` → `entry`. |
| F007 | AUTO | `scripts/profile-codebase.py`, `scripts/render-summary.py`, `scripts/build-report.py` (and their unused imports) | `ruff check --fix` | **closed** — 6 issues auto-fixed; F401/F841 = 0 remaining. |
| F002 | AUTO | `scripts/normalize-profile.py` (lines 32–86 + return-dict update) | Synthetic legacy profile fed through `normalize-profile.py`; `validate-profile.py` passes | **closed** — 1 risk_hotspot + 3 unknowns emitted; raw `_migrated_dependencies` preserved. |
| F009 | AUTO | `ruff.toml` (new file at plugin root) | `ruff check` reports `All checks passed!` | **closed** — E701 noise suppressed for the two detector files. |
| F001 | AUTO (after user choice) | `.docs/04-skill-catalog.md §2` (added fold note); `skills/profile-application/SKILL.md:155` (rewrote stale ref); `templates/audit-plan-template.md:39` (rewrote stale ref) | grep confirms no remaining stale `plan-assurance-program` references outside the catalog | **closed** — catalog documents the fold; refs updated. |

## Files touched (full list)

```
engineering-os/software-assurance-audit-program/scripts/build-evidence-pack.py     (F003)
engineering-os/software-assurance-audit-program/scripts/profile-codebase.py        (F004, F007)
engineering-os/software-assurance-audit-program/scripts/validate-findings.py       (F005)
engineering-os/software-assurance-audit-program/scripts/normalize-profile.py       (F002)
engineering-os/software-assurance-audit-program/scripts/build-report.py            (F007)
engineering-os/software-assurance-audit-program/scripts/render-summary.py          (F007)
engineering-os/software-assurance-audit-program/.docs/04-skill-catalog.md          (F001)
engineering-os/software-assurance-audit-program/skills/profile-application/SKILL.md (F001)
engineering-os/software-assurance-audit-program/templates/audit-plan-template.md   (F001)
engineering-os/software-assurance-audit-program/ruff.toml                          (F009, new file)
```

10 files touched (9 edits + 1 new file).

## Skipped / deferred

| ID | Reason |
|---|---|
| F006 | Per original report disposition: `set.add()` dedup pattern is acceptable. Mypy emits 2 hints that are harmless. |
| F008 | Per original report: `scripts/_detect_python.py` 631 lines is acceptable for v1.0.0. Worth splitting if it grows further. |
| F010 | MIGRATION-application-audit-to-saap.md — README pointer already present at `engineering/software-development/README.md`; nice-to-have, not required. |
| F011 | `_hook_io.py` helper to dedupe JSON-from-stdin parsing across 7 Python hooks — the duplication is small (~5 lines/hook) and the hooks all work; refactor would land in a 1.0.1 cleanup pass if the surface grows. |

## Re-audit diff

See `.anthril/audits/audit-resolver/2026-05-23/audit-resolver-reaudit-diff.md`.

**Headline:** Phase 1 verdict flips from FAIL → PASS at the next plan-completion-audit run. Phases 2 and 3 advance from PASS WITH WARNINGS → PASS for the audit-targeted findings (3 mypy advisories remain from DEFER items). Zero regressions, zero new findings.

## Final diff hint

The SAAP plugin was created entirely within this conversation and has never been committed; `git status` shows the files as untracked rather than modified. To review the audit-resolver's specific changes:

```bash
# Review just the audit-resolver's touched files vs. their state earlier in this conversation:
git status -- engineering-os/software-assurance-audit-program/{scripts,*.md,*.toml,.docs/*.md,skills/profile-application/*.md,templates/audit-plan-template.md}

# Or list the touched files with line counts:
wc -l engineering-os/software-assurance-audit-program/scripts/{build-evidence-pack,profile-codebase,validate-findings,normalize-profile,build-report,render-summary}.py \
      engineering-os/software-assurance-audit-program/.docs/04-skill-catalog.md \
      engineering-os/software-assurance-audit-program/skills/profile-application/SKILL.md \
      engineering-os/software-assurance-audit-program/templates/audit-plan-template.md \
      engineering-os/software-assurance-audit-program/ruff.toml
```

## Next step

Review the touched files, then commit when satisfied. Suggested commit message:

```
fix(saap): close 7 of 12 audit findings (W-01 through W-07 + S-01)

- F001 (W-01): Document plan-assurance-program fold into run-assurance-audit Phase 2
- F002 (W-02): Preserve legacy dependency data in migrate-anthril (risk_hotspots + unknowns + raw)
- F003 (W-03): Rename build-evidence-pack.py 'ap' -> 'artefact_path'
- F004 (W-04): Remove unused has_ci in profile-codebase.py
- F005 (W-05): Rename inner loop variable in validate-findings.py
- F007 (W-07): ruff --fix unused imports + locals (6 issues across 4 files)
- F009 (S-01): Add ruff.toml with E701 per-file-ignores for detector tables

Defers F006/F008/F010/F011 per original report dispositions.
Zero regressions; cross-stack harness and release-gates remain green.
```
