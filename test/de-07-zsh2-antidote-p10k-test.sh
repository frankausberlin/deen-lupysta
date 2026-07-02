#!/bin/bash
# de-07-zsh2-antidote-p10k-test.sh — Stage 2 Step 4: ZSH II, Antidote & P10k
# Corresponds to:   base-system/07-zsh2-antidote-p10k.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

# Helper: grep for pattern in variable output (pipefail-safe)
contains() { echo "$1" | grep -c "$2" 2>/dev/null | grep -q '[1-9]'; }

echo "=== de-07: ZSH II, Antidote & P10k ==="

# --- [auto] MesloLGS NF fonts ---
# fc-list outputs "MesloLGS NF:style=Regular" etc.
# Capture output once to avoid pipefail race condition with fc-list in pipe.
FONT_CACHE=$(fc-list 2>/dev/null || true)
FONT_STYLES="Regular Bold Italic Bold Italic"
FONT_OK=true
for style in $FONT_STYLES; do
  if ! contains "$FONT_CACHE" "MesloLGS NF:style=$style"; then
    FONT_OK=false
  fi
done
if $FONT_OK; then
  ok "all 4 MesloLGS NF fonts installed"
else
  no "some MesloLGS NF fonts missing (check fc-list | grep MesloLGS)"
fi

# --- [auto] Antidote ---
if [ -d ~/.antidote ] && [ -f ~/.antidote/antidote.zsh ]; then
  ok "~/.antidote exists and contains antidote.zsh"
else
  no "~/.antidote missing or incomplete"
fi

if [ -L ~/.shlib/.antidote ]; then
  ok "~/.shlib/.antidote comfort link exists"
else
  no "~/.shlib/.antidote comfort link missing"
fi

# --- [auto] Plugin selection ---
if [ -f ~/.zsh_plugins.txt ]; then
  ok "~/.zsh_plugins.txt exists"
  PLUGINS="powerlevel10k zsh-completions fzf-tab zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-autopair"
  MISSING=""
  for p in $PLUGINS; do
    grep -q "$p" ~/.zsh_plugins.txt 2>/dev/null || MISSING="$MISSING $p"
  done
  if [ -z "$MISSING" ]; then
    ok "all expected plugins in zsh_plugins.txt"
  else
    no "missing plugins:$MISSING"
  fi
else
  no "~/.zsh_plugins.txt missing"
fi

if [ -L ~/.shlib/.zsh_plugins.txt ]; then
  ok "~/.shlib/.zsh_plugins.txt comfort link exists"
else
  no "~/.shlib/.zsh_plugins.txt comfort link missing"
fi

# --- [auto] Shlib integration ---
if [ -f ~/.shlib/shlibs/31-zsh-appearance.sh ]; then
  ok "31-zsh-appearance.sh exists"
  grep -q "antidote" ~/.shlib/shlibs/31-zsh-appearance.sh 2>/dev/null && ok "31-zsh-appearance.sh contains antidote load" || no "31-zsh-appearance.sh missing antidote load"
  grep -q "compinit" ~/.shlib/shlibs/31-zsh-appearance.sh 2>/dev/null && ok "31-zsh-appearance.sh contains compinit" || no "31-zsh-appearance.sh missing compinit"
  grep -q "zoxide" ~/.shlib/shlibs/31-zsh-appearance.sh 2>/dev/null && ok "31-zsh-appearance.sh contains zoxide init" || no "31-zsh-appearance.sh missing zoxide init"
  grep -q "fzf-tab" ~/.shlib/shlibs/31-zsh-appearance.sh 2>/dev/null && ok "31-zsh-appearance.sh contains fzf-tab config" || no "31-zsh-appearance.sh missing fzf-tab config"
else
  no "31-zsh-appearance.sh missing"
fi

if [ -f ~/.shlib/shlibs/32-zsh-p10k.sh ]; then
  ok "32-zsh-p10k.sh exists"
  grep -q "p10k" ~/.shlib/shlibs/32-zsh-p10k.sh 2>/dev/null && ok "32-zsh-p10k.sh contains p10k source line" || no "32-zsh-p10k.sh missing p10k source"
else
  no "32-zsh-p10k.sh missing"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok "shlib lock intact after zsh2 changes"
  else
    no "shlib lock violated"
  fi
fi

# --- [auto] p10k config ---
if [ -f ~/.p10k.zsh ]; then
  ok "~/.p10k.zsh exists"
else
  no "~/.p10k.zsh missing"
fi

if [ -L ~/.shlib/.p10k.zsh ]; then
  ok "~/.shlib/.p10k.zsh comfort link exists"
else
  no "~/.shlib/.p10k.zsh comfort link missing"
fi

# --- [hitl] Shell verification ---
# Open a fresh shell and confirm:
#   - Powerlevel10k prompt renders correctly
#   - no errors or warnings on shell start
#   - Tab autocompletion works (fzf-tab)
#   - syntax highlighting is active (type a partial command and check for colors)
#   - command history search works (type partial command and press Up arrow)

# --- [hitl] Guake terminal (desktop only) ---
# If installed:
#   - confirm Guake shell is set to zsh
#   - confirm Guake font is set to MesloLGS NF Regular

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
