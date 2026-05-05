---
type: pattern
tags: [clean-code, code-review, agent-guidance]
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

# Clean Code Checklist

> Operational code cleanliness checklist for agents before finishing a code edit or review.

## Overview

Use this after code changes and during review. The goal is not to enforce *Clean Code* as doctrine; the goal is to catch readability, naming, function, error-handling, and test issues that make future edits harder.

Treat this as a review lens. If a rule conflicts with local conventions or the design checklist, prefer the option that reduces cognitive load in this repo.

## Use This Before

- Declaring implementation work done.
- Reviewing generated code.
- Adding or changing public names, exported functions, or test helpers.
- Leaving code with TODOs, unclear errors, hidden side effects, or brittle tests.
- Promoting advice into `CONVENTIONS.md`.

## Core Rule

Code should say what it does at the level the reader needs, and hide the rest behind names, tests, and small enough units of behavior.

Agent prompt: "What would confuse the next agent trying to change this?"

## Checklist

### 1. Names

- Use names that reveal purpose, domain meaning, and units.
- Avoid generic names like `data`, `info`, `result`, `handle`, or `process` unless the scope is tiny and obvious.
- Rename booleans so true/false meaning is clear at call sites.
- Do not encode obsolete implementation details in names.

### 2. Functions

- Each function should have one clear reason to exist.
- Split code when a named substep reduces reader load.
- Do not split code into shallow one-line helpers just to satisfy a size rule.
- Keep side effects visible in names or isolate them behind clear commands.

### 3. Control Flow

- Prefer guard clauses when they make failure and edge cases obvious.
- Avoid deeply nested branches when extraction or early return would clarify intent.
- Keep error paths explicit enough that callers know what can fail.

### 4. Comments

- Comments should explain why, constraints, invariants, and surprising decisions.
- Delete comments that restate code.
- Replace comments with better names when the comment exists only to explain confusing code.

### 5. Errors

- Preserve useful error context.
- Do not swallow errors unless the recovery behavior is intentional and documented by code shape or comment.
- Make user-facing and agent-facing failure messages specific enough to search later.

### 6. Tests

- Tests should describe behavior, not implementation trivia.
- Add coverage for the risk introduced by the change.
- Prefer clear setup and assertions over clever shared fixtures.
- If a bug was fixed, test the symptom or failure mode that would have caught it.

### 7. Local Fit

- Follow the repo's existing style before importing a book rule.
- Do not churn formatting, names, or structure outside the touched behavior.
- If a convention is missing and the choice is likely to recur, propose a convention rather than silently inventing one.

## Stop And Revise

Pause before finishing if:

- The main behavior cannot be described in one sentence.
- A name hides domain meaning or reverses boolean logic in the reader's head.
- Tests pass but do not protect the risky behavior.
- A helper adds indirection without hiding complexity.
- The change leaves searchable symptoms or errors undocumented.

## Agent Output

When applying this checklist, summarize:

```text
Readability risk checked: [names/functions/control flow/errors/tests]
Main cleanup made: [specific change]
Risk still accepted: [if any]
Validation: [test/check/review proof]
```

## Related

- [[patterns/software-design-checklist]]
- [[patterns/_index]]
- [[CONVENTIONS]]

## Sources

- Robert C. Martin, *Clean Code: A Handbook of Agile Software Craftsmanship*, Prentice Hall — 2008
- [O'Reilly listing for *Clean Code*](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) — 2026-05-03
