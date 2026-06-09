## LiteLLM & Vibe-Kanban

### LiteLLM

> 🚨 Important security notice (March 2026):
> * LiteLLM was recently the target of a serious supply chain attack on PyPI (versions 1.82.7 and 1.82.8 contained a credential stealer that targeted .env files, SSH keys and cloud credentials).
> * Hardening recommendation: The official Docker image (ghcr.io/berriai/litellm) was not affected by the compromised PyPI packages and provides secure isolation. When installing via pip, a secure, current version must be pinned (>= 1.83.0).
> * To be on the safe side, we use digest pinning at this point.

#### Installation and configuration

```shell
# 1. Create configuration directory & isolated environment
mkdir -p ~/.litellm && cd ~/.litellm

# Store API keys ONLY in this dedicated file to prevent agents from bypassing LiteLLM.
# Remove these keys from your global ~/.shlib/exports/ to enforce routing!
cat << 'EOF' > .env
LITELLM_MASTER_KEY="sk-lionheart-master-key"
OPENROUTER_API_KEY="your_openrouter_key_here"
# KILOCODE_API_KEY="your_kilo_key_here"
# OPENCODE_ZEN_API_KEY="your_zen_key_here"
DATABASE_URL="postgresql://postgres:postgres@firecrawl-nuq-postgres-1:5432/litellm"
EOF
chmod 600 .env

# 2. Create basic config (config.yaml)
# This is just an example configuration (syntax blueprint). Models can be customized as desired.
cat << 'EOF' > config.yaml
model_list:

  # --------------------------------------------------------🎓 Lionheart Models
  - model_name: lionheart-daily
    litellm_params:
      model: openrouter/deepseek/deepseek-v4-flash
  - model_name: lionheart-weekly
    litellm_params:
      model: openrouter/deepseek/deepseek-v4-pro
  - model_name: lionheart-chat
    litellm_params:
      model: openrouter/xiaomi/mimo-v2.5
  - model_name: lionheart-maintain
    litellm_params:
      model: openrouter/qwen/qwen3.7-max

  # --------------------------------------------------------🧠 Models Fleet
  - model_name: gpt-5.5
    litellm_params:
      model: openrouter/openai/gpt-5.5
  - model_name: opus-4.8
    litellm_params:
      model: openrouter/anthropic/claude-opus-4.8
  - model_name: sonnet-4.6
    litellm_params:
      model: openrouter/anthropic/claude-sonnet-4.6
  - model_name: gemini-3.5-flash
    litellm_params:
      model: openrouter/google/gemini-3.5-flash
  - model_name: gemini-3.1-pro
    litellm_params:
      model: openrouter/google/gemini-3.1-pro-preview
  - model_name: deepseek-v4-flash
    litellm_params:
      model: openrouter/deepseek/deepseek-v4-flash
  - model_name: deepseek-v4-pro
    litellm_params:
      model: openrouter/deepseek/deepseek-v4-pro
  - model_name: minimax-m3
    litellm_params:
      model: openrouter/minimax/minimax-m3
  - model_name: kimi-k2.6
    litellm_params:
      model: openrouter/moonshotai/kimi-k2.6
  - model_name: glm-5.1
    litellm_params:
      model: openrouter/z-ai/glm-5.1
  - model_name: qwen3.7-max
    litellm_params:
      model: openrouter/qwen/qwen3.7-max
  - model_name: qwen3.7-plus
    litellm_params:
      model: openrouter/qwen/qwen3.7-plus
  - model_name: mimo-v2.5-pro
    litellm_params:
      model: openrouter/xiaomi/mimo-v2.5-pro
  - model_name: mimo-v2.5
    litellm_params:
      model: openrouter/xiaomi/mimo-v2.5
  - model_name: grok-4.3
    litellm_params:
      model: openrouter/x-ai/grok-4.3

router_settings:
  fallbacks:
    - {"lionheart-daily": ["mimo-v2.5"]}
    - {"lionheart-weekly": ["mimo-v2.5-pro"]}
EOF

# 3. own db in postgres from firecrawl (installed for Open WebUI RAG)
docker exec -it firecrawl-nuq-postgres-1 psql -U postgres -c "CREATE DATABASE litellm;"

# optional: remove old container if present
docker rm -f litellm 2>/dev/null || true

# 4. special tag (skills endpoint) / pull image / resolve immutable digest
litellmtag="v1.85.0-rc.2" && docker pull ghcr.io/berriai/litellm:$litellmtag && \
litellm_digest=$(docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/berriai/litellm:$litellmtag)

# 5. start container using digest and isolated .env file
docker run -d --name litellm --restart always --network firecrawl_backend -p 127.0.0.1:4040:4000 \
  --add-host=host.docker.internal:host-gateway --security-opt=no-new-privileges:true --cap-drop=ALL \
  --env-file "$HOME/.litellm/.env" \
  -v "$HOME/.litellm/config.yaml:/app/config.yaml:ro" "$litellm_digest" --config /app/config.yaml

# 6. only run once per container lifecycle 
#    necessary because we integrated the container directly into the firecrawl network (postgres)
docker network connect bridge litellm && docker restart litellm
```

