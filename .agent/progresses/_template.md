# {N}. {Plan Name} — Progress

**Plan:** `.agent/plans/{N}.{plan-name}.md`
**Decisions:** `.agent/decisions/{N}.{plan-name}.md`
**Started:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD
**Author:** <!-- developer who started this progress file -->
**Contributors:** <!-- comma-separated names of others who took over or contributed; update on each handoff -->
**Status:** 🟡 In Progress | 🔴 Blocked | ⏳ Awaiting Validation | ✅ Done
**Status reason:** <!-- required when Blocked or Awaiting Validation: what is blocking, who needs to act, and what the success condition is -->

---

## Convention

| Marker | Meaning |
|---|---|
| `[ ]` | Not started |
| `[-]` | In progress |
| `[x]` | Completed and validated |
| `[~]` | Completed by agent; awaiting manual validation or external sign-off |

---

## Tasks

> Numbered to match the plan exactly.
> Do not mark `[x]` without running the validation test defined in the plan.

- [ ] 1. Task name
- [ ] 2. Task name
- [ ] 3. Task name

---

## Validation Results

> Record actual test output as you run each test. Paste real output.

### Task 1 — [Name]
- [ ] `[command]`
  ```
  [paste actual output here]
  ```
  Result: ✅ Pass / ❌ Fail

### Task 2 — [Name]
- [ ] `[command]`
  ```
  [paste actual output here]
  ```
  Result: ✅ Pass / ❌ Fail

---

## Blockers

<!-- Format:
### Blocker: [title]
**Task:** #N
**Since:** YYYY-MM-DD
**Status:** 🔴 Active | ✅ Resolved
**Description:** What is blocking and why. Who needs to act.
**Success condition:** What needs to be true for this blocker to be resolved.
**Resolution:** Fill in when resolved — what changed and when.
-->

---

## Discoveries & Notes

> Running log of findings and mid-task decisions. Newest at top.
> Flag wiki-worthy items with 📌.
> Flag micro-decisions with ⚡ (these go in the matching `.agent/decisions/{N}.{plan-name}.md` file).

<!-- Format:
### YYYY-MM-DD
- Finding or decision.
- 📌 Wiki update needed: [what to add and where]
- ⚡ Micro-decision: [decision made and why]
-->

---

## Wiki Updates Made

| Page | Change | Date |
|---|---|---|
| [[wiki/...]] | Created / Updated | YYYY-MM-DD |

---

## Retrospective

> Fill in when marking the plan Done. Feeds future planning quality.

**What took longer than expected?**
-

**What did the plan get wrong?**
-

**What to do differently next time?**
-

**Worth adding to wiki/lessons/?** Yes / No — [if yes, what]

---

## Completion Checklist

- [ ] All tasks `[x]` or `[~]` (with pending validations noted in Status reason)
- [ ] All validation tests passed and output recorded (or `[~]` tasks have explicit sign-off instructions)
- [ ] All blockers resolved
- [ ] All 📌 wiki updates made and logged above
- [ ] All ⚡ micro-decisions logged in the matching `.agent/decisions/{N}.{plan-name}.md`
- [ ] Retrospective filled in
- [ ] `wiki/log.md` updated
- [ ] `PROGRESS.md` updated
- [ ] `.agent/context.md` updated
- [ ] Move plan + progress + decision files to their `archive/` folders
