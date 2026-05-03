### MCPHub and LiteLLM

#### MCPHub — Base Installation (fully functional)

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

#### MCPHub - MCP-Server Collection

> ⚠️ Note: The filesystem mcp server is configured to access '/', which has advantages and disadvantages.<br>Change this if necessary. <br>
> ⚠️ If you **don't want to install searxng**, delete the line and **use web-search-mcp**.<br>
> ⚠️ To use searxng in a MCP server, the entry '-json' must be added under search->formats in config/settings.yml.

```shell
# This was already covered in the developer environment setup (Git, Code & SearXNG) and is only included here for the sake of completeness.
# insert '- json' in ~/.searxng/config/settings.yml with yq
"$(command -v yq)" -i '.search.formats = (.search.formats + ["json"] | unique)' "$HOME/.searxng/config/settings.yml"
```
* **Import into mcphub → server → import:**
> ⚠️ When importing many servers at once into MCPHub, it's normal for some to appear offline initially. All servers are installed in parallel after import. Simply wait until all servers are connected or offline, then retry the faulty ones.

```shell
# Make sure that docker, uvx and npx are installed.
# copy this json and paste it in mcphub->server->import
#
# 🔐 Secrets handling via the shlib exports system (recommended):
#   MCPHub expands ${VAR} references in the JSON using its own environment.
#   Put each secret into a single-line file under ~/.shlib/exports/, e.g.:
#       echo 'ghp_xxxxxxxxxxxxxxxxxxxx' > ~/.shlib/exports/GITHUB_TOKEN
#       echo 'rl_xxxxxxxxxxxxxxxxxxxx' > ~/.shlib/exports/STACKOVERFLOW_API_KEY
#       echo 'hf_xxxxxxxxxxxxxxxxxxxx' > ~/.shlib/exports/HUGGINGFACE_TOKEN
#       chmod 600 ~/.shlib/exports/*
#   The shlib loader exports these as env vars on shell init
#
# When importing so many servers at once, it's quite possible that one or more will appear offline.
# Since all servers are installed in parallel after the import, some may be marked as offline.
# Simply wait until all servers are connected or offline, and then try again with the faulty ones.
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

#### MCPHub - Client Integration

```shell
# for kilocode -> extension settings -> agent behaviour -> mcp servers -> edit global mcp
{
    "mcpServers": {
        "context7": {"type": "streamable-http", "url": "http://localhost:3000/mcp/context7"},
        "desktop-commander": {"type": "streamable-http", "url": "http://localhost:3000/mcp/desktop-commander"},
        "github": {"type": "streamable-http", "url": "http://localhost:3000/mcp/github"},
        "searxng": {"type": "streamable-http", "url": "http://localhost:3000/mcp/searxng"},
        "web-search-mcp": {"type": "streamable-http", "url": "http://localhost:3000/mcp/web-search-mcp"},
        "sequentialthinking": {"type": "streamable-http", "url": "http://localhost:3000/mcp/sequentialthinking"},
        "mcp-deepwiki": {"type": "streamable-http", "url": "http://localhost:3000/mcp/mcp-deepwiki"},
        "stackexchange": {"type": "streamable-http", "url": "http://localhost:3000/mcp/stackexchange"},
        "fastplaywright": {"type": "streamable-http", "url": "http://localhost:3000/mcp/fastplaywright"},
        "browsermcp": {"type": "streamable-http", "url": "http://localhost:3000/mcp/browsermcp"},
        "cloudflare": {"type": "streamable-http", "url": "http://localhost:3000/mcp/cloudflare"},
        "jupyter": {"type": "streamable-http", "url": "http://localhost:3000/mcp/jupyter"},
        "filesystem": {"type": "streamable-http", "url": "http://localhost:3000/mcp/filesystem"},
        "mcp-server-docker": {"type": "streamable-http", "url": "http://localhost:3000/mcp/mcp-server-docker"},
        "huggingface": {"type": "streamable-http", "url": "http://localhost:3000/mcp/huggingface"},
        "colab-mcp": {"type": "streamable-http", "url": "http://localhost:3000/mcp/colab-mcp"}
    }
}

# for claude
claude mcp add --transport http context7 http://localhost:3000/mcp/context7
claude mcp add --transport http desktop-commander http://localhost:3000/mcp/desktop-commander
claude mcp add --transport http github http://localhost:3000/mcp/github
claude mcp add --transport http searxng http://localhost:3000/mcp/searxng
claude mcp add --transport http web-search-mcp http://localhost:3000/mcp/web-search-mcp
claude mcp add --transport http sequentialthinking http://localhost:3000/mcp/sequentialthinking
claude mcp add --transport http mcp-deepwiki http://localhost:3000/mcp/mcp-deepwiki
claude mcp add --transport http stackexchange http://localhost:3000/mcp/stackexchange
claude mcp add --transport http fastplaywright http://localhost:3000/mcp/fastplaywright
claude mcp add --transport http browsermcp http://localhost:3000/mcp/browsermcp
claude mcp add --transport http cloudflare http://localhost:3000/mcp/cloudflare
claude mcp add --transport http jupyter http://localhost:3000/mcp/jupyter
claude mcp add --transport http filesystem http://localhost:3000/mcp/filesystem
claude mcp add --transport http mcp-server-docker http://localhost:3000/mcp/mcp-server-docker
claude mcp add --transport http huggingface http://localhost:3000/mcp/huggingface
claude mcp add --transport http colab-mcp http://localhost:3000/mcp/colab-mcp
```

#### Open WebUI

```shell
# 1) install open-webui
pnpm add -g open-webui

# 2) write service unit
sudo tee /etc/systemd/system/open-webui.service > /dev/null <<EOF
[Unit]
Description=Open-WebUI Server
After=network.target

[Service]
Type=simple
User=$USER
Environment="PATH=$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
Environment="DATA_DIR=$HOME/.open-webui"
ExecStart=$HOME/.local/bin/uvx --python 3.11 open-webui@latest serve --port 8081
Restart=always
RestartSec=5
WorkingDirectory=$HOME

[Install]
WantedBy=multi-user.target
EOF

# 3) enable & start
sudo systemctl daemon-reload && sudo systemctl enable --now open-webui.service
```

* I recommend adding a few mcp servers for internet research.
> add searxng, context7, mcp-deepwiki and stackexchange<br>
> --> mcphub admin settings --> settings --> integrations --> add tool-server connection (open api)

