---
type: pattern
tags: [design-patterns, software-design, agent-guidance]
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

# Design Patterns Decision Guide

> Operational guide for agents choosing common design patterns only when a concrete problem shape justifies them.

## Overview

Use this when code needs a recurring design shape, not when code merely looks messy. A design pattern is useful only if it simplifies a real variation point, dependency boundary, lifecycle state, construction rule, workflow, or cross-cutting behavior.

This page distills common design patterns into agent decision rules. It is not a pattern catalog.

## Use This Before

- Replacing conditionals with polymorphism or dispatch.
- Hiding an external API, library, file format, or legacy interface.
- Creating object construction rules.
- Modeling lifecycle-dependent behavior.
- Adding middleware, handlers, commands, jobs, event listeners, or repositories.
- Introducing a named pattern during design, refactoring, or review.

## Core Rule

Do not introduce a design pattern unless you can name the variation point, dependency boundary, lifecycle state, construction rule, workflow behavior, or cross-cutting concern it simplifies.

Agent prompt: "What specific complexity does this pattern remove for future callers?"

## Decision Table

| Problem shape | Pattern to consider | Use when | Avoid when |
|---|---|---|---|
| Behavior varies by policy, provider, algorithm, mode, or business rule | Strategy | Callers need one stable interface while behavior varies behind it | There are only one or two simple branches and no real variation pressure |
| External API, library, legacy interface, or file format does not match local code | Adapter | You need to isolate third-party or legacy weirdness from the rest of the repo | The adapter only renames methods without hiding mismatch or risk |
| A subsystem requires callers to know too many steps or collaborators | Facade | You can give callers one simple entrypoint and keep sequencing inside the subsystem | The facade becomes a dumping ground for unrelated operations |
| Construction has variants, dependencies, config, validation, or policy | Factory / Factory Method | Object creation rules should be centralized and named | Direct construction is obvious and repeated construction policy does not exist |
| Constructing an object requires many optional fields, ordered steps, or test setup | Builder | It makes construction readable and prevents invalid partial setup | It replaces a simple constructor or literal with ceremony |
| One event should notify multiple independent listeners | Observer / Pub-Sub | Producers should not know every consumer, and listeners are independent | Flow becomes hard to trace or ordering matters deeply |
| An action needs to be queued, retried, logged, authorized, undone, or run later | Command | Treating the action as an object clarifies execution, metadata, or scheduling | A plain function call is enough and no action lifecycle exists |
| Behavior changes by lifecycle state | State | State-specific behavior is scattered across conditionals | The state machine has only trivial states or unclear transitions |
| Behavior should be layered around a core operation | Decorator / Middleware / Pipeline | You need ordered layers like auth, validation, logging, caching, retry, or transforms | Layer ordering is implicit or debugging the flow becomes difficult |
| Persistence details should not leak into business logic | Repository | Query/storage details need a stable boundary and test seam | It becomes a thin pass-through over an ORM with no policy or isolation |
| Global access to one instance feels convenient | Singleton caution | Rarely, when the runtime truly guarantees one process-wide resource and tests are unaffected | Prefer dependency injection; Singleton often hides global state and makes tests/order coupling worse |

## Stop And Revise

Pause before introducing a pattern if:

- You cannot name the problem shape it solves.
- The pattern creates more concepts than it removes.
- Callers must learn the pattern to understand simple behavior.
- Existing repo conventions solve the problem more simply.
- The pattern hides control flow, error handling, or lifecycle ordering.
- The change is speculative because future variation might happen.

## Pattern Fit Checks

- Does the pattern create a better seam for tests or future changes?
- Does it reduce duplication of policy rather than duplicate vocabulary?
- Does it make invalid states or call sequences harder to express?
- Does it keep third-party, persistence, or infrastructure details at the boundary?
- Can a future agent remove it if the variation disappears?

## Agent Output

When applying this guide, summarize:

```text
Problem shape: [variation/boundary/lifecycle/construction/workflow/cross-cutting concern]
Pattern chosen: [pattern]
Why simpler than direct code: [specific reader or caller burden removed]
Why not over-engineered: [current evidence, not speculative future]
Risks: [hidden flow/global state/ceremony/test impact]
Validation: [test/check/review proof]
```

## Related

- [[patterns/software-design-checklist]]
- [[patterns/refactoring-checklist]]
- [[patterns/legacy-code-safe-change]]
- [[patterns/clean-code-checklist]]
- [[patterns/_index]]

## Sources

- Erich Gamma, Richard Helm, Ralph Johnson, and John Vlissides, *Design Patterns: Elements of Reusable Object-Oriented Software*, Addison-Wesley — 1994
- [Pearson listing for *Design Patterns: Elements of Reusable Object-Oriented Software*](https://www.pearson.com/en-us/subject-catalog/p/design-patterns-elements-of-reusable-object-oriented-software/P200000009480) — 2026-05-03
