# deen-lupysta — Developer Environment & Luxurious Python Stack

A curated, battle-tested development environment and Python workflow — from bare Ubuntu to production-ready CI/CD with AI agent integration.

This repository contains the **documentation**, **shell library**, and **AI agent skill** for the Luxurious Python Stack.

## What's inside

| Directory | Purpose |
|-----------|---------|
| `docs/` | Human-readable documentation |
| `skills/luxuspythonstack/` | Anthropic-conformant AI agent skill |
| `skills/luxuspythonstack/scripts/` | Shell functions: `pyinit`, `act`, `jl`, `cw`, `rlb` |
| `skills/luxuspythonstack/references/` | Detailed reference docs for AI agents |

## Quick Start

```bash
# 1. Install prerequisites (see docs/installation.md)
# 2. Source the shell library
source /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh

# 3. Ensure direnv hook is at the END of .zshrc
eval "$(direnv hook zsh)"

# 4. Create your first project
pyinit my-project
```

## Documentation

- **[Installation](docs/installation.md)** — System prerequisites, direnv, UV, Mamba
- **[Architecture](docs/architecture.md)** — Five-level concept explained
- **[Daily Commands](docs/daily-commands.md)** — Quick reference for all operations
- **[Agent Workflow](docs/agent-workflow.md)** — AI agent session lifecycle
- **[Skill](skills/luxuspythonstack/SKILL.md)** — AI agent instructions

## Shell Functions

| Function | Description |
|----------|-------------|
| `pyinit [name] [--lib] [--python X.Y] [--force]` | Initialize a Python project |
| `act <env>` | Activate Mamba environment |
| `jl [-x] [--colab] [dir]` | Start Jupyter Lab |
| `cw` / `cw .` | Jump to / set working folder |
| `rlb` | Reload shell configuration |

## License

MIT — see [LICENSE](LICENSE).
