# Skill Evaluator — Master Collation

**Date:** 2026-05-23  
**Scope:** engineering-os (257 skills) + venture-os (63 skills) = 320 skills  
**Output dirs:** `.anthril/audits/skill-evaluator/<skill-name>/` (per-skill report + JSON sidecar)  
**Batch summaries:** `_batch-summaries/batch-NN.md`

## Methodology note

All 16 batch subagents downgraded from full mode to **deterministic-only** (helper-script-based) because invoking the Skill tool 20× per agent was not viable in subagent context (the Skill tool returned the evaluator prompt for execution rather than running it). Phase 4 qualitative sub-agent review was skipped across all 320 skills. Score scales vary by agent — some reported out of 85 (true deterministic ceiling), others out of 100 or 91/100 — see individual batch summaries for the scale used.

## Per-batch summaries

### Batch 00

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-agent-system-design | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-ai-data-readiness-review | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-ai-feature-plan | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-ai-risk-assessment | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-human-in-the-loop-process | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-ml-system-design | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-mlops-pipeline | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-model-evaluation-plan | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-model-monitoring-plan | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-prompt-system | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-rag-system-design | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-responsible-ai-controls | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| review-ai-security | 74/100 | C | C20: Referenced path missing: .eng-os/handoffs/eng-ai-to-<target>-<timestamp>.json |
| create-code-review | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| create-engineering-design-doc | 48/100 | D | C20: Referenced path missing: .eng-os/ |
| debug-issue | 81/100 | B | C20: Referenced path missing: .eng-os/handoffs/eng-app-to-<target>-<timestamp>.json |
| implement-api | 62/100 | C | C20: Referenced path missing: .eng-os/decisions/ |
| implement-backend | 62/100 | C | C20: Referenced path missing: .eng-os/decisions/ |
| implement-feature | 62/100 | C | C20: Referenced path missing: .eng-os/decisions/ |
| implement-frontend | 62/100 | C | C20: Referenced path missing: .eng-os/decisions/ |

### Batch 01

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| implement-integration | 85/100 | B | -: No critical issues |
| implement-mobile-feature | 85/100 | B | -: No critical issues |
| implement-sdk | 85/100 | B | -: No critical issues |
| plan-implementation | 85/100 | B | -: No critical issues |
| refactor-module | 85/100 | B | -: No critical issues |
| choose-tech-stack | 85/100 | B | -: No critical issues |
| create-adr | 85/100 | B | -: No critical issues |
| create-api-architecture | 85/100 | B | -: No critical issues |
| create-cloud-architecture | 85/100 | B | -: No critical issues |
| create-data-architecture | 85/100 | B | -: No critical issues |
| create-domain-model | 85/100 | B | -: No critical issues |
| create-integration-architecture | 85/100 | B | -: No critical issues |
| create-nonfunctional-requirements | 85/100 | B | -: No critical issues |
| create-service-boundaries | 85/100 | B | -: No critical issues |
| create-solution-architecture | 85/100 | B | -: No critical issues |
| create-system-architecture | 85/100 | B | -: No critical issues |
| review-architecture-proposal | 85/100 | B | -: No critical issues |
| create-cloud-cost-optimization-plan | 85/100 | B | -: No critical issues |
| create-finops-report | 85/100 | B | -: No critical issues |
| create-legal-handoff-brief | 85/100 | B | -: No critical issues |

### Batch 02

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-open-source-license-handoff | 99/100 | A | None |
| create-procurement-brief | 96/100 | A | C02: description too short (45 chars) |
| create-software-asset-inventory | 96/100 | A | C02: description too short (49 chars) |
| create-technology-budget | 96/100 | A | C02: description too short (46 chars) |
| create-technology-roi-analysis | 96/100 | A | C02: description too short (41 chars) |
| create-unit-economics-model | 99/100 | A | None |
| create-vendor-exit-plan | 96/100 | A | C02: description too short (31 chars) |
| create-vendor-renewal-review | 96/100 | A | C02: description too short (27 chars) |
| create-vendor-selection-scorecard | 99/100 | A | None |
| create-cross-plugin-handoff | 99/100 | A | None |
| create-decision-log | 99/100 | A | None |
| create-engineering-glossary | 99/100 | A | None |
| create-risk-and-dependency-map | 96/100 | A | C02: description too short (30 chars) |
| create-service-catalog | 99/100 | A | None |
| create-system-context-pack | 99/100 | A | None |
| generate-work-breakdown | 96/100 | A | C02: description too short (27 chars) |
| profile-organization | 96/100 | A | C02: description too short (33 chars) |
| profile-product-system | 96/100 | A | C02: description too short (32 chars) |
| profile-tech-stack | 96/100 | A | C02: description too short (31 chars) |
| validate-engineering-context | 99/100 | A | None |

