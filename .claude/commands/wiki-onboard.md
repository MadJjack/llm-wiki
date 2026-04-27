---
description: "First-time wiki setup — scan this repo and populate the wiki skeleton with real project knowledge"
disable-model-invocation: true
allowed-tools: Read Write
---

You are onboarding LLM Wiki into this repository for the first time. Your job is to replace all placeholder content in the wiki with real, accurate information from this codebase.

Work through these steps **in order**. Complete each one fully before moving to the next.

---

## Step 1 — Architecture Overview

Scan the repository structure (source files, config files, package manifests, Dockerfiles, etc.). Then write a complete `wiki/architecture/overview.md` replacing all placeholder sections:

- **Overview**: 2–4 sentences describing the system
- **Components**: key modules/services and their responsibilities
- **Data Flow**: how data moves through the system
- **Tech Stack**: fill the table with real layers, technologies, and versions found in the repo

Use YAML frontmatter:
```yaml
---
type: architecture
tags: []
created: <today's date>
updated: <today's date>
status: current
---
```

---

## Step 2 — Conventions

Read the source files to understand how the project is actually written. Fill in `CONVENTIONS.md` replacing all `<!-- placeholder -->` comments with real entries:

- Stack table (language, framework, database, auth, testing, deployment)
- Naming conventions for files, folders, variables, functions, database tables
- Folder structure (draw from what you see)
- Error handling patterns in use
- API conventions if applicable
- Testing conventions (where tests live, naming patterns, mocking approach)
- Git conventions (branch naming, commit format) — check `.git/config` or recent commits if available
- Any patterns that are obviously enforced (e.g., repository pattern, service layer, DTOs)

If you can't determine a convention confidently, leave the placeholder rather than guessing.

---

## Step 3 — Ingest Existing Docs

List all files in `raw/`. For each file found (skip `raw/_readme.md`):

1. Read it fully
2. Extract the knowledge into appropriate wiki pages under `wiki/`
3. Update `wiki/index.md` with any new pages created
4. After processing all files, append one entry per file to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <Source Title>
   ```

If `raw/` contains only `_readme.md` or is empty, skip this step.

---

## Step 4 — Dev Environment

Scan for: `package.json`, `Makefile`, `Dockerfile`, `docker-compose.yml`, `pyproject.toml`, `Gemfile`, `.env.example`, `README.md`, CI config files (`.github/workflows/`, `.circleci/`, etc.).

Fill in `wiki/setup/dev-environment.md`:

- **Prerequisites**: tools and versions required
- **Initial Setup**: exact shell commands to clone and install
- **Environment Variables**: fill the table from `.env.example` or equivalent
- **Running Locally**: commands to start the app
- **Running Tests**: commands to run the test suite

Use YAML frontmatter with `status: current` and today's date.

---

## Step 5 — Data Model

Look for schema definitions: migration files, ORM models, Prisma schemas, TypeScript interfaces for DB entities, SQL files, etc.

If found, fill in `wiki/data-model/_index.md` with:
- Entity list and one-line descriptions
- Key relationships between entities
- Migration history summary (most recent 3–5 migrations)

If no schema files are found, set `status: draft` in the frontmatter and add a note: "No schema files found during onboard — fill in manually."

---

## Step 6 — Finalize Index and Log

1. Update `wiki/index.md` — ensure every page you created or modified has an entry in the correct category table.
2. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | Onboard — initial wiki population
   ```
3. Update `.agent/context.md` with a 2–4 sentence project state summary, set `Active Plan` to "none", and today's date.

---

## Rules

- Never modify files in `raw/` — read only.
- Use `[[wikilinks]]` for all internal cross-references in wiki pages.
- Set `status: current` on pages you filled in; leave `status: draft` on pages you couldn't populate.
- Do not invent information — if you can't determine something from the repo, leave the placeholder.
