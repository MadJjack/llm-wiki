# LLM Wiki — Developer Knowledge System

A self-maintaining knowledge base and planning system for software repositories.
Based on the [Karpathy LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f),
extended for software development workflows.

---

## Architecture

```
raw/          ← Immutable source material. Agent reads; never modifies.
wiki/         ← Compiled knowledge base. Agent owns this entirely.
CLAUDE.md     ← Agent schema. Read first, always.
CONVENTIONS.md← Code style and stack decisions. Agent reads before writing code.
compiled/     ← Generated artifacts from wiki queries.

.agent/
├── context.md        ← Hot cache. Rewritten at end of every session.
├── decisions.md      ← Micro-decisions log. Append-only.
├── plans/            ← {N}.{plan-name}.md
│   └── archive/
└── progresses/       ← {N}.{plan-name}.md  ← same filename as matching plan
    └── archive/

PROGRESS.md   ← Master tracker. Updated when plans are created or completed.
```

---

## Plan / Progress Pairing

Plans and progress files are always a matched pair with identical filenames:

```
.agent/plans/1.auth-setup.md
.agent/progresses/1.auth-setup.md
```

---

## Development Flow

```
1. Plan      → .agent/plans/{N}.{name}.md
2. Build     → execute, following CONVENTIONS.md
3. Validate  → run the validation tests defined in the plan
4. Iterate   → fix failures, re-validate
```

---

## Complexity Indicators

| Indicator | Meaning | Action |
|---|---|---|
| ✅ Simple | Single-pass, low risk | Proceed |
| ⚠️ Medium | May need iteration | Proceed with care |
| 🔴 Complex | Too large for one pass | Break into sub-plans first |

---

## The Three Wiki Operations

| Operation | Trigger | What happens |
|---|---|---|
| **Ingest** | "Ingest raw/file.md" | Source → wiki pages + index + log |
| **Query** | Any codebase question | wiki/index → pages → answer with citations |
| **Lint** | "Lint the wiki" | Find orphans, contradictions, stale pages |

Good query answers can be filed back as permanent wiki pages.

---

## Wiki Structure

```
wiki/
├── index.md           ← Master catalog — agent reads first on every query
├── log.md             ← ## [YYYY-MM-DD] operation | description
├── glossary.md
├── architecture/      ← System design, data flow
├── api/               ← HTTP endpoints, contracts
├── data-model/        ← Schema, entities, migrations
├── decisions/         ← Architecture Decision Records (ADRs)
├── modules/           ← Per-feature knowledge
├── patterns/          ← Reusable code patterns
├── integrations/      ← Third-party APIs and SDKs
├── testing/           ← Test strategy and conventions
├── lessons/           ← Hard-won lessons
├── troubleshooting/   ← Known issues and resolutions
└── setup/             ← Dev environment, onboarding
```

All wiki pages use YAML frontmatter:
```yaml
---
type: module
tags: [auth, middleware]
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: current | stale | draft
---
```

---

## Getting Started

Setup is intentionally two-phase: first bootstrap the clone locally, then run repo onboarding in your agent.

**Step 1 — Local bootstrap** (run once per clone):

```bash
bash scripts/onboard.sh
```

`scripts/onboard.sh` is an idempotent first-run setup script that bootstraps `.agent/context.md`, ensures that file stays ignored in `.gitignore`, verifies the required repo files exist, and then points you to the onboarding command.

**Step 2 — Repo onboarding** (run once per project):

| Agent | How to run onboarding |
|---|---|
| GitHub Copilot | Open Copilot Chat and type `/wiki-onboard` |
| Claude Code | Open Claude Code and type `/wiki-onboard` |
| Codex / other agents | Paste the contents of `.github/prompts/wiki-onboard.prompt.md` into chat |

The onboarding pass fills in the starter project knowledge from the actual repo, including:
- `wiki/architecture/overview.md`
- `CONVENTIONS.md`
- `wiki/setup/dev-environment.md`
- `wiki/data-model/_index.md` when schema files exist
- `wiki/log.md`

**What good looks like after onboarding:**
- `bash scripts/onboard.sh` has created `.agent/context.md` locally and kept it untracked
- `/wiki-onboard` has started replacing placeholders in `CONVENTIONS.md` and the wiki starter pages
- `bash scripts/validate-wiki.sh` passes
- Shared truth lives in the tracked wiki, progress, and plan files, while personal working memory lives in each developer’s local, gitignored hot cache

---

## Commands

This repo combines local shell scripts for bootstrap and validation with chat commands that drive the wiki workflow for onboarding, planning, querying, and maintenance.

### Shell Scripts

| Command | Use |
|---|---|
| `bash scripts/onboard.sh` | Bootstrap the local clone and prepare agent state |
| `bash scripts/validate-wiki.sh` | Structural repo check for required files, mirror sync, plan/progress pairing, wiki frontmatter, and Symptom Index wiring |
| `bash scripts/reset-template-state.sh` | Maintainer-only reset back to the clean template baseline |

### Agent Workflows

