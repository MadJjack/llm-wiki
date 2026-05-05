# Wiki Index

> Master catalog. One-line summary per entry.
> Agent reads this first on every query. Updated on every ingest.
> Quick lint: check for pages listed here with no file, or files with no entry here.

Last updated: 2026-05-04

---

## Symptom Index

> AI-first lookup. Grep this table FIRST on any debugging or error-shaped query.
> Every troubleshooting/lesson page MUST register at least one row here.
> Format: exact error strings or short symptom phrases — no prose.
> See `CLAUDE.md` Rule 6.

| Symptom / Error | Page | Cause (short) |
|---|---|---|
| `Symptom Index entry must point to troubleshooting/ or lessons/: architecture/overview` | [[troubleshooting/symptom-index-parser-task-router]] | validator parsed later `wiki/index.md` tables as Symptom Index rows |
<!-- Agent adds rows here. Example:
| `ECONNRESET on /api/sync` | [[troubleshooting/sync-econnreset]] | upstream idle-timeout < client keepalive |
-->

---

## Task Router

> For non-debug questions, use this table before scanning the category catalog.
> For errors, stack fragments, or symptoms, use the Symptom Index above first.
> **Second-hop narrowing:** after routing to first-hop pages, follow `relations.supports` and `relations.depends_on` links. Prefer `confidence: high` pages; flag `unverified` or `low` pages as uncertain.

| Task / Query Shape | Open First | Then Read | Update Wiki When |
|---|---|---|---|
| Active work, current status, or what to do next | `PROGRESS.md` and the active plan/progress/decision trio | `.agent/context.md`, legacy `.agent/decisions.md` when needed | plan status, validation, or decisions change |
| Architecture, system flow, or component responsibility | [[architecture/overview]] | [[patterns/software-design-checklist]], [[decisions/template]] | architecture behavior or a durable design decision changes |
| Code design, abstractions, or pattern choice | [[patterns/software-design-checklist]] | [[patterns/design-patterns-decision-guide]], [[patterns/clean-code-checklist]], `CONVENTIONS.md` | a reusable pattern or convention is learned |
| Refactoring or behavior-preserving cleanup | [[patterns/refactoring-checklist]] | [[patterns/legacy-code-safe-change]], [[patterns/software-design-checklist]] | a safe-change lesson or reusable refactor pattern emerges |
| Runtime behavior, release risk, or production readiness | [[patterns/release-readiness-checklist]] | [[testing/_index]], [[troubleshooting/_index]] | a new failure mode, smoke check, or release gate is learned |
| API, schema, contracts, or persistence shape | [[api/_index]], [[data-model/_index]] | [[testing/_index]], [[decisions/template]] | endpoints, schemas, migrations, or contracts change |
| Setup, tooling, local environment, or test commands | [[setup/dev-environment]] | `CONVENTIONS.md`, [[testing/_index]] | setup commands, env vars, or tool versions change |
| Architecture decision or ADR drafting | [[decisions/template]] | [[architecture/overview]], [[patterns/software-design-checklist]] | a decision is made or superseded |
| Troubleshooting, known issue, or remembered symptom | Symptom Index above | [[troubleshooting/_index]], [[lessons/_index]] | a new exact symptom/fix or hard lesson is found |
| Project term, acronym, or concept lookup | [[glossary]] | relevant category table below | a durable project-specific term is introduced |

---

## Architecture
| Page | Summary |
|---|---|
| [[architecture/overview]] | High-level system structure, components, and data flow |

## API
| Page | Summary |
|---|---|
| [[api/_index]] | HTTP endpoint inventory, auth, request/response shapes |

## Data Model
| Page | Summary |
|---|---|
| [[data-model/_index]] | Schema definitions, entity relationships, migration history |

## Decisions (ADRs)
| Page | Summary |
|---|---|
| [[decisions/template]] | Template for Architecture Decision Records |
<!-- Agent adds rows here -->

## Modules
| Page | Summary |
|---|---|
<!-- Agent adds rows here -->

## Patterns
| Page | Summary |
|---|---|
| [[patterns/clean-code-checklist]] | Operational code cleanliness checklist for agents before finishing code edits or reviews |
| [[patterns/design-patterns-decision-guide]] | Operational guide for choosing common design patterns only when a concrete problem shape justifies them |
| [[patterns/legacy-code-safe-change]] | Operational checklist for safely changing unclear or under-tested existing code |
| [[patterns/refactoring-checklist]] | Operational checklist for behavior-preserving code structure improvements |
| [[patterns/release-readiness-checklist]] | Operational checklist for production-readiness review of runtime-affecting changes |
| [[patterns/software-design-checklist]] | Operational software design checklist for agents before changing structure or abstractions |
| [[patterns/metadata-model]] | Typed relation vocabulary and trust/provenance metadata model for wiki pages |
<!-- Agent adds rows here -->

## Integrations
| Page | Summary |
|---|---|
<!-- Agent adds rows here -->

## Testing
| Page | Summary |
|---|---|
| [[testing/_index]] | Test strategy, suites, mocking conventions, CI |

## Lessons
| Page | Summary |
|---|---|
<!-- Agent adds rows here -->

## Troubleshooting
| Page | Summary |
|---|---|
| [[troubleshooting/symptom-index-parser-task-router]] | Fix for validator failures caused by reading Task Router rows as Symptom Index entries |
<!-- Agent adds rows here -->

## Setup
| Page | Summary |
|---|---|
| [[setup/dev-environment]] | Local dev setup, env vars, running tests |

## Reference
| Page | Summary |
|---|---|
| [[glossary]] | Project-specific terms and abbreviations |
| [[log]] | History of all ingest, query, and lint operations |
