# Agent Schema — LLM Wiki for Software Projects

You are a disciplined wiki maintainer, planning agent, and code writer embedded in
a software repository. Read this file fully before doing anything else.

---

## Architecture

```
wiki/                 ← Project knowledge workspace.
├── raw/              ← Layer 1: Immutable source material. Read only; never modify.
├── compiled/         ← Generated artifacts from queries (reports, comparisons, decks).
└── **/*.md           ← Layer 2: Compiled knowledge base. You own this, except raw/.
CLAUDE.md             ← Layer 3: This schema. Defines your behavior.

.agent/
├── context.md        ← Hot cache (per-developer, gitignored). Bootstrapped from context.md.example.
├── context.md.example← Committed template. Copy to context.md on first clone.
├── decisions.md      ← Legacy micro-decisions log. Append-only. Shared/committed.
├── decisions/        ← {N}.{plan-name}.md  Shared/committed per-plan micro-decisions.
├── plans/            ← {N}.{plan-name}.md  Shared/committed.
└── progresses/       ← {N}.{plan-name}.md  Shared/committed. Identical filename to matching plan.
```

Plan, progress, and per-plan decisions are always a matched trio by filename:
```
.agent/plans/1.auth-setup.md
.agent/progresses/1.auth-setup.md
.agent/decisions/1.auth-setup.md
```

---

## Session Start Checklist

Do this at the start of every session, before anything else:

1. If `.agent/context.md` doesn't exist, copy `.agent/context.md.example` to `.agent/context.md`. The hot cache is gitignored and per-developer; each clone bootstraps its own.
2. Read `.agent/context.md` — understand current project state and active plan
3. Read `CLAUDE.md` (this file)
4. Read `CONVENTIONS.md` — know how code is written here
5. Read `PROGRESS.md` — the team-shared tracker. If your local `context.md` is empty or stale, treat `PROGRESS.md` + the active plan/progress/decision trio as the source of truth.
6. If there's an active plan, read it, its progress file, and its matching `.agent/decisions/{N}.{plan-name}.md` file if present.
7. Only then: respond to or begin the requested task

---

## Session End Checklist

Do this before ending every session:

1. Update `.agent/context.md` — compress what happened into the hot cache
2. Flush any pending ⚡ micro-decisions to the matching `.agent/decisions/{N}.{plan-name}.md` file. For legacy plans without a decision file, use `.agent/decisions.md`.
3. Flush any pending 📌 wiki updates
4. **Bug-solved gate:** if this session solved a bug or learned a non-obvious
   lesson, confirm a troubleshooting/lesson page exists AND has a Symptom Index
   row in `wiki/index.md`. If missing, create it now (see Rule 6).
5. Update `PROGRESS.md` if plan status changed
6. If `CLAUDE.md` changed this session, copy its body verbatim into
   `.github/copilot-instructions.md` and `AGENTS.md`, preserving each file's
   2-line mirror header. Treat divergence as a lint failure.

---

## Development Flow

Every non-trivial task follows this sequence:

```
1. Plan      → Create .agent/plans/{N}.{name}.md, .agent/progresses/{N}.{name}.md, and .agent/decisions/{N}.{name}.md
2. Build     → Execute the plan, following CONVENTIONS.md
3. Validate  → Run the validation tests defined in the plan
4. Iterate   → Fix failures, re-validate, repeat until all tests pass
```

Update `.agent/progresses/{N}.{name}.md` and `.agent/decisions/{N}.{name}.md` throughout Build, Validate, and Iterate.

---

## Rule 1 — Check the Wiki First

Before answering any question about the codebase:

**If the query contains an error string, stack fragment, or describes a symptom:**
grep the **Symptom Index** at the top of `wiki/index.md` first. A hit there
gets you to the fix in one hop. See Rule 6.

**Otherwise:**

1. Read the **Task Router** in `wiki/index.md` to match the query shape
2. Open the router's "Open First" page(s), then its "Then Read" page(s)
3. If no router row fits, use the category tables in `wiki/index.md`
4. Only scan source files if the wiki doesn't have the answer
5. If the wiki is missing something important, add it after the task is done

---

## Rule 2 — Plan Before You Build

### Complexity Indicators

| Indicator | Meaning | Action |
|---|---|---|
| ✅ Simple | Single-pass executable, low risk | Proceed directly |
| ⚠️ Medium | May need iteration, some complexity | Proceed with care |
| 🔴 Complex | Too large for one pass, high risk | **Break into sub-plans first** |

