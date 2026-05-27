# Plan Completion Audit — Software Assurance Audit Program

> Audit date: 2026-05-23 · Plan: `engineering-os/software-assurance-audit-program/.docs/` (planning pack) + approved implementation plan at `C:\Users\john\.claude\plans\i-want-you-to-luminous-cookie.md` · Codebase: `engineering-os/software-assurance-audit-program/` at v1.0.0

## Headline

**25 of 26 plan items COMPLETE (96.2%) + 1 DEVIATES + 0 NOT STARTED + 0 PARTIAL.**

The plugin is at v1.0.0 with all five release-checklist gates green. One catalogued skill (`plan-assurance-program`) was folded into `run-assurance-audit` Phase 2 — the *functionality* exists (audit plan + cadence are produced as part of `run-assurance-audit`), but the standalone skill + `/plan` slash command from `06-hooks-commands-monitors.md §5` were never minted. Two scripted bugs surfaced: `normalize-profile.py` silently discards legacy dependency data during anthril migration, and minor unused-variable / variable-shadowing lint issues across four scripts. Everything else verified clean.

## Phase verdicts

| Phase | Verdict | Notes |
|---|---|---|
| **1. Plan completion** | **FAIL** (1 deviation) | 25/26 skills complete; `plan-assurance-program` deviated (folded into `run-assurance-audit`). Functionality exists; standalone command missing. |
| **2. Type safety & static analysis** | **PASS WITH WARNINGS** | Python + bash + JSON parse 100%. ruff 8 real warnings (5 unused imports, 2 unused locals, 1 redundant f-string) + 30 style nits (E701 one-line `if x: y`). mypy 9 advisory issues (3 are variable-shadowing patterns). No runtime bugs. |
| **3. Bug & logic audit** | **PASS WITH WARNINGS** | 1 medium bug (`normalize-profile.py:33` discards legacy dependency data). 3 variable-shadowing patterns that work at runtime but warrant cleanup. End-to-end harness passes; risk-score floor + ceiling both validated. |
| **4. Code structure & optimisation** | **PASS WITH WARNINGS** | 1 file > 500 lines (`scripts/_detect_python.py` at 631 — coherent unit, could be split later). All SKILL.md ≤ 180 lines, all agents ≤ 226 lines. No circular deps in plain text plugin. |
| **5. Failsafes & guardrails** | **PASS** | 0 bare `except:`. Every hook degrades gracefully against malformed JSON stdin (verified by feeding garbage to all 7 Python hooks — 6 exit 0 cleanly; 1 (`agent-run-event.py`) exits 2 with usage, correct because `hooks.json` always supplies `--phase`). |
| **6. Security** | **PASS** | No live secrets in source. Every `.mcp.json` URL is `${ENV_VAR}` form. PostHog OTel ingestion key in `settings.json` follows monorepo precedent (write-only telemetry, not customer data). |
| **7. Feature hardening** | **PASS** | No "Lorem ipsum"/placeholder copy. Cross-stack harness green (7/7 stacks, 0 leakage). Example artefacts validate against schemas. All three compliance templates carry mandatory "readiness only" boundary. |
| **8. Deprecated code cleanup** | **PASS** | 0 large commented-out blocks. 0 real orphaned scripts (one false positive on `validate-plugin-structure.py` — it IS referenced via repo-root path in `RELEASE-RHYTHM.md`). `__pycache__/` directories present locally but covered by repo-root `.gitignore` line 5 and not tracked by git. |
| **9. Build verification** | **PASS** | All five release gates green: `claude plugin validate` ✔, structural validator OK, cross-stack regression + leakage lint PASS, version sync ✓, 19 JSON files parse cleanly. |
| **10. Supabase backend** | **N/A** | Plugin has no database. |
| **11. Frontend ↔ backend alignment** | **PASS** | All 38 script-path references from skills resolve. All 18 agents named in `audit-router.md` routing table exist. All 28 agents declared in `plugin.json` resolve to files. 0 broken template references across skills/agents/scripts. |

---

## Phase 1 — Plan inventory (detail)

### Skills catalogued in `04-skill-catalog.md` → implementation status

