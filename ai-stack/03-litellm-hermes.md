
### LiteLLM & Hermes

LiteLLM fulfills several tasks in the AI stack:
> * Cost control for all providers (openrouter, kilo, opencode zen)
> * Reliability through model routing
> * Agent security through guardrails for autonomous agents
> * Routing strategies (e.g. use openrouter free until the quota is exhausted and then use ollama xyz)

Hermes agent is used to set up Lionheart:
> * System caretaker for the AI stack and the Ubuntu system
> * daily check system health (logs, errors, memory etc.)
> * If action is required, the file ~/reco.sh is created
> * No actions are taken, only the recommendation file is generated: ~/reco.sh

There are several options available to communicate with Lionheart including CLI, Open WebUI, Telegram<br>
The exact description can be found in [Lionheart Skill](../skills/lionheart/SKILL.md).

🚨 Important security notice (March 2026):
* LiteLLM was recently the target of a serious supply chain attack on PyPI (versions 1.82.7 and 1.82.8 contained a credential stealer that targeted .env files, SSH keys and cloud credentials).
* Hardening recommendation: The official Docker image (ghcr.io/berriai/litellm) was not affected by the compromised PyPI packages and provides secure isolation. When installing via pip, a secure, current version must be pinned (>= 1.83.0).
* To be on the safe side, we use digest pinning at this point.


#### LiteLLM

```shell
# 1. Create configuration directory
mkdir -p ~/.litellm && cd ~/.litellm

# 2. Create basic config (config.yaml)
# This is just an example configuration (syntax blueprint). Models can be customized as desired.
cat << 'EOF' > config.yaml
model_list:
  # -----------------------------------------------------------------🔒 Fail-safety Models
  # 🟢 TIER 1: Daily Tasks
  - model_name: daily-agent
    litellm_params:
      model: openrouter/free
      api_key: os.environ/OPENROUTER_API_KEY

  # 🟡 TIER 2: Weekly Checks
  - model_name: weekly-agent
    litellm_params:
      model: openrouter/deepseek/deepseek-v4-pro
      api_key: os.environ/OPENROUTER_API_KEY

  # -----------------------------------------------------------------📍 Stand alone models
  # -----------------------------------------------------------------   ki: kilo / or: openrouter / la: localai / ol: ollama
  - model_name: or-openrouter-free
    litellm_params:
      model: openrouter/free
      api_key: os.environ/OPENROUTER_API_KEY

  - model_name: or-deepseek-v4-pro
    litellm_params:
      model: openrouter/deepseek/deepseek-v4-pro
      api_key: os.environ/OPENROUTER_API_KEY

  - model_name: or-minimax-m2.7
    litellm_params:
      model: openrouter/minimax/minimax-m2.7
      api_key: os.environ/OPENROUTER_API_KEY


  - model_name: ki-kilo-free
    litellm_params:
      model: openai/kilo-auto/free
      api_base: https://api.kilo.ai/api/gateway
      api_key: os.environ/KILOCODE_API_KEY
      timeout: 30

  - model_name: ki-deepseek-v4-pro
    litellm_params:
      model: openai/deepseek/deepseek-v4-pro
      api_base: https://api.kilo.ai/api/gateway
      api_key: os.environ/KILOCODE_API_KEY


  - model_name: ol-qwen3.5-2b
    litellm_params:
      model: ollama/qwen3.5:2b
      api_base: http://host.docker.internal:11434

  - model_name: la-qwen3.6-35b
    litellm_params:
      model: openai/qwen3.6-35b-a3b-claude-4.6-opus-reasoning-distilled
      api_base: http://host.docker.internal:8080/v1
      api_key: sk-no-key-required
  

router_settings:
  fallbacks:
    - {"daily-agent": ["ki-kilo-free", "ol-qwen3.5-2b"]}
    - {"weekly-agent": ["or-minimax-m2.7", "la-qwen3.6-35b"]}
EOF

# 3. Create master key / reload shell
echo "sk-lionheart-master-key" > ~/.shlib/exports/LITELLM_MASTER_KEY
chmod 600 ~/.shlib/exports/LITELLM_MASTER_KEY && rlb

# 4. own db in postgres from firecrawl (container recycling)
docker exec -it firecrawl-nuq-postgres-1 psql -U postgres -c "CREATE DATABASE litellm;"

# optional: remove old container if present
docker rm -f litellm 2>/dev/null || true

# 5. special tag (skills endpoint) / pull image / resolve immutable digest
litellmtag="v1.85.0-rc.2" && docker pull ghcr.io/berriai/litellm:$litellmtag && \
litellm_digest=$(docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/berriai/litellm:$litellmtag)

# 6. start container using digest
docker run -d --name litellm --restart always --network firecrawl_backend -p 127.0.0.1:4040:4000 \
  --add-host=host.docker.internal:host-gateway --security-opt=no-new-privileges:true --cap-drop=ALL \
  -e OPENROUTER_API_KEY -e KILOCODE_API_KEY -e LITELLM_MASTER_KEY \
  -e DATABASE_URL="postgresql://postgres:postgres@firecrawl-nuq-postgres-1:5432/litellm" \
  -v "$HOME/.litellm/config.yaml:/app/config.yaml:ro" "$litellm_digest" --config /app/config.yaml

# 7. only run once per container lifecycle 
#    necessary because we integrated the container directly into the firecrawl network (postgres)
docker network connect bridge litellm && docker restart litellm

# maintain
docker logs -f litellm
curl http://127.0.0.1:4040/health  
```


#### Hermes Agent

* Install with the official install script
```shell
# Run the config wizard
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

* Enable Hermes Web API (we need it for Open WebUI)
```shell
# nano ~/.hermes/.env
API_SERVER_ENABLED=true
API_SERVER_HOST=127.0.0.1
API_SERVER_PORT=8642
API_SERVER_MODEL_NAME=Lionheart
API_SERVER_KEY=key_for_use_in_open_webui
```

* Add Hermes in Open WebUI<br>
1. Add a new OpenAI connection in Open Webui under Admin Panel / Settings / Connections
2. Enter `http://localhost:8642/v1` as the URL and next to bearer the `key_for_use_in_open_webui`.
3. Use the Lionheart model endpoint


#### Lionheart of Deen Lupysta - The Linux Operator Nerd Skill for the heartbeat(-agent) of Deen Lupysta

* Let the lionheart pound.
```shell
# link the skill
ls -s ~/gits/deen-lupysta/skills/lionheart ~/.hermes/skills/autonomous-ai-agents/lionheart

# Start hermes and prompt: Use your lionheart skill and set up your daily and weekly heartbeat.
```

* Skill structure
```shell
skills
├── lionheart                  # the skill folder
│   ├── references             # references as md's
│   │   ├── daily-checks.md    # Instructions for the short daily check with report templates
│   │   ├── reco-format.md     # Template for executable recommendations for action with detailed comments
│   │   └── weekly-checks.md   # instructions for the detailed weekly check with report templates
│   └── SKILL.md               # the actual skill
└── ...
```

#### Guardrails

* The basic idea: when I work with agents in open webui or in vscode or on the console, I take over the task of guardrails and prevent harmful actions through human-in-the-loop. No guardrails mechanic is necessary here, or if so, just a 'basic' version. But mostly I use the provider directly.
* However, if I use autonomous heartbeat agents, guardrails become an important tool.
* I'm still in the middle of the evaluation and research phase here

*(🚧 WIP)*