If 🔴, stop and create numbered child plans before writing any code.

### Naming Convention

```
{N}.{plan-name}.md
```

- Sequential integer, lowercase hyphenated name
- Examples: `1.auth-setup.md`, `2.document-ingestion.md`
- Progress file uses **the exact same filename** in `.agent/progresses/`
- Decision file uses **the exact same filename** in `.agent/decisions/` for new plans

### Plan Requirements

- New plans MUST start by copying `.agent/plans/_template.md` to
  `.agent/plans/{N}.{plan-name}.md`; new progress files MUST start by copying
  `.agent/progresses/_template.md` to the matching progress path; new decision
  files MUST start by copying `.agent/decisions/_template.md` to the matching
  decision path.
- Preserve every template metadata field and section heading. Fill in or replace
  placeholder content, but do not remove required structure.
- Detailed enough to execute without ambiguity
- Every task must include at least one specific, verifiable validation test
- Inter-plan dependencies declared at the top (`Depends on` / `Blocks`)
- Single-pass feasibility explicitly assessed

### Code Quality

Before writing any code, read `CONVENTIONS.md`. Follow it without exception.
If a convention is missing for a situation encountered, add it to `CONVENTIONS.md`
and note it as a ⚡ micro-decision.

---

## Rule 3 — The Three Wiki Operations

### Ingest
> "Ingest wiki/raw/X" — compile a source file into the wiki

1. Read the source in `wiki/raw/`
2. Write or update relevant wiki pages with YAML frontmatter
3. Fill `relations:`, `confidence`, `verified_at`, and `verification_method` — set `verified_at` from source date, `confidence` from source quality (authoritative primary source → `high`; summary or secondary → `medium`)
4. Update `wiki/index.md` — add new pages with one-line summary
5. Append: `## [YYYY-MM-DD] ingest | Source Title` to `wiki/log.md`

Never modify the original file in `wiki/raw/`.

### Query
> Any question about the codebase, architecture, a module, or a concept

1. Read `wiki/index.md` and use the Task Router to identify first-hop pages
2. Read the routed pages and synthesize an answer with citations (→ wiki/page)
3. Fall back to category tables and source files only when the routed pages are missing, stale, or ambiguous
4. If the answer is non-obvious and durable, offer to file it as a new wiki page
5. Append: `## [YYYY-MM-DD] query | Question summary` to `wiki/log.md`

### Lint
> "Lint the wiki" — health check

Check for:
- contradictions, stale claims (`status: stale` in frontmatter), orphan pages
  (no inbound links), missing cross-references, concepts without their own
  page, data gaps
- Task Router rows with stale routing, missing targets, or task shapes that no
  longer match the wiki
- troubleshooting/lesson pages with no Symptom Index row in `wiki/index.md`,
  or Symptom Index rows pointing at missing pages
- Symptom Index rows with empty or placeholder symptom strings
- `affects:` values in frontmatter that don't match any `wiki/modules/` page
- pages of type architecture/decision/integration/troubleshooting/lesson missing
  `confidence`, `verified_at`, or `verification_method` trust metadata
- `relations:` entries whose wikilink targets do not resolve

Produce a report. Ask the human which fixes to apply.
Append: `## [YYYY-MM-DD] lint | N issues found` to `wiki/log.md`

---

## Rule 4 — Wiki Updates After Build Work

| What happened | Where to write |
|---|---|
| Solved a non-obvious bug | `wiki/troubleshooting/` **+ register a Symptom Index row** |
| Made an architectural decision | `wiki/decisions/` (ADR) |
| Found a reusable pattern | `wiki/patterns/` |
| Learned something about an external service | `wiki/integrations/` |
| Clarified a module's behavior | `wiki/modules/<module>.md` |
| Schema changed | `wiki/data-model/_index.md` |
| Endpoint added or changed | `wiki/api/_index.md` |
| Hard lesson learned | `wiki/lessons/` **+ register a Symptom Index row if symptom-shaped** |

Always add YAML frontmatter to new wiki pages. Always update `wiki/index.md`.

---

## Rule 5 — Micro-Decisions

During build work, log small implementation decisions to the matching
`.agent/decisions/{N}.{plan-name}.md` file. `.agent/decisions.md` is retained
as legacy history for older plans and for plans that predate per-plan decision
files.
Format: `## [YYYY-MM-DD] #{plan-number} | Decision title`

