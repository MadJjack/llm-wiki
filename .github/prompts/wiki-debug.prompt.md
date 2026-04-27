---
name: "wiki-debug"
description: "Debug an error or symptom by checking the Symptom Index first, then the linked troubleshooting or lesson page"
argument-hint: "[exact error string or symptom]"
agent: agent
---

Debug an error or symptom using the wiki retrieval path first.

1. Use the exact user symptom or error string if provided. If not, ask for the exact text or clearest observable symptom.
2. Check the Symptom Index in `wiki/index.md` first.
3. If it hits, read the linked troubleshooting or lesson page before scanning source.
4. If it misses, read related troubleshooting or lesson pages and only then inspect source or other docs.
5. Explain the likely cause and next fix.
6. If you discover a new durable issue, create or update the corresponding troubleshooting or lesson page with extended frontmatter (`symptoms`, `error_codes`, `affects`, `triggers`), register a Symptom Index row in `wiki/index.md`, and append the appropriate `wiki/log.md` entry.
7. Never modify `raw/`. Use exact error strings where possible.