
## Hermes & Lionheart

### Hermes Agent

* Install with the official install script
```shell
# Run the config wizard
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

#### Enable Hermes Web API (we need it for Open WebUI)

```shell
# nano ~/.hermes/.env
API_SERVER_ENABLED=true
API_SERVER_HOST=127.0.0.1
API_SERVER_PORT=8642
API_SERVER_MODEL_NAME=Lionheart
API_SERVER_KEY=key_for_use_in_open_webui
```

#### Add Hermes in Open WebUI

1. Add a new OpenAI connection in Open Webui under Admin Panel / Settings / Connections
2. Enter `http://localhost:8642/v1` as the URL and next to bearer the `key_for_use_in_open_webui`.
3. Use the Lionheart model endpoint

#### Alternative: Routing through LiteLLM (Recommended for Local/Gateway Model Management)

> 🚨 **Prerequisite:** This setup requires LiteLLM to be configured and running first. The custom endpoints and routing rules will only be available once LiteLLM is fully set up as described in [LiteLLM & Vibe-Kanban](04-litellm-vibekanban.md).

To route Hermes directly through your local LiteLLM gateway, you must configure **both** the environment variables (`.env`) and the structured configuration (`config.yaml`). This dual configuration ensures model-routing consistency across both the core agent and all subprocesses/plugins it invokes:

1. **Configure Environment Variables (`~/.hermes/.env`):**
    > Add or update the following parameters at the bottom of the file. This ensures that any background scripts, third-party libraries (e.g., standard OpenAI SDKs), or custom plugins used by Hermes inherit the correct API base and key:
```shell
OPENAI_API_BASE=http://127.0.0.1:4040/v1
OPENAI_API_KEY=your_litellm_virtual_key_here  # e.g., sk-... (generated via LiteLLM key/generate)
DEFAULT_MODEL=lionheart-maintain
OPENAI_BASE_URL=http://127.0.0.1:4040/v1
OPEN_AI_BASE_URL=http://127.0.0.1:4040/v1
```

2. **Configure Structured Config (`~/.hermes/config.yaml`):**

    Update the core model and delegation blocks at the beginning and middle of the file. This defines the default model and API endpoint that the main conversation loops of Hermes use:
```shell
model:
  default: lionheart-maintain
  provider: openai-api
  base_url: http://127.0.0.1:4040/v1
  api_mode: chat_completions
  
delegation:
  model: lionheart-maintain
  provider: openai-api
  base_url: http://127.0.0.1:4040/v1
  api_key: '' # Automatically falls back to the OPENAI_API_KEY from environment
  api_mode: chat_completions
```

3. **Why do both files need this configuration?**
    * **`config.yaml`** controls the **core decision making** of the main Hermes agent process.
    * **`.env`** guarantees that any **background environments, shell tools, or external CLI commands** spawned by 
    
    Hermes inherit the same local API base and key. This prevents them from either bypassing the gateway or throwing authentication errors when attempting to connect to external endpoints.


### Lionheart

Lionheart of Deen Lupysta - The Linux Operator Nerd Skill for the heartbeat agent of Deen Lupysta

* Let the lionheart pound.
```shell
# link the skill
ln -s ~/gits/deen-lupysta/skills/lionheart ~/.hermes/skills/autonomous-ai-agents/lionheart

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

* The exact description can be found in [Lionheart Skill](../skills/lionheart/SKILL.md).


