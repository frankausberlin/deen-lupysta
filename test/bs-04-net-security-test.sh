#!/bin/bash
# bs-04-net-security-test.sh — Stage 2 Step 3: Network & Security
# Corresponds to: base-system/04-net-security.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== bs-04: Network & Security ==="

# --- [auto] SSH server ---
if systemctl is-enabled --quiet ssh 2>/dev/null; then
  ok "ssh service enabled"
else
  no "ssh service not enabled"
fi

if systemctl is-active --quiet ssh 2>/dev/null; then
  ok "ssh service running"
else
  no "ssh service not running"
fi

# --- [auto] SSH keys ---
if [ -f ~/.ssh/id_ed25519 ]; then
  ok "~/.ssh/id_ed25519 exists"
else
  no "~/.ssh/id_ed25519 missing"
fi

if [ -f ~/.ssh/id_ed25519.pub ]; then
  ok "~/.ssh/id_ed25519.pub exists"
else
  no "~/.ssh/id_ed25519.pub missing"
fi

if [ -f ~/.ssh/authorized_keys ]; then
  PERMS=$(stat -c %a ~/.ssh/authorized_keys 2>/dev/null)
  if [ "$PERMS" = "600" ]; then
    ok "authorized_keys has correct permissions (600)"
  else
    no "authorized_keys wrong permissions ($PERMS, expected 600)"
  fi
else
  no "~/.ssh/authorized_keys missing"
fi

SSHDIR_PERMS=$(stat -c %a ~/.ssh 2>/dev/null)
if [ "$SSHDIR_PERMS" = "700" ]; then
  ok "~/.ssh has correct permissions (700)"
else
  no "~/.ssh wrong permissions ($SSHDIR_PERMS, expected 700)"
fi

# --- [auto] SSH hardening config ---
HARDENING=/etc/ssh/sshd_config.d/99-custom-hardening.conf
if [ -f "$HARDENING" ]; then
  ok "$HARDENING exists"
else
  no "$HARDENING missing"
fi

if [ -f "$HARDENING" ]; then
  grep -q "PubkeyAuthentication yes" "$HARDENING" && ok "PubkeyAuthentication yes" || no "PubkeyAuthentication yes missing"
  grep -q "PasswordAuthentication no" "$HARDENING" && ok "PasswordAuthentication no" || no "PasswordAuthentication no missing"
  grep -q "PermitRootLogin no" "$HARDENING" && ok "PermitRootLogin no" || no "PermitRootLogin no missing"
  grep -q "AllowUsers" "$HARDENING" && ok "AllowUsers present" || no "AllowUsers missing"
fi

# sshd config valid? (needs sudo — commented for auto-run)
# sudo sshd -t 2>/dev/null && ok "sshd config valid" || no "sshd config invalid"

# comfort link
if [ -L ~/.shlib/99-custom-hardening.conf ]; then
  ok "~/.shlib/99-custom-hardening.conf comfort link exists"
else
  no "~/.shlib/99-custom-hardening.conf comfort link missing"
fi

# --- [auto] UFW firewall (needs sudo for status) ---
# ufw status requires root — check if binary exists for auto, full check in hitl
if command -v ufw &>/dev/null; then
  ok "ufw installed"
else
  no "ufw not installed"
fi

# --- [auto] fail2ban ---
if systemctl is-enabled --quiet fail2ban 2>/dev/null; then
  ok "fail2ban enabled"
else
  no "fail2ban not enabled"
fi

if systemctl is-active --quiet fail2ban 2>/dev/null; then
  ok "fail2ban running"
else
  no "fail2ban not running"
fi

if [ -f /etc/fail2ban/jail.local ]; then
  ok "/etc/fail2ban/jail.local exists"
  grep -q "\[sshd\]" /etc/fail2ban/jail.local && ok "sshd jail configured" || no "sshd jail missing in jail.local"
else
  no "/etc/fail2ban/jail.local missing"
fi

if [ -L ~/.shlib/jail.local ]; then
  ok "~/.shlib/jail.local comfort link exists"
else
  no "~/.shlib/jail.local comfort link missing"
fi

if [ -L ~/.shlib/.ssh ]; then
  ok "~/.shlib/.ssh comfort link exists"
else
  no "~/.shlib/.ssh comfort link missing"
fi

# --- [hitl] SSH login verification ---
# Open a second SSH session to this machine and confirm key-based login works
# Confirm password authentication is rejected

# --- [hitl] Firewall verification ---
# Run `sudo ufw status verbose` and confirm expected rules
# Uncomment to run:
# sudo ufw status verbose

# --- [hitl] sshd config validation (needs sudo) ---
# Uncomment to run:
# sudo sshd -t && echo "sshd config valid" || echo "sshd config INVALID"

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
