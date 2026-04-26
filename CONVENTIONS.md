# Conventions

> How code is written in this project.
> The agent reads this before writing any new code.
> Separate from CLAUDE.md (agent behavior) — this is about code consistency.
> Update this file when the team makes a deliberate style or stack decision.

---

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| <!-- e.g. Language --> | | | |
| <!-- e.g. Framework --> | | | |
| <!-- e.g. Database --> | | | |
| <!-- e.g. Auth --> | | | |
| <!-- e.g. Testing --> | | | |
| <!-- e.g. Deployment --> | | | |

---

## Naming Conventions

### Files & Folders
- <!-- e.g. Components: PascalCase.tsx -->
- <!-- e.g. Utilities: camelCase.ts -->
- <!-- e.g. Folders: kebab-case -->

### Variables & Functions
- <!-- e.g. Functions: camelCase -->
- <!-- e.g. Constants: UPPER_SNAKE_CASE -->
- <!-- e.g. Types/Interfaces: PascalCase, prefix I for interfaces -->

### Database
- <!-- e.g. Tables: snake_case, plural -->
- <!-- e.g. Columns: snake_case -->

---

## Folder Structure

```
<!-- Agent fills this in based on the project's actual structure -->
```

---

## Error Handling

- <!-- e.g. All async functions use try/catch -->
- <!-- e.g. Errors are logged before being rethrown -->
- <!-- e.g. User-facing errors go through a central error formatter -->

---

## API Conventions

- <!-- e.g. REST: noun-based routes, plural -->
- <!-- e.g. HTTP methods used as intended (GET/POST/PUT/PATCH/DELETE) -->
- <!-- e.g. Response envelope: { data, error, meta } -->
- <!-- e.g. Validation: Zod schemas on all inputs -->

---

## Testing Conventions

- <!-- e.g. Unit tests co-located: foo.test.ts next to foo.ts -->
- <!-- e.g. Integration tests in /tests -->
- <!-- e.g. Test naming: "should [behavior] when [condition]" -->
- <!-- e.g. Mocking strategy: MSW for HTTP, vitest.mock for modules -->

---

## Patterns We Always Use

- <!-- e.g. Repository pattern for all DB access -->
- <!-- e.g. Service layer between controllers and repositories -->
- <!-- e.g. DTOs for all external-facing data shapes -->

---

## Patterns We Never Use

> Anti-patterns that have burned us or that we've explicitly ruled out.

- <!-- e.g. No raw SQL outside of repository files -->
- <!-- e.g. No direct DB access from API route handlers -->
- <!-- e.g. No any type in TypeScript -->

---

## Dependency Rules

- <!-- e.g. No new dependencies without a team discussion -->
- <!-- e.g. Prefer built-ins and existing deps over new ones -->
- <!-- e.g. All deps pinned to exact versions -->

---

## Comments & Documentation

- <!-- e.g. JSDoc on all exported functions -->
- <!-- e.g. Inline comments explain "why", not "what" -->
- <!-- e.g. TODO format: // TODO(name): description -->

---

## Git Conventions

- **Branch naming:** <!-- e.g. feature/*, fix/*, chore/* -->
- **Commit format:** <!-- e.g. Conventional Commits: feat:, fix:, chore: -->
- **PR size:** <!-- e.g. Keep PRs under 400 lines where possible -->

---

## Related
- [[wiki/architecture/overview]]
- [[wiki/patterns/_index]]
