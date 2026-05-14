### Ollama and Coding Agents

#### Ollama (and LLMFit)

```shell
# Install latest (official script auto-creates user and systemd service)
curl -fsSL https://ollama.com/install.sh | sh

# Optional: add current user to ollama group
sudo usermod -a -G ollama $(whoami) # re-login or 'newgrp ollama' needed

# Ensure the service is running and enabled on boot
sudo systemctl enable --now ollama

# Selection models
ollama pull qwen3-embedding:0.6b # used in vscode kilocode codebase indexing and mcphub smart routing
ollama pull qwen3.5
ollama pull translategemma
```

* LLMFit
```shell
brew install llmfit
```

#### Coding Agents

* Kilo Code CLI
```shell
# kilocode has already been installed in the Node.js setup.
# See: developer-environment/07-nodejs.md
# pnpm add -g @kilocode/cli
```

* Open Code
```shell
# Install latest (official script)
curl -fsSL https://opencode.ai/install | bash

# remove path insert from .zshrc and shlib it
cp ~/.zshrc.lock ~/.zshrc && echo "export PATH=/home/frank/.opencode/bin:$PATH" > ~/.shlib/shlibs/70-opencode.sh
```

* Claude
```shell
# Install latest (official script)
curl -fsSL https://claude.ai/install.sh | bash
```

* Hermes Agent
```shell
# instructions in chapter Guardrails & Heartbeat-Agents
```
