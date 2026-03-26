# Duplication Consolidation Review

Generated: 2026-03-26

## Scope Reviewed

- parent roll-up docs in `..\docs`
- workshop-local catalog docs in `reference_catalog`
- workshop-local automation scripts in `scripts`

## Duplicate Or Overlapping Content Found

### Parent Docs

- `ai_workshop_resource_system.md`
- `ai_workshop_parent_vs_workshop_boundary_model.md`
- `ai_workshop_codex_execution_standard.md`

These overlap on boundary and drift-prevention rules, but they are intentionally short and serve different parent-level uses:

- resource location summary
- boundary contract
- Codex execution guardrail

Result: kept all three, but left them concise instead of expanding them further.

### Workshop-Local Docs

The following files substantially overlapped with `learning_plan_expansion.md`:

- `exercises_and_activity_bank.md`
- `teen_safe_use_and_parent_controls.md`
- `codex_beginner_segment.md`
- `what_beginners_are_not_told.md`

Result: consolidated into `learning_plan_expansion.md` and removed as standalone workshop-local files.

### Scripts

The following scripts overlapped in purpose:

- `download_public_references.ps1`
- `download_public_references_v2.ps1`
- `download_missing_public_references.ps1`
- `refresh_all.ps1`
- `refresh_all_v2.ps1`

Result: `download_missing_public_references.ps1` remains the canonical download-check script. The legacy download and refresh scripts were reduced to compatibility wrappers so there is one real implementation path to maintain.

## Canonical Maintained Set

### Parent Roll-Up Docs

- `..\docs\ai_workshop_resource_system.md`
- `..\docs\ai_workshop_parent_vs_workshop_boundary_model.md`
- `..\docs\ai_workshop_learning_content_expansion.md`
- `..\docs\ai_workshop_source_validation_matrix.md`
- `..\docs\ai_workshop_codex_execution_standard.md`

### Workshop-Local Catalog Docs

- `detailed_resource_inventory.csv`
- `detailed_resource_inventory.md`
- `source_claim_validation.csv`
- `source_claim_validation.md`
- `slide_candidate_matrix.csv`
- `slide_candidate_matrix.md`
- `learning_plan_expansion.md`
- `workshop_resource_expansion_audit.md`
- `duplication_consolidation_review.md`

### Workshop-Local Canonical Scripts

- `inventory_local_sources.ps1`
- `expand_reference_catalog.ps1`
- `download_missing_public_references.ps1`
- `build_workshop_resource_bundle.ps1`

## Maintenance Outcome

- fewer workshop-local markdown documents
- one workshop-local master learning-plan reference
- one workshop-local canonical download-check path
- less chance of child-root content drift
