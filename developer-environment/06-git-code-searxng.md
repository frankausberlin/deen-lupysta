## Github, VSCode, SearXNG

### Agent Instructions

* Load the Concierge skill (`skills/concierge/SKILL.md`) and follow its rules.
* In this stage you accompany the user in installing:
  * Git global config + GitHub CLI auth (SSH, using the key from the ssh-chapter)
  * VSCode (apt repo) + Nautilus context-menu integration
  * SearXNG (Docker, bound to localhost, JSON format enabled for the MCP server)
* Stage-specific notes:
  * Git config values (`user.name`, `user.email`, `.gitignore_global`) are personal — the user must fill in their own data, do not invent placeholders.
  * `gh auth login`: choose SSH and upload the `id_ed25519.pub` from stage 1.3.
  * SearXNG requires Docker (stage 1.4). The secret key is generated via `openssl rand`; the container is intentionally bound to `127.0.0.1:8080` — do not expose it.


### Github:
```shell
# Create global .gitignore (enter your agent folders, .env, venv etc. here)
# nano ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
# Git config
git config --global user.name "Your Name"
git config --global user.email "noreply-email" # -> https://github.com/settings/emails
git config --global init.defaultBranch main
git config --global pull.rebase true
# GitHub Login (Choose "SSH" and upload your id_ed25519.pub key!)
gh auth login
# Sets the credential helper for HTTPS remotes
gh auth setup-git
```

### VSCode
```shell
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm -f packages.microsoft.gpg
echo "deb https://packages.microsoft.com/repos/code stable main" | \
sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo nala update && sudo nala install -y code

# Add to context menu (nautilus)
bash -c "$(wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh)"
```


### SearXNG
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

# Comfort link
ln -s ~/.searxng/config/settings.yml ~/.shlib/settings_searxng.yml
```