### Batch 03

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-customer-health-technical-review | 100/100 | A | none |
| create-customer-runbook | 100/100 | A | none |
| create-customer-solution-design | 100/100 | A | none |
| create-enterprise-onboarding-checklist | 100/100 | A | none |
| create-escalation-brief | 100/100 | A | none |
| create-implementation-plan | 100/100 | A | none |
| create-integration-guide | 100/100 | A | none |
| create-partner-integration-plan | 100/100 | A | none |
| create-rfp-security-response | 100/100 | A | none |
| create-support-triage | 100/100 | A | none |
| create-technical-qbr | 100/100 | A | none |
| debug-customer-issue | 100/100 | A | none |
| create-analytics-model | 100/100 | A | none |
| create-dashboard-spec | 100/100 | A | none |
| create-data-governance-handoff | 100/100 | A | none |
| create-data-lineage-map | 100/100 | A | none |
| create-data-pipeline-plan | 100/100 | A | none |
| create-data-platform-architecture | 100/100 | A | none |
| create-data-quality-rules | 100/100 | A | none |
| create-event-taxonomy | 100/100 | A | none |

### Batch 04

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-executive-reporting-model | 84/85 | A | No fail-level findings |
| create-experiment-analysis-plan | 84/85 | A | No fail-level findings |
| create-metrics-layer | 84/85 | A | No fail-level findings |
| create-product-analytics-plan | 84/85 | A | No fail-level findings |
| review-data-contract | 83/85 | A | C41-45 1 anti-pattern hit(s) |
| choose-database-technology | 84/85 | A | No fail-level findings |
| create-backup-strategy | 84/85 | A | No fail-level findings |
| create-data-model | 84/85 | A | No fail-level findings |
| create-data-retention-plan | 84/85 | A | No fail-level findings |
| create-database-reliability-plan | 84/85 | A | No fail-level findings |
| create-indexing-strategy | 84/85 | A | No fail-level findings |
| create-migration-plan | 84/85 | A | No fail-level findings |
| design-database-schema | 84/85 | A | No fail-level findings |
| design-multitenancy-model | 84/85 | A | No fail-level findings |
| optimize-query | 84/85 | A | No fail-level findings |
| review-database-design | 83/85 | A | C41-45 1 anti-pattern hit(s) |
| create-component-spec | 84/85 | A | No fail-level findings |
| create-design-system-plan | 84/85 | A | No fail-level findings |
| create-information-architecture | 84/85 | A | No fail-level findings |
| create-interaction-spec | 84/85 | A | No fail-level findings |
| create-executive-reporting-model | 84/85 | A | No fail-level findings |
| create-experiment-analysis-plan | 84/85 | A | No fail-level findings |
| create-metrics-layer | 84/85 | A | No fail-level findings |
| create-product-analytics-plan | 84/85 | A | No fail-level findings |
| review-data-contract | 83/85 | A | C41-45 1 anti-pattern hit(s) |
| choose-database-technology | 84/85 | A | No fail-level findings |
| create-backup-strategy | 84/85 | A | No fail-level findings |
| create-data-model | 84/85 | A | No fail-level findings |
| create-data-retention-plan | 84/85 | A | No fail-level findings |
| create-database-reliability-plan | 84/85 | A | No fail-level findings |
| create-indexing-strategy | 84/85 | A | No fail-level findings |
| create-migration-plan | 84/85 | A | No fail-level findings |
| design-database-schema | 84/85 | A | No fail-level findings |
| design-multitenancy-model | 84/85 | A | No fail-level findings |
| optimize-query | 84/85 | A | No fail-level findings |
| review-database-design | 83/85 | A | C41-45 1 anti-pattern hit(s) |
| create-component-spec | 84/85 | A | No fail-level findings |
| create-design-system-plan | 84/85 | A | No fail-level findings |
| create-information-architecture | 84/85 | A | No fail-level findings |
| create-interaction-spec | 84/85 | A | No fail-level findings |
| create-executive-reporting-model | 84/85 | A | No fail-level findings |
| create-experiment-analysis-plan | 84/85 | A | No fail-level findings |
| create-metrics-layer | 84/85 | A | No fail-level findings |
| create-product-analytics-plan | 84/85 | A | No fail-level findings |
| review-data-contract | 83/85 | A | C41-45 1 anti-pattern hit(s) |
| choose-database-technology | 84/85 | A | No fail-level findings |
| create-backup-strategy | 84/85 | A | No fail-level findings |
| create-data-model | 84/85 | A | No fail-level findings |
| create-data-retention-plan | 84/85 | A | No fail-level findings |
| create-database-reliability-plan | 84/85 | A | No fail-level findings |
| create-indexing-strategy | 84/85 | A | No fail-level findings |
| create-migration-plan | 84/85 | A | No fail-level findings |
| design-database-schema | 84/85 | A | No fail-level findings |
| design-multitenancy-model | 84/85 | A | No fail-level findings |
| optimize-query | 84/85 | A | No fail-level findings |
| review-database-design | 83/85 | A | C41-45 1 anti-pattern hit(s) |
| create-component-spec | 84/85 | A | No fail-level findings |
| create-design-system-plan | 84/85 | A | No fail-level findings |
| create-information-architecture | 84/85 | A | No fail-level findings |
| create-interaction-spec | 84/85 | A | No fail-level findings |

