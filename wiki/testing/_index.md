---
type: testing
tags: []
created: <!-- YYYY-MM-DD -->
updated: <!-- YYYY-MM-DD -->
status: draft
---

# Testing

> Test strategy, how to run suites, test data conventions, and what's mocked vs. real.
> Per-task validation tests live in .agent/plans/. This is the project-wide testing philosophy.

## Strategy

<!-- Unit / integration / E2E split and rationale -->

## Running Tests

```bash
# All tests
# Agent fills in

# Unit only
# Agent fills in

# Integration only
# Agent fills in

# Single file
# Agent fills in

# Watch mode
# Agent fills in
```

## Test Structure

```
<!-- Where tests live relative to source -->
```

## What We Mock

| Thing | How | Why |
|---|---|---|
| <!-- e.g. External HTTP APIs --> | <!-- MSW --> | <!-- Avoid network in tests --> |
| <!-- e.g. Database --> | <!-- In-memory / test DB --> | |
| <!-- e.g. Auth --> | <!-- Stub middleware --> | |

## What We Don't Mock

<!-- Things that always run real in tests -->
-

## Test Data

<!-- How test fixtures and seed data are managed -->
- Fixtures location: `<!-- path -->`
- Seed command: `<!-- command -->`
- Reset command: `<!-- command -->`

## CI

<!-- What runs in CI, what gates merges -->

## Coverage

<!-- Target coverage %, what's excluded, how to check -->

## Related
- [[wiki/setup/dev-environment]]
- [[CONVENTIONS]]