| # | Skill (per catalog) | Status | Evidence |
|---|---|---|---|
| 1 | `profile-application` | ✅ COMPLETE | `skills/profile-application/SKILL.md` (180 lines) + `agents/codebase-profiler.md` + 4 helper agents + 7 detector scripts |
| 2 | `plan-assurance-program` | ⚠️ DEVIATES | Catalog (`04-skill-catalog.md §2`) and command map (`06 §5`) specify a standalone skill + `/plan` slash command. Implementation folds the same work into `run-assurance-audit` Phase 2 (lines 44–62: audit ID, scope, routing.json, render audit-plan-template.md). Two refs to the missing skill remain in source: `skills/profile-application/SKILL.md:155` and `templates/audit-plan-template.md:39`. |
| 3 | `run-assurance-audit` | ✅ COMPLETE | `skills/run-assurance-audit/SKILL.md` (173 lines), modes: standard/compliance/performance/security/full/agent-team |
| 4 | `secure-code-review` | ✅ COMPLETE | `skills/secure-code-review/SKILL.md` + `agents/secure-code-reviewer.md` |
| 5 | `application-security-assessment` | ✅ COMPLETE | `skills/application-security-assessment/SKILL.md` + `agents/appsec-auditor.md` |
| 6 | `dependency-supply-chain-audit` | ✅ COMPLETE | `skills/dependency-supply-chain-audit/SKILL.md` + `agents/dependency-supply-chain-auditor.md` |
| 7 | `secrets-configuration-audit` | ✅ COMPLETE | `skills/secrets-configuration-audit/SKILL.md` + `agents/secrets-config-auditor.md` |
| 8 | `cloud-infrastructure-audit` | ✅ COMPLETE | `skills/cloud-infrastructure-audit/SKILL.md` + `agents/cloud-infra-auditor.md` |
| 9 | `iam-access-review` | ✅ COMPLETE | `skills/iam-access-review/SKILL.md` + `agents/iam-access-auditor.md` |
| 10 | `performance-scalability-assessment` | ✅ COMPLETE | `skills/performance-scalability-assessment/SKILL.md` + `agents/performance-scalability-auditor.md` |
| 11 | `database-performance-review` | ✅ COMPLETE | `skills/database-performance-review/SKILL.md` + `agents/database-auditor.md` |
| 12 | `reliability-sre-review` | ✅ COMPLETE | `skills/reliability-sre-review/SKILL.md` + `agents/reliability-sre-auditor.md` |
| 13 | `backup-dr-review` | ✅ COMPLETE | `skills/backup-dr-review/SKILL.md` (dispatches reliability-sre-auditor in `backup_dr` mode) |
| 14 | `observability-monitoring-review` | ✅ COMPLETE | `skills/observability-monitoring-review/SKILL.md` + `agents/observability-auditor.md` |
| 15 | `data-privacy-governance-review` | ✅ COMPLETE | `skills/data-privacy-governance-review/SKILL.md` + `agents/privacy-data-governance-auditor.md` |
| 16 | `soc2-readiness-assessment` | ✅ COMPLETE | `skills/soc2-readiness-assessment/SKILL.md` + `templates/soc2-readiness-template.md` (with boundary statement) |
| 17 | `iso27001-readiness-assessment` | ✅ COMPLETE | `skills/iso27001-readiness-assessment/SKILL.md` + `templates/iso27001-readiness-template.md` |
| 18 | `pci-readiness-assessment` | ✅ COMPLETE | `skills/pci-readiness-assessment/SKILL.md` + `templates/pci-readiness-template.md` |
| 19 | `accessibility-review` | ✅ COMPLETE | `skills/accessibility-review/SKILL.md` + `agents/accessibility-auditor.md` |
| 20 | `vendor-risk-review` | ✅ COMPLETE | `skills/vendor-risk-review/SKILL.md` + `agents/vendor-risk-auditor.md` |
| 21 | `ai-ml-assurance-review` | ✅ COMPLETE | `skills/ai-ml-assurance-review/SKILL.md` + `agents/ai-ml-auditor.md` |
| 22 | `evidence-pack-builder` | ✅ COMPLETE | `skills/evidence-pack-builder/SKILL.md` + `scripts/build-evidence-pack.py` |
| 23 | `remediation-roadmap-builder` | ✅ COMPLETE | `skills/remediation-roadmap-builder/SKILL.md` + `agents/remediation-planner.md` |
| 24 | `audit-report-builder` | ✅ COMPLETE | `skills/audit-report-builder/SKILL.md` + `agents/report-writer.md` |
| 25 | `continuous-control-check` | ✅ COMPLETE | `skills/continuous-control-check/SKILL.md` (170 lines) + 5 monitors + 3 cadence templates |
| 26 | `migrate-anthril` | ✅ COMPLETE | `skills/migrate-anthril/SKILL.md` + `scripts/migrate-anthril.py` |

**Other plan deliverables (cross-check against `.docs/03–.docs/09`):**

