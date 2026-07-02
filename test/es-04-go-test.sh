#!/bin/bash
# es-04-go-test.sh — Stage 3: Go (Go Toolchain)
# Corresponds to: base-system/04-go.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== es-04: Go (Go Toolchain) ==="

# --- [auto] Go installation ---
if command -v go &>/dev/null; then
  ok "go installed ($(go version 2>/dev/null))"
else
  no "go not installed"
fi

# --- [auto] Shlib integration ---
if [ -f ~/.shlib/shlibs/43-go-config.sh ]; then
  ok "43-go-config.sh exists"
  grep -q "GOPATH" ~/.shlib/shlibs/43-go-config.sh 2>/dev/null && ok "43-go-config.sh contains GOPATH" || no "43-go-config.sh missing GOPATH"
  grep -q "export PATH" ~/.shlib/shlibs/43-go-config.sh 2>/dev/null && ok "43-go-config.sh contains PATH export" || no "43-go-config.sh missing PATH export"
else
  no "43-go-config.sh missing"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok "shlib lock intact after go install"
  else
    no "shlib lock violated"
  fi
fi

# --- [auto] GOPATH ---
if [ -d ~/go ]; then
  ok "~/go/ directory exists"
else
  no "~/go/ directory missing"
fi

if echo "$PATH" | grep -q "go/bin"; then
  ok "$GOPATH/bin is in PATH"
else
  no "$GOPATH/bin not in PATH"
fi

# --- [hitl] Functional check ---
# Run `go env GOPATH` and confirm it matches ~/go
# If lf was installed: run `lf --version` and confirm it works
# Uncomment to run:
# go env GOPATH
# lf --version

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
