---
type: pattern
tags: [production, resilience, release-readiness, agent-guidance]
created: 2026-05-03
updated: 2026-05-03
status: current
---

# Release Readiness Checklist

> Operational checklist for agents reviewing runtime-affecting changes before they are considered production-ready.

## Overview

Use this before shipping changes that affect runtime behavior, service calls, persistence, background jobs, queues, caches, network boundaries, retries, timeouts, deployment, configuration, or operational visibility. The goal is to catch production failure modes before the code reaches users.

This page distills *Release It!* into agent actions. It is not a book summary.

## Use This Before

- Adding or changing service calls, API handlers, database access, queues, jobs, caches, or external integrations.
- Changing retry, timeout, concurrency, rate-limit, or resource behavior.
- Introducing new configuration, deployment steps, migrations, or feature flags.
- Declaring a runtime-affecting change ready for release.
- Reviewing code that can fail differently in production than in tests.

## Core Rule

Assume production will apply pressure the happy path never shows. Review how the change fails, how far the failure spreads, and how operators or agents will detect and recover from it.

Agent prompt: "What happens when this dependency is slow, unavailable, partial, or returns bad data?"

## Checklist

### 1. Failure Modes

- List the dependencies touched: network, database, filesystem, cache, queue, clock, third-party API, environment, or user input.
- For each dependency, consider slow response, timeout, error response, partial response, invalid data, overload, and repeated failure.
- Make sure failures are bounded and observable.

### 2. Timeouts

- Confirm outbound calls have explicit timeouts.
- Avoid relying on library defaults unless the repo has chosen them deliberately.
- Make timeout values visible in configuration or local constants when they are operationally meaningful.

### 3. Retries And Backoff

- Retry only when the operation is safe or idempotent.
- Use bounded retries with backoff, not tight loops.
- Avoid retry storms that amplify dependency outages.
- Preserve enough context to know what failed after retries are exhausted.

### 4. Blast Radius

- Check whether one failing dependency can block unrelated work.
- Prefer isolation for risky calls, queues, workers, or resource pools.
- Avoid holding scarce resources while waiting on slow dependencies.

### 5. Resource Pressure

- Consider memory, file handles, threads, connections, queue depth, payload size, and unbounded collections.
- Put limits around loops, fan-out, buffering, and concurrency.
- Make large or repeated work cancellable or resumable when appropriate.

### 6. Observability

- Ensure failures produce searchable messages with useful context.
- Add or preserve logs, metrics, traces, counters, or status surfaces that match the repo's existing conventions.
- Do not log secrets or high-cardinality noise.

### 7. Deployment And Recovery

- Identify config, migration, rollout, rollback, and compatibility concerns.
- Make startup failure preferable to silent misconfiguration when safe.
- Document manual validation or smoke checks when automated tests cannot prove production behavior.

## Stop And Revise

Pause before release if:

- A dependency can hang without a timeout.
- A retry can duplicate side effects or amplify outage load.
- Operators or future agents cannot tell what failed from logs/errors.
- Resource usage can grow without bounds.
- Rollback or compatibility assumptions are unstated.

## Agent Output

When applying this checklist, summarize:

```text
Runtime surface touched: [API/job/db/cache/network/config/etc.]
Failure modes checked: [slow/error/partial/invalid/overload]
Protection added or confirmed: [timeout/retry/backoff/isolation/limit]
Observability: [logs/metrics/errors/smoke check]
Release risk still accepted: [if any]
Validation: [test/check/manual probe]
```

## Related

- [[patterns/legacy-code-safe-change]]
- [[patterns/refactoring-checklist]]
- [[patterns/clean-code-checklist]]
- [[patterns/_index]]

## Sources

- Michael T. Nygard, *Release It!: Design and Deploy Production-Ready Software*, 2nd edition, Pragmatic Bookshelf — 2018
- [O'Reilly listing for *Release It!, 2nd Edition*](https://www.oreilly.com/library/view/release-it-2nd/9781680504552/) — 2026-05-03
