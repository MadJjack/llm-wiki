# LLM Wiki

**A self-maintaining second brain for your codebase.**

Your AI agent reads it, writes to it, and routes every question through it — so knowledge accumulates instead of evaporating between sessions. Based on the [Karpathy LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), extended for software development workflows.

Works with GitHub Copilot, Claude Code, Codex, and any agent that reads markdown.

---

## Get Started

### New project — use this repo as a GitHub template

Click **"Use this template"** at the top of this page, or:

[![Use this template](https://img.shields.io/badge/Use_this_template-2ea44f?style=for-the-badge&logo=github)](https://github.com/MadJjack/llm-wiki/generate)

Then run local setup inside your new repo:

```bash
bash scripts/onboard.sh
```

### Existing project — install into your repo

Run this from your project root:

```bash
curl -sSL https://raw.githubusercontent.com/MadJjack/llm-wiki/main/scripts/install.sh | bash
```

The script copies the wiki skeleton, `.agent/` planning system, agent prompts, and scripts into your repo — **without overwriting any existing files**. Then run your agent's `/wiki-onboard` command to fill in project-specific knowledge.

<details>
<summary>Manual install (without curl)</summary>

1. Download and unzip this repo: [llm-wiki-main.zip](https://github.com/MadJjack/llm-wiki/archive/refs/heads/main.zip)
2. Copy `wiki/`, `.agent/`, `scripts/`, `.github/prompts/`, `.github/agents/`, `CLAUDE.md`, `AGENTS.md`, `CONVENTIONS.md`, and `PROGRESS.md` into your project root.
3. Add `.agent/context.md` to your `.gitignore`.
4. Run `bash scripts/onboard.sh` to bootstrap your local agent context.
5. Run `/wiki-onboard` in your agent.

</details>

---

## What's Included

The template ships with a starter wiki built around software development — ready to use immediately and extend as your project grows.

### Engineering Patterns Library

Six agent-readable pattern pages live in `wiki/patterns/`. Your agent uses these automatically when writing or reviewing code — no manual lookup required.

| Pattern | When the agent uses it |
|---|---|
| [Clean Code Checklist](wiki/patterns/clean-code-checklist.md) | Before finishing any code edit or PR |
| [Software Design Checklist](wiki/patterns/software-design-checklist.md) | Before refactoring, extracting abstractions, or adding modules |
| [Design Patterns Decision Guide](wiki/patterns/design-patterns-decision-guide.md) | When choosing a structural pattern (Factory, Observer, Strategy, etc.) |
| [Refactoring Checklist](wiki/patterns/refactoring-checklist.md) | Before and after any refactor pass |
| [Legacy Code Safe Change](wiki/patterns/legacy-code-safe-change.md) | When touching code without full test coverage |
| [Release Readiness Checklist](wiki/patterns/release-readiness-checklist.md) | Pre-release gate |

All six are templates — customize them to match your stack, conventions, and team standards.

### Starter Wiki Structure

Beyond patterns, the wiki skeleton includes stub pages for architecture, API, data model, decisions (ADRs), modules, integrations, testing, lessons, troubleshooting, and setup. Your agent fills these in during `/wiki-onboard` and keeps them current as the project evolves.

---

## Architecture

```
wiki/                 ← Project knowledge workspace.
├── raw/              ← Immutable source material. Agent reads; never modifies.
├── compiled/         ← Generated artifacts from wiki queries.
└── **/*.md           ← Compiled knowledge base. Agent owns this, except raw/.
CLAUDE.md             ← Agent schema. Read first, always.
CONVENTIONS.md        ← Code style and stack decisions. Agent reads before writing code.

.agent/
├── context.md        ← Hot cache. Rewritten at end of every session.
├── decisions.md      ← Legacy micro-decisions log. Append-only.
├── decisions/        ← {N}.{plan-name}.md per-plan micro-decisions
│   └── archive/
├── plans/            ← {N}.{plan-name}.md
│   └── archive/
└── progresses/       ← {N}.{plan-name}.md  ← same filename as matching plan
    └── archive/

PROGRESS.md   ← Master tracker. Updated when plans are created or completed.
```

---

## Plan / Progress / Decision Trio

New plans, progress files, and per-plan micro-decision files are a matched trio with identical filenames:

```
.agent/plans/1.auth-setup.md
.agent/progresses/1.auth-setup.md
.agent/decisions/1.auth-setup.md
```

The root `.agent/decisions.md` file is retained as legacy history for older plans; new work should log micro-decisions in the matching file under `.agent/decisions/`.

---

## Development Flow

```
1. Plan      → .agent/plans/{N}.{name}.md + .agent/progresses/{N}.{name}.md + .agent/decisions/{N}.{name}.md
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
| **Ingest** | "Ingest wiki/raw/file.md" | Source → wiki pages + index + log |
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
├── raw/               ← Immutable source material for ingest
├── compiled/          ← Generated query artifacts
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

## After Installing

**Step 1 — Local bootstrap** (run once per clone, or right after `install.sh`):

```bash
bash scripts/onboard.sh
```

Bootstraps `.agent/context.md`, patches `.gitignore`, and verifies required files.

**Step 2 — Repo onboarding** (run once per project):

| Agent | How to run |
|---|---|
| GitHub Copilot | Open Copilot Chat and type `/wiki-onboard` |
| Claude Code | Open Claude Code and type `/wiki-onboard` |
| Codex / other agents | Paste `.github/prompts/wiki-onboard.prompt.md` into chat |

The onboarding pass fills in starter project knowledge from your actual repo:
- `wiki/architecture/overview.md`
- `CONVENTIONS.md`
- `wiki/setup/dev-environment.md`
- `wiki/data-model/_index.md` (when schema files exist)
- `wiki/log.md`

**What good looks like after onboarding:**
- `.agent/context.md` exists locally and is gitignored
- `CONVENTIONS.md` and wiki starter pages have project-specific content
- `bash scripts/validate-wiki.sh` passes
- Shared truth lives in the tracked wiki, progress, and plan files; personal working memory lives in each developer's local, gitignored hot cache

---

## Commands

This repo combines local shell scripts for bootstrap and validation with chat commands that drive the wiki workflow for onboarding, planning, querying, and maintenance.

### Shell Scripts

| Command | Use |
|---|---|
| `curl -sSL https://raw.githubusercontent.com/MadJjack/llm-wiki/main/scripts/install.sh \| bash` | Install the wiki skeleton into an existing project (additive, no overwrites) |
| `bash scripts/onboard.sh` | Bootstrap the local clone and prepare agent state |
| `bash scripts/validate-wiki.sh` | Structural repo check for required files, mirror sync, plan/progress/decision pairing and template structure, wiki frontmatter, Symptom Index wiring, and broken wikilinks in `wiki/` |
| `bash scripts/reset-template-state.sh` | Maintainer-only reset back to the clean template baseline |

### Agent Workflows

| Workflow | Description |
|---|---|
| `/wiki-onboard` | Populate the wiki skeleton from the current repo. |
| `/wiki-lint` | Run a report-only wiki health check. |
| `/wiki-ingest` | Compile source docs from `wiki/raw/` into wiki pages. |
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
5. Use `/wiki-ingest` when you add source docs under `wiki/raw/`, `/wiki-lint` when you want a report-only health check, and `bash scripts/validate-wiki.sh` before wrapping up larger structural changes.

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
| `.agent/decisions/*.md` | Shared | Per-plan micro-decisions, paired by filename for new work. |
| `.agent/decisions.md` | Shared | Legacy append-only micro-decisions log. |
| `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` | Shared | Agent schema; mirrors stay in sync. |
| `.agent/context.md` | Personal, gitignored | Each developer's own hot cache. |
| `.agent/context.md.example` | Shared | Template the agent copies on first run. |

**Team bootstrap:** a new clone should run `bash scripts/onboard.sh`, not manually copy `.agent/context.md.example`. The script handles the local context file, `.gitignore`, and required-file check in one place.

**Practical team rules:**
- Use `PROGRESS.md` plus the matching plan/progress/decision trio as the shared source of truth.
- Take the next plan number from `PROGRESS.md` and add the plan, progress file, decision file, and tracker row in the same change.
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
