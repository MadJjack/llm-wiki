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

WARN_COUNT=0

pass() { echo -e "  ${GREEN}[ok]${RESET} $*"; }
fail() { echo -e "  ${RED}[fail]${RESET} $*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
warn() { echo -e "  ${CYAN}[warn]${RESET} $*"; WARN_COUNT=$((WARN_COUNT + 1)); }
info() { echo -e "${CYAN}[check]${RESET} $*"; }

trim_whitespace() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

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

get_frontmatter_value() {
  local file="$1"
  local key="$2"

  awk -v target="${key}:" '
    NR == 1 { next }
    $0 == "---" { exit }
    index($0, target) == 1 {
      val = substr($0, length(target) + 2)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
      print val
      exit
    }
  ' "$file"
}

active_symptom_index_rows() {
  awk '
    /^## Symptom Index$/ { in_section = 1; next }
    in_section && /^---$/ { exit }
    in_section && /^## / { exit }
    in_section {
      if ($0 ~ /<!--/) {
        in_comment = 1
      }
      if (!in_comment && /^\|/) {
        print
      }
      if ($0 ~ /-->/) {
        in_comment = 0
      }
    }
  ' "$REPO_ROOT/wiki/index.md" | awk 'NR > 2'
}

extract_wikilink_entries() {
  while IFS= read -r -d '' file; do
    awk -v path="${file#$REPO_ROOT/}" '
      {
        if (in_comment) {
          if ($0 ~ /-->/) {
            in_comment = 0
          }
          next
        }

        if ($0 ~ /<!--/) {
          if ($0 !~ /-->/) {
            in_comment = 1
          }
          next
        }

        remaining = $0
        while (match(remaining, /\[\[[^][]+\]\]/)) {
          target = substr(remaining, RSTART + 2, RLENGTH - 4)
          print path "\t" NR "\t" target
          remaining = substr(remaining, RSTART + RLENGTH)
        }
      }
    ' "$file"
  done < <(find "$REPO_ROOT/wiki" -type f -name "*.md" ! -name "log.md" ! -path "$REPO_ROOT/wiki/raw/*" ! -path "$REPO_ROOT/wiki/compiled/*" -print0)
}

normalize_wikilink_target() {
  local target

  target="$(trim_whitespace "$1")"
  target="${target%%|*}"
  target="${target%%#*}"
  target="$(trim_whitespace "$target")"
  target="${target%.md}"

  printf '%s' "$target"
}

should_skip_wikilink_target() {
  case "$1" in
    ""|"ADR-XXX"|"link"|"wikilink"|"wikilinks"|"target")
      return 0
      ;;
  esac

  return 1
}

wikilink_target_exists() {
  local target="$1"

  case "$target" in
    wiki/*)
      [ -f "$REPO_ROOT/$target.md" ]
      ;;
    */*)
      [ -f "$REPO_ROOT/wiki/$target.md" ]
      ;;
    *)
      [ -f "$REPO_ROOT/wiki/$target.md" ] || [ -f "$REPO_ROOT/$target.md" ]
      ;;
  esac
}

require_line() {
  local file="$1"
  local rel="$2"
  local line="$3"
  local description="$4"

  if grep -Fxq "$line" "$file"; then
    return 0
  fi

  fail "$rel missing required template $description: $line"
  return 1
}

