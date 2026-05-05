---
type: troubleshooting
tags: [validator, symptom-index, task-router]
symptoms:
  - "Symptom Index entry must point to troubleshooting/ or lessons/: architecture/overview"
  - "Symptom Index entry must point to troubleshooting/ or lessons/: patterns/software-design-checklist"
error_codes: []
affects: [scripts/validate-wiki.sh, wiki/index.md]
triggers: [adding a markdown table after the Symptom Index]
created: 2026-05-04
updated: 2026-05-04
status: current
relations:
  supports: []
  depends_on: []
  supersedes: []
  contradicts: []
  related_to: []
confidence: high
verified_at: 2026-05-04
verification_method: live-observation
owner: ""
---

# Symptom Index Parser Reads Task Router

> The wiki validator can misread later `wiki/index.md` tables as Symptom Index rows if Symptom Index parsing is not scoped to that section.

## Symptoms

- `Symptom Index entry must point to troubleshooting/ or lessons/: architecture/overview`
- `Symptom Index entry must point to troubleshooting/ or lessons/: patterns/software-design-checklist`
- Validator reports normal wiki pages from the Task Router as invalid Symptom Index entries.

## Cause

The validator's Symptom Index row reader scanned table rows across `wiki/index.md` instead of stopping at the end of the Symptom Index section. Adding another table after the Symptom Index exposed the parser scope bug.

## Fix

Scope `active_symptom_index_rows` in `scripts/validate-wiki.sh` to rows between `## Symptom Index` and the next section separator or heading. Then rerun `bash scripts/validate-wiki.sh`.

## Related

- [[index]]
- [[troubleshooting/_index]]
