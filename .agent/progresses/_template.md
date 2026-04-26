# {N}. {Plan Name} — Progress

**Plan:** `.agent/plans/{N}.{plan-name}.md`
**Started:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD
**Status:** 🟡 In Progress | 🔴 Blocked | ✅ Done

---

## Convention

| Marker | Meaning |
|---|---|
| `[ ]` | Not started |
| `[-]` | In progress |
| `[x]` | Completed |

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
**Description:** What is blocking.
**Resolution:** Fill in when unblocked.
-->

---

## Discoveries & Notes

> Running log of findings and mid-task decisions. Newest at top.
> Flag wiki-worthy items with 📌.
> Flag micro-decisions with ⚡ (these go in .agent/decisions.md).

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

- [ ] All tasks `[x]`
- [ ] All validation tests passed and output recorded
- [ ] All blockers resolved
- [ ] All 📌 wiki updates made and logged above
- [ ] All ⚡ micro-decisions logged in `.agent/decisions.md`
- [ ] Retrospective filled in
- [ ] `wiki/log.md` updated
- [ ] `PROGRESS.md` updated
- [ ] `.agent/context.md` updated
- [ ] Move both plan + progress to `archive/` folder
