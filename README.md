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

**Step 1 — File setup** (run once per clone):

```bash
bash scripts/onboard.sh
```

This copies `.agent/context.md.example` → `.agent/context.md` (your personal, gitignored agent cache) and patches `.gitignore` if needed. Safe to re-run.

**Step 2 — AI kickoff** (run once per project):

Run the onboarding command in your preferred agent:

| Agent | How to run onboarding |
|---|---|
| GitHub Copilot | Open Copilot Chat and type `/wiki-onboard` |
| Claude Code | Open Claude Code and type `/wiki-onboard` |
| Codex / other agents | Paste the contents of `.github/prompts/wiki-onboard.prompt.md` into chat |

The agent will scan your repo and populate:
- `wiki/architecture/overview.md` — system structure and tech stack
- `CONVENTIONS.md` — naming, patterns, and code style
- `wiki/setup/dev-environment.md` — prerequisites and run commands
- `wiki/data-model/_index.md` — schema and entities (if schema files exist)
- `wiki/log.md` — operation history

**Optional follow-ons:**
- Drop existing docs into `raw/` and say: `"Ingest raw/<file>"`
- Validate structural rules any time with `bash scripts/validate-wiki.sh`
- Start working — the agent maintains the wiki from here

---

## Command Surface

After onboarding, the repo exposes the same workflow names across supported agent surfaces.

| Workflow | Purpose |
|---|---|
| `/wiki-onboard` | Bootstrap the wiki from the repository and existing docs |
| `/wiki-lint` | Report structural and content issues in the wiki without auto-fixing |
| `/wiki-ingest` | Compile source material from `raw/` into the wiki |
| `/wiki-query` | Answer from the wiki first, then persist durable answers back into the wiki |
| `/wiki-plan-new` | Create the next-numbered plan/progress pair and register it in `PROGRESS.md` |
| `/wiki-plan-close` | Validate and close a completed plan, then archive it |
| `/wiki-debug` | Route an error or symptom through the Symptom Index before broader scanning |
| `/wiki-template-reset` | Maintainer-only reset that restores this repo to a publishable template baseline |

