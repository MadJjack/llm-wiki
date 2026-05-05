---
type: pattern
tags: [metadata, relations, trust, provenance]
created: 2026-05-04
updated: 2026-05-05
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
| Key | Meaning | Weight | Use when |
|---|---|---|---|
| `contradicts` | This page conflicts with the target — review required | 1.0 | A lesson invalidates prior guidance |
| `derived_from` | This page was created based on target; lineage/provenance | 0.9 | A page is compiled from an ingested raw source |
| `depends_on` | This page's claims rely on the target being true | 0.8 | A pattern that only works given a specific data model |
| `part_of` | This page is a component of target | 0.8 | A module page that belongs to a larger system |
| `supports` | This page provides evidence or rationale for the target | 0.7 | Backing up an architectural decision with implementation proof |
| `supersedes` | This page replaces the target (mark old page `status: stale`) | 0.7 | A new pattern replaces a legacy one |
| `related_to` | General non-directional topical association | 0.5 | Related-but-distinct pages that agents should read together |

**Agent traversal order:** Follow weight ≥ 0.8 edges before weight < 0.8 edges. Only follow `related_to` (0.5) if higher-weight paths are exhausted.

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

## Node Types

The `type:` frontmatter field classifies a page's role. The validator requires this field on every wiki page. Two types warrant special guidance:

| Type | Meaning | When to use |
|---|---|---|
| `concept` | A defined term, framework, or principle the agent should reason from | Durable ideas that span multiple modules; prefer over growing `glossary.md` |
| `hypothesis` | A falsifiable architectural assumption with a measurable test | Unvalidated beliefs — between a known unknown (`question`) and a resolved choice (`decision`) |

All other types: `module`, `decision`, `pattern`, `integration`, `lesson`, `troubleshooting`, `architecture`, `api`, `data-model`, `setup`, `reference`.

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