| Deliverable | Target | Found | Status |
|---|---|---|---|
| Agents | ~25 per `05-agent-system.md` | 28 | ✅ exceeds target |
| Domain auditors | per `05 §3` table (15 listed) | 15 distinct domain auditors | ✅ |
| Event monitors | 5 per `06 §7` | 5 (`ci-failure`, `deployment-event`, `security-advisory`, `incident-alert`, `scanner-finding`) | ✅ |
| Hook events declared | 13 per `06 §2` | 9 `hooks.json` events covering 13 logical hooks (some scripts called with `--phase`/`--batch` flags) | ✅ |
| Hook scripts | 7+ per `08 §7` | 8 distinct scripts + 3 bash entry-point scripts | ✅ |
| Stack adapters | 14 per `08 §4` | 14 | ✅ |
| Schemas | 8 (profile, capability-matrix, finding, evidence, audit-plan, risk-register, remediation-roadmap, control-matrix) | 8 | ✅ |
| Markdown templates | per `08 §1` (20+ items) | 21 | ✅ |
| References | per `08 §3` (13 items + stack adapters) | 13 + 14 stack = 27 | ✅ |
| Scripts | per `08 §6` (17 items) | 26 (extras: `_detect_python.py`, `_extract-capability-matrix.py`, `migrate-anthril.py`, ported `.anthril/` lifecycle scripts, hook scripts) | ✅ |
| Phase 9 fixtures | 7 per roadmap (Node/Python/Go/Java/.NET/Infra/AI-LLM) | 7 | ✅ |
| MVP demo | Phase 11 deliverable | `.docs/MVP-DEMO.md` | ✅ |
| Release rhythm | Phase 10 deliverable | `.docs/RELEASE-RHYTHM.md` | ✅ |

### TODO/FIXME/STUB scan

Only 7 hits in plugin source, all legitimate:

