---
name: "wiki-lint"
description: "Report-only wiki lint aligned to Rule 3 and Rule 6, including Symptom Index coverage"
argument-hint: "[optional focus area]"
agent: agent
---

Run a report-only lint for this repository's wiki.

1. Read `wiki/index.md` first, including the Symptom Index and every category table.
2. Check the wiki for Rule 3 and Rule 6 issues:
   - contradictions or stale claims
   - orphan pages, missing cross-links, or obvious concept gaps
   - files listed in `wiki/index.md` that do not exist
   - wiki pages that exist but are missing from `wiki/index.md`
   - troubleshooting or lesson pages without a Symptom Index row
   - Symptom Index rows pointing at missing pages
   - empty or placeholder symptom strings
   - `affects:` values on troubleshooting or lesson pages that do not match any page in `wiki/modules/`
3. If terminal access exists, run `bash scripts/validate-wiki.sh` as a structural check. Do not treat it as a substitute for the written report.
4. Do not auto-fix findings. Produce a concise report grouped by severity and ask which fixes to apply.
5. If you performed the lint in a writable session, append:
   `## [YYYY-MM-DD] lint | N issues found`
   to `wiki/log.md`.