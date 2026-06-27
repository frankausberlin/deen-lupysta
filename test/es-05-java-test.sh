#!/bin/bash
# es-05-java-test.sh — Stage 3: Java (SDKMAN!)
# Corresponds to: developer-environment/05-java.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== es-05: Java (SDKMAN!) ==="

# --- [auto] SDKMAN! ---
if [ -d ~/.sdkman ]; then
  ok "~/.sdkman/ exists"
else
  no "~/.sdkman/ missing"
fi

if [ -f ~/.shlib/shlibs/44-java.sh ]; then
  ok "44-java.sh exists"
  grep -q "SDKMAN_DIR" ~/.shlib/shlibs/44-java.sh 2>/dev/null && ok "44-java.sh contains SDKMAN_DIR" || no "44-java.sh missing SDKMAN_DIR"
  grep -q "sdkman-init.sh" ~/.shlib/shlibs/44-java.sh 2>/dev/null && ok "44-java.sh sources sdkman-init.sh" || no "44-java.sh missing sdkman-init.sh source"
else
  no "44-java.sh missing"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok "shlib lock intact after sdkman install"
  else
    no "shlib lock violated"
  fi
fi

# --- [auto] JDK ---
if command -v java &>/dev/null; then
  ok "java installed ($(java --version 2>&1 | head -1))"
else
  no "java not installed"
fi

if java --version 2>&1 | grep -q "21\."; then
  ok "java version is 21 (LTS)"
else
  no "java version is not 21 (got: $(java --version 2>&1 | head -1))"
fi

# --- [auto] Build tools ---
if command -v mvn &>/dev/null; then
  ok "maven installed"
else
  no "maven not installed"
fi

if command -v gradle &>/dev/null; then
  ok "gradle installed"
else
  no "gradle not installed"
fi

# --- [hitl] Shlib hygiene ---
# Check that .zshrc does NOT contain SDKMAN's auto-generated snippet at the end
# (it should only be in shlib)
# Run `sdk version` and confirm SDKMAN is operational
# Uncomment to run:
# grep -c "THIS MUST BE AT THE END OF THE FILE" ~/.zshrc
# sdk version

# --- [hitl] Functional check ---
# Run `java -version` and confirm it shows the correct LTS version
# Run `mvn -version` and `gradle -version` and confirm both work
# Uncomment to run:
# java -version
# mvn -version
# gradle -version

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
