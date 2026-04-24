# AI Stack — VSCode, Kilo, Ollama, MCPHub

Tools for AI-powered development and local LLM inference.

## VSCode

```shell
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm -f packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo nala update && sudo nala install -y code

# Add to context menu (nautilus)
bash -c "$(wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh)"
```

## Kilo Code Extension

```shell
# Install the extension via VSCode and get a key (kilo, openrouter, openai etc).

# As of April 2026, kilo v5.x.y is recommended (the last stable major version).
# v7.x.y is in pre-alpha — check from time to time if it's production-ready.
# The kilocode cli is installed in Ecosystems / Node.js:
# pnpm add -g @kilocode/cli
```

## Ollama + LLMFit

### Ollama

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

### LLMFit

```shell
brew install llmfit
```

## MCPHub — Base Installation (fully functional)

> ⚠️ **Pitfalls with node over `fnm`**
> `fnm` activates node per shell via an *ephemeral* directory: `/run/user/<uid>/fnm_multishells/<PID>_<timestamp>/bin`.
> This path disappears as soon as the shell ends — absolutely **unsuitable** for a systemd service.
> The script below detects and uses `fnm` the **persistent** symlink instead
> `~/.local/share/fnm/aliases/default/bin`, which always points to the current default node version.

```shell
# 1) install mcphub global via pnpm
pnpm add -g @samanhappy/mcphub

# 2) secrets you need
cat > ~/.mcphub.env <<EOF
GITHUB_TOKEN=$GITHUB_TOKEN
STACKOVERFLOW_API_KEY=$STACKOVERFLOW_API_KEY
HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN
EOF
chmod 600 ~/.mcphub.env

# 3. Robust paths: prefer fnm-default, otherwise fallback to system node (prevents /run/user/...)
NODE_BIN=$(readlink -f "$HOME/.local/share/fnm/aliases/default/bin" 2>/dev/null)
[ -z "$NODE_BIN" ] && NODE_BIN=$(command -v node | grep -v "fnm_multishells" | xargs dirname 2>/dev/null)
[[ -z "$NODE_BIN" || ! -x "$NODE_BIN/node" ]] && { echo "❌ No node path found"; return 1 2>/dev/null || exit 1; }
PNPM_BIN="$(pnpm bin -g 2>/dev/null || echo "$HOME/.local/share/pnpm")"
UVX_BIN="$(dirname "$(command -v uvx 2>/dev/null || echo /home/$USER/.local/bin/uvx)")"
MCPHUB_EXEC="$PNPM_BIN/mcphub"
[ ! -x "$MCPHUB_EXEC" ] && { echo "❌ mcphub not found"; return 1 2>/dev/null || exit 1; }
SERVICE_PATH="$NODE_BIN:$PNPM_BIN:$UVX_BIN:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# 4) write service unit
sudo tee /etc/systemd/system/mcphub.service > /dev/null <<EOF
[Unit]
Description=MCPHub Server
After=network.target

[Service]
Type=simple
User=$USER
Environment="PATH=$SERVICE_PATH"
EnvironmentFile=$HOME/.mcphub.env
ExecStart=$MCPHUB_EXEC
Restart=always
RestartSec=5
WorkingDirectory=$HOME

[Install]
WantedBy=multi-user.target
EOF

# 5) enable & start
sudo systemctl daemon-reload && sudo systemctl enable --now mcphub.service
```

## SearXNG

```shell
# Create directories
mkdir -p ~/.searxng/config/ ~/.searxng/data/

# Load standard config BEFORE the container starts
wget -O ~/.searxng/config/settings.yml https://raw.githubusercontent.com/searxng/searxng/master/utils/templates/etc/searxng/settings.yml

# Generate and enter a secure secret key (replaces "ultrasecretkey")
sed -i "s/ultrasecretkey/$(openssl rand -hex 32)/g" ~/.searxng/config/settings.yml

# Unlock JSON format for the MCP server
"$(command -v yq)" -i '.search.formats = (.search.formats + ["json"] | unique)' "$HOME/.searxng/config/settings.yml"

# Start container (Securely bound to localhost!)
docker run --name searxng -d --restart always -p 127.0.0.1:8080:8080 \
    -v "$HOME/.searxng/config/:/etc/searxng/" \
    -v "$HOME/.searxng/data/:/var/cache/searxng/" \
    docker.io/searxng/searxng:latest
```

## MCP Server Collection

Import into mcphub → server → import:

```json
{
    "mcpServers": {
        "searxng":            {"command": "npx", "args": ["-y", "mcp-searxng"], "env": {"SEARXNG_URL": "http://localhost:8080"}, "disabled": true},
        "web-search-mcp":     {"command": "npx", "args": ["-y", "@guhcostan/web-search-mcp"], "disabled": true},
        "context7":           {"command": "npx", "args": ["-y", "@upstash/context7-mcp" ], "env": {"DEFAULT_MINIMUM_TOKENS": ""}, "disabled": true},
        "mcp-deepwiki":       {"command": "npx", "args": ["-y", "mcp-deepwiki"], "disabled": true},
        "stackexchange":      {"command": "npx", "args": ["-y", "@notalk-tech/stackoverflow-mcp"], "env": {"STACKOVERFLOW_API_KEY": "${STACKOVERFLOW_API_KEY}"}, "disabled": true},
        "sequentialthinking": {"command": "npx", "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"], "disabled": true},
        "filesystem":         {"command": "npx", "args": ["-y", "@modelcontextprotocol/server-filesystem", "/"], "disabled": true},
        "desktop-commander":  {"command": "npx", "args": ["-y","@wonderwhy-er/desktop-commander"], "disabled": true},
        "mcp-server-docker":  {"command": "uvx", "args": ["mcp-server-docker"], "env": {"DOCKER_HOST": "unix:///var/run/docker.sock"}, "disabled": true},
        "github":             {"command": "docker", "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "-e", "GITHUB_TOOLSETS", "-e", "GITHUB_READ_ONLY", "ghcr.io/github/github-mcp-server"],
                               "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}", "GITHUB_READ_ONLY": "", "GITHUB_TOOLSETS": ""}, "disabled": true},
        "cloudflare":         {"command": "npx", "args": ["mcp-remote", "https://docs.mcp.cloudflare.com/mcp"], "disabled": true},
        "fastplaywright":     {"command": "npx", "args": ["@tontoko/fast-playwright-mcp"], "disabled": true},
        "browsermcp":         {"command": "npx", "args": ["@browsermcp/mcp"], "disabled": true},
        "huggingface":        {"type": "streamable-http", "url": "https://huggingface.co/mcp", "headers": {"Content-Type": "application/json", "Authorization": "Bearer ${HUGGINGFACE_TOKEN}" }, "disabled": true},
        "jupyter":            {"command": "uvx", "args": ["jupyter-mcp-server"], "env": {"ALLOW_IMG_OUTPUT": "true", "JUPYTER_TOKEN": "${JUPYTER_TOKEN}", "JUPYTER_URL": "http://localhost:8888"}, "disabled": true},
        "colab-mcp":          { "command": "uvx", "args": ["git+https://github.com/googlecolab/colab-mcp"], "timeout": 30000, "disabled": true}
    }
}
```

### Secrets Handling via shlib

MCPHub expands `${VAR}` references using its own environment. Put each secret into a single-line file under `~/.shlib/exports/`:

```shell
echo 'ghp_xxxxxxxxxxxxxxxxxxxx' > ~/.shlib/exports/GITHUB_TOKEN
echo 'rl_xxxxxxxxxxxxxxxxxxxx' > ~/.shlib/exports/STACKOVERFLOW_API_KEY
echo 'hf_xxxxxxxxxxxxxxxxxxxx' > ~/.shlib/exports/HUGGINGFACE_TOKEN
chmod 600 ~/.shlib/exports/*
```

### Kilo Code — Minimal MCP Server Config (without MCPHub)

For troubleshooting or without MCPHub:

```json
{
    "mcpServers": {
        "desktop-commander":  {"disabled": true, "alwaysAllow": [], "command": "npx", "args": ["-y", "@wonderwhy-er/desktop-commander"]},
        "web-search-mcp":     {"disabled": true, "alwaysAllow": [], "command": "npx", "args": ["-y", "@guhcostan/web-search-mcp"]},
        "fastplaywright":     {"disabled": true, "alwaysAllow": [], "command": "npx", "args": ["@tontoko/fast-playwright-mcp"]},
        "mcp-server-docker":  {"disabled": true, "alwaysAllow": [], "command": "uvx", "args": ["mcp-server-docker"],
                               "env": {"DOCKER_HOST": "unix:///var/run/docker.sock"}}
    }
}
```

## When importing many MCP servers

When importing many servers at once into MCPHub, it's normal for some to appear offline initially. All servers are installed in parallel after import. Simply wait until all servers are connected or offline, then retry the faulty ones.
