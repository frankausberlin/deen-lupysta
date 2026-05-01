### Node.js (fnm + pnpm)

We use **fnm** (Fast Node Manager) instead of nvm (written in Rust, no shell slowdown). As package manager we use **pnpm** (symlink system saves disk space).

```shell
# Install fnm (without shell modifications)
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

# Integrate into shlib (30-nodejs-config.sh):
cat << 'EOF' >> ~/.shlib/shlibs/30-nodejs-config.sh

# --- Node / fnm ---
export FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# --- pnpm ---
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
EOF

# Reload ZSH so that fnm is available
exec zsh

# Install Node LTS and set as default
fnm install --lts && fnm use lts-latest && fnm default lts-latest

# Enable Corepack (enables all shims including pnpm)
corepack enable

# Install global tools
pnpm add -g @kilocode/cli
pnpm approve-builds -g
pnpm add -g pm2

# Set up PM2 as a systemd service
pm2 startup systemd
```
