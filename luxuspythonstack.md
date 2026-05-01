# Luxurious Python Stack — Documentation

The Luxurious Python Stack is a combination of tools, scripts, aliases, and rules for efficient, conflict-free Python development. Its five-level architecture separates concerns into distinct layers, each with specific tools and mechanisms.

* For AI Agents
> The [skill](skills/luxuspythonstack/SKILL.md) provides structured instructions for AI coding agents working on projects initialized with this stack.


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

### direnv Utility Function

Create or verify `~/.config/direnv/direnvrc` with the `layout_uv` function:

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

# Architecture — Five-Level Concept

The Luxurious Python Stack separates concerns into five distinct layers. Each level has specific tools and purposes, ensuring environments never conflict.

## Level Overview

| Level | Name | Tool | Activation |
|-------|------|------|------------|
| 0 | Global / System | `/usr/bin/python` | Always active (fallback) |
| 1 | Mamba / Jupyter | Mamba + UV | `act <envname>` or startup via `.startenv` |
| 2 | Projects | UV + direnv | Auto via `direnv` when `.venv` exists |
| 3 | CI / CD | GitHub Actions + UV | On push/PR or manual trigger |
| 4 | AI Agents | AGENTS.md + SESSION.md | Agent session start |

## Level 0: Global / System

- The standard Python installation lives here (`/usr/bin/python`)
- Core tools installed via system package manager: `uv`, `just`, `ruff` (via `uv tool`), `basedpyright`, `direnv`
- Mamba/conda is installed but inactive until explicitly activated
- The system level is the fallback when no other environment is active

## Level 1: Mamba / Jupyter

