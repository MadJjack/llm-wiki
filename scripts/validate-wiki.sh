#!/usr/bin/env bash
# scripts/validate-wiki.sh - Structural validator for the LLM Wiki repo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

FAIL_COUNT=0

pass() { echo -e "  ${GREEN}[ok]${RESET} $*"; }
fail() { echo -e "  ${RED}[fail]${RESET} $*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
info() { echo -e "${CYAN}[check]${RESET} $*"; }

has_frontmatter_key() {
  local file="$1"
  local key="$2"

  awk -v target="${key}:" '
    NR == 1 { next }
    $0 == "---" { exit found ? 0 : 1 }
    index($0, target) == 1 { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$file"
}

active_symptom_index_rows() {
  awk '
    /<!--/ { in_comment = 1 }
    !in_comment && /^\|/ { print }
    /-->/ { in_comment = 0; next }
  ' "$REPO_ROOT/wiki/index.md" | awk 'NR > 2'
}

check_required_files() {
  local missing=0
  local required_files=(
    "CLAUDE.md"
    "AGENTS.md"
    ".github/copilot-instructions.md"
    "CONVENTIONS.md"
    "PROGRESS.md"
    "wiki/index.md"
    "wiki/log.md"
  )

  info "Checking required root files"
  for file in "${required_files[@]}"; do
    if [ ! -f "$REPO_ROOT/$file" ]; then
      fail "Missing required file: $file"
      missing=1
    fi
  done

  if [ "$missing" -eq 0 ]; then
    pass "Required root files present"
  fi
}

check_single_mirror() {
  local mirror="$1"
  local mirror_file="$REPO_ROOT/$mirror"
  local stripped

  stripped="$(mktemp)"

  if [ ! -f "$mirror_file" ]; then
    fail "Missing mirror file: $mirror"
    rm -f "$stripped"
    return
  fi

  if [ "$(wc -l < "$mirror_file")" -lt 3 ]; then
    fail "Mirror file is too short: $mirror"
    rm -f "$stripped"
    return
  fi

  tail -n +3 "$mirror_file" > "$stripped"
  if diff -u "$REPO_ROOT/CLAUDE.md" "$stripped" >/dev/null; then
    pass "$mirror matches CLAUDE.md"
  else
    fail "$mirror is out of sync with CLAUDE.md"
  fi

  rm -f "$stripped"
}

check_mirror_sync() {
  info "Checking mirror sync"
  check_single_mirror "AGENTS.md"
  check_single_mirror ".github/copilot-instructions.md"
}

check_plan_progress_pairs() {
  local plan_tmp
  local progress_tmp
  local missing_progress
  local missing_plans

  info "Checking plan/progress pairing"

  plan_tmp="$(mktemp)"
  progress_tmp="$(mktemp)"

  (
    cd "$REPO_ROOT"
    find .agent/plans -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" | sed 's#^.agent/plans/##' | LC_ALL=C sort
  ) > "$plan_tmp"
  (
    cd "$REPO_ROOT"
    find .agent/progresses -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" | sed 's#^.agent/progresses/##' | LC_ALL=C sort
  ) > "$progress_tmp"

  missing_progress="$(comm -23 "$plan_tmp" "$progress_tmp" || true)"
  missing_plans="$(comm -13 "$plan_tmp" "$progress_tmp" || true)"

  if [ -z "$missing_progress" ] && [ -z "$missing_plans" ]; then
    pass "Plan/progress files are paired"
  else
    if [ -n "$missing_progress" ]; then
      while IFS= read -r rel; do
        [ -n "$rel" ] && fail "Missing progress file for plan: .agent/progresses/$rel"
      done <<EOF
$missing_progress
EOF
    fi

    if [ -n "$missing_plans" ]; then
      while IFS= read -r rel; do
        [ -n "$rel" ] && fail "Missing plan file for progress: .agent/plans/$rel"
      done <<EOF
$missing_plans
EOF
    fi
  fi

  rm -f "$plan_tmp" "$progress_tmp"
}

check_wiki_frontmatter() {
  local section_failed=0
  local file
  local rel

  info "Checking wiki frontmatter"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"

    case "$rel" in
      "wiki/index.md"|"wiki/log.md")
        continue
        ;;
    esac

    if [ "$(sed -n '1p' "$file")" != "---" ]; then
      fail "Missing frontmatter opening fence: $rel"
      section_failed=1
      continue
    fi

    if ! awk 'NR == 1 { next } $0 == "---" { found = 1; exit } END { exit found ? 0 : 1 }' "$file"; then
      fail "Missing frontmatter closing fence: $rel"
      section_failed=1
      continue
    fi

    for key in type created updated status; do
      if ! has_frontmatter_key "$file" "$key"; then
        fail "Missing frontmatter key '$key' in $rel"
        section_failed=1
      fi
    done
  done < <(find "$REPO_ROOT/wiki" -type f -name "*.md" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Wiki frontmatter is present"
  fi
}

check_symptom_index() {
  local section_failed=0
  local symptom_index="$REPO_ROOT/wiki/index.md"
  local file
  local rel
  local page
  local line
  local cell
  local symptom
  local trimmed

  info "Checking Symptom Index wiring"

  for dir in troubleshooting lessons; do
    while IFS= read -r -d '' file; do
      rel="${file#$REPO_ROOT/wiki/}"
      page="${rel%.md}"

      for key in symptoms error_codes affects triggers; do
        if ! has_frontmatter_key "$file" "$key"; then
          fail "Missing '$key' in $rel"
          section_failed=1
        fi
      done

      if ! active_symptom_index_rows | grep -Fq "[[$page]]"; then
        fail "Missing Symptom Index row for $rel"
        section_failed=1
      fi
    done < <(find "$REPO_ROOT/wiki/$dir" -type f -name "*.md" ! -name "_index.md" -print0)
  done

  while IFS= read -r line; do
    cell="$(printf '%s\n' "$line" | awk -F'|' '{gsub(/^ +| +$/, "", $3); print $3}')"
    symptom="$(printf '%s\n' "$line" | awk -F'|' '{gsub(/^ +| +$/, "", $2); print $2}')"

    case "$cell" in
      "[["*"]]")
        page="${cell#[[}"
        page="${page%]]}"
        ;;
      *)
        continue
        ;;
    esac

    case "$page" in
      troubleshooting/*|lessons/*)
        ;;
      *)
        fail "Symptom Index entry must point to troubleshooting/ or lessons/: $page"
        section_failed=1
        continue
        ;;
    esac

    if [ ! -f "$REPO_ROOT/wiki/$page.md" ]; then
      fail "Symptom Index points to missing page: wiki/$page.md"
      section_failed=1
    fi

    trimmed="${symptom//\`/}"
    trimmed="$(printf '%s' "$trimmed" | tr -d '[:space:]')"
    case "$trimmed" in
      ""|"TODO"|"todo"|"..."|"<symptom>"|"placeholder")
        fail "Empty or placeholder symptom text in wiki/index.md for $page"
        section_failed=1
        ;;
    esac
  done < <(active_symptom_index_rows || true)

  if [ "$section_failed" -eq 0 ]; then
    pass "Symptom Index registrations are valid"
  fi
}

echo ""
echo -e "${BOLD}LLM Wiki Validator${RESET}"
echo "──────────────────────────────────────"

check_required_files
check_mirror_sync
check_plan_progress_pairs
check_wiki_frontmatter
check_symptom_index

echo ""
echo "──────────────────────────────────────"
if [ "$FAIL_COUNT" -eq 0 ]; then
  echo -e "${BOLD}${GREEN}Validation passed.${RESET}"
  exit 0
fi

echo -e "${BOLD}${RED}Validation failed.${RESET} ${FAIL_COUNT} issue(s) found."
exit 1