#### Virtual Keys and Maintenance
```shell
# 7. generate virtual key for Lionheart (Tracking only, no hard limits)
# Note: Deen Lupysta defaults to active spend monitoring via UI instead of hard limits
# to avoid complex "budget exceeded" handling in agent workflows.
# If budgets are desired, add: "max_budget": 5.0, "budget_duration": "30d" to the JSON payload.
curl -s -X POST "http://127.0.0.1:4040/key/generate" \
  -H "Authorization: Bearer sk-lionheart-master-key" \
  -H "Content-Type: application/json" \
  -d '{
    "key_alias": "Lionheart",
    "models": ["lionheart-daily", "lionheart-weekly", "lionheart-chat", "lionheart-maintain"],
    "aliases": {"user_id": "lionheart_agent"}
  }' | jq

# Maintenance
docker logs -f litellm
curl http://127.0.0.1:4040/health  
docker restart litellm

# cost tracking / spend queries
curl -s http://127.0.0.1:4040/spend/logs \
  -H "Authorization: Bearer sk-lionheart-master-key" | jq '.[] | {request_id, model, spend, total_tokens, status}'
# aggregated spend per model (USD, today):
curl -s "http://127.0.0.1:4040/spend?start_date=$(date -u +%Y-%m-%d)" \
  -H "Authorization: Bearer sk-lionheart-master-key" | jq
```


#### Guardrails

* The basic idea: when I work with agents in open webui or in vscode or on the console, I take over the task of guardrails and prevent harmful actions through human-in-the-loop. No guardrails mechanic is necessary here, or if so, just a 'basic' version. But mostly I use the provider directly.
* However, if I use autonomous heartbeat agents, guardrails become an important tool.
* I'm still in the middle of the evaluation and research phase here

*(🚧 WIP)*




### Vibe-Kanban

