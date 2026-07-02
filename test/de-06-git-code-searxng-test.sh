#!/bin/bash
# bs-06-git-code-searxng-test.sh — Stage 2 Step 4: Git, Code & SearXNG
# Corresponds to:   base-system/06-git-code-searxng.md
# SearXNG standard port: 8090 (keeps 8080 free for Odysseus etc.)

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

# Helper: grep for pattern in variable output (pipefail-safe)
contains() { echo "$1" | grep -c "$2" 2>/dev/null | grep -q '[1-9]'; }

echo "=== bs-06: Git, Code & SearXNG ==="

# --- [auto] Git configuration ---
if [ -f ~/.gitignore_global ]; then
  ok "~/.gitignore_global exists"
else
  no "~/.gitignore_global missing"
fi

EXCL=$(git config --global core.excludesfile 2>/dev/null || echo "")
if [ -n "$EXCL" ]; then
  ok "core.excludesfile set ($EXCL)"
else
  no "core.excludesfile not set"
fi

NAME=$(git config --global user.name 2>/dev/null || echo "")
if [ -n "$NAME" ]; then
  ok "user.name set ($NAME)"
else
  no "user.name not set"
fi

EMAIL=$(git config --global user.email 2>/dev/null || echo "")
if [ -n "$EMAIL" ]; then
  ok "user.email set ($EMAIL)"
else
  no "user.email not set"
fi

BRANCH=$(git config --global init.defaultBranch 2>/dev/null || echo "")
if [ "$BRANCH" = "main" ]; then
  ok "init.defaultBranch = main"
else
  no "init.defaultBranch not set to main (got: $BRANCH)"
fi

REBASE=$(git config --global pull.rebase 2>/dev/null || echo "")
if [ "$REBASE" = "true" ]; then
  ok "pull.rebase = true"
else
  no "pull.rebase not set to true (got: $REBASE)"
fi

# --- [auto] VSCode ---
if command -v code &>/dev/null; then
  ok "vscode installed"
else
  no "vscode not installed"
fi

if [ -f /etc/apt/sources.list.d/vscode.list ] || [ -f /etc/apt/sources.list.d/vscode.sources ]; then
  ok "vscode apt sources file exists"
else
  no "vscode apt sources file missing"
fi

if [ -f /etc/apt/keyrings/packages.microsoft.gpg ]; then
  ok "vscode apt key exists"
else
  no "vscode apt key missing"
fi

# --- [auto] SearXNG ---
if [ -d ~/.searxng/config ] && [ -d ~/.searxng/data ]; then
  ok "~/.searxng/config/ and ~/.searxng/data/ exist"
else
  no "~/.searxng directories missing"
fi

if [ -f ~/.searxng/config/settings.yml ]; then
  ok "settings.yml exists"
else
  no "settings.yml missing"
fi

if [ -f ~/.searxng/config/settings.yml ]; then
  if grep -q "ultrasecretkey" ~/.searxng/config/settings.yml 2>/dev/null; then
    no "secret key still 'ultrasecretkey' — not replaced"
  else
    ok "secret key has been replaced"
  fi

  if grep -q "json" ~/.searxng/config/settings.yml 2>/dev/null; then
    ok "JSON format enabled in settings.yml"
  else
    no "JSON format not enabled in settings.yml"
  fi
fi

# Docker checks — capture output first to avoid pipefail race condition
DOCKER_NAMES=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
DOCKER_PORTS=$(docker ps --format '{{.Ports}}' 2>/dev/null || true)

if contains "$DOCKER_NAMES" "searxng"; then
  ok "searxng docker container running"
else
  no "searxng docker container not running"
fi

if contains "$DOCKER_PORTS" "127.0.0.1:8090"; then
  ok "searxng bound to 127.0.0.1:8090"
else
  no "searxng not bound to 127.0.0.1:8090 (check docker ps)"
fi

if [ -L ~/.shlib/settings_searxng.yml ]; then
  ok "~/.shlib/settings_searxng.yml comfort link exists"
else
  no "~/.shlib/settings_searxng.yml comfort link missing"
fi

# --- [hitl] GitHub CLI authentication ---
# Run `gh auth status` and confirm SSH auth is active (not HTTPS token)
# Confirm the uploaded key is id_ed25519.pub
# Uncomment to run:
# gh auth status

# --- [hitl] VSCode nautilus integration (desktop only) ---
# Right-click in Nautilus and confirm "Open with Code" appears in context menu

# --- [hitl] SearXNG functional check ---
# Open http://localhost:8090 and confirm SearXNG search page loads
# Run a test search and confirm JSON format works:
# curl -s "http://localhost:8090/search?q=test&format=json" | jq .

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
