![](https://lh3.googleusercontent.com/d/1JdavIkcaCKkXrqiJtGHpAMvXAp73Z8tA)

# Developer Environment & Luxurious Python Stack

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

1. Follow the canonical [installation guide](docs/installation.md) for prerequisites, shell integration, agent skill symlinks, and updates.
2. Ensure the direnv hook is at the absolute end of your shell config.
3. Create your first project:

   ```bash
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
| `jupyter-launcher [-x] [--colab] [dir]` | Start Jupyter Lab |
| `jl` | Configurable alias for `jupyter-launcher` |
| `cw` / `cw .` | Jump to / set working folder |
| `rlb` | Reload shell configuration |

## License

MIT — see [LICENSE](LICENSE).
