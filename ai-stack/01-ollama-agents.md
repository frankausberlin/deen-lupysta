## Ollama and Coding Agents

### Agent Instructions

* Load the Concierge skill (`skills/concierge/SKILL.md`) and follow its rules.
* In this stage you accompany the user in installing:
  * Ollama and LLMFit
  * Odysseus (AI chat harness)
  * Coding Agents (Kilo Code CLI, Open Code, Claude)
* Stage-specific notes:
  * **Ollama User Group:** Adding the user to the `ollama` group requires a re-login or executing `newgrp ollama` in the current shell to take effect. Guide the user accordingly.
  * **Odysseus Hardware Check:** Ask the user explicitly if the host machine has an NVIDIA GPU. If yes, instruct them to rename/copy `docker-compose.gpu-nvidia.yml`. If no, instruct them to use `docker-compose.cpu-backup.yml`.
  * **SearXNG Variant Decision:** Explain the two SearXNG variants to the user:
    1. *Default:* Odysseus spins up its own SearXNG on port 8080 (easiest, works out of the box, but runs a second instance).
    2. *Single SearXNG:* Modify `docker-compose.yml` to point to the existing Deen Lupysta SearXNG on port 8090.
    If the user chooses variant 2, carefully guide them through the 3 modification steps in the docker-compose file before running `docker compose up -d`.
  * **Open Code Shlib Hygiene:** When setting up Open Code in `70-opencode.sh`, ensure the PATH extension only adds `~/.opencode/bin` and does not accidentally freeze a static snapshot of the current shell PATH. Recommend using the `exportadd ~/.opencode/bin` function if `deenlupysta.sh` is sourced.

### Ollama (and LLMFit)

```shell
# Install latest (official script auto-creates user and systemd service)
curl -fsSL https://ollama.com/install.sh | sh

# Optional: add current user to ollama group
sudo usermod -aG ollama $(whoami) # re-login or 'newgrp ollama' needed

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

### Odysseus

Odysseus is the AI chat harness from Pewdiepie. It brings its own SearXNG, ChromaDB, and ntfy containers via docker compose.

```shell
git clone https://github.com/pewdiepie-archdaemon/odysseus.git
cd odysseus
cp .env.example .env       # optional, but recommended for explicit defaults

# Use the GPU variant (NVIDIA) instead of the CPU default:
mv docker-compose.yml docker-compose.cpu-backup.yml
cp docker-compose.gpu-nvidia.yml docker-compose.yml

docker compose up -d
```

This starts Odysseus with its own SearXNG on port 8080. Two SearXNG instances will be running:
- Deen Lupysta SearXNG on port 8090
- Odysseus SearXNG on port 8080

This is the simplest setup — no compose modifications needed, everything works out of the box.

#### Variant: Single SearXNG (use the Deen Lupysta instance)

If you prefer to run only one SearXNG instance (the Deen Lupysta one on port 8090), you need to modify the docker-compose.yml. This requires a bit more configuration but avoids a second SearXNG container.

Three changes are needed:

**1. Point Odysseus to the Deen Lupysta SearXNG (port 8090):**

In `docker-compose.yml`, under `services: odysseus: environment`, change:
```yaml
# Before (two instances):
- SEARXNG_INSTANCE=http://searxng:8080

# After (single instance, via host):
- SEARXNG_INSTANCE=http://host.docker.internal:8090
```

**2. Remove the SearXNG service from docker-compose.yml:**

Delete the entire `searxng:` service block (including ports, volumes, healthcheck, environment, cap_drop, cap_add).

**3. Remove the SearXNG dependency:**

Under `services: odysseus: depends_on`, remove the `searxng` entry:
```yaml
# Before:
depends_on:
  searxng:
    condition: service_healthy
  chromadb:
    condition: service_started

# After:
depends_on:
  chromadb:
    condition: service_started
```

Also remove the `searxng-data` volume from the `volumes:` section at the bottom.

Then start with `docker compose up -d`. Odysseus will now use the Deen Lupysta SearXNG on port 8090.

> Document this deviation in `~/.deenlupysta/MYDEENLUPYSTA.md` under Stage 4.

### Coding Agents

* Kilo Code CLI
```shell
# kilocode has already been installed in the Node.js setup.
# See: base-system/07-nodejs.md
# pnpm add -g @kilocode/cli
```

* Open Code
```shell
# Install latest (official script) - was already done during onboarding.
# curl -fsSL https://opencode.ai/install | bash

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