### Batch 05

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-journey-map | 100/100 | A | none |
| create-personas | 100/100 | A | none |
| create-research-plan | 100/100 | A | none |
| create-service-blueprint | 100/100 | A | none |
| create-usability-test-plan | 100/100 | A | none |
| create-wireframe-spec | 100/100 | A | none |
| review-accessibility | 99/100 | A | [warn] anti-patterns (1) |
| synthesize-research | 100/100 | A | none |
| write-ux-copy | 100/100 | A | none |
| create-cd-pipeline | 100/100 | A | none |
| create-change-record | 100/100 | A | none |
| create-ci-pipeline | 100/100 | A | none |
| create-deployment-runbook | 100/100 | A | none |
| create-environment-strategy | 100/100 | A | none |
| create-feature-flag-plan | 100/100 | A | none |
| create-release-notes-input | 100/100 | A | none |
| create-release-plan | 100/100 | A | none |
| create-rollback-plan | 100/100 | A | none |
| create-versioning-strategy | 100/100 | A | none |
| review-pipeline | 99/100 | A | [warn] anti-patterns (1) |

### Batch 06

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-docs-information-architecture | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-docs-maintenance-plan | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-knowledge-base | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-training-plan | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| review-docs-quality | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| write-api-documentation | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| write-developer-guide | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| write-release-notes | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| write-runbook | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| write-technical-documentation | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| write-tutorial | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-architecture-governance-model | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-capability-maturity-model | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-engineering-operating-model | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-executive-briefing | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-executive-decision-memo | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-risk-executive-summary | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-technology-investment-plan | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-technology-kpi-framework | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |
| create-technology-portfolio-review | 100/100 | A | C33:no-license (LICENSE.txt missing — info-level) |

### Batch 07

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-technology-roadmap | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-technology-strategy | 89/100 | B | [info] C33: Missing LICENSE.txt |
| evaluate-build-buy-partner | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-business-continuity-plan | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-compliance-evidence-plan | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-control-exception-process | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-control-framework | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-data-governance-model | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-policy | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-privacy-impact-assessment | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-records-retention-schedule | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-regulatory-applicability-review | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-risk-register | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-third-party-risk-program | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-vendor-risk-review | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-device-management-plan | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-employee-onboarding-automation | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-enterprise-app-integration-plan | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-identity-lifecycle-plan | 89/100 | B | [info] C33: Missing LICENSE.txt |
| create-internal-support-knowledge-base | 89/100 | B | [info] C33: Missing LICENSE.txt |

