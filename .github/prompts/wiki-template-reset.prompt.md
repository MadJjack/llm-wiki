---
name: "wiki-template-reset"
description: "Maintainer-only reset to restore this repository to a publishable template baseline"
argument-hint: "[optional confirmation]"
agent: agent
---

Use this only when maintaining the template itself, not during normal project work.

1. Explain that this reset removes tracked maintainer history from `PROGRESS.md`, `.agent/decisions.md`, `wiki/log.md`, and `.agent/plans/` / `.agent/progresses/` artifacts.
2. Run `bash scripts/reset-template-state.sh` from the repo root.
3. Run `bash scripts/validate-wiki.sh` after the reset.
4. Report whether the repo is structurally valid and whether maintainer-specific plan, decision, and log history is gone.
5. Do not invent a second reset process. The script is the source of truth.