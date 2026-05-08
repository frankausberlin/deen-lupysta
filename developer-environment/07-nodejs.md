### Node.js (fnm + pnpm)

We use **fnm** (Fast Node Manager) instead of nvm (written in Rust, no shell slowdown). As package manager we use **pnpm** (symlink system saves disk space).

```shell
# 1. Install fnm (without shell modifications)
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

# 2. write shlib
cat << 'EOF' > ~/.shlib/shlibs/35-nodejs-config.sh

# --- Node / fnm ---
export FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# --- pnpm ---
export PNPM_HOME="$HOME/.local/share/pnpm"

# PNPM_HOME
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# PNPM_HOME/bin (pnpm v10+)
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
EOF

# 3. reload
exec zsh

# 4. Install Node LTS and set as default
fnm install --lts && fnm use lts-latest && fnm default lts-latest

# 5. Enable Corepack (enables all shims including pnpm)
corepack enable

# 6. Install global tools
pnpm add -g @kilocode/cli
pnpm add -g pm2

# 7. Set up PM2 as a systemd service
pm2 startup systemd
```
