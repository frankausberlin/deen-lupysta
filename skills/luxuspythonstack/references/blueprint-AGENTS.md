# AGENTS.md — {{PROJECT_NAME}}

## Build / Test / Lint

```bash
just check   # ruff check + ruff format --check + basedpyright + pytest --cov
just fix     # ruff auto-fix + format
just test    # pytest with coverage
just lint    # ruff + basedpyright (without tests)
```

## Code Style

- Python {{PYTHON_VERSION}}, strict type checking (basedpyright)
- Google-style docstrings for all public functions
- Line length 120 (ruff)
- `from __future__ import annotations` in every file
- Typer for CLI, pydantic for models, rich for console output

## Architecture

- `src/{{PACKAGE_NAME}}/main.py` — Application entrypoint
- `src/{{PACKAGE_NAME}}/` — Core logic modules
- `tests/` — Test suite with pytest-cov

## Rules

- No comments in code (ruff D rule)
- No dead code, no unused imports
- Exception handling with `raise ... from exc` (ruff B904)
- Typer options via `Annotated` (ruff B008)
- Tests in `tests/`, coverage via `pytest-cov`

## Session Workflow (Level 4 — Vibe Coding)

1. **Start:** Read `SESSION.md` (if present) for context, then `uv sync`, then `git status`
2. **Work:** Write code, `just check` must be green at the end
3. **End:** **Overwrite** `SESSION.md` with summary (volatile). **Append** dated entry to `JOURNAL.md` (history). Both are in `.gitignore`

## Debugging

- Test-driven: `uv run pytest -k <name> -s` (stdout visible with `-s`)
- Logging: `colorlog` available as dev-dependency
- Read the full traceback — identify origin in `src/` or third-party dependency

## Troubleshooting

- `ModuleNotFoundError` → `uv sync` or forgot `uv run`
- `just check` fails → `just fix` first, then manually resolve
- `bump-my-version` fails → working tree must be clean
