#!/usr/bin/env bash
# scripts/install.sh — Add LLM Wiki to an existing repository.
#
# Usage (one-liner, run from your project root):
#   curl -sSL https://raw.githubusercontent.com/MadJjack/llm-wiki/main/scripts/install.sh | bash
#
# Or clone and run locally:
#   bash /path/to/llm-wiki/scripts/install.sh
#
# Safe to run multiple times: never overwrites existing files.

set -euo pipefail

REPO_URL="https://github.com/MadJjack/llm-wiki.git"
TARGET_DIR="$PWD"

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
skip() { echo -e "  ${YELLOW}–${RESET} $* (already exists, skipping)"; }
info() { echo -e "  ${CYAN}→${RESET} $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $*"; }

echo ""
echo -e "${BOLD}LLM Wiki — Install into existing project${RESET}"
echo "──────────────────────────────────────"

# ── Guard: must be run from a directory that looks like a project root ────────
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: target directory does not exist: $TARGET_DIR"
  exit 1
fi

# ── Step 1: Clone template to temp dir ───────────────────────────────────────
echo ""
echo -e "${BOLD}Step 1: Fetch template${RESET}"

TMPDIR_WORK="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WORK"' EXIT

info "Cloning llm-wiki template (shallow)..."
if ! git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR_WORK/llm-wiki" 2>&1; then
  echo ""
  warn "git clone failed. Check your internet connection and try again."
  exit 1
fi
ok "Template fetched"

TEMPLATE="$TMPDIR_WORK/llm-wiki"

# ── Step 2: Copy files (additive — never overwrite) ───────────────────────────
echo ""
echo -e "${BOLD}Step 2: Copy wiki skeleton${RESET}"

# Directories to copy wholesale (additive merge)
DIRS=(
  "wiki"
  ".agent"
  "scripts"
  ".github/prompts"
  ".github/agents"
)

# Root-level files to copy
FILES=(
  "CLAUDE.md"
  "AGENTS.md"
  "CONVENTIONS.md"
  "PROGRESS.md"
)

copied=0
skipped=0

copy_file() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ]; then
    skip "$dst"
    (( skipped++ )) || true
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    ok "$dst"
    (( copied++ )) || true
  fi
}

# Copy root-level files
for f in "${FILES[@]}"; do
  copy_file "$TEMPLATE/$f" "$TARGET_DIR/$f"
done

# Copy directory trees (file by file so we never overwrite)
for dir in "${DIRS[@]}"; do
  src_dir="$TEMPLATE/$dir"
  dst_dir="$TARGET_DIR/$dir"

  if [ ! -d "$src_dir" ]; then
    continue
  fi

  while IFS= read -r -d '' src_file; do
    rel="${src_file#$src_dir/}"
    dst_file="$dst_dir/$rel"
    copy_file "$src_file" "$dst_file"
  done < <(find "$src_dir" -type f -print0)
done

echo ""
info "Copied $copied file(s), skipped $skipped existing file(s)"

# ── Step 3: Patch .gitignore ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Step 3: Patch .gitignore${RESET}"

GITIGNORE="$TARGET_DIR/.gitignore"
GITIGNORE_ENTRY=".agent/context.md"

if [ ! -f "$GITIGNORE" ]; then
  echo "# LLM Wiki — per-developer agent cache (not shared)" > "$GITIGNORE"
  echo "$GITIGNORE_ENTRY" >> "$GITIGNORE"
  ok "Created .gitignore with $GITIGNORE_ENTRY"
elif grep -qxF "$GITIGNORE_ENTRY" "$GITIGNORE"; then
  skip "$GITIGNORE_ENTRY already in .gitignore"
else
  if [ -s "$GITIGNORE" ] && [ "$(tail -c1 "$GITIGNORE" | wc -l)" -eq 0 ]; then
    echo "" >> "$GITIGNORE"
  fi
  echo "# LLM Wiki — per-developer agent cache (not shared)" >> "$GITIGNORE"
  echo "$GITIGNORE_ENTRY" >> "$GITIGNORE"
  ok "Added $GITIGNORE_ENTRY to .gitignore"
fi

# ── Step 4: Bootstrap local context ───────────────────────────────────────────
echo ""
echo -e "${BOLD}Step 4: Bootstrap agent context${RESET}"

CONTEXT_EXAMPLE="$TARGET_DIR/.agent/context.md.example"
CONTEXT_FILE="$TARGET_DIR/.agent/context.md"

if [ ! -f "$CONTEXT_EXAMPLE" ]; then
  warn ".agent/context.md.example not found — skipping context bootstrap"
elif [ -f "$CONTEXT_FILE" ]; then
  skip ".agent/context.md already exists"
else
  cp "$CONTEXT_EXAMPLE" "$CONTEXT_FILE"
  ok "Created .agent/context.md from template"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────"
echo -e "${BOLD}${GREEN}LLM Wiki installed.${RESET}"
echo ""
echo -e "Next steps:"
echo ""
echo -e "  1. Run ${BOLD}bash scripts/validate-wiki.sh${RESET} to confirm structure"
echo -e "  2. Open your AI agent and run ${BOLD}/wiki-onboard${RESET} to fill in project knowledge"
echo ""
echo -e "  GitHub Copilot  → open Copilot Chat, type ${BOLD}/wiki-onboard${RESET}"
echo -e "  Claude Code     → open Claude Code, type ${BOLD}/wiki-onboard${RESET}"
echo -e "  Codex / other   → paste ${BOLD}.github/prompts/wiki-onboard.prompt.md${RESET} into chat"
echo ""
