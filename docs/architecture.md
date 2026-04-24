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
