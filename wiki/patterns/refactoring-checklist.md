---
type: pattern
tags: [refactoring, safe-change, code-review, agent-guidance]
created: 2026-05-03
updated: 2026-05-05
status: current
relations:
  supports: []
  depends_on: []
  supersedes: []
  contradicts: []
  related_to: []
confidence: high
verified_at: 2026-05-03
verification_method: manual-review
owner: ""
---

# Refactoring Checklist

> Operational checklist for agents improving code structure without changing external behavior.

## Overview

Use this after behavior is protected and before making structural cleanup. The goal is to improve design in small, behavior-preserving steps without turning cleanup into accidental feature work.

This page distills Fowler's *Refactoring* into agent actions. It is not a refactoring catalog.

## Use This Before

- Renaming, extracting, moving, inlining, splitting, or reorganizing code.
- Cleaning up code after a bug fix.
- Reducing duplication or untangling conditionals.
- Reviewing a PR that claims "no behavior change."
- Applying [[patterns/software-design-checklist]] to existing code.

## Core Rule

Refactor only when behavior is protected. Each meaningful step should preserve behavior and be validated before the next step.

Agent prompt: "What proves this change only changed structure?"

## Checklist

### 1. Behavior Is Protected

- Confirm tests, characterization checks, or manual probes cover the behavior at risk.
- If behavior is unclear or under-tested, use [[patterns/legacy-code-safe-change]] first.
- Do not refactor and change behavior in the same step unless the task explicitly requires it and the final answer calls that out.

### 2. Name The Smell

- State the code smell or design pressure before editing: duplication, long function, confusing conditional, primitive obsession, feature envy, shotgun surgery, unclear name, mixed responsibilities, or dead code.
- If the smell cannot be named, do not refactor yet.
- Prefer local evidence over generic "clean code" claims.

Agent prompt: "What concrete pain does this refactor remove?"

### 3. Choose The Smallest Move

- Prefer small behavior-preserving transformations: rename, extract function, inline function, move function, split phase, introduce parameter object, replace temp with query, or remove dead code.
- Avoid broad rewrites when a sequence of small moves will do.
- Keep each move reviewable.

### 4. Validate Between Moves

- Run the narrowest useful test after each meaningful step.
- If a step fails, revert or fix that step before continuing.
- Do not stack several speculative refactors and debug them as a bundle.

### 5. Keep Scope Tied To The Task

- Refactor the code needed to complete or safely support the current change.
- Leave unrelated cleanup for a separate task.
- If the refactor reveals a larger design issue, record it rather than expanding silently.

### 6. Preserve Names And Intent

- Rename toward domain meaning, not novelty.
- Keep behavior names aligned with tests and user-facing concepts.
- Delete obsolete comments after the structure makes them unnecessary.

## Stop And Revise

Pause before refactoring if:

- You cannot prove behavior preservation.
- You cannot name the smell or design pressure.
- The refactor changes public behavior, data shape, timing, persistence, or error semantics.
- The cleanup touches unrelated modules.
- The diff is becoming harder to review than the original problem.

## Agent Output

When applying this checklist, summarize:

```text
Behavior protected by: [test/check/manual probe]
Smell addressed: [specific smell]
Refactoring moves: [small sequence]
Behavior intentionally changed: [none or explicit]
Validation: [test/check proof]
Deferred cleanup: [if any]
```

## Related

- [[patterns/legacy-code-safe-change]]
- [[patterns/software-design-checklist]]
- [[patterns/clean-code-checklist]]
- [[patterns/_index]]

## Sources

- Martin Fowler, *Refactoring: Improving the Design of Existing Code*, 2nd edition, Addison-Wesley — 2018
- [Martin Fowler's official Refactoring book page](https://martinfowler.com/books/refactoring.html) — 2026-05-03
