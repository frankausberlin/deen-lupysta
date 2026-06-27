#!/bin/bash
# es-03-rust-test.sh — Stage 3: Rust (rustup & cargo)
# Corresponds to: developer-environment/03-rust.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== es-03: Rust (rustup & cargo) ==="

# --- [auto] Rustup & Cargo ---
if command -v rustup &>/dev/null; then
  ok "rustup installed"
else
  no "rustup not installed"
fi

if command -v cargo &>/dev/null; then
  ok "cargo installed ($(cargo --version 2>/dev/null | head -1))"
else
  no "cargo not installed"
fi

if [ -f ~/.cargo/env ]; then
  ok "~/.cargo/env exists"
else
  no "~/.cargo/env missing"
fi

if [ -f ~/.shlib/shlibs/42-rust.sh ]; then
  ok "42-rust.sh exists"
  grep -q "cargo/env" ~/.shlib/shlibs/42-rust.sh 2>/dev/null && ok "42-rust.sh sources ~/.cargo/env" || no "42-rust.sh missing cargo/env source"
else
  no "42-rust.sh missing"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok "shlib lock intact after rust install"
  else
    no "shlib lock violated"
  fi
fi

# --- [auto] Cargo-Binstall ---
if command -v cargo-binstall &>/dev/null; then
  ok "cargo-binstall installed"
else
  no "cargo-binstall not installed"
fi

# --- [auto] Global cargo tools ---
for tool in cargo-watch cargo-update cargo-edit; do
  if cargo install --list 2>/dev/null | grep -q "$tool"; then
    ok "$tool installed"
  else
    no "$tool not installed"
  fi
done

# --- [hitl] Functional check ---
# Run `rustc --version` and `cargo --version` and confirm both work
# Run `cargo binstall --version` and confirm it works
# Uncomment to run:
# rustc --version
# cargo --version
# cargo binstall --version

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
