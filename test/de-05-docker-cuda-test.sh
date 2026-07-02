#!/bin/bash
# de-05-docker-cuda-test.sh — Stage 2 Step 3: Docker & CUDA Toolkit
# Corresponds to:   base-system/05-docker-cuda.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

# Helper: grep for pattern in variable output (pipefail-safe)
contains() { echo "$1" | grep -c "$2" 2>/dev/null | grep -q '[1-9]'; }

echo "=== de-05: Docker & CUDA Toolkit ==="

# --- [auto] Docker Engine ---
if command -v docker &>/dev/null; then
  ok "docker installed ($(docker --version 2>/dev/null | head -1))"
else
  no "docker not installed"
fi

if systemctl is-enabled --quiet docker 2>/dev/null; then
  ok "docker service enabled"
else
  no "docker service not enabled"
fi

if systemctl is-active --quiet docker 2>/dev/null; then
  ok "docker service running"
else
  no "docker service not running"
fi

if [ -f /etc/apt/sources.list.d/docker.sources ]; then
  ok "docker apt sources file exists"
else
  no "docker apt sources file missing"
fi

if [ -f /etc/apt/keyrings/docker.asc ]; then
  ok "docker apt key exists"
else
  no "docker apt key missing"
fi

GROUPS_OUT=$(groups "$USER" 2>/dev/null || echo "")
if contains "$GROUPS_OUT" "docker"; then
  ok "user is in docker group"
else
  no "user not in docker group"
fi

# --- [auto] Docker daemon.json (log rotation) ---
DAEMON_JSON=/etc/docker/daemon.json
if [ -f "$DAEMON_JSON" ]; then
  ok "$DAEMON_JSON exists"
  if grep -q "json-file" "$DAEMON_JSON" && grep -q "max-size" "$DAEMON_JSON"; then
    ok "daemon.json has json-file log driver with max-size"
  else
    no "daemon.json missing log rotation config"
  fi
else
  no "$DAEMON_JSON missing"
fi

# --- [hitl] Docker hello-world ---
# Run `docker run --rm hello-world` and confirm it prints the success message
# (requires reboot or newgrp docker if user was just added to docker group)
# Uncomment to run:
# docker run --rm hello-world

# --- [auto] NVIDIA Container Toolkit (skip on machines without NVIDIA GPU) ---
if ! command -v nvidia-smi &>/dev/null; then
  skip "no NVIDIA GPU detected — skipping container toolkit checks"
else
  if dpkg -l nvidia-container-toolkit &>/dev/null; then
    ok "nvidia-container-toolkit installed"
  else
    no "nvidia-container-toolkit not installed"
  fi

  if [ -f /etc/apt/sources.list.d/nvidia-container-toolkit.list ]; then
    ok "nvidia-container-toolkit apt sources exists"
  else
    no "nvidia-container-toolkit apt sources missing"
  fi

  DOCKER_INFO=$(docker info 2>/dev/null || true)
  if contains "$DOCKER_INFO" "nvidia"; then
    ok "nvidia runtime visible in docker info"
  else
    no "nvidia runtime not visible in docker info"
  fi
fi

# --- [hitl] GPU passthrough (skip on machines without NVIDIA GPU) ---
# Run `docker run --rm --gpus all ubuntu nvidia-smi` and confirm GPU output
# Uncomment to run:
# docker run --rm --gpus all ubuntu nvidia-smi

# --- [auto] UFW-Docker patch ---
if [ -x /usr/local/bin/ufw-docker ]; then
  ok "ufw-docker installed and executable"
else
  no "ufw-docker not installed or not executable"
fi

# ufw-docker integration check (needs sudo — see hitl)
# sudo ufw status | grep -i docker && ok "ufw-docker rules active" || no "ufw-docker rules not found"

# --- [hitl] UFW-Docker verification (needs sudo) ---
# Uncomment to run:
# sudo ufw status | grep -i docker

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
