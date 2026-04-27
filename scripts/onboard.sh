#!/usr/bin/env bash
# scripts/onboard.sh — First-time setup for LLM Wiki in a new repository.
# Safe to run multiple times: skips steps already done.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
skip() { echo -e "  ${YELLOW}–${RESET} $* (already done)"; }
info() { echo -e "  ${CYAN}→${RESET} $*"; }

echo ""
echo -e "${BOLD}LLM Wiki — Onboarding Setup${RESET}"
echo "──────────────────────────────────────"

# ── Step 1: Copy context.md.example → context.md ─────────────────────────────
CONTEXT_EXAMPLE="$REPO_ROOT/.agent/context.md.example"
CONTEXT_FILE="$REPO_ROOT/.agent/context.md"

echo ""
echo -e "${BOLD}Step 1: Bootstrap agent context${RESET}"

if [ ! -f "$CONTEXT_EXAMPLE" ]; then
  echo -e "  ${YELLOW}⚠${RESET}  .agent/context.md.example not found — skipping."
elif [ -f "$CONTEXT_FILE" ]; then
  skip ".agent/context.md already exists — not overwriting your working state"
else
  cp "$CONTEXT_EXAMPLE" "$CONTEXT_FILE"
  ok "Created .agent/context.md from template"
fi

# ── Step 2: Patch .gitignore ──────────────────────────────────────────────────
GITIGNORE="$REPO_ROOT/.gitignore"
GITIGNORE_ENTRY=".agent/context.md"

echo ""
echo -e "${BOLD}Step 2: Patch .gitignore${RESET}"

if [ ! -f "$GITIGNORE" ]; then
  echo "$GITIGNORE_ENTRY" > "$GITIGNORE"
  ok "Created .gitignore with $GITIGNORE_ENTRY"
elif grep -qxF "$GITIGNORE_ENTRY" "$GITIGNORE"; then
  skip "$GITIGNORE_ENTRY already in .gitignore"
else
  # Add a blank line separator if the file doesn't end with one
  if [ -s "$GITIGNORE" ] && [ "$(tail -c1 "$GITIGNORE" | wc -l)" -eq 0 ]; then
    echo "" >> "$GITIGNORE"
  fi
  echo "# LLM Wiki — per-developer agent cache (not shared)" >> "$GITIGNORE"
  echo "$GITIGNORE_ENTRY" >> "$GITIGNORE"
  ok "Added $GITIGNORE_ENTRY to .gitignore"
fi

# ── Step 3: Verify required files exist ───────────────────────────────────────
echo ""
echo -e "${BOLD}Step 3: Verify wiki structure${RESET}"

REQUIRED_FILES=(
  "CLAUDE.md"
  "CONVENTIONS.md"
  "PROGRESS.md"
  "wiki/index.md"
  "wiki/log.md"
)

all_ok=true
for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "$REPO_ROOT/$f" ]; then
    ok "$f"
  else
    echo -e "  ${YELLOW}⚠${RESET}  Missing: $f"
    all_ok=false
  fi
done

if [ "$all_ok" = false ]; then
  echo ""
  info "Some required files are missing. Make sure you copied the full llm-wiki folder."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────"
echo -e "${BOLD}${GREEN}Setup complete.${RESET}"
echo ""
echo -e "Next steps — run ${BOLD}/wiki-onboard${RESET} in your AI agent:"
echo ""
echo -e "  GitHub Copilot  -> open Copilot Chat, type ${BOLD}/wiki-onboard${RESET}"
echo -e "  Claude Code     -> open Claude Code, type ${BOLD}/wiki-onboard${RESET}"
echo -e "  Codex / other   -> paste .github/prompts/wiki-onboard.prompt.md into chat"
echo ""
