#!/bin/bash
# es-06-ruby-test.sh — Stage 3: Ruby (rbenv & bundler)
# Corresponds to:   base-system/06-ruby.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== es-06: Ruby (rbenv & bundler) ==="

# --- [auto] rbenv & ruby-build ---
if command -v rbenv &>/dev/null; then
  ok "rbenv installed"
else
  no "rbenv not installed"
fi

if command -v ruby-build &>/dev/null || rbenv install --list &>/dev/null 2>&1; then
  ok "ruby-build available"
else
  no "ruby-build not available"
fi

if [ -f ~/.shlib/shlibs/45-ruby.sh ]; then
  ok "45-ruby.sh exists"
  grep -q "rbenv init" ~/.shlib/shlibs/45-ruby.sh 2>/dev/null && ok "45-ruby.sh contains rbenv init" || no "45-ruby.sh missing rbenv init"
else
  no "45-ruby.sh missing"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok "shlib lock intact after ruby install"
  else
    no "shlib lock violated"
  fi
fi

# --- [auto] Ruby ---
if command -v ruby &>/dev/null; then
  ok "ruby installed ($(ruby --version 2>/dev/null))"
else
  no "ruby not installed"
fi

GLOBAL=$(rbenv global 2>/dev/null || echo "")
if [ -n "$GLOBAL" ] && [ "$GLOBAL" != "system" ]; then
  ok "global Ruby version set ($GLOBAL)"
else
  no "no global Ruby version set (or set to system)"
fi

if [ -d ~/.rbenv/versions ] && [ "$(ls ~/.rbenv/versions/ 2>/dev/null | wc -l)" -ge 1 ]; then
  ok "at least one Ruby version installed in ~/.rbenv/versions/"
else
  no "no Ruby versions in ~/.rbenv/versions/"
fi

# --- [auto] Bundler ---
if command -v bundle &>/dev/null || gem list bundler 2>/dev/null | grep -q bundler; then
  ok "bundler installed"
else
  no "bundler not installed"
fi

# --- [hitl] Functional check ---
# Run `ruby --version` and confirm it shows the compiled version (not system ruby)
# Run `bundle --version` and confirm it works
# Uncomment to run:
# ruby --version
# bundle --version

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
