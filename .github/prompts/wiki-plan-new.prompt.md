---
name: "wiki-plan-new"
description: "Create the next-numbered plan/progress/decision trio from templates and activate it in PROGRESS.md"
argument-hint: "[plan name and goal]"
agent: agent
---

Create the next numbered plan/progress/decision trio for a new unit of work.

1. If the user did not provide a plan name, module name, and goal, ask once for the missing inputs.
2. Determine the next plan number by inspecting `.agent/plans/` and ignoring `_template.md` and `archive/`.
3. Copy `.agent/plans/_template.md`, `.agent/progresses/_template.md`, and `.agent/decisions/_template.md` to the new numbered filenames before filling them in.
4. Preserve every template metadata field and section heading. Fill in or replace placeholder content, but do not remove required structure.
5. Use the Task Router in `wiki/index.md` to choose the first wiki references the plan should consult.
6. Fill the plan completely: goal, context, scope, references, technical approach, tasks, and risks. Every task must include at least one exact validation command or concrete check.
7. Fill the matching progress file with the same task names, pending validation sections, decision-file metadata, and any early blocker notes.
8. Fill the matching decision file with the plan/progress metadata and an empty `## Micro-Decisions` section.
9. Update `PROGRESS.md`: add the plan to `## Active Plans`, include the matching progress and decision files, remove the `No active plans` row if present, and add or update the relevant module section.
10. Do not mark anything complete until the validations have actually run. If the work is too large for one pass, split it into child plans instead.
