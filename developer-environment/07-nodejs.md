### Node.js (fnm + pnpm)

We use **fnm** (Fast Node Manager) instead of nvm (written in Rust, no shell slowdown). As package manager we use **pnpm** through Corepack (symlink system saves disk space).

> ⚠️ **Do not save full PATH snapshots in shlib files.**
> `fnm env` creates a fresh per-shell path like `/run/user/<uid>/fnm_multishells/<PID>_<timestamp>/bin`.
> If a later shlib file exports an old copied `PATH`, that stale path can hide `node`, `npm`, `corepack`, `npx`, and `pnpm` even though Node is installed correctly.
> Later shlib files must only add single directories with guarded `PATH` additions.

#### 1. Install fnm and integrate it into shlib

```shell
# 1. Install fnm (without installer-owned shell modifications)
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

# 2. Write shlib (35-nodejs-config.sh)
cat << 'EOF' > ~/.shlib/shlibs/35-nodejs-config.sh
# --- Node / fnm ---
export FNM_PATH="$HOME/.local/share/fnm"
export FNM_DEFAULT_BIN="$FNM_PATH/aliases/default/bin"

# fnm binary
case ":$PATH:" in
  *":$FNM_PATH:"*) ;;
  *) export PATH="$FNM_PATH:$PATH" ;;
esac

# fnm-managed Node activation for interactive shells.
# --corepack-enabled makes future fnm installs create Corepack shims automatically.
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh --corepack-enabled)"
fi

# Persistent default Node bin as a stable fallback for tools and non-current shells.
# Keep it AFTER fnm's active multishell path so project-specific Node switching still wins.
if [ -d "$FNM_DEFAULT_BIN" ]; then
  case ":$PATH:" in
    *":$FNM_DEFAULT_BIN:"*) ;;
    *) export PATH="$PATH:$FNM_DEFAULT_BIN" ;;
  esac
fi

# --- pnpm global tools ---
export PNPM_HOME="$HOME/.local/share/pnpm"
for pnpm_dir in "$PNPM_HOME/bin" "$PNPM_HOME"; do
  if [ -d "$pnpm_dir" ]; then
    case ":$PATH:" in
      *":$pnpm_dir:"*) ;;
      *) export PATH="$pnpm_dir:$PATH" ;;
    esac
  fi
done

rehash 2>/dev/null || true
EOF

# 3. Reload ZSH so that fnm is available
exec zsh
```

#### 2. Install Node LTS and enable pnpm

```shell
# 4. Verify fnm first. If this fails, fix the shlib integration before continuing.
command -v fnm && fnm --version

# 5. Install Node LTS and set it as default
fnm install --lts
fnm use lts-latest
fnm default lts-latest

# 6. Enable Corepack shims, including pnpm and pnpx
corepack enable
corepack prepare pnpm@latest --activate

# 7. Reload once so the persistent default alias and Corepack shims are visible
exec zsh
```

#### 3. Verify the Node layer before installing global tools

```shell
# Required commands
for cmd in fnm node npm corepack pnpm npx; do
  command -v "$cmd" || { echo "❌ missing: $cmd"; return 1 2>/dev/null || exit 1; }
done

# Versions
fnm current
node --version
npm --version
corepack --version
pnpm --version
npx --version

# Persistent default bin must exist; systemd services must use this, not /run/user/.../fnm_multishells/...
NODE_DEFAULT_BIN="$HOME/.local/share/fnm/aliases/default/bin"
[ -x "$NODE_DEFAULT_BIN/node" ] || { echo "❌ missing persistent Node default bin"; return 1 2>/dev/null || exit 1; }

# Detect stale fnm multishell paths and suspicious copied PATH exports in shlib files
if grep -R "fnm_multishells" ~/.shlib/shlibs 2>/dev/null; then
  echo "⚠️ Review these shlib lines. Do not keep stale fnm_multishells paths."
fi
if grep -R -E '^export PATH=([^"$]|"[^$]*")' ~/.shlib/shlibs 2>/dev/null; then
  echo "⚠️ Review these shlib lines. Do not keep copied full PATH snapshots."
fi

# pnpm global bin directory should be stable and in PATH
PNPM_GLOBAL_BIN="$(pnpm bin -g)"
[ -d "$PNPM_GLOBAL_BIN" ] || { echo "❌ pnpm global bin directory missing: $PNPM_GLOBAL_BIN"; return 1 2>/dev/null || exit 1; }
case ":$PATH:" in
  *":$PNPM_GLOBAL_BIN:"*) ;;
  *) echo "❌ pnpm global bin is not in PATH: $PNPM_GLOBAL_BIN"; return 1 2>/dev/null || exit 1 ;;
esac
```

#### 4. Install global tools

```shell
pnpm add -g @kilocode/cli
pnpm add -g pm2

# Verify installed global CLIs
command -v kilocode
command -v pm2

# 7. Set up PM2 as a systemd service
pm2 startup systemd
```
