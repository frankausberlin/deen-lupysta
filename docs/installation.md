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

Source the shell library in your `.zshrc` or `.bashrc`:

```shell
source /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh
```

### shlib Integration

If you use the [shlib system](skills/luxuspythonstack/references/devenv/shlib-system.md), copy the library to your shlib directory:

```shell
cp /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh \
   ~/.shlib/shlibs/80-luxuspythonstack.sh
```

## Verify Installation

```shell
# All commands should be available
type pyinit act jl cw rlb
pyinit --help   # (if using shell function: pyinit with no args)
```