**⚠️ Sunsetting notice (April 2026):** The company bloop has shut down. Vibe-Kanban continues as community-maintained open source (Apache-2.0). Remote services are limited; local-only architecture is the recommended deployment. Expect a slower release cadence and self-hosted deployments. See [sunset announcement](https://www.vibekanban.com/blog/shutdown).

#### Variants — what we're picking (and why)

Vibe-Kanban ships two install paths:

| Path | Command | Best for |
|------|---------|----------|
| **Local desktop** (single-user) | `npx vibe-kanban` | Personal machine, no auth, no DB — opens a Tauri desktop app |
| **Remote / Cloud** (multi-user) | `docker compose` on `crates/remote/` | Self-hosted shared Kanban with auth, projects, real-time sync (ElectricSQL) |

For Deen Lupysta we pick the **Remote / Cloud compose stack** with **bootstrap local auth** (no OAuth, no external account needed) — we want a real server (HTTP API + persistent DB + sync) so that other agents and the desktop client can connect to it later, but we keep it single-tenant.

#### Light profile — what's in the stack

The default `docker-compose.yml` in `crates/remote/` already comes in three optional profiles. We run the **base stack only**:

* `remote-db` — Postgres 16 (logical replication enabled for ElectricSQL)
* `electric` — ElectricSQL sync engine (internal, no host port)
* `remote-server` — Axum HTTP API + React SPA (port `8081` inside the container)

Excluded profiles (deliberately not started):

* `relay` — relay/tunnel daemon for remote SSH workspace access. Adds a Rust build, port `8082`, plus a wildcard TLS hostname. Not needed for local agent orchestration.
* `attachments` — Azurite blob storage for issue file uploads. Disabled; we don't attach files to issues.

If you ever need either, see the [optional profiles section](https://github.com/BloopAI/vibe-kanban/blob/main/crates/remote/README.md#optional-profiles) in the upstream README.

#### Port & directory decisions (and why)

| What | Default | Deen Lupysta | Reason |
|------|---------|--------------|--------|
| Web UI / API port | `3000` (host) → `8081` (container) | **`3001` → `8081`** | Port `3000` is taken by the **MCPHub user service** (see [02-mcphub-openwebui](02-mcphub-openwebui.md)). |
| Postgres host port | `5433` (debug) | `5433` (default) | No collision; leave for `psql` debugging. |
| Relay port | `8082` | not used | Relay profile is disabled. |
| Repo path | n/a | `~/gits/vibe-kanban` | Standard `~/gits/` policy. |

#### Installation

```shell
# 1. clone (if not already present)
cd ~/gits && git clone https://github.com/BloopAI/vibe-kanban.git && cd vibe-kanban

# 2. install shlib — gives us the `vk` manager (start/stop/logs/token/etc.)
ln -s ~/gits/deen-lupysta/scripts/vibe-kanban.sh ~/.shlib/shlibs/72-vibe-kanban.sh

# 3. generate two secrets
JWT_SECRET=$(openssl rand -base64 48)
ELECTRIC_PW=$(openssl rand -base64 24)

# 4. create .env.remote (single shared admin, no OAuth, port 3001)
cat > ~/gits/vibe-kanban/crates/remote/.env.remote <<EOF
# required
VIBEKANBAN_REMOTE_JWT_SECRET=$JWT_SECRET
ELECTRIC_ROLE_PASSWORD=$ELECTRIC_PW

# host port override (avoids mcphub on :3000)
REMOTE_SERVER_PORTS=127.0.0.1:3001:8081
PUBLIC_BASE_URL=http://localhost:3001

# bootstrap local auth — set BOTH to enable a single shared admin
SELF_HOST_LOCAL_AUTH_EMAIL=admin@deen-lupysta.local
SELF_HOST_LOCAL_AUTH_PASSWORD=change-me-to-a-strong-password

# oauth intentionally left blank (we use local auth)
GITHUB_OAUTH_CLIENT_ID=
GITHUB_OAUTH_CLIENT_SECRET=
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=

# optional integrations — all off
LOOPS_EMAIL_API_KEY=
VITE_RELAY_API_BASE_URL=
EOF
chmod 600 ~/gits/vibe-kanban/crates/remote/.env.remote

# 5. first start — builds the Rust + Node image (one-time ~5-10 min on this box)
vk up
```

> 💡 **Subsequent starts** are near-instant because Docker caches the build layers. The `remote-server` image rebuilds only when you change source files or pull a new commit.
>
> 💡 **`vk` shlib** is the single point of contact: `vk up`, `vk down`, `vk logs`, `vk status`, `vk health`, `vk open`, `vk token`, `vk reset`. Run `vk help` for the full list.

#### Verify it works

```shell
# 1) all three containers healthy?
vk status
# NAMES                       STATUS                   PORTS
# remote-electric-1           Up X minutes (healthy)
# remote-remote-server-1      Up X minutes (healthy)   127.0.0.1:3001->8081/tcp
# remote-remote-db-1          Up X minutes (healthy)   0.0.0.0:5433->5432/tcp

# 2) health endpoint returns JSON
vk health                              # → 200
curl -sS http://localhost:3001/v1/health
# {"status":"ok","version":"0.1.27"}

# 3) login works → JWT issued + personal org auto-created
curl -sS -X POST http://localhost:3001/v1/auth/local/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@deen-lupysta.local","password":"change-me-to-a-strong-password"}' \
  | python3 -m json.tool | head -5
# { "access_token": "eyJ…", "refresh_token": "eyJ…" }

# 4) use the access_token to call a protected endpoint
TOKEN=$(vk token)
curl -sS -H "Authorization: Bearer $TOKEN" http://localhost:3001/v1/identity | python3 -m json.tool
# { "user_id": "…", "username": null, "email": "admin@deen-lupysta.local" }

# 5) open the web UI
vk open
```

> ⚠️ **API gotchas** (only relevant if you script the API directly — the web UI hides these):
> * `POST /v1/projects` requires `color` in **HSL format** (`"142 71% 45%"`), not hex.
> * `POST /v1/issues` requires `status_id` (column UUID) and `sort_order` (float). The web UI creates both for you.
> * All mutations return `{ "data": …, "txid": <postgres_xid> }` so Electric can sync. Don't unwrap the wrong field.

#### Key responsibilities (from README Section 5.1)

* Kanban board + git worktree branches for autonomous agents
* Parallel orchestration: multiple agents in parallel or chained (sequence)
* Git & project integration with branches per task
* Bidirectional MCP:
  * As **client**: passes tools (from MCPHub or LiteLLM) to the agents
  * As **server**: exposes the Kanban board itself as an MCP resource
* Autonomous agents can independently create tasks or query board status

#### Maintenance

```shell
# tail logs (all services or a single one)
vk logs                  # all
vk logs remote-server    # one service

# rebuild the server image (after a `git pull`)
vk build && vk up

# full reset — ⚠️ drops DB + Electric state, keeps .env.remote
vk reset

# stop without losing data
vk down
```

> 🔄 **Updates:** `cd ~/gits/vibe-kanban && git pull && vk build && vk up`. The compose file references `crates/remote/`, so a fresh `git pull` is the only upgrade path — there is no image registry we pull from in this setup.

Lionheart health checks (planned, see `health-checks.md`):
* service status (container / process) — covered by `vk status` / `vk health`
* MCP server reachability — pending the MCP client/server wiring
* local vs remote mode warning — n/a in this single-tenant deployment





