---
type: pattern
tags: [software-design, complexity, agent-guidance]
created: 2026-05-03
updated: 2026-05-03
status: current
---

# Software Design Checklist

> Operational design checklist for agents before changing structure, extracting abstractions, or adding new modules.

## Overview

Use this before editing code that changes structure: new modules, new abstractions, refactors, APIs, orchestration, state flow, or cross-file behavior. The goal is to reduce complexity for the next agent that reads or changes the code.

This page distills *A Philosophy of Software Design* into agent actions. It is not a book summary.

## Use This Before

- Creating a new abstraction, helper, service, module, component, or layer.
- Splitting or merging functions/classes/files.
- Adding configuration, callbacks, flags, inheritance, adapters, or extension points.
- Touching code because it "feels messy" but the concrete design pressure is unclear.
- Reviewing a PR that claims to improve maintainability or simplicity.

## Core Rule

Reduce future cognitive load. Prefer designs that hide complexity behind simple interfaces and make the common path obvious.

Agent prompt: "After this change, what will the next agent no longer need to understand?"

## Checklist

### 1. Complexity Pressure

- Name the complexity being reduced: change amplification, cognitive load, unknown side effects, duplicated policy, or unclear ownership.
- If no specific complexity is named, do not refactor yet.
- Do not add a pattern because it is familiar; add it because it removes a concrete burden.

### 2. Deep Module Test

- Prefer a module with a simple interface and meaningful internal work.
- Be suspicious of shallow wrappers that add names, files, or indirection without hiding difficulty.
- If a helper only forwards arguments or renames an operation, inline it unless the repo already has a strong local pattern.

Agent prompt: "Is this abstraction deep enough to pay for its interface?"

### 3. Information Hiding

- Hide policy, sequencing, parsing, persistence details, or external-service quirks inside the owner that understands them.
- Do not leak internal representation through names, return shapes, flags, or required call order.
- Prefer one clear operation over several methods that force callers to know the internal steps.

### 4. Interface Shape

- Make the common path short and hard to misuse.
- Avoid boolean flags when they create hidden modes; prefer explicit operations or option objects when the distinction is real.
- Keep inputs and outputs aligned with the caller's mental model, not the callee's internal storage.

### 5. Tactical Programming Check

- Stop if the change is only making the immediate patch pass while increasing future confusion.
- Pay down nearby design debt when it is tightly coupled to the task.
- Do not broaden the refactor beyond the decision pressure of the current task.

### 6. Comment Intent

- Add comments for design intent, invariants, non-obvious constraints, and reasons.
- Do not add comments that repeat code.
- If a comment is needed to explain a confusing name or interface, first try to improve the name or interface.

## Stop And Revise

Pause before editing if:

- The abstraction does not hide meaningful complexity.
- The design introduces more concepts than it removes.
- Callers must know internal sequencing to use the API correctly.
- The change optimizes elegance but not an actual maintenance problem.
- You cannot state what future work becomes easier.

## Agent Output

When applying this checklist, summarize:

```text
Design pressure: [specific complexity]
Chosen shape: [module/interface/refactor]
Complexity hidden: [what callers no longer need to know]
Accepted cost: [new indirection, file, rule, or constraint]
Validation: [test/check/review proof]
```

## Related

- [[patterns/clean-code-checklist]]
- [[patterns/_index]]

## Sources

- John K. Ousterhout, *A Philosophy of Software Design*, Yaknyam Press — 2018
- [John Ousterhout's official book page](https://web.stanford.edu/~ouster/cgi-bin/aposd.php) — 2026-05-03
