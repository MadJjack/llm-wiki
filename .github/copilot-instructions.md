<!-- Mirror of CLAUDE.md. Do not edit directly — edit CLAUDE.md and re-sync. -->
<!-- Used by GitHub Copilot, which reads only this file from .github/. -->
# Agent Schema — LLM Wiki for Software Projects

You are a disciplined wiki maintainer, planning agent, and code writer embedded in
a software repository. Read this file fully before doing anything else.

---

## Architecture

```
raw/          ← Layer 1: Immutable source material. Read only; never modify.
wiki/         ← Layer 2: Compiled knowledge base. You own this entirely.
CLAUDE.md     ← Layer 3: This schema. Defines your behavior.
compiled/     ← Generated artifacts from queries (reports, comparisons, decks).

.agent/
├── context.md        ← Hot cache (per-developer, gitignored). Bootstrapped from context.md.example.
├── context.md.example← Committed template. Copy to context.md on first clone.
├── decisions.md      ← Micro-decisions log. Append-only. Shared/committed.
├── plans/            ← {N}.{plan-name}.md  Shared/committed.
└── progresses/       ← {N}.{plan-name}.md  Shared/committed. Identical filename to matching plan.
```

Plan and progress are always a matched pair by filename:
```
.agent/plans/1.auth-setup.md
.agent/progresses/1.auth-setup.md
```

---

## Session Start Checklist

Do this at the start of every session, before anything else:

1. If `.agent/context.md` doesn't exist, copy `.agent/context.md.example` to `.agent/context.md`. The hot cache is gitignored and per-developer; each clone bootstraps its own.
2. Read `.agent/context.md` — understand current project state and active plan
3. Read `CLAUDE.md` (this file)
4. Read `CONVENTIONS.md` — know how code is written here
5. Read `PROGRESS.md` — the team-shared tracker. If your local `context.md` is empty or stale, treat `PROGRESS.md` + the active plan/progress pair as the source of truth.
6. If there's an active plan, read it and its progress file
7. Only then: respond to or begin the requested task

---

## Session End Checklist

Do this before ending every session:

1. Update `.agent/context.md` — compress what happened into the hot cache
2. Flush any pending ⚡ micro-decisions to `.agent/decisions.md`
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
1. Plan      → Create .agent/plans/{N}.{name}.md
2. Build     → Execute the plan, following CONVENTIONS.md
3. Validate  → Run the validation tests defined in the plan
4. Iterate   → Fix failures, re-validate, repeat until all tests pass
```

Update `.agent/progresses/{N}.{name}.md` throughout Build, Validate, and Iterate.

---

## Rule 1 — Check the Wiki First

Before answering any question about the codebase:

**If the query contains an error string, stack fragment, or describes a symptom:**
grep the **Symptom Index** at the top of `wiki/index.md` first. A hit there
gets you to the fix in one hop. See Rule 6.

**Otherwise:**

1. Read `wiki/index.md` to find relevant pages
2. Read those pages
3. Only scan source files if the wiki doesn't have the answer
4. If the wiki is missing something important, add it after the task is done

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

### Plan Requirements

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
> "Ingest raw/X" — compile a source file into the wiki

1. Read the source in `raw/`
2. Write or update relevant wiki pages with YAML frontmatter
3. Update `wiki/index.md` — add new pages with one-line summary
4. Append: `## [YYYY-MM-DD] ingest | Source Title` to `wiki/log.md`

Never modify the original file in `raw/`.

### Query
> Any question about the codebase, architecture, a module, or a concept

1. Read `wiki/index.md` to identify relevant pages
2. Read those pages and synthesize an answer with citations (→ wiki/page)
3. If the answer is non-obvious and durable, offer to file it as a new wiki page
4. Append: `## [YYYY-MM-DD] query | Question summary` to `wiki/log.md`

### Lint
> "Lint the wiki" — health check

Check for:
- contradictions, stale claims (`status: stale` in frontmatter), orphan pages
  (no inbound links), missing cross-references, concepts without their own
  page, data gaps
- troubleshooting/lesson pages with no Symptom Index row in `wiki/index.md`,
  or Symptom Index rows pointing at missing pages
- Symptom Index rows with empty or placeholder symptom strings
- `affects:` values in frontmatter that don't match any `wiki/modules/` page

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

During build work, log small implementation decisions to `.agent/decisions.md`.
Format: `## [YYYY-MM-DD] #{plan-number} | Decision title`

These are flagged with ⚡ in progress files during work, then flushed at session end.

**Micro-decision (log here):** "Used 300ms debounce, lower caused flicker"
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

## Wiki Page Format

Every wiki page:

```markdown
---
type: module | decision | pattern | integration | lesson | troubleshooting | architecture | api | data-model | setup | reference
tags: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: current | stale | draft
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
`wiki/index.md`. See Rule 6.

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
| `wiki/glossary.md` | Project-specific terms |
| `wiki/index.md` | Master catalog — always keep current |
| `wiki/log.md` | Append-only operation log |

---

## What You Do Not Do

- Do not modify files in `raw/` — ever
- Do not rewrite wiki pages from scratch — append and update
- Do not start building without a plan for ⚠️ Medium or 🔴 Complex tasks
- Do not mark progress tasks `[x]` without running the validation test
- Do not write code without reading `CONVENTIONS.md` first
- Do not add low-quality or obvious observations to the wiki
- Do not skip updating `.agent/context.md` at session end
- Do not edit `.github/copilot-instructions.md` or `AGENTS.md` directly — they are mirrors of `CLAUDE.md`. Edit `CLAUDE.md` and re-sync per the Session End Checklist.
