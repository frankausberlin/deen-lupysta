#!/bin/bash
# bs-01-readme-stage1-test.sh — Stage 1: Onboarding
# Corresponds to: README.md §6.1
# Tests: nala, git, deen-lupysta repo, concierge skill link, MYDEENLUPYSTA.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== bs-01: Stage 1 — Onboarding ==="

# --- [auto] nala installed ---
if command -v nala &>/dev/null; then
  ok "nala installed ($(nala --version 2>/dev/null | head -1))"
else
  no "nala not installed"
fi

# --- [auto] git installed ---
if command -v git &>/dev/null; then
  ok "git installed ($(git --version))"
else
  no "git not installed"
fi

# --- [auto] an agent installed (check for hermes, opencode, or claude) ---
if command -v hermes &>/dev/null; then
  ok "agent: hermes installed"
elif command -v opencode &>/dev/null; then
  ok "agent: opencode installed"
elif command -v claude &>/dev/null; then
  ok "agent: claude installed"
else
  no "no known agent installed (hermes/opencode/claude)"
fi

# --- [auto] deen-lupysta repo cloned ---
if [ -d ~/gits/deen-lupysta ]; then
  ok "~/gits/deen-lupysta exists"
else
  no "~/gits/deen-lupysta missing"
fi

# --- [auto] ~/.deenlupysta directory ---
if [ -d ~/.deenlupysta ]; then
  ok "~/.deenlupysta exists"
else
  no "~/.deenlupysta missing"
fi

# --- [auto] MYDEENLUPYSTA.md exists ---
if [ -f ~/.deenlupysta/MYDEENLUPYSTA.md ]; then
  ok "MYDEENLUPYSTA.md exists"
else
  no "MYDEENLUPYSTA.md missing"
fi

# --- [auto] backup directory and UNDO.md ---
if [ -d ~/.deenlupysta/backup ]; then
  ok "~/.deenlupysta/backup exists"
else
  no "~/.deenlupysta/backup missing"
fi
if [ -f ~/.deenlupysta/backup/UNDO.md ]; then
  ok "UNDO.md exists"
else
  no "UNDO.md missing"
fi

# --- [auto] concierge skill linked ---
if [ -e ~/.hermes/skills/autonomous-ai-agents/concierge ]; then
  ok "concierge skill linked in ~/.hermes/skills/"
elif [ -e ~/.opencode/skills/concierge ]; then
  ok "concierge skill linked in ~/.opencode/skills/"
else
  no "concierge skill not linked in any agent skills folder"
fi

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
