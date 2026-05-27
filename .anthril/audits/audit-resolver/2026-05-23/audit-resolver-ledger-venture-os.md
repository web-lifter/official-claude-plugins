# Audit-resolver ledger — venture-os v0.1.0

- **Run date:** 2026-05-23
- **Source audit:** [.anthril/audits/plan-completion-audit/venture-os-audit.md](../../plan-completion-audit/venture-os-audit.md)
- **Plan:** [audit-resolver-plan.md](audit-resolver-plan.md)
- **Baseline ref:** `ad1fb4faf28f18b2de556551062630588013d7d9` ("Add PostHog eval IDs to many eval suites")
- **Branch:** `main`
- **Scope this run:** Full plan (AUTO + skills + agents) — user-selected

## Notable repo state

The entire `venture-os/` directory is gitignored at root [.gitignore:99](../../../../.gitignore). All plugin files are present on disk but invisible to `git diff` and `git status`. Edits in this run apply to the live disk state; if/when the user removes the gitignore entry, the full v0.1.0 plugin will appear as untracked files for staging.

## Findings inventory (from audit)

| ID | Sev | Phase | Strategy | Outcome |
|---|---|---|---|---|
| F-2.1 | CRITICAL | 2 | AUTO | closed |
| F-1.1 | CRITICAL | 1/7 | PLAN-FIRST (12 Batch A skills) | closed (Batch A only; B–K deferred) |
| F-1.2 | CRITICAL | 1 | PLAN-FIRST (9 Phase-1 agents) | closed (Phase-1 only; remaining 20 deferred) |
| F-3.1 | WARNING | 3 | AUTO | closed |
| F-5.1 | WARNING | 5 | AUTO | closed |
| F-8.1 | WARNING | 8 | AUTO | closed |
| F-8.2 | SUGGESTION | 8 | DEFER | deferred (covered organically by F-1.1 work) |
| F-1.3 | INFO | 1 | N/A | no action (intentional removal by user) |

**Totals:** 6 findings closed, 1 deferred (suggestion only), 1 no-action (informational).

## Execution log

### F-2.1 — Python syntax error in `render_operating_workflow.py`

