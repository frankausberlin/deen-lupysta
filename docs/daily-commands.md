# Daily Commands Reference

Quick lookup for all common operations. For full documentation, see [architecture.md](architecture.md).

## Project Initialization

```shell
pyinit                          # app in current directory
pyinit my-project               # app in new directory
pyinit my-lib --lib             # library in new directory
pyinit my-project --python 3.11 # specify Python version (default: 3.12)
pyinit my-project --force       # re-run and overwrite generated files
```

## Environment Management

### Mamba (Level 1 — Data Science)

```shell
act <envname>                              # activate + save to ~/.startenv
mamba activate <envname>                   # activate without saving
mamba deactivate                           # deactivate
mamba activate base                        # back to base
jupyter-launcher [folder]                  # start Jupyter Lab (token enabled)
jupyter-launcher -x [folder]               # start without token (unsafe)
jupyter-launcher --colab [folder]          # start with Colab origin
alias jl='jupyter-launcher -x'             # optional personal default
```

### UV/direnv (Level 2 — Projects)

```shell
direnv allow          # allow .envrc (run once per project)
uv sync               # sync environment after git pull or dependency change
```

## Dependencies

```shell
uv add <package>              # add runtime dependency
uv add --dev <package>        # add dev-only dependency
uv remove <package>           # remove dependency
uv sync                       # sync .venv with lock file
uv pip install <package>      # install directly (Level 1 only)
```

## Running Code

```shell
just run                            # run the main script
uv run python src/<project>/main.py # guaranteed sync (use in scripts/CI)
uvx <tool> <args>                   # run tool in ephemeral environment
```

## Testing

```shell
just test                   # run all tests with coverage
pytest -v                   # verbose output
pytest -k "test_name"       # run specific test
pytest -s                   # show stdout during tests
```

## Code Quality

```shell
just lint         # lint: find errors (ruff + basedpyright)
just typecheck    # type checking only
just check        # full local quality gate (lint + typecheck + tests)
just fix          # auto-fix formatting and lint issues
just audit        # security: scan dependencies for vulnerabilities
```

## Version & Release

```shell
# NEVER edit version numbers manually — always use:
just bump patch           # 0.2.0 → 0.2.1  (bugfixes)
just bump minor           # 0.2.1 → 0.3.0  (new features)
just bump major           # 0.3.0 → 1.0.0  (breaking changes)

# Push code AND tags
git push origin main --tags
```

## Git Workflow

```shell
# Feature development
git checkout -b feature/my-feature
just check
git add -A && git commit -m "feat: description"
git push origin feature/my-feature

# After git pull
uv sync
```

## Shell Functions

```shell
pyinit [name] [--lib] [--python X.Y] [--force]  # create project
act <envname>        # activate mamba env + save to ~/.startenv
jupyter-launcher [-x] [--colab] [dir]  # start Jupyter Lab
jl                   # alias for jupyter-launcher; customize in your shlib if desired
cw                   # cd to saved working folder
cw .                 # save current folder as working folder
rlb                  # reload shell configuration (source ~/.zshrc)
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Modules not found after `git pull` | `uv sync` |
| Wrong Python version | `uv python pin 3.12` |
| direnv not activating | `direnv allow` |
| Mamba env conflicts | recreate env (delete + create) |
| Lint errors | `just fix` |
| bump-my-version fails | Ensure clean git state (`git status`) |
