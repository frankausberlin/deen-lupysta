---
name: lionheart
description: >
  Skill for the heartbeat mechanism of Hermes Agent 'Lion' (LInux Operator Nerd).
  System health monitoring and housekeeping routine.
  Runs periodic checks on services, system resources, and performs routine
  cleanup. Designed for the AI-flavored Ubuntu developer environment
  (Deen Lupysta). Load this skill when the user asks about system health,
  service status, cleanup, monitoring, or when a cron-triggered heartbeat
  job invokes the agent.
---

# Heartbeat — System Health Monitoring

## Overview

The Heartbeat is Lion's self-monitoring and housekeeping routine. It
periodically checks that everything in the AI stack and base system is
healthy, performs gentle cleanup, and reports back to Frank.

This skill is designed to run:
- **Scheduled** via cron (e.g. every 4 hours, daily at 6 AM)
- **On demand** when Frank explicitly asks for a health check
- **Proactively** detected: if Frank says something feels slow, if he
  mentions crashes, disk space, or "can you check if everything is ok"

## Health Checks (in order)

### 1. System Resources

```bash
# Disk usage — warn if any mount > 85%
df -h | awk 'NR==1 || $5+0 > 85'

# RAM — warn if available < 1 GB
free -h | awk '/^Mem:/ {print $3"/"$2 " used ("$4" free)"}'

# CPU load vs core count
uptime | awk -F'load average:' '{print $2}'

# System uptime
uptime -p

# Temperature (if sensors available)
sensors 2>/dev/null | grep -i "core" | head -5

# ZFS/Btrfs pools (if applicable)
zpool list 2>/dev/null || true
```

### 2. Running Services

Check all systemd services that are part of the AI stack + core infrastructure:

| Service | Port | Check Command |
|---------|------|---------------|
| Ollama | 11434 | `systemctl is-active ollama` |
| MCPHub | (configurable) | `systemctl is-active mcphub` |
| Open WebUI | 8081 | `systemctl is-active open-webui` |
| Docker | socket | `systemctl is-active docker` |
| SSH | 22 | `systemctl is-active sshd` |
| fail2ban | - | `systemctl is-active fail2ban` |
| UFW | - | `ufw status` (verify active) |

```bash
# Quick check: is the Ollama HTTP endpoint alive?
curl -s -o /dev/null -w "%{http_code}" http://localhost:11434/api/tags

# Quick check: MCPHub endpoint
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>/dev/null || echo "MCPHub health endpoint not configured"
```

### 3. AI Stack Health

```bash
# Ollama: list loaded models
ollama list 2>/dev/null

# Docker: check if containers are running
docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null

# Check for failed systemd units overall
systemctl --failed --no-legend | awk '{print $1, $2}'
```

### 4. Cleanup & Housekeeping

Run these only when Frank explicitly requests cleanup OR when disk is
running low (>85%). Never auto-clean without notifying first.

```bash
# APT cache
sudo apt-get clean -y && echo "APT cache cleaned"

# Old kernel headers (safe: keeps 2 newest)
sudo apt-get autoremove -y && echo "Old packages removed"

# Journal logs (keep last 500MB)
sudo journalctl --vacuum-size=500M && echo "Journal vacuumed"

# Hermes temp files
find ~/.hermes/audio_cache -name "*.mp3" -mtime +7 -delete 2>/dev/null
find ~/.hermes/tmp -type f -mtime +1 -delete 2>/dev/null

# Old virtual environments (check if repo still exists)
# Warn, don't delete automatically
```

### 5. Git Repo Health

```bash
# Deen Lupysta
cd ~/gits/deen-lupysta && git status --short

# Hermes Agent
cd ~/.hermes/hermes-agent && git status --short
```

## Report Format

Output should be a clean terminal-friendly report with emoji status:

```
═══════════════════════════════════════════
  ❤️  Heartbeat Report — 2026-05-03 14:00
═══════════════════════════════════════════

💾 DISK
  /         52G used of 120G  (43%)   ✅
  /home     80G used of 200G  (40%)   ✅

🧠 RAM
  8.2G / 16G used  —  7.8G free  ✅

⚙️ CPU LOAD
  1.2 / 2.8 / 3.1  (8 cores)  ✅

🔌 SERVICES
  ollama     active ✅
  mcphub     active ✅
  open-webui active ✅
  docker     active ✅

🧹 CLEANUP
  No cleanup needed  ✅

📦 REPOS
  deen-lupysta:  clean  ✅
  hermes-agent:  2 unstaged files  ⚠️

───
Status: ✅ ALL CLEAN  |  ⚠️ 1 warning  |  ❌ 0 critical
```

### MCPHub Server Health Check (Deep Check)

MCPHub manages ~20 MCP servers. Some (especially HuggingFace) tend to
disconnect intermittently. The daily deep check should verify ALL servers:

```bash
# Query MCPHub API for server status
curl -s http://localhost:3000/api/servers | python3 -c "
import sys, json
data = json.load(sys.stdin)
servers = data.get('data', [])
disconnected = [s for s in servers if s.get('status') != 'connected']
if disconnected:
    print(f'⚠️  {len(disconnected)} server(s) disconnected:')
    for s in disconnected:
        print(f'   🔴 {s[\"name\"]} — {s.get(\"error\", \"unknown reason\")[:80]}')
else:
    print(f'✅ All {len(servers)} MCPHub servers connected')
"
```

If any server is disconnected, check if it's a known intermittent issue:
- **HuggingFace** (`EAI_AGAIN`): DNS flapping, usually resolves on reconnect
- **Jupyter** kernel errors: cosmetic, server still works
- **browsermcp** port kill: harmless race condition

For persistent disconnects (>24h), alert Frank and suggest a GUI restart
or `sudo systemctl restart mcphub`.

## Cron Job Setup

The heartbeat should run as a cron job in Hermes Agent:

```bash
# Create a cron job that runs every 4 hours
hermes cron create \
  --name "heartbeat" \
  --schedule "every 4h" \
  --prompt "Run a full heartbeat check. Check all system resources, services, and AI stack components. Report status to Frank. Skip cleanup unless disk > 85% full." \
  --skills lionheart
```

For a daily deep check with cleanup **including MCPHub server audit**:
```bash
hermes cron create \
  --name "heartbeat-daily" \
  --schedule "0 6 * * *" \
  --prompt "Run a DEEP heartbeat check with full cleanup. Check system resources, all systemd services, disk health, AND audit all 20 MCPHub servers for disconnections. If any disk is > 80% full, propose cleanup. If any MCPHub server is disconnected, report which ones." \
  --skills lionheart
```

## When to Run Proactively

Load this skill and run heartbeat checks when Frank says:
- "Irgendwas läuft langsam heute"
- "Kannst du mal nach dem Rechten sehen?"
- "Mein System spinnt"
- "Hast du gerade Zeit für einen Check?"
- "Was ist los mit dem Server?"

Also run automatically if a cron-triggered heartbeat invocation loads
this skill and the prompt asks for a health check.

## Troubleshooting

| Symptom | Action |
|---------|--------|
| Ollama not running | `sudo systemctl start ollama && sudo systemctl enable ollama` |
| MCPHub not running | Check node path (fnm multishell pitfall), restart systemd unit |
| Disk > 90% | Propose cleanup, list largest dirs with `du -sh /* 2>/dev/null` |
| Kernel messages in dmesg | `dmesg -l err,warn` to check hardware issues |
| Hermes repo modified | Check git diff, ask Frank if changes should be committed or stashed |