| Workflow | Description |
|---|---|
| `/wiki-onboard` | Populate the wiki skeleton from the current repo. |
| `/wiki-lint` | Run a report-only wiki health check. |
| `/wiki-ingest` | Compile source docs from `raw/` into wiki pages. |
| `/wiki-query` | Answer repo questions from the wiki first. |
| `/wiki-plan-new` | Create and activate a new numbered plan. |
| `/wiki-plan-close` | Validate, archive, and close a finished plan. |
| `/wiki-debug` | Debug a symptom using the Symptom Index first. |
| `/wiki-template-reset` | Reset the template repo to a clean publishable baseline. |

### Agent Matrix

| Workflow | GitHub Copilot | Claude Code | Codex / other agents |
|---|---|---|---|
| Onboard | `/wiki-onboard` | `/wiki-onboard` | Paste `.github/prompts/wiki-onboard.prompt.md` |
| Lint | `/wiki-lint` | `/wiki-lint` | Paste `.github/prompts/wiki-lint.prompt.md` |
| Ingest | `/wiki-ingest` | `/wiki-ingest` | Paste `.github/prompts/wiki-ingest.prompt.md` |
| Query | `/wiki-query` | `/wiki-query` | Paste `.github/prompts/wiki-query.prompt.md` |
| New plan | `/wiki-plan-new` | `/wiki-plan-new` | Paste `.github/prompts/wiki-plan-new.prompt.md` |
| Close plan | `/wiki-plan-close` | `/wiki-plan-close` | Paste `.github/prompts/wiki-plan-close.prompt.md` |
| Debug symptom | `/wiki-debug` | `/wiki-debug` | Paste `.github/prompts/wiki-debug.prompt.md` |
| Reset template | `/wiki-template-reset` | `/wiki-template-reset` | Paste `.github/prompts/wiki-template-reset.prompt.md` |

---

## Typical Daily Workflow

1. Run `bash scripts/onboard.sh` once on a fresh clone.
2. Run `/wiki-onboard` once for a new project or when the wiki is still mostly stubbed.
3. Use `/wiki-query` for normal codebase questions so answers come from the wiki first.
4. Use `/wiki-plan-new` before non-trivial work and `/wiki-plan-close` when the plan is validated and done.
5. Use `/wiki-ingest` when you add source docs under `raw/`, `/wiki-lint` when you want a report-only health check, and `bash scripts/validate-wiki.sh` before wrapping up larger structural changes.

---

## Working with Multiple Developers

The schema is built around a clean shared-vs-personal split. Anyone can clone the repo and start working without stepping on a teammate's state.

| File | Shared / Personal | Notes |
|---|---|---|
| `wiki/` | Shared | The team's compiled knowledge base. |
| `wiki/log.md` | Shared | Append-only history of ingest/query/lint operations. |
| `PROGRESS.md` | Shared | Master plan tracker — the team-wide "where are we" file. |
| `.agent/plans/*.md` | Shared | The work itself, numbered and committed. |
| `.agent/progresses/*.md` | Shared | Status of each plan, paired by filename. |
| `.agent/decisions.md` | Shared | Append-only micro-decisions log. |
| `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` | Shared | Agent schema; mirrors stay in sync. |
| `.agent/context.md` | Personal, gitignored | Each developer's own hot cache. |
| `.agent/context.md.example` | Shared | Template the agent copies on first run. |

**Team bootstrap:** a new clone should run `bash scripts/onboard.sh`, not manually copy `.agent/context.md.example`. The script handles the local context file, `.gitignore`, and required-file check in one place.

**Practical team rules:**
- Use `PROGRESS.md` plus the matching plan/progress pair as the shared source of truth.
- Take the next plan number from `PROGRESS.md` and add the plan, progress file, and tracker row in the same change.
- Keep wiki edits, plan updates, and decision logs append-oriented rather than rewriting pages from scratch.

---

## Agent Compatibility

- `CLAUDE.md` is the canonical instruction file for Claude-style agents and serves as the source of truth for shared agent behavior.
- `AGENTS.md` mirrors the same guidance for Codex and other tools that discover agent instructions through the `AGENTS.md` convention.
- `.github/copilot-instructions.md` mirrors the same content for GitHub Copilot, so all three files should stay in sync.

Command wrappers live under `.github/prompts/` and `.claude/commands/`. Other agents can reuse the matching `.github/prompts/*.prompt.md` files directly as task briefs.

## Template Maintainer Reset

This repository also serves as a publishable template. The reset flow is only for maintainers who need to remove tracked authoring history before publishing a clean baseline.

```bash
bash scripts/reset-template-state.sh
bash scripts/validate-wiki.sh
```

`/wiki-template-reset` is a maintainer-only cleanup command for publishing the template, not part of normal project workflow.

After the reset, confirm that the repo is back at the blank template baseline, with shared tracker/history files reset and the wiki validation still passing.

Do not use it in an active project unless you intentionally want to discard tracked template-author history.

`AGENTS.md` and `.github/copilot-instructions.md` are full mirrors of
`CLAUDE.md` — Copilot and Codex don't follow file pointers, so each agent
needs the schema in its own expected location. Edit `CLAUDE.md` only; the
agent re-syncs both mirrors at session end (see CLAUDE.md → Session End
Checklist).
