
### LiteLLM & Hermes

*(🚧 WIP)*

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


#### LiteLLM


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

