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

1. Copy this repo into your project (or use as a GitHub template)
2. Fill in `CONVENTIONS.md` with your stack and code style
3. `cp .agent/context.md.example .agent/context.md` — bootstrap your local hot cache (gitignored, per-developer)
4. Drop any existing docs into `raw/` and run: `"Ingest raw/<file>"`
5. Ask the agent: `"Scan the repo and populate wiki/architecture/overview.md"`
6. Start working — the agent handles the rest

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

`AGENTS.md` and `.github/copilot-instructions.md` are full mirrors of
`CLAUDE.md` — Copilot and Codex don't follow file pointers, so each agent
needs the schema in its own expected location. Edit `CLAUDE.md` only; the
agent re-syncs both mirrors at session end (see CLAUDE.md → Session End
Checklist).
