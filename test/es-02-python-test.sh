#!/bin/bash
# es-02-python-test.sh — Stage 3: Python (uv, mamba, direnv)
# Corresponds to: base-system/02-python.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== es-02: Python (uv, mamba, direnv) ==="

# --- [auto] Python base ---
if command -v python3 &>/dev/null; then
  ok "python3 installed"
else
  no "python3 not installed"
fi

# --- [auto] uv ---
if command -v uv &>/dev/null; then
  ok "uv installed ($(uv --version 2>/dev/null | head -1))"
else
  no "uv not installed"
fi

if [ -f ~/.local/bin/uv ] || command -v uv &>/dev/null; then
  ok "uv binary available"
else
  no "uv binary not found"
fi

# uv tools
UV_TOOLS="ruff bump-my-version basedpyright nbstripout"
MISSING=""
for tool in $UV_TOOLS; do
  if ! command -v "$tool" &>/dev/null; then
    MISSING="$MISSING $tool"
  fi
done
if [ -z "$MISSING" ]; then
  ok "all uv tools installed (ruff, bump-my-version, basedpyright, nbstripout)"
else
  no "missing uv tools:$MISSING"
fi

# --- [auto] direnv ---
if command -v direnv &>/dev/null; then
  ok "direnv installed"
else
  no "direnv not installed"
fi

if [ -f ~/.config/direnv/direnvrc ]; then
  ok "~/.config/direnv/direnvrc exists"
  grep -q "layout_uv" ~/.config/direnv/direnvrc 2>/dev/null && ok "direnvrc contains layout_uv" || no "direnvrc missing layout_uv"
else
  no "~/.config/direnv/direnvrc missing"
fi

if grep -q "direnv" ~/.zshrc 2>/dev/null; then
  ok "direnv hook in .zshrc"
else
  no "direnv hook missing in .zshrc"
fi

# --- [auto] Mamba ---
if [ -d ~/miniforge3 ]; then
  ok "~/miniforge3/ exists"
else
  no "~/miniforge3/ missing"
fi

if command -v mamba &>/dev/null; then
  ok "mamba available ($(mamba --version 2>/dev/null | head -1))"
else
  no "mamba not available"
fi

if [ -f ~/.shlib/shlibs/41-python-config.sh ]; then
  ok "41-python-config.sh exists"
  grep -q "UV_PYTHON_PREFERENCE" ~/.shlib/shlibs/41-python-config.sh 2>/dev/null && ok "41-python-config.sh contains UV_PYTHON_PREFERENCE" || no "41-python-config.sh missing UV_PYTHON_PREFERENCE"
  grep -q "MAMBA_ROOT_PREFIX" ~/.shlib/shlibs/41-python-config.sh 2>/dev/null && ok "41-python-config.sh contains MAMBA_ROOT_PREFIX" || no "41-python-config.sh missing MAMBA_ROOT_PREFIX"
  grep -q "mamba" ~/.shlib/shlibs/41-python-config.sh 2>/dev/null && ok "41-python-config.sh contains mamba shell hook" || no "41-python-config.sh missing mamba shell hook"
  grep -q "act" ~/.shlib/shlibs/41-python-config.sh 2>/dev/null && ok "41-python-config.sh contains act function" || no "41-python-config.sh missing act function"
  grep -q "allowuv" ~/.shlib/shlibs/41-python-config.sh 2>/dev/null && ok "41-python-config.sh contains allowuv alias" || no "41-python-config.sh missing allowuv alias"
else
  no "41-python-config.sh missing"
fi

# DIRENV_LOG_FORMAT empty?
if grep -q "DIRENV_LOG_FORMAT" ~/.shlib/shlibs/41-python-config.sh 2>/dev/null; then
  grep -q 'DIRENV_LOG_FORMAT=""' ~/.shlib/shlibs/41-python-config.sh 2>/dev/null && ok "DIRENV_LOG_FORMAT set to empty" || no "DIRENV_LOG_FORMAT not set to empty"
else
  no "DIRENV_LOG_FORMAT not found in shlib"
fi

# --- [auto] Jupyter config ---
if [ -f ~/.jupyter/jupyter_server_config.json ]; then
  ok "~/.jupyter/jupyter_server_config.json exists"
  if grep -q "jupyter_server_documents" ~/.jupyter/jupyter_server_config.json 2>/dev/null && \
     grep -q "false" ~/.jupyter/jupyter_server_config.json 2>/dev/null; then
    ok "RTC extensions disabled"
  else
    no "RTC extensions not disabled"
  fi
else
  no "~/.jupyter/jupyter_server_config.json missing"
fi

# --- [hitl] Functional check ---
# Run `uv --version` and confirm it works
# Run `mamba --version` and confirm it works
# Run `act` without arguments and confirm it shows current environment or switches to base
# Create a test directory, run `allowuv`, and confirm .envrc is created with `layout uv`

# --- [hitl] Data Science environment (optional) ---
# If a ds environment exists: run `mamba activate dsXX` (replace XX) and confirm it activates
# Run `python -c "import torch; print(torch.cuda.is_available())"` and confirm CUDA is available (on GPU machines)

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