require_pattern() {
  local file="$1"
  local rel="$2"
  local pattern="$3"
  local description="$4"

  if grep -Eq "$pattern" "$file"; then
    return 0
  fi

  fail "$rel missing required template $description"
  return 1
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

check_wiki_workspace_layout() {
  local section_failed=0
  local required_dirs=(
    "wiki/raw"
    "wiki/compiled"
    ".agent/decisions"
    ".agent/decisions/archive"
  )
  local dir

  info "Checking workspace layout"

  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$REPO_ROOT/$dir" ]; then
      fail "Missing required directory: $dir"
      section_failed=1
    fi
  done

  for dir in raw compiled; do
    if [ -e "$REPO_ROOT/$dir" ]; then
      fail "Legacy top-level directory should be nested under wiki/: $dir/"
      section_failed=1
    fi
  done

  if [ "$section_failed" -eq 0 ]; then
    pass "wiki and agent workspace directories are present"
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

check_decision_file_pairs() {
  local section_failed=0
  local file
  local rel
  local filename
  local plan_file
  local progress_file
  local declared

  info "Checking decision file pairing"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"
    filename="${rel#.agent/decisions/}"
    plan_file="$REPO_ROOT/.agent/plans/$filename"
    progress_file="$REPO_ROOT/.agent/progresses/$filename"

    if [ ! -f "$plan_file" ]; then
      fail "$rel points to missing plan file: .agent/plans/$filename"
      section_failed=1
    fi

    if [ ! -f "$progress_file" ]; then
      fail "$rel points to missing progress file: .agent/progresses/$filename"
      section_failed=1
    fi
  done < <(find "$REPO_ROOT/.agent/decisions" -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" -print0)

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"
    filename="${rel#.agent/plans/}"
    declared="**Decisions:** \`.agent/decisions/$filename\`"

    if grep -Fq "**Decisions:**" "$file"; then
      if ! grep -Fxq "$declared" "$file"; then
        fail "$rel has mismatched decisions metadata; expected: $declared"
        section_failed=1
      fi

      if [ ! -f "$REPO_ROOT/.agent/decisions/$filename" ]; then
        fail "Missing decision file for new-style plan: .agent/decisions/$filename"
        section_failed=1
      fi
    fi
  done < <(find "$REPO_ROOT/.agent/plans" -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Decision files are paired with new-style plans"
  fi
}

check_plan_template_structure() {
  local section_failed=0
  local file
  local rel
  local filename

  info "Checking plan template structure"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"
    filename="${rel#.agent/plans/}"

    require_line "$file" "$rel" "**File:** \`$rel\`" "file metadata" || section_failed=1
    require_line "$file" "$rel" "**Progress:** \`.agent/progresses/$filename\`" "progress metadata" || section_failed=1
    if grep -Fq "**Decisions:**" "$file"; then
      require_line "$file" "$rel" "**Decisions:** \`.agent/decisions/$filename\`" "decisions metadata" || section_failed=1
    fi
    require_pattern "$file" "$rel" '^\*\*Created:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}$' "created date" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Complexity:\*\* .+$' "complexity metadata" || section_failed=1
    require_pattern "$file" "$rel" '^> \*\*Single-pass feasibility:\*\* .+$' "single-pass feasibility line" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Depends on:\*\* .+$' "depends-on metadata" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Blocks:\*\* .+$' "blocks metadata" || section_failed=1

    for heading in \
      "## Goal" \
      "## Context" \
      "## Scope" \
      "## Wiki & Convention References" \
      "## Technical Approach" \
      "### Key Files / Areas" \
      "## Tasks & Validation" \
      "## Risks & Unknowns" \
      "## Notes"; do
      require_line "$file" "$rel" "$heading" "heading" || section_failed=1
    done

    require_pattern "$file" "$rel" '^### Task [0-9]+ ' "task section" || section_failed=1
    require_line "$file" "$rel" "**Validation:**" "task validation marker" || section_failed=1
  done < <(find "$REPO_ROOT/.agent/plans" -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Plan files preserve required template structure"
  fi
}

check_progress_template_structure() {
  local section_failed=0
  local file
  local rel
  local filename

  info "Checking progress template structure"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"
    filename="${rel#.agent/progresses/}"

    require_line "$file" "$rel" "**Plan:** \`.agent/plans/$filename\`" "plan metadata" || section_failed=1
    if grep -Fq "**Decisions:**" "$file"; then
      require_line "$file" "$rel" "**Decisions:** \`.agent/decisions/$filename\`" "decisions metadata" || section_failed=1
    fi
    require_pattern "$file" "$rel" '^\*\*Started:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}$' "started date" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Last updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}$' "last-updated date" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Status:\*\* .+$' "status metadata" || section_failed=1

    for heading in \
      "## Convention" \
      "## Tasks" \
      "## Validation Results" \
      "## Blockers" \
      "## Discoveries & Notes" \
      "## Wiki Updates Made" \
      "## Retrospective" \
      "## Completion Checklist"; do
      require_line "$file" "$rel" "$heading" "heading" || section_failed=1
    done

    require_pattern "$file" "$rel" '^- \[[ x~-]\] [0-9]+\. .+$' "numbered task checklist item" || section_failed=1
    require_pattern "$file" "$rel" '^### Task [0-9]+ ' "validation result task section" || section_failed=1
  done < <(find "$REPO_ROOT/.agent/progresses" -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Progress files preserve required template structure"
  fi
}

check_decision_template_structure() {
  local section_failed=0
  local file
  local rel
  local filename

  info "Checking decision template structure"

  if [ ! -f "$REPO_ROOT/.agent/decisions/_template.md" ]; then
    fail "Missing required file: .agent/decisions/_template.md"
    section_failed=1
  else
    require_line "$REPO_ROOT/.agent/decisions/_template.md" ".agent/decisions/_template.md" "**Plan:** \`.agent/plans/{N}.{plan-name}.md\`" "plan metadata" || section_failed=1
    require_line "$REPO_ROOT/.agent/decisions/_template.md" ".agent/decisions/_template.md" "**Progress:** \`.agent/progresses/{N}.{plan-name}.md\`" "progress metadata" || section_failed=1
    require_line "$REPO_ROOT/.agent/decisions/_template.md" ".agent/decisions/_template.md" "**Created:** YYYY-MM-DD" "created metadata" || section_failed=1
    require_line "$REPO_ROOT/.agent/decisions/_template.md" ".agent/decisions/_template.md" "**Last updated:** YYYY-MM-DD" "last-updated metadata" || section_failed=1
    require_line "$REPO_ROOT/.agent/decisions/_template.md" ".agent/decisions/_template.md" "## Micro-Decisions" "micro-decisions heading" || section_failed=1
  fi

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"
    filename="${rel#.agent/decisions/}"

    require_pattern "$file" "$rel" '^# .+ Decisions$' "title" || section_failed=1
    require_line "$file" "$rel" "**Plan:** \`.agent/plans/$filename\`" "plan metadata" || section_failed=1
    require_line "$file" "$rel" "**Progress:** \`.agent/progresses/$filename\`" "progress metadata" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Created:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}$' "created date" || section_failed=1
    require_pattern "$file" "$rel" '^\*\*Last updated:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}$' "last-updated date" || section_failed=1
    require_line "$file" "$rel" "## Micro-Decisions" "micro-decisions heading" || section_failed=1
  done < <(find "$REPO_ROOT/.agent/decisions" -type f -name "*.md" ! -name "_template.md" ! -path "*/archive/*" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Decision files preserve required template structure"
  fi
}

check_wiki_frontmatter() {
  local section_failed=0
  local file
  local rel

  info "Checking wiki frontmatter"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"

    case "$rel" in
      "wiki/index.md"|"wiki/log.md"|"wiki/raw/"*|"wiki/compiled/"*)
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

check_wiki_trust_metadata() {
  local section_failed=0
  local file
  local rel
  local page_type
  local confidence
  local verify_method

  info "Checking wiki trust metadata"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"

    case "$rel" in
      "wiki/index.md"|"wiki/log.md"|"wiki/raw/"*|"wiki/compiled/"*|"wiki/glossary.md")
        continue
        ;;
    esac

    case "$(basename "$file")" in
      "_index.md")
        continue
        ;;
    esac

    page_type="$(get_frontmatter_value "$file" "type")"
    case "$page_type" in
      architecture|decision|integration|troubleshooting|lesson)
        ;;
      *)
        continue
        ;;
    esac

    for key in confidence verified_at verification_method; do
      if ! has_frontmatter_key "$file" "$key"; then
        fail "Missing trust metadata key '$key' in $rel (type: $page_type)"
        section_failed=1
      fi
    done

    confidence="$(get_frontmatter_value "$file" "confidence")"
    case "$confidence" in
      high|medium|low|unverified|"")
        ;;
      *)
        fail "Invalid confidence value '$confidence' in $rel (expected: high|medium|low|unverified)"
        section_failed=1
        ;;
    esac

    verify_method="$(get_frontmatter_value "$file" "verification_method")"
    case "$verify_method" in
      manual-review|automated-test|live-observation|unverified|"")
        ;;
      *)
        fail "Invalid verification_method value '$verify_method' in $rel (expected: manual-review|automated-test|live-observation|unverified)"
        section_failed=1
        ;;
    esac
  done < <(find "$REPO_ROOT/wiki" -type f -name "*.md" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Wiki trust metadata is present and valid"
  fi
}

