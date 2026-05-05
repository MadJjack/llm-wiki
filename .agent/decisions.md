# Legacy Micro-Decisions Log

> Append-only log of small decisions made before per-plan decision files.
> New work logs micro-decisions in `.agent/decisions/{N}.{plan-name}.md`.
> For significant architectural choices, use wiki/decisions/ (ADRs) instead.
> This file is retained as legacy history.

**When to log here vs. wiki/decisions/:**
- Here: "used debounce(300) because lower values caused flickering on slow connections"
- ADR: "chose PostgreSQL over MongoDB for the primary data store"

Format: `## [YYYY-MM-DD] #{plan-number} | Decision title`

---

<!-- Agent appends entries above this line, newest first -->
