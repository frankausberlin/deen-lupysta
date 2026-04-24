#!/usr/bin/env bash
# install.sh — Install the Luxurious Python Stack shell library
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
LIB_FILE="$SCRIPT_DIR/luxuspythonstacklib.sh"
SHLIB_DIR="$HOME/.shlib/shlibs"
SHLIB_FILE="$SHLIB_DIR/80-luxuspythonstack.sh"

echo "🔧 Luxurious Python Stack — Installer"
echo ""

# Check if lib file exists
if [[ ! -f "$LIB_FILE" ]]; then
    echo "Error: luxuspythonstacklib.sh not found at $LIB_FILE" >&2
    exit 1
fi

# Option A: Install into shlib (if shlib system detected)
if [[ -d "$SHLIB_DIR" ]]; then
    echo "shlib system detected at $SHLIB_DIR"
    if [[ -f "$SHLIB_FILE" ]]; then
        echo "  → Updating existing: $SHLIB_FILE"
    else
        echo "  → Installing: $SHLIB_FILE"
    fi
    cp "$LIB_FILE" "$SHLIB_FILE"
    echo "  ✓ Done. Reload shell with: rlb"
    echo ""
    echo "  Verify: type pyinit"
    exit 0
fi

# Option B: Source directly in .zshrc/.bashrc
echo "No shlib system detected."
echo "Add this line to your ~/.zshrc or ~/.bashrc:"
echo ""
echo "  source $LIB_FILE"
echo ""
echo "Then reload: source ~/.zshrc"