### Batch 08

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-it-asset-inventory | 97/100 | A | No deterministic issues |
| create-it-change-plan | 97/100 | A | No deterministic issues |
| create-it-operating-model | 97/100 | A | No deterministic issues |
| create-saas-governance-plan | 97/100 | A | No deterministic issues |
| create-saas-offboarding-plan | 97/100 | A | No deterministic issues |
| create-service-desk-process | 97/100 | A | No deterministic issues |
| create-build-system-plan | 97/100 | A | No deterministic issues |
| create-dev-environment-plan | 97/100 | A | No deterministic issues |
| create-developer-onboarding-flow | 97/100 | A | No deterministic issues |
| create-developer-portal-spec | 97/100 | A | No deterministic issues |
| create-golden-path | 97/100 | A | No deterministic issues |
| create-idp-plan | 97/100 | A | No deterministic issues |
| create-platform-api | 97/100 | A | No deterministic issues |
| create-service-catalog-model | 97/100 | A | No deterministic issues |
| create-service-template | 97/100 | A | No deterministic issues |
| create-tooling-cli-plan | 97/100 | A | No deterministic issues |
| measure-developer-productivity | 97/100 | A | No deterministic issues |
| create-experiment-plan | 97/100 | A | No deterministic issues |
| create-feature-brief | 97/100 | A | No deterministic issues |
| create-opportunity-solution-tree | 97/100 | A | No deterministic issues |

### Batch 09

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-product-metrics-tree | 93/100 | A | C33: LICENSE.txt missing |
| create-product-strategy | 93/100 | A | C33: LICENSE.txt missing |
| create-release-scope | 93/100 | A | C33: LICENSE.txt missing |
| create-user-story-map | 93/100 | A | C33: LICENSE.txt missing |
| prioritize-roadmap | 93/100 | A | C33: LICENSE.txt missing |
| run-product-discovery | 93/100 | A | C33: LICENSE.txt missing |
| write-prd | 93/100 | A | C33: LICENSE.txt missing |
| write-technical-prd | 93/100 | A | C33: LICENSE.txt missing |
| create-accessibility-test-plan | 93/100 | A | C33: LICENSE.txt missing |
| create-automated-test-suite | 93/100 | A | C33: LICENSE.txt missing |
| create-compatibility-test-matrix | 93/100 | A | C33: LICENSE.txt missing |
| create-e2e-tests | 93/100 | A | C33: LICENSE.txt missing |
| create-performance-test-plan | 93/100 | A | C33: LICENSE.txt missing |
| create-release-quality-gate | 93/100 | A | C33: LICENSE.txt missing |
| create-test-data-plan | 93/100 | A | C33: LICENSE.txt missing |
| create-test-plan | 93/100 | A | C33: LICENSE.txt missing |
| create-test-strategy | 93/100 | A | C33: LICENSE.txt missing |
| create-uat-plan | 93/100 | A | C33: LICENSE.txt missing |
| triage-defects | 93/100 | A | C33: LICENSE.txt missing |
| create-cloud-security-plan | 93/100 | A | C33: LICENSE.txt missing |

### Batch 10

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-detection-rules | 91/100 | A | C33 Add LICENSE.txt |
| create-iam-design | 91/100 | A | C33 Add LICENSE.txt |
| create-red-team-test-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-security-architecture | 91/100 | A | C33 Add LICENSE.txt |
| create-security-automation | 91/100 | A | C33 Add LICENSE.txt |
| create-security-incident-playbook | 91/100 | A | C33 Add LICENSE.txt |
| create-supply-chain-security-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-threat-model | 91/100 | A | C33 Add LICENSE.txt |
| create-vulnerability-management-plan | 91/100 | A | C33 Add LICENSE.txt |
| review-application-security | 91/100 | A | C33 Add LICENSE.txt |
| analyze-production-incident | 91/100 | A | C33 Add LICENSE.txt |
| create-alerting-strategy | 91/100 | A | C33 Add LICENSE.txt |
| create-backup-restore-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-capacity-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-disaster-recovery-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-incident-response-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-observability-plan | 91/100 | A | C33 Add LICENSE.txt |
| create-operational-readiness-review | 91/100 | A | C33 Add LICENSE.txt |
| create-postmortem | 91/100 | A | C33 Add LICENSE.txt |
| create-runbook | 91/100 | A | C33 Add LICENSE.txt |

