#!/bin/bash
# de-02-zsh1-shlib-test.sh — Stage 2 Step 1: ZSH & Shlib System
# Corresponds to: developer-environment/02-zsh1-shlib.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== de-02: ZSH-1 & Shlib System ==="

# --- [auto] ZSH installed and active ---
if command -v zsh &>/dev/null; then
  ok "zsh installed"
else
  no "zsh not installed"
fi

if [ "$SHELL" = "/usr/bin/zsh" ] || [ "$SHELL" = "$(which zsh)" ]; then
  ok "zsh is active shell ($SHELL)"
else
  no "zsh not active shell (current: $SHELL)"
fi

# --- [auto] INTERACTIVE_COMMENTS set ---
if grep -q "INTERACTIVE_COMMENTS" ~/.zshrc 2>/dev/null || \
   grep -rq "INTERACTIVE_COMMENTS" ~/.shlib/shlibs/ 2>/dev/null; then
  ok "INTERACTIVE_COMMENTS is set"
else
  no "INTERACTIVE_COMMENTS not found in .zshrc or shlib"
fi

# --- [auto] Shlib directory structure ---
for d in ~/.shlib ~/.shlib/exports ~/.shlib/shlibs; do
  if [ -d "$d" ]; then
    ok "$d exists"
  else
    no "$d missing"
  fi
done

if [ -f ~/.shlib/exports/.gitignore ]; then
  ok "~/.shlib/exports/.gitignore exists"
else
  no "~/.shlib/exports/.gitignore missing"
fi

# --- [auto] deenlupysta.sh symlink ---
LINK=~/.shlib/shlibs/10-deenlupysta.sh
if [ -L "$LINK" ]; then
  TARGET=$(readlink -f "$LINK")
  if [ "$TARGET" = "$(readlink -f ~/gits/deen-lupysta/scripts/deenlupysta.sh 2>/dev/null)" ]; then
    ok "10-deenlupysta.sh -> scripts/deenlupysta.sh"
  else
    no "10-deenlupysta.sh points to wrong target ($TARGET)"
  fi
elif [ -f "$LINK" ]; then
  ok "10-deenlupysta.sh exists (not a symlink)"
else
  no "10-deenlupysta.sh missing"
fi

# --- [auto] .zshrc content ---
if [ -f ~/.zshrc ]; then
  ok "~/.zshrc exists"
else
  no "~/.zshrc missing"
fi

if grep -q "SHLIB_RC_FILE\|SHLIB_LOCK_FILE" ~/.zshrc 2>/dev/null; then
  ok ".zshrc contains shlib lock check block"
else
  no ".zshrc missing shlib lock check block"
fi

if grep -q "SHLIB_EXPORTS_DIR" ~/.zshrc 2>/dev/null; then
  ok ".zshrc contains exports loader"
else
  no ".zshrc missing exports loader"
fi

if grep -q "SHLIB_LIB_DIR" ~/.zshrc 2>/dev/null; then
  ok ".zshrc contains library loader"
else
  no ".zshrc missing library loader"
fi

if grep -q "direnv" ~/.zshrc 2>/dev/null; then
  ok ".zshrc contains direnv hook"
else
  no ".zshrc missing direnv hook"
fi

# --- [auto] Lock mechanism ---
if [ -f ~/.zshrc.lock ]; then
  ok "~/.zshrc.lock exists"
else
  no "~/.zshrc.lock missing"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok ".zshrc and .zshrc.lock are identical"
  else
    no ".zshrc and .zshrc.lock differ — SHLIB LOCK VIOLATION"
  fi
fi

# --- [hitl] Shell verification ---
# Open a fresh shell and confirm:
#   - zsh is active (not bash)
#   - no shlib lock warning appears on shell start
# Uncomment to run:
# echo "Current shell: $SHELL"

# --- [hitl] Functional check ---
# Run `cw` and confirm it works (from deenlupysta.sh, sourced via shlib)
# Run `los` or another alias from deenlupysta.sh and confirm it works
# Uncomment to run:
# cw
# los

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