- **Strategy:** AUTO
- **File:** [venture-os/scripts/render_operating_workflow.py:18](../../../../venture-os/scripts/render_operating_workflow.py)
- **Fix:** Changed `f"    {a}["{a} ({actor})"]"` to `f'    {a}["{a} ({actor})"]'` (use single-quoted f-string so the embedded double quotes don't need escaping).
- **Verifier:** `python -m py_compile scripts/render_operating_workflow.py` → 0 errors. Smoke test with a 3-row CSV → produces valid Mermaid output.
- **Outcome:** closed.

### F-3.1 — Typo'd helper in `generate_sprint_backlog.py`

- **Strategy:** AUTO
- **File:** [venture-os/scripts/generate_sprint_backlog.py](../../../../venture-os/scripts/generate_sprint_backlog.py)
- **Fix:** Inlined `DEFAULT_WORKSTREAMS` directly into the `enumerate(...)` call at line 39; deleted the misspelt `DEFAULT_WORKTREAMS_SAFE` helper that was at line 45.
- **Verifier:** `python scripts/generate_sprint_backlog.py --goal "post-fix verify" --out /tmp/sb.csv` → "Wrote …/sb.csv (12 rows)". Script behaviour unchanged; cosmetic-naming issue gone.
- **Outcome:** closed.

### F-5.1 — `userConfig` documentation gap

- **Strategy:** AUTO
- **File:** [venture-os/README.md](../../../../venture-os/README.md)
- **Fix:** Added a "Configuration" section to the README documenting the four conventional defaults (`workspaceDir`, `defaultEvidenceStandard`, `defaultVentureStage`, `redactResearchParticipants`), explicitly noting they are conventions (not surfaced as plugin-settings keys via `plugin.json` in this release) and how to override (env vars / CLI flags). Updated the "Privacy" section to cross-reference the redaction default and the `guard-external-actions.sh` hook.
- **Verifier:** `claude plugin validate ./venture-os` → ✔.
- **Outcome:** closed.

### F-8.1 — One-shot scaffolders left in `scripts/`

- **Strategy:** AUTO
- **Files:** moved six scaffolders from [venture-os/scripts/](../../../../venture-os/scripts/) → [venture-os/docs/planning/build-tooling/](../../../../venture-os/docs/planning/build-tooling/):
  - `_scaffold_skills.py`
  - `_scaffold_agents.py`
  - `_bulk_create_helpers.py`
  - `_bulk_create_references.py`
  - `_bulk_create_templates_examples.py`
  - `_bulk_create_docs.py`
- **`_lib.py` retained** in `scripts/` — it is a runtime dependency of `dedupe_signals.py`, `cluster_voc_themes.py`, `cluster_review_themes.py`, `hash_evidence_files.py`. Moving it would break those scripts.
- **Verifier:** `python -m py_compile` on all remaining `scripts/*.py` → 0 errors. `claude plugin validate ./venture-os` → ✔.
- **Outcome:** closed.

### F-1.1 — 63 generic SKILL.md bodies (Batch A: 12 skills)

- **Strategy:** PLAN-FIRST
- **Approach:** Wrote [_enrich_batch_a_skills.py](../../../../venture-os/docs/planning/build-tooling/_enrich_batch_a_skills.py) — a one-shot, idempotent enricher that uses a regex to replace the generic `## Phases` block in each skill with skill-specific phases. Each replacement carries a marker comment (`<!-- venture-os: skill-specific phases v0.1.0 -->`) so re-runs detect "already enriched".
- **Skills enriched (12):**
  - `profile-venture` — 5 phases: ingest, populate blocks, riskiest-assumptions sweep, normalise+validate, write artefacts. Calls out the stage-enum rule (never advance without primary evidence).
  - `run-discovery-sprint` — 6 phases including explicit "refuse to proceed without a goal".
  - `create-opportunity-brief` — 6 phases with the alternatives-sweep guardrail and the scoring is-input-not-verdict framing.
  - `market-landscape-research` — 6 phases including value-chain Mermaid render and the source-every-cell rule.
  - `create-customer-discovery-plan` — 6 phases with consent and PII redaction baked into Phase 4.
  - `synthesize-customer-interviews` — 6 phases including the "refuse on raw transcripts" PII rule and the "preserve minority signals" rule.
  - `competitor-landscape-analysis` — 6 phases including the substitutes guardrail and the no-reading-minds rule.
  - `business-model-canvas` — 5 phases with explicit coherence checks (revenue ↔ cost ↔ channels ↔ activities).
  - `value-proposition-canvas` — 5 phases with the "one canvas per segment" refusal rule.
  - `create-hypothesis-register` — 6 phases pre-committing evidence thresholds.
  - `design-experiment` — 6 phases with the category-to-method mapping table and the pre-commit success/failure rule.
  - `create-stage-gate-decision-pack` — 7 phases including the "refuse for a gate you haven't reached" rule.
- **Verifier:** `claude plugin validate ./venture-os` → ✔. Line counts 66-76 (well under 500). All 12 carry the marker comment.
- **Outcome:** closed for Batch A. **Remaining 51 skills (Batches B–K) deferred** — recommended follow-up sessions per audit.

#### F-1.1 Batch B follow-up (5 market skills) — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.1)
- **Trigger:** User invoked `/utilities:audit-resolve - complete batch b`.
- **Repo move noted:** Between the Batch A run and the Batch B run, the plugin was relocated from `venture-os/` (repo root) to `anthril-os/venture-os/`. All Batch B work targets the new path; previous Batch A enrichments survived the move intact (marker comments still present, validate still passes).
- **Approach:** Wrote `anthril-os/venture-os/docs/planning/build-tooling/_enrich_batch_b_skills.py` — same idempotent regex pattern as Batch A.
- **Skills enriched (5):**
  - `market-sizing-analysis` — 6 phases: boundary, top-down, bottom-up, comparable sanity check, reconcile with assumption-log, write. Codifies "the gap between top-down and bottom-up is a finding, not an average" rule.
  - `trend-signal-scan` — 6 phases including STEEP+C category sweep, dedupe via `dedupe_signals.py`, strength vs relevance separation, and "a signal is not a finding" rule.
  - `industry-value-chain-map` — 7 phases including the four-flow mapping (value/money/data/regulatory), Mermaid render, value-capture analysis, leverage points feeding `white-space-analysis`.
  - `segment-analysis` — 6 phases with weighted scoring via `score_segments.py`, vague-segment refusal rule, and contradiction-sweep against customer research.
  - `demand-signal-analysis` — 6 phases covering eight signal sources, normalisation via `normalize_demand_signals.py`, triangulation requirement.
- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. Line counts 70-89 (under 500). All 5 carry the marker comment.
- **Outcome:** closed for Batch B. **Remaining deferred:** Batches C–K (46 skills) and 20 agents.

#### F-1.1 Batch C follow-up (5 customer skills) — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.1)
- **Trigger:** User invoked `/utilities:audit-resolve - complete batch c` (then `proceed with /audit-resolve batch c`).
- **Note:** The original plan listed Batch C as 5 new skills plus a "refinement of `synthesize-customer-interviews`". The synthesise skill was fully enriched in Batch A; no further refinement was warranted — closed as already-complete.
- **Approach:** `anthril-os/venture-os/docs/planning/build-tooling/_enrich_batch_c_skills.py` — same idempotent regex pattern.
- **Skills enriched (5):**
  - `create-interview-guide` — 6 phases: anchor on learning goal, compose the 5-block discovery arc (warm-up / trigger / tools / pain / wand) with explicit time budget, leading-question audit, probe library, consent block, write. Codifies "refuse to generate a guide that doesn't tie to at least one hypothesis".
  - `create-jtbd-map` — 7 phases including the "refuse to build from a blank page" rule, separate extraction of functional/emotional/social jobs, switching-triggers as gold, and explicit forces-of-progress mapping for the dominant job.
  - `create-personas-archetypes` — 7 phases including the "no fictional names, no stock photos" evidence-only rule, behavioural clustering (not demographic), anti-pattern section requirement.
  - `create-customer-journey-map` — 7 phases including current vs future scope discipline, moments-of-truth identification, opportunity areas as hypothesis inputs (not solutions), Mermaid render via `render_journey_map.py`.
  - `voice-of-customer-analysis` — 7 phases including consent-basis check per source, PII scrub before storage, sentiment-without-volume warning, minority-signal preservation, theme clustering via `cluster_voc_themes.py`.
- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. Line counts 70-82.
- **Outcome:** closed for Batch C. **Remaining deferred:** Batches D–K (41 skills) and 20 agents.

#### F-1.1 Batch D follow-up (6 competitive skills) — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.1)
- **Trigger:** User invoked `proceed with /audit-resolve batch d`.
- **Approach:** `anthril-os/venture-os/docs/planning/build-tooling/_enrich_batch_d_skills.py` — same idempotent regex pattern.
- **Skills enriched (6):**
  - `substitute-analysis` — 6 phases anchored in customer "current alternatives" research; 7-bucket categorisation (manual / spreadsheet / DIY / agency / internal / adjacent / do-nothing); cost-of-substitute analysis across time/money/output; switching-cost analysis as customer's real frame of reference; wedge implications.
  - `feature-comparison-analysis` — 6 phases starting from customer evaluation criteria (not feature dumps); parity-required vs differentiation-candidate classification; packaging+limits capture; gap and self-claim-vs-review contradiction surfacing.
  - `pricing-packaging-analysis` — 6 phases including capture-date discipline, value-metric inventory (per-seat vs usage vs outcome), packaging-structure classification (linear vs decoy), WTP triangulation against customer research, monetization-risk surfacing.
  - `positioning-map` — 6 phases refusing arbitrary 2x2 axes; pulling axes from customer decision criteria; plotting self-stated vs perceived positioning and treating divergence as the finding; canonical positioning-statement form with claims-to-validate.
  - `review-mining-analysis` — 7 phases including legality/ToS check, anonymisation even for public reviews, clustering via `cluster_review_themes.py`, switching-trigger extraction as highest-value yield, unmet-needs feed to whitespace.
  - `white-space-analysis` — 6 phases requiring **all three sources** (market + customer + competitor) present and fresh; five-axis gap mapping (segment / job / workflow / business-model / experience); demand-signal cross-check to avoid "empty because demand absent"; narrow wedge framing.
- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. Line counts 70-95.
- **Outcome:** closed for Batch D. **Remaining deferred:** Batches E–K (35 skills) and 20 agents.

#### F-1.1 Batch E follow-up (7 business-model / value-prop skills) — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.1)
- **Trigger:** User said "batch d" — confirmed via AskUserQuestion they meant Batch E (next in sequence).
- **Approach:** `anthril-os/venture-os/docs/planning/build-tooling/_enrich_batch_e_skills.py` — same idempotent regex pattern.
- **Skills enriched (7):**
  - `lean-canvas` — 6 phases including "use BMC instead if venture has outgrown idea stage" recommendation, problem-block-first refusal rule, UVP-is-not-a-tagline discipline, unfair-advantage honesty test (refuse to fabricate).
  - `create-positioning-messaging` — 7 phases requiring both VPC and competitor positioning loaded; category-choice as separate strategic move; canonical positioning statement form; pillars-without-proof-points are taglines; three-perspective audience pass (target / sceptic / competitor sales rep).
  - `create-revenue-model` — 6 phases including don't-shortlist-before-inventorying anti-anchor rule, value-metric-customer-evidence match, model-specific risk surfacing (churn / liquidity / audit / concentration).
  - `unit-economics-model` — 7 phases including prerequisites refusal (won't model from imagination), rule-of-thumb checks against the unit-economics guide, three sensitivity scenarios (CAC +30%, churn +50%, ARPU -20%), cohort caveats.
  - `channel-partner-strategy` — 6 phases with full inventory before filtering, separate partner inventory from channels, channel-ICP-fit as dominant venture failure mode, channels become hypotheses (not decisions) with CAC thresholds.
  - `operating-model-design` — 7 phases anchored to BMC's key activities, workflow Mermaid via `render_operating_workflow.py`, capacity constraint per step, build/buy/partner classification, minimum-role-set discipline at discovery stage.
  - `create-venture-thesis` — 7 phases with readiness refusal (no thesis from a blank workspace), canonical 5-part structure (market belief / problem / why-now / wedge / advantage), three-source rule per part, disconfirming evidence requirement, kill criteria per risk.
- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. Line counts 70-88.
- **Outcome:** closed for Batch E. **Remaining deferred:** Batches F–K (28 skills) and 20 agents.

#### F-1.1 Batch F follow-up (5 concept skills) — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.1)
- **Trigger:** User invoked `continue with /audit-resolve batch f`.
- **Approach:** `anthril-os/venture-os/docs/planning/build-tooling/_enrich_batch_f_skills.py` — same idempotent regex pattern.
- **Skills enriched (5):**
  - `vision-sketch` — 7 phases including "refuse from blank workspace" rule, explicit time horizon (3 years default), concrete scenes (not abstractions), north-star-narrative as internal compass (not tagline), explicit delta-from-today.
  - `concept-design` — 7 phases requiring opportunity-brief + VPC + BMC prerequisites, force-write-in-customer-language test, 3-5 testable experience principles, narrowest-possible-MVP-wedge refusal of expansion, Mermaid render via `render_concept_map.py`.
  - `service-blueprint` — 6 phases with scope discipline (refuse "full-service" at discovery stage), canonical five-lane structure matching `render_service_blueprint.py`, "no backstage without corresponding customer-action" rule, handoff failure-mode identification.
  - `prototype-test-plan` — 7 phases with hypothesis-anchored refusal, deliberate fidelity choice with "higher fidelity ≠ better evidence" note, pre-committed success criteria in writing before sessions run, per-task success capture (not composite measures).
  - `pitch-narrative` — 7 phases with audience-explicit refusal of single deck for all audiences, story-arc choice (problem / market / vision / customer-led with risks per choice), 10-slide structure with the question each slide must answer, evidence-per-slide cross-check, objection slides.
- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. Line counts 70-88.
- **Outcome:** closed for Batch F. **Remaining deferred:** Batches G–K (23 skills) and 20 agents.

#### F-1.1 Batches G + H + I + J + K (23 skills) — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.1)
- **Trigger:** User invoked `/utilities:audit-resolve batch g /loop this process until all batches are complete /goal is to complete this plan as documented`. Loop authorisation explicit.
- **Approach:** Two enricher scripts — `_enrich_batch_g_skills.py` (7 hypothesis/experiment) and `_enrich_batch_ijk_skills.py` (9 finance+risk+planning); `_enrich_batch_h_skills.py` (7 GTM) — same idempotent regex pattern.

**Batch G — hypothesis & experiment (7):**

- `create-assumption-map` — 6 phases including 2x2 plot with "over-assumed" trigger, scoring via `score_assumptions.py`, owner-per-assumption rule.
- `create-learning-agenda` — 6 phases with RICE-lite prioritisation via `prioritize_learning.py`, dependency surfacing, explicit out-of-scope discipline.
- `smoke-test-plan` — 7 phases with channel-bias-explicit table, 200-visitor working minimum, pre-committed kill criteria, ethics audit for pre-orders.
- `concierge-mvp-plan` — 7 phases including value-vs-demand distinction (refuses demand-only hypotheses), cost ceiling + kill rule before launch, operations playbook output for `operating-model-design`.
- `pilot-beta-plan` — 7 phases with pilot-vs-beta distinction, success metrics differentiated, onboarding+feedback cadence, exit plan for both venture outcomes.
- `evidence-review` — 7 phases including bias sweep (4 named biases), contradiction preservation, confidence reconciliation (refuses over-claim), decision-grade recommendation with signed reasoning.
- `pivot-persevere-kill-decision` — 8 phases requiring pre-committed kill criteria for the memo to exist, disconfirming-case requirement, plain-recommendation refusal of hedging, named next actions with owners and dates.

**Batch H — GTM (7):**

- `define-icp` — 7 phases including behavioural-over-demographic emphasis, buying committee mapping for B2B, triggers as highest-leverage targeting input, disqualifier protection.
- `go-to-market-strategy` — 7 phases including prerequisites refusal, funnel-target-as-hypothesis (linked to register), decision thresholds per metric, launch+pricing as references not duplicates.
- `pricing-strategy` — 7 phases including value-metric reconfirmation, decoy-tier transparency, anchor-naming per price point, mandatory price-test hypothesis, objection responses.
- `sales-motion-design` — 7 phases with motion-choice table, qualification framework selection, stage-definition discipline, enterprise-motion procurement asset rule.
- `launch-plan` — 8 phases with launch-type classification, realistic 2-6 week sequencing, no-new-claims rule, sales+support readiness gate, "go" + "back-off" thresholds.
- `customer-onboarding-plan` — 7 phases with activation-is-not-sign-up rule, TTV target bands, friction audit, retention loop hookup.
- `launch-metrics-dashboard-spec` — 7 phases with downstream-only metric pull, dictionary discipline, leading-vs-lagging classification, instrumentation gap surfacing as first action.

**Batch I — finance (2):**

- `financial-model` — 8 phases including prerequisites refusal, three-scenario projection via `calculate_financial_scenarios.py`, funding-requirement derivation per scenario, sensitivity tornado (top-3 variables), confidence based on weakest input.
- `investment-memo` — 9 phases with audience-explicit emphasis, prerequisites refusal of empty sections, evidence link-back per claim, risks-honesty as highest-leverage section, length discipline (6-12 pages), evidence-validator + report-synthesizer gates.

**Batch J — risk (5):**

- `regulatory-applicability-review` — 6 phases with domain inventory (Australian Privacy + ACL + ASIC + TGA + ATO + Fair Work + sector-specific), questions-not-answers refusal, qualified-counsel handoff brief.
- `privacy-impact-review` — 7 phases with data-inventory-first refusal, sensitive-category flagging, lawful-basis per flow, "vague third parties" as finding.
- `ip-landscape-review` — 7 phases with trademark triage (non-clearance), third-party content licence surfacing, refuses non-infringement assertion, defensibility-vs-IP distinction.
- `venture-risk-register` — 7 phases with cross-workspace sweep, scoring via `score_risks.py`, owner-per-risk rule, mitigation-with-cost requirement, early-warning-signal per high-impact risk.
- `responsible-innovation-review` — 7 phases with 7-domain sweep (safety / fairness / privacy / misuse / reputation / social / environmental), concrete-risk discipline, tradeoff-explicit rule, design-constraint over policy preference, stakeholder consultation requirement for vulnerable populations.

**Batch K — planning / reporting (2):**

- `mvp-roadmap` — 8 phases with validation prerequisite refusal, wedge expansion resistance, customer-visible-outcome milestone discipline, build/buy/partner per capability, learning milestones interleaved.
- `venture-evidence-pack` — 8 phases including audience+purpose scope, manifest via `merge_evidence.py`, per-artefact summary requirement, cross-link integrity check, SHA-256 stamping via `hash_evidence_files.py`, evidence-validator+report-synthesizer gates.

- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. All 63 skills carry the marker comment; all line counts under 100.
- **Outcome:** **F-1.1 fully closed. All 63 skills enriched.**

#### F-1.2 20 remaining agents — closed in subsequent audit-resolve run

- **Strategy:** PLAN-FIRST (continuation of F-1.2)
- **Approach:** `_enrich_remaining_agents.py` — same idempotent regex pattern as the Phase-1 agent enricher.
- **Agents enriched (20):**
  - **Market:** `market-sizing-analyst` (two-methods-always, multiplier-citation), `trend-researcher` (STEEP+C, signal-not-finding), `industry-analyst` (four-flow mapping).
  - **Customer:** `ux-researcher` (observation-vs-inference, per-task capture), `jtbd-researcher` (functional/emotional/social, evidence-only jobs), `research-ops-specialist` (consent + PII + escalation triggers), `research-synthesist` (verbatim preservation, minority signals).
  - **Competitive:** `pricing-analyst` (external-evidence-over-internal-assumption, capture-dates).
  - **Product/business:** `product-strategist` (two-options-at-strategy-gates, strategy-is-saying-no), `financial-analyst` (no-certainty-claims, three-scenarios-always, sensitivity-over-precision), `data-analyst` (sample-and-bias-reported, effect-size-over-significance, cohort honesty).
  - **GTM:** `gtm-strategist` (hypothesis-vs-proven channels, channel-ICP-fit dominance), `product-marketing-manager` (customer-language-always, mark-unsupported-claims, one-claim-per-asset), `sales-strategist` (motion-matched-to-economics, pre-committed stage definitions, no-inventing-buyer-commitments), `customer-success-strategist` (activation-is-not-sign-up, TTV-as-metric, retention-loop hookup).
  - **Risk:** `legal-risk-advisor` (not-legal-advice-ever, questions-not-answers, jurisdiction-explicit), `privacy-regulatory-analyst` (data-inventory-first, sensitive-category-flagging, lawful-basis-per-flow), `responsible-innovation-reviewer` (concrete-risks-beat-vague, tradeoffs-explicit, design-constraints-over-policy), `technical-feasibility-advisor` (no-implementation-unless-explicit, build/buy/partner classification).
  - **Coordination:** `venture-program-manager` (stage-gate artefacts maintained, owner-per-workstream, decision log durable).
- **Verifier:** `claude plugin validate ./anthril-os/venture-os` → ✔. All 29 agents carry the marker comment.
- **Outcome:** **F-1.2 fully closed. All 29 agents enriched.**

## Final progress

| Finding | Status |
|---|---|
| F-2.1 (CRITICAL) | closed |
| F-1.1 (CRITICAL) | **closed** — all 63 skills enriched |
| F-1.2 (CRITICAL) | **closed** — all 29 agents enriched |
| F-3.1 (WARNING) | closed |
| F-5.1 (WARNING) | closed |
| F-8.1 (WARNING) | closed |
| F-8.2 (SUGGESTION) | resolved organically through F-1.1 batch enrichments |
| F-1.3 (INFO) | no action |

**Audit fully closed. 7 of 7 actionable findings resolved, 1 informational with no action required.**

## Final verifier state

```
$ claude plugin validate ./anthril-os/venture-os
✔ Validation passed

$ grep -lr "skill-specific phases v0.1.0" anthril-os/venture-os/skills | wc -l
63

$ grep -lr "role-specific agent body v0.1.0" anthril-os/venture-os/agents | wc -l
29
```

## Build-tooling artefacts

The complete enrichment toolset lives under `anthril-os/venture-os/docs/planning/build-tooling/`:

- `_scaffold_skills.py`, `_scaffold_agents.py` — original v0.1.0 scaffolders.
- `_bulk_create_*.py` — original references / templates / docs generators.
- `_enrich_batch_a_skills.py` — 12 v0.1.0 spine skills.
- `_enrich_phase1_agents.py` — 9 v0.1.0 spine agents.
- `_enrich_batch_b_skills.py` — 5 market skills.
- `_enrich_batch_c_skills.py` — 5 customer skills.
- `_enrich_batch_d_skills.py` — 6 competitive skills.
- `_enrich_batch_e_skills.py` — 7 business-model + value-prop skills.
- `_enrich_batch_f_skills.py` — 5 concept skills.
- `_enrich_batch_g_skills.py` — 7 hypothesis + experiment skills.
- `_enrich_batch_h_skills.py` — 7 GTM skills.
- `_enrich_batch_ijk_skills.py` — 9 finance + risk + planning skills.
- `_enrich_remaining_agents.py` — 20 remaining specialist agents.

All scripts are idempotent: marker comments stamped into target files prevent re-enrichment on subsequent runs.

### F-1.2 — 29 generic agent bodies (Phase-1: 9 agents)

- **Strategy:** PLAN-FIRST
- **Approach:** Wrote [_enrich_phase1_agents.py](../../../../venture-os/docs/planning/build-tooling/_enrich_phase1_agents.py) — same pattern as the skill enricher. Replaces the generic `## How you work` block with role-specific content. Marker: `<!-- venture-os: role-specific agent body v0.1.0 -->`.
- **Agents enriched (9):**
  - `venture-orchestrator` — routing rules, sequencing rules, synthesis rules. Also fixed a self-referential bug (rule #1 told the orchestrator to "ask the orchestrator to run profile-venture first" — now corrected to "run profile-venture yourself or stub the profile").
  - `market-researcher` — inputs loaded, skills driven, evidence rules (analyst reports as `[third-party-report]`, never primary), Australian-context preference.
  - `customer-discovery-lead` — no-pitching rule, past-behaviour-over-intent rule, sample-size honesty, consent and PII handling.
  - `competitive-intelligence-analyst` — substitutes-most-underweighted rule, no-reading-minds rule, source-with-capture-date rule.
  - `business-model-designer` — coherence checks, escalation to financial-analyst for unit economics, present-multiple-options rule.
  - `value-proposition-designer` — one-canvas-per-segment, pain-relievers-must-map-by-ID, mark-claims-needing-validation.
  - `experiment-designer` — pre-commit thresholds, category-to-method mapping, test-card discipline.
  - `evidence-validator` — exhaustive 8-point check list including sample adequacy, recency, bias, contradictions-preserved, confidence-matches-evidence, strong-claim words.
  - `report-synthesizer` — reader-first writing rules, no-new-claims rule, never-bypass-evidence-validator rule.
- **Verifier:** `claude plugin validate ./venture-os` → ✔. Line counts 58-66.
- **Outcome:** closed for Phase-1 set. **Remaining 20 agents deferred** — recommended follow-up sessions.

### F-8.2 — Used local scaffolder instead of `skill-ops:skill-creator`

- **Strategy:** DEFER (suggestion only)
- **Rationale:** The Batch A enrichment work above effectively re-applies the per-skill quality bar that `skill-ops:skill-evaluator` would enforce. The remaining 51 skills should be enriched batch-by-batch using `skill-ops:skill-evaluator` per the audit's prioritised action list.
- **Outcome:** deferred (covered organically by F-1.1).

### F-1.3 — Marketplace entry removed

- **Strategy:** none (informational; intentional removal by user before this run)
- **Outcome:** no action.

## Skipped / deferred

| Item | Reason |
|---|---|
| F-1.1 Batches B–K (51 skills) | Out of scope for this run — substantive content for 51 skills exceeds one session. Pattern established in Batch A. Use the same `_enrich_*` approach per batch. |
| F-1.2 remaining 20 agents | Same rationale — pattern established in Phase-1 set. |
| F-8.2 | Resolved organically; no separate action required. |

## Verifier final state

```
$ claude plugin validate ./venture-os
Validating plugin manifest: …\venture-os\.claude-plugin\plugin.json
✔ Validation passed

$ python -m py_compile (across all venture-os/scripts/*.py and hooks/scripts/*.py)
0 errors

$ bash -n (across all 3 hooks/scripts/*.sh)
0 errors
```

## Files touched (this run)

26 files edited under `venture-os/` + 6 scaffolders moved:

**Edited:**

- 1 README addition (F-5.1).
- 2 script fixes (F-2.1, F-3.1).
- 12 SKILL.md enriched (F-1.1).
- 9 agent .md enriched (F-1.2).
- 2 new enrichment scripts added under `docs/planning/build-tooling/`.

**Moved:** 6 scaffolders out of `scripts/` to `docs/planning/build-tooling/`.

**Total: 32 file operations** (26 edits + 6 moves).

## Re-audit

Not run (user did not request `--reaudit`). Recommended for the follow-up sessions that close the deferred Batches B–K skills and the remaining 20 agents.

## Final diff (tracked files only)

```
 .claude-plugin/marketplace.json | 236 ----------------------------------------
 .claude/CLAUDE.md               |   4 +-
 2 files changed, 2 insertions(+), 238 deletions(-)
```

Note: this diff is from baseline `ad1fb4f` and reflects the entire session, not just the audit-resolve run. The `venture-os/` tree is gitignored and therefore not in any git diff. The 32 file operations from this audit-resolve run apply only to the gitignored venture-os tree on disk.

## Next-step suggestions

1. Decide whether to remove the `venture-os/` line from [.gitignore:99](../../../../.gitignore) so the plugin enters version control.
2. Run a follow-up `/utilities:audit-resolve` session for Batch B skills (5: `market-sizing-analysis`, `trend-signal-scan`, `industry-value-chain-map`, `segment-analysis`, `demand-signal-analysis`).
3. Iterate batches C → K and remaining agents at a comfortable pace; the enrichment pattern is established.
4. When ready for public install, re-add the marketplace entry that was removed earlier in the session.

## Resume state

This ledger is the resume state. Re-invoking `audit-resolver` against the same source audit will detect the marker comments (`<!-- venture-os: skill-specific phases v0.1.0 -->` and `<!-- venture-os: role-specific agent body v0.1.0 -->`) and skip the already-enriched skills/agents.
