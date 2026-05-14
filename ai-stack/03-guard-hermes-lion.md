
### Guardrails & Heartbeat-Agents

#### Guardrails

* use of guardrails with open router *(🚧 WIP)*
* (not yet decided) use a guardrails proxy (openlite, litellm or others)
* The basic idea: when I work with agents in open webui or in vscode or on the console, I take over the task of guardrails and prevent harmful actions through human-in-the-loop. No guardrails mechanic is necessary here, or if so, just a 'basic' version.
* However, if I use autonomous heartbeat agents, guardrails become an important tool.
* I'm still in the middle of the evaluation phase here

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
API_SERVER_MODEL_NAME=Hermes Agent
API_SERVER_KEY=key_for_use_in_open_webui
```

* Add Hermes in Open WebUI<br>
1. Add a new OpenAI connection in Open Webui under Admin Panel / Settings / Connections
2. Enter `http://localhost:8642/v1` as the URL and next to bearer the `key_for_use_in_open_webui`.


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

