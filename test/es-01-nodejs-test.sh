#!/bin/bash
# es-01-nodejs-test.sh — Stage 3: Node.js (fnm + pnpm)
# Corresponds to:   base-system/01-nodejs.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== es-01: Node.js (fnm + pnpm) ==="

# --- [auto] fnm ---
if command -v fnm &>/dev/null; then
  ok "fnm installed"
else
  no "fnm not installed"
fi

if [ -d ~/.local/share/fnm ]; then
  ok "~/.local/share/fnm/ exists"
else
  no "~/.local/share/fnm/ missing"
fi

if [ -f ~/.shlib/shlibs/40-nodejs-config.sh ]; then
  ok "40-nodejs-config.sh exists"
  grep -q "FNM_PATH" ~/.shlib/shlibs/40-nodejs-config.sh 2>/dev/null && ok "40-nodejs-config.sh contains FNM_PATH" || no "40-nodejs-config.sh missing FNM_PATH"
  grep -q "fnm env" ~/.shlib/shlibs/40-nodejs-config.sh 2>/dev/null && ok "40-nodejs-config.sh contains fnm env" || no "40-nodejs-config.sh missing fnm env"
  grep -q "PNPM_HOME" ~/.shlib/shlibs/40-nodejs-config.sh 2>/dev/null && ok "40-nodejs-config.sh contains PNPM_HOME" || no "40-nodejs-config.sh missing PNPM_HOME"
else
  no "40-nodejs-config.sh missing"
fi

# --- [auto] Node.js ---
if command -v node &>/dev/null; then
  ok "node installed ($(node --version 2>/dev/null))"
else
  no "node not installed"
fi

if command -v npm &>/dev/null; then
  ok "npm installed"
else
  no "npm not installed"
fi

if [ -d ~/.local/share/fnm/aliases/default ]; then
  ok "default Node alias exists"
  if [ -f ~/.local/share/fnm/aliases/default/bin/node ]; then
    ok "persistent default bin/node exists"
  else
    no "persistent default bin/node missing"
  fi
else
  no "no default Node version set (fnm aliases/default missing)"
fi

# --- [auto] Corepack & pnpm ---
if command -v corepack &>/dev/null; then
  ok "corepack installed"
else
  no "corepack not installed"
fi

if command -v pnpm &>/dev/null; then
  ok "pnpm installed ($(pnpm --version 2>/dev/null))"
else
  no "pnpm not installed"
fi

if command -v npx &>/dev/null; then
  ok "npx installed"
else
  no "npx not installed"
fi

if echo "$PATH" | grep -q "PNPM_HOME\|pnpm"; then
  ok "PNPM_HOME in PATH"
else
  no "PNPM_HOME not in PATH"
fi

# --- [auto] Shlib hygiene ---
if grep -rq "fnm_multishells" ~/.shlib/shlibs/ 2>/dev/null; then
  no "stale fnm_multishells paths found in shlib files"
else
  ok "no stale fnm_multishells paths in shlib"
fi

if grep -rE '^export PATH=([^"$]|"[^$]*")' ~/.shlib/shlibs/ 2>/dev/null | grep -v 'export PATH=.*\$'; then
  no "hardcoded PATH snapshots found in shlib files"
else
  ok "no hardcoded PATH snapshots in shlib"
fi

# --- [auto] Global tools ---
if command -v kilocode &>/dev/null; then
  ok "kilocode installed"
else
  no "kilocode not installed"
fi

if command -v pm2 &>/dev/null; then
  ok "pm2 installed"
else
  no "pm2 not installed"
fi

# --- [hitl] Functional check ---
# Run `fnm current` and confirm it shows a Node LTS version
# Run `node --version` and `pnpm --version` and confirm both work
# Run `pm2 status` and confirm pm2 is operational
# Uncomment to run:
# fnm current
# node --version
# pnpm --version
# pm2 status

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
