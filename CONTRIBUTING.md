# Contributing

Thank you for your interest in contributing to LLM Wiki.

---

## Before You Start

- For **bug fixes and small improvements**, open a PR directly.
- For **new features, structural changes, or schema changes**, open an issue first to discuss the approach before writing code.
- Read `CLAUDE.md` — it defines how the agent schema works and is the source of truth for all agent behavior in this repo.

---

## Mirror Files

Three files in this repo are **mirrors** of `CLAUDE.md` and must never be edited directly:

| File | Agent |
|---|---|
| `AGENTS.md` | OpenAI Codex |
| `.github/copilot-instructions.md` | GitHub Copilot |

If your contribution modifies `CLAUDE.md`, you must re-sync both mirrors:

```bash
# Sync AGENTS.md (preserve its 2-line header)
{ head -2 AGENTS.md; tail -n +2 CLAUDE.md; } > tmp && mv tmp AGENTS.md

# Sync .github/copilot-instructions.md (preserve its 2-line header)
{ head -2 .github/copilot-instructions.md; tail -n +2 CLAUDE.md; } > tmp && mv tmp .github/copilot-instructions.md
```

Verify they are in sync:

```bash
diff <(tail -n +3 AGENTS.md) <(tail -n +2 CLAUDE.md)
diff <(tail -n +3 .github/copilot-instructions.md) <(tail -n +2 CLAUDE.md)
```

Both diffs should be empty.

---

## Branch Naming

```
feature/<short-description>
fix/<short-description>
chore/<short-description>
docs/<short-description>
```

---

## Commit Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add symptom index to wiki/index.md
fix: correct broken wikilink in troubleshooting/_index
docs: add contributing guide
chore: sync AGENTS.md mirror after CLAUDE.md update
```

---

## PR Checklist

Before opening a pull request, confirm:

- [ ] Changes are scoped — one logical change per PR
- [ ] `CLAUDE.md` updated if agent behavior changed
- [ ] Mirror files re-synced if `CLAUDE.md` was modified (see above)
- [ ] `wiki/index.md` updated if new wiki pages were added
- [ ] `wiki/log.md` appended if an ingest, query, or lint operation occurred
- [ ] No files in `raw/` were modified (immutable source layer)
- [ ] No secrets, tokens, or personal data included

---

## License

By contributing, you agree that your contributions will be licensed under the
[Apache License 2.0](LICENSE) that covers this project.
