---
description: "Answer codebase questions from the wiki first, then persist durable answers back into the wiki when needed"
disable-model-invocation: true
allowed-tools: Read Write Bash
---

Answer the user's codebase question from the wiki first, then write back durable knowledge when appropriate.

1. If the question is error- or symptom-shaped, check the Symptom Index in `wiki/index.md` first and read the linked troubleshooting or lesson page.
2. Otherwise read `wiki/index.md` and the relevant wiki pages before scanning source files.
3. Answer from the wiki first. Only inspect source when the wiki is missing, stale, or ambiguous.
4. If the answer is durable and not already captured, update the appropriate existing wiki page or create the right new page with frontmatter, then update `wiki/index.md` if needed.
5. For non-trivial repo questions answered from repo knowledge, append:
   `## [YYYY-MM-DD] query | <question summary>`
   to `wiki/log.md`.
6. Never modify `raw/`.