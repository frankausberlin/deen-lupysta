# Luxurious Python Stack — Full Documentation

## Overview

The Luxurious Python Stack is a combination of tools, scripts, aliases, and rules for efficient, conflict-free Python development. Its five-level architecture separates concerns into distinct layers, each with specific tools and activation mechanisms.

## Tools

- **Mamba**: Fast package manager for data science environments (C-extensions, CUDA, ML frameworks)
- **UV**: Python version manager + package manager + virtual environments (Rust-based, lightning fast)
- **direnv**: Auto-activates `.venv` when entering a project directory, deactivates when leaving
- **Ruff + basedpyright**: Linting, formatting, and strict type checking
- **bump-my-version**: Automated semantic versioning with Git tag synchronization
- **Just**: Command runner — all project operations in one file

## Five-Level Architecture

See [architecture.md](../../docs/architecture.md) for detailed explanation.

**Level isolation:** Level 2 (.venv) overrides Level 1 (Mamba) in any directory with a `.venv` folder via `direnv`.

## Shell Library Functions

Defined in `scripts/luxuspythonstacklib.sh`:

### Installation and Updates

The canonical installation guide is `../../docs/installation.md`. Install the shell library and agent skill via symbolic links. Do not copy either the `.sh` file or the skill folder; symlinks keep the checked-out repository as the source of truth.

The shlib number is user-defined and controls load order. Repeat the skill folder symlink for every agent skills directory that should provide this stack. Update the stack with `git pull` in the repository checkout.

### pyinit — Project Initializer

Creates a complete Python project with all files and folders. Supports `--lib`, `--python X.Y`, and `--force` flags.

Arguments:
- Positional: project name (creates directory) or `.` (current directory)
- `--lib`: initialize as a library instead of application
- `--python X.Y`: Python version (default: 3.12)
- `--force`: overwrite existing generated files

Generated files:
- `src/<package>/` with `__init__.py`, `main.py` (app) or `py.typed` (lib)
- `tests/` with `__init__.py`, `conftest.py`, `test_placeholder.py`
- `pyproject.toml` with ruff, basedpyright, pytest, bump-my-version config
- `.venv/` (Python 3.12 default), `.python-version`
- `.vscode/` with settings, launch, extensions
- `.envrc` with `layout uv` and direnv setup
- `.gitignore` (fetched from gitignore.io + stack additions)
- `.editorconfig` for cross-editor consistency
- `Justfile` with test/lint/check/fix/bump/audit/run recipes
- `.pre-commit-config.yaml` with ruff hooks
- `.github/workflows/{ci,release}.yml`
- `AGENTS.md` generated from blueprint
- `README.md`, `CONTRIBUTING.md`, `LICENSE` (MIT)
- **Library only:** `mkdocs.yml` + `docs/` with Material theme and mkdocstrings

Idempotency: re-running without `--force` skips existing files. `--force` regenerates all generated files but preserves user-customized `[tool.*]` sections in `pyproject.toml`.

### act — Activate Mamba Environment

Activates a Mamba environment and saves it to `~/.startenv` for automatic reactivation in new terminals.

```shell
act ds12     # activate ds12 and save
act base     # switch to base and save
```

### jl — Jupyter Lab Launcher

Start Jupyter Lab with sensible defaults.

```shell
jl              # current directory, token enabled (secure)
jl -x           # without token (unsafe, local-only)
jl --colab      # allow Colab origin
jl my-notebooks # start in specific directory
```

### cw — Current Working Folder

Jump to or set a globally saved working folder.

```shell
cw              # cd to saved folder
cw .            # save current directory as working folder
```

⚠️ Global state: stored in `~/.config/current_working_folder`, shared across ALL terminals. Setting `cw .` in one terminal overwrites it for all terminals.

### rlb — Reload Shell

```shell
rlb     # source ~/.zshrc (reload shell configuration)
```

## Project Conventions (Level 2)

### Code Style

- Python 3.12+, strict type checking (basedpyright `strict` mode)
- Google-style docstrings for all public functions
- Line length 120 (ruff)
- `from __future__ import annotations` in every file
- No comments in code (ruff D rule)
- Typer for CLI, pydantic for models, rich for console output

### Quality Gate (`just check`)

Runs in order:
1. `ruff check .` — linting
2. `ruff format --check .` — formatting verification
3. `basedpyright` — strict type checking
4. `pytest --cov=src --cov-report=term-missing` — tests with coverage

Any failure blocks the gate. Run `just fix` first for auto-fixable issues, then manually resolve the rest.

### Version Bumping

Never edit version numbers manually. The `bump` recipe:
1. Checks working tree is clean
2. Runs `bump-my-version bump <part>`
3. Creates a commit with standardized message
4. Creates a Git tag (`v{new_version}`)

### CI/CD (Level 3)

GitHub Actions workflows:

**ci.yml** (on push/PR):
- Checkout + setup-uv + setup-just
- `uv sync --dev`
- `just check`
- `uv run pip-audit` (security scan)

**release.yml** (on tag `v*`):
- `uv build`
- `uv publish` (OIDC Trusted Publishing)

## AI Agent Integration (Level 4)

For details on SESSION.md, JOURNAL.md, and the agent session workflow, see [agent-workflow.md](../../docs/agent-workflow.md).

AI agents use MCP servers to interact with tools and filesystems. A pre-configured collection of MCP servers (web search, GitHub, Docker, browser automation, etc.) managed by MCPHub is documented in `references/devenv/ai-stack.md` — load only when setting up agent infrastructure.

## Tool Version Precedence

`ruff` and `basedpyright` are installed both globally (`uv tool install`) and as per-project dev dependencies. When `direnv` activates a project's `.venv`, project-local binaries take precedence over global ones. Always use `uv run ruff ...` in scripts, CI, and automation to guarantee the project-pinned version runs.

## Shell Library Maintenance

`scripts/luxuspythonstacklib.sh` intentionally remains a single file for now because this makes symlink-based installation simple and robust. If it keeps growing, split it into smaller source modules only when there is also a build or concat step that produces one stable `luxuspythonstacklib.sh` target for shlib users.

## System Requirements

Designed for **Linux (Debian/Ubuntu)**. macOS and other distributions may require manual adaptation of the base system setup. See `references/devenv/ubuntu-setup.md` for full system bootstrap.
