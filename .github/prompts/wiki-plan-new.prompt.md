---
name: "wiki-plan-new"
description: "Create the next-numbered plan/progress pair from templates and activate it in PROGRESS.md"
argument-hint: "[plan name and goal]"
agent: agent
---

Create the next numbered plan/progress pair for a new unit of work.

1. If the user did not provide a plan name, module name, and goal, ask once for the missing inputs.
2. Determine the next plan number by inspecting `.agent/plans/` and ignoring `_template.md` and `archive/`.
3. Copy `.agent/plans/_template.md` and `.agent/progresses/_template.md` to the new numbered filenames.
4. Fill the plan completely: goal, context, scope, references, technical approach, tasks, and risks. Every task must include at least one exact validation command or concrete check.
5. Fill the matching progress file with the same task names, pending validation sections, and any early blocker notes.
6. Update `PROGRESS.md`: add the plan to `## Active Plans`, remove the `No active plans` row if present, and add or update the relevant module section.
7. Do not mark anything complete until the validations have actually run. If the work is too large for one pass, split it into child plans instead.