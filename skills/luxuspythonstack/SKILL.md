---
name: luxus-python-stack
description: >
  Expert knowledge of the Luxurious Python Stack — a five-level development workflow
  for Python projects using UV, direnv, ruff, basedpyright, and AI agent integration.
  This skill should be used PROACTIVELY when working on Python projects initialized
  with pyinit, when the user needs project scaffolding, environment management,
  quality gate automation, version bumping, or AI agent session workflow guidance.
---

# Luxurious Python Stack

## Overview

This skill provides expert knowledge of the Luxurious Python Stack — a five-level development workflow designed for flexible, conflict-free Python environment management. The stack separates concerns into distinct levels, each with specific tools and purposes.

For full documentation, load `references/luxus-python-stack.md`. For quick command lookup, see `references/daily-commands.md`. For DevEnv/setup context, browse `references/devenv/`.

## Installation Model

The canonical installation guide is `../../docs/installation.md`. The stack is installed by symbolic links, not by copying files. This keeps the repository checkout as the single source of truth and allows updates via `git pull`.

Agents should recommend the canonical guide instead of duplicating full install commands. The key rules are:

- Link `scripts/luxuspythonstacklib.sh` into the user's shlib setup with a user-chosen two-digit load-order prefix.
- Link the `skills/luxuspythonstack` folder into every agent-specific skills directory where this stack should be available.
- Avoid copy-based installation instructions.

## Maintenance / Update Policy

- Treat this repository checkout as the only editable source of truth.
- Do not patch files inside linked agent skills directories; edit the repository files instead.
- Do not replace symlinks with copied files during troubleshooting.
- Update installed integrations with `git pull` in the repository checkout, then reload the shell if shell functions changed.
- Keep detailed installation steps in `docs/installation.md`; keep this skill file focused on agent behavior and operational rules.

## Five-Level Architecture

| Level | Name | Tool | Activation |
|-------|------|------|------------|
| 0 | Global / System | `/usr/bin/python` | Always active (fallback) |
| 1 | Mamba / Jupyter | Mamba + UV | `act <envname>` or startup via `.startenv` |
| 2 | Projects | UV + direnv | Auto via `direnv` when `.venv` exists |
| 3 | CI / CD | GitHub Actions + UV | On push/PR or manual trigger |
| 4 | AI Agents | AGENTS.md + SESSION.md | Agent session start |

**Key principle**: Levels are isolated. Level 2 (.venv) overrides Level 1 (Mamba) in any directory with a `.venv` folder via `direnv`.

## Decision Tree

```
Starting fresh in a project directory?
  → Has .venv? → Already at Level 2 (direnv auto-activates)
  → No .venv?  → Run pyinit (see scripts/luxuspythonstacklib.sh) or uv init

Need to install a package?
  → In a project (.venv active): uv add <package>
  → In data science env:         uv pip install <package>
  → System-wide:                 avoid (use virtual envs)

Need to run code?
  → In terminal with direnv:  python src/...  (env auto-active)
  → In scripts/CI:            uv run python src/...  (guaranteed sync)

Need to release?
  → just bump [patch|minor|major]
  → git push origin main --tags
```

## Core Workflows

### 1. Initialize a New Python Project

Use the `pyinit` shell function (defined in [`scripts/luxuspythonstacklib.sh`](scripts/luxuspythonstacklib.sh)):

```shell
pyinit                              # app in current directory
pyinit my-project                   # app in new directory
pyinit my-lib --lib                 # library in new directory
pyinit my-project --python 3.11    # specify Python version (default: 3.12)
pyinit my-project --force          # re-run and overwrite generated files
```

