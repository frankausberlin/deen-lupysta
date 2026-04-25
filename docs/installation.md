# Installation

## Prerequisites

The Luxurious Python Stack requires the following installed at the system level:

| Tool | Purpose | Installation |
|------|---------|-------------|
| `uv` | Python version + package manager | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `direnv` | Auto-activate virtual environments | `brew install direnv` or `sudo apt install direnv` |
| `just` | Command runner | `brew install just` or `cargo install just` |
| `ruff` | Linting + formatting | `uv tool install ruff` |
| `basedpyright` | Strict type checking | `uv tool install basedpyright` |
| `mamba` | Data science environments (Level 1) | Miniforge installer |

For a full Ubuntu setup guide, see the `devenv/` references in the [skill](../skills/luxuspythonstack/references/devenv/).

### direnv Hook

The direnv hook must be at the **absolute end** of your shell configuration:

```shell
# In ~/.zshrc or ~/.bashrc (must be the LAST line)
eval "$(direnv hook zsh)"   # or: eval "$(direnv hook bash)"
```

### direnv Utility Function (Fallback)

If `use uv` is not available in your direnv version, create or verify `~/.config/direnv/direnvrc`:

```bash
layout_uv() {
    [ ! -d ".venv" ] && uv venv
    export VIRTUAL_ENV="$(pwd)/.venv" && PATH_add "$VIRTUAL_ENV/bin"
    export UV_PROJECT_ENVIRONMENT="$VIRTUAL_ENV"
}
```

## Shell Library Installation

This file is the canonical source for installation and update instructions. Other project files should link here instead of duplicating full command blocks.

The recommended installation is a symbolic link. Do **not** copy the shell library into your shell setup. A symlink keeps the live repository as the source of truth, so updates are only:

```shell
cd /path/to/deen-lupysta
git pull
```

### Direct Shell Sourcing

For a minimal setup, source the repository file directly in your `.zshrc` or `.bashrc`:

```shell
source /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh
```

### shlib Integration

If you use the [shlib system](../skills/luxuspythonstack/references/devenv/shlib-system.md), create a symlink in your shlib directory. Choose the two-digit prefix yourself according to your load order; `80` is only an example.

```shell
ln -s /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh \
      /path/to/.shlib/shlibs/80-luxuspythonstack.sh
```

Use a different number when it fits your shlib layout better, for example `70-luxuspythonstack.sh` or `85-luxuspythonstack.sh`.

### Agent Skill Installation

Install the AI agent skill with symlinks as well. Link the repository folder into every agent-specific skills directory where the stack should be available:

```shell
ln -s /path/to/deen-lupysta/skills/luxuspythonstack \
      /path/to/agent/skills/luxuspythonstack

# Repeat for additional agents if needed:
ln -s /path/to/deen-lupysta/skills/luxuspythonstack \
      /path/to/other-agent/skills/luxuspythonstack
```

This keeps the shell library and all agent skill references updateable through the same repository checkout.

## Verify Installation

```shell
# All commands should be available
type pyinit act jl cw rlb
pyinit --help   # (if using shell function: pyinit with no args)
```
