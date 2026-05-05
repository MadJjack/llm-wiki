# Operation Log

> Append-only. Newest entries at top.
> Format: `## [YYYY-MM-DD] operation | description`
> Operations: `ingest` | `query` | `lint`

Quick grep: `grep "^## \[" wiki/log.md | head -10`

---

<!-- Agent appends entries above this line -->

## [2026-05-05] query | Software development principles to follow

## [2026-05-04] build | Harden wiki schema: typed relations and trust metadata
Added Rule 7 (typed relations + trust metadata) to CLAUDE.md and mirrors, extended validate-wiki.sh with check_wiki_trust_metadata and check_wiki_relations, added fields to existing architecture/decision/troubleshooting pages, created wiki/patterns/metadata-model.md.
