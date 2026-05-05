---
name: "wiki-query"
description: "Answer codebase questions from the wiki first, then persist durable answers back into the wiki when needed"
argument-hint: "[question or topic]"
agent: agent
---

Answer the user's codebase question from the wiki first, then write back durable knowledge when appropriate.

1. If the question is error- or symptom-shaped, check the Symptom Index in `wiki/index.md` first and read the linked troubleshooting or lesson page.
2. Otherwise read the Task Router in `wiki/index.md`, open the matching "Open First" pages, then read the matching "Then Read" pages before scanning source files.
3. After routing to the first-hop pages, follow `relations.supports` and `relations.depends_on` links to find corroborating pages. Prefer `confidence: high` pages for authoritative answers; flag `low` or `unverified` pages as uncertain in the response.
4. Answer from the wiki first. Only inspect source when the routed pages are missing, stale, or ambiguous.
5. If the answer is durable and not already captured, update the appropriate existing wiki page or create the right new page with frontmatter (including `relations:`, `confidence`, `verified_at`, `verification_method`), then update `wiki/index.md` if needed.
6. For non-trivial repo questions answered from repo knowledge, append:
   `## [YYYY-MM-DD] query | <question summary>`
   to `wiki/log.md`.
7. Never modify `wiki/raw/`.
