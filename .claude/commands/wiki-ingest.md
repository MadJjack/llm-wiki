---
description: "Compile source material from raw/ into the wiki, using the provided target when available"
disable-model-invocation: true
allowed-tools: Read Write Bash
---

Compile source material from `raw/` into the wiki.

1. If the user named a target, use it. If not, ask for a path under `raw/` or a small target set.
2. Read only the source files under `raw/`. Never modify anything in `raw/`.
3. Convert the source material into the appropriate `wiki/` pages with YAML frontmatter and `[[wikilinks]]`.
4. Update `wiki/index.md` with any pages created or materially changed.
5. Append one log entry per source file processed:
   `## [YYYY-MM-DD] ingest | <Source Title>`
   to `wiki/log.md`.
6. If the source is ambiguous or incomplete, preserve the gap instead of inventing details.