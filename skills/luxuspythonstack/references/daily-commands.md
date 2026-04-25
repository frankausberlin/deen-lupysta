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