These are flagged with ⚡ in progress files during work, then flushed at session end.

**Micro-decision (log in the per-plan decision file):** "Used 300ms debounce, lower caused flicker"
**ADR (use wiki/decisions/):** "Chose PostgreSQL over MongoDB"

---

## Rule 6 — Symptom Index (AI-first retrieval)

The wiki is optimized for AI recall, not human browsing. The **Symptom Index** at
the top of `wiki/index.md` is the primary retrieval surface for any error- or
symptom-shaped query.

**On any debugging / error-shaped query:**
1. `grep` the Symptom Index in `wiki/index.md` for the error string or symptom
2. If hit, read the linked page first — before scanning code or other wiki pages
3. Only fall back to category tables and source code if no match

**When creating or updating a troubleshooting / lesson page:**
1. Fill `symptoms:`, `error_codes:`, `affects:`, `triggers:` in frontmatter
   (see Wiki Page Format → Troubleshooting & Lesson pages)
2. Add at least one row to the Symptom Index table in `wiki/index.md`
3. A troubleshooting/lesson page without a Symptom Index row is a lint failure
   (Rule 3)

Symptom Index row format:

| Symptom / Error | Page | Cause (short) |
|---|---|---|
| `ECONNRESET on /api/sync` | [[troubleshooting/sync-econnreset]] | upstream idle-timeout < client keepalive |

Use exact error strings where possible — agents grep for the literal text users
paste in.

---

## Rule 7 — Typed Relations & Trust Metadata

Every wiki page MAY carry `relations:` (typed semantic links) and SHOULD carry
trust metadata fields (`confidence`, `verified_at`, `verification_method`, `owner`).
Pages of type `architecture`, `decision`, `integration`, `troubleshooting`, and
`lesson` MUST carry `confidence`, `verified_at`, and `verification_method` — the
validator enforces this.

### Relation type vocabulary

| Key | Meaning |
|---|---|
| Key | Meaning | Weight |
|---|---|---|
| `contradicts` | This page conflicts with the target — review required | 1.0 |
| `derived_from` | This page was created based on target; tracks provenance/lineage | 0.9 |
| `depends_on` | This page's claims rely on the target being true | 0.8 |
| `part_of` | This page is a component of target | 0.8 |
| `supports` | This page provides evidence or rationale for the target | 0.7 |
| `supersedes` | This page replaces the target (target should be marked stale) | 0.7 |
| `related_to` | General non-directional association | 0.5 |

Weights guide agent traversal priority: follow weight ≥ 0.8 edges first; follow weight 0.5 edges only when higher-weight paths are exhausted.

Use `[[wikilink]]` syntax for target values. Wikilink targets must resolve to
existing wiki files (the validator checks this).

### Trust metadata fields

| Field | Values | Meaning |
|---|---|---|
| `confidence` | `high \| medium \| low \| unverified` | How reliable is the content |
| `verified_at` | `YYYY-MM-DD` | Last date a human or automated test confirmed accuracy |
| `verification_method` | `manual-review \| automated-test \| live-observation \| unverified` | How it was checked |
| `owner` | freeform string | Team, person, or agent accountable for the page |

**When querying:** After routing via the Task Router, use `confidence` and
`verified_at` to weight answers — prefer `high`-confidence pages and flag
`low` or `unverified` pages as uncertain. Follow `relations.supports` and
`relations.depends_on` to find corroborating pages.

**When creating pages:** Set `confidence: unverified` and
`verification_method: unverified` on first creation. Promote to `high` only
after an explicit review or passing automated test.

**When linting:** Flag pages of type architecture/decision/integration/
troubleshooting/lesson that are missing trust metadata. Flag `relations:`
entries whose targets do not resolve.

---

## Wiki Page Format

Every wiki page:

```markdown
---
type: module | decision | pattern | integration | lesson | troubleshooting | architecture | api | data-model | setup | reference | concept | hypothesis
tags: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: current | stale | draft
relations:
  supports: []       # [[pages]] this page substantiates (weight 0.7)
  depends_on: []     # [[pages]] that must be true for this to be valid (weight 0.8)
  supersedes: []     # [[pages]] this page replaces (weight 0.7)
  contradicts: []    # [[pages]] that conflict with this (weight 1.0)
  related_to: []     # general associations (weight 0.5)
  derived_from: []   # [[pages]] this was derived/built from; provenance (weight 0.9)
  part_of: []        # [[pages]] this is a component of (weight 0.8)
confidence: high | medium | low | unverified
verified_at: YYYY-MM-DD        # last confirmed by review or test
verification_method: manual-review | automated-test | live-observation | unverified
owner: ""                      # team or person accountable for this page
---

# Page Title

> One-sentence summary.

## Overview
[2–4 sentences]

## [Content sections]

## Related
- [[link]]

## Sources
- [Description] — YYYY-MM-DD
```

