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

WIP — installation, configuration, and integration notes coming soon.

Key responsibilities (mirrored from README Section 5.1):

* Kanban board + git worktree branches for autonomous agents
* Parallel orchestration: multiple agents in parallel or chained (sequence)
* Git & project integration with branches per task
* Bidirectional MCP:
  * As **client**: passes tools (from MCPHub or LiteLLM) to the agents
  * As **server**: exposes the Kanban board itself as an MCP resource
* Autonomous agents can independently create tasks or query board status

Lionheart health checks (planned, see `health-checks.md`):
* service status (container / process)
* MCP server reachability
* local vs remote mode warning