check_wiki_relations() {
  local section_failed=0
  local file
  local rel
  local invalid_keys

  info "Checking wiki relation type keys"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"

    case "$rel" in
      "wiki/index.md"|"wiki/log.md"|"wiki/raw/"*|"wiki/compiled/"*)
        continue
        ;;
    esac

    if ! has_frontmatter_key "$file" "relations"; then
      continue
    fi

    invalid_keys="$(awk '
      NR == 1 { next }
      $0 == "---" { exit }
      /^relations:/ { in_relations = 1; next }
      in_relations && /^[^ ]/ { exit }
      in_relations && /^  [a-z]/ {
        line = $0
        gsub(/^[[:space:]]+/, "", line)
        sub(/:.*$/, "", line)
        if (line != "supports" && line != "depends_on" && line != "supersedes" && line != "contradicts" && line != "related_to" && line != "derived_from" && line != "part_of") {
          print line
        }
      }
    ' "$file")"

    if [ -n "$invalid_keys" ]; then
      while IFS= read -r key; do
        fail "Invalid relation type key '$key' in $rel (allowed: supports|depends_on|supersedes|contradicts|related_to|derived_from|part_of)"
        section_failed=1
      done <<< "$invalid_keys"
    fi
  done < <(find "$REPO_ROOT/wiki" -type f -name "*.md" -print0)

  if [ "$section_failed" -eq 0 ]; then
    pass "Wiki relation type keys are valid"
  fi
}