- Intended for data science and experimentation
- Tools: Jupyter Lab, PyTorch, TensorFlow, Scikit-Learn, etc.
- Always active unless a `.venv` exists at the current location (superseded by direnv)
- **Startup:** `act <envname>` activates the environment and saves it to `~/.startenv`
- **Volatile:** The rule is "no updates, just delete and recreate"
- **Naming convention:** `ds12` = "data science Python 3.12"
- `uv pip install` is used for speed inside Mamba environments (intentionally not under Mamba's control)

## Level 2: Projects

- Standard Python projects managed with `uv` + `direnv`
- Activated automatically via `direnv` when a directory contains `.venv`
- Initialized with `pyinit [--app|--lib]`
- Quality gate: `just check` → ruff + basedpyright + pytest + pip-audit
- Version bumping: `just bump patch|minor|major`

### Project Structure (created by pyinit)

```
src/<package_name>/
tests/
pyproject.toml
Justfile
AGENTS.md
.envrc
.pre-commit-config.yaml
.github/workflows/{ci,release}.yml
```

## Level 3: CI / CD

- Automated gatekeeper between local development and production
- Environment parity via `uv.lock`
- On every push/PR: automated `just check` runs
- Release automation: `bump-my-version` + Git tagging
- Automated PyPI publishing via GitHub Actions with OIDC Trusted Publishing

## Level 4: AI Agents

- `AGENTS.md` (tracked in git): project overview, conventions, key commands
- `SESSION.md` (gitignored, volatile): overwritten each session with current state
- `JOURNAL.md` (gitignored, append-only): accumulated session history
- Session workflow: read → work → check → commit → update session files

## Level Interactions

Levels are layered and override each other:

```
Level 2 (.venv via direnv)
    overrides
Level 1 (Mamba)
    overrides
Level 0 (System Python)
```

When direnv detects a `.venv` in the current directory, it automatically deactivates the Mamba environment and activates the project's `.venv`. This ensures isolation without manual switching.


# Luxus Python Stack — Daily Commands

Quick reference for all common operations. For full documentation, see `references/luxus-python-stack.md`.

## Project Initialization

```shell
pyinit                          # app in current directory
pyinit my-project               # app in new directory
pyinit my-lib --lib             # library in new directory
pyinit my-project --python 3.11 # specify Python version (default: 3.12)
pyinit my-project --force       # re-run, overwrite generated files
```

## Environment Management

```shell
# Mamba (Level 1 — Data Science)
act <envname>             # activate + save to ~/.startenv
mamba activate <envname>  # activate without saving
mamba deactivate          # deactivate
jupyter-launcher [folder]          # Jupyter Lab (token enabled)
jupyter-launcher -x [folder]       # Jupyter Lab without token (unsafe)
jupyter-launcher --colab [folder]  # Jupyter Lab with Colab origin
alias jl='jupyter-launcher -x'     # optional personal default

# UV/direnv (Level 2 — Projects)
direnv allow   # allow .envrc (once per project)
uv sync        # sync after git pull / dependency change
```

## Dependencies

```shell
uv add <package>          # runtime dependency
uv add --dev <package>    # dev-only dependency
uv remove <package>       # remove
uv sync                   # sync .venv with lock file
uv pip install <package>  # Level 1 only
```

## Running Code

```shell
just run                            # main script
uv run python src/<pkg>/main.py     # guaranteed sync (CI/scripts)
uvx <tool> <args>                   # ephemeral tool run
```

## Testing

```shell
just test                       # all tests with coverage
pytest -v                       # verbose
pytest -k "test_name" -s        # specific test, show stdout
```

## Code Quality

```shell
just lint         # ruff + basedpyright
just typecheck    # type checking only
just check        # full gate (lint + typecheck + tests)
just fix          # auto-fix
just audit        # security: pip-audit
just pre-push     # CI checks before git push
```

## Version & Release

```shell
just bump patch   # 0.2.0 → 0.2.1
just bump minor   # 0.2.1 → 0.3.0
just bump major   # 0.3.0 → 1.0.0
git push origin main --tags
```

## Git Workflow

```shell
git checkout -b feature/my-feature
just check
git add -A && git commit -m "feat: ..."
git push origin feature/my-feature

# After git pull: uv sync
```

## Shell Functions

```shell
pyinit [name] [--lib] [--python X.Y] [--force]
act <envname>
jupyter-launcher [-x] [--colab] [dir]
jl  # alias for jupyter-launcher; customize locally if desired
cw / cw .
rlb
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| ModuleNotFoundError | `uv sync` or forgot `uv run` |
| Wrong Python version | `uv python pin 3.12` |
| direnv not activating | `direnv allow` |
| Mamba env conflicts | recreate env |
| Lint errors | `just fix` |
| bump-my-version fails | clean git state required |

# AI Agent Workflow (Level 4 — Vibe Coding)

The Luxurious Python Stack includes a structured session workflow for AI coding agents. This ensures the agent maintains context across sessions and follows project conventions.

## Core Files

| File | Location | Git | Purpose |
|------|----------|-----|---------|
| `AGENTS.md` | Project root | Tracked | Project overview, conventions, commands |
| `SESSION.md` | Project root | Gitignored | Volatile session snapshot (overwritten each session) |
| `JOURNAL.md` | Project root | Gitignored | Append-only session history |

## AGENTS.md

Generated by `pyinit` from a blueprint template. Contains:

- Build / test / lint commands
- Code style rules
- Architecture overview
- Session workflow instructions
- Debugging protocol
- Troubleshooting guide

An AI agent reads `AGENTS.md` at session start to understand how to work on the project.

## SESSION.md

Volatile memory file. **Overwritten** at the end of each session with:

- What was accomplished
- Current state of the codebase
- Open issues or next steps

Read at session start to restore context from the previous session.

## JOURNAL.md

Append-only history. A new **dated entry is appended** at session end:

```markdown
## 2026-04-25 — Feature X Implementation

Implemented feature X. Added tests. Fixed bug Y.
```

Never overwrite — provides historical debugging context.

## Session Workflow

### Session Start

1. Read `AGENTS.md` for project context
2. Read `SESSION.md` if it exists (last session snapshot)
3. Run `uv sync` to ensure environment is current
4. Run `git status` to check working tree state
5. Begin work

### During Session

1. Write code following project conventions
2. Run `just check` before considering work complete
3. Follow the debugging protocol for errors

### Session End

1. Run `just check` — must pass
2. Commit all changes: `git add -A && git commit -m "..."`
3. **Overwrite** `SESSION.md` with current state summary
4. **Append** dated entry to `JOURNAL.md`

### Session End Template (SESSION.md)

```markdown
# Session Summary — YYYY-MM-DD

## What was accomplished
- ...

## Current state
- ...

## Next steps
- ...
```

### Session End Template (JOURNAL.md)

```markdown
## YYYY-MM-DD — Session Notes
- Feature X implemented
- Bug Y fixed
- Tests passing: N passed
```

## Debugging Protocol

1. **Test-Driven Debugging**: Write or isolate a failing test first
   - `uv run pytest -k <test_name> -s` (stdout visible with `-s`)
2. **Logging over Printing**: Use `colorlog` (dev-dependency) for complex state tracking
3. **Traceback Analysis**: Read the FULL traceback. Identify origin in `src/` or third-party dependency
4. **Interactive State**: Use `breakpoint()` (pdb) for local variable inspection

## Troubleshooting

| Symptom | Solution |
|---------|----------|
| `ModuleNotFoundError` | `uv sync` or forgot `uv run` |
| `just check` fails | `just fix` first, then manually resolve |
| `bump-my-version` fails | Working tree must be clean |
