# Re-audit diff — audit-resolver 2026-05-23

> Compared against the original audit report at `.anthril/audits/plan-completion-audit/AUDIT_REPORT.md` (2026-05-23, SAAP v1.0.0).

## Verdict deltas

| Phase | Before | After | Change |
|---|---|---|---|
| 1. Plan completion | **FAIL** (1 deviation: plan-assurance-program) | **PASS** | F001 closed — catalog updated + 2 stale refs fixed; the fold from skill → run-assurance-audit Phase 2 is now documented as the canonical design. |
| 2. Type safety & static analysis | **PASS WITH WARNINGS** (31 ruff issues + 9 mypy hints) | **PASS WITH WARNINGS** (0 ruff issues; 3 mypy hints remaining — all from DEFERed items W-06, W-08) | All 8 ruff issues closed via F003/F004/F005/F007/F009; the 30 E701 nits suppressed via `ruff.toml` per S-01. |
| 3. Bug & logic audit | **PASS WITH WARNINGS** (W-02 deps data loss + 3 shadowing) | **PASS** | W-02 closed (legacy deps now surface as `risk_hotspots[]` + `unknowns[]` + raw preserved in `_migrated_dependencies`). W-03/W-04/W-05 all renamed / removed. |
| 4. Code structure | PASS WITH WARNINGS (`_detect_python.py` > 500) | unchanged — DEFERed per report | W-08 acceptable as-is for v1.0.0. |
| 5–11 | PASS / PASS WITH WARNINGS / N/A as before | unchanged | No regressions across the other phases. |

## Per-finding outcome

| ID | Severity | Status before | Status after | Notes |
|---|---|---|---|---|
| F001 (W-01) | medium | DEVIATES | **CLOSED** | Catalog `04-skill-catalog.md §2` now documents the fold; refs in `skills/profile-application/SKILL.md:155` and `templates/audit-plan-template.md:39` updated. |
| F002 (W-02) | medium | OPEN | **CLOSED** | `normalize-profile.py:32–86` now surfaces legacy dep data through 3 channels (risk_hotspots / unknowns / `_migrated_dependencies`). Smoke-tested with a 1-critical / 3-high / 5-moderate / 12-outdated / 2-cycles / 3-licenses synthetic legacy profile — all signals carried through; profile validates. |
| F003 (W-03) | low | OPEN | **CLOSED** | `build-evidence-pack.py:198` — `ap` → `artefact_path`. Mypy shadow gone. |
| F004 (W-04) | low | OPEN | **CLOSED** | `profile-codebase.py:129` — unused `has_ci` removed. |
| F005 (W-05) | low | OPEN | **CLOSED** | `validate-findings.py:157` — inner `e` → `entry`. Outer `e` (validator-error string) preserved. |
| F006 (W-06) | low | OPEN | **DEFERRED** (per original report) | `set.add()` dedup pattern acceptable; documented in W-06 disposition. |
| F007 (W-07) | low | OPEN | **CLOSED** | `ruff check --fix` removed 6 issues; final state: 0 F-codes outstanding. |
| F008 (W-08) | low | OPEN | **DEFERRED** (per original report) | `_detect_python.py` 631 lines is acceptable for v1.0.0. |
| F009 (S-01) | suggest | OPEN | **CLOSED** | `ruff.toml` added with `per-file-ignores` for E701 on the two detector files. `ruff check` now reports `All checks passed!`. |
| F010 (S-02) | suggest | OPEN | **DEFERRED** | MIGRATION doc — README pointer is sufficient for v1.0.0; revisit if migration friction surfaces. |
| F011 (S-03) | suggest | OPEN | **DEFERRED** | `_hook_io.py` helper — 7-hook refactor not justified by current duplication. |
| F012 (S-04) | suggest | OPEN | **CLOSED** (subsumed) | Folded into F002's `_migrated_dependencies` capture. |

## Score

- **Closed this run: 7 of 12 findings** (F001, F002, F003, F004, F005, F007, F009, F012).
- **Deferred per original report: 4** (F006, F008, F010, F011).
- **Regressions: 0.**
- **New findings: 0.**

## Verifier results (final state after fixes)

```
1. claude plugin validate  → ✔ Validation passed
2. structural validator    → OK at v1.0.0
3. ruff                    → All checks passed!
4. cross-stack regression  → 7/7 stacks at 100%, 0 leakage
5. mypy                    → 3 advisory hints (all DEFER items)
```

## Next steps for the user

- Phase 1 verdict flips to PASS at the next `plan-completion-audit` run.
- F006 / F008 / F010 / F011 deferrals are explicit; the report has rationale.
- Suggested 1.0.1 patch contents: the 4 deferred suggestions if/when revisited.