Run `bash scripts/validate-wiki.sh` any time you want a structural check of:
- required root files
- mirror sync (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`)
- plan/progress pairing
- wiki frontmatter
- Symptom Index registration for troubleshooting and lesson pages

### Agent Matrix

| Workflow | GitHub Copilot | Claude Code | Codex / other agents |
|---|---|---|---|
| Onboard | `/wiki-onboard` | `/wiki-onboard` | Paste `.github/prompts/wiki-onboard.prompt.md` |
| Lint the wiki | `/wiki-lint` | `/wiki-lint` | Paste `.github/prompts/wiki-lint.prompt.md` |
| Ingest docs into the wiki | `/wiki-ingest` | `/wiki-ingest` | Paste `.github/prompts/wiki-ingest.prompt.md` |
| Answer and persist a wiki query | `/wiki-query` | `/wiki-query` | Paste `.github/prompts/wiki-query.prompt.md` |
| Start a new plan | `/wiki-plan-new` | `/wiki-plan-new` | Paste `.github/prompts/wiki-plan-new.prompt.md` |
| Close an active plan | `/wiki-plan-close` | `/wiki-plan-close` | Paste `.github/prompts/wiki-plan-close.prompt.md` |
| Debug a symptom | `/wiki-debug` | `/wiki-debug` | Paste `.github/prompts/wiki-debug.prompt.md` |
| Reset template state | `/wiki-template-reset` | `/wiki-template-reset` | Paste `.github/prompts/wiki-template-reset.prompt.md` |

---

## Working with Multiple Developers

The schema is built around a clean shared-vs-personal split. Anyone can clone
the repo and start working without stepping on a teammate's state.

| File | Shared / Personal | Notes |
|---|---|---|
| `wiki/` | Shared | The team's compiled knowledge base. |
| `wiki/log.md` | Shared | Append-only history of ingest/query/lint operations. |
| `PROGRESS.md` | Shared | Master plan tracker — the team-wide "where are we" file. |
| `.agent/plans/*.md` | Shared | The work itself, numbered and committed. |
| `.agent/progresses/*.md` | Shared | Status of each plan, paired by filename. |
| `.agent/decisions.md` | Shared | Append-only micro-decisions log. |
| `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` | Shared | Agent schema; mirrors stay in sync. |
| `.agent/context.md` | **Personal, gitignored** | Each developer's own hot cache. |
| `.agent/context.md.example` | Shared | Template the agent copies on first run. |

**Why `context.md` is per-developer:** it's one agent's subjective working
memory — what *that* session just did and plans to do next. If two developers
committed it, you'd get meaningless merge conflicts and the file would reflect
whoever pushed last, not a shared truth. The shared "where are we" lives in
`PROGRESS.md` plus the active plan/progress pair, which are structured for
multiple authors.

**Workflow on a team:**
- A new clone runs the bootstrap step (`cp .agent/context.md.example .agent/context.md`); the agent does this automatically on first session per the Session Start Checklist.
- Plans are numbered sequentially. To avoid two devs grabbing the same number, pick the next number off `PROGRESS.md` and create the plan/progress files in the same commit/PR that adds the row.
- Wiki edits, decisions, and plan progress merge naturally because they're append-mostly. Avoid rewriting wiki pages from scratch (already a CLAUDE.md rule).

---

## Agent Compatibility

| File | Agent | Role |
|---|---|---|
| `CLAUDE.md` | Claude Code, Claude (claude.ai) | Source of truth |
| `AGENTS.md` | OpenAI Codex (and other agents that look for AGENTS.md) | Mirror of CLAUDE.md |
| `.github/copilot-instructions.md` | GitHub Copilot | Mirror of CLAUDE.md |

**Onboarding command locations:**
- GitHub Copilot: `.github/prompts/wiki-onboard.prompt.md` (run `/wiki-onboard` in Copilot Chat)
- Claude Code: `.claude/commands/wiki-onboard.md` (run `/wiki-onboard` in Claude Code)
- Codex and other agents: use `.github/prompts/wiki-onboard.prompt.md` as the onboarding prompt text

**Workflow command locations:**
- GitHub Copilot: `.github/prompts/*.prompt.md`
- Claude Code: `.claude/commands/*.md`
- Codex and other agents: use the matching `.github/prompts/*.prompt.md` file as the task brief

## Template Maintainer Reset

This repository is both a working project and a publishable template. When template maintainers finish a round of schema or workflow work, the repo can contain tracker rows, plan artifacts, archived examples, decisions, and operation-log entries that are useful during authoring but should not ship to downstream users.

Use the reset script to return the repo to a clean template baseline before publishing or cutting a fresh template snapshot:

```bash
bash scripts/reset-template-state.sh
```

The script is deterministic and idempotent. It rewrites the tracked history files back to their blank template baselines, removes non-template plan/progress artifacts including archived author examples, and preserves the archive directories for future plan closeout.

You can also invoke the same reset flow through the agent wrapper command:

- GitHub Copilot: `/wiki-template-reset`
- Claude Code: `/wiki-template-reset`
- Codex / other agents: paste `.github/prompts/wiki-template-reset.prompt.md`

This is a maintainer hygiene command, not a normal day-to-day workflow. Do not use it in an active project unless you explicitly want to discard tracked template-author history.

After running the reset, validate the result with:

```bash
bash scripts/validate-wiki.sh
```

Then confirm the repo has no author-specific rows left in `PROGRESS.md`, `.agent/decisions.md`, `wiki/log.md`, or archived plan/progress examples.

`AGENTS.md` and `.github/copilot-instructions.md` are full mirrors of
`CLAUDE.md` — Copilot and Codex don't follow file pointers, so each agent
needs the schema in its own expected location. Edit `CLAUDE.md` only; the
agent re-syncs both mirrors at session end (see CLAUDE.md → Session End
Checklist).
