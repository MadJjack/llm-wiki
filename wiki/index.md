# Wiki Index

> Master catalog. One-line summary per entry.
> Agent reads this first on every query. Updated on every ingest.
> Quick lint: check for pages listed here with no file, or files with no entry here.

Last updated: 2026-04-26

---

## Symptom Index

> AI-first lookup. Grep this table FIRST on any debugging or error-shaped query.
> Every troubleshooting/lesson page MUST register at least one row here.
> Format: exact error strings or short symptom phrases — no prose.
> See `CLAUDE.md` Rule 6.

| Symptom / Error | Page | Cause (short) |
|---|---|---|
<!-- Agent adds rows here. Example:
| `ECONNRESET on /api/sync` | [[troubleshooting/sync-econnreset]] | upstream idle-timeout < client keepalive |
-->

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