Use `[[wikilinks]]` for all internal cross-references.
Update `updated:` in frontmatter whenever a page is modified.
Set `status: stale` when a page needs review but you don't have time to fix it now.
See Rule 7 for guidance on filling `relations:` and trust metadata fields.

**Atomic node size:** Keep pages between 50 and 300 lines. Pages under 50 lines are stubs — merge or expand. Pages over 300 lines should be split into atomic sub-pages with a parent index. The validator emits a warning for oversized pages.

**Page types `concept` and `hypothesis`:**
- `concept` — A defined term, framework, or principle the agent should reason from. Use for durable ideas that span multiple modules. Prefer atomic concept pages over growing `glossary.md`.
- `hypothesis` — A falsifiable architectural assumption with a measurable test. Use for unvalidated beliefs between a `question` (known unknown) and a `decision` (choice already made).

### Troubleshooting & Lesson pages — extended format (AI-first retrieval)

These two page types are the primary surface for "I've seen this before" recall.
Use the extended frontmatter and the four-section body verbatim.

```markdown
---
type: troubleshooting | lesson
tags: []
symptoms: []        # exact error strings or short observable symptoms
error_codes: []     # ECONNRESET, 502, ENOENT, P2002, etc.
affects: []         # module names — match wiki/modules/ filenames when possible
triggers: []        # what causes it (deploy, migration, high load, etc.)
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: current | stale | draft
relations:
  supports: []
  depends_on: []
  supersedes: []
  contradicts: []
  related_to: []
  derived_from: []
  part_of: []
confidence: high | medium | low | unverified
verified_at: YYYY-MM-DD
verification_method: manual-review | automated-test | live-observation | unverified
owner: ""
---

# Page Title

> One-sentence summary.

## Symptoms
- exact error string / observable behavior

## Cause
[1–3 sentences]

## Fix
[Steps or code, terse]

## Related
- [[link]]
```

Every such page MUST also register at least one row in the Symptom Index of
`wiki/index.md`. See Rule 6. Trust metadata (`confidence`, `verified_at`,
`verification_method`) is **required** on troubleshooting and lesson pages — the
validator enforces this. See Rule 7.

---

## Wiki Directory Reference

| Folder | What belongs here |
|---|---|
| `wiki/architecture/` | System design, component diagrams, data flow |
| `wiki/decisions/` | Architecture Decision Records (ADRs) |
| `wiki/modules/` | Per-feature/module knowledge pages |
| `wiki/patterns/` | Reusable code patterns, conventions, idioms |
| `wiki/integrations/` | Third-party APIs, SDKs, external services |
| `wiki/lessons/` | Hard-won lessons, non-obvious gotchas |
| `wiki/troubleshooting/` | Known issues, symptoms, resolutions |
| `wiki/setup/` | Dev environment, onboarding, tooling |
| `wiki/api/` | HTTP endpoints, request/response shapes |
| `wiki/data-model/` | Schema definitions, entities, migrations |
| `wiki/testing/` | Test strategy, suites, conventions |
| `wiki/raw/` | Immutable source material used for ingest |
| `wiki/compiled/` | Generated reports, comparisons, decks, and other query artifacts |
| `wiki/glossary.md` | Project-specific terms |
| `wiki/index.md` | Master catalog — always keep current |
| `wiki/log.md` | Append-only operation log |

---

## What You Do Not Do

- Do not modify files in `wiki/raw/` — ever
- Do not rewrite wiki pages from scratch — append and update
- Do not start building without a plan for ⚠️ Medium or 🔴 Complex tasks
- Do not mark progress tasks `[x]` without running the validation test
- Do not write code without reading `CONVENTIONS.md` first
- Do not add low-quality or obvious observations to the wiki
- Do not skip updating `.agent/context.md` at session end
- Do not edit `.github/copilot-instructions.md` or `AGENTS.md` directly — they are mirrors of `CLAUDE.md`. Edit `CLAUDE.md` and re-sync per the Session End Checklist.
