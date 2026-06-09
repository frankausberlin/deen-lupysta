## Github, VSCode, SearXNG

* manipulated files: .gitignore_global
* created folders: ~/.searxng/, ~/.searxng/config/, ~/.searxng/data/
* created files: settings.yml

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
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
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
```

