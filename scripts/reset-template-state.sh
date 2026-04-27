#!/usr/bin/env bash
# scripts/reset-template-state.sh - Restore the repo to a publishable template baseline.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${CYAN}[reset]${RESET} $*"; }
pass() { echo -e "  ${GREEN}[ok]${RESET} $*"; }

write_progress_baseline() {
  cat <<'EOF' > "$REPO_ROOT/PROGRESS.md"
# Progress

> Master project progress tracker. The agent reads this to understand where the project stands.
> Detailed per-plan progress lives in `.agent/progresses/`.
> Update this file when plans are created or completed.

## Convention

| Marker | Meaning |
|---|---|
| `[ ]` | Not started |
| `[-]` | In progress |
| `[x]` | Completed |

---

## Active Plans

| # | Plan | Status | Progress File |
|---|---|---|---|
| — | No active plans | — | — |

---

## Completed Plans

| # | Plan | Completed |
|---|---|---|
| — | No completed plans | — |

---

## Modules

> One section per module or major feature area.
> The agent adds a section here when a plan for that module is created.

<!--
### Module Name
- [ ] 1. Plan name
- [ ] 2. Plan name
-->
EOF
}

write_decisions_baseline() {
  cat <<'EOF' > "$REPO_ROOT/.agent/decisions.md"
# Micro-Decisions Log

> Append-only log of small decisions made during build work.
> For significant architectural choices, use wiki/decisions/ (ADRs) instead.
> This captures the "why" behind day-to-day implementation choices.

**When to log here vs. wiki/decisions/:**
- Here: "used debounce(300) because lower values caused flickering on slow connections"
- ADR: "chose PostgreSQL over MongoDB for the primary data store"

Format: `## [YYYY-MM-DD] #{plan-number} | Decision title`

---

<!-- Agent appends entries above this line, newest first -->
EOF
}

write_log_baseline() {
  cat <<'EOF' > "$REPO_ROOT/wiki/log.md"
# Operation Log

> Append-only. Newest entries at top.
> Format: `## [YYYY-MM-DD] operation | description`
> Operations: `ingest` | `query` | `lint`

Quick grep: `grep "^## \[" wiki/log.md | head -10`

---

<!-- Agent appends entries above this line -->
EOF
}

remove_plan_history() {
  find "$REPO_ROOT/.agent/plans" -maxdepth 1 -type f -name '*.md' ! -name '_template.md' -delete
  find "$REPO_ROOT/.agent/progresses" -maxdepth 1 -type f -name '*.md' ! -name '_template.md' -delete
  find "$REPO_ROOT/.agent/plans/archive" -maxdepth 1 -type f ! -name '.gitkeep' -delete
  find "$REPO_ROOT/.agent/progresses/archive" -maxdepth 1 -type f ! -name '.gitkeep' -delete
}

ensure_archive_placeholders() {
  mkdir -p "$REPO_ROOT/.agent/plans/archive" "$REPO_ROOT/.agent/progresses/archive"

  if [ ! -f "$REPO_ROOT/.agent/plans/archive/.gitkeep" ]; then
    : > "$REPO_ROOT/.agent/plans/archive/.gitkeep"
  fi

  if [ ! -f "$REPO_ROOT/.agent/progresses/archive/.gitkeep" ]; then
    : > "$REPO_ROOT/.agent/progresses/archive/.gitkeep"
  fi
}

echo ""
echo -e "${BOLD}Reset Template State${RESET}"
echo "──────────────────────────────────────"

info "Rewriting tracked history files to baseline content"
write_progress_baseline
write_decisions_baseline
write_log_baseline
pass "Baseline tracker files restored"

info "Removing non-template plan and progress history"
ensure_archive_placeholders
remove_plan_history
pass "Plan/progress history removed"

echo ""
echo "──────────────────────────────────────"
echo -e "${BOLD}${GREEN}Template reset complete.${RESET}"
echo "Run: bash scripts/validate-wiki.sh"
echo "Then confirm the repo contains no maintainer-specific plan, decision, or log history."