The script creates:
- `src/<project>/` with `__init__.py`, `main.py` (app), or `py.typed` (lib)
- `tests/` with `__init__.py`, `conftest.py`, `test_placeholder.py`
- `pyproject.toml` with ruff, basedpyright, pytest, and bump-my-version config
- `.venv/` virtual environment (Python 3.12 by default)
- `.python-version`, `.vscode/` (settings, launch, extensions)
- `.envrc` for direnv auto-activation (with Conda deactivation guard)
- `.gitignore` (from gitignore.io + stack additions)
- `.editorconfig`, `Justfile`, `.pre-commit-config.yaml`
- `.github/workflows/ci.yml` and `release.yml`
- `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `LICENSE`
- **Library projects only:** `mkdocs.yml` + `docs/` with Material theme and mkdocstrings

After running pyinit, activate: `direnv allow`.

### 2. Environment Management

**Mamba environment (Level 1)**:
```shell
act ds12          # activates and saves to ~/.startenv
mamba activate ds12  # without saving
```

**Project environment (Level 2)**:
```shell
# direnv handles activation automatically when entering the directory
# If module errors arise after git pull:
uv sync
```

**Recreate Mamba environment**:
```shell
py=3.12 && ENV_NAME="ds${py: -2}"
mamba deactivate
mamba remove -y -n $ENV_NAME --all 2>/dev/null
mamba create -y -n $ENV_NAME python=$py <packages...>
mamba activate $ENV_NAME
```

### 3. Daily Development Commands

```shell
uv add <package>          # runtime dependency
uv add --dev <package>    # dev-only dependency
uv sync                   # sync environment

just run                  # run the main script
just test                 # pytest with coverage
just lint                 # ruff + basedpyright
just typecheck            # type checking only
just check                # full quality gate (lint + typecheck + tests)
just fix                  # auto-fix
just audit                # security scan
just pre-push             # CI checks (same as pre-push hook)
```

### 4. Release & Deployment

Never edit versions or create tags manually. Always use `bump-my-version`:

```shell
just bump patch           # 0.2.0 → 0.2.1
just bump minor           # 0.2.1 → 0.3.0
just bump major           # 0.3.0 → 1.0.0
git push origin main --tags
```

### 5. AI Agent Session Workflow (Level 4)

AI agents operate through MCP servers (web search, GitHub, Docker, browser automation, etc.) managed by MCPHub. Server setup is documented in `references/devenv/ai-stack.md` — load only when configuring agent infrastructure.

**Start:**
1. Read `AGENTS.md` for project context
2. Read `SESSION.md` if it exists
3. Run `uv sync` and `git status`
4. Begin work

**End:**
1. Run `just check` — must be green
2. Commit all changes
3. **Overwrite** `SESSION.md` with current state (volatile)
4. **Append** dated entry to `JOURNAL.md` (history, never overwrite)

## Key Shell Functions

Shell functions defined in `scripts/luxuspythonstacklib.sh`:

| Function | Usage | Description |
|----------|-------|-------------|
| `pyinit` | `pyinit [name] [--lib] [--python X.Y] [--force]` | Create a new Python project |
| `act` | `act <envname>` | Activate Mamba env + save to `.startenv` |
| `jl` | `jl [-x] [--colab] [folder]` | Start Jupyter Lab |
| `cw` | `cw` / `cw .` | Jump to / set working folder (global state) |
| `rlb` | `rlb` | Reload shell configuration |

## Important Rules

1. **`uv run` vs direct execution**: In scripts and CI always use `uv run` (auto-syncs). In terminal with direnv active, direct `python` is fine.

2. **Never mix uv packages into Mamba**: In Level 1, `uv pip install` is intentionally not under Mamba's control. The data science environment is disposable and rebuilt regularly.

3. **Version bumping**: Never edit `version =` in `pyproject.toml` or `__init__.py` manually. Never `git tag` manually. Always use `just bump`.

4. **direnv**: If auto-activation stops working, run `direnv allow` in the project directory.

5. **pre-push hook**: Install with `cp scripts/pre-push .git/hooks/pre-push` to run CI checks locally before pushing.

## Reference Files

Load on demand as needed:

- `references/luxus-python-stack.md` — Full stack documentation
- `references/daily-commands.md` — Complete command reference
- `references/blueprint-AGENTS.md` — Template for AGENTS.md generation
- `references/devenv/shlib-system.md` — Shell library system explanation
- `references/devenv/ubuntu-setup.md` — Ubuntu base system setup
- `references/devenv/zsh-setup.md` — ZSH, Antidote, p10k, fonts, prompt
- `references/devenv/ecosystems.md` — Node, Python, Go, Rust, Java, Ruby installation
- `references/devenv/networks-security.md` — SSH, UFW, fail2ban
- `references/devenv/docker-cuda.md` — Docker + NVIDIA container toolkit
- `references/devenv/ai-stack.md` — VSCode, Kilo, Ollama, MCPHub, SearXNG