### Batch 11

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| create-slo-framework | 98/100 | A | No critical fixes identified |
| create-cross-functional-raci | 98/100 | A | No critical fixes identified |
| create-delivery-risk-register | 98/100 | A | No critical fixes identified |
| create-dependency-map | 98/100 | A | No critical fixes identified |
| create-execution-dashboard | 98/100 | A | No critical fixes identified |
| create-launch-readiness-plan | 98/100 | A | No critical fixes identified |
| create-milestone-plan | 98/100 | A | No critical fixes identified |
| create-program-plan | 98/100 | A | No critical fixes identified |
| create-project-plan | 98/100 | A | No critical fixes identified |
| create-retrospective | 98/100 | A | No critical fixes identified |
| create-rituals-and-cadence | 98/100 | A | No critical fixes identified |
| create-stakeholder-update | 98/100 | A | No critical fixes identified |
| accessibility-review | 80/100 | B | C29 Missing templates/ directory |
| ai-ml-assurance-review | 80/100 | B | C29 Missing templates/ directory |
| application-security-assessment | 80/100 | B | C29 Missing templates/ directory |
| audit-report-builder | 80/100 | B | C29 Missing templates/ directory |
| backup-dr-review | 80/100 | B | C29 Missing templates/ directory |
| cloud-infrastructure-audit | 80/100 | B | C29 Missing templates/ directory |
| continuous-control-check | 80/100 | B | C29 Missing templates/ directory |
| data-privacy-governance-review | 80/100 | B | C29 Missing templates/ directory |

### Batch 12

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| database-performance-review | 65/100 | C | C29 fail: templates/ missing or empty |
| dependency-supply-chain-audit | 65/100 | C | C29 fail: templates/ missing or empty |
| evidence-pack-builder | 65/100 | C | C29 fail: templates/ missing or empty |
| iam-access-review | 65/100 | C | C29 fail: templates/ missing or empty |
| iso27001-readiness-assessment | 65/100 | C | C29 fail: templates/ missing or empty |
| migrate-anthril | 65/100 | C | C29 fail: templates/ missing or empty |
| observability-monitoring-review | 65/100 | C | C29 fail: templates/ missing or empty |
| pci-readiness-assessment | 65/100 | C | C29 fail: templates/ missing or empty |
| performance-scalability-assessment | 65/100 | C | C29 fail: templates/ missing or empty |
| profile-application | 65/100 | C | C29 fail: templates/ missing or empty |
| reliability-sre-review | 65/100 | C | C29 fail: templates/ missing or empty |
| remediation-roadmap-builder | 65/100 | C | C29 fail: templates/ missing or empty |
| run-assurance-audit | 65/100 | C | C29 fail: templates/ missing or empty |
| secrets-configuration-audit | 65/100 | C | C29 fail: templates/ missing or empty |
| secure-code-review | 65/100 | C | C29 fail: templates/ missing or empty |
| soc2-readiness-assessment | 65/100 | C | C29 fail: templates/ missing or empty |
| vendor-risk-review | 65/100 | C | C29 fail: templates/ missing or empty |
| business-model-canvas | 70/100 | C | No critical issues |
| channel-partner-strategy | 70/100 | C | No critical issues |
| competitor-landscape-analysis | 70/100 | C | No critical issues |