- `agents/quality-profiler.md`, `agents/secure-code-reviewer.md` — instruct auditors to grep for TODO/FIXME in *target* code (a feature, not a defect in SAAP itself).
- `agents/report-writer.md:130` — explicitly forbids "(TBD)/(TODO)" in shipped reports.
- `scripts/migrate-anthril.py:98` — `E-MIG-PLACEHOLDER-1` is the documented fallback evidence ID when a legacy finding has zero evidence pointers (correct behaviour per the agent's contract).

**Total: 25 of 26 plan items COMPLETE = 96.2%.** One DEVIATES. No NOT STARTED or PARTIAL items.

Per skill verdict rule (any non-COMPLETE = FAIL): **Phase 1 FAIL**. The fail is a single architectural fold (capable but uncatalogued), not missing capability.

---

## Findings (prioritised)

### CRITICAL

None.

### WARNINGS

| ID | File:line | Severity | Issue |
|---|---|---|---|
| W-01 | `04-skill-catalog.md §2` vs codebase | medium | The `plan-assurance-program` skill catalogued at `04-skill-catalog.md §2` and command-mapped at `06-hooks-commands-monitors.md §5` (the `/plan` slash command) is not implemented as a standalone skill. The functionality is folded into `run-assurance-audit` Phase 2 (which writes `audit-plan.json` + renders `audit-plan-template.md`). **Two stale references** remain in source code: `skills/profile-application/SKILL.md:155` and `templates/audit-plan-template.md:39`. **Recommended action:** either (a) extract `plan-assurance-program` as a standalone skill that produces `audit-plan.{json,md}` + `control-matrix.json` + `assurance-cadence-template.md` per the catalog, OR (b) update the catalog + command map + the two stale source references to reflect the fold. |
| W-02 | `scripts/normalize-profile.py:33` | medium | Legacy `dependencies` data is read from the codebase-profiler JSON but never written to the SAAP profile. Per `02-uploaded-skill-archive-inventory.md §2` the legacy profile contains `dependencies.direct`, `dev`, `transitive_estimate`, `vulnerable.{critical,high,moderate}`, `outdated_count`, `circular_imports`, `licenses` — all silently discarded during `migrate-anthril`. **Recommended action:** either surface a count summary in `risk_hotspots[]` (when `vulnerable.high+critical > 0`) or add explicit `unknowns[]` entries pointing users at the legacy file for follow-up. |
| W-03 | `scripts/build-evidence-pack.py:198` | low | Variable `ap` shadows the `ArgumentParser` (`ap = argparse.ArgumentParser()` on line 123) by being reassigned to a `Path` inside the artefact-resolve loop. Works at runtime because argparse is done by then, but mypy flags it as a type mismatch. **Recommended action:** rename to `artefact_path` in the loop. |
| W-04 | `scripts/profile-codebase.py:129` | low | `has_ci = bool(infra.get("ci_cd", {}).get("providers"))` computed but never used (the capability matrix populates without it; CI/CD is referenced via `dependency_supply_chain` defaults). **Recommended action:** either delete the line or wire `has_ci` into a dedicated matrix slot for `ci_cd_present`. |
| W-05 | `scripts/validate-findings.py:157` | low | Inner-loop variable `e` shadows the outer loop variable `e` (the outer iterates over schema-validation error strings; the inner over ledger entries). Functional at runtime but confuses mypy and readers. **Recommended action:** rename the inner loop to `entry` or similar. |
| W-06 | `scripts/_detect_python.py:454,624` | low | `cloud = [c for c in cloud if not (c in seen or seen.add(c))]` uses the `set.add()` returning `None` trick for order-preserving dedup. Works correctly but mypy flags it. **Recommended action:** acceptable as-is, or refactor to `cloud = list(dict.fromkeys(cloud))`. |
| W-07 | `scripts/normalize-profile.py:33`, `scripts/profile-codebase.py:23,129`, `scripts/render-summary.py:25,27`, `hooks/scripts/completion-gate.py:32`, `hooks/scripts/session-flush.py:17` | low | Ruff F401/F841 — 5 unused imports + 2 unused local variables across 4 files. **Recommended action:** `ruff check --fix scripts/ hooks/scripts/` removes the autofixable ones. |
| W-08 | `scripts/_detect_python.py` (631 lines) | low | Exceeds 500-line guideline (specifically meant for `SKILL.md` per project CLAUDE.md but worth noting). The file is a coherent unit (one detector function per stack family). **Recommended action:** acceptable for v1.0.0; consider splitting into `scripts/detectors/<lang>.py` if it grows further. |

### SUGGESTIONS

| ID | Where | Suggestion |
|---|---|---|
| S-01 | All Python scripts | Suppress E701 in `ruff.toml` (`per-file-ignores = ["scripts/_detect_python.py:E701"]`) — the `if x: y` one-liners in detector tables are intentional and 30 of them clutter `ruff check` output. |
| S-02 | `.docs/` | Add a `MIGRATION-application-audit-to-saap.md` doc as the canonical landing for users migrating off the deleted `application-audit` skill. The README has a pointer; a dedicated doc would help. |
| S-03 | `hooks/scripts/` | The 7 Python hooks each re-implement JSON-from-stdin parsing. A small `_hook_io.py` helper would dedupe the boilerplate. |
| S-04 | `scripts/migrate-anthril.py` | Consider extracting the legacy-dependency-data summarisation into a separate `--include-deps-summary` flag — addresses W-02 while keeping the default migration minimal. |

---

## What the user can do next

The plugin is **production-ready at v1.0.0**. All five release gates pass. The findings above are quality / cleanup items, not blockers. Two recommended sequenced actions:

1. **This week (close W-01):** decide whether to extract `plan-assurance-program` (the only DEVIATES item from Phase 1) or update the catalog. Either choice resolves Phase 1 to PASS for the next audit cycle.
2. **This month (close W-02):** wire legacy dependency data into `migrate-anthril.py` output so users with rich `.anthril/` profiles don't lose dependency-vuln context during migration.

The remaining warnings (W-03 through W-08) are clean-up suitable for a 1.0.1 patch.

> *To begin executing the action list, run `/utilities:audit-resolve` (or invoke the `[[audit-resolver]]` skill directly). It will parse this report, triage every finding, get your confirmation, then apply fixes batch-by-batch with verifier checks.*

---

## Audit metadata

- Output written to: `.anthril/audits/plan-completion-audit/AUDIT_REPORT.md`
- Tools used: `claude plugin validate`, `python3 -c py_compile`, `bash -n`, `mypy --ignore-missing-imports`, `ruff check`, `node scripts/check-versions.mjs`, custom cross-reference scanners
- Plan documents read: `SOFTWARE_ASSURANCE_AUDIT_PROGRAM_PLAN.md` plus `01`–`11` numbered docs under `.docs/` plus the approved implementation plan at `~/.claude/plans/i-want-you-to-luminous-cookie.md`
- Code under audit: `engineering-os/software-assurance-audit-program/` at SAAP v1.0.0 (`software-development` plugin at v1.5.0; marketplace synced)
- Phases skipped (with reason): Phase 10 (no Supabase backend)
- Phase 1 verdict per strict rule: FAIL (1 deviation, 0 not-started, 0 partial). Functional verdict: 25/26 complete (96.2%) — one architectural fold.
