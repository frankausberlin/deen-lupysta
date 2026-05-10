
### Guardrails & Heartbeat-Agents

#### Guardrails

* use of guardrails with open router *(🚧 WIP)*


* Create an environment for the guardrails service
```shell
# Create project directory
mkdir -p ~/.guardrails-proxy && cd ~/.guardrails-proxy

# Initialize uv project with a valid package name
uv init --name guardrails_proxy
uv add guardrails-ai

# Install a first guards from the hub (local execution)
uv run guardrails hub install hub://guardrails/secrets_present
```

* base_code_guard: a little python script to access the validator(s)
```shell
cat << 'EOF' | tee ~/.guardrails-proxy/config.py > /dev/null
from guardrails import Guard
from guardrails.hub import SecretsPresent

# This guard will scan the LLM output and block it if it contains exposed secrets
guard = Guard(
    name="base_code_guard",
    description="Filter to prevent secret/API key leaks in code generation."
).use(
    SecretsPresent()
)
EOF
```

* Service and Environment
```shell
# pass on key
echo "OPENROUTER_API_KEY=$OPENROUTER_API_KEY" > ~/.guardrails-proxy/.env
chmod 600 ~/.guardrails-proxy/.env

# Preflight: Ensure uv is available
command -v uv || { echo "❌ missing uv — finish the Python setup first"; return 1 2>/dev/null || exit 1; }
UV_EXEC="$(command -v uv)"

# Write service unit
sudo tee /etc/systemd/system/guardrails.service > /dev/null <<EOF
[Unit]
Description=Guardrails AI Proxy Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/.guardrails-proxy
Environment="PATH=$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
EnvironmentFile="$HOME/.guardrails-proxy/.env"
ExecStart=$UV_EXEC run guardrails-api start --config config.py --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable & start
sudo systemctl daemon-reload && sudo systemctl enable --now guardrails.service
```

#### Lionheart - The Linux Operator Nerd Skill for heartbeating Agents ()

*(🚧 WIP)*

* set up hermes agent as heartbeat agent: codename Lionheart
* System caretaker for the AI stack and the Ubuntu system
* daily check system health (logs, errors, memory etc.)
* Daily short report via telegram with information about the need for action
* If action is required, the file ~/reco.sh is created
* It contains the recommendation for action (as a comment) and the corresponding command(s).
* the commands are described in detail (except the trivial stuff that everyone knows anyway).
* If there is no need for action and there is still a ~/reco.sh (previous day), it will be deleted (brief note in the telegram report)
* No actions are taken, only the recommendation file is generated: ~/reco.sh