check_wiki_page_size() {
  local file
  local rel
  local line_count

  info "Checking wiki page sizes (50–300 lines)"

  while IFS= read -r -d '' file; do
    rel="${file#$REPO_ROOT/}"

    case "$rel" in
      "wiki/index.md"|"wiki/log.md"|"wiki/raw/"*|"wiki/compiled/"*)
        continue
        ;;
    esac

    line_count="$(wc -l < "$file")"

    if [ "$line_count" -gt 300 ]; then
      warn "$rel is $line_count lines (soft cap: 300). Consider splitting into atomic sub-pages."
    fi

    if [ "$line_count" -lt 50 ]; then
      warn "$rel is $line_count lines (min: 50). Stubs should be merged or expanded."
    fi
  done < <(find "$REPO_ROOT/wiki" -type f -name "*.md" -print0)
}

check_wikilinks() {
  local section_failed=0
  local entry
  local source
  local line
  local raw_target
  local target

  info "Checking wikilink targets"

  while IFS=$'\t' read -r source line raw_target; do
    [ -n "$source" ] || continue

    target="$(normalize_wikilink_target "$raw_target")"

    if should_skip_wikilink_target "$target"; then
      continue
    fi

    if ! wikilink_target_exists "$target"; then
      fail "$source:$line has unresolved wikilink [[${raw_target}]]"
      section_failed=1
    fi
  done < <(extract_wikilink_entries | awk -F'\t' '!seen[$1 FS $3]++')

  if [ "$section_failed" -eq 0 ]; then
    pass "Wikilink targets resolve to files"
  fi
}

echo ""
echo -e "${BOLD}LLM Wiki Validator${RESET}"
echo "──────────────────────────────────────"

check_required_files
check_wiki_workspace_layout
check_mirror_sync
check_plan_progress_pairs
check_decision_file_pairs
check_plan_template_structure
check_progress_template_structure
check_decision_template_structure
check_wiki_frontmatter
check_wiki_trust_metadata
check_wiki_relations
check_symptom_index
check_wikilinks
check_wiki_page_size

echo ""
echo "──────────────────────────────────────"
if [ "$FAIL_COUNT" -eq 0 ] && [ "$WARN_COUNT" -eq 0 ]; then
  echo -e "${BOLD}${GREEN}Validation passed.${RESET}"
  exit 0
fi

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo -e "${BOLD}${GREEN}Validation passed.${RESET} ${WARN_COUNT} warning(s)."
  exit 0
fi

echo -e "${BOLD}${RED}Validation failed.${RESET} ${FAIL_COUNT} issue(s) found, ${WARN_COUNT} warning(s)."
exit 1
