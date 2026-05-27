# Audit-resolver plan — venture-os v0.1.0 audit

- **Source report:** [.anthril/audits/plan-completion-audit/venture-os-audit.md](.anthril/audits/plan-completion-audit/venture-os-audit.md)
- **Generated:** 2026-05-23

## Triage table

| ID | Sev | Phase | Strategy | File(s) | Order |
|---|---|---|---|---|---|
| F-2.1 | CRITICAL | 2 | AUTO | `venture-os/scripts/render_operating_workflow.py` | 1 (blocks Phase 2 verifier) |
| F-3.1 | WARNING | 3 | AUTO | `venture-os/scripts/generate_sprint_backlog.py` | 2 (cluster with F-2.1 — same file dir) |
| F-5.1 | WARNING | 5 | AUTO | `venture-os/README.md` | 3 |
| F-8.1 | WARNING | 8 | AUTO | `venture-os/scripts/_*.py` → `venture-os/docs/planning/build-tooling/` | 4 (last AUTO — moves don't break compile) |
| F-1.1 | CRITICAL | 1/7 | PLAN-FIRST | 12× `venture-os/skills/<slug>/SKILL.md` (Batch A) | 5 |
| F-1.2 | CRITICAL | 1 | PLAN-FIRST | 9× `venture-os/agents/<slug>.md` (Phase-1 set) | 6 |
| F-8.2 | SUGGESTION | 8 | DEFER | n/a | — |
| F-1.3 | (info) | 1 | N/A | n/a | — |

## Dependency notes

- **Order rationale:** AUTO batch first because (a) F-2.1 unblocks the Phase 2 verifier baseline, and (b) the AUTO fixes are reversible single-file edits. PLAN-FIRST work follows because (c) it touches 21 files with substantive content, so verifying we still validate after each cluster is important.
- F-8.1 (move scaffolders) must NOT move `_lib.py` — it is a runtime dependency for `dedupe_signals.py`, `cluster_voc_themes.py`, `cluster_review_themes.py`, and `hash_evidence_files.py`. Only `_scaffold_skills.py`, `_scaffold_agents.py`, `_bulk_create_helpers.py`, `_bulk_create_references.py`, `_bulk_create_templates_examples.py`, `_bulk_create_docs.py` move.

## Verifiers per batch

| Batch | Verifier |
|---|---|
| AUTO | `python -m py_compile` on every changed `.py`; `bash -n` on `.sh`; `claude plugin validate ./venture-os` |
| PLAN-FIRST (skills) | `claude plugin validate ./venture-os`; YAML frontmatter check; SKILL.md < 500 lines |
| PLAN-FIRST (agents) | `claude plugin validate ./venture-os`; frontmatter check |

## Deferred (with reason)

- **F-1.1 Batches B–K (51 skills):** Out of scope for this run — substantive content for 51 skills exceeds one session. Recommended follow-up: enrich per batch using `skill-ops:skill-evaluator` after Batch A pattern is established.
- **F-1.2 remaining 20 agents:** Same rationale — enrich after Phase-1 agent pattern is established.
- **F-8.2:** Resolved organically when skills are enriched (the audit suggested retroactive `skill-ops` use; doing that during F-1.1 enrichment covers this).

## Scope option for this run

Default plan executes all 4 AUTO + 2 PLAN-FIRST batches. User may opt to:

- Stop after AUTO batch (closes 4 of 7 findings, leaves 2 CRITICAL substantive items open)
- Stop after AUTO + skills enrichment (closes 5 of 7)
- Full plan (closes 6 of 7; defers 1 SUGGESTION)
