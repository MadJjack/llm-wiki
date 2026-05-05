---
type: pattern
tags: [metadata, relations, trust, provenance]
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
verification_method: manual-review
owner: ""
---

# Wiki Metadata Model

> Typed relation links and trust/provenance metadata make wiki pages machine-navigable and confidence-weighted for AI agents.

## Overview

AI agents reading this wiki face four structural limitations in plain text knowledge bases: monolithic notes, untyped links, missing trust signals, and no scoped retrieval. This repo addresses all four:

1. **Monolithic notes** — mitigated by the category/index structure, Task Router, and section requirements
2. **Untyped links** — solved by the `relations:` frontmatter field with a typed vocabulary
3. **No trust metadata** — solved by `confidence`, `verified_at`, `verification_method`, and `owner` fields
4. **No scoped retrieval** — solved by the Symptom Index (grep-first) and Task Router (shape-first routing) in `wiki/index.md`

---

## Relation Type Vocabulary

Add a `relations:` block to any page's YAML frontmatter. Keys must be from this vocabulary:

| Key | Meaning | Use when |
|---|---|---|
| `supports` | This page provides evidence or rationale for the target | Backing up an architectural decision with implementation proof |
| `depends_on` | This page's claims rely on the target being true | A pattern that only works given a specific data model |
| `supersedes` | This page replaces the target | A new pattern replaces a legacy one (mark old page `status: stale`) |
| `contradicts` | This page conflicts with the target — review required | A lesson that invalidates prior guidance |
| `related_to` | General non-directional association | Related-but-distinct pages that agents should read together |

Values use `[[wikilink]]` syntax. The validator checks that targets resolve to existing files.

**Example:**
```yaml
relations:
  supports:
    - "[[decisions/template]]"
  depends_on:
    - "[[data-model/_index]]"
  related_to:
    - "[[patterns/clean-code-checklist]]"
```

---

## Trust Metadata Fields

Every page SHOULD carry these fields. Pages of type `architecture`, `decision`, `integration`, `troubleshooting`, and `lesson` MUST carry them (the validator enforces this).

| Field | Values | Required on |
|---|---|---|
| `confidence` | `high \| medium \| low \| unverified` | All required types |
| `verified_at` | `YYYY-MM-DD` | All required types |
| `verification_method` | `manual-review \| automated-test \| live-observation \| unverified` | All required types |
| `owner` | freeform string | Optional everywhere |

### Confidence levels

| Value | Meaning |
|---|---|
| `high` | Claims confirmed by test, live observation, or explicit review |
| `medium` | Likely correct; inferred from a secondary source or partial evidence |
| `low` | Plausible but untested; use with caution |
| `unverified` | Default for newly created pages; promote after review |

### Verification methods

| Value | Meaning |
|---|---|
| `manual-review` | A human explicitly reviewed and confirmed the content |
| `automated-test` | A passing test proves the claim |
| `live-observation` | Observed directly in a running system |
| `unverified` | No verification performed yet |

---

## When to Fill / Promote

**Creating a page:** Set `confidence: unverified` and `verification_method: unverified`. Set `verified_at` to today.

**After an explicit review:** Promote `confidence` to `high` or `medium`, update `verification_method`, and update `verified_at` to today.

**When linting:** Flag `confidence: unverified` pages that are more than 90 days old — they should be reviewed or marked `status: stale`.

---

## How Agents Use This

**Querying:** After the Task Router routes to first-hop pages, use `relations.supports` and `relations.depends_on` to find corroborating pages. Prefer `confidence: high` pages for authoritative answers; flag `low` or `unverified` pages explicitly in the response.

**Ingesting:** Set `verified_at` from the source document's date. Set `confidence: high` for authoritative primary sources; `medium` for summaries or secondary sources.

**Linting:** Flag any page of type architecture/decision/integration/troubleshooting/lesson that is missing `confidence`, `verified_at`, or `verification_method`. Flag `relations:` entries whose `[[wikilink]]` targets do not resolve.

---

## Related

- [[index]]
- [[patterns/_index]]

## Sources

- CLAUDE.md Rule 7 — 2026-05-04
