# Health Checks — Full Component Coverage

> 🚧 **Status:** Stub. This file is a placeholder for the complete
> ~45-check list across all 16 Deen Lupysta stack components. The
> current `daily-checks.md` (8 checks) and `weekly-checks.md`
> (21 checks) cover the **Tier 1 essentials**. This document will
> eventually list every conceivable check, grouped by stack layer.

## Why this file exists

Lionheart's mandate is to keep the entire Deen Lupysta stack healthy
— not just the services that systemd can monitor. As the stack grows
(Hermes, LiteLLM, Vibe-Kanban, LocalAI, OpenLIT, future tools), the
health-check surface grows too. This file tracks the full wish-list
so checks are not invented ad-hoc each session.

## Stack layers (16 components target)

### Layer 1 — System
- [ ] Ubuntu base
- [ ] shlib lock integrity (✅ in daily #8)
- [ ] nala policy (⛔ never touched — Tier 4)

### Layer 2 — Foundation
- [ ] Docker daemon
- [ ] Docker containers health (✅ in daily #2)
- [ ] CUDA toolkit
- [ ] systemd user services
- [ ] Network reachability (SearXNG ✅ in daily #7)

### Layer 3 — Inference Backends
- [ ] Ollama service (✅ in daily #1) + model disk usage
- [ ] LocalAI (systemd user service, port 9090)
- [ ] VastAI connectivity (if used)
- [ ] OpenLIT observability endpoint

### Layer 4 — Routing & Security
- [ ] LiteLLM container health
- [ ] LiteLLM config validation
- [ ] LiteLLM master key rotation reminder
- [ ] LiteLLM DB connection (postgres)
- [ ] Guardrails config (when implemented)

### Layer 5 — Agent Harnesses
- [ ] Hermes Agent heartbeat
- [ ] OpenCode binary
- [ ] Claude Code CLI
- [ ] Kilo Code CLI

### Layer 6 — Workflow & Orchestration
- [ ] MCPHub service + API (✅ partially in weekly #21)
- [ ] Vibe-Kanban service + MCP server
- [ ] Open WebUI service (✅ in daily #1)
- [ ] Telegram bot reachability

### Layer 7 — User Interface
- [ ] Open WebUI (RAG index health)
- [ ] Telegram notifications
- [ ] Hermes Desktop App (gateway connection)
- [ ] Lionheart reco.sh freshness

## Tier classification (when implementing)

- **🟢 Tier 1 (auto, read-only):** Most health checks. Quick, safe, daily.
- **🟡 Tier 2 (auto, safe action):** Cleanup, restarts that don't lose data.
- **🔴 Tier 3 (reco.sh only):** Anything requiring sudo, downtime, or risk.
- **⛔ Tier 4 (never):** nala, .zshrc edits, firewall changes.

## How to add a new check

1. Decide the layer and tier
2. Add to `references/daily-checks.md` (if Tier 1 daily) or
   `references/weekly-checks.md` (if Tier 1 weekly)
3. Add a tracking row above
4. Add a Telegram report template entry
5. Verify the command runs without sudo (Frank is in `adm`, `docker`,
   `systemd-journal` groups — that's enough for most reads)

## See also

- `references/daily-checks.md` — the 8 daily Tier-1 checks
- `references/weekly-checks.md` — the 21 weekly Tier-1 checks
- `references/cron-setup.md` — how to schedule the heartbeat
- `references/reco-format.md` — how to write the reco.sh recommendations
