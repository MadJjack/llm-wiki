---
type: pattern
tags: [legacy-code, testing, safe-change, agent-guidance]
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

# Legacy Code Safe Change

> Operational checklist for agents changing existing code whose behavior is not fully understood or well protected by tests.

## Overview

Use this before modifying legacy, unclear, high-risk, or under-tested code. The goal is to avoid the most common agent failure mode: improving structure while accidentally changing behavior.

This page distills *Working Effectively with Legacy Code* into safe-change actions. It is not a book summary.

## Use This Before

- Editing code with weak or missing tests.
- Fixing a bug in code whose surrounding behavior is unclear.
- Refactoring before the current behavior is characterized.
- Touching code with hidden dependencies, global state, time, randomness, IO, network calls, or database access.
- Replacing old code because it looks bad rather than because the change requires it.

## Core Rule

Protect behavior before changing structure. When behavior is unclear, first capture what the system currently does, then make the smallest safe change.

Agent prompt: "What behavior must stay the same while I make this change?"

## Checklist

### 1. Characterize Current Behavior

- Find the narrowest behavior surface affected by the change.
- Add characterization tests when behavior is not already protected.
- Test observable behavior, not private implementation trivia.
- If the current behavior looks wrong but existing users may depend on it, document that uncertainty before changing it.

Agent prompt: "What test would fail if I accidentally changed existing behavior?"

### 2. Find A Seam

- Identify where the code can be observed, isolated, or substituted.
- Prefer the smallest seam that enables testing: parameter, wrapper, adapter, extracted function, fixture, or test double.
- Do not introduce a broad abstraction just to make one test possible.

Agent prompt: "Where can I insert a test or substitute without redesigning the whole system?"

### 3. Break Dependencies Minimally

- Isolate hard dependencies such as filesystem, network, clock, randomness, database, environment variables, and global state.
- Break only the dependency needed for the current test or change.
- Keep the production path behavior-equivalent unless the requested change explicitly alters it.

### 4. Change One Axis At A Time

- Do not mix behavior changes and cleanup in the same step when risk is high.
- First add/adjust tests around current behavior.
- Then make the behavior change.
- Then refactor only after tests protect the behavior.

### 5. Preserve Searchable Symptoms

- If the work fixes a bug, capture the symptom in a test name, assertion, troubleshooting page, or log entry as appropriate.
- Make failure messages specific enough that future agents can search for them.
- If the fix teaches a non-obvious lesson, follow the bug-solved gate in `CLAUDE.md`.

### 6. Stop The Rewrite Reflex

- Do not replace legacy code wholesale unless the requested task requires it and behavior is well characterized.
- Prefer small, reversible moves.
- If a rewrite is unavoidable, state which behavior is intentionally preserved and which behavior is intentionally changed.

## Stop And Revise

Pause before editing if:

- You cannot name the behavior that must be preserved.
- There is no test, characterization, or manual validation path for the risky behavior.
- The change combines refactoring, cleanup, and behavior change.
- A new abstraction is larger than the dependency it breaks.
- You are relying on "this code looks wrong" without evidence of intended behavior.

## Agent Output

When applying this checklist, summarize:

```text
Protected behavior: [what must stay the same]
Characterization added: [test/check/manual probe]
Seam used: [where the code was isolated]
Behavior change: [what intentionally changed]
Refactor scope: [what cleanup was deferred or performed]
Validation: [test/check proof]
```

## Related

- [[patterns/software-design-checklist]]
- [[patterns/clean-code-checklist]]
- [[patterns/_index]]

## Sources

- Michael Feathers, *Working Effectively with Legacy Code*, Prentice Hall — 2004
- [O'Reilly listing for *Working Effectively with Legacy Code*](https://www.oreilly.com/library/view/working-effectively-with/0131177052/) — 2026-05-03
