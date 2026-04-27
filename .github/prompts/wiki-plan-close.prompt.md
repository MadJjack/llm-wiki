---
name: "wiki-plan-close"
description: "Verify validations, update wiki and tracker state, and archive a completed plan only after everything passes"
argument-hint: "[plan number or name]"
agent: agent
---

Close an existing plan only when it is actually complete.

1. If the user did not name the plan, ask which active plan should be closed.
2. Read the plan, the matching progress file, `PROGRESS.md`, `.agent/context.md`, and any touched wiki pages.
3. Verify every task is complete and every validation was actually run with real output recorded in the progress file. Run outstanding validations when tools allow, including `bash scripts/validate-wiki.sh` for wiki-structure changes.
4. Ensure promised wiki updates are complete, `wiki/log.md` has the relevant entries, `PROGRESS.md` moves the plan from Active to Completed, and `.agent/context.md` is refreshed.
5. Archive the plan/progress pair only after all validations pass and the completion checklist is fully true.
6. If anything is missing, stop, leave the plan active, and record a blocker instead of archiving it.