---
type: setup
tags: []
created: 2026-05-04
updated: 2026-05-05
status: current
relations:
  supports: []
  depends_on: []
  supersedes: []
  contradicts: []
  related_to: []
confidence: unverified
verified_at: 2026-05-05
verification_method: unverified
owner: ""
---

# Dev Environment Setup

> Everything needed to get the project running locally.

## Prerequisites
- [ ] ...

## Initial Setup
```bash
# Agent fills this in
```

## Obsidian Vault

Open this folder as the Obsidian vault:

```text
/Users/jacquespaul/Dev/llm-wiki/wiki
```

Do not open the repository root as the vault if you want the graph to resolve correctly. The wiki's internal links are written relative to `wiki/`, so a link such as `[[patterns/clean-code-checklist]]` resolves to `wiki/patterns/clean-code-checklist.md` only when `wiki/` is the vault root.

Use `wiki/index.md` as the home note. In Obsidian, that note appears as `index.md` because the vault root is already `wiki/`.

The global graph should show links between pages such as [[patterns/clean-code-checklist]], [[patterns/software-design-checklist]], and [[patterns/design-patterns-decision-guide]]. If the graph is noisy, use Obsidian's graph filters to exclude `raw/` and `compiled/`; those folders hold source material and generated artifacts rather than compiled knowledge pages.

## Environment Variables

| Variable | Required | Description |
|---|---|---|

## Running Locally
```bash
# Agent fills this in
```

## Running Tests
```bash
# Agent fills this in
```

## Related
- [[troubleshooting/_index]]
- [[index]]
