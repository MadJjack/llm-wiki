---
name: "wiki-plan-close"
description: "Verify validations, update wiki and tracker state, and archive a completed plan only after everything passes"
argument-hint: "[plan number or name]"
agent: agent
---

Close an existing plan only when it is actually complete.

1. If the user did not name the plan, ask which active plan should be closed.
2. Read the plan, the matching progress file, the matching decision file if present, `PROGRESS.md`, `.agent/context.md`, and any touched wiki pages.
3. Verify every task is marked `[x]` or `[~]` and every validation was actually run with real output recorded in the progress file. Run outstanding validations when tools allow, including `bash scripts/validate-wiki.sh` for wiki-structure changes.
4. **Scan the progress file for unflushed 📌 and ⚡ items:**
   - For every line beginning with `📌 Wiki update needed:` — confirm the named wiki page was created or updated. If not, do it now.
   - For every line beginning with `⚡ Micro-decision:` — confirm the decision was flushed to the matching `.agent/decisions/{N}.{plan-name}.md` file. If not, flush it now.
   - Do not archive while any 📌 or ⚡ item is still pending.
5. Ensure Task Router routing in `wiki/index.md` is still correct for any new or changed pages, `wiki/log.md` has the relevant entries, `PROGRESS.md` moves the plan from Active to Completed, and `.agent/context.md` is refreshed with what was learned.
6. Archive the plan/progress/decision trio only after all validations pass, the 📌/⚡ scan is clean, and the completion checklist is fully true.
7. If anything is missing, stop, leave the plan active, and record a blocker in the progress file instead of archiving it.