### Batch 13

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| concept-design | 84/100 | B | C09: Missing required field: name |
| concierge-mvp-plan | 84/100 | B | C09: Missing required field: name |
| create-assumption-map | 83/100 | B | C09: Missing required field: name |
| create-customer-discovery-plan | 84/100 | B | C09: Missing required field: name |
| create-customer-journey-map | 84/100 | B | C09: Missing required field: name |
| create-hypothesis-register | 85/100 | B | C09: Missing required field: name |
| create-interview-guide | 84/100 | B | C09: Missing required field: name |
| create-jtbd-map | 82/100 | B | C09: Missing required field: name |
| create-learning-agenda | 82/100 | B | C09: Missing required field: name |
| create-opportunity-brief | 87/100 | B | C09: Missing required field: name |
| create-personas-archetypes | 84/100 | B | C09: Missing required field: name |
| create-positioning-messaging | 83/100 | B | C09: Missing required field: name |
| create-revenue-model | 84/100 | B | C09: Missing required field: name |
| create-stage-gate-decision-pack | 83/100 | B | C09: Missing required field: name |
| create-venture-thesis | 85/100 | B | C09: Missing required field: name |
| customer-onboarding-plan | 84/100 | B | C09: Missing required field: name |
| define-icp | 81/100 | B | C09: Missing required field: name |
| demand-signal-analysis | 83/100 | B | C09: Missing required field: name |
| design-experiment | 84/100 | B | C09: Missing required field: name |
| evidence-review | 83/100 | B | C09: Missing required field: name |

### Batch 14

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| feature-comparison-analysis | 85/85 | A | No issues detected |
| financial-model | 85/85 | A | No issues detected |
| go-to-market-strategy | 85/85 | A | No issues detected |
| industry-value-chain-map | 85/85 | A | No issues detected |
| investment-memo | 85/85 | A | No issues detected |
| ip-landscape-review | 85/85 | A | No issues detected |
| launch-metrics-dashboard-spec | 85/85 | A | No issues detected |
| launch-plan | 85/85 | A | No issues detected |
| lean-canvas | 85/85 | A | No issues detected |
| market-landscape-research | 85/85 | A | No issues detected |
| market-sizing-analysis | 85/85 | A | No issues detected |
| mvp-roadmap | 85/85 | A | No issues detected |
| operating-model-design | 85/85 | A | No issues detected |
| pilot-beta-plan | 85/85 | A | No issues detected |
| pitch-narrative | 85/85 | A | No issues detected |
| pivot-persevere-kill-decision | 85/85 | A | No issues detected |
| positioning-map | 85/85 | A | No issues detected |
| pricing-packaging-analysis | 85/85 | A | No issues detected |
| pricing-strategy | 85/85 | A | No issues detected |
| privacy-impact-review | 85/85 | A | No issues detected |

### Batch 15

| Skill | Score | Grade | Top Fix |
|-------|-------|-------|---------|
| profile-venture | 92/115 | B | C20 verify schemas/venture-profile.schema.json reference |
| segment-analysis | 92/115 | B | Trim shared boilerplate from description tail |
| review-mining-analysis | 91/115 | B | Clarify rate-limit and ToS handling for review scraping in body |
| synthesize-customer-interviews | 92/115 | B | Add PII redaction guidance in body for interview notes |
| value-proposition-canvas | 91/115 | B | Trim shared boilerplate from description tail |
| run-discovery-sprint | 92/115 | B | Document orchestration handoffs to sibling skills in body |
| vision-sketch | 90/115 | B | Trim shared boilerplate; clarify deliverable distinction from value-prop |
| venture-evidence-pack | 92/115 | B | Document linkage to all sibling artefacts being compiled |
| service-blueprint | 91/115 | B | Trim shared boilerplate from description tail |
| white-space-analysis | 92/115 | B | Trim shared boilerplate from description tail |
| sales-motion-design | 91/115 | B | Trim shared boilerplate; specify which motion types are in scope |
| smoke-test-plan | 91/115 | B | Add ethical/disclosure note for waitlist/pre-order smoke tests |
| prototype-test-plan | 91/115 | B | Trim boilerplate at desc tail; front-load unique trigger |
| substitute-analysis | 91/115 | B | Trim shared boilerplate from description tail |
| unit-economics-model | 93/115 | B | Add explicit assumptions vs evidence delineation for CAC/LTV inputs |
| regulatory-applicability-review | 90/115 | B | Add explicit 'not legal advice' disclaimer earlier in description |
| voice-of-customer-analysis | 91/115 | B | Add PII redaction guidance for support tickets/calls |
| responsible-innovation-review | 91/115 | B | Trim shared boilerplate from description tail |
| trend-signal-scan | 91/115 | B | Trim shared boilerplate from description tail |
| venture-risk-register | 91/115 | B | Trim shared boilerplate from description tail |

